import '../actions/game_action.dart';
import 'tx.dart';

/// Orders phase actions (T-05).
void setOrder(Tx tx, SetOrder action) => throw const IllegalAction(IllegalCodes.illegalOrder);

void clearOrder(Tx tx, ClearOrder action) => throw const IllegalAction(IllegalCodes.noOrder);
