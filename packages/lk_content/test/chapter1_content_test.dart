import 'dart:io';

import 'package:lk_content/io.dart';
import 'package:lk_content/lk_content.dart';
import 'package:lk_rules/lk_rules.dart';
import 'package:test/test.dart';

void main() {
  final dir = findContentDir();

  test('the real content validates (art and audio may still be missing)', () {
    expect(dir, isNotNull);
    final result = validateContent(readContentDir(dir!), assetPaths: listAssetPaths(dir.parent));
    expect(result.errors, isEmpty, reason: result.errors.join('\n'));
    expect(result.warnings.every((w) => w.code == 'missingAsset'), isTrue, reason: result.warnings.join('\n'));
  });

  test('Chapter 1 has the five missions in order, each playable by the engine', () {
    final bundle = loadContent(readContentDir(dir!));
    expect(bundle.missions.keys, ['ch1_m1', 'ch1_m2', 'ch1_m3', 'ch1_m4', 'ch1_m5']);
    expect(bundle.officers.keys.toSet(), {
      'tran-thai-tong',
      'tran-thu-do',
      'le-phu-tran',
      'tran-quoc-tuan',
      'tran-khanh-du',
      'tran-nhat-hieu',
    });
    for (final id in bundle.missions.keys) {
      final engine = GameEngine(bundle.ruleset(id));
      final s = engine.newGame(1).state;
      expect(s.phase, Phase.council, reason: id);
      expect(engine.legalActions(s), isNotEmpty, reason: id);
    }
  });

  test('numbers match build-spec section 5 as tuned in T-25', () {
    final b = loadContent(readContentDir(dir!));
    final m2 = b.missions['ch1_m2']!;
    expect((m2.seasonTurns, m2.heatStartTurn, m2.start.rice, m2.start.support), (4, null, 4, 3));
    final m5 = b.missions['ch1_m5']!;
    final army = m5.yuanArmies.single;
    // Build-spec section 5 has 24 troops, morale 5 and heat from turn 1; T-25
    // tuned the last two and the troops (docs/balance/t25-report.md).
    expect((army.troops, army.supply, army.maxSupply, army.morale, army.retreatNodeId), (30, 6, 20, 9, 'bien-gioi'));
    expect(m5.heatStartTurn, 6);
    expect(m5.deck.map((d) => (d.cardId, d.count)), [
      ('vuon-khong-nha-trong', 3),
      ('lui-binh-bao-toan', 2),
      ('phuc-kich-ben-song', 2),
      ('phan-cong', 3),
    ]);
    final tuan = b.officers['tran-quoc-tuan']!;
    expect(tuan.longKyPersonId, 'tran-hung-dao');
    expect(tuan.troopCap, 6);
    final graph = MapGraph(b.maps['ch1']!);
    expect(graph.nodeIds, hasLength(9));
    expect(graph.edges, hasLength(12));
    expect(graph.capitalId, 'thang-long');
  });

  test('every content file in the repo is covered by the validator', () {
    final files = readContentDir(dir!).keys.where((f) => f.endsWith('.json')).toSet();
    expect(files, containsAll(requiredFiles));
    expect(File('${dir.path}/maps/ch1.json').existsSync(), isTrue);
  });
}
