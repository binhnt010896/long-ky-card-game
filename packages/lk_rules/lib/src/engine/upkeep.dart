import '../balance.dart';
import '../model/enums.dart';
import 'events.dart';
import 'loyalty.dart';
import 'tx.dart';

/// Upkeep, in the order of build-spec section 4. Win and loss are checked by
/// the caller afterwards (step 8).
void runUpkeep(Tx tx) {
  consumeSupply(tx);
  applyStarvation(tx);
  applyHeat(tx);
  routeBrokenArmies(tx);
  collectIncome(tx);
  checkInducements(tx);
  drawToHandSize(tx);
}

int _ceilDiv(int a, int b) => (a + b - 1) ~/ b;

/// Step 1: each army uses ceil(troops / 10) Supply.
void consumeSupply(Tx tx) {
  for (final id in tx.activeArmyIds()) {
    final a = tx.army(id);
    final need = _ceilDiv(a.troops, Balance.troopsPerSupply);
    final used = need > a.supply ? a.supply : need;
    tx.updateArmy(id, (a) => a.copyWith(supply: a.supply - used));
    tx.emit(SupplyConsumed(id, used));
  }
}

/// Step 2: an army at 0 Supply loses 2 morale and ceil(troops × 0.1) troops.
void applyStarvation(Tx tx) {
  for (final id in tx.activeArmyIds()) {
    final a = tx.army(id);
    if (a.supply > 0) continue;
    final lost = _clampLoss(ceilSafe(a.troops * Balance.starvationTroopFraction), a.troops);
    tx.updateArmy(id, (a) => a.copyWith(troops: a.troops - lost));
    tx.setArmyMorale(id, a.morale - Balance.starvationMoraleLoss);
    tx.emit(Starvation(id, a.morale - tx.army(id).morale, lost));
  }
}

/// Step 3: from `heatStartTurn`, each army loses `turn − heatStartTurn + 1`.
void applyHeat(Tx tx) {
  final start = tx.mission.heatStartTurn;
  if (start == null || tx.s.turn < start) return;
  final loss = tx.s.turn - start + 1;
  for (final id in tx.activeArmyIds()) {
    final a = tx.army(id);
    final lost = _clampLoss(loss, a.troops);
    tx.updateArmy(id, (a) => a.copyWith(troops: a.troops - lost));
    tx.emit(HeatAttrition(id, lost));
  }
}

/// Step 4: an army with morale ≤ 0 or troops ≤ 0 is routed and removed.
void routeBrokenArmies(Tx tx) {
  for (final id in tx.activeArmyIds()) {
    final a = tx.army(id);
    if (a.morale > 0 && a.troops > 0) continue;
    tx.updateArmy(id, (a) => a.copyWith(status: ArmyStatus.routed, intent: null, predictedIntent: null));
    tx.emit(ArmyRouted(id));
  }
}

/// Step 5: Rice from held, non-evacuated nodes, then troop upkeep. A
/// shortfall sets Rice to 0 and costs every officer 1 morale.
void collectIncome(Tx tx) {
  var income = 0;
  for (final id in tx.graph.nodeIds) {
    final n = tx.node(id);
    if (n.controller == Side.daiViet && !n.evacuated) income += tx.graph.node(id).riceYield;
  }
  final troops = tx.activeOfficerIds().fold(0, (sum, id) => sum + tx.officer(id).troops);
  final upkeep = _ceilDiv(troops, Balance.troopsPerRice);
  final rice = tx.s.rice + income - upkeep;
  final shortfall = rice < 0;
  tx.setResource(Resource.rice, rice);
  tx.emit(IncomeCollected(income, upkeep, shortfall: shortfall));
  if (shortfall) {
    for (final id in tx.activeOfficerIds()) {
      tx.setOfficerMorale(id, tx.officer(id).morale - Balance.riceShortfallMoraleLoss);
    }
  }
}

int _clampLoss(int loss, int troops) => loss > troops ? troops : loss;

/// Step 7: draw up to `handSize`; an empty deck reshuffles the discard.
void drawToHandSize(Tx tx) {
  final drawn = <String>[];
  while (tx.s.hand.length < tx.mission.handSize) {
    if (tx.s.deck.isEmpty) {
      if (tx.s.discard.isEmpty) break;
      final reshuffled = tx.withRng((rng) => rng.shuffled(tx.s.discard));
      tx.s = tx.s.copyWith(deck: reshuffled, discard: const []);
      tx.emit(DeckShuffled(reshuffled.length));
    }
    final card = tx.s.deck.first;
    tx.s = tx.s.copyWith(deck: tx.s.deck.sublist(1), hand: [...tx.s.hand, card]);
    drawn.add(card);
  }
  if (drawn.isNotEmpty) tx.emit(CardsDrawn(drawn));
}
