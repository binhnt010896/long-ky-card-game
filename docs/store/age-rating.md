# Age-rating notice (T-27)

Facts about the game, for whoever fills in the questionnaires (Google Play IARC, App Store Connect, Microsoft Store).
The rating itself is **assigned by each store from the owner's answers**; this file does not give one.

| Question | Fact | Source |
| --- | --- | --- |
| Online features, accounts, chat, user-generated content | None. The game is offline, single-player, with no accounts. | CLAUDE.md "Hard rules" |
| Ads, in-app purchases, loot boxes, gambling | None. Cards are fixed decks; no purchase or real-money random item exists. | CLAUDE.md "Hard rules"; docs/plan.md |
| Data collected or shared | None: no analytics, no networking. (T-29 checks it.) | CLAUDE.md; build-spec section 7 "Offline guard" |
| Location, contacts, camera, microphone | Not used. | `AndroidManifest.xml`, `Info.plist` (no usage strings) |
| Violence | Historical war theme shown as abstract tokens, arrows and numbers on a map; battle results are numbers (Power, troops lost). No blood, wounds or depictions of people being hurt; no gore. Suggested answer: mild/abstract, historical, not realistic. | `BoardPainter` and the battle overlays; content JSON |
| Sexual content, nudity, drugs, alcohol, profanity | None. | content JSON |
| Frightening content | None beyond the war theme above. | |
| Real-world links | "Read more in Long Ký" opens a web link or store page chosen by the owner (the Long Ký app or its store page), from a fixed template, not open browsing. Desktop shows it as a QR code. | `LongKyLinks`, T-24 |
| Kids' category | Not designed for it. Do not opt into a kids programme without a separate review. | |

Before the final answers: the history reviewer should read the content export, since the war theme depends on the
wording of the briefings and debriefs, which are still placeholders (`todo` in each mission).
