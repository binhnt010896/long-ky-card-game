import '../balance.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'combat.dart';
import 'tx.dart';

/// Expected Powers of a battle before it happens (the battle preview, and
/// planning for simulator strategies). Ambushes give a range for the roll.
final class BattleForecast {
  const BattleForecast({
    required this.daiVietPower,
    required this.yuanPower,
    required this.winner,
    this.daiVietLosses = 0,
    this.yuanLosses = 0,
    double? daiVietPowerMax,
    Side? winnerAtMaxRoll,
    int? daiVietLossesAtMaxRoll,
    int? yuanLossesAtMaxRoll,
  })  : daiVietPowerMax = daiVietPowerMax ?? daiVietPower,
        winnerAtMaxRoll = winnerAtMaxRoll ?? winner,
        daiVietLossesAtMaxRoll = daiVietLossesAtMaxRoll ?? daiVietLosses,
        yuanLossesAtMaxRoll = yuanLossesAtMaxRoll ?? yuanLosses;

  /// Đại Việt Power (for an ambush, at the lowest roll).
  final double daiVietPower;

  /// For an ambush, Đại Việt Power at the highest roll.
  final double daiVietPowerMax;
  final double yuanPower;

  /// Winner (for an ambush, at the lowest roll).
  final Side winner;
  final Side winnerAtMaxRoll;

  /// Troops (in thousands) each side is expected to lose, summed over its
  /// units (for an ambush, at the lowest roll).
  final int daiVietLosses;
  final int yuanLosses;

  /// Same, at the highest roll; equal to the above for a field battle.
  final int daiVietLossesAtMaxRoll;
  final int yuanLossesAtMaxRoll;
}

int _sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);

/// A field battle at [nodeId] between [officerIds] and [armyIds] (default:
/// the active armies there). Officers in [moving] arrive this turn (no
/// defence bonuses); the others use [orders] (default: their current order).
BattleForecast forecastFieldBattleIn(
  Tx tx,
  String nodeId, {
  required List<String> officerIds,
  List<String>? armyIds,
  Set<String> moving = const {},
  Map<String, Order?> orders = const {},
}) {
  final armies = armyIds ?? tx.activeArmiesAt(nodeId);
  final combatants = [
    for (final id in officerIds)
      OfficerCombatant(
        officerId: id,
        defending: !moving.contains(id),
        holding: !moving.contains(id) && _isHold(orders.containsKey(id) ? orders[id] : tx.officer(id).order),
      ),
  ];
  final f = forecastFieldBattle(tx, nodeId, combatants, armies, heldAtStart: tx.node(nodeId).controller);
  final losses = battleLosses(
    tx,
    officerIds: officerIds,
    armyIds: armies,
    daiVietPower: f.daiViet,
    yuanPower: f.yuan,
    winner: f.winner,
  );
  return BattleForecast(
    daiVietPower: f.daiViet,
    yuanPower: f.yuan,
    winner: f.winner,
    daiVietLosses: _sum(losses.officers.values),
    yuanLosses: _sum(losses.armies.values),
  );
}

bool _isHold(Order? o) => o == null || o.kind == OrderKind.hold;

/// An ambush by [officerId] on [armyId] as it crosses a river edge.
BattleForecast forecastAmbushIn(Tx tx, String officerId, String armyId) {
  Side winner(double dv, double y) => battleWinner(tx,
      daiVietPower: dv,
      yuanPower: y,
      officerIds: [officerId],
      armyIds: [armyId],
      heldAtStart: tx.node(tx.officer(officerId).nodeId).controller);
  final c = OfficerCombatant(officerId: officerId, defending: true, holding: false, ambusher: true);
  final king = tx.officerDef(officerId).hasPassive(PassiveIds.kingPresence);
  final lo = officerPower(tx, c, Balance.ambushTerrain,
      kingPresent: king, opposingArmies: [armyId], roll: Balance.ambushRollMin);
  final hi = officerPower(tx, c, Balance.ambushTerrain,
      kingPresent: king, opposingArmies: [armyId], roll: Balance.ambushRollMax);
  final y = armyPower(tx, armyId, Balance.ambushTerrain);
  final winnerLo = winner(lo, y);
  final winnerHi = winner(hi, y);
  final lossesLo = battleLosses(tx,
      officerIds: [officerId], armyIds: [armyId], daiVietPower: lo, yuanPower: y, winner: winnerLo);
  final lossesHi = battleLosses(tx,
      officerIds: [officerId], armyIds: [armyId], daiVietPower: hi, yuanPower: y, winner: winnerHi);
  return BattleForecast(
    daiVietPower: lo,
    daiVietPowerMax: hi,
    yuanPower: y,
    winner: winnerLo,
    winnerAtMaxRoll: winnerHi,
    daiVietLosses: _sum(lossesLo.officers.values),
    yuanLosses: _sum(lossesLo.armies.values),
    daiVietLossesAtMaxRoll: _sum(lossesHi.officers.values),
    yuanLossesAtMaxRoll: _sum(lossesHi.armies.values),
  );
}
