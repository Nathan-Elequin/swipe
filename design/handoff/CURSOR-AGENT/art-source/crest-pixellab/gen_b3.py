# B3 pieces: 18px medallions with baked icons (2x2 sheet) + tag with a top notch. Guarded by plg (own cap).
import sys, json; from PIL import Image, ImageDraw
import plg
plg.CAP=15
D='<ANIM_PITCH>/mockups/layouts/crest/'; P='<ANIM_PITCH>/mockups/layouts/pl/clean/'
O=(16,14,12,255);G=(255,216,74,255);G2=(232,195,106,255);GS=(168,120,40,255);B=(59,38,24,255);B2=(28,24,20,255)
def med18():
    im=Image.new('RGBA',(18,18),(0,0,0,0)); d=ImageDraw.Draw(im)
    d.ellipse((0,0,17,17),fill=O); d.ellipse((1,1,16,16),fill=GS); d.ellipse((1,1,15,15),fill=G2)
    d.arc((1,1,16,16),200,290,fill=G); d.ellipse((2,2,15,15),fill=O); d.ellipse((3,3,14,14),fill=B2)
    return im
def fit(im,m):
    s=min(m/im.width,m/im.height,1); return im.resize((max(1,round(im.width*s)),max(1,round(im.height*s))),Image.NEAREST)
def sheet():
    sh=Image.new('RGBA',(64,64),(0,0,0,0)); m=med18()
    for i,ic in enumerate(['ic_horn','ic_scales','ic_bolt','ic_fang']):
        cell=Image.new('RGBA',(32,32),(0,0,0,0)); cell.alpha_composite(m,(7,7))
        import icons10; icon=icons10.get(ic[3:]); cell.alpha_composite(icon,(16-(icon.width+1)//2,16-(icon.height+1)//2))
        sh.alpha_composite(cell,((i%2)*32,(i//2)*32))
    sh.save(D+'init/b3_med_sheet.png'); return sh
def tag_top():
    W,H=96,16; im=Image.new('RGBA',(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
    d.rounded_rectangle((0,0,W-1,H-1),3,fill=O); d.rounded_rectangle((1,1,W-2,H-2),2,fill=G2)
    d.line((3,1,W-4,1),fill=G); d.line((1,3,1,H-4),fill=G); d.line((3,H-2,W-4,H-2),fill=GS); d.line((W-2,3,W-2,H-4),fill=GS)
    d.rectangle((3,3,W-4,H-4),fill=B2); d.line((3,3,W-4,3),fill=B)
    cx=W//2   # bite into the TOP border: medallion centre sits 5 rows above the tag
    d.ellipse((cx-12,-16,cx+11,6),fill=O); d.ellipse((cx-11,-15,cx+10,5),fill=G); d.ellipse((cx-10,-14,cx+9,4),fill=(0,0,0,0))
    im.save(D+'init/tag_topnotch.png'); return im
if __name__=='__main__':
    jobs={'b3_med':('pixel art game UI sprite sheet, 2x2 grid of four separate small round gold medallion crests with bevelled rims, dark centers each holding one tiny icon: brass war horn, gold balance scales, yellow lightning bolt, white fang with red blood',sheet()),
          'tag_topnotch':('pixel art game UI name tag plate, dark walnut center, bright gold bevelled rim, a round semicircular notch cut into the middle of the TOP border with a gold lip, crypt dungeon style',tag_top())}
    for k in (sys.argv[1:] or jobs):
        plg.gen(jobs[k][0],jobs[k][1],k,strength=450 if k=='b3_med' else 350)
