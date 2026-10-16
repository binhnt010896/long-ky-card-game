import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';

/// Chapter and mission select (T-23).
class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.menuCampaign)),
      body: Center(child: Text(l.comingSoon)),
    );
  }
}
