import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/progress.dart';
import '../../data/progress_repository.dart';

/// Holds [Progress] (settings, stars, unlocks) and saves every change.
class ProgressCubit extends Cubit<Progress> {
  ProgressCubit(this._repository, Progress initial) : super(initial);

  final ProgressRepository _repository;

  Future<void> _update(Progress next) async {
    emit(next);
    await _repository.save(next);
  }

  Future<void> updateSettings(GameSettings Function(GameSettings s) change) =>
      _update(state.copyWith(settings: change(state.settings)));

  Future<void> setLanguage(String code) => updateSettings((s) => s.copyWith(languageCode: code));

  Future<void> setTextScale(double scale) => updateSettings((s) => s.copyWith(textScale: scale));

  Future<void> setReduceMotion(bool on) => updateSettings((s) => s.copyWith(reduceMotion: on));

  /// Clears stars and unlocks; settings are kept.
  Future<void> resetProgress() => _update(state.reset());
}
