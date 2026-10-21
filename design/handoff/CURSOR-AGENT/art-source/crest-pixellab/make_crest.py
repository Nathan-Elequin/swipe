# B1 (round medallion crest) / B2 (heraldic shield crest) set into a notched name tag, full 8, 1680x1040.
# Tag + crest at 3x Nearest (same scale as the ATK/HP badges); icon baked into the crest at native size.
import sys; sys.path.insert(0,'<ANIM_PITCH>/mockups/layouts')
import make_layouts as L
from make_layouts import base, draw_sprite, badge, txt, tw, F, MON, EX, IC, U, up, plate, header, GOLD, INK, ORNG, OUTL, CX, CY, R
from PIL import Image, ImageDraw
D='<ANIM_PITCH>/mockups/layouts/crest/'; C=D+'clean/'; S=3
OUT_=(16,14,12,255)
def fix_tag(t):   # hand fix: PixelLab dithered the outer outline; make the border ring solid #100e0c
    t=t.copy(); px=t.load(); W,H=t.size
    for x in range(W):
        for y in (0,H-1):
            if px[x,y][3] and not (abs(x-47.5)<12 and y==H-1): px[x,y]=OUT_
    for y in range(H):
        for x in (0,W-1):
            if px[x,y][3]: px[x,y]=OUT_
    return t
TAG={k:fix_tag(Image.open(C+f'tag_{k}.png').convert('RGBA')) for k in ('round','shield')}
for k,t in TAG.items(): t.save(C+f'tag_{k}_fixed.png')
CREST_OFF={'round':(4,12),'shield':(5,12)}   # crest top-left inside the 30px fixed centre block, native px
def tag_native(kind,wn):
    t=TAG[kind]; o=Image.new('RGBA',(wn,16),(0,0,0,0)); c0=wn//2-15
    o.paste(t.crop((0,0,4,16)),(0,0)); o.paste(t.crop((92,0,96,16)),(wn-4,0))
    for x in range(4,c0): o.paste(t.crop((10,0,11,16)),(x,0))
    for x in range(c0+30,wn-4): o.paste(t.crop((80,0,81,16)),(x,0))
    o.paste(t.crop((33,0,63,16)),(c0,0)); return o,c0
def crest_tag(kind,mid,name):
    wn=max(42,(tw(name,15)+30)//S+1); wn+=wn%2
    t,c0=tag_native(kind,wn)
    cr=Image.open(C+('medallion' if kind=='round' else 'shield')+'_'+IC[mid][3:]+'.png').convert('RGBA')
    ox,oy=CREST_OFF[kind]; can=Image.new('RGBA',(wn,oy+cr.height),(0,0,0,0)); can.alpha_composite(t,(0,0)); can.alpha_composite(cr,(c0+ox,oy))
    return up(can,S)   # whole tag+crest unit at one pixel scale
def block_centre(ang):
    ux,uy=U(ang)
    if abs(uy)>0.7: return (CX+ux*0.60*R, CY+uy*0.60*R)
    r=0.645*R; return (CX+ux*r, CY+uy*r+(16 if uy>0 else -16))   # side slices: push away from the horizontal divider
def opt_crest(kind,hot=7):
    im=base(); H_SPR=96
    for i,(mid,name,call,ang,_,atk,hp) in enumerate(MON):
        unit=crest_tag(kind,mid,name); bh_total=H_SPR+4+unit.height
        bc=block_centre(ang); top=bc[1]-bh_total/2
        big,_=L.sprite(mid)
        feet,(bw,bh)=draw_sprite(im,mid,(bc[0],top+H_SPR-big.height/2))
        g=bw/2+24; badge(im,'hp',(feet[0]-g,feet[1]-20),hp); badge(im,'atk',(feet[0]+g,feet[1]-20),atk)   # HP left, ATK right
        ux0=bc[0]-unit.width/2; uy0=feet[1]+4
        im.alpha_composite(unit,(int(ux0),int(uy0)))
        txt(ImageDraw.Draw(im),(bc[0],uy0+7*S),name,15)
        crc=(bc[0],uy0+(CREST_OFF[kind][1]+11)*S)   # crest centre
        if i==hot:
            d=ImageDraw.Draw(im); ex=EX[mid]; cw=(max(tw(ex,13),tw(call,16)+40)+40+3)//4*4
            cc=(crc[0]-40-cw/2, crc[1]+8); paste=plate(cw,72); L.paste_c(im,paste,cc); d=ImageDraw.Draw(im)
            x0=cc[0]-cw/2+18; L.paste_c(im,up(L.P[IC[mid]],2),(x0+11,cc[1]-14)); txt(d,(x0+28,cc[1]-14),call,16,ORNG,'lm')
            txt(d,(x0,cc[1]+14),ex,13,INK,'lm')
            d.ellipse((crc[0]-38,crc[1]-38,crc[0]+38,crc[1]+38),outline=GOLD,width=3)
    nm={'round':'B1|Round medallion crest set into the tag (full 8, 96px)','shield':'B2|Heraldic shield crest set into the tag (full 8, 96px)'}[kind]
    header(im,'OPTION '+nm,['Name tag with a notched bottom border; the ability crest hangs from the notch, centred. Hover or face shows the full card (upper-left Commander hovered). HP heart left, ATK star right.'])
    return im
if __name__=='__main__':
    outs=[('B_compact_chip',L.opt_B()),('B1_medallion_crest',opt_crest('round')),('B2_shield_crest',opt_crest('shield'))]
    for k,im in outs: im.convert('RGB').save(D+f'layout_{k}.png'); print(D+f'layout_{k}.png',im.size)
    # contact sheet: B, B1, B2 side by side at half size
    cs=Image.new('RGB',(3*840+40,520+80),(18,14,12)); d=ImageDraw.Draw(cs)
    d.text((14,10),'Option B variants: chip on shoulder (B) vs crest set into the tag (B1 medallion, B2 shield). HP left, ATK right.',font=F(22),fill=GOLD)
    for i,(k,im) in enumerate(outs):
        x=10+i*850; cs.paste(im.convert('RGB').resize((840,520),Image.LANCZOS),(x,50)); d.text((x+6,50+525-2),k.replace('_',' '),font=F(18),fill=INK)
    cs.save(D+'crest_contact_sheet.png'); print('contact',cs.size)
    # close-up: lower-left Commander block from each, 2x nearest
    bc=block_centre(157.5); box=(int(bc[0]-150),int(bc[1]-70),int(bc[0]+150),int(bc[1]+120))   # lower-left Commander: badges, tag, crest
    cl=Image.new('RGB',(3*(box[2]-box[0])*2+40,(box[3]-box[1])*2+50),(18,14,12)); d=ImageDraw.Draw(cl)
    for i,(k,im) in enumerate(outs):
        c=im.convert('RGB').crop(box); c=c.resize((c.width*2,c.height*2),Image.NEAREST); x=10+i*(c.width+10)
        cl.paste(c,(x,40)); d.text((x+4,8),k.replace('_',' ')+'  (2x)',font=F(18),fill=GOLD)
    cl.save(D+'crest_closeup_2x.png'); print('closeup',cl.size)
