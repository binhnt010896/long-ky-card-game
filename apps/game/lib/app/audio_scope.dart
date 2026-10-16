import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../audio/audio_service.dart';
import '../data/progress.dart';
import '../features/settings/progress_cubit.dart';

/// Keeps the [AudioService] in step with the app: the volumes of Settings
/// apply as they change, and sound pauses while the app is in the background.
class AudioScope extends StatefulWidget {
  const AudioScope({super.key, required this.audio, required this.child});

  final AudioService audio;
  final Widget child;

  @override
  State<AudioScope> createState() => _AudioScopeState();
}

class _AudioScopeState extends State<AudioScope> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.audio.applySettings(context.read<ProgressCubit>().state.settings);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.audio.resume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        widget.audio.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProgressCubit, Progress>(
      listenWhen: (a, b) =>
          a.settings.musicVolume != b.settings.musicVolume ||
          a.settings.voiceVolume != b.settings.voiceVolume ||
          a.settings.effectsVolume != b.settings.effectsVolume,
      listener: (context, progress) => widget.audio.applySettings(progress.settings),
      child: widget.child,
    );
  }
}
