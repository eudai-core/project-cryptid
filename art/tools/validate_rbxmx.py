"""Project Cryptid rbxmx validator v2 (box-side; NOT a substitute for Studio checks).
usage: python3 validate_rbxmx.py <file.rbxmx> --max N [--id-key CryptidId|AssetId] [--id VALUE] [--neon Name1,Name2] [--max-visible N]"""
import sys, base64, struct, argparse, xml.etree.ElementTree as ET, numpy as np
ap=argparse.ArgumentParser(); ap.add_argument("file"); ap.add_argument("--max",type=int,required=True)
ap.add_argument("--id-key"); ap.add_argument("--id"); ap.add_argument("--neon",default=""); ap.add_argument("--version",default="1.0"); ap.add_argument("--placeholder",action="store_true")
a=ap.parse_args(); ok=True
def fail(m):
    global ok; ok=False; print("FAIL:",m)
PAL={0x0B0A0C,0x1A1719,0x2A2427,0x7A0F12,0x94171B,0x9C7A3C,0xC9A55A,0xE8E0CF,0xA79F90,0x7FA34A,0x5E7A4A,0x8C9AA3}  # rarity trims: Moss (spec 01 A2), Silver (D11)
root=ET.parse(a.file).getroot()
if not(root.tag=="roblox" and root.get("version")=="4"): fail("not roblox v4")
refs=[i.get("referent") for i in root.iter("Item")]
if len(set(refs))!=len(refs): fail("dup referents")
P=lambda it,n: next((p for p in it.find("Properties") if p.get("name")==n),None)
def attrs(it):
    x=P(it,"AttributesSerialize")
    if x is None or not (x.text or "").strip(): return {}
    b=base64.b64decode(x.text); n=struct.unpack_from("<I",b,0)[0]; o=4; at={}
    for _ in range(n):
        l=struct.unpack_from("<I",b,o)[0];o+=4;k=b[o:o+l].decode();o+=l;ty=b[o];o+=1
        if ty==3: at[k]=bool(b[o]); o+=1; continue
        if ty!=2: fail(f"attr {k} unsupported type {ty}"); return at
        l=struct.unpack_from("<I",b,o)[0];o+=4;at[k]=b[o:o+l].decode();o+=l
    return at
top=[i for i in root.findall("Item")]
if len(top)!=1 or top[0].get("class")!="Model": fail("expected exactly one top-level Model")
m=top[0]; at=attrs(m); print("model:",P(m,"Name").text,"attrs:",at)
if at.get("AssetVersion")!=a.version: fail(f"AssetVersion {at.get('AssetVersion')} != {a.version}")
if a.id_key and at.get(a.id_key)!=a.id: fail(f"{a.id_key}={at.get(a.id_key)} expected {a.id}")
if a.placeholder and at.get("IsPlaceholder") is not True: fail("IsPlaceholder bool attribute missing")
parts=[]; groups=[]
def walk(it,path):
    for c in it.findall("Item"):
        cl=c.get("class")
        if cl=="Model": groups.append((path+"/"+P(c,"Name").text,attrs(c))); walk(c,path+"/"+P(c,"Name").text)
        else: parts.append((c,path))
walk(m,"")
allowed={"Part","WedgePart","CornerWedgePart"}; neon_ok=set(filter(None,a.neon.split(","))); names=set(); mats={}; neon=[]
for it,path in parts:
    nm=P(it,"Name").text; cl=it.get("class")
    if cl not in allowed: fail(f"{path}/{nm} class {cl}"); continue
    if nm in names: fail("dup name "+nm)
    names.add(nm)
    for k,v in (("Anchored","true"),("CanCollide","false"),("CanTouch","false"),("CanQuery","false")):
        if P(it,k) is None or P(it,k).text!=v: fail(f"{nm} {k}")
    mat=int(P(it,"Material").text); mats[mat]=mats.get(mat,0)+1
    if mat in (256,272): fail(nm+" plastic")
    if mat==288:
        neon.append(nm)
        if nm not in neon_ok: fail(nm+" Neon not allowed")
    col=int(P(it,"Color3uint8").text)&0xFFFFFF
    tr=float(P(it,"Transparency").text)
    if col not in PAL and tr<1: fail(f"{nm} colour #{col:06X} off-palette")
    s=P(it,"size"); sz=[float(s.find(k).text) for k in "XYZ"]
    if np.prod(sz)<1 and P(it,"CastShadow").text!="false": fail(nm+" small part casts shadow")
    cf=P(it,"CFrame"); Rm=np.array([float(cf.find(k).text) for k in ["R00","R01","R02","R10","R11","R12","R20","R21","R22"]]).reshape(3,3)
    if not np.allclose(Rm@Rm.T,np.eye(3),atol=1e-5) or abs(np.linalg.det(Rm)-1)>1e-5: fail(nm+" bad rotation")
    if cl=="Part" and P(it,"shape") is None: fail(nm+" no shape")
    if nm=="Root":
        if not np.allclose(Rm,np.eye(3),atol=1e-6): fail("Root not flat")
        if tr<1: fail("Root visible")
        po=P(it,"PivotOffset"); y=float(cf.find("Y").text)
        if po is None: fail("Root has no PivotOffset")
        elif abs(y+float(po.find("Y").text))>1e-4: fail(f"pivot not at ground: Root.Y {y} + offset {po.find('Y').text}")
pp=P(m,"PrimaryPart").text; ppn=[P(i,"Name").text for i,_ in parts if i.get("referent")==pp]
if ppn!=["Root"]: fail(f"PrimaryPart -> {ppn}")
if len(parts)>a.max: fail(f"{len(parts)} parts > {a.max}")
if any(i.get("class") in("Script","LocalScript","ModuleScript","MeshPart","SpecialMesh","Decal","Texture") for i in root.iter("Item")): fail("script/mesh/decal present")
vis=sum(1 for i,_ in parts if float(P(i,"Transparency").text)<1)
print(f"parts: {len(parts)} (visible {vis}) groups: {groups} neon: {neon} materials: {mats}")
print("RESULT:","PASS" if ok else "FAIL"); sys.exit(0 if ok else 1)
