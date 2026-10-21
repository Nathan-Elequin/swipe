# Full-8 wheel layout options A-D over Nathan's screenshot, 1680x1040.
# UI chrome = PixelLab pieces in pl/clean/ (Nearest only). All text upright.
from PIL import Image, ImageDraw, ImageFont
import math
REF='<ANIM_PITCH>/src/shots/wheel_ref.png'
SPR='<ANIM_PITCH>/src/sprites/'
PC='<ANIM_PITCH>/mockups/layouts/pl/clean/'
OUT='<ANIM_PITCH>/mockups/layouts/'
FB='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
CX,CY,R,HUB=839.5,438.5,406,139
COL={'red':[(164,74,57),(158,61,42),(148,41,20)],'orange':[(152,100,61),(144,88,47),(133,71,25)]}
INK=(240,230,216); GOLD=(255,216,74); GOLD2=(232,195,106); OUTL=(16,14,12); ORNG=(240,154,52)
# id, name, call, angle, colour, atk, hp, icon, explainer (catalog.json "explainer")
EX={'commander':'Neighbors +2 Attack','merchant':'Choose an item. I upgrade it.',
    'eel':'Facing: takes Attack = Block you Gain','vampire':'+1 HP and +1 ATK each time you lose HP'}
IC={'commander':'ic_horn','merchant':'ic_scales','eel':'ic_bolt','vampire':'ic_fang'}
MON=[('vampire','Vampire','Bloodlust',-112.5,'red',4,4),('merchant','Merchant','Fair Trade',-67.5,'orange',4,4),
     ('eel','Eel','Conductive',-22.5,'orange',6,4),('eel','Eel','Conductive',22.5,'orange',6,4),
     ('merchant','Merchant','Fair Trade',67.5,'orange',4,4),('vampire','Vampire','Bloodlust',112.5,'red',4,4),
     ('commander','Commander','War Cry',157.5,'red',3,3),('commander','Commander','War Cry',202.5,'red',3,3)]
def F(n): return ImageFont.truetype(FB,n)
P={k:Image.open(PC+k+'.png').convert('RGBA') for k in ['banner','plate9','chip','disc','atk','hp','ic_horn','ic_scales','ic_bolt','ic_fang']}
def up(im,k): return im.resize((im.width*k,im.height*k),Image.NEAREST)

def nine(src,w,h,c):          # native 9-slice, corners c px fixed, edges/centre stretched (nearest)
    W,H=src.size; o=Image.new('RGBA',(w,h),(0,0,0,0))
    xs=[(0,c,0,c),(c,W-c,c,w-c),(W-c,W,w-c,w)]; ys=[(0,c,0,c),(c,H-c,c,h-c),(H-c,H,h-c,h)]
    for sx0,sx1,dx0,dx1 in xs:
        for sy0,sy1,dy0,dy1 in ys:
            if dx1>dx0 and dy1>dy0: o.paste(src.crop((sx0,sy0,sx1,sy1)).resize((dx1-dx0,dy1-dy0),Image.NEAREST),(dx0,dy0))
    return o
def plate(wpx,hpx): return up(nine(P['plate9'],wpx//4,hpx//4,5),4)
def banner(wpx):              # tails fixed, body stretched horizontally only
    s=P['banner']; w=wpx//4; o=Image.new('RGBA',(w,s.height),(0,0,0,0))
    o.paste(s.crop((0,0,12,s.height)),(0,0)); o.paste(s.crop((52,0,64,s.height)),(w-12,0))
    o.paste(s.crop((12,0,52,s.height)).resize((w-24,s.height),Image.NEAREST),(12,0)); return up(o,4)

def paste_c(im,piece,c): im.alpha_composite(piece,(int(round(c[0]-piece.width/2)),int(round(c[1]-piece.height/2))))
def txt(d,c,t,size,fill=INK,anchor='mm'): d.text(c,t,font=F(size),fill=fill,stroke_width=3,stroke_fill=OUTL,anchor=anchor)
def tw(t,size): return F(size).getbbox(t)[2]

def base():
    ref=Image.open(REF).convert('RGBA'); im=Image.new('RGBA',(1680,1040))
    im.paste(ref,(0,0)); ImageDraw.Draw(im).rectangle((0,1006,1679,1039),fill=ref.crop((0,1000,300,1006)).resize((1,1),Image.BOX).getpixel((0,0)))  # pad 34px (screenshot is 1006 tall)
    d=ImageDraw.Draw(im)
    for m in MON:
        a0,a1=m[3]-22.5+0.5,m[3]+22.5-0.5; c=COL[m[4]]
        for r0,r1,cc in [(HUB+3,0.70*R,c[0]),(0.70*R,0.86*R,c[1]),(0.86*R,R-4,c[2])]:
            pts=[(CX+math.cos(math.radians(a0+(a1-a0)*k/40))*r1,CY+math.sin(math.radians(a0+(a1-a0)*k/40))*r1) for k in range(41)]
            pts+=[(CX+math.cos(math.radians(a0+(a1-a0)*k/40))*r0,CY+math.sin(math.radians(a0+(a1-a0)*k/40))*r0) for k in range(40,-1,-1)]
            d.polygon(pts,fill=cc)
    return im

def sprite(mid):
    s=Image.open(SPR+mid+'.png').convert('RGBA'); s=s.crop(s.getbbox()); s=s.resize((s.width//4,s.height//4),Image.NEAREST)
    k=max(1,round(96/s.height)); return up(s,k),k
def draw_sprite(im,mid,c):    # c = sprite centre; returns feet point
    big,k=sprite(mid); sx,sy=c; feet=(sx,sy+big.height/2)
    sh=Image.new('RGBA',im.size,(0,0,0,0)); ImageDraw.Draw(sh).ellipse((feet[0]-big.width*0.45,feet[1]-8,feet[0]+big.width*0.45,feet[1]+8),fill=(10,6,4,120)); im.alpha_composite(sh)
    ol=Image.new('RGBA',big.size,OUTL+(255,)); ol.putalpha(big.split()[3])
    for ox,oy in [(-k,0),(k,0),(0,-k),(0,k)]: im.alpha_composite(ol,(int(sx-big.width/2+ox),int(sy-big.height/2+oy)))
    im.alpha_composite(big,(int(sx-big.width/2),int(sy-big.height/2))); return feet,big.size
def badge(im,kind,c,n):
    paste_c(im,up(P[kind],3),c); txt(ImageDraw.Draw(im),(c[0],c[1]+(1 if kind=='atk' else -1)),str(n),22)
def chip(im,mid,c,k=3):
    paste_c(im,up(P['chip'],k),c); paste_c(im,up(P[IC[mid]],2 if k==3 else 3),c)
def disc(im,c,n):
    paste_c(im,up(P['disc'],3),c); txt(ImageDraw.Draw(im),c,str(n),22,GOLD)
def U(ang): a=math.radians(ang); return math.cos(a),math.sin(a)

def header(im,title,lines,y=18):
    d=ImageDraw.Draw(im); t1,t2=title.split('|'); txt(d,(20,y),t1,24,GOLD,'la'); txt(d,(20,y+30),t2,15,GOLD2,'la'); y+=56
    words=' '.join(lines).split(); line=''
    for w in words:
        if tw(line+' '+w,13)>380: txt(d,(20,y),line.strip(),13,INK,'la'); y+=18; line=''
        line+=' '+w
    txt(d,(20,y),line.strip(),13,INK,'la')

# ---------- A: outer rim band ----------
def opt_A():
    im=base(); d=ImageDraw.Draw(im)
    for mid,name,call,ang,_,atk,hp in MON:
        ux,uy=U(ang); feet,(bw,bh)=draw_sprite(im,mid,(CX+ux*0.535*R,CY+uy*0.535*R))
        g=bw/2+24; badge(im,'hp',(feet[0]-g,feet[1]-20),hp); badge(im,'atk',(feet[0]+g,feet[1]-20),atk)   # HP left, ATK right (Nathan 10-20)
        w=max(tw(name,17),tw(call,13)+30)+64; w=(w+3)//4*4
        pc=(CX+ux*0.93*R,CY+uy*0.93*R); b=banner(w); paste_c(im,b,pc); d=ImageDraw.Draw(im)
        txt(d,(pc[0],pc[1]-9),name,17)
        tx=pc[0]-(tw(call,13)+26)/2; paste_c(im,up(P[IC[mid]],2),(tx+11,pc[1]+12)); txt(d,(tx+26,pc[1]+12),call,13,ORNG,'lm')
    header(im,'OPTION A|Outer rim band  (full 8, 96px)',['Upright banner sits on the rim ring at each slice; sprite + flanking ATK/HP stay in the slice body.',
           'Name + ability icon + call name on every plate. Plates overhang the rim on the 4 diagonal-side slices.'])
    return im

# ---------- B: compact in-slice ----------
def opt_B():
    im=base(); hot=7   # slice index shown hovered/facing
    for i,(mid,name,call,ang,_,atk,hp) in enumerate(MON):
        ux,uy=U(ang); bc=(CX+ux*0.60*R,CY+uy*0.60*R)
        big,_=sprite(mid); sc=(bc[0],bc[1]-30)            # block: sprite (96) + gap + 40px tag
        feet,(bw,bh)=draw_sprite(im,mid,(sc[0],bc[1]-30+ (96-big.height)/2))
        g=bw/2+24; badge(im,'hp',(feet[0]-g,feet[1]-20),hp); badge(im,'atk',(feet[0]+g,feet[1]-20),atk)   # HP left, ATK right (Nathan 10-20)
        w=(tw(name,16)+36+3)//4*4; tc=(feet[0],feet[1]+26); paste_c(im,plate(w,40),tc)
        txt(ImageDraw.Draw(im),tc,name,16)
        side=1 if ux>=0 else -1; chx,chy=feet[0]+side*(bw/2+10),feet[1]-bh+10   # chip on the outward shoulder
        chip(im,mid,(chx,chy))
        if i==hot:   # hover / facing expands the chip into a full-text card
            ex=EX[mid]; cw=(max(tw(ex,13),tw(call,16)+40)+40+3)//4*4; cc=(chx-30-cw/2,chy); p=plate(cw,72); paste_c(im,p,cc); d=ImageDraw.Draw(im)
            x0=cc[0]-cw/2+18; paste_c(im,up(P[IC[mid]],2),(x0+11,cc[1]-14)); txt(d,(x0+28,cc[1]-14),call,16,ORNG,'lm')
            txt(d,(x0,cc[1]+14),ex,13,INK,'lm')
            d.rectangle((chx-24,chy-24,chx+24,chy+24),outline=GOLD,width=3)
    header(im,'OPTION B|Compact: name tag + ability chip  (full 8, 96px)',['Name-only tag under the feet; ability = icon chip on the shoulder. Hover a chip (or face the monster)',
           'to open the full card. Shown: upper-left Commander chip hovered. Least clutter; ability needs learning the icons.'])
    return im

# ---------- C: upright in-slice two-line plate ----------
def opt_C():
    im=base()
    for mid,name,call,ang,_,atk,hp in MON:
        ux,uy=U(ang); bc=(CX+ux*0.60*R,CY+uy*0.60*R)
        w=(max(tw(name,16),tw(call,12)+26)+40+3)//4*4; ph=56
        big,_=sprite(mid); top_plate = uy< -0.5     # top slices: plate on the rim side (above)
        if top_plate: pc=(bc[0],bc[1]-76+ph/2); spc=(bc[0]+12,pc[1]+ph/2+8+48)
        else:         spc=(bc[0]+12,bc[1]-76+48); pc=(bc[0],spc[1]+56+ph/2)
        feet,(bw,bh)=draw_sprite(im,mid,(spc[0],spc[1]+(96-big.height)/2))
        bx=feet[0]-bw/2-26; badge(im,'hp',(bx,feet[1]-bh+30),hp); badge(im,'atk',(bx,feet[1]-24),atk)   # stacked column, HP first
        paste_c(im,plate(w,ph),pc); d=ImageDraw.Draw(im)
        txt(d,(pc[0],pc[1]-9),name,16)
        tx=pc[0]-(tw(call,12)+24)/2; paste_c(im,up(P[IC[mid]],2),(tx+10,pc[1]+12)); txt(d,(tx+24,pc[1]+12),call,12,ORNG,'lm')
    header(im,'OPTION C|Upright in-slice plate, badges stacked (full 8)',['Two-line plate (name / icon + call) always horizontal inside the slice: on the rim side for top slices,',
           'under the feet elsewhere. ATK/HP stack in a column so the plate gets the width. Everything readable, densest look.'])
    return im

# ---------- D: side legend ----------
def opt_D():
    im=base(); hot=6
    for i,(mid,name,call,ang,_,atk,hp) in enumerate(MON):
        ux,uy=U(ang); feet,(bw,bh)=draw_sprite(im,mid,(CX+ux*0.55*R,CY+uy*0.55*R))
        g=bw/2+24; badge(im,'hp',(feet[0]-g,feet[1]-20),hp); badge(im,'atk',(feet[0]+g,feet[1]-20),atk)   # HP left, ATK right (Nathan 10-20)
        disc(im,(CX+ux*0.93*R,CY+uy*0.93*R),i+1)
    # legend panel left of the wheel (free floor area x<430)
    x0,y0,pw,rh=20,132,396,92; pnl=plate(pw,rh*8+24); paste_c(im,pnl,(x0+pw/2,y0+(rh*8+24)/2)); d=ImageDraw.Draw(im)
    for i,(mid,name,call,ang,cn,atk,hp) in enumerate(MON):
        y=y0+12+i*rh
        if i==hot: d.rectangle((x0+10,y+2,x0+pw-10,y+rh-4),outline=GOLD,width=3)
        d.rectangle((x0+16,y+10,x0+22,y+rh-12),fill=COL[cn][1])          # slice colour swatch
        disc(im,(x0+50,y+rh/2-4),i+1); d=ImageDraw.Draw(im)
        txt(d,(x0+84,y+20),name,18,INK,'lm')
        paste_c(im,up(P[IC[mid]],2),(x0+96,y+45)); txt(d,(x0+112,y+45),call,14,ORNG,'lm')
        txt(d,(x0+84,y+68),EX[mid],12,(220,210,196),'lm')
    if hot is not None:  # hover highlight on its slice
        ux,uy=U(MON[hot][3]); c=(CX+ux*0.93*R,CY+uy*0.93*R); d.ellipse((c[0]-30,c[1]-30,c[0]+30,c[1]+30),outline=GOLD,width=3)
    header(im,'OPTION D|Side legend  (full 8, 96px)',['Wheel: sprite + ATK/HP + numbered coin only. Legend lists slices clockwise with name, ability, rule text. Hover row 7 = ring on coin 7.'])
    return im

if __name__=='__main__':
  outs=[]
  for k,f in [('A_rim_band',opt_A),('B_compact_chip',opt_B),('C_upright_inslice',opt_C),('D_side_legend',opt_D)]:
      im=f().convert('RGB'); p=OUT+f'layout_{k}.png'; im.save(p); outs.append((k,im)); print(p,im.size)
  # contact sheet 2x2 at half size
  cs=Image.new('RGB',(1680+30,1040+90),(18,14,12)); d=ImageDraw.Draw(cs)
  d.text((14,10),'Spinheritance wheel: full-8 layout options (96px monsters, PixelLab UI pieces, all text upright)',font=F(22),fill=GOLD)
  for i,(k,im) in enumerate(outs):
      x=10+(i%2)*850; y=50+(i//2)*540
      cs.paste(im.resize((840,520),Image.LANCZOS),(x,y)); d.text((x+6,y+500),k.replace('_',' '),font=F(16),fill=INK,stroke_width=2,stroke_fill=OUTL)
  cs.save(OUT+'layouts_contact_sheet.png'); print('contact',cs.size)
