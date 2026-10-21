import numpy as np, sys
from PIL import Image
from common import *
SRC=sys.argv[1] if len(sys.argv)>1 else '../returns/sprout_run_raw.jpg'
N=int(sys.argv[2]) if len(sys.argv)>2 else 48
TAG=sys.argv[3] if len(sys.argv)>3 else ''
a=np.asarray(Image.open(SRC).convert('RGB')).astype(float)
R,G,B=a[...,0],a[...,1],a[...,2]
# magenta key incl. JPEG fringe: magenta-ish hue (R and B both well above G)
bgmask=((R-G>70)&(B-G>70)&(abs(R-B)<110))
dark=a.max(-1)<60
cols=np.where(dark.mean(0)>0.85)[0]; rows=np.where(dark.mean(1)>0.85)[0]
# segments between divider runs
def runs(ix,n):
    seg=[];prev=-1
    for i in list(ix)+[n]:
        if i>prev+1: seg.append((prev+1,i))
        prev=i
    return seg
xs=[s for s in runs(cols,a.shape[1]) if s[1]-s[0]>100]; ys=[s for s in runs(rows,a.shape[0]) if s[1]-s[0]>100]
y0,y1=ys[0]
print('frames',xs,'rows',ys)
SUB=['100e0c','1c1814','1a1210','0b0706','fff3d6','ffd84a','e8c36a','b8733a','c4e07a','8cbc48','5a8a30','86b4a4','4f8a7c','33605a','d0644a','9a3428','5e1c18','d0b07a','c4a574','a08458','8a6a40','74603e','4e4028']
SUBI=np.array([PAL_HEX.index(h) for h in SUB])
idx_all=SUBI[snap_idx(a,PAL[SUBI])]
BG=-1
frames=[]
for (x0,x1) in xs:
    m=~bgmask[y0+2:y1-2,x0+2:x1-2]
    idx=idx_all[y0+2:y1-2,x0+2:x1-2].copy(); idx[~m]=BG
    yy,xx=np.where(m)
    bb=(xx.min(),yy.min(),xx.max()+1,yy.max()+1)
    up=yy<yy.min()+0.6*(yy.max()-yy.min())
    cx=xx[up].mean()
    frames.append(dict(idx=idx,bb=bb,cx=cx))
H=max(f['bb'][3]-f['bb'][1] for f in frames); Wd=max(max(f['bb'][2]-f['cx'],f['cx']-f['bb'][0]) for f in frames)*2
cell=max(H/(N-1),Wd/(N-1))  # leave room for outline growth on sides/top
print('char px h %d w %d -> cell %.2f src px per native px (detected grid ~8.35)'%(H,Wd,cell))
pal_idx=None
outs=[]
OUT=PAL_HEX.index('100e0c')
for f in frames:
    idx=f['idx']; bb=f['bb']
    oy=bb[3]-N*cell  # feet: bottom of bbox = bottom of last row
    ox=f['cx']-N/2*cell
    pad=int(cell*N)+10
    P=np.pad(idx,pad,constant_values=BG)
    nat=mode_cells(P,cell,N,N,ox+pad,oy+pad,ignore=BG,minfrac=0.5)
    outs.append(nat)
# ramps for "one step darker"
RAMPS=[['c4e07a','8cbc48','5a8a30','44702a'],['9cc060','6a9a3a','44702a'],['86b4a4','4f8a7c','33605a','2e3448'],['d0644a','9a3428','5e1c18'],
 ['d0b07a','c4a574','a08458','8a6a40','74603e','4e4028'],['62ccb4','2f8c7e','33605a']]
DARKER={}
for r in RAMPS:
    for i in range(len(r)-1): DARKER.setdefault(PAL_HEX.index(r[i]),PAL_HEX.index(r[i+1]))
def comps(mask):
    lab=np.zeros(mask.shape,int);n=0
    for y,x in zip(*np.where(mask)):
        if lab[y,x]: continue
        n+=1;st=[(y,x)];lab[y,x]=n
        while st:
            cy,cx=st.pop()
            for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):
                ny,nx=cy+dy,cx+dx
                if 0<=ny<mask.shape[0] and 0<=nx<mask.shape[1] and mask[ny,nx] and not lab[ny,nx]:
                    lab[ny,nx]=n;st.append((ny,nx))
    return lab,n
notes=[]
final=[]
for k,nat in enumerate(outs):
    op=nat!=BG
    # orphans
    rem=0
    for y in range(N):
        for x in range(N):
            if op[y,x] and sum(op[y+dy,x+dx] for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)) if 0<=y+dy<N and 0<=x+dx<N)==0:
                nat[y,x]=BG;rem+=1
    # transparent single holes fully surrounded -> fill with majority
    op=nat!=BG
    nat2,ds=despeckle(np.where(op,nat,-5))
    nat=np.where(nat2==-5,BG,nat2)
    # far leg: lower 28% rows of the opaque bbox, non-outline pixels, components
    op=nat!=BG; ys_,xs_=np.where(op); top,bot=ys_.min(),ys_.max()
    r0=int(bot-0.25*(bot-top))
    legmask=np.zeros_like(op); GREEN=[PAL_HEX.index(h) for h in ('c4e07a','8cbc48','5a8a30')]
    legmask[r0:bot+1]=np.isin(nat[r0:bot+1],GREEN)
    lab,n=comps(legmask)
    sizes=sorted([((lab==i).sum(),i) for i in range(1,n+1)],reverse=True)[:2]
    far=None
    if len(sizes)==2:
        L=[dict(i=i,cx=np.where(lab==i)[1].mean(),bot=np.where(lab==i)[0].max(),n=s) for s,i in sizes]
        back,front=sorted(L,key=lambda d:d['cx'])
        hi,lo=sorted(L,key=lambda d:d['bot'])  # hi = lifted (smaller bottom row)
        far={0:back,1:hi,2:front,3:lo}[k]
        m=lab==far['i']; cnt=0
        for y,x in zip(*np.where(m)):
            if nat[y,x] in DARKER: nat[y,x]=DARKER[nat[y,x]];cnt+=1
        notes.append('f%d: 2 leg blobs (x %.0f/%.0f, bottoms %d/%d); darkened %s leg, %d px'%(k,back['cx'],front['cx'],hi['bot'],lo['bot'],{0:'back',1:'lifted',2:'front',3:'planted'}[k],cnt))
    else: notes.append('f%d: found %d leg blobs, no shading'%(k,len(sizes)))
    # exterior outline where missing
    op=nat!=BG; add=0
    new=nat.copy()
    for y in range(N):
        for x in range(N):
            if op[y,x]: continue
            nb=[(y+dy,x+dx) for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)) if 0<=y+dy<N and 0<=x+dx<N]
            if any(op[p] and nat[p] not in (OUT,PAL_HEX.index('1c1814'),PAL_HEX.index('1a1210'),PAL_HEX.index('0b0706')) for p in nb):
                new[y,x]=OUT;add+=1
    nat=new
    # ensure feet on last row: shift down if empty bottom rows
    op=nat!=BG; ys_=np.where(op.any(1))[0]; sh=N-1-ys_.max()
    if sh>0: nat=np.roll(nat,sh,axis=0); nat[:sh]=BG
    notes[-1]+='; orphans removed %d, outline px added %d, bottom shift %d'%(rem,add,sh)
    final.append(nat)
used=set()
for k,nat in enumerate(final):
    rgba=np.zeros((N,N,4),np.uint8); op=nat!=BG
    rgba[op,:3]=PAL[nat[op]].astype(np.uint8); rgba[op,3]=255
    used|=set(np.unique(nat[op]).tolist())
    im=Image.fromarray(rgba); im.save('sprout_run%s_f%d_native%d.png'%(TAG,k,N)); im.resize((N*4,N*4),Image.NEAREST).save('sprout_run%s_f%d_x4.png'%(TAG,k))
print('\n'.join(notes)); print('colours used',len(used),sorted(PAL_HEX[i] for i in used))
open('sprout%s_notes.txt'%TAG,'w').write('cell %.2f\n'%cell+'\n'.join(notes)+'\ncolours %d %s\n'%(len(used),sorted(PAL_HEX[i] for i in used)))
# contact sheet x4 on dark bg + gif
ims=[Image.open('sprout_run%s_f%d_x4.png'%(TAG,k)).convert('RGBA') for k in range(4)]
cs=Image.new('RGBA',(N*4*4+5*8,N*4+16),(58,52,46,255))
for k,im in enumerate(ims): cs.alpha_composite(im,(8+k*(N*4+8),8))
cs.save('sprout_run%s_contact_x4.png'%TAG)
gf=[]
for im in ims:
    b=Image.new('RGBA',im.size,(58,52,46,255)); b.alpha_composite(im); gf.append(b.convert('P',palette=Image.ADAPTIVE))
gf[0].save('sprout_run%s_x4_8fps.gif'%TAG,save_all=True,append_images=gf[1:],duration=125,loop=0,disposal=2)
