import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_rules/lk_rules.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import 'battle_cubit.dart';
import 'battle_keys.dart';
import 'battle_preview.dart';
import 'board/battle_board.dart';
import 'board/board_hover.dart';
import 'board/board_layout.dart';
import 'board/board_scene.dart';
import 'labels.dart';
import 'overlays/battle_menu.dart';
import 'overlays/objectives_dialog.dart';
import 'overlays/strategy_cutscene.dart';
import 'overlays/card_dialog.dart';
import 'overlays/choice_overlay.dart';
import 'overlays/event_log.dart';
import 'overlays/hand.dart';
import 'overlays/inspector.dart';
import 'overlays/officer_actions.dart';
import 'overlays/officer_strip.dart';
import 'overlays/result_screen.dart';
import 'overlays/panel.dart';
import 'overlays/phase_button.dart';
import 'overlays/preview_dialog.dart';
import 'overlays/top_bar.dart';
import '../tutorial/guided_flow.dart';
import '../tutorial/tutorial_coach.dart';
import '../tutorial/tutorial_flow.dart';

/// The battle screen: the Flame board with Flutter overlays around it
/// (build-spec section 6). Reads its [BattleCubit] from the context.
///
/// The board sits in the space the overlays leave free, so nothing covers
/// it except what is open on purpose: the inspector, the hand fan on
/// compact and the log popover on compact.
class BattleScreen extends StatefulWidget {
  const BattleScreen({
    super.key,
    required this.ruleset,
    this.onExit,
    this.onRetry,
    this.nextTitle,
    this.newlyUnlocked = false,
    this.onNext,
    this.tutorial = const [],
    this.onTutorialDone,
  });

  final Ruleset ruleset;

  /// Shows a back button in the top bar when set.
  final VoidCallback? onExit;

  /// Shows "Play again" on the Result screen when set.
  final VoidCallback? onRetry;

  /// The next mission after a win (T-23): its title, whether this win opened
  /// it, and how to go there.
  final LocalizedText? nextTitle;
  final bool newlyUnlocked;
  final VoidCallback? onNext;

  /// The mission's coach marks (T-22), when they are to be shown: empty for a
  /// player who has finished or skipped them.
  final List<TutorialStep> tutorial;

  /// Called once when the coach marks are over (all read, skipped or passed).
  final VoidCallback? onTutorialDone;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

/// The most the text size setting may enlarge the battle HUD on a phone.
const double compactMaxTextScale = 1.2;

class _BattleScreenState extends State<BattleScreen> {
  final GlobalKey<BattleBoardState> _boardKey = GlobalKey<BattleBoardState>();
  Selection? _selection;

  /// Regular: the left log panel is expanded.
  bool _logExpanded = true;

  /// Compact: the log popover and the hand fan are open.
  bool _logOpen = false;
  bool _handOpen = false;

  /// The board is playing the last step's animations.
  /// The strategy whose cutscene is playing, and the step that started it.
  CardDef? _cutscene;
  int _cutsceneStep = -1;

  /// The Result screen is shown on request, after the board has been looked at.
  bool _showResult = false;
  bool _busy = false;

  // Coach marks (T-22): what has been read, and the elements they point at.
  final Set<String> _readTips = {};
  bool _tutorialReported = false;
  String? _measuredFor;
  String? _guidedTargetFor;
  Rect? _guidedTarget;
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _topBarKey = GlobalKey();
  final GlobalKey _stripKey = GlobalKey();
  final GlobalKey _phaseKey = GlobalKey();
  final GlobalKey _handKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // A battle picked up late (resumed in turn 3) has nothing left to teach.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final guided = _guided;
      if (guided != null) {
        // Pick the lesson up where the game is.
        setState(() => guided.resumeAt(_tutorialContext(BattleLayoutMode.forWidth(MediaQuery.sizeOf(context).width))));
        return;
      }
      if (_tutorialOn && _flow.finished(_cubit.game, _readTips)) _reportTutorialDone();
    });
  }

  late final TutorialFlow _flow = TutorialFlow([for (final t in widget.tutorial) t.id]);

  /// The training mission has steps that wait for the player to act (`until`);
  /// its tutorial is guided instead of a list of tips.
  late final GuidedFlow? _guided = widget.tutorial.any((t) => t.until != null) ? GuidedFlow(widget.tutorial) : null;

  bool get _tutorialOn => widget.tutorial.isNotEmpty && !_tutorialReported && !(_guided?.finished ?? false);

  /// Nothing is left to teach: every step is over, or the mission is.
  bool _flowFinished(GameState state) {
    final guided = _guided;
    return guided == null ? _flow.finished(state, _readTips) : (state.isOver || guided.finished);
  }

  /// What the game and the screen look like now, for the guided steps.
  TutorialContext _tutorialContext(BattleLayoutMode mode) {
    final s = _selection;
    final kind = switch (s?.kind) {
      SelectionKind.node => SelectionTarget.node,
      SelectionKind.officer => SelectionTarget.officer,
      SelectionKind.army => SelectionTarget.army,
      null => null,
    };
    return TutorialContext(
      state: _cubit.game,
      ruleset: widget.ruleset,
      selectedKind: kind,
      selectedId: s?.id,
      // The regular layout always shows the hand.
      handOpen: !mode.isCompact || _handOpen,
      zoomed: _boardKey.currentState?.game.view.value.isZoomed ?? false,
    );
  }

  void _reportTutorialDone() {
    if (_tutorialReported) return;
    setState(() => _tutorialReported = true);
    widget.onTutorialDone?.call();
  }

  void _readTip(String id) {
    setState(() => _readTips.add(id));
    if (_flow.finished(_cubit.game, _readTips)) _reportTutorialDone();
  }

  /// Next (or "skip this step") on a guided step.
  void _guidedAdvance() {
    final guided = _guided!;
    setState(guided.advance);
    if (guided.finished) _reportTutorialDone();
  }

  /// A rect of an element, in the coordinates of the screen's own stack.
  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    final stack = _stackKey.currentContext?.findRenderObject();
    if (box is! RenderBox || stack is! RenderBox || !box.attached || !stack.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
  }

  /// The spotlit element of a coach mark (`highlight` in the content).
  Rect? _spotlight(String? highlight, BattleLayoutMode mode) {
    switch (highlight) {
      case 'topBar':
        return _rectOf(_topBarKey);
      case 'officerStrip':
        return _rectOf(_stripKey);
      case 'phaseButton':
      case 'battlePreview':
        return _rectOf(_phaseKey);
      case 'hand':
        return _rectOf(_handKey);
      case 'map':
        return _rectOf(_boardKey);
      case 'zoom':
        return _unionOfKeys(const [Key('zoom-in'), Key('zoom-out'), Key('zoom-reset')]);
      case 'inspector':
        return _firstRectOfKeys(const [Key('inspector-officer'), Key('inspector-node'), Key('inspector-army')]);
      case 'log':
        return _firstRectOfKeys(const [Key('log-panel'), Key('log-button')]);
      case 'intentArrows':
        final board = _rectOf(_boardKey);
        final scene = _boardKey.currentState?.game.scene;
        if (board == null || scene == null || scene.arrows.isEmpty) return board;
        var r = Rect.fromPoints(scene.arrows.first.start, scene.arrows.first.end);
        for (final a in scene.arrows) {
          r = r.expandToInclude(Rect.fromPoints(a.start, a.end));
        }
        return r.inflate(scene.layout.nodeRadius).shift(board.topLeft);
      default:
        // `officer:<id>` (its tile in the strip), `army:<id>` and `node:<id>` (on the board).
        final parts = highlight?.split(':');
        if (parts == null || parts.length != 2) return null;
        switch (parts[0]) {
          case 'officer':
            return _rectOfKey(Key('officer-${parts[1]}'));
          case 'army':
          case 'node':
            final board = _rectOf(_boardKey);
            final scene = _boardKey.currentState?.game.scene;
            if (board == null || scene == null) return null;
            if (parts[0] == 'node') {
              final n = scene.nodes.where((n) => n.id == parts[1]).firstOrNull;
              return n == null ? null : Rect.fromCircle(center: n.center, radius: n.radius + 4).shift(board.topLeft);
            }
            final t = scene.tokens.where((t) => t.id == parts[1]).firstOrNull;
            return t == null ? null : Rect.fromCircle(center: t.center, radius: t.radius + 4).shift(board.topLeft);
        }
        return null;
    }
  }

  /// The rect of the widget with [key] anywhere under the screen's stack.
  Rect? _rectOfKey(Key key) {
    final stack = _stackKey.currentContext;
    final stackBox = stack?.findRenderObject();
    if (stack == null || stackBox is! RenderBox || !stackBox.attached) return null;
    Element? found;
    void visit(Element e) {
      if (found != null) return;
      if (e.widget.key == key) {
        found = e;
        return;
      }
      e.visitChildren(visit);
    }

    stack.visitChildElements(visit);
    final box = found?.renderObject;
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero, ancestor: stackBox) & box.size;
  }

  Rect? _firstRectOfKeys(List<Key> keys) {
    for (final k in keys) {
      final r = _rectOfKey(k);
      if (r != null) return r;
    }
    return null;
  }

  Rect? _unionOfKeys(List<Key> keys) {
    Rect? out;
    for (final k in keys) {
      final r = _rectOfKey(k);
      if (r != null) out = out == null ? r : out.expandToInclude(r);
    }
    return out;
  }

  /// Also true in the frame between a step and the board starting to play it.
  bool get _isBusy => _busy || (_boardKey.currentState?.game.busy.value ?? false);

  BattleCubit get _cubit => context.read<BattleCubit>();

  void _endPhase() {
    if (!_isBusy) _cubit.endPhase();
  }

  /// Gives an order, after a battle preview if the order would cause a battle.
  Future<void> _setOrder(String officerId, Order order) async {
    if (_isBusy) return;
    final cubit = _cubit;
    final previews = battlePreviewsFor(cubit.engine, cubit.game, officerId, order);
    if (previews.isNotEmpty) {
      final ok = await showBattlePreviewDialog(context, previews: previews, state: cubit.game, ruleset: widget.ruleset);
      if (!ok || !mounted) return;
    }
    cubit.setOrder(officerId, order);
  }

  Future<void> _openCard(CardDef card) {
    final cubit = _cubit;
    return showCardDialog(
      context,
      card: card,
      state: cubit.game,
      ruleset: widget.ruleset,
      legal: cubit.legalActions,
      enabled: !_isBusy,
      onPlay: (target) {
        if (!_isBusy) cubit.playCard(card.id, target: target);
      },
    );
  }

  /// The hand, the log and the inspector are popups on a phone, and only one
  /// shows at a time: opening one closes the others.
  void _toggleHand() {
    final open = !_handOpen;
    setState(() {
      _handOpen = open;
      if (open) _logOpen = false;
    });
    if (open) _select(null);
  }

  void _toggleLog() {
    final open = !_logOpen;
    setState(() {
      _logOpen = open;
      if (open) _handOpen = false;
    });
    if (open) _select(null);
  }

  void _select(Selection? s) => _boardKey.currentState?.select(s);

  /// A strategy the player just played gets its cutscene (not for reduced
  /// motion, and not for the cards the mission plays by itself).
  void _maybeCutscene(BattleViewState view) {
    if (view.step == _cutsceneStep || MediaQuery.disableAnimationsOf(context)) return;
    for (final e in view.lastEvents) {
      if (e is CardPlayed && !e.scripted) {
        final card = widget.ruleset.cards[e.cardId];
        if (card == null) return;
        _cutsceneStep = view.step;
        setState(() => _cutscene = card);
        return;
      }
    }
  }

  Future<void> _openObjectives() =>
      showObjectives(context, ruleset: widget.ruleset, state: _cubit.game);

  Future<void> _openMenu() async {
    final choice = await showBattleMenu(context);
    if (!mounted) return;
    if (choice == BattleMenuChoice.leave) {
      widget.onExit?.call();
    } else if (choice == BattleMenuChoice.objectives) {
      await _openObjectives();
    }
  }

  /// A battle key (build-spec section 6). Returns whether it was used.
  /// Nothing happens under the Result screen or a pending choice, which have
  /// their own buttons.
  bool _onCommand(BattleCommand command) {
    final game = _cubit.game;
    if (game.isOver || game.pendingChoice != null) return false;
    switch (command) {
      case EndPhaseCommand():
        _endPhase();
        return true;
      case EscapeCommand():
        // Closes what is open, the most temporary first; with nothing open it
        // opens the menu.
        if (_handOpen) {
          setState(() => _handOpen = false);
        } else if (_logOpen) {
          setState(() => _logOpen = false);
        } else if (_selection != null) {
          _select(null);
        } else {
          _openMenu();
        }
        return true;
      case PickCardCommand(:final index):
        final cards = handCards(game, widget.ruleset);
        if (index >= cards.length) return false;
        _openCard(cards[index]);
        return true;
      case CycleOfficerCommand(:final step):
        final ids = [
          for (final id in (game.officers.keys.toList()..sort()))
            if (game.officers[id]!.status == OfficerStatus.active) id,
        ];
        final next = cycleOfficer(ids, _selection?.kind == SelectionKind.officer ? _selection!.id : null, step);
        if (next == null) return false;
        _select(Selection(SelectionKind.officer, next));
        return true;
    }
  }

  /// A right click cancels the current selection.
  void _onPointerDown(PointerDownEvent e) {
    if (e.kind == PointerDeviceKind.mouse && e.buttons == kSecondaryMouseButton && _selection != null) {
      final game = _cubit.game;
      if (!game.isOver && game.pendingChoice == null) _select(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BattleKeyboard(
      onCommand: _onCommand,
      child: Listener(onPointerDown: _onPointerDown, child: _scaffold(context, l)),
    );
  }

  Widget _scaffold(BuildContext context, AppLocalizations l) {
    return Scaffold(
      backgroundColor: LongKyColors.lacquer,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mode = BattleLayoutMode.forWidth(constraints.maxWidth);
          // On a phone the strip, the hand and the phase button have no room
          // to grow: past 120% their labels are cut off and collide.
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mode.isCompact ? mq.textScaler.clamp(maxScaleFactor: compactMaxTextScale) : mq.textScaler,
            ),
            child: SafeArea(
            child: BlocListener<BattleCubit, BattleViewState>(
              // A player who goes on without reading the rest has seen enough.
              listener: (context, view) {
                _maybeCutscene(view);
                if (_tutorialOn && _flowFinished(view.state)) _reportTutorialDone();
              },
              child: BlocBuilder<BattleCubit, BattleViewState>(
                builder: (context, view) => Stack(
                  key: _stackKey,
                  children: [
                    Positioned.fill(child: mode.isCompact ? _compact(context, l, view) : _regular(context, l, view)),
                    if (view.state.isOver && !_busy && !_showResult)
                      Positioned(
                        left: 12,
                        right: 12,
                        top: BattleTopBar.heightFor(mode) + 8,
                        child: _reviewBanner(view.state, l),
                      ),
                    if (view.state.isOver && !_busy && _showResult)
                      Positioned.fill(
                        child: ResultScreen(
                          onReview: () => setState(() => _showResult = false),
                          onContinue: _continueFreePlay,
                          state: view.state,
                          ruleset: widget.ruleset,
                          onBack: widget.onExit,
                          onRetry: widget.onRetry,
                          nextTitle: widget.nextTitle,
                          newlyUnlocked: widget.newlyUnlocked,
                          onNext: widget.onNext,
                        ),
                      ),
                    if (view.state.pendingChoice != null && !_busy)
                      Positioned.fill(
                        child: ChoiceOverlay(
                          choice: view.state.pendingChoice!,
                          ruleset: widget.ruleset,
                          onChoose: _cubit.resolveChoice,
                        ),
                      ),
                    if (_cutscene != null)
                      Positioned.fill(
                        child: StrategyCutscene(
                          key: ValueKey(_cutsceneStep),
                          card: _cutscene!,
                          onDone: () => setState(() => _cutscene = null),
                        ),
                      ),
                    ..._coach(view, mode),
                  ],
                ),
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  /// After the last step the board stays, so the player can look at who is
  /// where; the Result screen opens when they ask for it.
  Widget _reviewBanner(GameState state, AppLocalizations l) {
    // After free play the banner tells how free play ended; the mission's own
    // result is on the Result screen.
    final won = state.freePlay ? state.freePlayOutcome == Outcome.won : state.outcome == Outcome.won;
    final accent = won ? LongKyColors.goldLeaf : const Color(0xFFE88A80);
    final title = state.freePlay ? (won ? l.freePlayWon : l.freePlayLost) : (won ? l.outcomeWon : l.outcomeLost);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Container(
          key: const Key('review-banner'),
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(
            color: LongKyColors.lacquer.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      key: const Key('review-title'),
                      style: TextStyle(color: accent, fontSize: state.freePlay ? 16 : 20, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      state.freePlay ? l.reviewHint : '${l.reviewHint} ${l.freePlayHint}',
                      style: const TextStyle(color: LongKyColors.ivory, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  if (!state.freePlay)
                    OutlinedButton(
                      key: const Key('review-continue'),
                      onPressed: _continueFreePlay,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, minTouch)),
                      child: Text(l.freePlayContinue),
                    ),
                  FilledButton(
                    key: const Key('review-result'),
                    onPressed: () => setState(() => _showResult = true),
                    style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                    child: Text(l.reviewResult),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Goes on playing after the mission ended, until one side has no troops.
  void _continueFreePlay() {
    setState(() => _showResult = false);
    _cubit.continueFreePlay();
  }

  Widget _board(BattleViewState view, AppLocalizations l) => BoardHover(
    sceneOf: () => _boardKey.currentState?.game.scene,
    describe: (s) => _hoverText(l, view.state, s),
    child: BattleBoard(
      key: _boardKey,
      ruleset: widget.ruleset,
      state: view.state,
      languageCode: l.localeName,
      onSelectionChanged: (s) => setState(() {
        _selection = s;
        // One popup at a time: picking something to inspect closes the hand and the log.
        if (s != null) {
          _handOpen = false;
          _logOpen = false;
        }
      }),
      events: view.lastEvents,
      step: view.step,
      onBusyChanged: (busy) => setState(() => _busy = busy),
      // The inspector follows the selection, which moves when the map does.
      onViewChanged: () {
        // The guided tutorial also watches the zoom.
        if ((_selection != null || _guided != null) && mounted) setState(() {});
      },
    ),
  );

  /// What the pointer rests on, in a few words.
  String? _hoverText(AppLocalizations l, GameState state, Selection s) {
    final namer = Namer(l, widget.ruleset);
    switch (s.kind) {
      case SelectionKind.node:
        final def = widget.ruleset.map.nodes.firstWhere((n) => n.id == s.id);
        return '${l.content(def.name)} · ${l.terrainName(def.terrain)}';
      case SelectionKind.officer:
        final o = state.officers[s.id];
        return o == null ? null : '${namer.officer(s.id)} · ${l.troopsFull(o.troops)}';
      case SelectionKind.army:
        final a = state.armies[s.id];
        return a == null ? null : '${namer.army(state, s.id)} · ${l.troopsFull(a.troops)}';
    }
  }

  Widget _topBar(BattleViewState view, BattleLayoutMode mode, {Widget? trailing}) => KeyedSubtree(
    key: _topBarKey,
    child: BattleTopBar(
      state: view.state,
      seasonTurns: widget.ruleset.mission.seasonTurns,
      mode: mode,
      leading: widget.onExit == null
          ? null
          : IconButton(
              key: const Key('battle-exit'),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              constraints: const BoxConstraints(minWidth: minTouch, minHeight: minTouch),
              onPressed: widget.onExit,
              icon: const Icon(Icons.arrow_back, color: LongKyColors.goldLeaf),
            ),
      trailing: trailing,
    ),
  );

  Widget _strip(BattleViewState view, BattleLayoutMode mode) => KeyedSubtree(
    key: _stripKey,
    child: OfficerStrip(
      state: view.state,
      ruleset: widget.ruleset,
      mode: mode,
      selection: _selection,
      onSelect: _select,
    ),
  );

  Widget _inspector(BattleViewState view, BattleLayoutMode mode) => InspectorPanel(
    selection: _selection!,
    state: view.state,
    ruleset: widget.ruleset,
    mode: mode,
    onClose: () => _select(null),
    actions: _selection!.kind == SelectionKind.officer
        ? OfficerActions(
            officerId: _selection!.id,
            state: view.state,
            ruleset: widget.ruleset,
            legal: _cubit.legalActions,
            enabled: !_busy,
            onSetOrder: (o) => _setOrder(_selection!.id, o),
            onClearOrder: () => _cubit.clearOrder(_selection!.id),
            onUseSkill: (t) {
              if (!_isBusy) _cubit.useSkill(_selection!.id, target: t);
            },
          )
        : null,
  );

  // ---- coach marks (T-22)

  /// The coach mark for this moment of the game, if there is one. It waits
  /// while the board animates and while a choice or the Result screen cover
  /// the game.
  List<Widget> _coach(BattleViewState view, BattleLayoutMode mode) {
    if (!_tutorialOn || _busy || view.state.pendingChoice != null || view.state.isOver) return const [];
    if (_guided != null) return _guidedCoach(view, mode);
    final id = _flow.current(view.state, _readTips);
    if (id == null) return const [];
    final step = widget.tutorial.firstWhere((t) => t.id == id);
    final l = AppLocalizations.of(context);
    final target = _spotlight(step.highlight, mode);
    if (target == null && step.highlight != null && _measuredFor != id) {
      // The element it points at is not laid out yet (the tip came with the
      // first frame): measure again once it is.
      _measuredFor = id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
    return [
      Positioned.fill(
        child: TutorialCoach(
          key: ValueKey(id),
          text: l.content(step.text),
          position: _flow.position(id),
          total: widget.tutorial.length,
          target: target,
          onNext: () => _readTip(id),
          onSkip: () {
            setState(() => _readTips.addAll(_flow.steps));
            _reportTutorialDone();
          },
        ),
      ),
    ];
  }

  /// The guided coach mark: the step the player is on, moved along first by
  /// whatever they have already done.
  List<Widget> _guidedCoach(BattleViewState view, BattleLayoutMode mode) {
    final guided = _guided!;
    if (guided.update(_tutorialContext(mode)) && guided.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reportTutorialDone();
      });
    }
    final step = guided.current;
    if (step == null) return const [];
    final l = AppLocalizations.of(context);
    // Finding a highlighted widget walks the element tree, which cannot be
    // done while building: measure after the frame and keep the last result
    // (a moved element is measured again by the next frame).
    final target = _guidedTargetFor == step.id ? _guidedTarget : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final measured = _spotlight(step.highlight, mode);
      if (_guidedTargetFor != step.id || measured != _guidedTarget) {
        setState(() {
          _guidedTargetFor = step.id;
          _guidedTarget = measured;
        });
      }
    });
    return [
      Positioned.fill(
        child: TutorialCoach(
          key: ValueKey(step.id),
          text: l.content(step.text),
          position: guided.position,
          total: widget.tutorial.length,
          target: target,
          waitingForAction: guided.waitingForAction,
          onNext: _guidedAdvance,
          onSkipStep: _guidedAdvance,
          onSkip: () {
            setState(guided.finish);
            _reportTutorialDone();
          },
        ),
      ),
    ];
  }

  // ---- compact (< 900 wide)

  Widget _compact(BuildContext context, AppLocalizations l, BattleViewState view) {
    const mode = BattleLayoutMode.compact;
    final top = BattleTopBar.heightFor(mode);
    final bottom = OfficerStrip.heightFor(mode);
    final lines = logLines(l, widget.ruleset, view.state, view.events);
    return LayoutBuilder(
      builder: (context, c) {
        final free = c.maxHeight - top - bottom;
        return Stack(
          children: [
            Positioned.fill(top: top, bottom: bottom, child: _board(view, l)),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _topBar(
                view,
                mode,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (view.state.freePlay && !view.state.isOver) const _FreePlayTag(),
                    ObjectivesButton(onPressed: _openObjectives),
                    LogButton(onPressed: _toggleLog),
                  ],
                ),
              ),
            ),
            // Bottom row: officers, hand handle, phase button.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottom,
              child: ColoredBox(
                color: LongKyColors.lacquer,
                child: Row(
                  children: [
                    Expanded(child: _strip(view, mode)),
                    KeyedSubtree(
                      key: _handKey,
                      child: HandDrawer(
                        state: view.state,
                        ruleset: widget.ruleset,
                        open: _handOpen,
                        onToggle: _toggleHand,
                      ),
                    ),
                    const SizedBox(width: 4),
                    KeyedSubtree(
                      key: _phaseKey,
                      child: PhaseButton(state: view.state, mode: mode, busy: _busy, onPressed: _endPhase),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            if (_handOpen)
              Positioned(
                left: 8,
                right: 8,
                bottom: bottom + 4,
                child: Center(
                  child: HandFan(
                    state: view.state,
                    ruleset: widget.ruleset,
                    availableWidth: c.maxWidth - 16,
                    onCardTap: _openCard,
                  ),
                ),
              ),
            if (_selection != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: bottom,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 560, maxHeight: free * 0.85),
                    child: _inspector(view, mode),
                  ),
                ),
              ),
            if (_logOpen)
              Positioned(
                top: top,
                right: 4,
                width: 320,
                height: free,
                child: LogPopover(lines: lines, onClose: () => setState(() => _logOpen = false)),
              ),
          ],
        );
      },
    );
  }

  // ---- regular (>= 900 wide)

  Widget _regular(BuildContext context, AppLocalizations l, BattleViewState view) {
    const mode = BattleLayoutMode.regular;
    final top = BattleTopBar.heightFor(mode);
    final bottom = OfficerStrip.heightFor(mode);
    final left = _logExpanded ? LogSidePanel.expandedWidth : LogSidePanel.collapsedWidth;
    const right = HandColumn.width;
    final lines = logLines(l, widget.ruleset, view.state, view.events);
    return LayoutBuilder(
      builder: (context, c) {
        final boardRect = Rect.fromLTRB(left, top, c.maxWidth - right, c.maxHeight - bottom);
        return Stack(
          children: [
            Positioned.fromRect(rect: boardRect, child: _board(view, l)),
            Positioned(left: 0, right: 0, top: 0, child: _topBar(view, mode, trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (view.state.freePlay && !view.state.isOver) const _FreePlayTag(),
                ObjectivesButton(onPressed: _openObjectives),
              ],
            ))),
            Positioned(
              left: 0,
              top: top,
              bottom: 0,
              child: LogSidePanel(
                lines: lines,
                expanded: _logExpanded,
                onToggle: () => setState(() => _logExpanded = !_logExpanded),
              ),
            ),
            Positioned(
              left: left,
              right: right,
              bottom: 0,
              height: bottom,
              child: ColoredBox(color: LongKyColors.lacquer, child: _strip(view, mode)),
            ),
            Positioned(
              right: 0,
              top: top,
              bottom: 0,
              width: right,
              child: Column(
                children: [
                  Expanded(
                    child: KeyedSubtree(
                      key: _handKey,
                      child: HandColumn(state: view.state, ruleset: widget.ruleset, onCardTap: _openCard),
                    ),
                  ),
                  ColoredBox(
                    color: LongKyColors.lacquer,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: double.infinity,
                        child: KeyedSubtree(
                          key: _phaseKey,
                          child: PhaseButton(state: view.state, mode: mode, busy: _busy, onPressed: _endPhase),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_selection != null)
              Positioned.fill(
                child: CustomSingleChildLayout(
                  delegate: _FloatingInspectorDelegate(
                    anchor: _anchorFor(view.state, boardRect),
                    gap: _inspectorGap(boardRect.size),
                    bounds: boardRect,
                  ),
                  child: _inspector(view, mode),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Clear space between the selected node and the panel: the node, the token
  /// fan beside it and a margin.
  double _inspectorGap(Size boardSize) {
    final layout = _boardKey.currentState?.game.scene?.layout ?? BoardLayout(widget.ruleset.map, boardSize);
    return layout.nodeRadius + layout.tokenRadius * 2.5 + 16;
  }

  /// Where the selection is on screen: its node's centre (tokens fan out
  /// from there), in the screen's coordinates.
  Offset _anchorFor(GameState state, Rect boardRect) {
    final s = _selection!;
    final nodeId = switch (s.kind) {
      SelectionKind.node => s.id,
      SelectionKind.officer => state.officers[s.id]?.nodeId,
      SelectionKind.army => state.armies[s.id]?.nodeId,
    };
    final layout = _boardKey.currentState?.game.scene?.layout ?? BoardLayout(widget.ruleset.map, boardRect.size);
    final local = nodeId == null ? boardRect.size.center(Offset.zero) : layout.nodeCenter(nodeId);
    return boardRect.topLeft + local;
  }
}

/// Puts the regular-layout inspector beside the selection: to its right if
/// it fits inside the board area, otherwise to its left, and always inside
/// the board area.
class _FloatingInspectorDelegate extends SingleChildLayoutDelegate {
  _FloatingInspectorDelegate({required this.anchor, required this.gap, required this.bounds});

  final Offset anchor;
  final double gap;
  final Rect bounds;

  static const double margin = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(maxWidth: InspectorPanel.floatingWidth, maxHeight: bounds.height - 2 * margin);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var x = anchor.dx + gap;
    if (x + childSize.width > bounds.right - margin) x = anchor.dx - gap - childSize.width;
    x = x.clamp(bounds.left + margin, bounds.right - margin - childSize.width);
    final y = (anchor.dy - childSize.height / 2).clamp(bounds.top + margin, bounds.bottom - margin - childSize.height);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_FloatingInspectorDelegate old) => old.anchor != anchor || old.gap != gap || old.bounds != bounds;
}


/// "Free play" in the top bar: the mission has ended and the player plays on.
class _FreePlayTag extends StatelessWidget {
  const _FreePlayTag();

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('free-play-tag'),
    margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: LongKyColors.goldLeaf),
    ),
    child: Text(
      AppLocalizations.of(context).freePlayTag,
      style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );
}
