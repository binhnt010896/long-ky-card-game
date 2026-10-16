import '../../app/l10n/app_localizations.dart';
import '../../data/codex.dart';
import '../../data/long_ky_access.dart';
import '../settings/progress_cubit.dart';
import '../battle/labels.dart';

/// What came of an unlock code.
sealed class RedeemResult {
  const RedeemResult();
}

final class Redeemed extends RedeemResult {
  const Redeemed(this.entries, {required this.alreadyUnlocked});

  /// The pages that opened: one person, or all the cards of an event.
  final List<CodexEntry> entries;
  final bool alreadyUnlocked;
}

final class InvalidCode extends RedeemResult {
  const InvalidCode();
}

/// No secret is configured in this build, so no code can be checked.
final class CodesUnavailable extends RedeemResult {
  const CodesUnavailable();
}

/// Checks [input] offline against every Long Ký id in the [codex] and, if it
/// matches, unlocks that page (the same for a typed code and a deep link).
Future<RedeemResult> redeemCode({
  required String input,
  required LongKyAccess access,
  required Codex codex,
  required ProgressCubit progress,
}) async {
  if (!access.codes.isConfigured) return const CodesUnavailable();
  final id = access.codes.idFor(input, codex.unlockableIds);
  final entries = id == null ? const <CodexEntry>[] : codex.entriesOf(id);
  if (entries.isEmpty) return const InvalidCode();
  final already = progress.state.unlocks.contains(id);
  await progress.unlock(id!);
  return Redeemed(entries, alreadyUnlocked: already);
}

/// The sentence for [result] in the player's language.
String redeemMessage(AppLocalizations l, RedeemResult result) => switch (result) {
  Redeemed(:final entries, :final alreadyUnlocked) => () {
    final names = {for (final e in entries) l.content(e.name)}.join(', ');
    return alreadyUnlocked ? l.codexCodeAlready(names) : l.codexCodeOk(names);
  }(),
  InvalidCode() => l.codexCodeInvalid,
  CodesUnavailable() => l.codexCodeUnavailable,
};
