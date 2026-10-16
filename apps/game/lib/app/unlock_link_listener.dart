import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/long_ky_config.dart';
import '../data/codex.dart';
import '../data/content_repository.dart';
import '../data/long_ky_access.dart';
import '../features/codex/redeem.dart';
import '../features/settings/progress_cubit.dart';
import 'l10n/app_localizations.dart';

/// The code in an incoming unlock link (`longkygame://unlock?code=LK-XXXX-XXXX`),
/// or null if [uri] is some other link.
String? unlockCodeOf(Uri uri) {
  if (uri.scheme != LongKyConfig.unlockScheme || uri.host != 'unlock') return null;
  final code = uri.queryParameters['code'];
  return code == null || code.isEmpty ? null : code;
}

/// Turns unlock links that open the game (mobile) into unlocks, and says what
/// happened in a snack bar. Anything that is not an unlock link is ignored.
class UnlockLinkListener extends StatefulWidget {
  const UnlockLinkListener({super.key, required this.links, required this.child});

  final Stream<Uri> links;
  final Widget child;

  @override
  State<UnlockLinkListener> createState() => _UnlockLinkListenerState();
}

class _UnlockLinkListenerState extends State<UnlockLinkListener> {
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.links.listen(_onLink);
  }

  @override
  void didUpdateWidget(UnlockLinkListener old) {
    super.didUpdateWidget(old);
    if (old.links != widget.links) {
      _subscription?.cancel();
      _subscription = widget.links.listen(_onLink);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _onLink(Uri uri) async {
    final code = unlockCodeOf(uri);
    if (code == null || !mounted) return;
    final progress = context.read<ProgressCubit>();
    final access = context.read<LongKyAccess>();
    final bundle = DefaultAssetBundle.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    RedeemResult result;
    try {
      final content = await loadContentFromAssets(bundle);
      result = await redeemCode(input: code, access: access, codex: Codex(content), progress: progress);
    } on Object {
      result = const InvalidCode();
    }
    if (!mounted) return;
    final l = lookupAppLocalizations(Locale(progress.state.settings.languageCode));
    messenger?.showSnackBar(SnackBar(content: Text(redeemMessage(l, result))));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
