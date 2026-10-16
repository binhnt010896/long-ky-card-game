import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../data/battle_save_repository.dart';
import '../../data/content_repository.dart';
import '../settings/progress_cubit.dart';
import 'battle_cubit.dart';
import 'battle_screen.dart';
import 'overlays/panel.dart';

/// Plays one mission: loads its content, starts a new battle or resumes the
/// saved one, autosaves after every step and records the stars on a win.
///
/// Without a [saves] repository (and none in the context) nothing is saved;
/// without a [ProgressCubit] in the context no stars are recorded. Tests rely
/// on both.
class BattlePage extends StatefulWidget {
  const BattlePage({
    super.key,
    required this.missionId,
    this.resume = false,
    this.seed,
    this.bundle,
    this.saves,
    this.progress,
  });

  final String missionId;

  /// Continue the saved battle instead of starting a new one.
  final bool resume;

  /// The seed of a new battle; by default one taken from the clock (the rules
  /// themselves never read it).
  final int? seed;
  final AssetBundle? bundle;
  final BattleSaveRepository? saves;
  final ProgressCubit? progress;

  @override
  State<BattlePage> createState() => _BattlePageState();
}

enum _Stage { loading, ready, cannotResume, failed }

class _BattlePageState extends State<BattlePage> {
  _Stage _stage = _Stage.loading;
  ContentBundle? _content;
  Ruleset? _ruleset;
  BattleCubit? _cubit;

  BattleSaveRepository? _saves;
  ProgressCubit? _progress;
  late final AssetBundle _bundle;

  @override
  void initState() {
    super.initState();
    // Looked up once, before the first await.
    _saves = widget.saves ?? _maybe<BattleSaveRepository>();
    _progress = widget.progress ?? _maybe<ProgressCubit>();
    _bundle = widget.bundle ?? context.getInheritedWidgetOfExactType<DefaultAssetBundle>()?.bundle ?? rootBundle;
    _start(resume: widget.resume);
  }

  T? _maybe<T extends Object>() {
    try {
      return context.read<T>();
    } on Object {
      return null;
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  Future<void> _start({required bool resume}) async {
    setState(() => _stage = _Stage.loading);
    try {
      final content = _content ?? await loadContentFromAssets(_bundle);
      _content = content;
      final ruleset = content.ruleset(widget.missionId);
      final engine = GameEngine(ruleset);

      if (resume && _saves != null) {
        final found = await _saves!.load();
        if (found is FoundSavedBattle &&
            found.save.missionId == widget.missionId &&
            found.save.contentHash == content.contentHash) {
          try {
            _adopt(
              ruleset,
              BattleCubit.resume(
                engine,
                seed: found.save.seed,
                actions: found.save.actions,
                onChanged: (v) => _changed(content, v),
              ),
            );
            return;
          } on SaveReplayException {
            // Falls through to the restart prompt.
          }
        }
        if (found is! NoSavedBattle) {
          if (mounted) setState(() => _stage = _Stage.cannotResume);
          return;
        }
      }

      await _saves?.clear();
      final cubit = BattleCubit(
        engine,
        seed: widget.seed ?? DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
        onChanged: (v) => _changed(content, v),
      );
      _adopt(ruleset, cubit);
      _changed(content, cubit.state);
    } on Object {
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  void _adopt(Ruleset ruleset, BattleCubit cubit) {
    final old = _cubit;
    if (!mounted) {
      cubit.close();
      return;
    }
    setState(() {
      _ruleset = ruleset;
      _cubit = cubit;
      _stage = _Stage.ready;
    });
    old?.close();
  }

  /// Autosave after every step; a finished mission clears the save and
  /// records its stars.
  void _changed(ContentBundle content, BattleViewState view) {
    final s = view.state;
    if (s.isOver) {
      _saves?.clear();
      if (s.outcome == Outcome.won) _progress?.recordStars(s.missionId, s.stars);
      return;
    }
    _saves?.save(SaveGame(missionId: s.missionId, contentHash: content.contentHash, seed: s.seed, actions: s.log));
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _Stage.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case _Stage.failed:
        return Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(AppLocalizations.of(context).battleLoadError)),
        );
      case _Stage.cannotResume:
        return _CannotResume(onRestart: () => _start(resume: false), onBack: () => Navigator.maybePop(context));
      case _Stage.ready:
        return BlocProvider.value(
          value: _cubit!,
          child: BattleScreen(
            ruleset: _ruleset!,
            onExit: () => Navigator.maybePop(context),
            onRetry: () => _start(resume: false),
          ),
        );
    }
  }
}

/// The save is from other content or is damaged: start the mission again, or
/// leave. (Build-spec section 4: "offer to restart the mission instead".)
class _CannotResume extends StatelessWidget {
  const _CannotResume({required this.onRestart, required this.onBack});

  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                key: const Key('cannot-resume'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.resumeUnusableTitle,
                    style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(l.resumeUnusableBody, style: const TextStyle(color: LongKyColors.ivory, fontSize: 15)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        key: const Key('resume-back'),
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, minTouch)),
                        child: Text(l.outcomeBack),
                      ),
                      FilledButton(
                        key: const Key('resume-restart'),
                        onPressed: onRestart,
                        style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                        child: Text(l.resumeRestart),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
