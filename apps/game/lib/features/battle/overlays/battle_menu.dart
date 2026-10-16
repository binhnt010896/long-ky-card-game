import 'package:flutter/material.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import 'panel.dart';

/// What the player chose in the battle menu.
enum BattleMenuChoice { resume, leave }

/// The menu Esc opens when no panel is open (build-spec section 6). The
/// battle is autosaved after every step, so leaving loses nothing.
Future<BattleMenuChoice?> showBattleMenu(BuildContext context) =>
    showDialog<BattleMenuChoice>(context: context, builder: (_) => const BattleMenu());

class BattleMenu extends StatelessWidget {
  const BattleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      key: const Key('battle-menu'),
      backgroundColor: LongKyColors.lacquerRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: LongKyColors.goldLeaf),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.battleMenuTitle,
                style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('menu-resume'),
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(BattleMenuChoice.resume),
                style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                child: Text(l.battleMenuResume),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('menu-leave'),
                onPressed: () => Navigator.of(context).pop(BattleMenuChoice.leave),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, minTouch)),
                child: Text(l.battleMenuLeave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
