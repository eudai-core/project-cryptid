"""Project Cryptid placeholder silhouette kit (Parts only, box-side generator).
One stand-in = archetype body (winged | lurker | beast | serpent) + rarity trim band + rarity shape cue + crimson eye pair, 8-15 parts.
usage:
  python3 build_placeholder.py --name Jackalope --archetype beast --rarity uncommon --height 3 --length 4 --cryptid-id jackalope
  python3 build_placeholder.py --roster ../roster-provisional.md   # all roster rows
  python3 build_placeholder.py --samples          # 12 archetype x rarity samples + contact-sheet JSON
Output: art/models/placeholders/<Name>_PH.rbxmx  (Model name <Name>_PH, PrimaryPart Root, pivot at ground centre, front = -Z)
Attributes: CryptidId, AssetVersion "1.0", IsPlaceholder = true (bool), Archetype, Rarity, Scale."""
import argparse, os, sys, json, numpy as np
sys.path.insert(0, os.path.dirname(__file__))
from rbxlib import Asset, rx, ry, rz, seg, M
HERE=os.path.dirname(os.path.abspath(__file__)); OUT=os.path.join(HERE,"..","models","placeholders")
RARITY={"common":"BoneDim","uncommon":"Moss","rare":"Silver","epic":"Blood"}   # spec 01 A2 / spec 09 §2; Silver approved D11
ARCH=("winged","lurker","beast","serpent")
EYE=dict(color="Blood",mat="Glass")   # crimson, NOT Neon (D10 limits Neon eyes to Mothman)
def eyes(a,head,dx,dz,d=0.34):
    for t,sx in (("_R",1),("_L",-1)): a.add("Eye"+t,"Part",(d,d,d),head+[sx*dx,0.1,dz],shape="Ball",**EYE)
def extras(a,rarity,head_top,hx,band):
    """rarity = shape too (style guide §3), all in the trim colour:
       Common: band only | Uncommon: two swept-back ear tufts | Rare: single centre crest | Epic: crest + two tall horns"""
    if rarity=="uncommon":
        for t,sx in (("_R",1),("_L",-1)):
            a.add("Tuft"+t,"WedgePart",(0.22,0.55,0.75),head_top+[sx*hx*0.9,0.1,0.3],rz(sx*-20),color=band,mat="Limestone")
    if rarity in("rare","epic"): a.add("Crest","WedgePart",(0.25,0.7,1.0),head_top+[0,0.3,0.15],color=band,mat="Limestone")
    if rarity=="epic":
        for t,sx in (("_R",1),("_L",-1)):
            seg(a,"Horn"+t,head_top+[sx*hx,-0.1,0],head_top+[sx*(hx+0.45),0.85,0.35],0.18,color=band,mat="Limestone")
def winged(a,band,rarity):
    a.root((1.2,1.6,1),(0,2.3,0))
    a.add("Body","Part",(1.4,2.2,1.1),(0,2.3,0),rx(-8),color="Ash",mat="Fabric")
    head=np.array([0,3.85,-0.15]); a.add("Head","Part",(1.25,1.25,1.25),head,shape="Ball",color="Soot",mat="Fabric")
    for t,sx in (("_R",1),("_L",-1)):   # big V of wings = the read
        a.add("Wing"+t,"Part",(0.2,3.6,2.4),(sx*1.55,3.0,0.4),rz(sx*-28)@ry(sx*-12),color="Soot",mat="Fabric")
        seg(a,"Leg"+t,np.array([sx*0.35,1.3,0]),np.array([sx*0.5,0,-0.1]),0.28,color="Soot",mat="Fabric")
    a.add("Band","Part",(0.55,1.7,1.7),(0,3.2,-0.1),rz(90),shape="Cylinder",color=band,mat="Limestone")
    eyes(a,head,0.28,-0.5); extras(a,rarity,head+[0,0.5,0],0.35,band)
def lurker(a,band,rarity):
    a.root((1,2,1),(0,3,0))
    a.add("Pelvis","Part",(1.1,0.7,0.7),(0,3.0,0.1),color="Soot",mat="Slate")
    a.add("Torso","Part",(1.3,2.2,0.8),(0,4.4,-0.25),rx(-18),color="Soot",mat="Slate")
    head=np.array([0,5.85,-0.8]); a.add("Head","Part",(0.9,1.1,0.9),head,rx(-10),color="Soot",mat="Slate")
    for t,sx in (("_R",1),("_L",-1)):
        seg(a,"Arm"+t,np.array([sx*0.75,5.3,-0.45]),np.array([sx*1.05,2.1,-0.9]),0.3,color="Soot",mat="Slate")   # too-long arms
        seg(a,"Leg"+t,np.array([sx*0.35,2.8,0.1]),np.array([sx*0.55,0,0.2]),0.34,color="Soot",mat="Slate")
    a.add("Band","Part",(1.45,0.55,1.05),(0,3.45,0.05),color=band,mat="Limestone")
    eyes(a,head,0.2,-0.42,0.26); extras(a,rarity,head+[0,0.55,0],0.3,band)
def beast(a,band,rarity):
    a.root((2,1.2,3),(0,1.9,0))
    a.add("Body","Part",(2.0,1.5,3.6),(0,1.9,0.3),rx(4),color="Soot",mat="Slate")
    head=np.array([0,2.3,-2.05]); a.add("Head","Part",(1.5,1.2,1.4),head,color="Soot",mat="Slate")
    a.add("Jaw","WedgePart",(1.4,0.5,1.3),head+[0,-0.75,-0.15],ry(180),color="Ash",mat="Slate")
    for i,(x,z) in enumerate(((0.75,-1.1),(-0.75,-1.1),(0.75,1.5),(-0.75,1.5))):
        a.add(f"Leg{i+1}","Part",(0.5,1.3,0.55),(x,0.65,z),color="Soot",mat="Slate")
    seg(a,"Tail",np.array([0,2.2,2.05]),np.array([0,1.2,2.8]),0.32,color="Soot",mat="Slate")
    a.add("Band","Part",(2.3,1.75,0.6),(0,1.95,-1.0),color=band,mat="Limestone")
    eyes(a,head,0.42,-0.7); extras(a,rarity,head+[0,0.6,0],0.45,band)
def serpent(a,band,rarity):
    a.root((1,1,1),(0,0.6,0))
    pts=[np.array(p) for p in ((0.0,0.55,2.1),(0.9,0.55,1.1),(0.0,0.6,0.3),(-0.8,1.1,-0.6),(-0.3,2.7,-1.2))]
    th=[0.75,0.95,1.05,1.0,0.9]
    a.add("TailTip","WedgePart",(0.45,0.45,1.2),pts[0]+[0,-0.3,0.6],color="Soot",mat="Slate")
    for i in range(4): seg(a,f"Coil{i+1}",pts[i],pts[i+1],th[i],color="Soot",mat="Slate")   # S-curve rearing up = the read
    head=pts[4]+[0,0.5,-0.5]; a.add("Head","Part",(1.35,0.85,1.6),head,rx(10),color="Soot",mat="Slate")
    a.add("Band","Part",(0.5,1.3,1.3),(pts[2]+pts[3])/2,rz(90)@ry(45),shape="Cylinder",color=band,mat="Limestone")
    eyes(a,head,0.34,-0.55,0.28); extras(a,rarity,head+[0,0.4,0.1],0.3,band)
BUILD=dict(winged=winged,lurker=lurker,beast=beast,serpent=serpent)
def bbox(parts):
    vis=[p for p in parts if p["transp"]<1]
    lo=np.min([p["pos"]-np.abs(p["rot"])@(np.array(p["size"])/2) for p in vis],0); hi=np.max([p["pos"]+np.abs(p["rot"])@(np.array(p["size"])/2) for p in vis],0)
    return lo,hi
def make(name,archetype,rarity,scale,cid,write=True,height=None,length=None):
    """height/length (studs) = roster H x L; L = longest horizontal extent. Overrides --scale (non-uniform: Y vs XZ)."""
    assert archetype in ARCH and rarity in RARITY and 0.5<=scale<=2.0
    a=Asset(name+"_PH",{"CryptidId":cid,"AssetVersion":"1.0","IsPlaceholder":True,"Archetype":archetype,"Rarity":rarity,"Scale":f"{scale:g}"})
    BUILD[archetype](a,RARITY[rarity],rarity)
    def apply(S):
        for p in a.parts:
            A=S@np.array(p["rot"]); ln=np.linalg.norm(A,axis=0)          # stretched local axes
            U,_,Vt=np.linalg.svd(A/ln); Rn=U@Vt                           # nearest rotation
            if p["shape"]=="Ball": k=float(np.mean(ln)); sz=[v*k for v in p["size"]]   # Roblox balls stay round
            else: sz=[v*l for v,l in zip(p["size"],ln)]
            p["pos"]=S@np.array(p["pos"]); p["rot"]=Rn; p["size"]=sz
        a.pivot_y*=S[1,1]
    if height or length:
        tot=np.ones(2)
        for _ in range(4):                       # iterate: rotated parts make the bbox respond non-linearly
            lo,hi=bbox(a.parts); e=hi-lo
            sh=(length/max(e[0],e[2])) if length else (height/e[1]); sv=(height/e[1]) if height else sh
            apply(np.diag([sh,sv,sh])); tot*=[sh,sv]
        a.attrs["Scale"]=f"{tot[0]:.2f}x{tot[1]:.2f}"
    else: apply(np.diag([scale]*3))
    for p in a.parts: p["shadow"]=p["transp"]<1 and float(np.prod(p["size"]))>=1
    lo,hi=bbox(a.parts)
    ext=hi-lo; n=len(a.parts)
    root=next(p for p in a.parts if p["name"]=="Root"); c=(lo+hi)/2; root["pos"]=np.array([c[0],root["pos"][1],c[2]])   # pivot under footprint centre
    warn=[w for w,c in (("over 8x8 footprint",max(ext[0],ext[2])>8.05),("Common over 6x6",rarity=="common" and max(ext[0],ext[2])>6.05),("over 10 tall",ext[1]>10.05),("not 8-15 parts",not 8<=n<=15)) if c]
    if write:
        os.makedirs(OUT,exist_ok=True); a.write(os.path.join(OUT,name+"_PH.rbxmx"),os.path.join(OUT,name+"_PH.parts.json"))
        print(f"   size {ext.round(1)}  {'WARN: '+', '.join(warn) if warn else 'fit OK'}")
    return a
if __name__=="__main__":
    ap=argparse.ArgumentParser(); ap.add_argument("--name"); ap.add_argument("--archetype",choices=ARCH); ap.add_argument("--rarity",choices=list(RARITY))
    ap.add_argument("--scale",type=float,default=1.0); ap.add_argument("--cryptid-id"); ap.add_argument("--samples",action="store_true")
    ap.add_argument("--height",type=float); ap.add_argument("--length",type=float); ap.add_argument("--roster",help="markdown roster table (art/roster-provisional.md)")
    g=ap.parse_args()
    if g.roster:
        BODY={"winged":"winged","biped":"lurker","quadruped":"beast","serpent":"serpent"}
        sheet={"name":"Provisional launch roster: placeholders at roster H x L","sets":[],"parts":[]}
        for line in open(g.roster):
            c=[x.strip().strip("`") for x in line.strip().strip("|").split("|")]
            if len(c)<6 or not c[0].isdigit(): continue
            nm="".join(w.capitalize() for w in c[2].split("_")); H,L=[float(v) for v in c[5].lower().replace(" ","").split("x")[:2]]
            a=make(nm,BODY[c[4].lower()],c[3].lower(),1.0,c[2],height=H,length=L)
            sheet["sets"].append({"label":f"{c[0]}. {c[1]} ({c[3]}, {len(a.parts)}p, {H:g}x{L:g})","groups":[nm]})
            for p in a.parts: sheet["parts"].append(dict(p,name=nm+"."+p["name"],group=nm,pos=np.array(p["pos"]).tolist(),rot=np.array(p["rot"]).tolist()))
        json.dump(sheet,open(os.path.join(OUT,"_roster_sheet.parts.json"),"w")); sys.exit()
    if not g.samples:
        if not(g.name and g.archetype and g.rarity and g.cryptid_id): ap.error("--name --archetype --rarity --cryptid-id required")
        make(g.name,g.archetype,g.rarity,g.scale,g.cryptid_id,height=g.height,length=g.length); sys.exit()
    OUT=os.path.join(OUT,"samples")   # keep samples out of the Rojo-mapped placeholders folder
    sheet={"name":"Placeholder kit: 4 archetypes x 4 rarities (scale 1.0)","sets":[],"parts":[]}
    for arch in ARCH:
        for r in RARITY:
            nm=f"Sample{arch.capitalize()}{r.capitalize()}"
            a=make(nm,arch,r,1.0,f"placeholder_{arch}_{r}")
            sheet["sets"].append({"label":f"{arch} / {r} ({len(a.parts)} parts)","groups":[nm]})
            for p in a.parts: sheet["parts"].append(dict(p,name=nm+"."+p["name"],group=nm,pos=p["pos"].tolist(),rot=np.array(p["rot"]).tolist()))
    json.dump(sheet,open(os.path.join(OUT,"_contact_sheet.parts.json"),"w"))
