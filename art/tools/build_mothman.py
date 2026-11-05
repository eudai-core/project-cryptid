"""Builds MothmanHatchling.rbxmx (Parts only) + box-side preview renders.
Coordinates: studs, model-local. Ground y=0. Creature FRONT = -Z (Roblox LookVector of Root)."""
import math, json, base64, struct, sys, os
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "models", "MothmanHatchling.rbxmx")
PARTS_JSON = os.path.join(HERE, "..", "models", "MothmanHatchling.parts.json")

# Palette tokens (style-guide §1)
C = {"Void":(11,10,12),"Ash":(26,23,25),"Soot":(42,36,39),"Blood":(122,15,18),"BloodHover":(148,23,27),
     "Gold":(156,122,60),"GoldBright":(201,165,90),"Bone":(232,224,207),"BoneDim":(167,159,144),"Rift":(127,163,74)}
MAT = {"Fabric":1312,"Limestone":820,"Basalt":788,"Slate":800,"Glass":1568}
SHAPE = {"Ball":0,"Block":1,"Cylinder":2}

def rx(a):a=math.radians(a);c,s=math.cos(a),math.sin(a);return np.array([[1,0,0],[0,c,-s],[0,s,c]])
def ry(a):a=math.radians(a);c,s=math.cos(a),math.sin(a);return np.array([[c,0,s],[0,1,0],[-s,0,c]])
def rz(a):a=math.radians(a);c,s=math.cos(a),math.sin(a);return np.array([[c,-s,0],[s,c,0],[0,0,1]])
def R(x=0,y=0,z=0): return ry(y)@rx(x)@rz(z)   # same as CFrame.fromEulerAnglesYXZ

parts=[]
def add(name, cls, size, pos, rot=np.eye(3), color="Soot", mat="Fabric", shape="Block", transp=0.0, shadow=False):
    parts.append(dict(name=name, cls=cls, size=list(map(float,size)), pos=np.array(pos,float), rot=np.array(rot,float),
                      color=color, mat=mat, shape=shape, transp=transp, shadow=shadow))

M = np.diag([-1.0,1,1])
def mirror(p):  # mirror a part across x=0 (keeps proper rotation)
    q=dict(p); q["pos"]=M@p["pos"]; q["rot"]=M@p["rot"]@M; q["name"]=p["name"].replace("_R","_L"); return q

# ---------- body ----------
hunch = R(x=-18)   # tip top forward (toward -Z)
add("Root","Part",(1.6,2.0,1.4),(0,1.9,0.15),hunch,"Ash","Fabric",transp=1.0)
add("Torso","Part",(1.4,1.9,1.2),(0,1.85,0.2),hunch,"Ash","Fabric",shadow=True)
add("Belly","Part",(0.9,1.1,0.25),(0,1.6,-0.45),hunch,"Soot","Fabric")
add("FurRuff","Part",(1.4,0.6,0.6),(0,2.55,-0.35),R(x=-25),"BoneDim","Fabric")
add("Head","Part",(1.3,1.3,1.3),(0,3.05,-0.55),shape="Ball",color="Soot",mat="Fabric",shadow=True)
# eyes: big, set into the face; Glass BloodHover (no Neon in lairs, spec 01 A4)
for sx,tag in ((1,"_R"),(-1,"_L")):
    add("Eye"+tag,"Part",(0.56,0.56,0.56),(sx*0.32,3.12,-1.08),shape="Ball",color="BloodHover",mat="Glass")
    add("EyeGlint"+tag,"Part",(0.15,0.15,0.15),(sx*0.38,3.26,-1.33),shape="Ball",color="Bone",mat="Limestone")

# ---------- antennae (feathery) ----------
def antenna(sx,tag):
    base=np.array([sx*0.3,3.6,-0.8])
    tilt=R(x=-20,z=-sx*38)           # up, a bit forward, splayed outward
    up=tilt@np.array([0,1,0]); L=1.25
    add("AntennaStalk"+tag,"Part",(L,0.1,0.1),base+up*L/2,tilt@rz(90),"BoneDim","Fabric",shape="Cylinder")
    # feather fronds: flat leaf-shaped blades (diamond = block rotated 45deg) along the stalk
    for i,(off,s) in enumerate(((0.45,0.55),(0.8,0.42))):
        add(f"AntennaFrond{i+1}"+tag,"Part",(0.05,s,s*0.55),base+up*L*off,tilt@rx(45),"BoneDim","Fabric")
for sx,tag in ((1,"_R"),(-1,"_L")): antenna(sx,tag)

# ---------- legs / claws ----------
for sx,tag in ((1,"_R"),(-1,"_L")):
    add("Leg"+tag,"Part",(0.7,0.28,0.28),(sx*0.38,0.45,0.0),rz(90),"Soot","Fabric",shape="Cylinder")
    add("Claw"+tag,"WedgePart",(0.34,0.22,0.5),(sx*0.38,0.11,-0.3),np.eye(3),"Bone","Limestone")

# ---------- wings (right built, left mirrored) ----------
# Folded moth wing = tall triangle: high point at the FRONT shoulder (above the head),
# sloping down to the back; plane = local YZ, local +x = outward.
H,D=4.2,2.3
wingR = R(y=-16, z=-12)      # rear edge wraps toward back-centre; bottom flares outward
wpos  = np.array([1.0,2.5,0.45])
def wpart(name,cls,size,lpos,lrot=np.eye(3),**kw):
    add(name+"_R",cls,size,wpos+wingR@np.array(lpos,float),wingR@lrot,**kw)
n0=len(parts)
wpart("Wing","WedgePart",(0.14,H,D),(0,0,0),R(y=180),color="Soot",mat="Fabric",shadow=True)
slope=math.degrees(math.atan2(H,D))           # angle of the trailing edge
# veins (BoneDim) give the wing a moth pattern and lift it off the dark floor
def seg(name,z0,y0,z1,y1,w=0.09):   # thin strip on the wing between two (z,y) points
    L=math.hypot(z1-z0,y1-y0); ang=math.degrees(math.atan2(y1-y0,z1-z0))
    wpart(name,"Part",(0.16,w,L),(0.03,(y0+y1)/2,(z0+z1)/2),rx(ang),color="BoneDim",mat="Fabric")
seg("WingVein1",-1.02,1.5,-0.95,-1.95,0.11)     # costal vein along the leading edge
seg("WingVein2",-0.9,-0.75,0.55,-1.95)
wpart("WingEyespotRing","Part",(0.04,0.85,0.85),(0.11,-0.05,-0.5),color="BoneDim",mat="Fabric",shape="Cylinder")
wpart("WingEyespot","Part",(0.05,0.6,0.6),(0.14,-0.05,-0.5),color="Blood",mat="Fabric",shape="Cylinder")
# tattered trailing edge: diamond teeth half-buried in the slope, uneven sizes
for i,(t,s) in enumerate(((0.3,0.55),(0.55,0.42),(0.8,0.6))):
    z=-D/2+D*t; y=H/2-H*t
    wpart(f"WingTatter{i+1}","Part",(0.12,s,s),(0,y,z),rx(45-(90-slope)),color="Soot",mat="Fabric")
parts += [mirror(p) for p in parts[n0:]]

# ---------- hatchling eggshell shards ----------
add("EggShard1","WedgePart",(0.9,0.55,0.6),(0.75,0.27,-0.85),ry(35),"Bone","Limestone")
add("EggShard2","WedgePart",(0.7,0.4,0.5),(-0.85,0.2,-0.65),ry(-150)@rx(8),"BoneDim","Limestone")

# Wedge tatters sit just below the wing; drop anything below ground
for p in parts:
    if p["pos"][1] < 0.05: p["pos"][1] = 0.05

# ---------- write XML ----------
def esc(s): return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
def attrs(d):
    b=struct.pack("<I",len(d))
    for k,v in d.items():
        kb=k.encode(); vb=v.encode()
        b+=struct.pack("<I",len(kb))+kb+b"\x02"+struct.pack("<I",len(vb))+vb
    return base64.b64encode(b).decode()

refs={}
for i,p in enumerate(parts): refs[p["name"]]="RBX%032X"%(0xC0FFEE000+i+1)
model_ref="RBX%032X"%0xC0FFEE000
def fmt(x): return ("%.6f"%x).rstrip("0").rstrip(".") if abs(x)>1e-9 else "0"
L=['<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">',
   '\t<Meta name="ExplicitAutoJoints">true</Meta>',
   f'\t<Item class="Model" referent="{model_ref}">','\t\t<Properties>',
   '\t\t\t<string name="Name">MothmanHatchling</string>',
   f'\t\t\t<Ref name="PrimaryPart">{refs["Root"]}</Ref>',
   f'\t\t\t<BinaryString name="AttributesSerialize">{attrs({"CryptidId":"mothman_hatchling","AssetVersion":"0.1"})}</BinaryString>',
   '\t\t</Properties>']
for p in parts:
    r=p["rot"]; x,y,z=p["pos"]
    col=C[p["color"]]; c3=(0xFF<<24)|(col[0]<<16)|(col[1]<<8)|col[2]
    L.append(f'\t\t<Item class="{p["cls"]}" referent="{refs[p["name"]]}">'); L.append('\t\t\t<Properties>')
    L.append(f'\t\t\t\t<string name="Name">{esc(p["name"])}</string>')
    for b,v in (("Anchored",True),("CanCollide",False),("CanTouch",False),("CanQuery",False),("CastShadow",p["shadow"]),("Locked",False)):
        L.append(f'\t\t\t\t<bool name="{b}">{"true" if v else "false"}</bool>')
    cf="".join(f"<{k}>{fmt(v)}</{k}>" for k,v in zip(["X","Y","Z","R00","R01","R02","R10","R11","R12","R20","R21","R22"],[x,y,z,*r.flatten()]))
    L.append(f'\t\t\t\t<CoordinateFrame name="CFrame">{cf}</CoordinateFrame>')
    L.append(f'\t\t\t\t<Color3uint8 name="Color3uint8">{c3}</Color3uint8>')
    L.append(f'\t\t\t\t<token name="Material">{MAT[p["mat"]]}</token>')
    L.append(f'\t\t\t\t<float name="Transparency">{fmt(p["transp"])}</float>')
    L.append(f'\t\t\t\t<float name="Reflectance">0</float>')
    for s in ("TopSurface","BottomSurface","FrontSurface","BackSurface","LeftSurface","RightSurface"):
        L.append(f'\t\t\t\t<token name="{s}">0</token>')
    sx,sy,sz=p["size"]
    L.append(f'\t\t\t\t<Vector3 name="size"><X>{fmt(sx)}</X><Y>{fmt(sy)}</Y><Z>{fmt(sz)}</Z></Vector3>')
    if p["cls"]=="Part": L.append(f'\t\t\t\t<token name="shape">{SHAPE[p["shape"]]}</token>')
    L.append('\t\t\t</Properties>'); L.append('\t\t</Item>')
L+=['\t</Item>','</roblox>']
os.makedirs(os.path.dirname(OUT), exist_ok=True)
open(OUT,"w").write("\n".join(L)+"\n")
json.dump([dict(p,pos=p["pos"].tolist(),rot=p["rot"].tolist()) for p in parts],open(PARTS_JSON,"w"),indent=1)
print("parts:",len(parts))
