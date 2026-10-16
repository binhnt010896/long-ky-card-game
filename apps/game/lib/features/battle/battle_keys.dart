import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// What a key press asks of the battle screen (build-spec section 6,
/// "Keyboard"): Space or Enter ends the phase, Esc closes a panel or opens
/// the menu, 1–9 selects a card, Tab cycles the officers.
sealed class BattleCommand {
  const BattleCommand();
}

final class EndPhaseCommand extends BattleCommand {
  const EndPhaseCommand();
}

final class EscapeCommand extends BattleCommand {
  const EscapeCommand();
}

/// Card number [index] of the hand, counting from 0 (key "1" is 0).
final class PickCardCommand extends BattleCommand {
  const PickCardCommand(this.index);

  final int index;
}

/// The next officer, or with [step] −1 the previous one.
final class CycleOfficerCommand extends BattleCommand {
  const CycleOfficerCommand(this.step);

  final int step;
}

const _digits = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];

const _numpad = [
  LogicalKeyboardKey.numpad1,
  LogicalKeyboardKey.numpad2,
  LogicalKeyboardKey.numpad3,
  LogicalKeyboardKey.numpad4,
  LogicalKeyboardKey.numpad5,
  LogicalKeyboardKey.numpad6,
  LogicalKeyboardKey.numpad7,
  LogicalKeyboardKey.numpad8,
  LogicalKeyboardKey.numpad9,
];

/// The command for [key], or null if it is not one of the battle's keys.
/// [shift] reverses Tab.
BattleCommand? commandForKey(LogicalKeyboardKey key, {bool shift = false}) {
  if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
    return const EndPhaseCommand();
  }
  if (key == LogicalKeyboardKey.escape) return const EscapeCommand();
  if (key == LogicalKeyboardKey.tab) return CycleOfficerCommand(shift ? -1 : 1);
  final i = _digits.indexOf(key);
  if (i >= 0) return PickCardCommand(i);
  final n = _numpad.indexOf(key);
  if (n >= 0) return PickCardCommand(n);
  return null;
}

/// Listens to the keyboard while its page is the one on top and sends the
/// battle keys to [onCommand]; [onCommand] returns whether it used the key.
///
/// It listens on [HardwareKeyboard], ahead of the focus tree, so the keys work
/// whatever was last tapped (a focused button would otherwise take Space and
/// Enter for itself). While a dialog or another page is on top, the page is
/// not the current route and every key is left alone.
class BattleKeyboard extends StatefulWidget {
  const BattleKeyboard({super.key, required this.onCommand, required this.child});

  final bool Function(BattleCommand command) onCommand;
  final Widget child;

  @override
  State<BattleKeyboard> createState() => _BattleKeyboardState();
}

class _BattleKeyboardState extends State<BattleKeyboard> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handle);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handle);
    super.dispose();
  }

  bool _handle(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (ModalRoute.of(context)?.isCurrent != true) return false;
    final keyboard = HardwareKeyboard.instance;
    // Ctrl, Alt and Meta keep their own meaning (copy, window shortcuts).
    if (keyboard.isControlPressed || keyboard.isAltPressed || keyboard.isMetaPressed) return false;
    final command = commandForKey(event.logicalKey, shift: keyboard.isShiftPressed);
    if (command == null) return false;
    return widget.onCommand(command);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Who Tab moves to: after [current] in [ids] (wrapping round), before it with
/// [step] −1. With nobody current, forwards starts at the first and backwards
/// at the last. Null when there is nobody to go to.
String? cycleOfficer(List<String> ids, String? current, int step) {
  if (ids.isEmpty) return null;
  final at = current == null ? -1 : ids.indexOf(current);
  if (at < 0) return step > 0 ? ids.first : ids.last;
  return ids[(at + step) % ids.length];
}
