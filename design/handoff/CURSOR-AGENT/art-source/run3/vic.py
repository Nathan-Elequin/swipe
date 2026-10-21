import sys,os,numpy as np
sys.path.insert(0,'.'); from touch import A,I,H,finish,DARK
P='final/_pre_touchup/'
SK={H(h) for h in ('9cc060','5a8a30','44702a','8cbc48','c4e07a','6a9a3a')}
def erase_hands(a,y0=30):
    a=a.copy(); Hh,W=a.shape[:2]
    m=np.zeros((Hh,W),bool)
    for y in range(y0,Hh):
        for x in range(W):
            if a[y,x,3] and tuple(a[y,x,:3]) in SK: m[y,x]=True
    for it in range(20):
        if not m.any(): break
        for y,x in zip(*np.where(m)):
            nb=[(y+dy,x+dx) for dy,dx in ((0,-1),(0,1),(-1,0),(1,0),(-1,-1),(1,1),(-1,1),(1,-1)) if 0<=y+dy<Hh and 0<=x+dx<W and a[y+dy,x+dx,3] and not m[y+dy,x+dx]]
            body=[tuple(a[q][:3]) for q in nb if tuple(a[q][:3]) not in DARK]
            if body:
                vals,c=np.unique(np.array(body),axis=0,return_counts=True); a[y,x,:3]=vals[c.argmax()]; m[y,x]=False
            elif it>15: a[y,x,3]=0; m[y,x]=False
    return a
def seg(a,p0,p1,r,cols,behind=False):
    (x0,y0),(x1,y1)=p0,p1; n=int(max(abs(x1-x0),abs(y1-y0))*3)+1
    for t in np.linspace(0,1,n):
        cx,cy=x0+(x1-x0)*t,y0+(y1-y0)*t; col=cols(t)
        for y in range(int(cy-r-1),int(cy+r+2)):
            for x in range(int(cx-r-1),int(cx+r+2)):
                d=np.hypot(x-cx,y-cy)
                if d<=r and 0<=y<64 and 0<=x<64:
                    if behind and a[y,x,3] and tuple(a[y,x,:3]) not in DARK: continue
                    side=(x-cx)+(y-cy)  # >0 = lower-right = shadow
                    c=col[0] if side<-0.5 else col[2] if side>0.6 else col[1]
                    a[y,x,:3]=H(c); a[y,x,3]=255
def fist(a,x,y,cols,behind=False):
    for yy in range(y,y+5):
        for xx in range(x,x+5):
            if behind and a[yy,xx,3] and tuple(a[yy,xx,:3])!=H('100e0c'): continue
            s=(xx-x)+(yy-y); a[yy,xx,:3]=H(cols[0] if s<3 else cols[2] if s>5 else cols[1]); a[yy,xx,3]=255
SLV=('8a6a40','7a4e2b','5a3a22'); SKIN=('c4e07a','9cc060','5a8a30'); SKB=('6a9a3a','44702a','44702a'); SLB=('7a4e2b','5a3a22','3b2618')
OL=lambda t:('100e0c',)*3
def arm(a,p0,p1,fx,fy,sl,sk,behind):
    seg(a,p0,p1,2.6,OL,behind); fist(a,fx-1,fy-1,('100e0c',)*3,behind) if False else None
    for yy in range(fy-1,fy+6):
        for xx in range(fx-1,fx+6):
            if 0<=yy<64 and 0<=xx<64 and not (behind and a[yy,xx,3] and tuple(a[yy,xx,:3]) not in DARK): a[yy,xx,:3]=H('100e0c'); a[yy,xx,3]=255
    seg(a,p0,p1,1.6,lambda t:sl if t<0.45 else sk,behind=False if not behind else 'in')
    fist(a,fx,fy,sk)
def raise_arms(a,lift=0):
    xs=I(a).getbbox()[0]; a=erase_hands(a)
    arm(a,(xs+9,35),(xs-1,11-lift),xs-5,4-lift,SLB,SKB,True)      # back arm, behind body
    arm(a,(xs+33,34),(xs+42,12-lift),xs+40,4-lift,SLV,SKIN,False) # front arm, right of face
    return a
v=[A(P+f'sprout64_victory_f{k}.png') for k in range(4)]
v[1]=raise_arms(v[1]); v[2]=raise_arms(v[2],lift=1)
for k in range(4): I(finish(v[k])).save(f'final/sprout64_victory_f{k}.png')
print(I(v[1]).getbbox())
