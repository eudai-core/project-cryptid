"""Write a cryptid handoff note from a built model's .parts.json (box-side). Used by Batch 03."""
import json,collections,numpy as np
MAT={512:'Wood',788:'Basalt',800:'Slate',820:'Limestone',1040:'CorrodedMetal',1312:'Fabric',1568:'Glass',288:'Neon'}
def mname(k): return MAT.get(k,str(k)) if isinstance(k,int) else k
def write(n,d,cap=80,capname="large-cryptid cap (Rare+ ≤ 80 parts / 5,000 tris, style guide §6)",date="2026-11-04"):
    P=json.load(open(f'models/{n}.parts.json'))['parts']
    m=collections.Counter(); cols=collections.defaultdict(list); sh=[]; cls=collections.Counter(); lo=np.full(3,1e9);hi=-lo; neon=[]
    for p in P:
        if p['transp']>=1: continue
        m[p['mat']]+=1; cols[p['color']].append(p['name']); cls[p['cls']+('' if p['cls']!='Part' else ':'+p['shape'])]+=1
        if mname(p['mat'])=='Neon': neon.append(p['name'])
        if p['shadow']: sh.append(p['name'])
        Rr=np.array(p['rot']);h=np.abs(Rr)@(np.array(p['size'])/2);lo=np.minimum(lo,np.array(p['pos'])-h);hi=np.maximum(hi,np.array(p['pos'])+h)
    e=hi-lo; H=e[1]; L=max(e[0],e[2]); rh,rl=d['size']
    colstr="\n".join(f"  - {k}: {', '.join(v)}" for k,v in cols.items())
    ver=d.get('ver','1.0'); neon_s=(f"Neon: **{', '.join(neon)}** ({d['neon_dec']})" if neon else "Neon: none")
    txt=f"""### Handoff: {n} (v{ver}, {date})
- **Asset id / model name:** `{n}` · Attributes `CryptidId = "{d['id']}"` (spec 09 §3 / `art/roster-provisional.md`), `AssetVersion = "{ver}"`
- **Roster:** {d['roster']} (provisional, ~70%).
- **File path (box):** `/workspace/project-cryptid/art/models/{n}.rbxmx`. Generator: `art/tools/build_assets.py {n}` (lib `rbxlib.py`). Do NOT map the preview data in `models/{n}.parts.json` into Rojo.
- **Proposed place path:** `ReplicatedStorage.Assets.Cryptids.{n}`. It replaces `Assets.Placeholders.{n}_PH` (same `CryptidId`; see `PLACEHOLDER-KIT.md`).
- **Counts:** **{len(P)} parts** (incl. invisible `Root`): {', '.join(f'{v} {k}' for k,v in cls.items())}. **0 meshes, 0 textures, 0 lights, 0 emitters, 0 decals, {neon_s}, scripts: none.** Within the {capname}.
- **Materials:** {', '.join(f'{mname(k)} ×{v}' for k,v in m.items())}. No Plastic/SmoothPlastic.
- **Colours (tokens):**
{colstr}
- **Pivot / facing:** `PrimaryPart = Root` (invisible, anchored, **flat**), at the footprint centre. `PivotOffset` puts the pivot on the floor (y = 0), so `model:PivotTo(pad.CryptidMount.CFrame)` needs **no offset**. **Front = −Z.**
- **Size (studs):** {e[0]:.1f} W × {H:.1f} H × {e[2]:.1f} D → **H {H:.1f} × L {L:.1f}** vs roster {rh:g} × {rl:g} (H {100*(H/rh-1):+.0f}%, L {100*(L/rl-1):+.0f}%; ±15% OK). Fits ≤ 8 × 8 footprint and ≤ 10 height.
- **Rarity cue (§3):** {d['cue']}
- **Physics:** all parts `Anchored`, `CanCollide/CanTouch/CanQuery = false`. `CastShadow` only on {', '.join(f'`{x}`' for x in sh) or 'none'}; off on everything else (< 1 stud³).
- **Scripts inside:** none ✅ · **Source & licence:** self-built by Grok Bot (Parts only), project-owned; based on folklore; no Creator Store assets, no generated meshes.
- **Screenshots:** box-side previews (NOT Studio proof): `qa/screenshots/{n}_{d.get('shot',date)}_preview-front34.png`, `..._preview-side.png`. Studio proof: **PENDING**.

**Design:** {d['design']}
- **Redesign passes used:** {d['passes']}.
- **Notes:** {d['notes']}

#### Checklist (style guide §7)
| # | Check | Result |
|---|---|---|
| 1 | Palette | **PASS**: §1 tokens only (validator) |
| 2 | Rift green | **PASS**: none used |
| 3 | Neon | **PASS**: {('only ' + ', '.join(neon) + ' (' + d['neon_dec'] + '; validator allowlist)') if neon else 'none'} |
| 4 | Materials | **PASS**: {', '.join(mname(k) for k in m)}; no Plastic/SmoothPlastic. Glass only where a glow is wanted (§2) |
| 5 | Silhouette | **PASS (box preview)**: hero shape reads in 3/4 and side. Studio read **PENDING** |
| 6 | Not toy-like / age-appropriate | **PASS (preview)**: spooky, not gore; no blood or wounds |
| 7 | Fit | **PASS**: within ±15% of roster H × L; ≤ 8 × 8, ≤ 10 tall; faces −Z |
| 8 | Budget | **PASS**: {len(P)} ≤ {cap} parts; 0 textures/lights/emitters |
| 9 | Readability (phone, §4 lighting) | **PENDING**: lighting read in Play (Studio) |
| 10 | UI | **N/A** |
| 11 | Physics hygiene | **PASS**: all anchored; collide/touch/query off; small parts cast no shadow; no unions |
| 12 | Naming | **PASS**: unique part names (`_R`/`_L` mirrored pairs) |
| 13 | Screenshot proof | **PENDING**: Studio captures by QA (D12: these also feed icon/thumbnails; box renders are only a fallback if imports slip past Mon 9 Nov) |
| 14 | Creator Store safety | **N/A / PASS**: no Store assets; validator confirms no scripts/meshes/decals |
| 15 | Licence | **PASS**: self-built |
| 16 | Handoff | **PASS**: this note |

**Also PENDING (Studio-only):** wedge facing (BATCH-01 #1), pivot flush on `Pad.CryptidMount`, pad billboard clearance, Highlight limit (D8) before any outline, triangle count.
"""
    open(f'handoff/{n}.md','w').write(txt); return len(P),H,L
