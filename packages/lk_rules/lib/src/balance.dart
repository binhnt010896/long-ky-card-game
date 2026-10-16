/// Rule constants (build-spec section 4). First-pass values, tuned in T-25.
///
/// Balance changes go in content JSON first, then here, and every change is
/// backed by a simulator report (build-spec section 7).
library;

import 'model/enums.dart';

abstract final class Balance {
  // Officers and Unity.
  static const int officerStartMorale = 7;
  static const int moraleMin = 0;
  static const int moraleMax = 10;
  static const int unityMin = 0;
  static const int unityMax = 10;

  /// A Unity pillar below this value triggers its penalty.
  static const int unityLowThreshold = 4;

  /// Court below [unityLowThreshold]: every card costs this much extra Support.
  static const int lowCourtCardSupportSurcharge = 1;

  /// Clan below [unityLowThreshold]: inducement threshold rises by this much.
  static const int lowClanDefectionBonus = 2;

  // Map.
  /// A node's starting `riceStock` is `riceYield × riceStockPerYield`.
  static const int riceStockPerYield = 3;

  // Orders.
  static const double holdPowerMultiplier = 1.2;
  static const int maxRiverEdgesPerMove = 2;
  static const int evacuateSupportCost = 1;
  static const int evacuateSupportCostLowPeople = 2;
  static const int raidSupplyBase = 2;
  static const int raidWarDivisor = 3;
  static const int raiderSupplyMultiplier = 2;
  static const int raidTroopLossDivisor = 20;
  static const int rallyMorale = 1;
  static const int rallyTroops = 1;

  /// People lost by each evacuation after the first in the same turn.
  static const int extraEvacuationPeopleLoss = 1;

  /// People gained per battle won.
  static const int battleWonPeopleGain = 1;

  /// Court lost the first time the capital falls.
  static const int capitalLostCourtLoss = 1;

  /// Clan lost per defection.
  static const int defectionClanLoss = 1;

  // Combat.
  static const int troopsPerLeadership = 3;
  static const double overCapTroopValue = 0.5;
  static const double warDivisor = 10;
  static const double moraleBase = 0.5;
  static const double moraleDivisor = 20;
  static const double loserLossBase = 0.5;
  static const double loserLossRatio = 0.3;
  static const double winnerLossRatio = 0.25;
  static const int loserMoraleLoss = 2;
  static const int winnerMoraleGain = 1;
  static const double ambusherPowerMultiplier = 1.5;
  static const double ambushRollMin = 0.9;
  static const double ambushRollMax = 1.1;
  static const int ambushExtraMoraleLoss = 2;
  static const int kingPresenceMorale = 1;

  /// `counterattackAt` needs the army below this fraction of its max Supply.
  static const double counterattackSupplyFraction = 0.5;

  /// Terrain used for an ambush battle on a river edge.
  static const Terrain ambushTerrain = Terrain.river;

  /// Rounding guard: `ceil(x)` is computed as `ceil(x - epsilon)` so that
  /// float noise (10 × 0.3 = 3.0000000000000004) does not add a whole troop.
  static const double roundingEpsilon = 1e-9;

  static double daiVietTerrain(Terrain t, {required bool defending}) =>
      switch (t) {
        Terrain.city => defending ? 1.2 : 1.0,
        Terrain.plain => 1.0,
        Terrain.river => 1.2,
        Terrain.marsh => 1.2,
        Terrain.hill => 1.1,
      };

  static double yuanTerrain(Terrain t) => switch (t) {
        Terrain.city => 1.0,
        Terrain.plain => 1.2,
        Terrain.river => 0.9,
        Terrain.marsh => 0.8,
        Terrain.hill => 1.0,
      };

  // Forage and Upkeep.
  static const int forageSupplyPerRice = 2;
  static const int troopsPerSupply = 10;
  static const int starvationMoraleLoss = 2;
  static const double starvationTroopFraction = 0.1;
  static const int troopsPerRice = 10;
  static const int riceShortfallMoraleLoss = 1;

  // Yuan AI.
  static const int aiRetreatMorale = 2;
  static const double aiForageSupplyFraction = 0.4;

  // Intel.
  static const int baseRevealDepth = 1;
  static const int borderWatchRevealDepth = 2;
}
