import '../actions/game_action.dart';
import '../effects/effects.dart';
import '../model/defs.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'events.dart';
import 'objectives.dart';
import 'tx.dart';
import 'unity.dart';

/// PlayCard: pay the cost, check conditions, apply effects, discard.
void playCard(Tx tx, PlayCard action) {
  final cardId = action.cardId;
  final index = tx.s.hand.indexOf(cardId);
  if (index < 0) throw IllegalAction(IllegalCodes.cardNotInHand, cardId);
  final card = tx.def.cards[cardId]!;
  if (card.type == CardType.intent) throw IllegalAction(IllegalCodes.badTarget, '$cardId is an enemy intent');
  final bindings = bindTarget(tx, card.target, action.target);
  if (!conditionsHold(tx, card.conditions, bindings)) throw IllegalAction(IllegalCodes.conditionFailed, cardId);

  final support = cardSupportCost(tx, card);
  if (tx.s.rice < card.cost.rice || tx.s.support < support) {
    throw IllegalAction(IllegalCodes.cannotAfford, cardId);
  }
  tx.modResource(Resource.rice, -card.cost.rice);
  tx.modResource(Resource.support, -support);
  final hand = [...tx.s.hand]..removeAt(index);
  tx.s = tx.s.copyWith(hand: hand, discard: [...tx.s.discard, cardId]);
  _countCard(tx, cardId);
  tx.emit(CardPlayed(cardId, target: action.target));
  runEffects(tx, card.effects, EffectScope(source: ChoiceSource.card, sourceId: cardId, bindings: bindings));
}

/// UseSkill: an activated skill with uses left.
void useSkill(Tx tx, UseSkill action) {
  final id = action.officerId;
  final o = tx.s.officers[id];
  if (o == null) throw IllegalAction(IllegalCodes.unknownOfficer, id);
  if (o.status != OfficerStatus.active) throw IllegalAction(IllegalCodes.officerInactive, id);
  final skill = tx.officerDef(id).skill;
  if (skill == null || skill.kind != SkillKind.activated) throw IllegalAction(IllegalCodes.noActivatedSkill, id);
  if (o.skillUsesLeft <= 0) throw IllegalAction(IllegalCodes.noUsesLeft, id);
  final bindings = bindTarget(tx, skill.target, action.target);

  tx.updateOfficer(id, (o) => o.copyWith(skillUsesLeft: o.skillUsesLeft - 1));
  tx.updateStats((m) => m.copyWith(skillsUsed: {...m.skillsUsed, skill.id: (m.skillsUsed[skill.id] ?? 0) + 1}));
  tx.emit(SkillUsed(id, skill.id, target: action.target));
  runEffects(tx, skill.effects, EffectScope(source: ChoiceSource.skill, sourceId: id, bindings: bindings));
}

/// ResolveChoice: applies the chosen option, then continues any scripted
/// events still queued for this turn.
void resolveChoice(Tx tx, ResolveChoice action) {
  final pc = tx.s.pendingChoice;
  if (pc == null) throw const IllegalAction(IllegalCodes.noChoicePending);
  if (action.index < 0 || action.index >= pc.optionCount) {
    throw IllegalAction(IllegalCodes.badChoiceIndex, '${action.index} of ${pc.optionCount}');
  }
  final choice = _choiceAt(tx, pc);
  tx.s = tx.s.copyWith(pendingChoice: null);
  tx.emit(ChoiceResolved(pc.sourceId, action.index));
  runEffects(
    tx,
    choice.options[action.index].effects,
    EffectScope(
      source: pc.source,
      sourceId: pc.sourceId,
      bindings: pc.bindings,
      path: [...pc.path, action.index],
    ),
  );
  processScriptedQueue(tx);
}

ChoiceEffect _choiceAt(Tx tx, PendingChoice pc) {
  var effects = switch (pc.source) {
    ChoiceSource.card => tx.def.cards[pc.sourceId]!.effects,
    ChoiceSource.skill => tx.officerDef(pc.sourceId).skill!.effects,
  };
  for (var i = 0; i < pc.path.length; i += 2) {
    final effect = effects[pc.path[i]] as ChoiceEffect;
    if (i + 1 == pc.path.length) return effect;
    effects = effect.options[pc.path[i + 1]].effects;
  }
  throw StateError('bad choice path ${pc.path}');
}

/// Plays this turn's queued scripted Event cards until one asks a choice.
/// Scripted cards cost nothing and are not discarded into the deck.
void processScriptedQueue(Tx tx) {
  while (tx.s.scriptedQueue.isNotEmpty && tx.s.pendingChoice == null) {
    // An earlier card or choice may already have lost the mission.
    checkEnd(tx, endOfTurn: false);
    if (tx.s.isOver) return;
    final cardId = tx.s.scriptedQueue.first;
    tx.s = tx.s.copyWith(scriptedQueue: tx.s.scriptedQueue.sublist(1));
    final card = tx.def.cards[cardId]!;
    if (!conditionsHold(tx, card.conditions, const {})) continue;
    _countCard(tx, cardId);
    tx.emit(CardPlayed(cardId, scripted: true));
    runEffects(tx, card.effects, EffectScope(source: ChoiceSource.card, sourceId: cardId));
  }
}

void _countCard(Tx tx, String cardId) => tx.updateStats(
    (m) => m.copyWith(cardsPlayed: {...m.cardsPlayed, cardId: (m.cardsPlayed[cardId] ?? 0) + 1}));

/// Checks [target] against [kind] and returns the effect bindings.
Map<String, String> bindTarget(Tx tx, TargetKind kind, String? target) {
  void fail() => throw IllegalAction(IllegalCodes.badTarget, '${kind.name}: $target');
  final variable = bindingVariable(kind);
  if (variable == null) {
    if (target != null) fail();
    return const {};
  }
  if (target == null) fail();
  final ok = switch (kind) {
    TargetKind.none => false,
    TargetKind.ownNode => tx.s.nodes[target]?.controller == Side.daiViet,
    TargetKind.anyNode => tx.s.nodes.containsKey(target),
    TargetKind.riverEdge => tx.graph.edges[target]?.kind == EdgeKind.river,
    TargetKind.ownOfficer => tx.isActiveOfficer(target!),
    TargetKind.yuanArmy => tx.isActiveArmy(target!),
  };
  if (!ok) fail();
  return {variable: target!};
}

/// Possible targets for [kind] (legal or not); callers filter.
List<String?> candidateTargets(Tx tx, TargetKind kind) => switch (kind) {
      TargetKind.none => const [null],
      TargetKind.ownNode || TargetKind.anyNode => tx.graph.nodeIds,
      TargetKind.riverEdge => [
          for (final e in tx.graph.edges.values)
            if (e.kind == EdgeKind.river) e.key,
        ]..sort(),
      TargetKind.ownOfficer => tx.activeOfficerIds(),
      TargetKind.yuanArmy => tx.activeArmyIds(),
    };
