import '../balance.dart';
import '../model/defs.dart';
import '../model/enums.dart';
import '../model/game_state.dart';
import 'tx.dart';

/// Support a card costs now: +1 while Court is below 4.
int cardSupportCost(Tx tx, CardDef card) =>
    card.cost.support +
    (tx.s.unity.court < Balance.unityLowThreshold ? Balance.lowCourtCardSupportSurcharge : 0);

/// Court −1 the first time the capital falls to the Yuan.
void onNodeControlChanged(Tx tx, String nodeId, Side to) {
  if (nodeId != tx.graph.capitalId || to != Side.yuan || tx.s.hasFlag(GameFlags.capitalLost)) return;
  tx.addFlag(GameFlags.capitalLost);
  tx.modUnity(Pillar.court, -Balance.capitalLostCourtLoss);
}
