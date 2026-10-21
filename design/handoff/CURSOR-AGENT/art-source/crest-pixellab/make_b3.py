# B3: compact name tag with the ability medallion notched into the TOP border, overlapping the feet.
# Seat-count agnostic (4-8): each block is placed by a clearance search inside its slice.
import sys, math; sys.path.insert(0,'<ANIM_PITCH>/mockups/layouts'); sys.path.insert(0,'<ANIM_PITCH>/mockups/layouts/crest')
import make_layouts as L
from make_layouts import draw_sprite, badge, txt, tw, F, EX, IC, U, up, plate, header, GOLD, INK, ORNG, OUTL, CX, CY, R, HUB, COL
from PIL import Image, ImageDraw
D='<ANIM_PITCH>/mockups/layouts/crest/'; C=D+'clean/'; S=3
MON8=L.MON
MON6=[('merchant','Merchant','Fair Trade',-60,'orange',4,4),('eel','Eel','Conductive',0,'orange',6,4),
      ('merchant','Merchant','Fair Trade',60,'orange',4,4),('vampire','Vampire','Bloodlust',120,'red',4,4),
      ('commander','Commander','War Cry',180,'red',3,3),('vampire','Vampire','Bloodlust',240,'red',4,4)]
MED_OVERLAP=12        # px the medallion rim rises above the feet line
def base(mons):
    ref=Image.open(L.REF).convert('RGBA'); im=Image.new('RGBA',(1680,1040)); im.paste(ref,(0,0))
    ImageDraw.Draw(im).rectangle((0,1006,1679,1039),fill=ref.crop((0,1000,300,1006)).resize((1,1),Image.BOX).getpixel((0,0)))
    d=ImageDraw.Draw(im); h=180/len(mons)
    # repaint the whole disc first so the 8-seat screenshot dividers don't show through at 6 seats
    d.ellipse((CX-(R-4),CY-(R-4),CX+(R-4),CY+(R-4)),fill=(40,30,24))
    for m in mons:
        a0,a1=m[3]-h+0.5,m[3]+h-0.5; c=COL[m[4]]
        for r0,r1,cc in [(HUB+3,0.70*R,c[0]),(0.70*R,0.86*R,c[1]),(0.86*R,R-4,c[2])]:
            n=60; pts=[(CX+math.cos(math.radians(a0+(a1-a0)*k/n))*r1,CY+math.sin(math.radians(a0+(a1-a0)*k/n))*r1) for k in range(n+1)]
            pts+=[(CX+math.cos(math.radians(a0+(a1-a0)*k/n))*r0,CY+math.sin(math.radians(a0+(a1-a0)*k/n))*r0) for k in range(n,-1,-1)]
            d.polygon(pts,fill=cc)
    # hub ring back on top (screenshot hub is a dark disc with a gold rim)
    ref_hub=ref.crop((int(CX-HUB-4),int(CY-HUB-4),int(CX+HUB+4),int(CY+HUB+4))); mask=Image.new('L',ref_hub.size,0)
    ImageDraw.Draw(mask).ellipse((0,0,ref_hub.width-1,ref_hub.height-1),fill=255); im.paste(ref_hub,(int(CX-HUB-4),int(CY-HUB-4)),mask)
    return im
# ---- pieces ----
TAG=Image.open(C+'tag_topnotch.png').convert('RGBA')
def med(icon): return Image.open(C+f'med18_{icon}.png').convert('RGBA')
def tag_unit(mid,name):
    wn=max(40,(tw(name,15)+30)//S+1); wn+=wn%2; c0=wn//2-15; t=Image.new('RGBA',(wn,16),(0,0,0,0))
    t.paste(TAG.crop((0,0,4,16)),(0,0)); t.paste(TAG.crop((92,0,96,16)),(wn-4,0))
    for x in range(4,c0): t.paste(TAG.crop((10,0,11,16)),(x,0))
    for x in range(c0+30,wn-4): t.paste(TAG.crop((80,0,81,16)),(x,0))
    t.paste(TAG.crop((33,0,63,16)),(c0,0))
    m=med(IC[mid][3:])                       # 20x20: 18px medallion + 1px dark rim
    can=Image.new('RGBA',(wn,15+16),(0,0,0,0)); can.alpha_composite(t,(0,15)); can.alpha_composite(m,(wn//2-10,0))
    return up(can,S)                          # medallion centre = 5 native rows above the tag top
# ---- block geometry (relative to feet) ----
def block_parts(mid,name):
    big,_=L.sprite(mid); bw,bh=big.size; unit=tag_unit(mid,name); g=bw/2+24
    rects=[(-bw/2,-bh,bw/2,0),(-g-24,-44,g+24,4),                       # sprite, badge row
           (-unit.width/2,-MED_OVERLAP+15*S-3,unit.width/2,-MED_OVERLAP+unit.height)]   # tag
    return big,unit,rects
def clearance(pt,ang,h):
    x,y=pt[0]-CX,pt[1]-CY; r=math.hypot(x,y); a=math.degrees(math.atan2(y,x))
    da=(a-ang+540)%360-180
    edge=r*math.sin(math.radians(h-abs(da))) if abs(da)<90 else -r
    return min(edge, r-(HUB+6), (R-6)-r)
def solve(ang,h,rects):
    best=None; ux,uy=U(ang)
    for rr in range(int(0.40*R),int(0.86*R),3):
        for dy in range(-24,25,4):
            fx,fy=CX+ux*rr, CY+uy*rr+dy
            cl=min(clearance((fx+px,fy+py),ang,h) for (x0,y0,x1,y1) in rects
                   for px in (x0,(x0+x1)/2,x1) for py in (y0,(y0+y1)/2,y1))
            key=(round(cl/4),-abs(rr-0.60*R)-abs(dy))
            if best is None or key>best[0]: best=(key,(fx,fy),cl,rr/R,dy)
    return best
def render(mons,hot,label):
    im=base(mons); h=180/len(mons); report=[]
    plan=[]
    for i,(mid,name,call,ang,_,atk,hp) in enumerate(mons):
        big,unit,rects=block_parts(mid,name); best=solve(ang,h,rects)
        plan.append((i,mid,name,call,ang,atk,hp,big,unit,best)); report.append((name,ang,round(best[3],3),best[4],round(best[2],1)))
    for i,mid,name,call,ang,atk,hp,big,unit,best in plan:          # layer: sprite -> tag+medallion -> badges
        fx,fy=best[1]; feet,(bw,bh)=draw_sprite(im,mid,(fx,fy-big.height/2))
        im.alpha_composite(unit,(int(fx-unit.width/2),int(fy-MED_OVERLAP)))
        txt(ImageDraw.Draw(im),(fx,fy-MED_OVERLAP+15*S+int(9.5*S)),name,15)
        g=bw/2+24; badge(im,'hp',(fx-g,fy-20),hp); badge(im,'atk',(fx+g,fy-20),atk)
        if i==hot:
            d=ImageDraw.Draw(im); ex=EX[mid]; cw=(max(tw(ex,13),tw(call,16)+40)+40+3)//4*4
            tl=fx-unit.width/2; cc=(tl-12-cw/2,fy+40); L.paste_c(im,plate(cw,72),cc); d=ImageDraw.Draw(im)
            x0=cc[0]-cw/2+18; L.paste_c(im,up(L.P[IC[mid]],2),(x0+11,cc[1]-14)); txt(d,(x0+28,cc[1]-14),call,16,ORNG,'lm'); txt(d,(x0,cc[1]+14),ex,13,INK,'lm')
            mc=(fx,fy-MED_OVERLAP+10*S); d.ellipse((mc[0]-36,mc[1]-36,mc[0]+36,mc[1]+36),outline=GOLD,width=3)
    header(im,f'OPTION B3|Top medallion, {len(mons)} seats (96px)',['Compact name tag; the ability medallion is notched into the TOP border and overlaps the feet. HP heart left, ATK star right. Hover or face opens the full card (Commander hovered). Blocks placed by the seat-count-agnostic clearance search.'])
    return im,report
if __name__=='__main__':
    outs=[]
    for mons,hot,n in [(MON8,7,8),(MON6,4,6)]:
        im,rep=render(mons,hot,n); p=D+f'layout_B3_top_medallion_{n}.png'; im.convert('RGB').save(p); outs.append((n,im)); print(p)
        for r in rep: print('  ',n,'seats',r)
    for n in (4,5,7):
        mons=[MON8[k%8][:3]+(-90+(k+0.5)*360/n,)+MON8[k%8][4:] for k in range(n)]
        im,rep=render(mons,None,n); im.convert('RGB').save(D+f'_fit_B3_{n}.png'); print('fit',n,min(r[4] for r in rep))
    # close-up B1 vs B3 (8 seats, lower-left Commander), 2x nearest
    import make_crest as MC
    b1=Image.open(D+'layout_B1_medallion_crest.png').convert('RGB'); b3=outs[0][1].convert('RGB')
    bc1=MC.block_centre(157.5); box1=(int(bc1[0]-150),int(bc1[1]-70),int(bc1[0]+150),int(bc1[1]+120))
    big,unit,rects=block_parts('commander','Commander'); f3=solve(157.5,22.5,rects)[1]; box3=(int(f3[0]-150),int(f3[1]-110),int(f3[0]+150),int(f3[1]+80))
    cl=Image.new('RGB',(2*600+30,380+50),(18,14,12)); d=ImageDraw.Draw(cl)
    for k,(nm,im,bx) in enumerate([('B1 medallion under the tag',b1,box1),('B3 medallion on top, -18%',b3,box3)]):
        c=im.crop(bx).resize((600,380),Image.NEAREST); x=10+k*610; cl.paste(c,(x,40)); d.text((x+4,8),nm+'  (2x)',font=F(18),fill=GOLD)
    cl.save(D+'crest_closeup_B1_vs_B3_2x.png'); print('closeup')
    # contact sheet: B1 | B3 8 | B3 6
    b1s=Image.open(D+'layout_B1_medallion_crest.png').convert('RGB')
    cs=Image.new('RGB',(3*840+40,600),(18,14,12)); d=ImageDraw.Draw(cs)
    d.text((14,10),'B1 (crest under tag) vs B3 (medallion on top, overlapping the feet) at 8 and 6 seats. HP left, ATK right.',font=F(22),fill=GOLD)
    for k,(nm,im) in enumerate([('B1  8 seats',b1s),('B3  8 seats',outs[0][1]),('B3  6 seats',outs[1][1])]):
        x=10+k*850; cs.paste(im.convert('RGB').resize((840,520),Image.LANCZOS),(x,50)); d.text((x+6,575),nm,font=F(18),fill=INK)
    cs.save(D+'crest_B3_contact_sheet.png'); print('contact')
