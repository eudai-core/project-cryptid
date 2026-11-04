"""Box-side preview of a parts JSON (NOT a Studio render).
Usage: preview_parts.py <parts.json> <out_prefix> [title]  -> <out_prefix>_preview-front34.png / _preview-side.png
One panel per preview set (variants / tiers)."""
import json, sys, math, numpy as np
C={"Moss":(94,122,74),"Silver":(140,154,163),"Void":(11,10,12),"Ash":(26,23,25),"Soot":(42,36,39),"Blood":(122,15,18),"BloodHover":(148,23,27),"Gold":(156,122,60),
   "GoldBright":(201,165,90),"Bone":(232,224,207),"BoneDim":(167,159,144),"Rift":(127,163,74)}
def box(sx,sy,sz):
    v=np.array([[x,y,z] for x in(-1,1) for y in(-1,1) for z in(-1,1)])*[sx/2,sy/2,sz/2]
    return v,[[0,1,3,2],[4,6,7,5],[0,4,5,1],[2,3,7,6],[0,2,6,4],[1,5,7,3]]
def wedge(sx,sy,sz):  # ASSUMED Roblox wedge: full bottom + full back (+Z), slope down to the front (-Z). Verify in Studio.
    hx,hy,hz=sx/2,sy/2,sz/2
    v=np.array([[-hx,-hy,-hz],[hx,-hy,-hz],[hx,-hy,hz],[-hx,-hy,hz],[-hx,hy,hz],[hx,hy,hz]])
    return v,[[0,1,2,3],[3,2,5,4],[0,4,5,1],[0,3,4],[1,5,2]]
def ball(sx,sy,sz,n=9):
    r=min(sx,sy,sz)/2; v=[];f=[]
    for i in range(n+1):
        t=math.pi*i/n
        for j in range(2*n): p=math.pi*j/n; v.append([r*math.sin(t)*math.cos(p),r*math.cos(t),r*math.sin(t)*math.sin(p)])
    for i in range(n):
        for j in range(2*n): a=i*2*n+j;b=i*2*n+(j+1)%(2*n); f.append([a,b,b+2*n,a+2*n])
    return np.array(v),f
def cyl(sx,sy,sz,n=16):
    r=min(sy,sz)/2;h=sx/2;v=[[s,r*math.cos(2*math.pi*j/n),r*math.sin(2*math.pi*j/n)] for s in(-h,h) for j in range(n)]
    return np.array(v),[[j,(j+1)%n,n+(j+1)%n,n+j] for j in range(n)]+[list(range(n)),list(range(2*n-1,n-1,-1))]
D=json.load(open(sys.argv[1])); prefix=sys.argv[2]
if isinstance(D,list): D={"name":"asset","parts":D,"sets":[{"label":"all","groups":[None]}]}
title=sys.argv[3] if len(sys.argv)>3 else D["name"]
parts=D["parts"]; sets=D["sets"]
Lt=np.array([-0.4,0.8,-0.5]);Lt/=np.linalg.norm(Lt)
def polys(groups):
    P=[];F=[]
    for p in parts:
        if p.get("group") not in groups or p["transp"]>=1: continue
        s=p["size"]; v,f=(wedge(*s) if p["cls"]=="WedgePart" else ball(*s) if p["shape"]=="Ball" else cyl(*s) if p["shape"]=="Cylinder" else box(*s))
        w=(np.array(p["rot"])@v.T).T+np.array(p["pos"]); ctr=w.mean(0); col=np.array(C[p["color"]])/255
        a=1-p["transp"]
        for face in f:
            q=w[face]; n=np.cross(q[1]-q[0],q[2]-q[0]); nn=np.linalg.norm(n)
            if nn<1e-9: continue
            n/=nn
            if np.dot(n,q.mean(0)-ctr)<0: n=-n
            k=0.55+0.6*max(0,np.dot(n,Lt))
            if p["mat"]=="Glass": k+=0.35
            if p["mat"]=="Neon": k=1.6
            P.append(q[:,[0,2,1]]*[1,-1,1]); F.append((*np.clip(col*k,0,1),a))
    return P,F
from PIL import Image, ImageDraw, ImageFont
BG=(58,52,54)
def render(groups, elev, azim, W=520, H=560, scale=None, center=None):
    P,F=polys(groups)
    e,az=math.radians(elev),math.radians(azim)
    fwd=np.array([math.cos(e)*math.cos(az),math.cos(e)*math.sin(az),math.sin(e)])   # toward camera (plot coords, z up)
    right=np.cross([0,0,1],fwd); right/=np.linalg.norm(right); up=np.cross(fwd,right)
    img=np.zeros((H,W,3)); img[:]=np.array(BG)/255; zb=np.full((H,W),-1e9)
    for q,col in zip(P,F):
        q=np.array(q)-center; u=q@right*scale+W/2; v=H*0.55-q@up*scale; d=q@fwd
        for k in range(1,len(q)-1):
            tri=[0,k,k+1]; x=u[tri]; y=v[tri]; z=d[tri]
            x0,x1=int(max(0,np.floor(x.min()))),int(min(W-1,np.ceil(x.max()))); y0,y1=int(max(0,np.floor(y.min()))),int(min(H-1,np.ceil(y.max())))
            if x1<x0 or y1<y0: continue
            den=(y[1]-y[2])*(x[0]-x[2])+(x[2]-x[1])*(y[0]-y[2])
            if abs(den)<1e-9: continue
            X,Y=np.meshgrid(np.arange(x0,x1+1)+0.5,np.arange(y0,y1+1)+0.5)
            l0=((y[1]-y[2])*(X-x[2])+(x[2]-x[1])*(Y-y[2]))/den; l1=((y[2]-y[0])*(X-x[2])+(x[0]-x[2])*(Y-y[2]))/den; l2=1-l0-l1
            m=(l0>=-1e-6)&(l1>=-1e-6)&(l2>=-1e-6)
            Z=l0*z[0]+l1*z[1]+l2*z[2]
            sub=zb[y0:y1+1,x0:x1+1]; m&=Z>sub
            if col[3]<1:
                sub_img=img[y0:y1+1,x0:x1+1]; sub_img[m]=sub_img[m]*(1-col[3])+np.array(col[:3])*col[3]
            else:
                sub[m]=Z[m]; img[y0:y1+1,x0:x1+1][m]=col[:3]
    return Image.fromarray((np.clip(img,0,1)*255).astype(np.uint8))
vis=[p for p in parts if p["transp"]<1]
pts=np.array([np.array(p["pos"])[[0,2,1]]*[1,-1,1] for p in vis]); rad=max(np.linalg.norm(np.array(p["size"]))/2 for p in vis)
lo=pts.min(0)-rad*0.6; hi=pts.max(0)+rad*0.6; center=(lo+hi)/2; span=np.linalg.norm(hi-lo)
try: font=ImageFont.load_default(size=16); small=ImageFont.load_default(size=12)
except TypeError: font=small=ImageFont.load_default()
for view,(elev,azim) in {"preview-front34":(16,55),"preview-side":(6,0)}.items():
    n=len(sets); cols=int(__import__("os").environ.get("COLS",min(n,3))); rows=math.ceil(n/cols); W,H=520,560
    sheet=Image.new("RGB",(W*cols,H*rows+70),BG); dr=ImageDraw.Draw(sheet)
    for i,st in enumerate(sets):
        im=render(st["groups"],elev,azim,W,H,scale=W*1.15/span,center=center)
        sheet.paste(im,((i%cols)*W,(i//cols)*H+50))
        if n>1: dr.text(((i%cols)*W+W/2,(i//cols)*H+62),st["label"],fill=(232,224,207),font=font,anchor="mt")
    dr.text((sheet.width/2,8),title,fill=(232,224,207),font=font,anchor="mt")
    dr.text((sheet.width/2,30),"BOX-SIDE PREVIEW (z-buffer, box tools) - NOT Studio proof - "+view,fill=(201,165,90),font=small,anchor="mt")
    dr.text((sheet.width/2,sheet.height-16),"bg = proposed floor #3A3436 | flat shading approx | wedge orientation assumed, verify in Studio",fill=(167,159,144),font=small,anchor="mt")
    out=f"{prefix}_{view}.png"; sheet.save(out); print(out)
