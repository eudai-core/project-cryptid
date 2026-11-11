# Spec 08: Rare-Catch Announcements

> **11 Nov 2026.** Variant words are spec 15 §6: Normal, Spectral, Gilded, Shadow, Moonlit. The save field stays `mutation`. A Shadow catch takes the banner that this spec used to give the darker variant. A Spectral catch takes the toast.

> **4 Nov 2026:** all [A] assumptions are approved by the owner as starting values, to be tuned from playtest data. Robux prices are still pending Eudai's approval.

**Owner:** Cryptid Growth Strategist · **Builder:** Cryptid Systems Architect · **Status:** Draft v2.3 (Wed 4 Nov 2026; v2.3: audit fix, free-source wording. v2.2: decision B, readings earn-only and silent; named boost banners; Mythic sky per style guide v0.6. v2.1: Epic = Blood `#7A0F12`, never purple; Mythic sky trigger rule. v2: readings never announce; boost-buyer banners for Blood Moon and Server Luck. v1 same day) · **Due:** Sun 8 Nov
**Builds on:** Spec 09 v3 (odds), spec 10 v2, spec 01 v2.1 (theme tokens), art style guide `/workspace/project-cryptid/art/style-guide.md` (v0.6 rulings; file now v0.7).

> **v2.2 change (Wed 4 Nov 2026), Eudai's decision B + Grok Bot rulings:**
> - **Tarot readings are earn-only and always silent.** The old "paid pulls show only to the buyer / free readings silent so nobody can tell who paid" wording is removed: no readings are sold (spec 09 v3, spec 10 v2).
> - **Server-wide boosts name the buyer** in a thank-you banner with **no price and no buy link**: "**{DisplayName} summoned a Blood Moon over Hollowmere!**" and "**{DisplayName} summoned Server Luck ×2 over Hollowmere!**" (§4b). **Personal Robux purchases never announce.**
> - **Server Luck is paid** (Eudai option A, January only): restricted players (`ArePaidRandomItemsRestricted`) **don't see its banner, chat line or chip** and don't benefit (spec 10 v2 §5).
> - **Style guide:** D29 ("no banner for anything bought") is **overridden for server-wide boosts** (D36 already allows server-wide gift banners; **Art Director to amend D29** to cover Blood Moon and Server Luck explicitly). Rift-belt Epics still announce: D29 as amended says cash = free, so no conflict remains.
> - **From spec 11 v1 §11 (approved by Grok Bot as the design base, 4 Nov):** **Shadow** catches from the Wilds or the Rift belt (any rarity) also get the server banner, same rate limits (**Update 1**, with variants). Spectral catches get only the catcher's toast.
> - **Mythic sky (§8.5):** GoldBright + Bone flare + thin Rift core (D34); Rift ≤ 5% of the screen for 20 s (D35); fires on **every free source**. **v2.3 (compliance audit (`compliance-audit-cash-random.md` §4; Grok Bot approved, 4 Nov; cash = paid currency)):** Nothing bought at a shop, with Robux or cash, counts as a free source. The Rift belt counts as a building, so its catches stay free sources; Pedlar buys don't.

> **[A]** = design assumption. Grounding (research canvas): rare-catch announcements are a launch must-have; Salganik et al. 2006 show visible signals of other people's success shape behaviour (social proof); loss aversion should be used gently, so no "you missed it!" copy. Odds from spec 09 (checked by `specs/tools/verify_odds.py`).

## 1. Goal
When someone catches something truly rare, **the whole server sees it for a moment**. That gives a "this could be me" spark for everyone else, and a proud moment for the catcher. It must stay rare, calm and on-brand.

## 2. Threshold and scope

| Rule | Value |
|---|---|
| Announces | Catching an **Epic** (Jersey Devil, Loch Ness Serpent) from the **Wilds** or the **Rift Fissure conveyor**. **Update 1 (spec 11 §3.2):** also a **Shadow** catch of any rarity from those sources (banner: "**{DisplayName}** has bound a **Shadow Hodag** from the Wilds."); Spectral = catcher's toast only |
| Per-species odds at that threshold | Rift **0.2%** each, Wilds **0.1%** each (spec 09) |
| Doesn't announce | Pedlar purchases (you chose to buy it), daily reward creatures, rebirth familiars, Rares, **every tarot reading** (readings are earn-only and always silent, spec 09 v3 §5.5, spec 10 v2), and **any personal Robux purchase** (Bound Rites, passes, cash bundles, cosmetics) |
| Scope | **This server only** at launch |
| Global (cross-server) | **Deferred** until Legendary/Mythic ship (plan: January). At launch CCU, a global feed would be either empty or spammy, and it needs MessagingService rate budgeting [A] |

**Expected frequency [A]:** an active catcher grabs roughly 1 Rift or wild cryptid every 10–15 s, so an Epic is about 1 per ~40–60 min of catching per player. In a full 8-player server that's roughly **one banner every 5–8 minutes**: rare enough to matter, often enough that most sessions see one.

## 3. Rate limits
| Limit | Value |
|---|---|
| Server banner gap | At most **1 banner per 20 s** |
| Queue | Up to **3** waiting; extra ones show only in chat |
| Per player | At most **1 banner per 60 s** for the same catcher (more go to chat only) |
| Banner time on screen | 4 s (slide in 0.3 s, hold, fade 0.5 s; Reduced Motion: fade only) |

## 4. Message text
- **Banner:** "**{DisplayName}** has bound a **Jersey Devil** from the Wilds."
  - Rift variant: "…from the Rift."
- **Chat system message** (TextChatService, every qualifying catch): `[The Rift] {DisplayName} has bound a Jersey Devil.`
- **Catcher's own toast:** "The Rift answers you. An Epic: **Jersey Devil**."
- Uses the player's Roblox **DisplayName** only. Never player-typed text (no cryptid nicknames), so no extra text filtering is needed [A, Architect to confirm against TextChatService rules].
- No "you missed it", no "only X left", no shop links.

## 4b. Boost-buyer banners (v2)
These thank the buyer for a **public boost to the whole server**. **Personal Robux purchases never announce.**

| Boost | Ships | Banner text | Chat line |
|---|---|---|---|
| **Blood Moon** (spec 09 v3 §8.1) | Update 1 | "**{DisplayName} summoned a Blood Moon over Hollowmere!**" Sub-line: "Every lair earns +50% for 10 minutes." | `[The Moon] {DisplayName} summoned a Blood Moon over Hollowmere!` |
| **Server Luck** (spec 10 v2 §5, paid, PolicyService-gated) | **January (not launch)** | "**{DisplayName} summoned Server Luck ×2 over Hollowmere!**" Stacks: "**{DisplayName}** raised Server Luck to **×2.5** over Hollowmere!" | `[The Rift] {DisplayName} summoned Server Luck over Hollowmere!` (eligible players only) |

- **No price, no Robux symbol, no "buy one too" button or link** in any banner, toast or chat line.
- **Blood Moon** banner, chat line and chip ("Blood Moon · 7m 12s") show to everyone (income only, not a paid random item).
- **Server Luck** banner, chat line and chip ("Luck ×2 · 9:41") show **only to eligible players** (policy check succeeded and `ArePaidRandomItemsRestricted == false`). Restricted or unknown-policy players see nothing of it and their rolls stay ×1 (conservative, spec 10 v2 §5.1).
- Boost banners use the same queue and 20 s gap as catch banners, but jump to the **front** of the queue (a boost is time-limited) [A].
- Per buyer: max **1 boost banner per 60 s**; extra stacked purchases in that minute go to chat only.
- Fill uses `Blood` for Blood Moon and `Ash` with a `Rift` hairline for Server Luck (accent only).

## 5. Look (palette)
| Element | Token |
|---|---|
| Banner fill | Blood `#7A0F12` at 92% opacity |
| Border | Gold `#9C7A3C`, 2 px |
| Text | Bone `#E8E0CF`; cryptid name in GoldBright `#C9A55A` (spec 01) |
| Accent | Rift `#7FA34A`: one thin crack glyph left of the text only (**rare use**) |
| Font | `GrenzeGotisch` 22 (name line), `Merriweather` 16 |
| Size / place | 640 × 64 desktop, top-centre, below the top bar; mobile full-width minus 16 px |
| Sound | One low bell, volume 0.4, respects the SFX toggle |

**Epic is Blood crimson `#7A0F12`, never purple** (style guide D24). The Art Director may tint the cryptid name in Blood `#7A0F12` (with Bone outline for contrast). No purple anywhere.

## 6. Data to save
None in the profile. Server memory only: `lastBannerTime`, `queue[]`, `lastBannerByUser{}`. Analytics event `epic_announced {source, cryptidId}` [A].

## 7. Server vs client
- **Server:** decides that the catch was an Epic from a qualifying source (from the server roll, never a client claim), applies rate limits, fires `AnnounceCatch:FireAllClients({displayName, cryptidId, source})`, and sends the chat system message.
- **Client:** shows the banner and plays the sound. It can't trigger one.

## 8. Edge cases
1. **Catcher leaves before the banner plays:** it still shows (DisplayName cached).
2. **Two Epics in 1 s:** first banner now, second after 20 s (queued).
3. **Restricted-policy players:** catch banners unchanged (free catches aren't paid random items). They **never** see Server Luck banners, chat lines or chips.
4. **Player has chat off:** banner still shows.
5. **Mythic sky (spec 10 v2 §10, January; style guide D26/D29 as amended, D34, D35):** fires for a real server-rolled Mythic from **every free source**: earned readings, wild catches, **Rift belt** catches, **expeditions**, free events. Nothing bought at a shop, with Robux or cash, counts as a free source. The Rift belt counts as a building, so its catches stay free sources; Pedlar buys don't. Nothing bought fires it. **Look:** Gold-led, **GoldBright `#C9A55A`** with a **Bone `#E8E0CF` flare** and only a **thin Rift-green `#7FA34A` core**, not Rift-heavy. Rift green may reach **5% of the screen for the 20 s** only (elsewhere ≤ 2%; on cards ≈ 2% of the card area); readability floor kept. An earned-reading Mythic gets the sky with **no** name banner (readings stay silent); a wild or Rift-belt Mythic gets the sky plus this banner; an expedition Mythic gets the sky only.
6. **Luck boosts (spec 10 v2 §5, January):** the catch threshold stays "Epic+". Odds panels show the boosted odds live (Roblox [paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items): modified odds must be "dynamically updated").

## 9. QA acceptance tests
| # | Test | Pass if |
|---|---|---|
| 1 | Trigger | Forcing an Epic Rift roll shows the banner to all clients in the server |
| 2 | Pedlar | Buying an Epic at the Pedlar shows no banner |
| 3 | Rare | Catching a Rare shows no banner |
| 4 | Gap | Two forced Epics 5 s apart: second banner appears ≥ 20 s after the first |
| 5 | Queue | 5 forced Epics at once: 3 banners total, all 5 in chat |
| 6 | Per player | Same player, 2 Epics in 30 s: 1 banner, 2 chat lines |
| 7 | Client spoof | Firing the announce remote from a client does nothing |
| 8 | Text | Uses DisplayName; the cryptid's nickname never appears |
| 9 | Palette | Blood fill, Gold border, Bone text; no purple |
| 10 | Mobile | Banner fits a 360 px-wide screen without covering the HUD buttons |
| 11 | Readings silent (v2.2) | An earned Epic reading: no banner, no chat line for anyone; only the reader sees the reveal |
| 12 | Boost banner (v2.2) | Buying a Blood Moon shows "{DisplayName} summoned a Blood Moon over Hollowmere!" to everyone; Server Luck shows its banner to eligible players only; never a price, Robux symbol or buy link |
| 13 | **Personal purchases silent** | Buying a Bound Rite, a pass, a cash bundle or a cosmetic: no banner, no chat line, nothing for other players |
| 14 | Restricted viewer | A UK-emulated restricted player in the server sees no Server Luck banner, chat line or chip when someone else buys it; Blood Moon still shows |
| 15 | Mythic sky look/trigger | Forced Mythic from the Rift belt and from an expedition fires the sky; a Robux-flagged source or a Pedlar purchase doesn't; Gold-led look, Rift ≤ 5% of screen for 20 s |
