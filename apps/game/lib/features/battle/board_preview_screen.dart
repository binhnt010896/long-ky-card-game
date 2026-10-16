import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../data/content_repository.dart';
import 'battle_cubit.dart';
import 'battle_screen.dart';

/// Debug-only route: the battle screen on a mission's start state, until the
/// briefing hands over a real mission (T-17, T-18).
class BoardPreviewScreen extends StatefulWidget {
  const BoardPreviewScreen({super.key, this.missionId = 'ch1_m2', this.seed = 1, this.bundle});

  final String missionId;
  final int seed;
  final AssetBundle? bundle;

  @override
  State<BoardPreviewScreen> createState() => _BoardPreviewScreenState();
}

class _BoardPreviewScreenState extends State<BoardPreviewScreen> {
  late final Future<Ruleset> _loaded = _load();

  Future<Ruleset> _load() async {
    final ContentBundle content = await loadContentFromAssets(widget.bundle ?? rootBundle);
    return content.ruleset(widget.missionId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Ruleset>(
      future: _loaded,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            body: Center(child: snap.hasError ? Text('${snap.error}') : const CircularProgressIndicator()),
          );
        }
        final ruleset = snap.data!;
        return BlocProvider(
          create: (_) => BattleCubit(GameEngine(ruleset), seed: widget.seed),
          child: BattleScreen(ruleset: ruleset, onExit: () => Navigator.maybePop(context)),
        );
      },
    );
  }
}
