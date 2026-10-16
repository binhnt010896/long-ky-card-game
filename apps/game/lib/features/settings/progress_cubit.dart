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

  /// Keeps the best stars per mission: a star once earned is never lost by
  /// a later, worse run.
  Future<void> recordStars(String missionId, List<bool> stars) {
    final old = state.stars[missionId] ?? const <bool>[];
    final length = old.length > stars.length ? old.length : stars.length;
    final best = [for (var i = 0; i < length; i++) (i < old.length && old[i]) || (i < stars.length && stars[i])];
    if (best.length == old.length && [for (var i = 0; i < best.length; i++) best[i] == old[i]].every((x) => x)) {
      return Future.value();
    }
    return _update(state.copyWith(stars: {...state.stars, missionId: best}));
  }

  /// Remembers that [missionId]'s coach marks were finished or skipped, so
  /// they are not shown again.
  Future<void> markTutorialDone(String missionId) {
    if (state.tutorialDone.contains(missionId)) return Future.value();
    return _update(state.copyWith(tutorialDone: [...state.tutorialDone, missionId]));
  }

  /// Clears stars and unlocks; settings are kept.
  Future<void> resetProgress() => _update(state.reset());
}
