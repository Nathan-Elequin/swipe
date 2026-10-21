# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
# usage: python3 sheet.py out.png scale label=img1,img2 ...  (rows)
import sys
from PIL import Image,ImageDraw
out,sc=sys.argv[1],int(sys.argv[2]); rows=[]
for a in sys.argv[3:]:
    lab,fs=a.split('=',1); rows.append((lab,[Image.open(f).convert('RGBA') for f in fs.split(',')]))
W=max(110+sum(i.size[0]*sc+6 for i in r) for _,r in rows); H=sum(max(i.size[1] for i in r)*sc+18 for _,r in rows)+6
sh=Image.new('RGBA',(W,H),(60,52,70,255)); d=ImageDraw.Draw(sh); y=4
for lab,r in rows:
    d.text((4,y+4),lab,fill=(255,255,255,255)); x=110
    for i in r:
        t=Image.new('RGBA',(i.size[0]*sc,i.size[1]*sc),(60,52,70,255)); t.alpha_composite(i.resize(t.size,0)); sh.paste(t,(x,y)); x+=t.size[0]+6
    y+=max(i.size[1] for i in r)*sc+18
sh.save(out)
