import numpy as np
from PIL import Image, ImageDraw
OUT='<TITLE_TEASER>/out/'
im=Image.open(OUT+'title_still_native.png').convert('RGB')
W,H=im.size
im.resize((W*2,H*2),Image.NEAREST).save(OUT+'_review_still_2x.png')
ov=im.resize((W*4,H*4),Image.NEAREST); d=ImageDraw.Draw(ov)
for (x,y,w,h),c in [((0,0,1680,1040),(255,255,255)),((340,80,1000,160),(232,195,106)),((260,250,1160,80),(255,243,214)),((340,920,1000,80),(201,185,168)),((480,260,720,520),(213,68,59))]:
    for k in range(3): d.rectangle([x+k,y+k,x+w-1-k,y+h-1-k],outline=c)
for x in range(0,1680,12):
    if x<260 or x>=1420: d.rectangle([x,466,x+5,469],fill=(123,201,80))   # 45% line, face-safe columns
ov.resize((840,520),Image.NEAREST).save(OUT+'_review_still_rects_half.png')
ov.save(OUT+'_review_still_rects.png')
a=np.array(im.resize((W*4,H*4),Image.NEAREST)).astype(float)
a[260:780,480:1200]*=0.4
dim=Image.fromarray(a.astype(np.uint8)); dd=ImageDraw.Draw(dim)
for i in range(5):  # stand-in hub buttons
    y=290+i*96; dd.rectangle([560,y,1120,y+70],fill=(59,38,24),outline=(122,78,43),width=8)
dim.save(OUT+'_review_still_hubdim.png'); dim.resize((840,520),Image.NEAREST).save(OUT+'_review_still_hubdim_half.png')
t=im.resize((210,130),Image.BOX); t.save(OUT+'_review_still_thumb_210x130.png')
t.resize((840,520),Image.NEAREST).save(OUT+'_review_still_thumb_view.png')
g=im.convert('L'); g.resize((840,520),Image.NEAREST).save(OUT+'_review_still_values.png')
