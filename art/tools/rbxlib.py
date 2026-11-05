"""Shared Parts-only Roblox model builder (box-side). Writes .rbxmx (roblox version 4) + parts JSON for previews.
Conventions (style guide): studs; ground y=0; model FRONT = -Z (Root LookVector); pivot = ground centre via Root.PivotOffset."""
import math, json, base64, struct, zlib
import numpy as np

C = {"Void":(11,10,12),"Ash":(26,23,25),"Soot":(42,36,39),"Blood":(122,15,18),"BloodHover":(148,23,27),
     "Gold":(156,122,60),"GoldBright":(201,165,90),"Bone":(232,224,207),"BoneDim":(167,159,144),"Rift":(127,163,74),
     # rarity-trim accents: Moss = Uncommon (spec 01 A2), Silver = Rare (D11)
     "Moss":(94,122,74),"Silver":(140,154,163)}
MAT = {"Fabric":1312,"Limestone":820,"Basalt":788,"Slate":800,"Glass":1568,"CorrodedMetal":1040,
       "Wood":512,"WoodPlanks":528,"Cobblestone":880,"Concrete":816,"Neon":288}
SHAPE = {"Ball":0,"Block":1,"Cylinder":2}
SMALL_VOLUME = 1.0   # parts below this volume get CastShadow off by default

def rx(a):a=math.radians(a);c,s=math.cos(a),math.sin(a);return np.array([[1,0,0],[0,c,-s],[0,s,c]])
def ry(a):a=math.radians(a);c,s=math.cos(a),math.sin(a);return np.array([[c,0,s],[0,1,0],[-s,0,c]])
def rz(a):a=math.radians(a);c,s=math.cos(a),math.sin(a);return np.array([[c,-s,0],[s,c,0],[0,0,1]])
def R(x=0,y=0,z=0): return ry(y)@rx(x)@rz(z)       # == CFrame.fromEulerAnglesYXZ
def axis_to(v):
    """rotation whose local +X points along v (for Roblox cylinders, axis = X)"""
    v=np.array(v,float); v/=np.linalg.norm(v); a=np.array([0,1,0]) if abs(v[1])<0.9 else np.array([1,0,0])
    y=np.cross(a,v); y/=np.linalg.norm(y); z=np.cross(v,y); return np.column_stack([v,y,z])
def yaxis_to(v): return axis_to(v)@rz(-90)            # local +Y along v (for blocks used as limbs)
def seg(asset, name, a, b, thick, **kw):
    """block whose local Y runs from point a to point b"""
    a=np.array(a,float); b=np.array(b,float); L=np.linalg.norm(b-a)
    tx,tz=(thick if isinstance(thick,(tuple,list)) else (thick,thick))
    return asset.add(name,"Part",(tx,L,tz),(a+b)/2,yaxis_to(b-a),**kw)
M = np.diag([-1.0,1,1])

class Asset:
    def __init__(self, name, attrs):
        self.name=name; self.attrs=attrs; self.parts=[]; self.groups={}; self.sets=None
    def group(self, gname, attrs=None): self.groups[gname]=attrs or {}
    def add(self, name, cls, size, pos, rot=None, color="Soot", mat="Fabric", shape="Block",
            transp=0.0, shadow=None, group=None):
        assert color in C and mat in MAT, (name,color,mat)
        rot=np.eye(3) if rot is None else np.array(rot,float)
        if shadow is None: shadow = (size[0]*size[1]*size[2] >= SMALL_VOLUME) and transp < 1
        self.parts.append(dict(name=name, cls=cls, size=[float(v) for v in size], pos=np.array(pos,float), rot=rot,
                               color=color, mat=mat, shape=shape, transp=float(transp), shadow=bool(shadow), group=group))
        return self.parts[-1]
    def mirror_from(self, start, frm="_R", to="_L"):
        for p in list(self.parts[start:]):
            q=dict(p); q["pos"]=M@p["pos"]; q["rot"]=M@p["rot"]@M; q["name"]=p["name"].replace(frm,to); self.parts.append(q)
    def root(self, size, center, group=None):
        """invisible anchored Root at body centre, pivot moved to ground (y=0) below it"""
        self.add("Root","Part",size,center,np.eye(3),"Ash","Fabric",transp=1.0,shadow=False,group=group)
        self.pivot_y=-float(center[1])

    # ---------- output ----------
    @staticmethod
    def _attrs(d):
        b=struct.pack("<I",len(d))
        for k,v in d.items():
            kb=k.encode(); b+=struct.pack("<I",len(kb))+kb
            if isinstance(v,bool): b+=b"\x03"+(b"\x01" if v else b"\x00")      # Roblox bool attribute
            else: vb=str(v).encode(); b+=b"\x02"+struct.pack("<I",len(vb))+vb
        return base64.b64encode(b).decode()
    @staticmethod
    def _f(x): return ("%.6f"%x).rstrip("0").rstrip(".") if abs(x)>1e-9 else "0"
    def _cf(self, tag, pos, rot):
        ks=["X","Y","Z","R00","R01","R02","R10","R11","R12","R20","R21","R22"]
        return f'<CoordinateFrame name="{tag}">'+"".join(f"<{k}>{self._f(v)}</{k}>" for k,v in zip(ks,[*pos,*np.array(rot).flatten()]))+'</CoordinateFrame>'
    def write(self, out, parts_json):
        names=[p["name"] for p in self.parts]; assert len(names)==len(set(names)), "duplicate part names"
        n=[0]
        def ref(): n[0]+=1; return "RBX%08X%024X"%(zlib.crc32(self.name.encode()), n[0])
        mref=ref(); prefs={p["name"]:ref() for p in self.parts}; grefs={g:ref() for g in self.groups}
        L=['<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">',
           '\t<Meta name="ExplicitAutoJoints">true</Meta>', f'\t<Item class="Model" referent="{mref}">','\t\t<Properties>',
           f'\t\t\t<string name="Name">{self.name}</string>', f'\t\t\t<Ref name="PrimaryPart">{prefs["Root"]}</Ref>',
           f'\t\t\t<BinaryString name="AttributesSerialize">{self._attrs(self.attrs)}</BinaryString>','\t\t</Properties>']
        def part_xml(p,ind):
            t="\t"*ind; col=C[p["color"]]; c3=(0xFF<<24)|(col[0]<<16)|(col[1]<<8)|col[2]
            o=[f'{t}<Item class="{p["cls"]}" referent="{prefs[p["name"]]}">',f'{t}\t<Properties>',f'{t}\t\t<string name="Name">{p["name"]}</string>']
            for b,v in (("Anchored",True),("CanCollide",False),("CanTouch",False),("CanQuery",False),("CastShadow",p["shadow"]),("Locked",False)):
                o.append(f'{t}\t\t<bool name="{b}">{"true" if v else "false"}</bool>')
            o.append(t+"\t\t"+self._cf("CFrame",p["pos"],p["rot"]))
            if p["name"]=="Root": o.append(t+"\t\t"+self._cf("PivotOffset",[0,self.pivot_y,0],np.eye(3)))
            o+= [f'{t}\t\t<Color3uint8 name="Color3uint8">{c3}</Color3uint8>', f'{t}\t\t<token name="Material">{MAT[p["mat"]]}</token>',
                 f'{t}\t\t<float name="Transparency">{self._f(p["transp"])}</float>', f'{t}\t\t<float name="Reflectance">0</float>']
            for s in ("TopSurface","BottomSurface","FrontSurface","BackSurface","LeftSurface","RightSurface"):
                o.append(f'{t}\t\t<token name="{s}">0</token>')
            sx,sy,sz=p["size"]; o.append(f'{t}\t\t<Vector3 name="size"><X>{self._f(sx)}</X><Y>{self._f(sy)}</Y><Z>{self._f(sz)}</Z></Vector3>')
            if p["cls"]=="Part": o.append(f'{t}\t\t<token name="shape">{SHAPE[p["shape"]]}</token>')
            o+=[f'{t}\t</Properties>',f'{t}</Item>']; return o
        for p in self.parts:
            if p["group"] is None: L+=part_xml(p,2)
        for g,ga in self.groups.items():
            L+=[f'\t\t<Item class="Model" referent="{grefs[g]}">','\t\t\t<Properties>',f'\t\t\t\t<string name="Name">{g}</string>']
            if ga: L.append(f'\t\t\t\t<BinaryString name="AttributesSerialize">{self._attrs(ga)}</BinaryString>')
            L.append('\t\t\t</Properties>')
            for p in self.parts:
                if p["group"]==g: L+=part_xml(p,3)
            L.append('\t\t</Item>')
        L+=['\t</Item>','</roblox>']
        open(out,"w").write("\n".join(L)+"\n")
        sets=self.sets or [{"label":"all","groups":[None]+list(self.groups)}]
        json.dump({"name":self.name,"sets":sets,"parts":[dict(p,pos=p["pos"].tolist(),rot=p["rot"].tolist()) for p in self.parts]},
                  open(parts_json,"w"),indent=1)
        print(f"{self.name}: {len(self.parts)} parts -> {out}")

def tri(asset, name, A, B, C, thick=0.1, **kw):
    """flat triangle A-B-C from 2 WedgeParts (split at the foot of the altitude onto the longest side).
    Uses the assumed wedge geometry: right angle at bottom-back, slope from top-back down to bottom-front (-Z)."""
    P=[np.array(v,float) for v in (A,B,C)]
    i=max(range(3),key=lambda k: np.linalg.norm(P[(k+1)%3]-P[k])); A,B,C=P[i],P[(i+1)%3],P[(i+2)%3]
    u=(B-A)/np.linalg.norm(B-A); D=A+u*np.dot(C-A,u); out=[]
    for k,E in enumerate((A,B)):
        if np.linalg.norm(E-D)<1e-3: continue
        Z=(D-E)/np.linalg.norm(D-E); Y=(C-D)/np.linalg.norm(C-D); X=np.cross(Y,Z)
        out.append(asset.add(f"{name}{'ab'[k]}","WedgePart",(thick,np.linalg.norm(C-D),np.linalg.norm(D-E)),D+(E-D)/2+(C-D)/2,np.column_stack([X,Y,Z]),**kw))
    return out
