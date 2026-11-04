"""Batch builder: python3 build_assets.py [Name ...]. Outputs art/models/<Name>.rbxmx + .parts.json"""
import os, sys, math, numpy as np
sys.path.insert(0, __file__.rsplit("/",1)[0])
from rbxlib import *
HERE=os.path.dirname(os.path.abspath(__file__))
MODELS=os.path.join(HERE,"..","models")

# ------------------------------------------------------------------ Mothman Hatchling v0.2
def mothman():
    a=Asset("MothmanHatchling",{"CryptidId":"mothman_hatchling","AssetVersion":"0.2"})
    hunch=R(x=-18)
    a.root((1.6,2.0,1.4),(0,1.9,0.15))                      # v0.2: Root flat, pivot at feet
    a.add("Torso","Part",(1.4,1.9,1.2),(0,1.85,0.2),hunch,"Ash","Fabric")
    a.add("Belly","Part",(0.9,1.1,0.25),(0,1.6,-0.45),hunch,"Soot","Fabric")
    a.add("FurRuff","Part",(1.4,0.6,0.6),(0,2.55,-0.35),R(x=-25),"BoneDim","Fabric")
    a.add("Head","Part",(1.3,1.3,1.3),(0,3.05,-0.55),None,"Soot","Fabric",shape="Ball")
    for sx,t in ((1,"_R"),(-1,"_L")):
        a.add("Eye"+t,"Part",(0.56,0.56,0.56),(sx*0.32,3.12,-1.08),None,"Blood","Neon",shape="Ball")  # D10
        a.add("EyeGlint"+t,"Part",(0.15,0.15,0.15),(sx*0.38,3.26,-1.33),None,"Bone","Limestone",shape="Ball")
    for sx,t in ((1,"_R"),(-1,"_L")):
        base=np.array([sx*0.3,3.6,-0.8]); tilt=R(x=-20,z=-sx*38); up=tilt@np.array([0,1,0]); L=1.25
        a.add("AntennaStalk"+t,"Part",(L,0.1,0.1),base+up*L/2,tilt@rz(90),"BoneDim","Fabric",shape="Cylinder")
        for i,(off,s) in enumerate(((0.45,0.55),(0.8,0.42))):
            a.add(f"AntennaFrond{i+1}"+t,"Part",(0.05,s,s*0.55),base+up*L*off,tilt@rx(45),"BoneDim","Fabric")
    for sx,t in ((1,"_R"),(-1,"_L")):
        a.add("Leg"+t,"Part",(0.7,0.28,0.28),(sx*0.38,0.45,0.0),rz(90),"Soot","Fabric",shape="Cylinder")
        a.add("Claw"+t,"WedgePart",(0.34,0.22,0.5),(sx*0.38,0.11,-0.3),None,"Bone","Limestone")
    H,D=4.2,2.3; wingR=R(y=-16,z=-12); wpos=np.array([1.0,2.5,0.45])
    def w(name,cls,size,lpos,lrot=np.eye(3),**kw): a.add(name+"_R",cls,size,wpos+wingR@np.array(lpos,float),wingR@lrot,**kw)
    n0=len(a.parts)
    w("Wing","WedgePart",(0.14,H,D),(0,0,0),R(y=180),color="Soot",mat="Fabric")
    def vein(name,z0,y0,z1,y1,wd=0.09):
        L=math.hypot(z1-z0,y1-y0); ang=math.degrees(math.atan2(y1-y0,z1-z0))
        w(name,"Part",(0.16,wd,L),(0.03,(y0+y1)/2,(z0+z1)/2),rx(ang),color="BoneDim",mat="Fabric")
    vein("WingVein1",-1.02,1.5,-0.95,-1.95,0.11); vein("WingVein2",-0.9,-0.75,0.55,-1.95)
    w("WingEyespotRing","Part",(0.04,0.85,0.85),(0.11,-0.05,-0.5),color="BoneDim",mat="Fabric",shape="Cylinder")
    w("WingEyespot","Part",(0.05,0.6,0.6),(0.14,-0.05,-0.5),color="Blood",mat="Fabric",shape="Cylinder")
    slope=math.degrees(math.atan2(H,D))
    for i,(t,s) in enumerate(((0.3,0.55),(0.55,0.42),(0.8,0.6))):
        w(f"WingTatter{i+1}","Part",(0.12,s,s),(0,H/2-H*t,-D/2+D*t),rx(45-(90-slope)),color="Soot",mat="Fabric")
    a.mirror_from(n0)
    a.add("EggShard1","WedgePart",(0.9,0.55,0.6),(0.75,0.27,-0.85),ry(35),"Bone","Limestone")
    a.add("EggShard2","WedgePart",(0.7,0.4,0.5),(-0.85,0.2,-0.65),ry(-150)@rx(8),"BoneDim","Limestone")
    for p in a.parts:
        if p["pos"][1]<0.05: p["pos"][1]=0.05
    return a

# ------------------------------------------------------------------ Pad (4 states + affordable border)
def pad():
    a=Asset("Pad",{"AssetId":"Pad","AssetVersion":"1.0","States":"Occupied,Empty,Locked,Sealed"})
    a.root((2,0.4,2),(0,0.2,0))
    cyl=rz(90)                                   # cylinder axis -> world Y
    a.add("Ring","Part",(0.4,10,10),(0,0.2,0),cyl,"Gold","CorrodedMetal",shape="Cylinder")
    a.add("Centre","Part",(0.46,8.6,8.6),(0,0.23,0),cyl,"Soot","Slate",shape="Cylinder")
    a.add("CryptidMount","Part",(1,0.1,1),(0,0.51,0),None,"Ash","Fabric",transp=1.0,shadow=False)  # cryptid:PivotTo(this)
    top=0.47
    for g,st in (("State_Occupied","Occupied"),("State_Empty","Empty"),("State_Locked","Locked"),("State_Sealed","Sealed"),("Mod_Affordable","Affordable")):
        a.group(g,{"State":st})
    # Occupied: a bright gold band between ring and centre ("the circle is bound")
    a.add("BoundBand","Part",(0.44,9.15,9.15),(0,0.22,0),cyl,"GoldBright","CorrodedMetal",shape="Cylinder",group="State_Occupied")
    # Empty: faint chalk sigil (X rune)
    for i,ang in enumerate((40,-40)):
        a.add(f"Sigil{i+1}","Part",(0.4,0.04,6.2),(0,top,0),ry(ang),"BoneDim","Limestone",transp=0.55,group="State_Empty")
    # Locked: solid sigil (spec 01 B5: BoneDim sigil); price text is a Billboard/SurfaceGui (code)
    for i,ang in enumerate((40,-40)):
        a.add(f"LockSigil{i+1}","Part",(0.45,0.05,6.2),(0,top,0),ry(ang),"BoneDim","Limestone",group="State_Locked")
    # Affordable modifier: Blood border (spec 01 B5), used together with State_Locked
    a.add("AffordableBorder","Part",(0.3,10.5,10.5),(0,0.15,0),cyl,"Blood","Fabric",shape="Cylinder",group="Mod_Affordable")
    # Sealed: cracked sigil (spec 02 §3), three broken shards
    for i,(L,ang,off) in enumerate(((3.0,40,(-1.1,0,-1.2)),(2.4,-48,(1.3,0,-0.9)),(2.6,25,(0.6,0,1.6)))):
        a.add(f"CrackedSigil{i+1}","Part",(0.4,0.05,L),(off[0],top,off[2]),ry(ang),"BoneDim","Limestone",group="State_Sealed")
    a.sets=[{"label":"Occupied","groups":[None,"State_Occupied"]},{"label":"Empty","groups":[None,"State_Empty"]},
            {"label":"Locked","groups":[None,"State_Locked"]},{"label":"Locked + Affordable","groups":[None,"State_Locked","Mod_Affordable"]},
            {"label":"Sealed","groups":[None,"State_Sealed"]}]
    return a

# ------------------------------------------------------------------ Bone Altar (L0 base + Tier1 + Tier2)
def bone_altar():
    a=Asset("BoneAltar",{"AssetId":"boneAltar","AssetVersion":"1.0","MaxTier":"2"})
    a.root((4,2,4),(0,1,0))
    cyl=rz(90)
    a.add("Step1","Part",(0.8,14,14),(0,0.4,0),cyl,"Soot","Basalt",shape="Cylinder")
    a.add("Step2","Part",(0.8,10.5,10.5),(0,1.2,0),cyl,"Soot","Slate",shape="Cylinder")
    a.add("Plinth","Part",(4.5,2.6,4.5),(0,2.9,0),ry(45),"Soot","Basalt")
    a.add("TopTrim","Part",(5.2,0.35,5.2),(0,4.375,0),ry(45),"Gold","CorrodedMetal")
    for i in range(4):
        th=math.radians(45+90*i); x,z=4.3*math.sin(th),4.3*math.cos(th)
        a.add(f"Candle{i+1}","Part",(1.2,0.45,0.45),(x,2.2,z),cyl,"Bone","Limestone",shape="Cylinder")
        a.add(f"Flame{i+1}","Part",(0.3,0.3,0.3),(x,2.95,z),None,"GoldBright","Glass",shape="Ball")
    a.add("FillLightMount","Part",(0.5,0.5,0.5),(0,9.0,0),None,"Ash","Fabric",transp=1.0,shadow=False)
    T=4.55
    a.group("Tier1",{"Tier":"1"}); a.group("Tier2",{"Tier":"2"})
    # Tier 1 (Bone Altar I): crown of ribs + a skull facing the front (-Z)
    for i in range(6):
        th=math.radians(30+60*i); d=np.array([math.sin(th),0,math.cos(th)])
        tip=d*2.6+np.array([0,T+2.0,0]); base=d*1.5+np.array([0,T,0])
        a.add(f"CrownRib{i+1}","Part",(np.linalg.norm(tip-base),0.32,0.32),(tip+base)/2,axis_to(tip-base),"Bone","Limestone",shape="Cylinder",group="Tier1")
    a.add("Skull","Part",(1.15,1.15,1.15),(0,T+0.55,-1.25),None,"Bone","Limestone",shape="Ball",group="Tier1")
    a.add("SkullJaw","Part",(0.8,0.3,0.55),(0,T+0.12,-1.6),None,"BoneDim","Limestone",group="Tier1")
    for sx,t in ((1,"_R"),(-1,"_L")):
        a.add("SkullSocket"+t,"Part",(0.3,0.3,0.3),(sx*0.22,T+0.65,-1.75),None,"Void","Basalt",shape="Ball",group="Tier1")
    for i,ang in enumerate((35,-35)):
        a.add(f"CrossBone{i+1}","Part",(2.6,0.3,0.3),(0,2.55,-3.45),rz(ang),"BoneDim","Limestone",shape="Cylinder",group="Tier1")
    # Tier 2 (Bone Altar II): vertebra spire + rib cage + horned crown skull
    ys=[T+0.45,T+1.35,T+2.2,T+3.0]; ds=[0.95,0.85,0.72,0.6]
    for i,(y,dd) in enumerate(zip(ys,ds)):
        a.add(f"Vertebra{i+1}","Part",(0.75,dd,dd),(0,y,0.2),cyl,"Bone" if i%2==0 else "BoneDim","Limestone",shape="Cylinder",group="Tier2")
    for i in range(6):
        th=math.radians(60*i); d=np.array([math.sin(th),0,math.cos(th)])
        base=d*1.3+np.array([0,T+0.2,0.2]); tip=d*0.35+np.array([0,T+3.3,0.2])
        mid=(base+tip)/2+d*0.6
        a.add(f"CageRib{i+1}","Part",(np.linalg.norm(tip-base)+0.3,0.22,0.22),mid,axis_to(tip-base),"BoneDim","Limestone",shape="Cylinder",group="Tier2")
    a.add("CrownSkull","Part",(0.9,0.9,0.9),(0,T+3.85,0.1),None,"Bone","Limestone",shape="Ball",group="Tier2")
    for sx,t in ((1,"_R"),(-1,"_L")):
        a.add("CrownHorn"+t,"WedgePart",(0.25,1.3,0.6),(sx*0.55,T+4.6,0.25),rz(-sx*25),"Bone","Limestone",group="Tier2")
    a.sets=[{"label":"Level 0","groups":[None]},{"label":"Level I (Tier1)","groups":[None,"Tier1"]},
            {"label":"Level II (Tier1+Tier2)","groups":[None,"Tier1","Tier2"]}]
    return a

# ------------------------------------------------------------------ Fresno Nightcrawler (<=15)
def fresno():
    a=Asset("FresnoNightcrawler",{"CryptidId":"fresno_nightcrawler","AssetVersion":"1.0"})
    a.root((1.4,2,1),(0,3,0))
    a.add("Waist","Part",(1.7,0.9,1.0),(0,4.7,0),None,"Bone","Fabric")
    a.add("Bulb","Part",(1.35,1.35,1.35),(0,5.45,-0.05),None,"Bone","Limestone",shape="Ball")
    for sx,t in ((1,"_R"),(-1,"_L")):
        a.add("EyePit"+t,"Part",(0.24,0.24,0.24),(sx*0.24,5.55,-0.66),None,"Void","Basalt",shape="Ball")
    legs={"_R":[(0.45,4.4,0),(0.52,2.45,-0.75),(0.5,0.45,-1.1)], "_L":[(-0.45,4.4,0),(-0.52,2.4,0.35),(-0.5,0.6,1.05)]}
    for t,(hip,knee,ank) in legs.items():
        seg(a,"Thigh"+t,hip,knee,0.62,color="Bone",mat="Fabric")
        seg(a,"Shin"+t,knee,ank,0.5,color="Bone",mat="Fabric")
        a.add("Knee"+t,"Part",(0.6,0.6,0.6),knee,None,"BoneDim","Limestone",shape="Ball")
        a.add("Anklet"+t,"Part",(0.25,0.62,0.62),(ank[0],ank[1]+0.05,ank[2]),rz(90),"Soot","Fabric",shape="Cylinder")
        tilt=rx(-25) if t=="_L" else np.eye(3)
        a.add("Foot"+t,"WedgePart",(0.55,0.4,1.0),(ank[0],max(0.2,ank[1]-0.25),ank[2]-0.3),tilt,"BoneDim","Limestone")
    return a

# ------------------------------------------------------------------ Hidebehind (<=35)
def hidebehind():
    a=Asset("Hidebehind",{"CryptidId":"hidebehind","AssetVersion":"1.0"})
    a.root((1.2,3,1),(-0.42,4.5,-0.58))   # pivot under footprint centre (x flips in the mirror pass)
    cyl=rz(90); sc=np.array([-0.2,0,-1.0])                # stump centre (front of the creature)
    a.add("Stump","Part",(6.2,3.0,3.0),sc+[0,3.0,0],cyl,"BoneDim","Wood",shape="Cylinder")
    a.add("StumpJag1","WedgePart",(1.0,1.4,1.2),sc+[-0.4,6.7,0.1],ry(70),"BoneDim","Wood")
    a.add("StumpJag2","WedgePart",(0.8,0.9,1.0),sc+[0.5,6.45,-0.3],ry(-130),"BoneDim","Wood")
    a.add("StumpRoot1","WedgePart",(0.7,0.8,1.4),sc+[-1.3,0.4,-0.6],ry(-120),"BoneDim","Wood")
    a.add("StumpRoot2","WedgePart",(0.7,0.7,1.3),sc+[0.6,0.35,-1.4],ry(160),"BoneDim","Wood")
    seg(a,"DeadBranch",sc+[-1.0,4.6,0],sc+[-2.6,5.6,-0.3],0.32,color="BoneDim",mat="Wood")
    sk=dict(color="Soot",mat="Slate")
    pelvis=np.array([0.45,4.0,1.15]); sh=np.array([0.25,6.8,0.85])
    a.add("Pelvis","Part",(1.0,0.7,0.7),pelvis,None,**sk)
    seg(a,"Torso",pelvis+[0,0.2,0],sh,(1.0,0.7),**sk)
    head=np.array([1.45,7.3,-0.75])
    seg(a,"Neck",sh+[0.2,0.1,0],head+[-0.1,-0.4,0.2],0.28,**sk)
    a.add("Head","Part",(0.7,1.3,0.8),head,R(z=-15,x=-10),**sk)
    for i,dx in enumerate((-0.15,0.17)):
        a.add(f"EyeGlint{i+1}","Part",(0.24,0.24,0.24),head+[dx,0.2,-0.42],None,"Bone","Limestone",shape="Ball")
    # right arm wraps the right side of the stump
    sR=np.array([0.75,6.75,0.8]); eR=np.array([1.9,5.9,0.1]); hR=np.array([1.35,5.4,-1.5])
    seg(a,"ArmUpper_R",sR,eR,0.26,**sk); seg(a,"ArmFore_R",eR,hR,0.22,**sk)
    for i,dy in enumerate((0.25,0,-0.25)):
        seg(a,f"Finger{i+1}_R",hR+[0,dy,0],hR+[-0.45,dy-0.1,-0.75],0.11,color="BoneDim",mat="Limestone")
    # left arm reaches over the top, fingers hang down the front
    sL=np.array([-0.25,6.85,0.85]); eL=np.array([-0.7,7.6,0.1]); hL=np.array([-0.9,6.4,-2.3])
    seg(a,"ArmUpper_L",sL,eL,0.26,**sk); seg(a,"ArmFore_L",eL,hL,0.22,**sk)
    for i,dx in enumerate((-0.28,0,0.28)):
        seg(a,f"Finger{i+1}_L",hL+[dx,0,0],hL+[dx*1.3,-0.9-0.15*(i%2),-0.35],0.11,color="BoneDim",mat="Limestone")
    for t,(hip,knee,ft) in {"_R":((0.75,3.8,1.15),(1.0,2.0,0.75),(0.9,0.1,1.4)),"_L":((0.15,3.8,1.15),(-0.1,2.0,1.8),(0.0,0.1,1.3))}.items():
        seg(a,"Thigh"+t,hip,knee,0.3,**sk); seg(a,"Shin"+t,knee,ft,0.26,**sk)
    # pass 2: mirror so the creature peeks out on the side away from the default 3/4 camera
    for p in a.parts: p["pos"]=M@p["pos"]; p["rot"]=M@p["rot"]@M
    for p in a.parts:
        n=p["name"]; p["name"]=n.replace("_R","_X").replace("_L","_R").replace("_X","_L")
    return a

# ------------------------------------------------------------------ Hodag (<=40)
def hodag():
    a=Asset("Hodag",{"CryptidId":"hodag","AssetVersion":"1.0"})
    a.root((3,2,4),(0,1.8,0.3))
    hide=dict(color="Soot",mat="Slate"); bone=dict(color="Bone",mat="Limestone")
    a.add("Body","Part",(3.6,2.0,4.6),(0,2.0,0.4),None,**hide)
    a.add("Shoulders","Part",(4.0,2.3,1.9),(0,2.35,-1.55),rx(-8),**hide)
    a.add("Skull","Part",(3.2,1.3,2.2),(0,2.6,-3.25),rx(6),**hide)
    a.add("Jaw","Part",(3.0,0.55,2.2),(0,1.3,-3.35),rx(-10),**hide)
    a.add("Maw","Part",(2.8,0.8,1.9),(0,1.9,-3.2),None,"Blood","Fabric")
    for i,x in enumerate((-1.15,-0.58,0,0.58,1.15)):
        a.add(f"Tooth{i+1}","WedgePart",(0.32,0.5,0.28),(x,1.78,-4.18),rz(180),**bone)
    for sx,t in ((1,"_R"),(-1,"_L")):
        a.add("Tusk"+t,"WedgePart",(0.3,0.7,0.3),(sx*1.3,1.85,-4.15),None,**bone)
        a.add("Eye"+t,"Part",(0.55,0.55,0.55),(sx*1.0,3.05,-4.2),None,"GoldBright","Glass",shape="Ball")
        a.add("Brow"+t,"WedgePart",(0.9,0.35,0.6),(sx*1.0,3.4,-4.0),None,**hide)
        hb=np.array([sx*1.1,3.2,-3.0]); ht=np.array([sx*1.9,4.6,-2.5])
        a.add("Horn"+t,"Part",(np.linalg.norm(ht-hb),0.42,0.42),(hb+ht)/2,axis_to(ht-hb),shape="Cylinder",**bone)
    for i,(z,h) in enumerate(((-1.9,1.3),(-1.0,1.55),(-0.1,1.45),(0.8,1.25),(1.6,1.0),(2.3,0.8))):
        ybase=3.0 if i<2 else 3.0
        a.add(f"Spike{i+1}","WedgePart",(0.35,h,0.9),(0,ybase+h/2,z),None,**bone)
    seg(a,"Tail",(0,2.1,2.6),(0,2.7,4.3),(1.0,0.8),**hide)
    a.add("TailSpike","WedgePart",(0.35,0.7,0.9),(0,3.0,4.1),None,**bone)
    for i,(x,z) in enumerate(((1.5,-1.7),(-1.5,-1.7),(1.5,1.9),(-1.5,1.9))):
        a.add(f"Leg{i+1}","Part",(0.95,1.4,0.95),(x,0.7,z),None,**hide)
        a.add(f"Claw{i+1}","WedgePart",(0.95,0.3,0.6),(x,0.15,z-0.7),None,**bone)
    # fit pass: style guide says Common footprint <= 6x6; scale the whole beast to 2/3 (ground stays at y=0)
    k=2/3
    for p in a.parts: p["pos"]=np.array(p["pos"])*k; p["size"]=tuple(np.array(p["size"])*k)
    a.pivot_y*=k
    for p in a.parts: p["shadow"]=bool(p["shadow"]) and float(np.prod(p["size"]))>=1
    return a

# ================================================================== Batch 02: Uncommons (<=40 parts, small-cryptid cap)
def jackalope():   # roster 3 H x 4 L; antlered hare
    a=Asset("Jackalope",{"CryptidId":"jackalope","AssetVersion":"1.0"})
    fur=dict(color="Soot",mat="Fabric"); pale=dict(color="BoneDim",mat="Fabric"); bone=dict(color="Bone",mat="Limestone")
    a.root((1.2,1,1.2),(0,1.0,0.1))
    a.add("Body","Part",(1.5,1.4,2.2),(0,1.15,0.35),rx(-15),**fur)
    a.add("Chest","Part",(1.25,1.25,1.25),(0,1.4,-0.6),shape="Ball",**pale)
    a.add("Head","Part",(0.95,0.85,1.1),(0,2.0,-1.15),rx(10),**fur)
    a.add("Snout","Part",(0.6,0.5,0.45),(0,1.85,-1.75),**pale)
    a.add("Tail","Part",(0.55,0.55,0.55),(0,1.05,1.55),shape="Ball",**bone)
    st=len(a.parts)
    a.add("Haunch_R","Part",(1.3,1.3,1.3),(0.55,0.85,0.85),shape="Ball",**fur)
    a.add("Eye_R","Part",(0.22,0.22,0.22),(0.42,2.12,-1.4),shape="Ball",color="Blood",mat="Glass")
    seg(a,"Ear_R",(0.25,2.35,-0.95),(0.5,2.75,-0.05),(0.3,0.1),**fur)
    for nm,p,q in (("AntlerBeam_R",(0.22,2.4,-1.2),(0.85,2.82,-1.25)),("AntlerTine1_R",(0.52,2.6,-1.22),(0.62,2.97,-1.4)),
                   ("AntlerTine2_R",(0.85,2.82,-1.25),(1.0,2.97,-0.95)),("AntlerTine3_R",(0.85,2.82,-1.25),(1.15,2.78,-1.55))):
        seg(a,nm,p,q,0.13,**bone)
    seg(a,"Foreleg_R",(0.35,1.0,-0.65),(0.33,0.12,-0.85),0.26,**fur)
    a.add("Forepaw_R","Part",(0.3,0.15,0.4),(0.33,0.075,-0.95),**pale)
    a.add("HindFoot_R","Part",(0.4,0.25,1.3),(0.6,0.125,0.5),**fur)
    a.mirror_from(st)
    return a

def dover_demon():   # roster 4 H x 3 L; melon head, thin limbs, glowing eyes
    a=Asset("DoverDemon",{"CryptidId":"dover_demon","AssetVersion":"1.0"})
    skin=dict(color="BoneDim",mat="Fabric")
    a.root((1,1,0.8),(0,1.6,0))
    a.add("Head","Part",(1.7,1.7,1.7),(0,3.1,-0.1),shape="Ball",color="BoneDim",mat="Limestone")
    a.add("HeadBack","Part",(1.5,1.5,1.5),(0,3.3,0.35),shape="Ball",color="BoneDim",mat="Limestone")
    seg(a,"Neck",(0,1.95,0.05),(0,2.45,-0.05),0.18,**skin)
    a.add("Torso","Part",(0.6,0.9,0.4),(0,1.55,0.05),**skin)
    a.add("Pelvis","Part",(0.5,0.3,0.35),(0,1.05,0.05),**skin)
    st=len(a.parts)
    a.add("Eye_R","Part",(0.46,0.46,0.46),(0.38,3.05,-0.8),shape="Ball",color="GoldBright",mat="Glass")
    seg(a,"ArmUpper_R",(0.35,1.95,0.05),(0.85,1.35,-0.2),0.14,**skin)
    seg(a,"ArmFore_R",(0.85,1.35,-0.2),(1.2,0.7,-0.4),0.12,**skin)
    for i,(dx,dz) in enumerate(((0.05,-0.2),(0.2,-0.05),(0.12,0.15))):
        seg(a,f"Finger{i+1}_R",(1.2,0.7,-0.4),(1.2+dx,0.25,-0.4+dz),0.06,**skin)
    seg(a,"Thigh_R",(0.18,1.1,0.05),(0.45,0.62,-0.3),0.15,**skin)
    seg(a,"Shin_R",(0.45,0.62,-0.3),(0.4,0.08,0.05),0.13,**skin)
    a.add("Foot_R","Part",(0.22,0.08,0.6),(0.4,0.04,-0.12),**skin)
    a.mirror_from(st)
    return a

def snallygaster():   # roster 5 H x 7 L; winged reptile-bird, one eye, metal beak, tentacle hints
    a=Asset("Snallygaster",{"CryptidId":"snallygaster","AssetVersion":"1.0"})
    hide=dict(color="Soot",mat="Slate"); memb=dict(color="Ash",mat="Fabric"); strut=dict(color="BoneDim",mat="Limestone")
    a.root((1.5,1,2),(0,2.4,-0.7))   # footprint centre
    a.add("Body","Part",(1.6,1.4,2.6),(0,2.5,0.2),rx(-10),**hide)
    a.add("Chest","Part",(1.6,1.6,1.6),(0,2.7,-0.9),shape="Ball",**hide)
    seg(a,"Neck",(0,3.0,-1.3),(0,3.9,-2.2),0.7,**hide)
    a.add("Head","Part",(0.9,0.8,1.1),(0,4.15,-2.55),rx(10),**hide)
    a.add("BeakUpper","WedgePart",(0.6,0.45,1.3),(0,4.05,-3.6),color="Gold",mat="CorrodedMetal")
    a.add("BeakLower","WedgePart",(0.5,0.3,1.0),(0,3.75,-3.4),rz(180),color="Gold",mat="CorrodedMetal")
    a.add("Eye","Part",(0.5,0.5,0.5),(0,4.45,-3.02),shape="Ball",color="Blood",mat="Glass")   # folklore: a single eye
    a.add("Crest","WedgePart",(0.25,0.55,1.0),(0,4.8,-2.35),color="Bone",mat="Limestone")
    for i,(x,z,dx,dz) in enumerate(((0.28,-2.75,0.15,-0.1),(-0.28,-2.75,-0.2,0.05),(0.1,-2.55,0.05,0.2),(-0.1,-2.55,-0.1,0.25))):
        seg(a,f"Tentacle{i+1}",(x,3.75,z),(x+dx,2.75+0.15*i,z+dz),0.14,color="Blood",mat="Fabric")
    seg(a,"Tail1",(0,2.4,1.4),(0,1.8,2.2),0.55,**hide)
    seg(a,"Tail2",(0,1.8,2.2),(0,1.5,2.75),0.35,**hide)
    st=len(a.parts)
    S,E,T,B=np.array([0.7,3.1,-0.4]),np.array([2.2,4.4,0.0]),np.array([3.75,3.2,0.7]),np.array([0.75,2.5,1.4])
    seg(a,"WingArm_R",S,E,0.2,**strut); seg(a,"WingFinger_R",E,T,0.15,**strut)
    tri(a,"WingInner_R",S+[0,-0.05,0],E+[0,-0.05,0],B,0.1,**memb); tri(a,"WingOuter_R",E+[0,-0.05,0],T,B,0.1,**memb)
    seg(a,"Thigh_R",(0.5,2.0,0.6),(0.6,1.0,0.2),0.35,**hide)
    seg(a,"Shin_R",(0.6,1.0,0.2),(0.6,0.15,0.45),0.28,**hide)
    a.add("Talon_R","WedgePart",(0.5,0.2,0.75),(0.6,0.1,0.1),color="Bone",mat="Limestone")
    a.mirror_from(st)
    return a

def loveland_frogman():   # roster 5 H x 3 L; upright frog-man with a sparking wand (folklore)
    a=Asset("LovelandFrogman",{"CryptidId":"loveland_frogman","AssetVersion":"1.0"})
    skin=dict(color="Soot",mat="Slate"); pale=dict(color="BoneDim",mat="Limestone")
    a.root((1,1,0.8),(0,2.0,-0.3))   # footprint centre
    a.add("Torso","Part",(1.35,1.8,0.95),(0,2.6,0.05),rx(-12),**skin)
    a.add("Belly","Part",(1.3,1.3,1.3),(0,2.2,-0.2),shape="Ball",**pale)
    a.add("Head","WedgePart",(1.9,0.8,1.3),(0,4.07,-0.2),**skin)   # pass 1: sloped frog snout, not a box
    a.add("Throat","Part",(1.6,0.4,1.05),(0,3.55,-0.15),**pale)
    a.add("Mouth","Part",(1.75,0.1,0.06),(0,3.72,-0.86),color="Blood",mat="Fabric")
    seg(a,"Wand",(1.22,1.6,-0.85),(1.35,3.0,-1.15),0.09,color="BoneDim",mat="Wood")
    a.add("WandTip","Part",(0.24,0.24,0.24),(1.36,3.08,-1.17),shape="Ball",color="GoldBright",mat="Glass")
    st=len(a.parts)
    a.add("Eye_R","Part",(0.66,0.66,0.66),(0.62,4.45,0.05),shape="Ball",**pale)
    a.add("Pupil_R","Part",(0.36,0.1,0.06),(0.62,4.47,-0.29),color="Void",mat="Slate")
    seg(a,"ArmUpper_R",(0.72,3.15,0.0),(1.1,2.35,-0.3),0.26,**skin)
    seg(a,"ArmFore_R",(1.1,2.35,-0.3),(1.2,1.65,-0.7),0.22,**skin)
    a.add("Hand_R","WedgePart",(0.55,0.12,0.55),(1.22,1.55,-0.85),ry(-15),**pale)
    seg(a,"Thigh_R",(0.4,1.75,0.1),(0.85,1.0,-0.35),0.42,**skin)
    seg(a,"Shin_R",(0.85,1.0,-0.35),(0.7,0.15,0.2),0.34,**skin)
    a.add("Foot_R","WedgePart",(0.8,0.15,1.05),(0.85,0.075,-0.2),ry(-20),**skin)
    a.mirror_from(st)
    return a

ALL={"MothmanHatchling":mothman,"Pad":pad,"BoneAltar":bone_altar,"FresnoNightcrawler":fresno,"Hidebehind":hidebehind,"Hodag":hodag,
     "Jackalope":jackalope,"DoverDemon":dover_demon,"Snallygaster":snallygaster,"LovelandFrogman":loveland_frogman}
if __name__=="__main__":
    os.makedirs(MODELS, exist_ok=True)
    for n in (sys.argv[1:] or ALL):
        ALL[n]().write(f"{MODELS}/{n}.rbxmx",f"{MODELS}/{n}.parts.json")
