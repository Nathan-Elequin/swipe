from PIL import Image, ImageDraw
D='<ANIM_PITCH>/mockups/layouts/crest/init/'
O=(16,14,12,255);G=(255,216,74,255);G2=(232,195,106,255);GS=(168,120,40,255);B=(59,38,24,255);B2=(28,24,20,255);BH=(90,58,34,255)
def tag(kind):
    W,H=96,16; im=Image.new('RGBA',(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
    d.rounded_rectangle((0,0,W-1,H-1),3,fill=O); d.rounded_rectangle((1,1,W-2,H-2),2,fill=G2)
    d.line((3,1,W-4,1),fill=G); d.line((1,3,1,H-4),fill=G); d.line((3,H-2,W-4,H-2),fill=GS); d.line((W-2,3,W-2,H-4),fill=GS)
    d.rectangle((3,3,W-4,H-4),fill=B2); d.line((3,3,W-4,3),fill=B)
    cx=W//2
    if kind=='round':   # semicircular bite in the bottom border, gold lip following it
        d.ellipse((cx-13,H-6,cx+12,H+19),fill=O); d.ellipse((cx-12,H-5,cx+11,H+18),fill=G); d.ellipse((cx-11,H-4,cx+10,H+17),fill=(0,0,0,0))
    else:               # square socket cut into the bottom border
        d.rectangle((cx-12,H-6,cx+11,H-1),fill=O); d.rectangle((cx-11,H-5,cx+10,H-1),fill=G); d.rectangle((cx-10,H-4,cx+9,H-1),fill=(0,0,0,0))
    # clear below the lip so the crest can sit in it
    for x in range(W):
        for y in range(H):
            pass
    im.save(D+f'tag_{kind}.png'); return im
def medallion():
    im=Image.new('RGBA',(32,32),(0,0,0,0)); d=ImageDraw.Draw(im); o=5
    d.ellipse((o,o,o+21,o+21),fill=O); d.ellipse((o+1,o+1,o+20,o+20),fill=GS); d.ellipse((o+1,o+1,o+19,o+19),fill=G2)
    d.arc((o+1,o+1,o+20,o+20),200,290,fill=G); d.ellipse((o+3,o+3,o+18,o+18),fill=O); d.ellipse((o+4,o+4,o+17,o+17),fill=B2)
    d.arc((o+4,o+4,o+17,o+17),20,110,fill=B)
    im.save(D+'medallion.png'); return im
def shield():
    im=Image.new('RGBA',(32,32),(0,0,0,0)); d=ImageDraw.Draw(im); x0,y0,w,h=6,4,20,24
    pts=[(x0,y0),(x0+w-1,y0),(x0+w-1,y0+12),(x0+w//2,y0+h-1),(x0+w//2-1,y0+h-1),(x0,y0+12)]
    d.polygon(pts,fill=O)
    d.polygon([(x0+1,y0+1),(x0+w-2,y0+1),(x0+w-2,y0+12),(x0+w//2,y0+h-3),(x0+w//2-1,y0+h-3),(x0+1,y0+12)],fill=G2)
    d.line((x0+1,y0+1,x0+w-2,y0+1),fill=G); d.line((x0+1,y0+1,x0+1,y0+12),fill=G)
    d.polygon([(x0+3,y0+3),(x0+w-4,y0+3),(x0+w-4,y0+12),(x0+w//2,y0+h-6),(x0+w//2-1,y0+h-6),(x0+3,y0+12)],fill=O)
    d.polygon([(x0+4,y0+4),(x0+w-5,y0+4),(x0+w-5,y0+12),(x0+w//2,y0+h-7),(x0+w//2-1,y0+h-7),(x0+4,y0+12)],fill=(122,30,24,255))
    d.line((x0+4,y0+4,x0+w-5,y0+4),fill=(190,58,52,255))
    im.save(D+'shield.png'); return im
if __name__=='__main__':
    tag('round'); tag('shield'); medallion(); shield()
    for f in ['tag_round','tag_shield','medallion','shield']:
        im=Image.open(D+f+'.png'); im.resize((im.width*8,im.height*8),0).save(D+f+'_x8.png')
