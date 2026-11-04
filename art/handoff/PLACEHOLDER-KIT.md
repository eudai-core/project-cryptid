# Placeholder silhouette kit (v1.1, 2026-11-04: Uncommon trim, roster mode, sizing to H × L)

**Purpose:** the launch roster (12 cryptids, art due ~Mon 9 Nov) isn't final. Any roster name can get a readable, on-palette stand-in in seconds, then be swapped for a full model later with **no code changes**.

## Archetypes (scale 1.0; Common / Uncommon / Rare / Epic part counts)
| Archetype | Read | Parts | Size W × H × D (studs) |
|---|---|---|---|
| `winged` | big V of wings over a small body + round head | 10 / 12 / 11 / 13 | 5.4 × 4.8–5.3 × 2.4 |
| `lurker` | tall stooped biped with too-long arms | 11 / 13 / 12 / 14 | 2.4 × 6.5–7.3 × 1.8 |
| `beast` | low boxy quadruped, jaw, tail | 12 / 14 / 13 / 15 | 2.2 × 2.9–3.8 × 5.8 |
| `serpent` | S-curve body rearing up into a flat head | 10 / 12 / 11 / 13 | 2.6 × 3.0–3.8 × 5.9 |

Every placeholder has:
- a **crimson eye pair**: Blood `#7A0F12` **Glass**, not Neon, because D10 allows Neon eyes on the Mothman only
- one **rarity band** part
- body in Soot/Ash, Slate/Fabric

**Rarity trims**, from the style guide §1 rarity line. Rarity = shape *and* colour (§3):
- **Common:** BoneDim band
- **Uncommon:** Moss `#5E7A4A` band (spec 01 A2) + **two swept-back tufts** (shape cue)
- **Rare:** Tarnished-silver `#8C9AA3` band + a crest. Approved by **D11** (Master Controller, 2026-11-04)
- **Epic:** Blood band + crest + two horns

**Scale:** `--scale 0.5–2.0` scales everything around the pivot. Or give `--height H --length L` (studs; L = longest horizontal extent) and the script fits a non-uniform scale (vertical × horizontal, balls stay round, Root recentred) to hit the roster size. The script warns if the footprint goes over 8 × 8 (or 6 × 6 for Common), if the model is taller than 10, or if the part count falls outside 8–15. At scale 1 all 16 samples fit Common limits.

## Usage
```bash
python3 art/tools/build_placeholder.py --name Jackalope --archetype beast --rarity uncommon --height 3 --length 4 --cryptid-id jackalope
# -> art/models/placeholders/Jackalope_PH.rbxmx   (Model "Jackalope_PH")
python3 art/tools/build_placeholder.py --roster art/roster-provisional.md   # all 12 roster placeholders at roster sizes
python3 art/tools/build_placeholder.py --samples   # 16 kit samples -> art/models/placeholders/samples/ (NOT Rojo-mapped)
python3 art/tools/validate_rbxmx.py art/models/placeholders/Jackalope_PH.rbxmx --max 15 --id-key CryptidId --id jackalope --placeholder
```
**Attributes:**
- `CryptidId` (use the roster id exactly)
- `AssetVersion = "1.0"`
- `IsPlaceholder = true` (a real **bool**)
- `Archetype`, `Rarity`, `Scale` (strings)

**Conventions:**
- `PrimaryPart = Root`: flat, invisible, at the **footprint centre**, with the pivot on the floor.
- Front = −Z.
- All parts anchored, with collide/touch/query off.

**Roster placeholders:** `art/models/placeholders/<CamelCaseId>_PH.rbxmx` for all 12 roster entries (real CryptidIds, roster H × L), 10–14 parts, all **PASS**. Sheet: `qa/screenshots/RosterPlaceholders_2026-11-04_preview-sheet.png` (+ `-sheet-side.png`).

**Samples:** `art/models/placeholders/samples/Sample<Archetype><Rarity>_PH.rbxmx`, with `CryptidId = placeholder_<archetype>_<rarity>`. All 16 **PASS**. Kept in a subfolder so Rojo never ships them.

**Previews (box-side, NOT Studio proof):**
- `qa/screenshots/Placeholders_2026-11-04_preview-sheet.png`: 3/4 view; rows are archetypes, columns are Common/Uncommon/Rare/Epic.
- `qa/screenshots/Placeholders_2026-11-04_preview-sheet-side.png`
- `qa/screenshots/Placeholders_2026-11-04_preview-silhouette-side.png`: pure-black shape test.

Redesign passes used: 1 (bigger rarity bands; the serpent rears higher with a bigger head). v1.1 additions (Uncommon, sizing) were first-pass.

**Folklore rule (spec 09):** American/British folklore only; no figures sacred to living Indigenous cultures. The old Wendigo usage example broke that rule and has been replaced.

## Swapping a placeholder for the full model (Architect)
Code should **look up models by `CryptidId`, never by instance name**:
```lua
-- sketch only
local function findCryptidModel(id)
	for _, folder in ipairs({Assets.Cryptids, Assets.Placeholders}) do   -- real models win over placeholders
		for _, m in ipairs(folder:GetChildren()) do
			if m:GetAttribute("CryptidId") == id then return m end
		end
	end
end
-- placement is identical for both: model:PivotTo(pad.CryptidMount.CFrame)
```
To swap:
1. Add the real model (e.g. `assets/cryptids/Jackalope.rbxmx`, done in Batch 02) with the **same `CryptidId`** and the same pivot convention (Root flat, pivot on the floor, front −Z). Every batch model already follows this.
2. Delete `assets/placeholders/Jackalope_PH.rbxmx` (or leave it: the lookup prefers `Cryptids`).
3. No code, data or pad changes are needed. `GetAttribute("IsPlaceholder")` lets UI/QA flag stand-ins, for example to block a "final art" build while any remain.

## PENDING (Studio)
- Wedge facing (crest, beast jaw, serpent tail tip); see BATCH-01 #1.
- 30-stud silhouette read on a phone. The box sheet suggests the front/3/4 reads clearly; from the side, `winged` is a flat slab by nature.
- Glass Blood eyes may read dark rather than glowing. If they need to glow, that is a new Neon decision (D10 doesn't cover placeholders).
- Studio screenshots.
