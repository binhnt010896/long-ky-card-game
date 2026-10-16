import '../actions/game_action.dart';
import 'tx.dart';

/// Council actions. Card effects arrive in T-09.
void playCard(Tx tx, PlayCard action) =>
    throw const IllegalAction(IllegalCodes.cardNotInHand, 'card play arrives in T-09');

void useSkill(Tx tx, UseSkill action) =>
    throw const IllegalAction(IllegalCodes.noActivatedSkill, 'skills arrive in T-09');

void resolveChoice(Tx tx, ResolveChoice action) {
  if (tx.s.pendingChoice == null) throw const IllegalAction(IllegalCodes.noChoicePending);
  throw const IllegalAction(IllegalCodes.badChoiceIndex, 'choices arrive in T-09');
}

/// Plays this turn's queued scripted Event cards until one asks a choice.
void processScriptedQueue(Tx tx) {
  if (tx.s.scriptedQueue.isNotEmpty) {
    throw UnsupportedError('scripted events arrive in T-09');
  }
}
