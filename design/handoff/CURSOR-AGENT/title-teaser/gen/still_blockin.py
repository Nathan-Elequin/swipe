# Value-only block-in for title_still (native 420x260). Greys only.
from PIL import Image, ImageDraw
W,H=420,260
im=Image.new('L',(W,H),18); d=ImageDraw.Draw(im)
# sky gradient bands
for y in range(0,120): d.line([(0,y),(W,y)],fill=14+y//20)
# mountain mass (peak 210,30), left flank to x0 y~128, right to x420 y~120
d.polygon([(0,132),(70,96),(150,48),(210,28),(270,50),(350,92),(420,118),(420,260),(0,260)],fill=40)
d.polygon([(150,48),(210,28),(196,60),(120,130),(40,160),(0,160),(0,132),(70,96)],fill=50)  # lit left face
# Sprout ledge upper-left
d.polygon([(0,112),(64,108),(76,118),(60,126),(0,128)],fill=60)
d.rectangle([22,76,52,111],fill=110)  # Sprout block
# dragon upper-right
d.ellipse([352,22,420,82],fill=95); d.rectangle([380,60,420,130],fill=80)
d.rectangle([370,86,398,114],fill=90)  # minion
# claw arm reaching down-left into river
d.line([(395,120),(320,160),(262,198)],fill=85,width=9)
# mouth
d.ellipse([165,105,255,175],fill=8)
d.ellipse([178,118,242,172],fill=170); d.ellipse([192,130,228,170],fill=230)
# river: from mouth lip down then down-left out bottom-left
river=[(186,160),(234,160),(246,190),(236,206),(190,216),(150,222),(116,232),(92,248),(84,260),(30,260),(48,240),(78,222),(118,206),(160,196),(190,188)]
d.polygon(river,fill=205)
d.line([(200,170),(170,200),(110,220),(66,250)],fill=245,width=3)
# kettle hill lower-left
d.polygon([(0,176),(30,170),(60,178),(72,196),(50,260),(0,260)],fill=34)
d.rectangle([10,186,40,210],fill=52); d.polygon([(6,186),(25,174),(44,186)],fill=52)  # ghost cabin
d.rectangle([46,196,50,210],fill=60); d.point((52,198),fill=200)
# monster crowd lower-right
for b in [(350,180,420,260),(318,208,346,236),(336,236,372,260),(296,222,320,236)]: d.rectangle(b,fill=70)
d.line([(300,170),(352,196)],fill=150,width=2)  # boot streak
# bank peekers
for b in [(80,190,96,204),(104,206,118,220),(132,222,146,229),(200,218,214,229),(70,150,86,166),(304,150,322,168)]: d.rectangle(b,fill=75)
im.save('<TITLE_TEASER>/qa_still/blockin_native.png')
im.resize((210,130),Image.BOX).resize((840,520),Image.NEAREST).save('<TITLE_TEASER>/qa_still/blockin_thumb_view.png')
ov=im.convert('RGB'); o=ImageDraw.Draw(ov)
for (x,y,w,h),c in [((85,20,250,40),(232,195,106)),((65,62,290,21),(255,243,214)),((120,65,180,130),(213,68,59)),((85,230,250,20),(201,185,168))]:
    o.rectangle([x,y,x+w-1,y+h-1],outline=c)
for xx in range(0,420,3): o.point((xx,117),fill=(123,201,80)) if (xx<65 or xx>355) else None
ov.resize((840,520),Image.NEAREST).save('<TITLE_TEASER>/qa_still/blockin_rects_2x.png')
