# B4: plain (un-notched) compact name tag; the 18px medallion sits IN FRONT of it, overlapping the tag's top edge.
# z-order per seat: shadow < sprite < tag < medallion < HP/ATK badges. Seat-count agnostic (fit search from make_b3).
import sys; sys.path.insert(0,'<ANIM_PITCH>/mockups/layouts/crest')
import make_b3 as B3
from make_b3 import L, MON8, MON6, base, solve, draw_sprite, badge, txt, tw, F, EX, IC, up, plate, header, GOLD, INK, ORNG, D
from PIL import Image, ImageDraw
MED=60            # 20 native x 3
MED_TOP=-12       # medallion rim top, relative to the feet line (overlaps the feet 12px)
TAG_OVER=18       # px of the medallion that hangs over the tag (0.30 of its height)
TAG_H=48          # plain B tag (plate9 at 4x, 12 native tall)
TAG_TOP=MED_TOP+MED-TAG_OVER          # = +30
TEXT_Y=TAG_TOP+30                     # name sits below the medallion's bottom edge (+48)
def tag_w(name): return max(108,(tw(name,15)+40+2)//3*3)
def tag_plate(w,h): return up(L.nine(L.P['plate9'],w//3,h//3,5),3)   # plain B tag, at 3x like the medallion and badges
def parts(mid,name):
    big,_=L.sprite(mid); bw,bh=big.size; g=bw/2+24; w=tag_w(name)
    rects=[(-bw/2,-bh,bw/2,0),(-g-24,-44,g+24,4),(-w/2,TAG_TOP,w/2,TAG_TOP+TAG_H)]
    return big,w,rects
def render(mons,hot,n):
    im=base(mons); h=180/len(mons); rep=[]; plan=[]
    for i,(mid,name,call,ang,_,atk,hp) in enumerate(mons):
        big,w,rects=parts(mid,name); best=solve(ang,h,rects); plan.append((i,mid,name,call,ang,atk,hp,big,w,best)); rep.append((name,ang,round(best[3],3),best[4],round(best[2],1)))
    for i,mid,name,call,ang,atk,hp,big,w,best in plan:
        fx,fy=best[1]; feet,(bw,bh)=draw_sprite(im,mid,(fx,fy-big.height/2))
        L.paste_c(im,tag_plate(w,TAG_H),(fx,fy+TAG_TOP+TAG_H/2))                              # tag (full straight top border)
        txt(ImageDraw.Draw(im),(fx,fy+TEXT_Y),name,15)
        m=up(B3.med(IC[mid][3:]),3); im.alpha_composite(m,(int(fx-MED/2),int(fy+MED_TOP)))   # medallion in front of the tag
        g=bw/2+24; badge(im,'hp',(fx-g,fy-20),hp); badge(im,'atk',(fx+g,fy-20),atk)
        if i==hot:
            d=ImageDraw.Draw(im); ex=EX[mid]; cw=(max(tw(ex,13),tw(call,16)+40)+40+3)//4*4
            cc=(fx-w/2-12-cw/2,fy+TAG_TOP+TAG_H/2); L.paste_c(im,plate(cw,72),cc); d=ImageDraw.Draw(im)
            x0=cc[0]-cw/2+18; L.paste_c(im,up(L.P[IC[mid]],2),(x0+11,cc[1]-14)); txt(d,(x0+28,cc[1]-14),call,16,ORNG,'lm'); txt(d,(x0,cc[1]+14),ex,13,INK,'lm')
            mc=(fx,fy+MED_TOP+MED/2); d.ellipse((mc[0]-36,mc[1]-36,mc[0]+36,mc[1]+36),outline=GOLD,width=3)
    header(im,f'OPTION B4|Medallion over a plain tag, {len(mons)} seats',['Plain compact name tag (straight top border). The ability medallion sits in front, overlapping the tag top by 30% and the feet a little. HP heart left, ATK star right. Hover or face opens the full card (Commander hovered).'])
    return im,rep
if __name__=='__main__':
    outs={}
    for mons,hot,n in [(MON8,7,8),(MON6,4,6)]:
        im,rep=render(mons,hot,n); im.convert('RGB').save(D+f'layout_B4_{n}.png'); outs[n]=im
        print(n,'seats min',min(r[4] for r in rep)); [print('   ',r) for r in rep]
    for n in (4,5,7):
        mons=[MON8[k%8][:3]+(-90+(k+0.5)*360/n,)+MON8[k%8][4:] for k in range(n)]
        im,rep=render(mons,None,n); im.convert('RGB').save(D+f'_fit_B4_{n}.png'); print(n,'seats min',min(r[4] for r in rep))
    # 2x close-up B3 vs B4, lower-left Commander at 8 seats
    b3=Image.open(D+'layout_B3_top_medallion_8.png').convert('RGB'); b4=outs[8].convert('RGB')
    _,_,r3=B3.block_parts('commander','Commander'); f3=solve(157.5,22.5,r3)[1]
    _,_,r4=parts('commander','Commander'); f4=solve(157.5,22.5,r4)[1]
    cl=Image.new('RGB',(2*600+30,380+50),(18,14,12)); d=ImageDraw.Draw(cl)
    for k,(nm,im,f) in enumerate([('B3  notched tag',b3,f3),('B4  medallion over a plain tag',b4,f4)]):
        bx=(int(f[0]-150),int(f[1]-110),int(f[0]+150),int(f[1]+80))
        c=im.crop(bx).resize((600,380),Image.NEAREST); x=10+k*610; cl.paste(c,(x,40)); d.text((x+4,8),nm+'  (2x)',font=F(18),fill=GOLD)
    cl.save(D+'crest_closeup_B3_vs_B4_2x.png'); print('closeup ok')
