import numpy as np, sys
from PIL import Image
from common import *
src=np.asarray(Image.open('../returns/title_still_v3_raw.jpg').convert('RGB')).astype(float)
H,W,_=src.shape; g=src.mean(-1)
def phase(p,axis):
    d=np.abs(np.diff(g,axis=1-axis)).sum(axis=axis); d=d-d.mean(); n=np.arange(len(d))
    best=(0,None)
    for pp in np.arange(p-0.08,p+0.081,0.005):
        z=(d*np.exp(-2j*np.pi*n/pp)).sum()
        if abs(z)>best[0]: best=(abs(z),pp,np.angle(z))
    _,pp,ang=best; edge=(ang/(2*np.pi))*pp % pp   # position of edges (cell boundaries) ~ +0.5 offset from diff index
    return pp, (edge+0.5)%pp
px,ox=phase(3.15,0); py,oy=phase(3.15,1)
cell=(px+py)/2
print('cell x %.3f y %.3f -> native %.1f x %.1f, phase %.2f %.2f'%(px,py,W/px,H/py,ox,oy))
# pad to 420x260 cells, centred, edge replicate
needW=420*cell; needH=260*cell
padx=(needW-W)/2; pady=(needH-H)/2
print('pad x %.1f px each side, y %.1f'%(padx,pady))
# shift so that a cell boundary sits on the pad start
ox0=ox-padx; ox0-=np.floor(ox0/cell)*cell  # boundary in padded coords
pl=int(np.ceil(padx+cell)); pt=int(np.ceil(pady+cell))
P=np.pad(src,((pt,pt),(pl,pl),(0,0)),mode='edge')
# boundary positions in P coordinates
bx=ox+pl; by=oy+pt
# choose start so 420 cells centred
cx=(pl+W/2)-210*cell; cy=(pt+H/2)-130*cell
sx=bx+np.round((cx-bx)/cell)*cell; sy=by+np.round((cy-by)/cell)*cell
EXTRA=['7a6aa8','4a3a78','2e2450','aaa2c6','766e9a','4a446a','3e8ea8','7a9af0','633f2b','8c5228']
import sys
if 'ext' in sys.argv: PAL=np.vstack([PAL,np.array([hex2rgb(h) for h in EXTRA],float)])
TAG='_ext' if 'ext' in sys.argv else ''
idx=snap_idx(P,PAL)
nat=mode_cells(idx,cell,420,260,sx,sy)
nat,n=despeckle(nat); print('despeckled',n)
used=np.unique(nat); print('palette colours used after snap:',len(used))
img=PAL[nat].astype(np.uint8)
Image.fromarray(img).save('title_still_v3_native_420x260%s.png'%TAG)
Image.fromarray(img).resize((1680,1040),Image.NEAREST).save('title_still_v3_clean_1680x1040%s.png'%TAG)
# glow check: also extended palette = PAL + k extra colours from residual in glow region
np.save('title_nat_idx%s.npy'%TAG,nat)
open('title_stats%s.txt'%TAG,'w').write('cell %.3f %.3f native %.1f x %.1f pad x %.1f y %.1f colours %d despeckled %d\n'%(px,py,W/px,H/py,padx,pady,len(used),n))
