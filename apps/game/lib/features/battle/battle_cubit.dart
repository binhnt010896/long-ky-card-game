import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_rules/lk_rules.dart';

/// What the battle screen shows: the game state and the events so far.
final class BattleViewState {
  const BattleViewState({
    required this.state,
    this.events = const [],
    this.lastEvents = const [],
    this.step = 0,
    this.previous,
  });

  final GameState state;

  /// The state before the latest step, so that what the step did can be
  /// judged by what was set up (for example the orders of a resolved turn).
  final GameState? previous;

  /// Every event since the mission started, oldest first.
  final List<GameEvent> events;

  /// The events of the latest step, for the board to animate in order.
  final List<GameEvent> lastEvents;

  /// Counts steps, so the board plays [lastEvents] once per step.
  final int step;
}

/// A saved battle that cannot be replayed (the engine refuses an action).
final class SaveReplayException implements Exception {
  const SaveReplayException(this.message);

  final String message;

  @override
  String toString() => 'SaveReplayException: $message';
}

/// Holds the [GameState] of the battle and sends actions to the engine
/// (build-spec section 6). [onChanged] runs after every step: that is where
/// the battle is autosaved.
class BattleCubit extends Cubit<BattleViewState> {
  BattleCubit(this.engine, {required int seed, this.onChanged}) : super(_start(engine, seed));

  /// Picks up a saved battle: replays [actions] from the mission start with
  /// [seed], giving the same state, and the same log, as when it was saved.
  /// Nothing is animated. Throws [SaveReplayException] if an action is no
  /// longer legal.
  BattleCubit.resume(this.engine, {required int seed, required List<GameAction> actions, this.onChanged})
    : super(_replay(engine, seed, actions));

  final GameEngine engine;

  /// Called after each step with the new state.
  final void Function(BattleViewState view)? onChanged;

  static BattleViewState _start(GameEngine engine, int seed) {
    final r = engine.newGame(seed);
    return BattleViewState(state: r.state, events: r.events);
  }

  static BattleViewState _replay(GameEngine engine, int seed, List<GameAction> actions) {
    final first = engine.newGame(seed);
    var state = first.state;
    final events = [...first.events];
    for (final a in actions) {
      try {
        final r = engine.apply(state, a);
        state = r.state;
        events.addAll(r.events);
      } on IllegalAction catch (e) {
        throw SaveReplayException('$a: $e');
      }
    }
    return BattleViewState(state: state, events: events);
  }

  GameState get game => state.state;

  GameState? _legalFor;
  List<GameAction> _legal = const [];

  /// Every legal action now, cached per state.
  List<GameAction> get legalActions {
    if (!identical(_legalFor, game)) {
      _legal = engine.legalActions(game);
      _legalFor = game;
    }
    return _legal;
  }

  /// Ends the current phase (Council → Orders, Orders → next turn).
  bool endPhase() => perform(const GameAction.endPhase());

  bool playCard(String cardId, {String? target}) => perform(GameAction.playCard(cardId: cardId, target: target));

  bool useSkill(String officerId, {String? target}) =>
      perform(GameAction.useSkill(officerId: officerId, target: target));

  bool resolveChoice(int index) => perform(GameAction.resolveChoice(index: index));

  /// After the mission has ended: keep playing until one side has no troops.
  bool continueFreePlay() => perform(const GameAction.continueFreePlay());

  /// Orders can be changed freely until the phase ends.
  bool setOrder(String officerId, Order order) => perform(GameAction.setOrder(officerId: officerId, order: order));

  bool clearOrder(String officerId) => perform(GameAction.clearOrder(officerId: officerId));

  /// Applies [action]; false (and no change) when it is not legal.
  bool perform(GameAction action) {
    final StepResult r;
    try {
      r = engine.apply(game, action);
    } on IllegalAction {
      return false;
    }
    final next = BattleViewState(
      state: r.state,
      events: [...state.events, ...r.events],
      lastEvents: r.events,
      step: state.step + 1,
      previous: game,
    );
    emit(next);
    onChanged?.call(next);
    return true;
  }
}
