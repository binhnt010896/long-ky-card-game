import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/progress.dart';
import 'progress_cubit.dart';

/// Language, audio volumes, text size, reduce motion, reset progress,
/// credits and sources. Every change applies at once and is saved.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<ProgressCubit>();
    final s = context.select<ProgressCubit, GameSettings>((c) => c.state.settings);
    final heading = Theme.of(context).textTheme.titleMedium?.copyWith(color: LongKyColors.goldLeaf);

    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(title, style: heading),
        );

    Widget volume(Key key, String label, double value, GameSettings Function(double v) change) => ListTile(
          title: Text(label),
          subtitle: Slider(
            key: key,
            value: value,
            divisions: 10,
            label: l.percentValue((value * 100).round()),
            semanticFormatterCallback: (v) => l.percentValue((v * 100).round()),
            onChanged: (v) => cubit.updateSettings((_) => change(v)),
          ),
          trailing: Text(l.percentValue((value * 100).round())),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            children: [
              section(l.settingsLanguage),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<String>(
                  key: const Key('language'),
                  segments: [
                    ButtonSegment(value: 'vi', label: Text(l.languageVietnamese)),
                    ButtonSegment(value: 'en', label: Text(l.languageEnglish)),
                  ],
                  selected: {s.languageCode},
                  onSelectionChanged: (v) => cubit.setLanguage(v.single),
                ),
              ),
              section(l.settingsAudio),
              volume(const Key('musicVolume'), l.volumeMusic, s.musicVolume, (v) => s.copyWith(musicVolume: v)),
              volume(const Key('voiceVolume'), l.volumeVoice, s.voiceVolume, (v) => s.copyWith(voiceVolume: v)),
              volume(const Key('effectsVolume'), l.volumeEffects, s.effectsVolume, (v) => s.copyWith(effectsVolume: v)),
              section(l.settingsTextSize),
              ListTile(
                title: Slider(
                  key: const Key('textScale'),
                  value: s.textScale,
                  min: GameSettings.minTextScale,
                  max: GameSettings.maxTextScale,
                  divisions: 7,
                  label: l.percentValue((s.textScale * 100).round()),
                  onChanged: cubit.setTextScale,
                ),
                trailing: Text(l.percentValue((s.textScale * 100).round())),
              ),
              SwitchListTile(
                key: const Key('reduceMotion'),
                title: Text(l.settingsReduceMotion),
                subtitle: Text(l.settingsReduceMotionHint),
                value: s.reduceMotion,
                onChanged: cubit.setReduceMotion,
              ),
              const Divider(height: 32),
              ListTile(
                key: const Key('credits'),
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l.settingsCredits),
                onTap: () => Navigator.pushNamed(context, Routes.credits),
              ),
              ListTile(
                key: const Key('resetProgress'),
                leading: const Icon(Icons.restart_alt, color: LongKyColors.cinnabar),
                title: Text(l.settingsResetProgress),
                onTap: () => _confirmReset(context, cubit),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, ProgressCubit cubit) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.resetConfirmTitle),
        content: Text(l.resetConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: LongKyColors.cinnabar,
              foregroundColor: LongKyColors.ivory,
              minimumSize: const Size(96, 48),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionReset),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await cubit.resetProgress();
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.resetDone)));
  }
}
