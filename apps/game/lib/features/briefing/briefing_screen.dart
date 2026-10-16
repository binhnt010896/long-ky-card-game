import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../audio/audio_service.dart';
import '../../data/mission_loader.dart';
import '../battle/battle_page.dart';
import '../battle/labels.dart';
import '../battle/overlays/panel.dart';

/// The Briefing (build-spec section 6): the narration with subtitles, the
/// objectives, the officers who start, and Start.
///
/// The voice is Vietnamese in both languages; the subtitles follow the chosen
/// language. Without a voice file (it ships with the audio) the subtitles are
/// all there is.
class BriefingScreen extends StatefulWidget {
  const BriefingScreen({super.key, required this.missionId, this.bundle, this.audio, this.seed});

  final String missionId;
  final AssetBundle? bundle;
  final AudioService? audio;

  /// The seed of the battle Start begins; by default one from the clock.
  final int? seed;

  @override
  State<BriefingScreen> createState() => _BriefingScreenState();
}

class _BriefingScreenState extends State<BriefingScreen> {
  LoadedMission? _loaded;
  bool _failed = false;
  late final AudioService _audio;
  StreamSubscription<String?>? _voiceSub;
  bool _listening = false;

  String get _voiceId => AudioPaths.briefing(widget.missionId);

  @override
  void initState() {
    super.initState();
    _audio = widget.audio ?? _maybeAudio() ?? AudioService.silent();
    _voiceSub = _audio.voiceChanges.listen((id) {
      if (mounted) setState(() => _listening = id == _voiceId);
    });
    _load();
  }

  AudioService? _maybeAudio() {
    try {
      return context.read<AudioService>();
    } on Object {
      return null;
    }
  }

  Future<void> _load() async {
    final bundle = widget.bundle ?? context.getInheritedWidgetOfExactType<DefaultAssetBundle>()?.bundle ?? rootBundle;
    try {
      final loaded = await loadMission(bundle, widget.missionId);
      if (!mounted) return;
      setState(() => _loaded = loaded);
      unawaited(_audio.playMusic(AudioPaths.chapterMusic(loaded.ruleset.mission.chapter)));
      unawaited(_audio.playVoice(_voiceId));
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _voiceSub?.cancel();
    _audio.stopVoice();
    super.dispose();
  }

  void _start() {
    _audio.stopVoice();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BattlePage(missionId: widget.missionId, seed: widget.seed, bundle: widget.bundle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loaded = _loaded;
    if (_failed) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.briefingLoadError)),
      );
    }
    if (loaded == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final ruleset = loaded.ruleset;
    final mission = ruleset.mission;
    final state = GameEngine(ruleset).newGame(widget.seed ?? 1).state;
    final namer = Namer(l, ruleset);
    final compact = BattleLayoutMode.forWidth(MediaQuery.sizeOf(context).width).isCompact;

    final narration = _Narration(
      title: l.content(mission.title),
      text: l.content(mission.briefing),
      listening: _listening,
      canListen: _audio.hasVoice(_voiceId),
      onToggle: () => _listening ? _audio.stopVoice() : _audio.playVoice(_voiceId),
    );
    final facts = _Facts(
      objectives: [for (final o in mission.win) namer.objective(state, o)],
      loseIf: namer.extraLossRules(mission),
      officers: [
        for (final p in mission.playerOfficers)
          (name: namer.officer(p.officerId), line: l.briefingOfficerLine(l.troopsFull(p.troops), namer.node(p.nodeId))),
      ],
    );
    final start = FilledButton(
      key: const Key('briefing-start'),
      onPressed: _start,
      style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
      child: Text(l.briefingStart),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: compact
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: narration),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(child: facts),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 16, 12),
                          child: SizedBox(width: double.infinity, child: start),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: narration),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(child: facts),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 24, 20),
                          child: SizedBox(width: double.infinity, child: start),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The mission title and the narration as subtitles, with a button to hear it.
class _Narration extends StatelessWidget {
  const _Narration({
    required this.title,
    required this.text,
    required this.listening,
    required this.canListen,
    required this.onToggle,
  });

  final String title;
  final String text;
  final bool listening;
  final bool canListen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: const Key('briefing-title'),
            style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: l.briefingSubtitles,
            container: true,
            child: Container(
              key: const Key('briefing-subtitles'),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: lacquerPanel(),
              child: Text(text, style: const TextStyle(color: LongKyColors.ivory, fontSize: 17, height: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          if (canListen)
            TextButton.icon(
              key: const Key('briefing-voice'),
              onPressed: onToggle,
              style: TextButton.styleFrom(minimumSize: const Size(minTouch, minTouch)),
              icon: Icon(listening ? Icons.stop_circle_outlined : Icons.volume_up_outlined),
              label: Text(listening ? l.briefingStopVoice : l.briefingPlayVoice),
            ),
        ],
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.objectives, required this.loseIf, required this.officers});

  final List<String> objectives;

  /// Extra ways to lose, beyond the standard ones.
  final List<String> loseIf;
  final List<({String name, String line})> officers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(l.briefingObjectives),
          for (var i = 0; i < objectives.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                objectives[i],
                key: Key('briefing-objective-$i'),
                style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.3),
              ),
            ),
          if (loseIf.isNotEmpty) ...[
            const SizedBox(height: 14),
            _heading(l.briefingLoss),
            for (var i = 0; i < loseIf.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  loseIf[i],
                  key: Key('briefing-loss-$i'),
                  style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.3),
                ),
              ),
          ],
          const SizedBox(height: 14),
          _heading(l.briefingOfficers),
          for (var i = 0; i < officers.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: officers[i].name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' · ${officers[i].line}'),
                  ],
                ),
                key: Key('briefing-officer-$i'),
                style: const TextStyle(color: LongKyColors.ivory, fontSize: 15, height: 1.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );
}
