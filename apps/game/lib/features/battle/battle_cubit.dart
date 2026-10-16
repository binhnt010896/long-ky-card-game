import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_rules/lk_rules.dart';

/// What the battle screen shows: the game state and the events so far.
final class BattleViewState {
  const BattleViewState({required this.state, this.events = const [], this.lastEvents = const [], this.step = 0});

  final GameState state;

  /// Every event since the mission started, oldest first.
  final List<GameEvent> events;

  /// The events of the latest step, for the board to animate in order.
  final List<GameEvent> lastEvents;

  /// Counts steps, so the board plays [lastEvents] once per step.
  final int step;
}

/// Holds the [GameState] of the battle and sends actions to the engine
/// (build-spec section 6). Autosave comes with T-18.
class BattleCubit extends Cubit<BattleViewState> {
  BattleCubit(this.engine, {required int seed}) : super(_start(engine, seed));

  final GameEngine engine;

  static BattleViewState _start(GameEngine engine, int seed) {
    final r = engine.newGame(seed);
    return BattleViewState(state: r.state, events: r.events);
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
    emit(
      BattleViewState(
        state: r.state,
        events: [...state.events, ...r.events],
        lastEvents: r.events,
        step: state.step + 1,
      ),
    );
    return true;
  }
}
