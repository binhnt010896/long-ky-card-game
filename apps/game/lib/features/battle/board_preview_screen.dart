import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../data/content_repository.dart';
import 'board/battle_board.dart';
import 'board/board_scene.dart';

/// Debug-only screen that draws the start state of a mission, until the
/// full battle screen exists (T-16, T-17).
class BoardPreviewScreen extends StatefulWidget {
  const BoardPreviewScreen({super.key, this.missionId = 'ch1_m2', this.seed = 1, this.bundle});

  final String missionId;
  final int seed;
  final AssetBundle? bundle;

  @override
  State<BoardPreviewScreen> createState() => _BoardPreviewScreenState();
}

class _BoardPreviewScreenState extends State<BoardPreviewScreen> {
  late final Future<(Ruleset, GameState)> _loaded = _load();
  Selection? _selection;

  Future<(Ruleset, GameState)> _load() async {
    final ContentBundle content = await loadContentFromAssets(widget.bundle ?? rootBundle);
    final ruleset = content.ruleset(widget.missionId);
    return (ruleset, GameEngine(ruleset).newGame(widget.seed).state);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: FutureBuilder<(Ruleset, GameState)>(
        future: _loaded,
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: snap.hasError ? Text('${snap.error}') : const CircularProgressIndicator());
          final (ruleset, state) = snap.data!;
          return Stack(
            children: [
              Positioned.fill(
                child: BattleBoard(
                  ruleset: ruleset,
                  state: state,
                  languageCode: lang,
                  onSelectionChanged: (s) => setState(() => _selection = s),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BackButton(onPressed: () => Navigator.maybePop(context)),
                        Text(_selection == null ? '${widget.missionId} · turn ${state.turn}' : '$_selection'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
