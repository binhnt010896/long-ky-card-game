import '../balance.dart';
import '../model/enums.dart';
import 'events.dart';
import 'tx.dart';

/// Upkeep step 6: for each inducement this turn, the active, non-locked
/// officer with the lowest loyalty (ties by id) defects if
/// `loyalty + floor(clan / 2) < threshold` (threshold +2 while Clan < 4).
/// A defector's troops are removed and Clan drops by 1.
void checkInducements(Tx tx) {
  for (final inducement in tx.mission.inducements) {
    if (inducement.turn != tx.s.turn) continue;
    final candidates = [
      for (final id in tx.activeOfficerIds())
        if (!tx.officerDef(id).loyaltyLocked) id,
    ]..sort((a, b) {
        final byLoyalty = tx.officer(a).loyalty.compareTo(tx.officer(b).loyalty);
        return byLoyalty != 0 ? byLoyalty : a.compareTo(b);
      });
    if (candidates.isEmpty) continue;
    final id = candidates.first;
    final clan = tx.s.unity.clan;
    final threshold =
        inducement.threshold + (clan < Balance.unityLowThreshold ? Balance.lowClanDefectionBonus : 0);
    if (tx.officer(id).loyalty + clan ~/ 2 >= threshold) {
      tx.emit(InducementResisted(id));
      continue;
    }
    tx.updateOfficer(id, (o) => o.copyWith(status: OfficerStatus.defected, troops: 0, order: null));
    tx.updateStats((m) => m.copyWith(defections: m.defections + 1));
    tx.emit(OfficerDefected(id));
    tx.modUnity(Pillar.clan, -Balance.defectionClanLoss);
  }
}
