import 'package:lk_rules/lk_rules.dart';

import 'view.dart';

/// Developer-facing text for the terminal player and simulator traces.
/// (Not player-facing UI: content names come from the content in
/// Vietnamese; the labels are English.)
final class Describer {
  Describer(this.engine);

  final GameEngine engine;

  String node(String id) => '${engine.graph.node(id).name.vi} [$id]';
  String officer(String id) => engine.def.officers[id]?.name.vi ?? id;
  String card(String id) => engine.def.cards[id]?.name.vi ?? id;
  String army(GameState s, String id) {
    final c = engine.def.commanders[s.armies[id]?.commanderId];
    return '$id (${c?.name.vi ?? '?'})';
  }

  String intent(Intent? i) {
    if (i == null) return '-';
    final to = i.moveTo == null ? 'stays' : '→ ${i.moveTo}';
    final target = i.targetNodeId == null ? '' : ' (heading for ${i.targetNodeId})';
    return '${i.kind.name} $to$target';
  }

  String order(Order? o) => o == null ? 'hold (no order)' : '${o.kind.name}${o.target == null ? '' : ' ${o.target}'}';

  String action(GameState s, GameAction a) => switch (a) {
        PlayCard(:final cardId, :final target) => 'play ${card(cardId)}${target == null ? '' : ' → $target'}',
        UseSkill(:final officerId, :final target) =>
          'use ${engine.def.officers[officerId]?.skill?.name.vi ?? 'skill'} (${officer(officerId)})${target == null ? '' : ' → $target'}',
        ResolveChoice(:final index) => 'choose: ${_optionLabel(s, index)}',
        SetOrder(:final officerId, :final order) => '${officer(officerId)}: ${this.order(order)}',
        ClearOrder(:final officerId) => '${officer(officerId)}: clear order',
        EndPhase() => 'end ${s.phase.name}',
        ContinueFreePlay() => 'continue in free play',
      };

  String _optionLabel(GameState s, int index) {
    final pc = s.pendingChoice;
    if (pc == null) return '#$index';
    var effects = pc.source == ChoiceSource.card
        ? engine.def.cards[pc.sourceId]!.effects
        : engine.def.officers[pc.sourceId]!.skill!.effects;
    ChoiceEffect? choice;
    for (var i = 0; i < pc.path.length; i += 2) {
      choice = effects[pc.path[i]] as ChoiceEffect;
      if (i + 1 < pc.path.length) effects = choice.options[pc.path[i + 1]].effects;
    }
    final opt = choice!.options[index];
    return '${opt.label.vi} / ${opt.label.en}';
  }

  String event(GameState s, GameEvent e) => switch (e) {
        TurnStarted(:final turn) => '— Turn $turn —',
        PhaseChanged(:final phase) => '· ${phase.name}',
        IntentRevealed(:final armyId, :final intent, :final predicted) =>
          '${predicted ? 'Predicted' : 'Intent'}: $armyId ${this.intent(intent)}',
        RevealDepthChanged(:final depth) => 'Intel depth $depth',
        CardPlayed(:final cardId, :final target, :final scripted) =>
          '${scripted ? 'Event' : 'Played'}: ${card(cardId)}${target == null ? '' : ' → $target'}',
        SkillUsed(:final officerId, :final skillId) => '${officer(officerId)} uses $skillId',
        ChoiceRequested(:final sourceId) => 'Choice needed: ${card(sourceId)}',
        ChoiceResolved(:final index) => 'Chose option ${index + 1}',
        UnityChanged(:final pillar, :final from, :final to) => 'Unity ${pillar.name} $from → $to',
        ResourceChanged(:final resource, :final from, :final to) => '${resource.name} $from → $to',
        OrdersSkipped() => 'Orders skipped this turn',
        OrderSet(:final officerId, :final order) => 'Order ${officer(officerId)}: ${this.order(order)}',
        OfficerMoved(:final officerId, :final from, :final to, :final reason) =>
          '${officer(officerId)} ${reason.name}: $from → $to',
        ArmyMoved(:final armyId, :final from, :final to, :final reason) => '$armyId ${reason.name}: $from → $to',
        NodeEvacuated(:final nodeId, :final riceGained) => 'Evacuated ${node(nodeId)} (+$riceGained rice)',
        Rallied(:final officerId, :final troopsGained) => '${officer(officerId)} rallies (+$troopsGained troops)',
        AmbushPlaced(:final edge, :final officerId) => 'Ambush on $edge by ${officer(officerId)}',
        BattleResolved(:final report) => _battle(report),
        OfficerCaptured(:final officerId, :final nodeId) => 'CAPTURED: ${officer(officerId)} at $nodeId',
        KingShielded(:final shieldId) => '${officer(shieldId)} is captured shielding the king',
        Raided(:final officerId, :final armyId, :final supplyLost, :final troopsLost) =>
          'Raid by ${officer(officerId)}: $armyId −$supplyLost Supply (raider −$troopsLost troops)',
        Foraged(:final armyId, :final nodeId, :final supplyGained) => '$armyId forages $nodeId: +$supplyGained Supply',
        NodeControlChanged(:final nodeId, :final from, :final to) => '${node(nodeId)}: ${from.name} → ${to.name}',
        ArmyChanged(:final armyId, :final field, :final from, :final to) => '$armyId ${field.name} $from → $to',
        SupplyConsumed(:final armyId, :final amount) => '$armyId uses $amount Supply',
        Starvation(:final armyId, :final moraleLost, :final troopsLost) =>
          '$armyId starves: −$moraleLost morale, −$troopsLost troops',
        HeatAttrition(:final armyId, :final troopsLost) => '$armyId loses $troopsLost troops to the heat',
        ArmyRouted(:final armyId) => 'ROUTED: $armyId',
        IncomeCollected(:final riceGained, :final riceUpkeep, :final shortfall) =>
          'Income +$riceGained rice, upkeep −$riceUpkeep${shortfall ? ' (SHORTFALL: officers −1 morale)' : ''}',
        OfficerDefected(:final officerId) => 'DEFECTED: ${officer(officerId)}',
        InducementResisted(:final officerId) => '${officer(officerId)} resists the inducement',
        CardsDrawn(:final cardIds) => 'Drew ${cardIds.map(card).join(', ')}',
        DeckShuffled(:final size) => 'Discard reshuffled into the deck ($size cards)',
        FreePlayStarted() => '*** Free play ***',
        FreePlayEnded(:final playerWon) => '*** Free play over: ${playerWon ? 'the Yuan have no troops' : 'our troops are gone'} ***',
        MissionEnded(:final outcome, :final reason, :final stars) =>
          '*** Mission ${outcome.name.toUpperCase()}${reason == null ? '' : ' ($reason)'} · stars ${stars.where((x) => x).length}/${stars.length} ***',
      };

  String _battle(BattleReport r) {
    final where = r.kind == BattleKind.ambush ? 'Ambush on ${r.edge}' : 'Battle at ${node(r.nodeId)}';
    final roll = r.roll == null ? '' : ' (roll ${r.roll!.toStringAsFixed(3)})';
    final dv = r.officerLosses.entries.map((e) => '${officer(e.key)} −${e.value}').join(', ');
    final y = r.armyLosses.entries.map((e) => '${e.key} −${e.value}').join(', ');
    return '$where: Đại Việt ${r.daiVietPower.toStringAsFixed(2)} vs Yuan ${r.yuanPower.toStringAsFixed(2)}$roll'
        ' → ${r.winner == Side.daiViet ? 'Đại Việt wins' : 'Yuan win'}${r.daiVietStarted ? ' (you attacked)' : ''}. '
        'Losses: $dv; $y';
  }

  /// The board as text.
  String board(GameState s) {
    final v = GameView(engine, s);
    final m = engine.def.mission;
    final b = StringBuffer()
      ..writeln('${m.id} · ${m.title.vi} · turn ${s.turn}/${m.seasonTurns} · ${s.phase.name}'
          '${m.heatStartTurn == null ? '' : ' · heat from turn ${m.heatStartTurn}'}')
      ..writeln('Rice ${s.rice} · Support ${s.support} · Court ${s.unity.court} · Clan ${s.unity.clan} · '
          'People ${s.unity.people} · intel depth ${s.revealDepth}');
    for (final id in engine.graph.nodeIds) {
      final n = engine.graph.node(id);
      final st = s.nodes[id]!;
      final flags = [if (n.isCapital) 'capital', if (n.isBorder) 'border', if (st.evacuated) 'EVACUATED'].join(',');
      b.writeln('  ${id.padRight(15)} ${n.terrain.name.padRight(5)} ${st.controller.name.padRight(7)} '
          'rice ${st.riceStock.toString().padLeft(2)}${flags.isEmpty ? '' : ' [$flags]'}');
      for (final o in v.officersAt(id)) {
        final os = s.officers[o]!;
        final mult = os.nextBattleMultiplier == 1 ? '' : ' ×${os.nextBattleMultiplier}';
        b.writeln('      ĐV  ${officer(o)} [$o] ${os.troops} troops, morale ${os.morale}, loyalty ${os.loyalty}'
            '${os.skillUsesLeft > 0 ? ', skill ×${os.skillUsesLeft}' : ''}$mult · ${order(os.order)}');
      }
      for (final a in v.armiesAt(id)) {
        final st = s.armies[a]!;
        b.writeln('      YUAN ${army(s, a)} ${st.troops} troops, Supply ${st.supply}/${st.maxSupply}, '
            'morale ${st.morale} · ${intent(st.intent)}'
            '${st.predictedIntent == null ? '' : ' · next: ${intent(st.predictedIntent)}'}');
      }
    }
    final edges = engine.graph.edges.values.map((e) => '${e.from}${e.kind == EdgeKind.river ? '≈' : '-'}${e.to}').join('  ');
    b
      ..writeln('  edges (≈ river, - land): $edges')
      ..writeln('Hand: ${s.hand.map(card).join(' | ')}  (deck ${s.deck.length}, discard ${s.discard.length})');
    if (s.ambushes.isNotEmpty) b.writeln('Ambushes: ${s.ambushes.map((a) => '${a.edge} (${a.officerId})').join(', ')}');
    return b.toString();
  }
}
