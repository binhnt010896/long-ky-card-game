# Long Ký - The Game — Plan

2026-10-16 · Nguyen Thanh Binh

> Exported from the Claude Doc "Long Ký - The Game — Plan". The doc is the living version; re-export this file after changing it.

## Overview

Long Ký - The Game is the first game in the Long Ký universe: a single-player, offline, turn-based card strategy game for Android, iOS, macOS and Windows, with no web build. You defend Đại Việt through the three Mongol–Yuan invasions (1258, 1285, 1287–88). Version 1 ships Chapter 1 (1258) only.

Instructions for the coding agent: [docs/build-spec.md](build-spec.md)

**The Long Ký universe.** The people and events are real; the art is ours. The game uses the same person and event IDs as the Long Ký app's data (`people.json`, `events.json`), so a card and an app lesson always point to the same person. Run a trademark search on "Long Ký" and "Long Ký - The Game" before launch.

**Design pillars**

1.  **Trade land for time.** You win by retreating, emptying the land and starving the invader, not by conquest. The Trần accepted withdrawal when the enemy was strong ([Luật Minh Khuê](https://luatminhkhue.vn/nguyen-nhan-va-y-nghia-cua-ba-lan-khang-chien-chong-quan-mong.aspx)) and used scorched earth in all three wars ([VietJack](https://vietjack.com/sbt-lich-su-7-kn/giai-sbt-lich-su-7-trang-48-ket-noi.jsp)).

2.  **Officers are the cards.** Every officer card is a real person whose skill comes from what they did.

3.  **Unity is the real health bar.** Three pillars: court, clan, people, mirroring the period's own account of why it won ([PLO](https://plo.vn/hoi-nghi-dien-hong-va-bai-hoc-doan-ket-dong-thuan-post775608.html)).

4.  **History you can check.** Every card and event carries a source field and links to its Long Ký lesson.

| Item           | Version 1                                                                                                                  |
|----------------|----------------------------------------------------------------------------------------------------------------------------|
| Platforms      | Android, iOS, macOS, Windows. No web, no Linux                                                                             |
| Orientation    | Landscape on every platform, minimum 1280×720 window on desktop                                                            |
| Input          | Touch on mobile; mouse and keyboard on desktop                                                                             |
| Network        | Fully offline, no accounts, no server                                                                                      |
| Genre          | Turn-based strategy with light deckbuilding                                                                                |
| Session length | 10–20 min per mission (target)                                                                                             |
| Audience       | Long Ký users and Vietnamese history learners first; strategy players abroad second                                        |
| Languages      | Vietnamese and English                                                                                                     |
| Content        | Chapter 1 (1258): 5 missions, 6 officers, about 10 map nodes                                                               |
| Age rating     | Self-classified under Decree 147, Art. 38 ([LSVN](https://lsvn.vn/phan-loai-game-theo-do-tuoi-tu-25-12-2024-a150127.html)) |
| Business model | Open decision (see Risks)                                                                                                  |

## Core loop and turn structure

Each mission is a race: survive and keep Unity standing until the Yuan army's supply and morale collapse, then counterattack. One turn is about a week of campaign time.

**Turn phases**

1.  **Intel.** Every enemy army shows its intent for the turn (move, forage, assault) on the map, so you plan against known threats.

2.  **Council.** Play Stratagem and Event cards from your hand, paid for with Rice (Lương) and Popular Support (Lòng dân).

3.  **Orders.** Assign each officer card to a map node with one order: Hold, Evacuate, Raid, Ambush or Rally.

4.  **Resolution.** Enemy moves resolve, then battles, then foraging. Foraging in an evacuated node yields nothing.

5.  **Upkeep.** The season clock advances, enemy attrition applies, Yuan inducement cards trigger loyalty checks, and you draw.

**Win and loss**

- **Win:** an enemy army's Supply or Morale reaches 0 and you hold a counterattack node, or the season clock runs out with the court intact.

- **Loss:** the king is captured, or any Unity pillar reaches 0.

- **Not a loss:** losing Thăng Long. In 1258 the Mongols took and burned the capital, and Đại Việt still won ([WarHistory](https://weaponsandwarfare.com/?p=14762)). Teaching this is the point of Chapter 1.

**Meta loop (between missions)**

- Earn stars per mission (won, Unity above a threshold, no defections).

- Spend stars to upgrade officers or unlock Stratagem cards.

- Unlock officer lore and bonus cards by finishing the matching Long Ký lesson (see Art, audio and Long Ký).

## Systems

Six systems carry the game. Each maps to something documented in the record, so mechanics teach history without text dumps.

| System                | How it works                                                                                                                                                                        | Historical basis                                                                                                                                                                                                                                                   |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| River map             | About 10 nodes joined by river and land routes. Chapter 1 follows the 1258 route: down the Thao River to Bạch Hạc, then to Bình Lệ Nguyên, where Trần Thái Tông's line stopped them | [Loigiaihay](https://loigiaihay.com/giai-bai-3-trang-47-sbt-su-7-a68523.html)                                                                                                                                                                                      |
| Yuan supply           | Each enemy army has a Supply value. Foraging an occupied node refills it unless you evacuated that node first                                                                       | Scorched earth left the Yuan foraging under attack and short of food ([Loigiaihay](https://loigiaihay.com/chien-thang-bach-dang-a13767.html))                                                                                                                      |
| Season clock          | A fixed number of turns per mission. Yuan attrition rises each turn as the hot season nears                                                                                         | Lack of supplies and the tropical climate drove the Mongols back in 1258 ([WarHistory](https://weaponsandwarfare.com/?p=14762)); by early summer 1285 the Yuan were short of food ([PubHTML5](https://pubhtml5.com/ocldv/uoyc/basic/51-100))                       |
| Unity (three pillars) | Court, Clan and People, each 0–10. Each pillar buffs a different stat; any pillar at 0 loses the mission                                                                            | King and court of one mind, clan in harmony, whole country contributing ([PLO](https://plo.vn/hoi-nghi-dien-hong-va-bai-hoc-doan-ket-dong-thuan-post775608.html))                                                                                                  |
| Loyalty and defection | Each officer has Loyalty 1–10. Yuan play inducement cards each Upkeep; an officer below the check defects with their troops                                                         | Envoys demanded surrender three times before 1258 ([VietJack](https://vietjack.com/lich-su-11-ct/lich-su-11-trang-50.jsp)); Trần Ích Tắc and Trần Kiện defected in 1285 ([Znews](https://znews.vn/ket-cuc-bi-tham-cua-nhung-ke-ban-nuoc-cau-vinh-post940631.html)) |
| Combat                | Deterministic comparison with a preview before you commit; small seeded variance only on ambushes                                                                                   | Design choice: a strategy player should lose to their plan, not to dice                                                                                                                                                                                            |

**Combat formula (draft)**

``` latex
\text{Power} = \text{Troops} \times \left(1 + \frac{\text{War}}{10}\right) \times \text{Terrain} \times \text{Morale}
```

The higher Power wins, and the loser takes losses scaled by the gap. Terrain favours Đại Việt on rivers and marshes and the Yuan on open ground. Leadership breaks ties and caps how many troops an officer can command.

**Resources**

- **Rice (Lương):** pays for Stratagems and keeps your troops fed.

- **Popular Support (Lòng dân):** pays for Evacuate orders and Events. It drops when you evacuate too often and rises with victories and the Diên Hồng event in Chapter 2.

- **Troops:** attached to officers, never pooled.

## Cards

Four card types share one frame: Officer, Stratagem, Event and Enemy Intent. Officers are permanent and placed on the map; the other three are drawn, played and discarded.

**Officer stat model (1–10 scale, borrowed from Three Kingdoms games)**

| Stat         | Name  | Effect                                                                           |
|--------------|-------|----------------------------------------------------------------------------------|
| Leadership   | Thống | Max troops commanded, tie-breaker in battle                                      |
| War          | Võ    | Battle power multiplier                                                          |
| Intelligence | Trí   | Ambush and stratagem success, sees enemy intent one turn further ahead           |
| Politics     | Chính | Rice income and Popular Support recovery at the node                             |
| Loyalty      | Trung | Resistance to Yuan inducement cards; locked at 10 for fixed historical loyalists |

Each officer also has one **signature skill** and, where the record supports it, one **flaw**.

**Chapter 1 roster (1258)**

Stats are first-pass design values to be tuned in playtests, not historical claims.

| Officer        | Thống/Võ/Trí/Chính | Signature skill                                                                                         | Flaw                                        | Historical basis                                                                                                                                                                                     |
|----------------|--------------------|---------------------------------------------------------------------------------------------------------|---------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Trần Thái Tông | 7/6/6/8            | **Ngự giá thân chinh:** +1 Morale to all units at his node                                              | Mission lost if captured                    | Led the Bình Lệ Nguyên line in person, then withdrew ([Loigiaihay](https://loigiaihay.com/bai-17-ba-lan-khang-chien-chong-quan-xam-luoc-mong-nguyen-sgk-lich-su-va-dia-li-7-canh-dieu-a107988.html)) |
| Trần Thủ Độ    | 8/5/8/9            | **"Đầu thần chưa rơi":** once per mission, restore Court to full                                        | None                                        | His reply to the king after Bình Lệ Nguyên ([VietJack](https://vietjack.com/sbt-lich-su-7-kn/giai-sbt-lich-su-7-trang-48-ket-noi.jsp))                                                               |
| Lê Phụ Trần    | 6/7/6/6            | **Ván thuyền che tên:** shields the king; the king cannot be captured while Lê Phụ Trần shares his node | None                                        | Shielded Thái Tông from arrows with a boat plank during the retreat ([Mytour](https://mytour.vn/vi/blog/bai-viet/le-phu-tran.html))                                                                  |
| Trần Quốc Tuấn | 9/8/10/7           | **Trấn biên:** border nodes reveal enemy intent two turns ahead                                         | Starts at low rank in Chapter 1 (troop cap) | Commanded the border in 1258 ([Mytour](https://mytour.vn/vi/blog/bai-viet/top-7-vi-tuong-noi-bat-trong-cuoc-chien-chong-quan-mong-nguyen.html))                                                      |
| Trần Khánh Dư  | 7/9/7/4            | **Phiêu Kỵ:** Raid orders deal double Supply damage                                                     | Chapter 2+: can be disgraced and recalled   | Made his name in the first war; titled Phiêu Kỵ đại tướng quân ([Mytour](https://mytour.vn/vi/blog/bai-viet/top-7-vi-tuong-noi-bat-trong-cuoc-chien-chong-quan-mong-nguyen.html))                    |
| Trần Nhật Hiệu | 4/3/6/6            | **Thanh dã** (was Nhập Tống, dropped: it means fleeing to Song, a cowardly act): lets you abandon a node with no Popular Support cost                                   | Playing his skill costs 1 Court Unity       | Wrote "Nhập Tống" when asked for a plan ([Znews](https://znews.vn/10-cau-noi-luu-danh-muon-doi-cua-anh-hung-nuoc-viet-post818481.html))                                                              |

**Enemy commander (Chapter 1):** Ngột Lương Hợp Thai (Uriyangkhadai), 30,000 troops ([VietJack](https://vietjack.com/lich-su-11-ct/lich-su-11-trang-50.jsp)). Enemy commanders are AI-driven cards with an intent deck, not playable.

**Stratagem cards (Chapter 1)**

- **Vườn không nhà trống:** evacuate a node; foraging there yields 0 Supply this turn.

- **Lui binh bảo toàn:** withdraw an officer with no troop loss.

- **Phục kích bến sông:** set an ambush on a river edge; triggers when an enemy crosses.

- **Phản công:** double power on one attack, only when the target's Supply is below half.

**Event cards (Chapter 1)**

- **Sứ giả phương Bắc:** a Yuan envoy demands surrender; refuse for +1 People, accept to skip a turn and lose 2 Court.

- **Nắng nóng:** heat; +1 attrition to every Yuan army this turn.

**Card design rule:** frames look like lacquer tablets or scrolls, never like playing cards (see Legal, regulatory and accuracy checklist).

## Campaign

Chapter 1 is five missions that each teach one system, ending in the Đông Bộ Đầu counterattack. Chapters 2 and 3 reuse every system and add new ones.

**Chapter 1: 1258 (version 1)**

| \#  | Mission           | Teaches                                   | Historical basis                                                                                                                                           |
|-----|-------------------|-------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1   | Sứ giả phương Bắc | Council phase, Event cards, Loyalty       | Three letters demanding passage south against the Song ([Wikipedia](https://en.wikipedia.org/wiki/Tr%E1%BA%A7n_Th%C3%A1i_T%C3%B4ng))                       |
| 2   | Bình Lệ Nguyên    | Combat, a battle you cannot win, Lui binh | The Mongols beat the line, but the king escaped by boat ([Wikipedia](https://en.wikipedia.org/wiki/Battle_of_B%C3%ACnh_L%E1%BB%87_Nguy%C3%AAn))            |
| 3   | Bỏ ngỏ Thăng Long | Evacuate orders, enemy Supply             | Court and people left Thăng Long under the scorched-earth plan ([Loigiaihay](https://loigiaihay.com/giai-bai-1-trang-19-tap-ban-do-lich-su-7-a74430.html)) |
| 4   | Đầu thần chưa rơi | Unity crisis, Trần Thủ Độ's skill         | Thủ Độ's reply to the worried king ([VietJack](https://vietjack.com/sbt-lich-su-7-kn/giai-sbt-lich-su-7-trang-48-ket-noi.jsp))                             |
| 5   | Đông Bộ Đầu       | Phản công, win condition                  | The Trần counterattack at Đông Bộ Đầu forced the Mongols out ([Loigiaihay](https://loigiaihay.com/giai-bai-1-trang-19-tap-ban-do-lich-su-7-a74430.html))   |

**Chapter 2: 1285 (expansion 1).** Adds Diên Hồng (People pillar event), defections (Trần Ích Tắc, Trần Kiện), Trần Bình Trọng's rear guard covering the court's retreat to Thiên Trường, and the river battles Tây Kết, Hàm Tử and Chương Dương ([VietJack](https://vietjack.com/sbt-lich-su-7-kn/giai-sbt-lich-su-7-trang-48-ket-noi.jsp), [Loigiaihay](https://loigiaihay.com/giai-bai-5-trang-48-sbt-su-7-a68525.html)).

**Chapter 3: 1287–88 (expansion 2).** Adds sea routes and convoys: Trần Khánh Dư's Vân Đồn raid on Trương Văn Hổ's grain fleet, then the Bạch Đằng finale as a tide puzzle: plant stakes, lure the fleet with light boats, strike as the tide falls ([VietJack](https://vietjack.com/lich-su-7-cd/lich-su-7-trang-67.jsp), [Loigiaihay](https://loigiaihay.com/giai-bai-5-trang-48-sbt-su-7-a68525.html)).

**Framing note.** English-language sources describe Bình Lệ Nguyên as a Mongol victory and note that Thái Tông later agreed to tribute every three years ([Wikipedia](https://en.wikipedia.org/wiki/Tr%E1%BA%A7n_Th%C3%A1i_T%C3%B4ng)). The game shows the lost battle honestly; the chapter's victory is the Mongol withdrawal, which matches Vietnamese textbooks.

## Art, audio and Long Ký integration

The game reuses the Việt Sử look and voice so app, shorts and game read as one brand: black lacquer ground, gold leaf, cinnabar accents, the same faces for the same people.

**Art pipeline (per officer)**

1.  Start from the person's existing Long Ký art (avatar and full body), or generate one in the series style with Higgsfield.

2.  Make a turnaround: portrait, half body, battle pose, keeping the same features.

3.  **Human paint-over** of the final card art: costume details, weapon, emblem, cleanup. This is what makes the art protectable; purely prompted output is not copyrightable in the US ([Sidley](https://datamatters.sidley.com/2025/02/07/u-s-copyright-office-issues-report-on-artificial-intelligence-and-copyrightability/)), and Vietnam also requires human authorship ([Tilleke](https://www.tilleke.com/insights/the-ip-puzzle-of-ai-generated-songs-protection-responsibility-and-the-future-of-music-law)).

4.  Keep the layered files and edit history in the repo as evidence of authorship.

**Art list for version 1**

- 6 officer cards and 1 enemy commander card (portrait plus card frame).

- About 12 Stratagem and Event illustrations.

- 1 painted map of the 1258 theatre with about 10 node markers.

- Unit tokens: infantry, boats, war elephants, Mongol cavalry.

- UI kit: lacquer card frames, Unity pillar gauges, buttons.

**Audio**

- Narration: the series voice already chosen in ElevenLabs (Tung Dang), for mission intros and lore.

- Character lines: separate ElevenLabs voices per officer, as in the shorts.

- Music: subtle royalty-free tracks, matching the shorts.

**Long Ký integration (no server)**

- Every officer, event and stratagem carries `longKyPersonId` or `longKyEventId`, using the IDs already in Long Ký's `people.json` and `events.json` (for example `tran-thai-tong`, `khang-chien-mong-co-lan-mot`).

- **Mobile:** "Read more" opens Long Ký at that person or event through a deep link, or the store page if Long Ký is not installed.

- **Desktop:** Long Ký is a mobile app, so "Read more" shows a QR code that opens the same deep link on the player's phone.

- **Unlocks:** finishing a lesson in Long Ký shows a short unlock code. The player types it into the game on any platform, or taps a deep link on mobile. The game checks it offline and unlocks that officer's lore and a bonus card.

- Codes only deter casual sharing, because any offline check can be reverse-engineered. That is acceptable for cosmetic unlocks.

- Long Ký needs two additions: a deep-link route per person and event, and an unlock-code screen after a lesson.

- Nothing talks to a server, which keeps the game in the simplest licensing category (see the legal checklist).

## Tech architecture

Build one Flutter app with Flame for Android, iOS, macOS and Windows, and keep every game rule in a pure-Dart package with no Flutter dependency. Rules are then unit-testable, and the Yuan AI can be simulated thousands of times to balance missions. The full instructions for the coding agent are in the build spec (docs/build-spec.md).

**Architecture (5 parts, no server)**

- **Content data** (officers, cards, missions, map, sourceRef as JSON) → *loads into* →
- **Rules engine** (pure Dart: state, actions, Yuan AI, seeded RNG, no Flutter) ⇄ *state / orders* ⇄
- **Presentation** (Flame: map and tokens; Flutter: cards, menus).
- Rules engine ⇄ **Local save** (on-device action log; no server, stays G4).
- Presentation ⇄ **Long Ký app** (lesson deep links; unlock codes, QR on desktop).

The UI only sends orders and draws state; content is data, so cards and missions change without touching code.

**Versions.** Flame on pub.dev was at v1.37.0 as of April 2026 ([depscope](https://depscope.dev/pkg/pub/flame)), and Flame was already adapting to Flutter 3.47 in August 2026 ([Flame PR \#3995](https://github.com/flame-engine/flame/pull/3995)). Pin both versions at project start.

**Project structure**

    long-ky-card-game/
      packages/
        lk_rules/     pure Dart: GameState, actions, reducer, Yuan AI, seeded RNG
        lk_content/   JSON content + loader + validator
      apps/
        game/         Flutter + Flame app: android, ios, macos, windows only
      tools/
        sim/          CLI: plays scripted strategies against the AI to balance missions
      docs/           this plan and the build spec, exported as Markdown
      CLAUDE.md       rules for the coding agent

**Core data model**

| Entity   | Key fields                                                                                            |
|----------|-------------------------------------------------------------------------------------------------------|
| Officer  | id, name, leadership, war, intelligence, politics, loyalty, skillId, flawId, lessonId, sourceRef, art |
| Card     | id, type (stratagem, event, intent), cost (rice, support), effect, lessonId, sourceRef                |
| Mission  | id, chapter, map, starting units, season length, win and loss rules, script events                    |
| Map node | id, name, terrain, river edges, land edges, rice yield, evacuated flag                                |

**Key decisions**

- Rules are a pure reducer: `(state, action) → state`, with a seeded RNG. Same seed and actions give the same game, so bugs are reproducible.

- A save file is the mission seed plus the action log, which also gives replays for free.

- State management: `flutter_bloc`, with one Cubit wrapping the rules engine.

- One responsive landscape layout scales from phone to desktop window; desktop adds hover tooltips and keyboard shortcuts.

- The app is created with only the four target platforms, so no web or Linux folders exist to maintain.

- A CI check rejects content where any card lacks `sourceRef`, or where a Long Ký ID does not exist.

## Production roadmap

Chapter 1 can launch around mid-April 2027 at about 25 hours a week, with legal work running in parallel from November. Dates are estimates for a solo developer; re-plan after M2.

**Roadmap (solo developer, about 25 hours a week)**

| Milestone | Dates |
| --- | --- |
| M0 Pre-production | Oct 19 – Nov 8, 2026 |
| M1 Rules engine | Nov 9 – Dec 6, 2026 |
| M2 Vertical slice | Dec 7, 2026 – Jan 17, 2027 |
| M3 Chapter 1 content | Jan 18 – Mar 7, 2027 |
| M4 Beta and review | Mar 8 – Apr 4, 2027 |
| Legal and licensing (parallel) | Nov 2, 2026 – Apr 4, 2027 |
| Launch Chapter 1 | Apr 12, 2027 |

The rules engine comes before any art, so content and visuals can then proceed in parallel.

**Exit criteria per milestone**

1.  **M0 Pre-production:** this plan signed off; a paper prototype of mission 2 played at least 5 times; one finished officer card as the style frame; the empty app runs on all four platforms.

2.  **M1 Rules engine:** every Chapter 1 system in pure Dart with tests; mission 2 playable as text through the simulator.

3.  **M2 Vertical slice:** mission 2 playable with final art and voice on an Android phone, an iPhone, a Mac and a Windows PC; 5 outside playtesters.

4.  **M3 Chapter 1 content:** all 5 missions, 6 officers and all cards in; content freeze.

5.  **M4 Beta and review:** TestFlight (iOS and macOS), Google Play closed testing, a Windows test build; historian sign-off; G4 paperwork filed.

6.  **Launch:** only after the G4 release-notice confirmation is in hand.

The G4 processing time is not confirmed here. Ask the lawyer in M0, because it decides whether mid-April holds.

## Legal, regulatory and accuracy checklist

A fully offline, single-player game is a G4 game under Decree 147, which still needs a certificate and a release notice, but avoids the G1 content-approval licence. Confirm everything below with a Vietnamese lawyer before launch.

**Licensing (Vietnam)**

- Confirm G4 status: downloaded over the network, with no interaction between players or with the publisher's server ([Luật Việt Nam](https://luatvietnam.vn/doanh-nghiep/dieu-kien-thu-tuc-de-cung-cap-dich-vu-tro-choi-dien-tu-g2-g3-g4-561-101208-article.html)). A server feature (accounts, cloud save, live events) moves the game to G2, which falls under the same certificate.

- Set up a company: providing G2–G4 games is a conditional business line ([Luật Việt Nam](https://luatvietnam.vn/doanh-nghiep/dieu-kien-thu-tuc-de-cung-cap-dich-vu-tro-choi-dien-tu-g2-g3-g4-561-101208-article.html)).

- Obtain the G2–G4 service certificate and the release-notice confirmation for this game ([Conventus Law](https://conventuslaw.com/report/a-closer-look-at-vietnams-decree-147-on-internet-services-and-online-information/)) before uploading to the app stores ([Thương hiệu và Công luận](https://thuonghieucongluan.com.vn/xu-ly-game-lau-game-co-bac-game-doc-hai-a248975.html)).

- Self-classify the age rating and state it in the application ([LSVN](https://lsvn.vn/phan-loai-game-theo-do-tuoi-tu-25-12-2024-a150127.html)).

- Ask whether the under-18 limit of 60 minutes per game per day applies to G4 ([Thương hiệu và Công luận](https://thuonghieucongluan.com.vn/xu-ly-game-lau-game-co-bac-game-doc-hai-a248975.html)).

- Declare every virtual item and unlock in the filing; they must match what was reported ([LSVN](https://lsvn.vn/khong-mua-ban-vat-pham-ao-giua-nhung-nguoi-choi-tro-choi-dien-tu-voi-nhau-a149864.html)).

- **Card imagery:** Decree 147 bars games resembling casino games or using images of playing cards ([Conventus Law](https://conventuslaw.com/report/a-closer-look-at-vietnams-decree-147-on-internet-services-and-online-information/)). Officer cards are not playing cards, but get a written opinion and keep the frames looking like lacquer tablets.

- Never add real-time multiplayer: G1 needs a licence plus content approval that bans distortion of history ([Thư viện Pháp luật](https://thuvienphapluat.vn/hoi-dap-phap-luat/thu-tuc-cap-quyet-dinh-phat-hanh-tro-choi-dien-tu-g1-tren-mang-138048046.html)).

Enforcement is real: since 2017 authorities had 142 games removed from the Vietnamese app stores, citing gambling, violence, profanity or distortion of history ([Game World Observer](https://gameworldobserver.com/2019/07/23/license-game-vietnam)).

**Desktop distribution (macOS, Windows)**

- Confirm with the lawyer that one G4 filing covers all four platforms; G4 covers games downloaded over the network ([Luật Việt Nam](https://luatvietnam.vn/doanh-nghiep/dieu-kien-thu-tuc-de-cung-cap-dich-vu-tro-choi-dien-tu-g2-g3-g4-561-101208-article.html)), which includes PC downloads.

- macOS: ship through the Mac App Store (same Apple developer account as iOS), or notarize builds distributed outside it.

- Windows: choose Microsoft Store, direct download, or Steam for players outside Vietnam. Steam was reported blocked in Vietnam in May 2024 ([Game Developer](https://www.gamedeveloper.com/business/steam-suddenly-banned-in-vietnam)); its status in 2026 is not verified here.

**Intellectual property**

- File trademarks for Long Ký and the final game title; protection lasts 10 years ([Viet An Law](https://vietanlaw.com/trademark-registration-in-vietnam/)), and examination often takes 18–24 months or more ([Tilleke](https://www.tilleke.com/insights/vietnam-addressing-conflict-between-trademark-and-copyright-relation-logos/8/)).

- Human paint-over on all final art, with layered files kept (see Art pipeline).

- Check every music track's licence covers games, not only video.

**Historical accuracy**

- Pick one canonical source (Đại Việt sử ký toàn thư) and give every card and event a `sourceRef` field.

- Resolve conflicting dates in the content data. Example: sources give Đông Bộ Đầu as 29 January 1258 ([HNUE](https://staff.hnue.edu.vn/Tintuc-Sukien/Trangtintonghop/tabid/260/news/213/Nhungmuaxuanlichsu.aspx)) and as 29-2-1258 ([Loigiaihay](https://loigiaihay.com/giai-bai-1-trang-19-tap-ban-do-lich-su-7-a74430.html)), likely solar versus lunar.

- Keep battlefield numbers abstract where sources disagree (Vân Đồn grain: 170,000 thạch in [Znews](https://znews.vn/danh-tuong-ban-than-danh-chim-170000-thach-luong-cua-quan-nguyen-post906418.html), 100,000 thạch in [Znews](https://znews.vn/10-tran-thuy-chien-vang-danh-su-viet-khien-quan-thu-kinh-hon-bat-via-post919180.html)).

- Get one historian or history teacher to review every card text before submission.

## Tools and MCPs

No new MCP is needed: the connectors already on this account cover art, voice and documents. The repo is attached; what's still missing is access to your local files.

| Tool                                     | Status                       | Use in this project                                                               |
|------------------------------------------|------------------------------|-----------------------------------------------------------------------------------|
| GitHub: `binhnt010896/long-ky-card-game` | Attached, empty              | Game code, content data, CI                                                       |
| Claude Code (coding agent)               | Yours to run                 | Builds the game from the build spec (docs/build-spec.md)                                           |
| Higgsfield                               | Connected                    | Character turnarounds, card illustrations, map art, upscaling, background removal |
| ElevenLabs                               | Connected                    | Narration (series voice) and per-officer character lines                          |
| Claude Docs                              | Connected                    | This plan and the build spec                                                      |
| Long Ký data (this Project)              | Available                    | `people.json`, `events.json`, `periods.json` for shared IDs                       |
| Your computer's folders                  | Not connected yet            | The Long Ký art in your viet-su project folder                                    |
| Supabase                                 | Connected, not for version 1 | Any server feature moves the game from G4 to G2                                   |
| PostHog                                  | Connected, not for version 1 | Analytics; ask the lawyer whether telemetry alone affects G4 status               |

**What I need from you**

- Create the GitHub repo.

- Connect your viet-su project folder: in the Claude desktop app, choose "Add folder" from the "+" menu beside the message box.

- Apple Developer and Google Play developer accounts.

- A Mac for iOS and macOS builds and a Windows PC for Windows builds, or CI runners for each.

- A Vietnamese lawyer for the company and G4 filing, and a history reviewer.

**Not needed:** a separate design tool (card and screen mockups can be made here as designs), or a game engine editor (Flame is code-only).

## Risks and open decisions

The biggest risk is scope, not tech: ship Chapter 1 and measure before building Chapters 2–3.

| Risk                                                           | Impact                                | Mitigation                                                                                              |
|----------------------------------------------------------------|---------------------------------------|---------------------------------------------------------------------------------------------------------|
| Scope creep (more officers, chapters, modes)                   | Launch slips past mid-2027            | Chapter 1 content is frozen at milestone M3; new ideas go to a backlog                                  |
| Four platforms multiply testing                                | Bugs on one platform hold the release | One shared layout; CI builds all four on every main-branch merge; test each platform at every milestone |
| Card imagery read as playing cards under Decree 147            | Filing rejected or game removed       | Lacquer-tablet frames, written legal opinion before M4                                                  |
| Historical complaint (wrong date, framing, defector portrayal) | Removal from VN stores                | One canonical source, `sourceRef` on all content, reviewer sign-off                                     |
| AI art not protectable                                         | Others can copy raw assets            | Human paint-over, trademarks on names and logo                                                          |
| Asymmetric balance (retreat feels like losing)                 | Players quit at mission 2             | Clear Yuan Supply meter, early wins on raids, playtest every mission                                    |
| Solo bandwidth                                                 | Everything slips together             | Pure-Dart rules engine first, so content and art can proceed in parallel                                |

**Open decisions**

- Business model: premium, or free Chapter 1 with paid Chapters 2–3.

- Weekly hours available; the roadmap assumes about 25 hours per week.

- Trademark search on "Long Ký - The Game" (name decided).

- Windows channel: Microsoft Store, direct download, or Steam outside Vietnam.

- Whether the Yuan side is ever playable (recommended: no, for sensitivity).

## Sources

**History**

- [LSVN: Hào khí Đông A](https://lsvn.vn/hao-khi-dong-a-suc-manh-vo-hinh-cua-nuoc-viet-thoi-nha-tran-a5504.html)

- [Luật Minh Khuê: ba lần kháng chiến chống Mông Nguyên](https://luatminhkhue.vn/nguyen-nhan-va-y-nghia-cua-ba-lan-khang-chien-chong-quan-mong.aspx)

- [VietJack: SBT Lịch sử 7, trang 48](https://vietjack.com/sbt-lich-su-7-kn/giai-sbt-lich-su-7-trang-48-ket-noi.jsp)

- [VietJack: Lịch sử 11, trang 50](https://vietjack.com/lich-su-11-ct/lich-su-11-trang-50.jsp)

- [VietJack: Lịch sử 7 Cánh diều, trang 67](https://vietjack.com/lich-su-7-cd/lich-su-7-trang-67.jsp)

- [Loigiaihay: SBT sử 7, bài 3](https://loigiaihay.com/giai-bai-3-trang-47-sbt-su-7-a68523.html)

- [Loigiaihay: SBT sử 7, bài 5](https://loigiaihay.com/giai-bai-5-trang-48-sbt-su-7-a68525.html)

- [Loigiaihay: Chiến thắng Bạch Đằng](https://loigiaihay.com/chien-thang-bach-dang-a13767.html)

- [Loigiaihay: Lịch sử 7 Cánh diều, bài 17](https://loigiaihay.com/bai-17-ba-lan-khang-chien-chong-quan-xam-luoc-mong-nguyen-sgk-lich-su-va-dia-li-7-canh-dieu-a107988.html)

- [Loigiaihay: Tập bản đồ Lịch sử 7, trang 19](https://loigiaihay.com/giai-bai-1-trang-19-tap-ban-do-lich-su-7-a74430.html)

- [HNUE: Những mùa xuân lịch sử](https://staff.hnue.edu.vn/Tintuc-Sukien/Trangtintonghop/tabid/260/news/213/Nhungmuaxuanlichsu.aspx)

- [PLO: Hội nghị Diên Hồng và bài học đoàn kết](https://plo.vn/hoi-nghi-dien-hong-va-bai-hoc-doan-ket-dong-thuan-post775608.html)

- [WarHistory: Mongol invasions of Vietnam](https://weaponsandwarfare.com/?p=14762)

- [Wikipedia: Trần Thái Tông](https://en.wikipedia.org/wiki/Tr%E1%BA%A7n_Th%C3%A1i_T%C3%B4ng)

- [Wikipedia: Battle of Bình Lệ Nguyên](https://en.wikipedia.org/wiki/Battle_of_B%C3%ACnh_L%E1%BB%87_Nguy%C3%AAn)

- [Mytour: Lê Phụ Trần](https://mytour.vn/vi/blog/bai-viet/le-phu-tran.html)

- [Mytour: 7 vị tướng chống Mông Nguyên](https://mytour.vn/vi/blog/bai-viet/top-7-vi-tuong-noi-bat-trong-cuoc-chien-chong-quan-mong-nguyen.html)

- [Znews: 10 câu nói lưu danh](https://znews.vn/10-cau-noi-luu-danh-muon-doi-cua-anh-hung-nuoc-viet-post818481.html)

- [Znews: những kẻ bán nước](https://znews.vn/ket-cuc-bi-tham-cua-nhung-ke-ban-nuoc-cau-vinh-post940631.html)

- [Znews: Trần Khánh Dư](https://znews.vn/danh-tuong-ban-than-danh-chim-170000-thach-luong-cua-quan-nguyen-post906418.html)

- [Znews: 10 trận thủy chiến](https://znews.vn/10-tran-thuy-chien-vang-danh-su-viet-khien-quan-thu-kinh-hon-bat-via-post919180.html)

- [PubHTML5: Trần Bình Trọng](https://pubhtml5.com/ocldv/uoyc/basic/51-100)

**Law and regulation**

- [Luật Việt Nam: G2, G3, G4 conditions](https://luatvietnam.vn/doanh-nghiep/dieu-kien-thu-tuc-de-cung-cap-dich-vu-tro-choi-dien-tu-g2-g3-g4-561-101208-article.html)

- [Conventus Law: Decree 147](https://conventuslaw.com/report/a-closer-look-at-vietnams-decree-147-on-internet-services-and-online-information/)

- [Thương hiệu và Công luận: Decree 147 on games](https://thuonghieucongluan.com.vn/xu-ly-game-lau-game-co-bac-game-doc-hai-a248975.html)

- [LSVN: age classification](https://lsvn.vn/phan-loai-game-theo-do-tuoi-tu-25-12-2024-a150127.html)

- [LSVN: virtual items](https://lsvn.vn/khong-mua-ban-vat-pham-ao-giua-nhung-nguoi-choi-tro-choi-dien-tu-voi-nhau-a149864.html)

- [Thư viện Pháp luật: G1 release](https://thuvienphapluat.vn/hoi-dap-phap-luat/thu-tuc-cap-quyet-dinh-phat-hanh-tro-choi-dien-tu-g1-tren-mang-138048046.html)

- [Game World Observer: licensing games in Vietnam](https://gameworldobserver.com/2019/07/23/license-game-vietnam)

- [Viet An Law: trademark registration](https://vietanlaw.com/trademark-registration-in-vietnam/)

- [Tilleke: trademark and copyright for logos](https://www.tilleke.com/insights/vietnam-addressing-conflict-between-trademark-and-copyright-relation-logos/8/)

- [Tilleke: AI-generated works in Vietnam](https://www.tilleke.com/insights/the-ip-puzzle-of-ai-generated-songs-protection-responsibility-and-the-future-of-music-law)

- [Sidley: USCO report on AI copyrightability](https://datamatters.sidley.com/2025/02/07/u-s-copyright-office-issues-report-on-artificial-intelligence-and-copyrightability/)

**Tech**

- [depscope: flame on pub.dev](https://depscope.dev/pkg/pub/flame)

- [Flame PR \#3995: adapt to Flutter 3.47](https://github.com/flame-engine/flame/pull/3995)

- [Flutter: desktop support](https://docs.flutter.dev/platform-integration/desktop)

- [Claude Code: model configuration](https://code.claude.com/docs/en/model-config.md)

- [Game Developer: Steam blocked in Vietnam](https://www.gamedeveloper.com/business/steam-suddenly-banned-in-vietnam)
