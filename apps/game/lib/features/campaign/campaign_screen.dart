import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/lacquer.dart';
import '../../app/theme.dart';
import '../../data/battle_save_repository.dart';
import '../../data/campaign.dart';
import '../../data/content_repository.dart';
import '../../data/progress.dart';
import '../battle/labels.dart';
import '../briefing/briefing_screen.dart';
import '../settings/progress_cubit.dart';

/// Loads the content for the campaign screens.
mixin _ContentLoader<T extends StatefulWidget> on State<T> {
  ContentBundle? bundle;
  bool loadFailed = false;

  AssetBundle get assets => context.getInheritedWidgetOfExactType<DefaultAssetBundle>()?.bundle ?? rootBundle;

  Future<void> loadCampaignContent() async {
    try {
      final b = await loadContentFromAssets(assets);
      if (mounted) setState(() => bundle = b);
    } on Object {
      if (mounted) setState(() => loadFailed = true);
    }
  }
}

/// The campaign (build-spec section 6): the chapters, each with how far the
/// player has got; a chapter opens the list of its missions.
class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> with _ContentLoader<CampaignScreen> {
  bool _offered = false;

  @override
  void initState() {
    super.initState();
    loadCampaignContent();
  }

  /// A player who has not played anything yet is taken to the training
  /// mission, once; backing out of it leaves the campaign list as usual.
  void _offerTraining(Campaign campaign, Progress progress) {
    final training = campaign.training;
    if (_offered || training == null) return;
    _offered = true;
    if (progress.stars.isNotEmpty || progress.tutorialDone.contains(training.id)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProgressCubit>().markTutorialDone(training.id);
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BriefingScreen(missionId: training.id)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final body = loadFailed
        ? Center(child: Text(l.battleLoadError))
        : bundle == null
        ? const Center(child: CircularProgressIndicator())
        : BlocBuilder<ProgressCubit, Progress>(
            builder: (context, progress) {
              final campaign = Campaign(bundle!.missions.values);
              _offerTraining(campaign, progress);
              return _CentredList(
                children: [
                  for (final chapter in campaign.chapters)
                    _ChapterCard(
                      key: Key('chapter-$chapter'),
                      chapter: chapter,
                      campaign: campaign,
                      progress: progress,
                    ),
                ],
              );
            },
          );
    return LacquerPage(title: l.menuCampaign, body: body);
  }
}

class _CentredList extends StatelessWidget {
  const _CentredList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        // A chapter has a handful of rows: build them all, so none below the
        // fold is dropped by a lazy list.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({super.key, required this.chapter, required this.campaign, required this.progress});

  final int chapter;
  final Campaign campaign;
  final Progress progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final open = campaign.chapterUnlocked(progress, chapter);
    final missions = campaign.missionsOf(chapter);
    final summary = l.campaignChapterSummary(
      campaign.wonInChapter(progress, chapter),
      missions.length,
      campaign.starsInChapter(progress, chapter),
      campaign.starsPossible(chapter),
    );
    final training = chapter == Campaign.trainingChapter;
    return _Tile(
      artPath: 'ui/title-cover.jpg',
      title: training ? l.campaignTraining : l.campaignChapter(chapter),
      subtitle: !open ? l.campaignLocked : (training ? '${l.campaignTrainingHint} · $summary' : summary),
      locked: !open,
      onTap: open
          ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ChapterScreen(chapter: chapter)))
          : null,
    );
  }
}

/// The missions of one chapter, with their stars and locks.
class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key, required this.chapter});

  final int chapter;

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> with _ContentLoader<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    loadCampaignContent();
  }

  BattleSaveRepository? get _saves {
    try {
      return context.read<BattleSaveRepository>();
    } on Object {
      return null;
    }
  }

  /// Opens the briefing of [m]. A saved battle is lost when another one
  /// starts, so the player is asked first.
  Future<void> _open(MissionDef m) async {
    final l = AppLocalizations.of(context);
    final saved = await _saves?.exists() ?? false;
    if (!mounted) return;
    if (saved) {
      final go = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          key: const Key('replace-save'),
          title: Text(l.campaignReplaceTitle),
          content: Text(l.campaignReplaceBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
            FilledButton(
              key: const Key('replace-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.campaignStartAnyway),
            ),
          ],
        ),
      );
      if (go != true || !mounted) return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BriefingScreen(missionId: m.id)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final body = loadFailed
        ? Center(child: Text(l.battleLoadError))
        : bundle == null
        ? const Center(child: CircularProgressIndicator())
        : BlocBuilder<ProgressCubit, Progress>(
            builder: (context, progress) {
              final campaign = Campaign(bundle!.missions.values);
              return _CentredList(
                children: [
                  for (final m in campaign.missionsOf(widget.chapter))
                    _MissionTile(
                      key: Key('mission-${m.id}'),
                      mission: m,
                      progress: progress,
                      unlocked: campaign.isUnlocked(progress, m.id),
                      onOpen: () => _open(m),
                    ),
                ],
              );
            },
          );
    return LacquerPage(
      title: widget.chapter == Campaign.trainingChapter ? l.campaignTraining : l.campaignChapter(widget.chapter),
      body: body,
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    super.key,
    required this.mission,
    required this.progress,
    required this.unlocked,
    required this.onOpen,
  });

  final MissionDef mission;
  final Progress progress;
  final bool unlocked;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final earned = Campaign.starsEarned(progress, mission.id);
    final total = mission.stars.length;
    return _Tile(
      artPath: mission.art,
      title: l.content(mission.title),
      subtitle: !unlocked
          ? l.campaignLockedHint
          : (mission.chapter == Campaign.trainingChapter ? l.campaignTrainingHint : l.campaignMissionNumber(mission.order)),
      locked: !unlocked,
      stars: unlocked ? (earned: earned, total: total) : null,
      onTap: unlocked ? onOpen : null,
    );
  }
}

/// A row of the campaign: a title, a line under it, the stars or a lock.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.subtitle,
    required this.locked,
    this.artPath,
    this.stars,
    this.onTap,
  });

  /// The painted picture on the left, under `assets/images/`.
  final String? artPath;
  final String title;
  final String subtitle;
  final bool locked;
  final ({int earned, int total})? stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      enabled: !locked,
      label: [title, subtitle, if (stars != null) l.campaignStarsSemantics(stars!.earned, stars!.total)].join(', '),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 84),
            clipBehavior: Clip.antiAlias,
            decoration: lacquerCard(glow: !locked && onTap != null),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 84,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Color(0xFF1A0D0C)),
                      PaintedImage(path: artPath),
                      // A locked mission is dimmed and shows a lock.
                      if (locked)
                        ColoredBox(
                          color: Colors.black.withValues(alpha: 0.65),
                          child: const Center(
                            child: Icon(Icons.lock_outline, key: Key('lock'), color: LongKyColors.ivory),
                          ),
                        ),
                      // Fade into the panel.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0x00000000), Color(0xFF1B0F0D)],
                            stops: [0.55, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: locked ? LongKyColors.goldLeaf.withValues(alpha: 0.6) : LongKyColors.goldLeaf,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(color: LongKyColors.ivory.withValues(alpha: locked ? 0.6 : 0.85), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!locked && stars != null)
                  // Filled or outlined, so the count is not told by colour alone.
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Row(
                      key: const Key('stars'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < stars!.total; i++)
                          Icon(
                            i < stars!.earned ? Icons.star : Icons.star_border,
                            size: 22,
                            color: LongKyColors.goldLeaf,
                          ),
                      ],
                    ),
                  )
                else if (!locked)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.chevron_right, color: LongKyColors.goldLeaf),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
