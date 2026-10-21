# Flat-block composition thumbnails, 420x260 native. Planning only, not final art.
from PIL import Image, ImageDraw
W,H=420,260
C=dict(ink='#100e0c',void='#0b0706',sky='#141a24',sky2='#1e2838',mtn='#222736',mtn2='#2a2a30',snow='#d9c79c',
 hill='#1e2a22',oak='#3a2414',oak2='#5a3a24',tan='#c4a574',cream='#fff3d6',gold='#e8c36a',torch='#f09a34',
 goblin='#7bc950',cloak='#2f8a8a',scarf='#d5443b',mon='#6a2e2e',mon2='#8a3a3a',drag='#b0502c',
 ghost='#4a5a6a',nib='#4a6a8a',hall='#2a2218',hall2='#3a3026',boot='#7a4ea0',helm='#4fa3d9',white='#ffffff')
def base(d,sky_h=150):
    d.rectangle([0,0,W,H],fill=C['sky'])
    d.rectangle([0,0,W,60],fill=C['void'])
def mountain(d,peak=(210,30),bw=230,col='mtn',snow=True):
    x,y=peak; d.polygon([(x-bw,H),(x,y),(x+bw,H)],fill=C[col])
    d.polygon([(x-bw*0.6,H),(x-bw*0.2,y+50),(x+bw*0.1,H)],fill=C['mtn2'])
    if snow: d.polygon([(x-14,y+16),(x,y),(x+14,y+16),(x+5,y+12),(x-4,y+18)],fill=C['snow'])
def stars(d):
    for i in range(40):
        x=(i*97)%W; y=(i*53)%110
        d.point((x,y),fill=C['cream'])
def sprout(d,x,y,s=1.0,throw=False):
    # x,y = feet centre. ~ 64*s tall
    h=int(64*s); w=int(30*s)
    d.ellipse([x-w*1.1,y-h*0.95,x+w*0.1,y-h*0.35],fill=C['oak2'],outline=C['ink'])  # sack on back (left)
    d.rectangle([x-w//2,y-h*0.6,x+w//2,y],fill=C['cloak'],outline=C['ink'])        # body/cloak
    d.rectangle([x-w//2,y-h*0.62,x+w//2,y-h*0.55],fill=C['scarf'])
    d.ellipse([x-w*0.45,y-h,x+w*0.55,y-h*0.58],fill=C['goblin'],outline=C['ink'])   # head
    d.polygon([(x+w*0.5,y-h*0.85),(x+w*1.0,y-h*0.95),(x+w*0.5,y-h*0.75)],fill=C['goblin'])  # ear R
    d.point((x+int(w*0.3),y-int(h*0.82)),fill=C['ink'])  # eye facing right
    if throw: d.line([x,y-h*0.5,x-w*1.3,y-h*1.05],fill=C['goblin'],width=max(2,int(4*s)))
def loot(d,x,y,col,r=7,glow=True):
    if glow: d.ellipse([x-r-4,y-r-4,x+r+4,y+r+4],fill='#5a4a24')
    d.rectangle([x-r,y-r,x+r,y+r],fill=C[col] if col in C else col,outline=C['ink'])
def monster(d,x,y,w,h,col='mon',face=True,facing=1):
    d.rectangle([x-w//2,y-h,x+w//2,y],fill=C[col],outline=C['ink'])
    if face:
        ex=x+facing*w//4; d.rectangle([ex-2,y-h+h//4,ex+1,y-h+h//4+2],fill=C['torch'])
def cabin_ghost(d,x,y,s=1.0,lantern=True):
    w=int(34*s);h=int(22*s)
    d.polygon([(x-w//2-4,y-h),(x,y-h-int(16*s)),(x+w//2+4,y-h)],fill=C['ghost'])
    d.rectangle([x-w//2,y-h,x+w//2,y],fill=C['ghost'])
    d.rectangle([x-w//4-3,y-h+6,x-w//4+3,y-h+12],fill=C['torch'])
    if lantern:
        d.rectangle([x+w//2+6,y-14,x+w//2+12,y],fill=C['nib'])  # Nib
        d.ellipse([x+w//2+12,y-14,x+w//2+18,y-8],fill=C['gold'])
def rects(d):
    for r,c in [((85,20,250,40),'#e8c36a'),((65,62,290,21),'#fff3d6'),((120,65,180,130),'#d5443b'),((85,230,250,20),'#c9b9a8')]:
        x,y,w,h=r; d.rectangle([x,y,x+w-1,y+h-1],outline=c)
    # face-safe zones (upper 45% outer corners) as dashed-ish ticks
    for x0,x1 in [(0,64),(356,419)]:
        for xx in range(x0,x1,4): d.point((xx,116),fill='#7bc950')

def A(d):  # Throw to keep
    base(d); stars(d); mountain(d,(200,40),260)
    d.rectangle([150,150,270,260],fill=C['void'])                    # mountain mouth (centre, no faces)
    d.polygon([(150,150),(210,128),(270,150)],fill=C['void'])
    cabin_ghost(d,36,64,0.9)                                           # ghost cabin + Nib, upper-left corner
    d.rectangle([0,200,W,H],fill=C['hall'])                           # floor band
    sprout(d,385,112,1.25,throw=True)                                  # hero upper-right corner, mid-throw
    for i,(x,y,c) in enumerate([(360,40,'gold'),(406,34,'scarf'),(372,22,'tan'),(396,52,'gold')]): loot(d,x,y,c,5)  # kept loot halo
    loot(d,300,150,'boot',6,False); loot(d,250,185,'helm',6,False)   # spent arc down into the crowd
    for x,y,w,h,c in [(30,250,40,46,'mon2'),(80,256,36,30,'mon'),(330,256,40,40,'drag'),(380,258,46,34,'mon2'),(130,258,30,24,'mon'),(285,258,30,26,'mon')]:
        monster(d,x,y,w,h,c,facing=1 if x<210 else -1)
def B(d):  # Loot river out of the Bellyvault
    base(d); stars(d); mountain(d,(210,20),300)
    d.ellipse([170,110,250,200],fill=C['void'])                      # belly mouth centre
    for i in range(9):                                                 # loot river spilling down-left
        loot(d,205-i*22,150+i*9 - (i%2)*6,['gold','tan','scarf','gold','boot','helm','gold','tan','gold'][i],5)
    d.polygon([(0,170),(140,190),(150,260),(0,260)],fill=C['hill'])    # Kettle Hill lower-left
    cabin_ghost(d,40,196,1.1)
    sprout(d,40,110,1.2)                                                # hero upper-left, on slope, facing right toward mountain
    loot(d,70,52,'gold',5); loot(d,16,48,'scarf',5)
    monster(d,385,100,60,70,'drag',facing=-1)                          # dragon face upper-right
    monster(d,345,112,30,30,'mon',facing=-1)
    for x,y,w,h in [(330,260,40,40),(380,260,36,50),(285,260,30,22)]: monster(d,x,y,w,h,'mon2',facing=-1)
    d.line([260,200,330,225],fill=C['boot'],width=3)                   # thrown boot streak into ogre
def Cc(d):  # Tug of war
    base(d); stars(d); mountain(d,(210,30),280); mountain(d,(110,80),120,'mtn2',False)
    cabin_ghost(d,340,236,0.9)                                          # ghost cabin far below right, below hub
    d.rectangle([0,205,W,H],fill=C['hall'])
    sprout(d,52,112,1.4)                                                 # hero upper-left, heels dug in
    d.line([20,60,300,70],fill=C['tan'],width=3)                         # sack strap stretched across the top (over tagline gap)
    d.ellipse([280,40,330,95],fill=C['oak2'],outline=C['ink'])          # sack in dragon's claw
    monster(d,385,112,64,80,'drag',facing=-1)                           # dragon face upper-right
    for (x,y,c) in [(200,120,'gold'),(230,150,'scarf'),(170,165,'tan'),(260,180,'gold'),(150,130,'gold')]: loot(d,x,y,c,5)  # loot spilling in the hub hole (no faces)
    loot(d,330,30,'boot',6,False); loot(d,120,195,'helm',6,False)     # boot bouncing off dragon nose; dented helm dropped
    for x,y,w,h,c in [(20,258,36,30,'mon'),(70,258,30,40,'mon2'),(400,258,36,30,'mon')]: monster(d,x,y,w,h,c,facing=1)
out='<TITLE_TEASER>/thumbs/'
sheet=Image.new('RGB',(W*2*3+40,H*2*2+30),'#100e0c')
for i,(n,f) in enumerate([('A_throw_to_keep',A),('B_loot_river',B),('C_tug_of_war',Cc)]):
    im=Image.new('RGB',(W,H)); f(ImageDraw.Draw(im)); im.save(out+f'still_{n}.png')
    ov=im.copy(); rects(ImageDraw.Draw(ov)); ov.save(out+f'still_{n}_rects.png')
    sheet.paste(im.resize((W*2,H*2),Image.NEAREST),(10+i*(W*2+10),10))
    sheet.paste(ov.resize((W*2,H*2),Image.NEAREST),(10+i*(W*2+10),20+H*2))
sheet.save(out+'_contact_2x.png')
