# Content review export (T-26)

`content-text.csv` lists every Vietnamese and English text of the game content
(cards, officers, the Yuan commander, map places, missions with their briefing,
debrief and tutorial steps) with:

- `contentId`: the item it belongs to (`tran-thai-tong/kingPresence` is the skill of an officer),
- `sourceRefs` and `sources`: the citations of that item (ids from `sources.json`, and the work they name),
- `todo`: the open notes of the item, e.g. "en text drafted from vi, needs review".

Content hash when exported: `63ff31bdbb7c2155`. Regenerate after any content change:

```bash
dart run packages/lk_content/bin/export_text.dart --out docs/review/content-text.csv
```

The file is UTF-8 with a byte-order mark so that Excel opens the Vietnamese text correctly.
Map places have no `sourceRefs` yet (the `maps/ch1.json` rows): the reviewer should name
a source for each, or confirm the names are game labels.
