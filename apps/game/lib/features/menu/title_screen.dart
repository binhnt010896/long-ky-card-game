import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';

/// Title screen: Continue, Campaign, Codex, Settings.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.appTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(color: LongKyColors.goldLeaf, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 40),
                // Continue resumes a saved battle (T-18); there is none yet.
                FilledButton(onPressed: null, child: Text(l.menuContinue)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.campaign),
                  child: Text(l.menuCampaign),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.codex),
                  child: Text(l.menuCodex),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.settings),
                  child: Text(l.menuSettings),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, Routes.boardPreview),
                    child: const Text('Board preview (debug)'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
