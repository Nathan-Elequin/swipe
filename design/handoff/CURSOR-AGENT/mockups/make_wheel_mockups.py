# Wheel monster redesign mockups over Nathan's 1680x1006 screenshot.
from PIL import Image, ImageDraw, ImageFont
import math
REF='<ANIM_PITCH>/src/shots/wheel_ref.png'
SPR='<ANIM_PITCH>/src/sprites/'
OUT='<ANIM_PITCH>/mockups/'
FB='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
CX,CY,R,HUB=839.5,438.5,406,139
BANDS=[(0.70,None),(0.86,None)]  # glow <0.70R, wash <0.86R, base outside
COL={'red':[(164,74,57),(158,61,42),(148,41,20)],'orange':[(152,100,61),(144,88,47),(133,71,25)]}
MON=[ # id, name, call, mid-angle deg (screen, y down), slice colour, atk, hp, call colour
 ('commander','Commander','War Cry',202.5,'red',3,3,(232,150,60)),
 ('merchant','Merchant','Fair Trade',-67.5,'orange',4,4,(232,195,106)),
 ('eel','Eel','Conductive',22.5,'orange',6,4,(232,150,60)),
 ('vampire','Vampire','Bloodlust',112.5,'red',4,4,(232,150,60)),
]
GOLD=(232,195,106); INK=(240,230,216); OUTL=(16,14,12)
def F(n): return ImageFont.truetype(FB,n)

def wedge(d,r0,r1,a0,a1,col):
    pts=[]; n=40
    for k in range(n+1):
        a=math.radians(a0+(a1-a0)*k/n); pts.append((CX+math.cos(a)*r1,CY+math.sin(a)*r1))
    for k in range(n,-1,-1):
        a=math.radians(a0+(a1-a0)*k/n); pts.append((CX+math.cos(a)*r0,CY+math.sin(a)*r0))
    d.polygon(pts,fill=col)

def native(n):
    im=Image.open(SPR+n+'.png').convert('RGBA'); im=im.crop(im.getbbox())
    return im.resize((im.width//4,im.height//4),Image.NEAREST)  # art is stored at 4x

def star(d,c,r,fill,edge):
    pts=[]
    for k in range(16):
        a=-math.pi/2+k*math.pi/8; rr=r if k%2==0 else r*0.74
        pts.append((c[0]+math.cos(a)*rr,c[1]+math.sin(a)*rr))
    d.polygon(pts,fill=fill,outline=edge); d.line(pts+[pts[0]],fill=edge,width=3)

def heart(d,c,r,fill,edge):
    x,y=c; s=r
    pts=[]
    for k in range(60):
        t=k/60*2*math.pi
        hx=16*math.sin(t)**3; hy=-(13*math.cos(t)-5*math.cos(2*t)-2*math.cos(3*t)-math.cos(4*t))
        pts.append((x+hx*s/17,y+hy*s/17+s*0.1))
    d.polygon(pts,fill=fill); d.line(pts+[pts[0]],fill=edge,width=3)

def num(d,c,t,size):
    d.text(c,t,font=F(size),fill=INK,stroke_width=3,stroke_fill=OUTL,anchor='mm')

def banner(im,center,ang_deg,name,call,ccol,w,scale=1.0):
    h=int(54*scale); W=int(w)
    b=Image.new('RGBA',(W+40,h+12),(0,0,0,0)); d=ImageDraw.Draw(b)
    # ribbon tails
    d.polygon([(4,14),(26,10),(26,h-2),(4,h+2),(14,(h+12)//2)],fill=(70,22,14,255),outline=OUTL)
    d.polygon([(W+36,14),(W+14,10),(W+14,h-2),(W+36,h+2),(W+26,(h+12)//2)],fill=(70,22,14,255),outline=OUTL)
    d.rounded_rectangle((18,4,W+22,h+4),radius=10,fill=(22,16,12,240),outline=GOLD,width=3)
    d.text(((W+40)//2,4+h*0.36),name,font=F(int(21*scale)),fill=INK,stroke_width=3,stroke_fill=OUTL,anchor='mm')
    d.text(((W+40)//2,4+h*0.74),call,font=F(int(15*scale)),fill=ccol,stroke_width=3,stroke_fill=OUTL,anchor='mm')
    rot=-ang_deg
    r=b.rotate(rot,resample=Image.BICUBIC,expand=True)
    im.alpha_composite(r,(int(center[0]-r.width/2),int(center[1]-r.height/2)))

FULL=[('vampire','Vampire','Bloodlust',-112.5,'red',4,4,(232,150,60)),('eel','Eel','Conductive',-22.5,'orange',6,4,(232,150,60)),
      ('merchant','Merchant','Fair Trade',67.5,'orange',4,4,(232,195,106)),('commander','Commander','War Cry',157.5,'red',3,3,(232,150,60))]
def build(target_native, fname, title, full=False):
    global MON
    base=MON; MON=MON+FULL if full else MON
    im=Image.open(REF).convert('RGBA'); d=ImageDraw.Draw(im)
    for mid,(mid_id,_,_,ang,cname,*_) in [(m[0],m) for m in MON]:
        a0,a1=ang-22.5+0.5,ang+22.5-0.5; c=COL[cname]
        wedge(d,HUB+3,0.70*R,a0,a1,c[0]); wedge(d,0.70*R,0.86*R,a0,a1,c[1]); wedge(d,0.86*R,R-4,a0,a1,c[2])
    for mid,name,call,ang,cname,atk,hp,ccol in MON:
        a=math.radians(ang); ux,uy=math.cos(a),math.sin(a)
        spr=native(mid)
        k=max(1,round(target_native*4/spr.height))   # integer scale; 16px sources = placeholder
        big=spr.resize((spr.width*k,spr.height*k),Image.NEAREST)
        rc=0.56*R                                    # sprite centre radius
        sx,sy=CX+ux*rc,CY+uy*rc
        feet=(sx,sy+big.height/2)
        # floor shadow
        sh=Image.new('RGBA',im.size,(0,0,0,0)); ImageDraw.Draw(sh).ellipse((feet[0]-big.width*0.45,feet[1]-9,feet[0]+big.width*0.45,feet[1]+9),fill=(10,6,4,120))
        im.alpha_composite(sh)
        # 1px-native dark outline like _draw_tex_outline, at k px
        alpha=big.split()[3]; ol=Image.new('RGBA',big.size,OUTL+(255,)); ol.putalpha(alpha)
        for ox,oy in [(-k,0),(k,0),(0,-k),(0,k)]:
            im.alpha_composite(ol,(int(sx-big.width/2+ox),int(sy-big.height/2+oy)))
        im.alpha_composite(big,(int(sx-big.width/2),int(sy-big.height/2)))
        d=ImageDraw.Draw(im)
        br=26 if target_native==24 else 28
        gap=big.width/2+br-6
        star(d,(feet[0]-gap,feet[1]-br*0.6),br,(196,90,20),(240,160,64)); num(d,(feet[0]-gap,feet[1]-br*0.6),str(atk),26)
        heart(d,(feet[0]+gap,feet[1]-br*0.6),br,(196,40,42),(240,230,216)); num(d,(feet[0]+gap,feet[1]-br*0.6),str(hp),26)
        if k*4!=target_native*4 or spr.height*k!=target_native*4:
            d.text((sx,sy-big.height/2-6),f'placeholder {spr.width}x{spr.height} @{k}x',font=F(11),fill=(255,255,255),stroke_width=2,stroke_fill=OUTL,anchor='md')
        # nameplate banner along the tangent, in the outer band
        tilt=ang+90
        while tilt>90: tilt-=180
        while tilt<-90: tilt+=180
        if abs(ux)>0.7:   # side slices: horizontal plate under the feet
            banner(im,(sx,feet[1]+40),0,name,call,ccol,w=150)
        else:             # top/bottom slices: plate in the outer band, tilted with the slice
            rb=0.885*R
            banner(im,(CX+ux*rb,CY+uy*rb),max(-25,min(25,tilt)),name,call,ccol,w=150)
    d=ImageDraw.Draw(im)
    d.text((24,24),title,font=F(24),fill=GOLD,stroke_width=3,stroke_fill=OUTL)
    d.text((24,56),'No frame: sprite on a floor shadow; slice colour = Weak/Tough/Deadly. Attack star + HP heart flank the feet. Nameplate along the slice.',font=F(15),fill=INK,stroke_width=3,stroke_fill=OUTL)
    im.convert('RGB').save(OUT+fname); MON=base
build(24,'wheel_bigger_24x4.png','MOCKUP A  Wheel monsters 24 native @4x = 96px')
build(32,'wheel_bigger_32x4.png','MOCKUP B  Wheel monsters 32 native @4x = 128px')
build(24,'wheel_bigger_24x4_full8.png','FIT TEST A  8 of 8 slots filled (duplicates), 96px',True)
build(32,'wheel_bigger_32x4_full8.png','FIT TEST B  8 of 8 slots filled (duplicates), 128px',True)
print('ok')
