import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_rules/lk_rules.dart';

/// What the battle screen shows: the game state and the events so far.
final class BattleViewState {
  const BattleViewState({required this.state, this.events = const []});

  final GameState state;

  /// Every event since the mission started, oldest first.
  final List<GameEvent> events;
}

/// Holds the [GameState] of the battle and sends actions to the engine
/// (build-spec section 6). T-16 only wires the phase button; card plays,
/// orders and choices come with T-17, autosave with T-18.
class BattleCubit extends Cubit<BattleViewState> {
  BattleCubit(this.engine, {required int seed}) : super(_start(engine, seed));

  final GameEngine engine;

  static BattleViewState _start(GameEngine engine, int seed) {
    final r = engine.newGame(seed);
    return BattleViewState(state: r.state, events: r.events);
  }

  /// Ends the current phase (Council → Orders, Orders → next turn).
  /// Does nothing when that is not legal, for example while a choice is pending.
  void endPhase() => _apply(const GameAction.endPhase());

  void _apply(GameAction action) {
    final StepResult r;
    try {
      r = engine.apply(state.state, action);
    } on IllegalAction {
      return;
    }
    emit(BattleViewState(state: r.state, events: [...state.events, ...r.events]));
  }
}
