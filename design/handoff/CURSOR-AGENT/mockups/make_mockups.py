# Static mockups composited from the real 1680x1040 midfight capture + PixelLab finals.
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import math
SRC='<ANIM_PITCH>/src/shots/midfight.png'
PL3='<ART_KIT>/pixellab/run3/final/'; PL2='<ART_KIT>/pixellab/run2/final/'
OUT='<ANIM_PITCH>/mockups/'
B='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
def F(n): return ImageFont.truetype(B,n)
GOLD=(232,195,106); INK=(240,230,216); OUTL=(16,14,12)

def up(im,k): return im.resize((im.width*k,im.height*k),Image.NEAREST)

def claw_badge(lit=False, spent=False):
    """16x16 native claw badge (placeholder for PixelLab art), returned at 4x."""
    s=Image.new('RGBA',(16,16),(0,0,0,0)); d=ImageDraw.Draw(s)
    rim=(255,240,192) if lit else (16,14,12)
    fill=(196,40,32) if lit else (106,28,20)
    if spent: fill=(58,56,52)
    # rounded shield / paw blob
    d.rounded_rectangle((1,2,14,15),radius=4,fill=fill,outline=rim)
    # three claw rakes across the top
    for x in (4,7,10):
        d.line((x,1,x+2,5),fill=(240,230,216) if not spent else (138,130,120))
    return up(s,4)

def num(d,cx,cy,t,size=30,col=INK):
    f=F(size); w,h=d.textbbox((0,0),t,font=f)[2:]
    d.text((cx-w/2,cy-h/2-2),t,font=f,fill=col,stroke_width=3,stroke_fill=OUTL)

def burst(d,cx,cy,r,col):
    for k in range(10):
        a=k*math.pi/5+0.3
        d.line((cx+math.cos(a)*r*0.55,cy+math.sin(a)*r*0.55,cx+math.cos(a)*r,cy+math.sin(a)*r),fill=col,width=5)

def label(d,xy,t,size=18,col=GOLD,anchor='la'):
    d.text(xy,t,font=F(size),fill=col,stroke_width=3,stroke_fill=OUTL,anchor=anchor)

# ---------- 1. Intent plate: Hornet Swarm, two '2' badges, first hit landing ----------
im=Image.open(SRC).convert('RGBA')
ov=Image.new('RGBA',im.size,(0,0,0,0)); d=ImageDraw.Draw(ov)
# dim everything but the faced Hornet slice region
dim=Image.new('RGBA',im.size,(0,0,0,90)); dd=ImageDraw.Draw(dim)
dd.ellipse((600,350,770,520),fill=(0,0,0,0))
im=Image.alpha_composite(im,dim)
# plate: dark capsule with a tail pointing at the hornet portrait (685,438)
px,py=420,300; pw,ph=180,96
d.rounded_rectangle((px,py,px+pw,py+ph),radius=14,fill=(20,15,12,235),outline=GOLD,width=3)
d.polygon([(px+pw-30,py+ph-4),(px+pw+0,py+ph-4),(650,404)],fill=(20,15,12,235))
d.line([(px+pw-30,py+ph-2),(650,404)],fill=GOLD,width=3); d.line([(px+pw,py+ph-14),(650,404)],fill=GOLD,width=3)
im=Image.alpha_composite(im,ov); d=ImageDraw.Draw(im)
b1=claw_badge(lit=True); b2=claw_badge()
x1,x2,yb=px+16,px+100,py+16
burst(d,x1+32,yb+34,52,(255,214,120))
im.alpha_composite(b1,(x1,yb)); im.alpha_composite(b2,(x2,yb)); d=ImageDraw.Draw(im)
num(d,x1+32,yb+38,'2'); num(d,x2+32,yb+38,'2',col=(201,185,168))
# hit 1 lands: red slash toward hub hearts
d.line([(x1+60,yb+10),(800,300)],fill=(255,214,120),width=3)
# Take button now reads Take 4 (two swings of 2), patch over 'Take 1'
d.rectangle((700,765,808,805),fill=(232,220,190)); label(d,(754,785),'Take 4',24,(106,18,18),'mm')
# callouts (design notes, not in-game text)
label(d,(40,120),'MOCKUP 1  Intent plate',26,GOLD)
label(d,(40,156),'Facing Hornet Swarm: one claw badge per incoming hit, number inside.',18,INK)
label(d,(40,182),'Hit 1 is landing: badge 1 lights + bursts. Badge 2 waits (dim) for hit 2.',18,INK)
label(d,(40,208),'No word "ATK". Badges are 16x16 native at 4x (64px).',18,INK)
im.convert('RGB').save(OUT+'mock_intent_plate_hornet.png')

# ---------- 2. Slash portrait mid cut-in: Ogre roars (Empath) ----------
im=Image.open(SRC).convert('RGBA')
im=Image.alpha_composite(im,Image.new('RGBA',im.size,(0,0,0,120)))
ov=Image.new('RGBA',im.size,(0,0,0,0)); d=ImageDraw.Draw(ov)
band=[(-40,620),(1720,250),(1720,600),(-40,970)]
d.polygon(band,fill=(10,7,6,235))
# speed lines inside band, parallel to the band slope
slope=(250-620)/1760
import random; random.seed(4)
for _ in range(70):
    x=random.randint(-40,1700); y0=620+slope*(x+40); off=random.randint(20,330); L=random.randint(60,260)
    d.line([(x,y0+off),(x+L,y0+off+slope*L)],fill=(240,230,216,random.randint(40,120)),width=random.choice([1,2,3]))
d.line([band[0],band[1]],fill=GOLD,width=6); d.line([band[3],band[2]],fill=GOLD,width=4)
# red roar flash behind portrait
d.ellipse((520,330,980,790),fill=(160,30,24,110))
im=Image.alpha_composite(im,ov.filter(ImageFilter.GaussianBlur(0.6))); d=ImageDraw.Draw(im)
ogre=Image.open(PL2+'mon_ogre_f2.png').convert('RGBA')
port=up(ogre,6)  # 48 native -> 288px (portrait canvas is free-size per monster)
im.alpha_composite(port,(606,416))
# roar shock rings
for r in (170,200):
    d.arc((750-r,560-r,750+r,560+r),200,340,fill=(255,240,192),width=3)
label(d,(1000,560),'Ogre',34,INK)
label(d,(1000,604),'Empath',44,GOLD)
label(d,(1000,660),'When you lose HP, I lose equal HP.',20,(216,203,184))
label(d,(40,40),'MOCKUP 2  Slash portrait (mid cut-in, frame 3 of 5)',26,GOLD)
label(d,(40,76),'Band snaps in from the left (120ms), portrait plays its 4-6f action, band slashes out (160ms).',18,INK)
im.convert('RGB').save(OUT+'mock_slash_portrait_ogre.png')

# ---------- 3. Hotbar shimmer (Weak copper / Tough silver) + 2x inset ----------
im=Image.open(SRC).convert('RGBA')
cards=[((572,838,700,1010),(212,137,78)),((708,838,836,1010),(212,137,78)),
       ((844,838,972,1010),(212,137,78)),((980,838,1108,1010),(244,247,251))]
for i,(r,col) in enumerate(cards):
    x0,y0,x1,y1=r; w,h=x1-x0,y1-y0
    g=Image.new('RGBA',(w,h),(0,0,0,0)); gd=ImageDraw.Draw(g)
    t=[0.25,0.55,0.8,0.4][i]   # each card caught at a different glint phase
    cx=int(-h+t*(w+h*2))
    gd.polygon([(cx,0),(cx+26,0),(cx+26-h,h),(cx-h,h)],fill=col+(110,))
    gd.polygon([(cx+34,0),(cx+42,0),(cx+42-h,h),(cx+34-h,h)],fill=col+(70,))
    mask=Image.new('L',(w,h),0); ImageDraw.Draw(mask).rounded_rectangle((3,3,w-4,h-4),radius=8,fill=255)
    g.putalpha(Image.composite(g.split()[3],Image.new('L',(w,h),0),mask))
    im.alpha_composite(g,(x0,y0))
    ImageDraw.Draw(im).rounded_rectangle((x0+1,y0+1,x1-1,y1-1),radius=9,outline=col+(255,),width=3)
d=ImageDraw.Draw(im)
# Deadly sparkle sample (gold) on a ghost slot to the right
gx,gy=1130,850
d.rounded_rectangle((gx,gy,gx+128,gy+160),radius=9,outline=(255,230,168),width=3)
for (sx,sy) in [(gx+30,gy+40),(gx+96,gy+110),(gx+70,gy+20)]:
    d.line((sx-8,sy,sx+8,sy),fill=(255,230,168),width=3); d.line((sx,sy-8,sx,sy+8),fill=(255,230,168),width=3)
label(d,(gx+64,gy+80),'Deadly',18,(255,230,168),'mm'); label(d,(gx+64,gy+104),'(sample)',14,(201,185,168),'mm')
# inset 2x of the hotbar at top-right
crop=im.crop((560,830,1270,1015)); inset=crop.resize((crop.width*2//1,crop.height*2//1),Image.NEAREST)
inset=inset.crop((0,0,min(inset.width,1020),inset.height))
ImageDraw.Draw(im).rectangle((620-4,40-4,620+inset.width+4,40+inset.height+4),fill=GOLD)
im.alpha_composite(inset,(620,40)); d=ImageDraw.Draw(im)
label(d,(40,60),'MOCKUP 3  Hotbar shimmer',26,GOLD)
label(d,(40,96),'Weak = copper, slow glint',18,(212,137,78))
label(d,(40,122),'Tough = silver, medium glint',18,(244,247,251))
label(d,(40,148),'Deadly = gold, fast glint + sparkle',18,(255,230,168))
label(d,(40,184),'Rank words only in tooltips/door.',16,INK)
label(d,(40,206),'The word "Tier" never shows.',16,INK)
im.convert('RGB').save(OUT+'mock_hotbar_shimmer.png')
print('done')
