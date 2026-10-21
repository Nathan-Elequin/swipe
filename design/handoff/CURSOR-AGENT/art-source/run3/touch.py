import sys,os,numpy as np
sys.path.insert(0,'.'); from clean3 import clean
from PIL import Image
os.chdir('<ART_KIT>/pixellab/run3')
P='final/_pre_touchup/'
H=lambda h: tuple(int(h[i:i+2],16) for i in (0,2,4))
def A(p): return np.array(Image.open(p).convert('RGBA'))
def I(a): return Image.fromarray(a.astype(np.uint8))
DARK={H(h) for h in ('100e0c','0c0e16','121620','1a1210','0b0706','1c1814')}
def ringfix(a):
    op=a[...,3]>0; pad=np.pad(op,1); nb=~(pad[:-2,1:-1]&pad[2:,1:-1]&pad[1:-1,:-2]&pad[1:-1,2:])
    for y,x in zip(*np.where(op&nb)):
        if tuple(a[y,x,:3]) in DARK: a[y,x,:3]=H('100e0c')
    return a
def finish(a,bottom=True):
    return ringfix(np.array(clean(I(a),bottom=bottom)))
# 1) wolf relight
RAMP=[H(h) for h in ('0c0e16','121620','1a1e2a','222736','2e3448','3e4254','484e60','5c6474','8a8a9c','a8acb4')]
from scipy.ndimage import gaussian_filter
def relight(a):
    op=(a[...,3]>0).astype(float); b=gaussian_filter(op,1.6)
    gy,gx=np.gradient(b); mag=np.hypot(gx,gy)+1e-6; nx=-gx/mag; w=np.clip(mag*6,0,1)
    o=a.copy()
    for y,x in zip(*np.where(op>0)):
        c=tuple(a[y,x,:3])
        if c not in RAMP: continue
        d=int(np.round(-2.0*nx[y,x]*w[y,x]))
        o[y,x,:3]=RAMP[int(np.clip(RAMP.index(c)+d,1 if c!=RAMP[0] else 0,len(RAMP)-1))]
    return o
for f in ['mon_dire_wolf_base']+[f'mon_dire_wolf_gallop_f{k}' for k in range(4)]:
    I(finish(relight(A(P+f+'.png')))).save(f'final/{f}.png')
# 2) hurt
def lean(a,s,tilt):
    o=np.zeros_like(a); Hh=a.shape[0]
    for y in range(Hh):
        sh = s+(tilt if y<14 else 0) if y<36 else int(round(s*(46-y)/10)) if y<46 else 0
        o[y]=np.roll(a[y],-sh,axis=0)
    return o
hurt=[A(P+f'sprout64_hurt_f{k}.png') for k in range(4)]
hurt[2]=lean(hurt[2],2,1); hurt[3]=lean(hurt[3],3,1)
for k in range(4): I(finish(hurt[k])).save(f'final/sprout64_hurt_f{k}.png')
a=A('final/sprout64_hurt_f1.png'); op=a[...,3]>0
pad=np.pad(op,1); edge=op&~(pad[:-2,1:-1]&pad[2:,1:-1]&pad[1:-1,:-2]&pad[1:-1,2:])
a[op,:3]=H('f8f8fc'); a[edge,:3]=H('100e0c'); I(a).save('final/sprout64_hurt_f1_flash.png')
# 4) blink 2-frame
b=A(P+'sprout64_blink_f0.png'); I(b).save('final/sprout64_blink_f0.png'); c=b.copy()
c[15:20,39:43,:3]=H('9cc060'); c[18,39:43,:3]=H('1c1814'); c[19,42,:3]=H('1c1814')
I(c).save('final/sprout64_blink_f1.png')
for k in (2,3):
    p=f'final/sprout64_blink_f{k}.png'
    if os.path.exists(p): os.remove(p)
# 5) scroll
op_=A(P+'intro_scroll_unfurl_f1.png'); rolled=A(P+'intro_scroll_unfurl_f0.png')
top=op_[1:12]; paper=op_[12:32]; bot=op_[32:43]
def part(h):
    st=np.concatenate([top,paper[:h],bot],0); o=np.zeros_like(op_); o[48-st.shape[0]:]=st; return o
fr=[rolled,part(7),part(13),part(20)]
for k,f in enumerate(fr): I(finish(f)).save(f'final/intro_scroll_unfurl_f{k}.png')
print('ok')
