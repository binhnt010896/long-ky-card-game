import 'package:flutter/material.dart';

import 'battle_page.dart';

/// Debug-only route: a new battle on a mission, until the campaign and
/// briefing screens (T-23) start missions.
class BoardPreviewScreen extends StatelessWidget {
  const BoardPreviewScreen({super.key, this.missionId = 'ch1_m2', this.seed, this.bundle});

  final String missionId;
  final int? seed;
  final AssetBundle? bundle;

  @override
  Widget build(BuildContext context) => BattlePage(missionId: missionId, seed: seed, bundle: bundle);
}
