import 'package:flutter/services.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';

import 'content_repository.dart';

/// A mission's content, ready to play or to brief.
final class LoadedMission {
  const LoadedMission(this.content, this.ruleset);

  final ContentBundle content;
  final Ruleset ruleset;
}

/// Loads the game content from [bundle] and picks [missionId].
Future<LoadedMission> loadMission(AssetBundle bundle, String missionId) async {
  final content = await loadContentFromAssets(bundle);
  return LoadedMission(content, content.ruleset(missionId));
}
