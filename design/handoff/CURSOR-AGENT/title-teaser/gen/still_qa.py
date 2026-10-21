import numpy as np, glob, os, json
from PIL import Image
OUT='<TITLE_TEASER>/out/'
nat=Image.open(OUT+'title_still_native.png'); shp=Image.open(OUT+'title_still.png')
a=np.array(nat.convert('RGB')).astype(int); b=np.array(shp.convert('RGB')).astype(int)
r={'native':nat.size,'shipped':shp.size,'mode':[nat.mode,shp.mode],'format':shp.format,
   'x4_nearest_exact':bool((a.repeat(4,0).repeat(4,1)==b).all())}
cols=sorted(set(map(tuple,a.reshape(-1,3)))); r['palette_count']=len(cols)
files=sorted(set(glob.glob('src/live_cards/*.png')+glob.glob('src/assets/dungeon/items/*.png')+glob.glob('src/assets/dungeon/extra/*.png')))
live=[]
for f in files:
    im=np.array(Image.open(f).convert('RGBA'))
    for s in (8,4,2,1):
        if im.shape[0]%s==0 and im.shape[1]%s==0 and (im[::s,::s].repeat(s,0).repeat(s,1)==im).all(): break
    live.append((f,im[::s,::s]))
best=(0,None,None); per=[]
for nm,sp in live:
    al=sp[:,:,3]>0
    if al.sum()<12: continue
    rgb=sp[:,:,:3].astype(int); h,w=al.shape; bb=(0,None)
    if h>260 or w>420: continue
    for y in range(0,260-h+1):
        win=np.lib.stride_tricks.sliding_window_view(a[y:y+h],(h,w,3))[0,:,0]
        eq=(win==rgb[None]).all(-1)&al[None]
        fr=eq.sum((1,2))/al.sum(); i=int(fr.argmax())
        if fr[i]>bb[0]: bb=(float(fr[i]),(i,y))
    per.append((round(bb[0],3),os.path.basename(nm),bb[1]))
    if bb[0]>best[0]: best=(bb[0],nm,bb[1])
per.sort(reverse=True)
r['live_files_checked']=len(per); r['best_match']=per[0]; r['top5']=per[:5]
json.dump(r,open('<TITLE_TEASER>/qa_still/still_qa.json','w'),indent=1,default=str)
print(json.dumps(r,indent=1,default=str))
