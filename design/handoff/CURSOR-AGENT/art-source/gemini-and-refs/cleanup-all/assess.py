import numpy as np, json, sys
from PIL import Image
from common import *
EXTRA=['7a6aa8','4a3a78','2e2450','aaa2c6','766e9a','4a446a','3e8ea8','7a9af0','633f2b','8c5228']
PALX=np.vstack([PAL,np.array([hex2rgb(h) for h in EXTRA],float)]); HEXX=PAL_HEX+EXTRA
OUT=HEXX.index('100e0c'); DARKS={HEXX.index(h) for h in ('100e0c','1c1814','1a1210','0b0706','0c0e16')}
RET='<ART_KIT>/returns/'
BG=-1
def bgmask(a):
    R,G,B=a[...,0],a[...,1],a[...,2]
    return (R-G>60)&(B-G>60)&(abs(R-B)<120)
def cells_grid(box,cols,rows,trim=0.02):
    x0,y0,x1,y1=box; w=(x1-x0)/cols; h=(y1-y0)/rows; out=[]
    for r in range(rows):
        for c in range(cols):
            out.append((int(x0+c*w+w*trim),int(y0+r*h+h*trim),int(x0+(c+1)*w-w*trim),int(y0+(r+1)*h-h*trim)))
    return out
def cells_blobs(a,box,n):
    x0,y0,x1,y1=box; fg=~bgmask(a[y0:y1,x0:x1]) & (a[y0:y1,x0:x1].max(-1)>0)
    col=fg.mean(0)>0.01
    runs=[];s=None
    for i,v in enumerate(list(col)+[False]):
        if v and s is None: s=i
        if not v and s is not None:
            runs.append((s,i)); s=None
    runs=sorted(runs,key=lambda r:-(r[1]-r[0]))[:n]; runs.sort()
    return [(x0+max(0,r0-4),y0,x0+r1+4,y1) for r0,r1 in runs]
def process(name,raw,N,cells,flip=False,select=None):
    a=np.asarray(Image.open(RET+raw).convert('RGB')).astype(float)
    if select: cells=[cells[i] for i in select]
    frames=[]
    for (x0,y0,x1,y1) in cells:
        sub=a[y0:y1,x0:x1]; m=~bgmask(sub)
        # drop dark divider lines touching the cell edges: remove fg rows/cols that are >80% dark
        dk=sub.max(-1)<60
        for ax in (0,1):
            frac=dk.mean(ax)
            for i,v in enumerate(frac):
                if v>0.8:
                    if ax==0: m[:,i]=False
                    else: m[i,:]=False
        idx=snap_idx(sub,PALX); idx[~m]=BG
        # keep largest connected area region: remove tiny specks far away via mode later
        yy,xx=np.where(m)
        if len(yy)==0: continue
        # robust bbox: ignore rows/cols with very few fg px (noise)
        rows=np.where(m.sum(1)>2)[0]; cols_=np.where(m.sum(0)>2)[0]
        bb=(cols_.min(),rows.min(),cols_.max()+1,rows.max()+1)
        up=(yy<bb[1]+0.6*(bb[3]-bb[1]))
        frames.append(dict(idx=idx,bb=bb,cx=xx[up].mean()))
    H=max(f['bb'][3]-f['bb'][1] for f in frames); W=max(max(f['bb'][2]-f['cx'],f['cx']-f['bb'][0]) for f in frames)*2
    cell=max(H/(N-1),W/(N-2))
    outs=[]
    for f in frames:
        idx=f['idx']; bb=f['bb']; pad=int(cell*N)+10
        P=np.pad(idx,pad,constant_values=BG)
        nat=mode_cells(P,cell,N,N,f['cx']-N/2*cell+pad,bb[3]-N*cell+pad,ignore=BG,minfrac=0.5)
        if flip: nat=nat[:,::-1]
        op=nat!=BG
        for y in range(N):
            for x in range(N):
                if op[y,x] and sum(op[y+dy,x+dx] for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)) if 0<=y+dy<N and 0<=x+dx<N)==0: nat[y,x]=BG
        op=nat!=BG; n2,_=despeckle(np.where(op,nat,-5)); nat=np.where(n2==-5,BG,n2)
        op=nat!=BG; new=nat.copy()
        for y in range(N):
            for x in range(N):
                if op[y,x]: continue
                nb=[(y+dy,x+dx) for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)) if 0<=y+dy<N and 0<=x+dx<N]
                if any(op[p] and nat[p] not in DARKS for p in nb): new[y,x]=OUT
        nat=new; op=nat!=BG
        if op.any():
            sh=N-1-np.where(op.any(1))[0].max()
            if sh>0: nat=np.roll(nat,sh,0); nat[:sh]=BG
        outs.append(nat)
    ims=[]; used=set()
    for k,nat in enumerate(outs):
        rgba=np.zeros((N,N,4),np.uint8); op=nat!=BG; rgba[op,:3]=PALX[nat[op]].astype(np.uint8); rgba[op,3]=255
        used|=set(np.unique(nat[op]).tolist())
        im=Image.fromarray(rgba); im.save('%s_f%d_native%d.png'%(name,k,N)); ims.append(im)
    S=4; cs=Image.new('RGBA',(len(ims)*(N*S+8)+8,N*S+16),(58,52,46,255))
    for k,im in enumerate(ims): cs.alpha_composite(im.resize((N*S,N*S),Image.NEAREST),(8+k*(N*S+8),8))
    cs.save('%s_contact_x4.png'%name)
    if len(ims)>1:
        gf=[]
        for im in ims:
            b=Image.new('RGBA',(N*S,N*S),(58,52,46,255)); b.alpha_composite(im.resize((N*S,N*S),Image.NEAREST)); gf.append(b.convert('P',palette=Image.ADAPTIVE))
        gf[0].save('%s_x4_8fps.gif'%name,save_all=True,append_images=gf[1:],duration=125,loop=0,disposal=2)
    # leg-region similarity f0 vs f2
    info=dict(name=name,raw=raw,N=N,frames=len(ims),cell=round(cell,2),colours=len(used),extra_used=sorted(HEXX[i] for i in used if i>=len(PAL_HEX)))
    if len(outs)==4:
        lo=int(N*0.72)
        d02=(outs[0][lo:]!=outs[2][lo:]).mean(); d01=(outs[0][lo:]!=outs[1][lo:]).mean()
        info['leg_diff_f0_f2']=round(float(d02),3); info['leg_diff_f0_f1']=round(float(d01),3)
    print(json.dumps(info)); return info
J=[]
J.append(process('sprout_run','sprout_run_raw.jpg',48,cells_grid((6,3,2058,510),4,1,0.01)))
J.append(process('sprout_grab','sprout_grab_raw.jpg',48,cells_grid((0,0,2064,512),4,1,0.02)))
J.append(process('sprout_throw','sprout_throw_raw.jpg',48,cells_grid((0,0,2064,512),4,1,0.02)))
J.append(process('nib_lantern','nib_lantern_raw.jpg',32,cells_grid((0,0,1456,720),4,2,0.02),select=[2,3]))
J.append(process('mon_goblin','mon_goblin_raw.jpg',32,cells_grid((0,0,2064,512),4,1,0.02)))
J.append(process('mon_skeleton','mon_skeleton_raw.jpg',32,cells_grid((0,0,2064,512),4,1,0.02)))
a=np.asarray(Image.open(RET+'mon_ogre_raw.jpg').convert('RGB')).astype(float)
J.append(process('mon_ogre','mon_ogre_raw.jpg',48,cells_blobs(a,(16,16,992,325),3)))
J.append(process('mon_hornet_swarm','mon_hornet_swarm_raw.jpg',32,cells_grid((0,0,1008,1049),2,2,0.02)))
J.append(process('mon_spider_queen','mon_spider_queen_raw.jpg',48,cells_grid((0,0,2064,512),4,1,0.02)))
J.append(process('mon_dragon','mon_dragon_raw.jpg',64,cells_grid((0,0,1376,768),2,2,0.02)))
a=np.asarray(Image.open(RET+'sprout_design_raw.jpg').convert('RGB')).astype(float)
J.append(process('sprout_design_views','sprout_design_raw.jpg',48,cells_blobs(a,(0,60,1008,435),4)))
J.append(process('sprout_design_coin','sprout_design_raw.jpg',48,[(330,520,680,950)]))
json.dump(J,open('assess.json','w'),indent=1)
