import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/lacquer.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/battle_save_repository.dart';
import '../battle/battle_page.dart';

/// Title screen: Continue, Campaign, Codex, Settings.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  /// The saved battle, once looked up.
  SavedBattle? _saved;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  BattleSaveRepository? get _saves {
    try {
      return context.read<BattleSaveRepository>();
    } on Object {
      return null;
    }
  }

  Future<void> _refresh() async {
    final saved = await _saves?.load() ?? const NoSavedBattle();
    if (mounted) setState(() => _saved = saved);
  }

  /// The mission to continue, if there is a save to continue (or at least one
  /// that can be offered a restart).
  String? get _continueMission => switch (_saved) {
    FoundSavedBattle(:final save) => save.missionId,
    UnusableSavedBattle(:final missionId) => missionId,
    _ => null,
  };

  Future<void> _continue() async {
    final mission = _continueMission;
    if (mission == null) return;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => BattlePage(missionId: mission, resume: true)));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: LacquerBackdrop(
        path: 'ui/title-cover.jpg',
        alignment: const Alignment(0.35, 0),
        scrim: LacquerBackdrop.fromLeft,
        child: SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and title side by side, so the menu fits a phone held sideways.
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: LongKyColors.goldLeaf.withValues(alpha: 0.8), width: 1),
                            boxShadow: [BoxShadow(color: LongKyColors.goldLeaf.withValues(alpha: 0.35), blurRadius: 20)],
                          ),
                          child: const PaintedImage(path: 'ui/logo.png', width: 56, height: 56, circle: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l.appTitle,
                            style: textTheme.titleLarge?.copyWith(
                              color: LongKyColors.goldLeaf,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              shadows: const [Shadow(color: Colors.black, blurRadius: 12)],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Center(child: GoldDivider(width: 280)),
                    const SizedBox(height: 16),
                    // Continue resumes the saved battle, if there is one.
                    FilledButton(
                      key: const Key('menu-continue'),
                      onPressed: _continueMission == null ? null : _continue,
                      child: Text(l.menuContinue),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.campaign),
                      child: Text(l.menuCampaign),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.codex),
                      child: Text(l.menuCodex),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.settings),
                      child: Text(l.menuSettings),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.boardPreview).then((_) => _refresh()),
                        child: const Text('Board preview (debug)'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.briefingPreview),
                        child: const Text('Briefing preview (debug)'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
