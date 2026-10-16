/// Enumerations shared by definitions and game state.
library;

enum Side { daiViet, yuan, none }

enum Phase { intel, council, orders, resolution, upkeep, ended }

enum Outcome { won, lost }

enum Pillar { court, clan, people }

enum Resource { rice, support }

enum OfficerStatus { active, defected, captured }

enum ArmyStatus { active, routed }

enum OrderKind { hold, move, evacuate, raid, ambush, rally }

enum IntentKind { hold, advance, assault, forage, retreat }

enum Terrain { city, plain, river, marsh, hill }

enum EdgeKind { land, river }

enum CardType { stratagem, event, intent }

enum SkillKind { activated, passive }

/// What a card or activated skill is played on (build-spec section 3).
enum TargetKind { none, ownNode, anyNode, riverEdge, ownOfficer, yuanArmy }

enum ArmyField { troops, supply, morale }

/// Passive skill ids the engine implements (closed list, build-spec section 4).
abstract final class PassiveIds {
  static const String kingPresence = 'kingPresence';
  static const String shieldKing = 'shieldKing';
  static const String borderWatch = 'borderWatch';
  static const String raider = 'raider';

  static const Set<String> all = {kingPresence, shieldKing, borderWatch, raider};
}

/// Flaw ids the engine implements (closed list, build-spec section 4).
abstract final class FlawIds {
  static const String isKing = 'isKing';
  static const String troopCap = 'troopCap';

  static const Set<String> all = {isKing, troopCap};
}

/// The variable an effect uses to refer to the play action's target.
String? bindingVariable(TargetKind kind) => switch (kind) {
      TargetKind.none => null,
      TargetKind.ownNode || TargetKind.anyNode => r'$node',
      TargetKind.riverEdge => r'$edge',
      TargetKind.ownOfficer => r'$officer',
      TargetKind.yuanArmy => r'$army',
    };
