### Handoff: Pad (v1.0, 2026-11-03)
- **Asset id / model name:** `Pad` · Attributes `AssetId = "Pad"`, `AssetVersion = "1.0"`, `States = "Occupied,Empty,Locked,Sealed"`
- **File path (box):** `/workspace/project-cryptid/art/models/Pad.rbxmx`. Generator: `art/tools/build_assets.py Pad` (shared lib `art/tools/rbxlib.py`; preview data `models/Pad.parts.json`, do NOT map the `.json` into Rojo)
- **Proposed place path:** `ReplicatedStorage.Assets.Lair.Pad` (style guide §8, proposed)
- **Goes in game at:** cloned 12× per plot into `Workspace.Plots.Plot<i>` on the ring (radius 28 around the altar, Pad 1 nearest the gate) `[S02 §3]`. Code sets `beingStolen` on each pad instance `[S02 §8]`.
- **Counts:** **13 parts in the template** (2 invisible). **Visible per active state: 3–5** (base 2 + state 1–3), within the ≤ 6 per pad budget. 4 cylinders, 7 blocks + 2 invisible blocks. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, scripts: none.**
- **Materials:** CorrodedMetal ×2 (ring, affordable border), Slate ×1 (centre), Limestone ×7 (sigils/band). No Plastic/Neon.
- **Colours (tokens):**
  - Gold: `Ring` (CorrodedMetal, Ø10 × 0.4)
  - Soot: `Centre` (Slate, Ø8.6, top at 0.46)
  - GoldBright: `BoundBand` (Occupied)
  - BoneDim: sigils (Empty faint 55 % transparent, Locked solid, Sealed cracked 3-piece)
  - Blood: `AffordableBorder` (Ø10.5 rim)
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**). `PivotOffset` puts the **pivot at ground level (y = 0)**, so `model:PivotTo(cf)` sits it flat with **no offset**. **Front = −Z** (`Root.CFrame.LookVector`). Pivot is the pad centre on the floor. **`CryptidMount`** (invisible, top-centre at y = 0.51) is where a cryptid goes: `cryptid:PivotTo(pad.CryptidMount.CFrame)`.
- **Size (studs):** Ø 10.5 (with affordable rim) × 0.5 tall
- **States / variants:** 4 states + 1 modifier as sub-Models (see below)
- **Physics:** every part `Anchored = true`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` on only for `Ring`, `Centre`, `BoundBand`, `AffordableBorder`; off on all other parts.
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned. No Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/Pad_2026-11-03_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** a low, sunken ritual circle: a thick corroded-gold ring around a dark slate disc, ≤ 0.5 studs tall. Each state adds one small readable mark on the disc.

#### State switching (Architect)
The template contains **all** states. Each is a sub-Model with attribute `State`:

| Sub-Model | `State` attr | Parts | Show when |
|---|---|---|---|
| `State_Occupied` | `Occupied` | `BoundBand` (GoldBright inner band) | a cryptid is on the pad |
| `State_Empty` | `Empty` | `Sigil1/2` (faint BoneDim X) | unlocked, nothing on it |
| `State_Locked` | `Locked` | `LockSigil1/2` (solid BoneDim X) | locked, can be carved (shows "$120 · Carve" billboard from code) |
| `Mod_Affordable` | `Affordable` | `AffordableBorder` (Blood rim) | **with** Locked, when the player can afford it `[S01 B5]` |
| `State_Sealed` | `Sealed` | `CrackedSigil1–3` (broken X) | Pads 7–12 sealed (+ "Sealed" BoneDim billboard from code) `[S02 §3]` |

Recommended: on clone, keep a reference to every state Model and **detach the inactive ones** (`Parent = nil`), so states can flip at runtime with no re-cloning. Don't park them in a Folder under the pad: anything under Workspace still renders.
```lua
-- sketch only, not shipped: the Architect owns the real code
local function initPad(pad)                      -- call once after cloning the template
	local states = {}
	for _, g in ipairs(pad:GetChildren()) do
		if g:IsA("Model") and g:GetAttribute("State") then states[g:GetAttribute("State")] = g end
	end
	return states
end
local function setPadState(pad, states, state, affordable)   -- "Occupied" | "Empty" | "Locked" | "Sealed"
	for s, g in pairs(states) do
		local on = (s == state) or (s == "Affordable" and state == "Locked" and affordable == true)
		g.Parent = on and pad or nil
	end
end
```
Then place a cryptid with `cryptid:PivotTo(pad.CryptidMount.CFrame)`. Billboards (name/income, price, "Sealed") are BillboardGui/SurfaceGui created in code, not parts.
#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: Gold/Soot/GoldBright/BoneDim/Blood only |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: none |
| 4 | Materials | **PASS**: CorrodedMetal Gold ring + Slate centre as spec `[S01 A4]`; Limestone sigils |
| 5 | Silhouette | **PASS (box preview)**: ring + disc read; states differ by mark. Studio read **PENDING**, esp. Empty vs Locked (faint vs solid X, same shape; the Locked billboard carries most of the difference) |
| 6 | Not toy-like | **PASS**: flat, worn, no gloss |
| 7 | Fit | **PASS**: Ø10 (Ø10.5 with rim) ≤ the 14.5 spacing; ≤ 0.6 tall |
| 8 | Budget | **PASS**: ≤ 5 visible per active state (≤ 6 budget); 13 in template |
| 9 | Readability (phone, §4 lighting) | **PENDING**: style guide readability test (2): locked/empty/occupied distinguishable on phone at low brightness |
| 10 | UI | **PENDING**: billboards are code/UI-owned, not in this file |
| 11 | Physics hygiene | **PASS**: all anchored; CanCollide/CanTouch/CanQuery off; CastShadow off on parts < 1 stud³; no unions |
| 12 | Naming | **PASS**: every part uniquely named |
| 13 | Screenshot proof | **PENDING**: Studio screenshots by QA after import. Box previews exist but are not proof |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts, meshes or decals |
| 15 | Licence | **PASS**: self-built, project-owned |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (assumed slope runs down toward −Z; see BATCH-01), pivot flush on the real pad, Highlight limit (D8) before any outline, and pad billboard clearance.
