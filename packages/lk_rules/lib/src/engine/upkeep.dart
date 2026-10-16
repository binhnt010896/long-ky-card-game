import 'events.dart';
import 'tx.dart';

/// Upkeep, in the order of build-spec section 4 (T-07 adds steps 1–6).
void runUpkeep(Tx tx) {
  drawToHandSize(tx);
}

/// Step 7: draw up to `handSize`; an empty deck reshuffles the discard.
void drawToHandSize(Tx tx) {
  final drawn = <String>[];
  while (tx.s.hand.length < tx.mission.handSize) {
    if (tx.s.deck.isEmpty) {
      if (tx.s.discard.isEmpty) break;
      final reshuffled = tx.withRng((rng) => rng.shuffled(tx.s.discard));
      tx.s = tx.s.copyWith(deck: reshuffled, discard: const []);
      tx.emit(DeckShuffled(reshuffled.length));
    }
    final card = tx.s.deck.first;
    tx.s = tx.s.copyWith(deck: tx.s.deck.sublist(1), hand: [...tx.s.hand, card]);
    drawn.add(card);
  }
  if (drawn.isNotEmpty) tx.emit(CardsDrawn(drawn));
}
