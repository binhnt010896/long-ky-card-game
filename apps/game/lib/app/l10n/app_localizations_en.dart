// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Long Ký - The Game';

  @override
  String get menuContinue => 'Continue';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get menuCodex => 'Codex';

  @override
  String get menuSettings => 'Settings';

  @override
  String get comingSoon => 'Coming soon.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get volumeMusic => 'Music';

  @override
  String get volumeVoice => 'Voice';

  @override
  String get volumeEffects => 'Effects';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint => 'Skip map animations.';

  @override
  String get settingsResetProgress => 'Reset progress';

  @override
  String get resetConfirmTitle => 'Reset all progress?';

  @override
  String get resetConfirmBody =>
      'Stars and unlocks will be erased. Settings are kept.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionReset => 'Reset';

  @override
  String get resetDone => 'Progress reset.';

  @override
  String get settingsCredits => 'Credits and sources';

  @override
  String get creditsFont =>
      'Be Vietnam Pro typeface, under the SIL Open Font License 1.1.';

  @override
  String get creditsLicenses => 'Software licences';

  @override
  String get creditsSources => 'Sources';

  @override
  String get creditsLoadError => 'Could not read the source list.';

  @override
  String battleTurnClock(int turn, int total) {
    return 'Turn $turn/$total';
  }

  @override
  String battleSeasonClockSemantics(int turn, int total) {
    return 'Season clock: turn $turn of $total';
  }

  @override
  String get phaseIntel => 'Intel';

  @override
  String get phaseCouncil => 'Council';

  @override
  String get phaseOrders => 'Orders';

  @override
  String get phaseResolution => 'Resolution';

  @override
  String get phaseUpkeep => 'Upkeep';

  @override
  String get phaseEnded => 'Ended';

  @override
  String get resourceRice => 'Rice';

  @override
  String get resourceSupport => 'Support';

  @override
  String get unityCourt => 'Court';

  @override
  String get unityClan => 'Clan';

  @override
  String get unityPeople => 'People';

  @override
  String unitySemantics(String pillar, int value) {
    return '$pillar: $value of 10';
  }

  @override
  String unitySemanticsLow(String pillar, int value) {
    return '$pillar: $value of 10, low';
  }

  @override
  String resourceSemantics(String resource, int value) {
    return '$resource: $value';
  }

  @override
  String get officerStripLabel => 'Officers';

  @override
  String troopsShort(int n) {
    return '${n}k';
  }

  @override
  String troopsFull(int n) {
    return '$n,000 troops';
  }

  @override
  String moraleShort(int n) {
    return 'Morale $n';
  }

  @override
  String get statusDefected => 'Defected';

  @override
  String get statusCaptured => 'Captured';

  @override
  String get orderNone => 'No order';

  @override
  String get orderHold => 'Hold';

  @override
  String get orderMove => 'Move';

  @override
  String get orderEvacuate => 'Evacuate';

  @override
  String get orderRaid => 'Raid';

  @override
  String get orderAmbush => 'Ambush';

  @override
  String get orderRally => 'Rally';

  @override
  String orderWithTarget(String order, String target) {
    return '$order: $target';
  }

  @override
  String officerSemantics(String name, String troops, String state) {
    return '$name, $troops, $state';
  }

  @override
  String handTitle(int count) {
    return 'Hand ($count)';
  }

  @override
  String get handEmpty => 'No cards in hand.';

  @override
  String get handShow => 'Show hand';

  @override
  String get handHide => 'Hide hand';

  @override
  String handPiles(int deck, int discard) {
    return 'Draw: $deck · Discard: $discard';
  }

  @override
  String handCourtSurcharge(int extra) {
    return 'Court is low: every card costs $extra more Support.';
  }

  @override
  String get cardTypeStratagem => 'Stratagem';

  @override
  String get cardTypeEvent => 'Event';

  @override
  String get cardTypeIntent => 'Enemy intent';

  @override
  String get cardFree => 'Free';

  @override
  String get cardCannotAfford => 'Cannot afford';

  @override
  String cardCostSemantics(int rice, int support) {
    return 'Cost: $rice Rice, $support Support';
  }

  @override
  String cardSemantics(String name, String type, String cost) {
    return '$name, $type, $cost';
  }

  @override
  String get phaseButtonCouncil => 'To Orders';

  @override
  String get phaseButtonOrders => 'Resolve turn';

  @override
  String get phaseButtonChoice => 'Choose first';

  @override
  String get phaseButtonEnded => 'Mission over';

  @override
  String get phaseButtonWait => 'In progress';

  @override
  String get logTitle => 'Log';

  @override
  String get logShow => 'Open log';

  @override
  String get logHide => 'Close log';

  @override
  String get logCollapse => 'Collapse log';

  @override
  String get logExpand => 'Expand log';

  @override
  String get logEmpty => 'Nothing has happened yet.';

  @override
  String logTurnStarted(int turn) {
    return 'Turn $turn begins.';
  }

  @override
  String logPhaseChanged(String phase) {
    return 'Phase: $phase.';
  }

  @override
  String logCardPlayed(String card) {
    return 'Played $card.';
  }

  @override
  String logCardPlayedOn(String card, String target) {
    return 'Played $card on $target.';
  }

  @override
  String logSkillUsed(String officer, String skill) {
    return '$officer used $skill.';
  }

  @override
  String logOrderSet(String officer, String order) {
    return '$officer: $order.';
  }

  @override
  String logOrderCleared(String officer) {
    return '$officer: order cleared.';
  }

  @override
  String get logOrdersSkipped => 'Orders are skipped this turn.';

  @override
  String logUnitMoved(String unit, String from, String to) {
    return '$unit moved from $from to $to.';
  }

  @override
  String logNodeEvacuated(String node, int rice) {
    return '$node evacuated: +$rice Rice.';
  }

  @override
  String logRallied(String officer, String node, int troops) {
    return '$officer rallied $troops,000 more troops at $node.';
  }

  @override
  String logAmbushPlaced(String officer, String edge) {
    return '$officer set an ambush on $edge.';
  }

  @override
  String logBattleWon(String node) {
    return 'Battle at $node: Đại Việt wins.';
  }

  @override
  String logBattleLost(String node) {
    return 'Battle at $node: the Yuan win.';
  }

  @override
  String logBattleDraw(String node) {
    return 'Battle at $node: no winner.';
  }

  @override
  String logOfficerCaptured(String officer, String node) {
    return '$officer was captured at $node.';
  }

  @override
  String logKingShielded(String king, String shield) {
    return '$shield shielded $king.';
  }

  @override
  String logRaided(String officer, String army, int supply, int troops) {
    return '$officer raided $army: Supply -$supply, troops -${troops}k.';
  }

  @override
  String logForaged(String army, String node, int supply) {
    return '$army foraged at $node: Supply +$supply.';
  }

  @override
  String logNodeControl(String node, String side) {
    return '$node now belongs to $side.';
  }

  @override
  String logArmyRouted(String army) {
    return '$army is routed.';
  }

  @override
  String logStarvation(String army, int morale, int troops) {
    return '$army is starving: morale -$morale, troops -${troops}k.';
  }

  @override
  String logAttrition(String army, int troops) {
    return '$army lost ${troops}k to attrition.';
  }

  @override
  String logIncome(int gained, int upkeep) {
    return 'Income $gained Rice, upkeep $upkeep Rice.';
  }

  @override
  String get logIncomeShortfall => 'Rice ran short: every officer lost morale.';

  @override
  String logDefected(String officer) {
    return '$officer defected.';
  }

  @override
  String logInducementResisted(String officer) {
    return '$officer resisted the offer.';
  }

  @override
  String get logChoiceRequested => 'A decision is needed.';

  @override
  String logUnityChanged(String pillar, int from, int to) {
    return '$pillar: $from to $to.';
  }

  @override
  String logResourceChanged(String resource, int from, int to) {
    return '$resource: $from to $to.';
  }

  @override
  String get logMissionWon => 'Mission won.';

  @override
  String get logMissionLost => 'Mission lost.';

  @override
  String get inspectorClose => 'Close inspector';

  @override
  String get terrainCity => 'City';

  @override
  String get terrainPlain => 'Plain';

  @override
  String get terrainRiver => 'River';

  @override
  String get terrainMarsh => 'Marsh';

  @override
  String get terrainHill => 'Hill';

  @override
  String get sideDaiViet => 'Đại Việt';

  @override
  String get sideYuan => 'the Yuan';

  @override
  String get sideNone => 'nobody';

  @override
  String get nodeCapital => 'Capital';

  @override
  String get nodeBorder => 'Border';

  @override
  String get nodeEvacuated => 'Evacuated';

  @override
  String nodeControlledBy(String side) {
    return 'Held by $side';
  }

  @override
  String nodeRiceStock(int n) {
    return 'Rice stock: $n';
  }

  @override
  String get nodeUnits => 'Here now';

  @override
  String get nodeNoUnits => 'Nobody here.';

  @override
  String get statLeadership => 'Leadership';

  @override
  String get statWar => 'War';

  @override
  String get statIntelligence => 'Intelligence';

  @override
  String get statPolitics => 'Politics';

  @override
  String get statLoyalty => 'Loyalty';

  @override
  String get inspectorOrder => 'Order';

  @override
  String get inspectorSkill => 'Skill';

  @override
  String get inspectorFlaw => 'Flaw';

  @override
  String get skillPassive => 'Passive';

  @override
  String skillUsesLeft(int n) {
    return '$n uses left';
  }

  @override
  String get officerIsKing => 'King';

  @override
  String get inspectorCommander => 'Commander';

  @override
  String inspectorSupply(int supply, int max) {
    return 'Supply $supply/$max';
  }

  @override
  String get inspectorIntent => 'Intent';

  @override
  String get intentHold => 'Hold';

  @override
  String get intentAdvance => 'Advance';

  @override
  String get intentAssault => 'Assault';

  @override
  String get intentForage => 'Forage';

  @override
  String get intentRetreat => 'Retreat';

  @override
  String get intentUnknown => 'Unknown';

  @override
  String intentToward(String intent, String node) {
    return '$intent toward $node';
  }

  @override
  String intentPredicted(String intent) {
    return 'Next turn: $intent';
  }

  @override
  String get armyRouted => 'Routed';

  @override
  String armyOf(String commander) {
    return '$commander\'s army';
  }

  @override
  String get cardPlay => 'Play card';

  @override
  String cardPlayOn(String target) {
    return 'Play on $target';
  }

  @override
  String get cardPickTarget => 'Choose a target:';

  @override
  String get cardNoTargets => 'There is no legal target.';

  @override
  String get cardOnlyCouncil => 'Cards can only be played during Council.';

  @override
  String get cardFinal => 'A played card cannot be taken back.';

  @override
  String get cardClose => 'Close';

  @override
  String get skillUse => 'Use skill';

  @override
  String skillUseOn(String target) {
    return 'Use skill on $target';
  }

  @override
  String get ordersTitle => 'Give an order';

  @override
  String get orderClear => 'Clear order';

  @override
  String get ordersOnlyInOrders => 'Orders are given during the Orders phase.';

  @override
  String get ordersNone => 'No order is possible.';

  @override
  String get orderNoOrders => 'Takes no orders this turn.';

  @override
  String orderCostSupport(String order, String support, int n) {
    return '$order ($support $n)';
  }

  @override
  String get previewTitle => 'Battle preview';

  @override
  String previewField(String node) {
    return 'Battle at $node';
  }

  @override
  String previewAmbush(String edge) {
    return 'Ambush on $edge';
  }

  @override
  String previewOfficers(String names) {
    return 'Our officers: $names';
  }

  @override
  String previewArmies(String names) {
    return 'Enemy: $names';
  }

  @override
  String previewPowers(String dv, String yuan) {
    return 'Power: Đại Việt $dv, the Yuan $yuan';
  }

  @override
  String previewWinner(String side) {
    return 'Expected: $side wins';
  }

  @override
  String previewUncertain(String low, String high) {
    return 'The result depends on the roll: $low wins on a low roll, $high on a high roll.';
  }

  @override
  String previewLosses(String dv, String yuan) {
    return 'Expected losses: Đại Việt ${dv}k, the Yuan ${yuan}k';
  }

  @override
  String get previewConfirm => 'Give this order anyway';

  @override
  String get choiceTitle => 'A decision is needed';

  @override
  String get outcomeWon => 'Victory';

  @override
  String get outcomeLost => 'Defeat';

  @override
  String outcomeStars(int n, int total) {
    return 'Stars earned: $n/$total';
  }

  @override
  String get lossKingCaptured => 'The king was captured.';

  @override
  String get lossSeasonEnded => 'The season ended.';

  @override
  String lossUnity(String pillar) {
    return '$pillar ran out.';
  }

  @override
  String get lossObjective => 'The mission objective was not met.';

  @override
  String get outcomeBack => 'Back';

  @override
  String get resultObjectives => 'Objectives';

  @override
  String get resultMet => 'Met';

  @override
  String get resultNotMet => 'Not met';

  @override
  String get resultDebrief => 'Debrief';

  @override
  String get resultRetry => 'Play again';

  @override
  String get objWon => 'Win the mission';

  @override
  String get objAllArmiesBroken => 'Break every enemy army';

  @override
  String objArmyBroken(String army) {
    return 'Break $army';
  }

  @override
  String objCounterattackAt(String node) {
    return 'Win a counterattack at $node';
  }

  @override
  String objSurviveTurns(int n) {
    return 'Survive $n turns';
  }

  @override
  String objKingAt(String node, int turn) {
    return 'Bring the king to $node by the end of turn $turn';
  }

  @override
  String objArmySupplyAtMost(String army, int percent) {
    return '$army\'s Supply at most $percent%';
  }

  @override
  String get objKingNotCaptured => 'The king is not captured';

  @override
  String get objCapitalHeld => 'Hold the capital';

  @override
  String objUnityAllAbove(int n) {
    return 'Every Unity pillar above $n';
  }

  @override
  String objUnityAtLeast(String pillar, int n) {
    return '$pillar at least $n at the end';
  }

  @override
  String get objNoDefections => 'No officer defects';

  @override
  String get objNoCaptures => 'No officer is captured';

  @override
  String objTroopsLostAtMost(int n) {
    return 'Lose at most $n,000 troops';
  }

  @override
  String objWinByTurn(int turn) {
    return 'Win by the end of turn $turn';
  }

  @override
  String objAnyOf(String a, String b) {
    return '$a or $b';
  }

  @override
  String get resumeUnusableTitle => 'The saved battle cannot be continued';

  @override
  String get resumeUnusableBody =>
      'The game content has changed or the save is damaged. Start this mission again?';

  @override
  String get resumeRestart => 'Start again';

  @override
  String get battleLoadError => 'Could not load the mission.';

  @override
  String get battleMenuTitle => 'Paused';

  @override
  String get battleMenuResume => 'Resume';

  @override
  String get battleMenuLeave => 'Leave the battle (saved)';

  @override
  String shortcutHint(String label, String keys) {
    return '$label ($keys)';
  }

  @override
  String get briefingObjectives => 'Objectives';

  @override
  String get briefingOfficers => 'Officers in the field';

  @override
  String briefingOfficerLine(String troops, String node) {
    return '$troops at $node';
  }

  @override
  String get briefingStart => 'Start the mission';

  @override
  String get briefingSubtitles => 'Narration subtitles';

  @override
  String get briefingPlayVoice => 'Play the narration';

  @override
  String get briefingStopVoice => 'Stop the narration';

  @override
  String get briefingLoadError => 'Could not load the briefing.';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialGotIt => 'Got it';

  @override
  String get tutorialSkip => 'Skip the tutorial';

  @override
  String tutorialCount(int n, int total) {
    return '$n/$total';
  }

  @override
  String tutorialSemantics(String text) {
    return 'Tutorial: $text';
  }

  @override
  String campaignChapter(int n) {
    return 'Chapter $n';
  }

  @override
  String campaignChapterSummary(int won, int total, int stars, int starsTotal) {
    return '$won/$total missions · $stars/$starsTotal stars';
  }

  @override
  String campaignMissionNumber(int n) {
    return 'Mission $n';
  }

  @override
  String get campaignLocked => 'Locked';

  @override
  String get campaignLockedHint =>
      'Win the previous mission to unlock this one.';

  @override
  String campaignStarsSemantics(int n, int total) {
    return '$n of $total stars';
  }

  @override
  String get campaignReplaceTitle => 'Replace the saved battle?';

  @override
  String get campaignReplaceBody =>
      'The saved battle is lost if you start this mission.';

  @override
  String get campaignStartAnyway => 'Start anyway';

  @override
  String resultUnlocked(String title) {
    return 'Unlocked: $title';
  }

  @override
  String get resultNext => 'Next mission';

  @override
  String get codexOfficers => 'Đại Việt officers';

  @override
  String get codexEnemies => 'Mongol–Yuan commanders';

  @override
  String get codexCards => 'Stratagems and events';

  @override
  String get codexUnlocked => 'Unlocked';

  @override
  String get codexSources => 'Sources';

  @override
  String get codexCodeTitle => 'Enter an unlock code';

  @override
  String get codexCodeHelp =>
      'The code appears after you finish a lesson in Long Ký.';

  @override
  String get codexCodeField => 'Unlock code';

  @override
  String get codexCodeRedeem => 'Unlock';

  @override
  String codexCodeOk(String name) {
    return 'Unlocked: $name.';
  }

  @override
  String codexCodeAlready(String name) {
    return '$name was already unlocked.';
  }

  @override
  String get codexCodeInvalid =>
      'That code is not valid. Check it and try again.';

  @override
  String get codexCodeUnavailable => 'Codes cannot be checked in this build.';

  @override
  String get longKyReadMore => 'Read more in Long Ký';

  @override
  String get longKyScan => 'Scan with your phone to open Long Ký';

  @override
  String get longKyQrSemantics => 'QR code that opens Long Ký';

  @override
  String get longKyOpenFailed => 'Could not open Long Ký.';

  @override
  String get actionClose => 'Close';

  @override
  String get briefingLoss => 'You lose if';

  @override
  String lossTroopsOver(int n) {
    return 'Our losses pass $n,000 troops';
  }

  @override
  String get boardZoomIn => 'Zoom in';

  @override
  String get boardZoomOut => 'Zoom out';

  @override
  String get boardZoomReset => 'Show the whole map';

  @override
  String get tutorialDoIt => 'Do what the prompt says to continue.';

  @override
  String get tutorialSkipStep => 'Skip step';

  @override
  String get campaignTraining => 'Training';

  @override
  String get campaignTrainingHint => 'A step-by-step lesson on how to play.';
}
