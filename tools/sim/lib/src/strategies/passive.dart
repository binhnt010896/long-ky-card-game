import 'package:lk_rules/lk_rules.dart';

import '../strategy.dart';
import '../view.dart';

/// Every officer holds; no cards; the first option of every choice.
final class PassiveStrategy extends PlannedStrategy {
  @override
  String get name => 'passive';

  @override
  List<GameAction> planCouncil(GameView v) => const [];

  @override
  Map<String, Order> planOrders(GameView v) => {for (final id in v.officerIds) id: Order.hold};
}
