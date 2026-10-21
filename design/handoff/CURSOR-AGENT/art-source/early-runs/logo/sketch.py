import numpy as np, math
from PIL import Image
INK=(16,14,12,255); G1=(197,205,216,255); G2=(138,138,156,255); G3=(92,100,116,255); G4=(58,58,68,255)
DARK=(26,18,16,255); GOLD=(255,216,74,255); EYE=(255,216,74,255); HUB1=(168,172,180,255)
def sketch(n):
    a=np.zeros((n,n,4),np.uint8); c=(n-1)/2; R=n/2-1.0
    for y in range(n):
        for x in range(n):
            dx,dy=x-c,y-c; d=math.hypot(dx,dy); ang=math.degrees(math.atan2(dy,dx))%360
            if d<=R-0.5:
                lit=(-dx-dy)/(R*1.41)
                if d>R*0.62:  # outer stone ring
                    col=G1 if lit>0.45 else G2 if lit>-0.2 else G3
                    # doorways at 45,135,225,315
                    if min(abs(((ang-45)%90)-45+45-45),99)<0: pass
                    da=min(abs(((ang+45)%90)-45),99)
                    if da<10 and d<R-1.5: col=DARK
                    if d>R-1.6 and lit>0.35: col=GOLD
                    # block seams
                    if abs(((ang)%30))<360/(2*math.pi*d) and da>=10: col=G4
                elif d>R*0.32:  # corridors floor ring (dark) with 4 corridors spokes stone
                    da=min(abs(((ang)%90)-45),99)
                    col=DARK if da>20 else G3
                    corr=min(abs(((ang+45)%90)-45),99)
                    col=DARK if corr*math.pi/180*d<1.0 else G2
                else:
                    col=HUB1 if lit>0 else G2
                    if lit>0.4: col=G1
                a[y,x]=col
            elif d<=R+0.6: a[y,x]=INK
    return a
for n in (32,16):
    a=sketch(n); im=Image.fromarray(a,'RGBA')
    # eyes in doorways
    c=(n-1)/2; R=n/2-1.0
    for ang in (45,135,225,315):
        r=R*0.78; x=c+r*math.cos(math.radians(ang)); y=c+r*math.sin(math.radians(ang))
        im.putpixel((int(round(x)),int(round(y))),EYE)
        if n==32: im.putpixel((int(round(x))+1,int(round(y))),EYE)
    im.save(f'logo/sketch_{n}.png'); im.resize((n*8,n*8),0).save(f'logo/sketch_{n}_x8.png')
