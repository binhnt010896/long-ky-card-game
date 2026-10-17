import 'package:lk_rules/lk_rules.dart';

import 'issues.dart';
import 'model.dart';
import 'reader.dart';

/// A reference from one content item to another, checked after parsing.
final class Ref {
  const Ref(this.kind, this.id, this.file, this.path, {this.scope});

  final RefKind kind;
  final String id;
  final String file;
  final String path;

  /// For nodes: the map id; for armies: the mission id.
  final String? scope;
}

enum RefKind { officer, commander, card, map, node, army, source, longKyPerson, longKyEvent, image, audio }

/// Parses content files into definitions, recording references and every
/// schema problem in [issues].
final class ContentParser {
  ContentParser(this.issues);

  final Issues issues;
  final List<Ref> refs = [];

  // -- Files -----------------------------------------------------------------

  List<T> parseList<T>(String file, Object? json, String what, T? Function(Obj o) parse) {
    if (json is! List<Object?>) {
      issues.error(Rule.schema, 'type', file, r'$', 'expected a list of $what');
      return const [];
    }
    final out = <T>[];
    for (var i = 0; i < json.length; i++) {
      final o = Obj.from(issues, file, '\$[$i]', json[i]);
      if (o == null) continue;
      final v = parse(o);
      o.done();
      if (v != null) out.add(v);
    }
    return out;
  }

  T? parseObject<T>(String file, Object? json, T Function(Obj o) parse) {
    final o = Obj.from(issues, file, r'$', json);
    if (o == null) return null;
    final v = parse(o);
    o.done();
    return v;
  }

  void _todo(Obj o) => o.strings('todo', required: false);

  List<String> _sourceRefs(Obj o) {
    final ids = o.strings('sourceRefs');
    for (var i = 0; i < ids.length; i++) {
      refs.add(Ref(RefKind.source, ids[i], o.file, '${o.sub('sourceRefs')}[$i]'));
    }
    return ids;
  }

  String? _longKy(Obj o, String key, RefKind kind) {
    final id = o.strOrNull(key, required: true);
    if (id != null) refs.add(Ref(kind, id, o.file, o.sub(key)));
    return id;
  }

  String? _image(Obj o, String key, {bool required = true}) {
    final p = o.strOrNull(key, required: required);
    if (p != null) refs.add(Ref(RefKind.image, p, o.file, o.sub(key)));
    return p;
  }

  // -- Sources and Long Ký ids -------------------------------------------------

  SourceDef? source(Obj o) {
    final s = SourceDef(
      id: o.str('id'),
      work: o.str('work'),
      publisher: o.strOrNull('publisher'),
      url: o.strOrNull('url'),
      section: o.strOrNull('section'),
      author: o.strOrNull('author'),
      note: o.strOrNull('note'),
    );
    if (s.work.trim().isEmpty) issues.error(Rule.schema, 'emptyText', o.file, o.sub('work'), 'work must not be empty');
    _todo(o);
    return s;
  }

  LongKyIds longKyIds(Obj o) {
    final ids = LongKyIds(people: o.strings('people').toSet(), events: o.strings('events').toSet());
    o.strOrNull('generatedFrom');
    o.strOrNull('note');
    return ids;
  }

  // -- Officers and commanders ----------------------------------------------

  OfficerDef? officer(Obj o) {
    final id = o.str('id');
    final statsObj = o.obj('stats');
    OfficerStats stats = const OfficerStats(leadership: 0, war: 0, intelligence: 0, politics: 0, loyalty: 0);
    if (statsObj != null) {
      stats = OfficerStats(
        leadership: statsObj.integer('leadership', min: 1, max: 10),
        war: statsObj.integer('war', min: 1, max: 10),
        intelligence: statsObj.integer('intelligence', min: 1, max: 10),
        politics: statsObj.integer('politics', min: 1, max: 10),
        loyalty: statsObj.integer('loyalty', min: 1, max: 10),
      );
      statsObj.done();
    }
    final skillObj = o.obj('skill', nullable: true);
    final skill = skillObj == null ? null : _skill(skillObj);
    skillObj?.done();
    final flawObj = o.obj('flaw', nullable: true);
    final flaw = flawObj == null ? null : _flaw(flawObj);
    flawObj?.done();
    final art = o.obj('art');
    final portrait = art == null ? null : _image(art, 'portrait');
    final card = art == null ? null : _image(art, 'card');
    art?.done();
    final def = OfficerDef(
      id: id,
      longKyPersonId: _longKy(o, 'longKyPersonId', RefKind.longKyPerson),
      name: o.text('name'),
      title: o.textOrNull('title', required: false),
      stats: stats,
      loyaltyLocked: o.boolean('loyaltyLocked'),
      isKing: o.boolean('isKing'),
      skill: skill,
      flaw: flaw,
      portraitArt: portrait,
      cardArt: card,
      sourceRefs: _sourceRefs(o),
    );
    _todo(o);
    if (def.isKing != (flaw?.id == FlawIds.isKing)) {
      issues.error(Rule.schema, 'kingFlaw', o.file, o.path, 'isKing must be true exactly when the flaw is "isKing"');
    }
    return def;
  }

  SkillDef _skill(Obj o) {
    final id = o.str('id');
    final kind = o.enumValue('kind', SkillKind.values);
    final target = o.enumValue('target', TargetKind.values, defaultValue: TargetKind.none);
    final name = o.text('name');
    final text = o.text('text');
    if (kind == SkillKind.passive) {
      if (!PassiveIds.all.contains(id)) {
        issues.error(Rule.closedLists, 'unknownPassive', o.file, o.sub('id'), 'passive skill "$id" is not in the closed list');
      }
      if (o.has('effects') || o.has('usesPerMission')) {
        o.list('effects', required: false);
        o.intOrNull('usesPerMission');
        issues.error(Rule.schema, 'passiveEffects', o.file, o.path, 'passive skills have no effects or uses');
      }
      return SkillDef(id: id, kind: kind, name: name, text: text);
    }
    final uses = o.integer('usesPerMission', min: 1);
    final effects = effectList(o, 'effects', target);
    return SkillDef(id: id, kind: kind, usesPerMission: uses, target: target, name: name, text: text, effects: effects);
  }

  FlawDef _flaw(Obj o) {
    final id = o.str('id');
    if (!FlawIds.all.contains(id)) {
      issues.error(Rule.closedLists, 'unknownFlaw', o.file, o.sub('id'), 'flaw "$id" is not in the closed list');
    }
    final value = o.intOrNull('value', required: id == FlawIds.troopCap, min: 1);
    return FlawDef(id: id, value: value, name: o.text('name'), text: o.text('text'));
  }

  CommanderDef? commander(Obj o) {
    final statsObj = o.obj('stats');
    var stats = const CommanderStats(leadership: 0, war: 0, intelligence: 0);
    if (statsObj != null) {
      stats = CommanderStats(
        leadership: statsObj.integer('leadership', min: 1, max: 10),
        war: statsObj.integer('war', min: 1, max: 10),
        intelligence: statsObj.integer('intelligence', min: 1, max: 10),
      );
      statsObj.done();
    }
    final art = o.obj('art');
    final portrait = art == null ? null : _image(art, 'portrait');
    final card = art == null ? null : _image(art, 'card');
    art?.done();
    final def = CommanderDef(
      id: o.str('id'),
      longKyPersonId: _longKy(o, 'longKyPersonId', RefKind.longKyPerson),
      name: o.text('name'),
      title: o.textOrNull('title'),
      stats: stats,
      portraitArt: portrait,
      cardArt: card,
      sourceRefs: _sourceRefs(o),
    );
    _todo(o);
    return def;
  }

  // -- Cards, effects, conditions -------------------------------------------

  CardDef? card(Obj o) {
    final target = o.enumValue('target', TargetKind.values);
    final costObj = o.obj('cost');
    var cost = const CardCost();
    if (costObj != null) {
      cost = CardCost(rice: costObj.integer('rice', min: 0), support: costObj.integer('support', min: 0));
      costObj.done();
    }
    final def = CardDef(
      id: o.str('id'),
      type: o.enumValue('type', CardType.values),
      name: o.text('name'),
      text: o.text('text'),
      cost: cost,
      target: target,
      conditions: o.objects('conditions', (c) => _condition(c, target)),
      effects: effectList(o, 'effects', target),
      longKyEventId: _longKy(o, 'longKyEventId', RefKind.longKyEvent),
      art: _image(o, 'art'),
      sourceRefs: _sourceRefs(o),
    );
    _todo(o);
    return def;
  }

  /// Effects under [key]. A `choice` must be the last effect in its list.
  List<EffectDef> effectList(Obj o, String key, TargetKind target) {
    final effects = o.objects(key, (e) => _effect(e, target));
    for (var i = 0; i < effects.length - 1; i++) {
      if (effects[i] is ChoiceEffect) {
        issues.error(Rule.schema, 'choiceNotLast', o.file, '${o.sub(key)}[$i]', 'choice must be the last effect');
      }
    }
    return effects;
  }

  /// Checks that `$var` matches the card or skill target.
  String _var(Obj o, String key, TargetKind target, {Set<String> also = const {}}) {
    final v = o.str(key);
    if (also.contains(v)) return v;
    final expected = bindingVariable(target);
    if (v != expected) {
      issues.error(Rule.references, 'badVariable', o.file, o.sub(key),
          '"$v" does not match target ${target.name} (expected ${expected ?? 'no variable'})');
    }
    return v;
  }

  EffectDef? _effect(Obj o, TargetKind target) {
    final op = o.str('op');
    switch (op) {
      case 'modUnity':
        return ModUnityEffect(o.enumValue('pillar', Pillar.values), o.integer('delta'));
      case 'setUnity':
        return SetUnityEffect(o.enumValue('pillar', Pillar.values), o.integer('value', min: 0, max: 10));
      case 'modResource':
        return ModResourceEffect(o.enumValue('resource', Resource.values), o.integer('delta'));
      case 'evacuateNode':
        return EvacuateNodeEffect(_var(o, 'target', target));
      case 'withdrawOfficer':
        return WithdrawOfficerEffect(_var(o, 'target', target));
      case 'placeAmbush':
        return PlaceAmbushEffect(_var(o, 'target', target));
      case 'powerMultiplier':
        final t = _var(o, 'target', target);
        final value = o.number('value', min: 0);
        final duration = o.str('duration');
        if (duration != 'nextBattle') {
          issues.error(Rule.schema, 'unknownValue', o.file, o.sub('duration'), 'duration must be "nextBattle"');
        }
        return PowerMultiplierEffect(t, value, enemySupplyBelow: o.numberOrNull('enemySupplyBelow', min: 0, max: 1));
      case 'modArmy':
        return ModArmyEffect(
          _var(o, 'target', target, also: {ModArmyEffect.allArmies}),
          o.enumValue('field', ArmyField.values),
          o.integer('delta'),
        );
      case 'revealIntent':
        return RevealIntentEffect(o.integer('turnsAhead', min: 1));
      case 'skipTurn':
        return const SkipTurnEffect();
      case 'choice':
        final options = o.objects('options', (opt) => ChoiceOption(label: opt.text('label'), effects: effectList(opt, 'effects', target)));
        if (options.length < 2) {
          issues.error(Rule.schema, 'range', o.file, o.sub('options'), 'a choice needs at least two options');
        }
        return ChoiceEffect(options);
      default:
        issues.error(Rule.closedLists, 'unknownEffect', o.file, o.sub('op'), 'effect op "$op" is not in the closed list');
        o.markAllRead();
        return null;
    }
  }

  ConditionDef? _condition(Obj o, TargetKind target) {
    final op = o.str('op');
    switch (op) {
      case 'armySupplyBelowFraction':
        return ArmySupplyBelowFractionCondition(_var(o, 'target', target), o.number('value', min: 0, max: 1));
      case 'unityAtLeast':
        return UnityAtLeastCondition(o.enumValue('pillar', Pillar.values), o.integer('value', min: 0, max: 10));
      case 'nodeTerrain':
        return NodeTerrainCondition(_var(o, 'target', target), o.enumValue('terrain', Terrain.values));
      default:
        issues.error(Rule.closedLists, 'unknownCondition', o.file, o.sub('op'), 'condition "$op" is not in the closed list');
        o.markAllRead();
        return null;
    }
  }

  // -- Map -------------------------------------------------------------------

  MapDef map(Obj o) {
    final id = o.str('id');
    final nodes = o.objects(
      'nodes',
      (n) => NodeDef(
        id: n.str('id'),
        name: n.text('name'),
        terrain: n.enumValue('terrain', Terrain.values),
        x: n.number('x', min: 0, max: 1),
        y: n.number('y', min: 0, max: 1),
        riceYield: n.integer('riceYield', min: 0),
        isCapital: n.boolean('isCapital', defaultValue: false),
        isBorder: n.boolean('isBorder', defaultValue: false),
      ),
    );
    final edges = o.objects('edges', (e) {
      final edge = EdgeDef(from: e.str('from'), to: e.str('to'), kind: e.enumValue('kind', EdgeKind.values));
      refs.add(Ref(RefKind.node, edge.from, e.file, e.sub('from'), scope: id));
      refs.add(Ref(RefKind.node, edge.to, e.file, e.sub('to'), scope: id));
      if (edge.from == edge.to) issues.error(Rule.schema, 'loopEdge', e.file, e.path, 'an edge must join two nodes');
      return edge;
    });
    final image = _image(o, 'image', required: false);
    _todo(o);
    return MapDef(id: id, nodes: nodes, edges: edges, imagePath: image);
  }

  // -- Missions --------------------------------------------------------------

  MissionDef mission(Obj o) {
    final id = o.str('id');
    final mapId = o.str('map');
    refs.add(Ref(RefKind.map, mapId, o.file, o.sub('map')));
    String node(Obj x, String key) {
      final n = x.str(key);
      refs.add(Ref(RefKind.node, n, x.file, x.sub(key), scope: mapId));
      return n;
    }

    final startObj = o.obj('start');
    var start = const MissionStart(rice: 0, support: 0, unity: StartingUnity(court: 0, clan: 0, people: 0));
    if (startObj != null) {
      final u = startObj.obj('unity');
      var unity = const StartingUnity(court: 0, clan: 0, people: 0);
      if (u != null) {
        unity = StartingUnity(
          court: u.integer('court', min: 1, max: 10),
          clan: u.integer('clan', min: 1, max: 10),
          people: u.integer('people', min: 1, max: 10),
        );
        u.done();
      }
      start = MissionStart(rice: startObj.integer('rice', min: 0), support: startObj.integer('support', min: 0), unity: unity);
      startObj.done();
    }

    final officers = o.objects('playerOfficers', (p) {
      final officerId = p.str('officerId');
      refs.add(Ref(RefKind.officer, officerId, p.file, p.sub('officerId')));
      return PlayerOfficerSetup(officerId: officerId, nodeId: node(p, 'nodeId'), troops: p.integer('troops', min: 0));
    });

    final armies = o.objects('yuanArmies', (a) {
      final commanderId = a.str('commanderId');
      refs.add(Ref(RefKind.commander, commanderId, a.file, a.sub('commanderId')));
      final setup = YuanArmySetup(
        id: a.str('id'),
        commanderId: commanderId,
        nodeId: node(a, 'nodeId'),
        troops: a.integer('troops', min: 1),
        supply: a.integer('supply', min: 0),
        maxSupply: a.integer('maxSupply', min: 1),
        morale: a.integer('morale', min: 1, max: 10),
        retreatNodeId: node(a, 'retreatNodeId'),
      );
      if (setup.supply > setup.maxSupply) {
        issues.error(Rule.schema, 'range', a.file, a.sub('supply'), 'supply is above maxSupply');
      }
      return setup;
    });

    final deck = o.objects('deck', (d) {
      final cardId = d.str('cardId');
      refs.add(Ref(RefKind.card, cardId, d.file, d.sub('cardId')));
      return DeckEntry(cardId: cardId, count: d.integer('count', min: 1));
    });

    final scripted = o.objects('scriptedEvents', (e) {
      final cardId = e.str('cardId');
      refs.add(Ref(RefKind.card, cardId, e.file, e.sub('cardId')));
      return ScriptedEvent(turn: e.integer('turn', min: 1), cardId: cardId);
    }, required: false);

    final inducements = o.objects(
      'inducements',
      (i) => Inducement(turn: i.integer('turn', min: 1), threshold: i.integer('threshold', min: 0)),
      required: false,
    );

    final script = o.objects('yuanScript', (s) {
      final armyId = s.str('armyId');
      refs.add(Ref(RefKind.army, armyId, s.file, s.sub('armyId'), scope: id));
      final target = s.strOrNull('targetNodeId');
      if (target != null) refs.add(Ref(RefKind.node, target, s.file, s.sub('targetNodeId'), scope: mapId));
      return YuanScriptEntry(
        turn: s.integer('turn', min: 1),
        armyId: armyId,
        intent: s.enumValue('intent', IntentKind.values),
        targetNodeId: target,
      );
    }, required: false);

    final objectiveNode = o.strOrNull('yuanObjectiveNodeId');
    if (objectiveNode != null) {
      refs.add(Ref(RefKind.node, objectiveNode, o.file, o.sub('yuanObjectiveNodeId'), scope: mapId));
    }

    List<ObjectiveDef> objectives(String key) => o.objects(key, (x) => _objective(x, id, mapId));
    final win = objectives('win');
    final loss = objectives('loss');
    final stars = objectives('stars');
    if (stars.length != 3) {
      issues.error(Rule.schema, 'range', o.file, o.sub('stars'), 'a mission has exactly 3 stars');
    } else if (stars.first is! WonObjective) {
      issues.error(Rule.schema, 'starOne', o.file, '${o.sub('stars')}[0]', 'star 1 is always {"type": "won"}');
    }

    final tutorial = o.objects('tutorial', (t) {
      final until = t.strOrNull('until');
      TutorialCondition? condition;
      if (until != null) {
        condition = TutorialCondition.parse(until);
        if (condition == null) {
          issues.error(Rule.closedLists, 'unknownTutorialCondition', t.file, t.sub('until'),
              '"$until" is not in the closed list of tutorial conditions');
        } else {
          _tutorialRefs(condition, t, id, mapId);
        }
      }
      return TutorialStep(
        id: t.str('id'),
        text: t.text('text'),
        highlight: t.strOrNull('highlight'),
        until: condition,
      );
    }, required: false);

    final def = MissionDef(
      id: id,
      chapter: o.integer('chapter', min: 0),
      order: o.integer('order', min: 1),
      title: o.text('title'),
      briefing: o.text('briefing'),
      debrief: o.text('debrief'),
      mapId: mapId,
      seasonTurns: o.integer('seasonTurns', min: 1),
      heatStartTurn: o.intOrNull('heatStartTurn', required: true, min: 1),
      start: start,
      playerOfficers: officers,
      yuanArmies: armies,
      deck: deck,
      handSize: o.integer('handSize', min: 1),
      scriptedEvents: scripted,
      inducements: inducements,
      yuanScript: script,
      yuanObjectiveNodeId: objectiveNode,
      win: win,
      loss: loss,
      stars: stars,
      tutorial: tutorial,
      longKyEventId: _longKy(o, 'longKyEventId', RefKind.longKyEvent),
      sourceRefs: _sourceRefs(o),
      art: _image(o, 'art', required: false),
    );
    for (final key in ['briefing', 'debrief']) {
      refs.add(Ref(RefKind.audio, 'voice/${id}_$key.mp3', o.file, o.sub(key)));
    }
    _todo(o);
    return def;
  }

  /// Records the ids a tutorial condition names, to be checked like any other reference.
  void _tutorialRefs(TutorialCondition c, Obj o, String missionId, String mapId) {
    final path = o.sub('until');
    switch (c) {
      case SelectedCondition(:final kind, :final id) when kind != null && id != null:
        switch (kind) {
          case SelectionTarget.node:
            refs.add(Ref(RefKind.node, id, o.file, path, scope: mapId));
          case SelectionTarget.officer:
            refs.add(Ref(RefKind.officer, id, o.file, path));
          case SelectionTarget.army:
            refs.add(Ref(RefKind.army, id, o.file, path, scope: missionId));
        }
      case CardPlayedCondition(:final cardId):
        refs.add(Ref(RefKind.card, cardId, o.file, path));
      case SkillUsedCondition(:final officerId):
        refs.add(Ref(RefKind.officer, officerId, o.file, path));
      case OrderGivenCondition(:final officerId):
        refs.add(Ref(RefKind.officer, officerId, o.file, path));
      default:
        break;
    }
  }

  ObjectiveDef? _objective(Obj o, String missionId, String mapId) {
    if (o.has('anyOf')) {
      final list = o.objects('anyOf', (x) => _objective(x, missionId, mapId));
      if (list.length < 2) issues.error(Rule.schema, 'range', o.file, o.sub('anyOf'), 'anyOf needs at least two objectives');
      return AnyOfObjective(list);
    }
    String army() {
      final id = o.str('armyId');
      refs.add(Ref(RefKind.army, id, o.file, o.sub('armyId'), scope: missionId));
      return id;
    }

    String node() {
      final id = o.str('nodeId');
      refs.add(Ref(RefKind.node, id, o.file, o.sub('nodeId'), scope: mapId));
      return id;
    }

    final type = o.str('type');
    switch (type) {
      case 'allArmiesBroken':
        return const AllArmiesBrokenObjective();
      case 'armyBroken':
        return ArmyBrokenObjective(army());
      case 'counterattackAt':
        return CounterattackAtObjective(node());
      case 'surviveTurns':
        return SurviveTurnsObjective(o.integer('turns', min: 1));
      case 'kingAt':
        return KingAtObjective(node(), o.integer('turn', min: 1));
      case 'armySupplyAtMost':
        return ArmySupplyAtMostObjective(army(), o.number('fraction', min: 0, max: 1));
      case 'kingNotCaptured':
        return const KingNotCapturedObjective();
      case 'capitalHeld':
        return const CapitalHeldObjective();
      case 'unityAllAbove':
        return UnityAllAboveObjective(o.integer('value', min: 0, max: 10));
      case 'unityAtLeastAtEnd':
        return UnityAtLeastAtEndObjective(o.enumValue('pillar', Pillar.values), o.integer('value', min: 0, max: 10));
      case 'noDefections':
        return const NoDefectionsObjective();
      case 'noCaptures':
        return const NoCapturesObjective();
      case 'troopsLostAtMost':
        return TroopsLostAtMostObjective(o.integer('value', min: 0));
      case 'winByTurn':
        return WinByTurnObjective(o.integer('turn', min: 1));
      case 'won':
        return const WonObjective();
      default:
        issues.error(Rule.closedLists, 'unknownObjective', o.file, o.sub('type'), 'objective "$type" is not in the closed list');
        o.markAllRead();
        return null;
    }
  }
}
