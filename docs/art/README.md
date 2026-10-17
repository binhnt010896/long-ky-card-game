# Art in the game

Where every picture comes from, and how to add or replace one.

## Sources

| Art | Where it comes from | In the game |
| --- | --- | --- |
| Officer and commander portraits (7) | The owner's **viet-su** project (`content/eras/*/characters/<id>-avatar.png` and `-full.png`; Trần Quốc Tuấn is `tran-hung-dao`) | `officers|enemies/<id>/portrait.jpg` (1:1, 512 px) and `card.jpg` (2:3) |
| Title cover, dragon splash, logo | viet-su (`eras/tran-thai-tong/cover.png`, `brand/splash/splash-dragon.png`, `brand/logo/longky-01-circle-oxblood.png`) | `ui/title-cover.jpg`, `ui/dragon-splash.jpg`, `ui/logo.png` |
| Mission 2 and 4 backdrops | viet-su event paintings (`khang-chien-mong-co-lan-mot`, `tran-thu-do-dung-nen`) | `missions/ch1_m2.jpg`, `missions/ch1_m4.jpg` |
| Painted map, six card illustrations, mission 1, 3 and 5 backdrops | **Generated with Higgsfield** (`nano_banana_pro`, 2K), prompts below | `maps/ch1.jpg`, `cards/<id>.jpg`, `missions/ch1_m{1,3,5}.jpg` |

`tools/art/import_viet_su.sh` re-imports the viet-su files (resized, JPEG);
`tools/art/save_generated.sh <url> <path> <edge>` saves a generated image.

## Rules that apply to every picture

- Painterly realism in the Vietnamese sơn mài lacquer tradition: oxblood red,
  black lacquer, gold leaf; full-bleed; no frame.
- **No text, letters, calligraphy or Hán tự** in any picture (plaques, banners
  and scrolls stay blank or purely ornamental). Check each generated image.
- **AI-generated pictures need a human paint-over before release** (plan.md,
  "Art pipeline"; AI output alone is not protectable). Treat everything
  generated here, and the viet-su pictures made the same way, as drafts.
- The history reviewer should check each picture against its subject (armour,
  boats, buildings of the 13th century) before the content freeze.

## Prompts (generated pictures)

Common ending: *Painterly realism in the Vietnamese sơn mài lacquer-painting
tradition: deep oxblood red, black lacquer and gold-leaf palette, warm firelight
and amber glow, rich oil-paint texture, cinematic composition, full-bleed
illustration. No text, no letters, no captions, no signatures, no Chinese
characters, no frame, no border, no modern objects.*

- **maps/ch1.jpg** (16:9): an illustrated terrain map of the Red River delta and
  northern Đại Việt in the 13th century seen from above, black-red lacquer
  ground, forested mountains upper-left, rivers as gold-and-teal ribbons flowing
  southeast, rice plains and villages, a walled citadel centre-right, a river
  port lower right, gold cloud swirls in the margins; open terrain for a board.
  Node positions in `maps/ch1.json` were fitted to it by eye.
- **cards/vuon-khong-nha-trong.jpg** (3:4): a deserted 13th-century village at
  dusk, doors open, spilled rice, smouldering thatch, villagers leaving far down
  the road.
- **cards/lui-binh-bao-toan.jpg**: Trần soldiers withdrawing in good order at
  night onto long river boats with torches and wounded, mist.
- **cards/phuc-kich-ben-song.jpg**: warriors hidden in reeds at a river ford at
  dusk, a Mongol cavalry column crossing.
- **cards/phan-cong.jpg**: a Trần army surging from war boats onto a river bank
  at dawn under red banners, a general pointing forward.
- **cards/su-gia-phuong-bac.jpg**: Mongol envoys presenting a rolled letter to
  the seated young king in a lacquer court hall.
- **cards/nang-nong.jpg**: a Mongol army in heavy armour wilting under a
  tropical sun beside a marsh.
- **missions/ch1_m1.jpg** (3:2): a wide audience hall, envoys offering a sealed
  letter at the throne, the plaque above the throne blank.
- **missions/ch1_m3.jpg**: the Thăng Long citadel at dawn, abandoned on purpose,
  gate open, last carts leaving toward the river.
- **missions/ch1_m5.jpg**: boats landing at the Đông Bộ Đầu river bank at dawn
  and charging a weakened Mongol camp; banners plain.

## Added 2026-10-17 (battle polish)

- **maps/ch1-wide.jpg**: `maps/ch1.jpg` widened to 21:9 with Higgsfield `outpaint_image` (no prompt). Its middle 16:9 is the original map the nodes are placed on.
- **ui/btn-gold.jpg**, **ui/btn-lacquer.jpg** (21:9, `nano_banana_pro`): texture swatches for buttons. Prompts: "a seamless horizontal texture swatch for a game button: polished gold-leaf over black-red sơn mài lacquer, subtle craquelure, hammered gold flecks, warm highlights at the top fading to bronze at the bottom" and the same in oxblood-red lacquer with a glossy sheen. No text or objects.

## Added 2026-10-17 (officer callouts)

- **officers/{tran-thai-tong,tran-thu-do,tran-quoc-tuan}/charge.jpg** (2:3, `nano_banana_pro` with the officer's `card.jpg` as the reference image): the same person and clothes, pointing forward and shouting. Prompt: "the same person as in the reference image, exact same face, costume and colours, same painterly lacquer style; new pose: dynamic heroic stance, right arm extended forward with the index finger pointing straight ahead, mouth wide open in a fierce commanding battle shout, intense eyes, cape and banners streaming, dramatic upward angle, warm firelight; no text". Used by the callout when the turn is resolved (the king) and when that officer uses a skill.
- Voice lines in `assets/audio/voice/` (supplied by the owner): `end-turn.mp3` and `end-turn-2.mp3` (the king's shout, in turn), `tran-thu-do-skill.mp3`, `tran-quoc-tuan-skill.mp3`, `victorious.mp3`, `defeated.mp3`. `tran-quoc-tuan-kill.mp3` is not used yet.
