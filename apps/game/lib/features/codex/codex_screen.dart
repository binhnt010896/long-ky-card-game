import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';

/// Officer, event and card lore (T-24).
class CodexScreen extends StatelessWidget {
  const CodexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.menuCodex)),
      body: Center(child: Text(l.comingSoon)),
    );
  }
}
