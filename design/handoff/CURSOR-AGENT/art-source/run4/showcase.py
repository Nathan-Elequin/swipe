import os,glob,re
from PIL import Image,ImageDraw
os.chdir('<ART_KIT>/pixellab/run4'); BG=(26,22,18,255); G='showcase/gif/'; os.makedirs(G,exist_ok=True)
def gif(fr,p,sc=4):
    g=[]
    for im in fr:
        b=Image.new('RGBA',(im.size[0]*sc,im.size[1]*sc),BG); b.alpha_composite(im.resize(b.size,0)); g.append(b.convert('RGB'))
    pal=g[0].quantize(256); g=[x.quantize(palette=pal,dither=0) for x in g]
    g[0].save(p,save_all=True,append_images=g[1:],duration=125,loop=0)
def groups(files):
    gr={}
    for f in sorted(files):
        n=os.path.basename(f)[:-4]; s=re.sub(r'_f\d+$','',n); gr.setdefault(s,[]).append(f)
    for s in gr: gr[s]=sorted(gr[s],key=lambda p:int(re.search(r'_f(\d+)\.png$',p).group(1)) if re.search(r'_f(\d+)\.png$',p) else -1)
    return gr
def sheet(rows,out,sc,label_w=260):
    ims=[(l,[Image.open(f).convert('RGBA') for f in fs]) for l,fs in rows]
    H=[max(i.size[1] for i in r)*sc for _,r in ims]; W=label_w+max(sum(i.size[0]*sc+6 for i in r) for _,r in ims)+8
    sh=Image.new('RGBA',(W,sum(h+10 for h in H)+10),BG); d=ImageDraw.Draw(sh); y=6
    for (l,r),h in zip(ims,H):
        d.text((6,y+h//2-5),l,fill=(255,216,74,255) if l.startswith('==') else (240,230,216,255)); x=label_w
        for i in r: sh.alpha_composite(i.resize((i.size[0]*sc,i.size[1]*sc),0),(x,y)); x+=i.size[0]*sc+6
        y+=h+10
    sh.crop((0,0,W,y)).save(out)
# UI + items
ui=groups(glob.glob('final/assets/ui/anim/*.png')+glob.glob('final/assets/dungeon/anim/*.png'))
stat=[f for s,fs in ui.items() for f in fs if not re.search(r'_f\d+\.png$',f)]
rows=[('static icons (16/12/8/4)',[f for f in stat if Image.open(f).size[0]<=16]),('static items (24)',[f for f in stat if Image.open(f).size[0]>16])]
for s,fs in ui.items():
    if re.search(r'_f\d+\.png$',fs[0]): rows.append((s,fs)); gif([Image.open(f).convert('RGBA') for f in fs],G+f'{s}_x4_8fps.gif')
sheet(rows,'showcase/contact_sheet_ui_items_x4.png',4)
# portraits
sl=groups(glob.glob('final/assets/dungeon/anim/slash/*_slash_f*.png'))
rows=[]
for s,fs in sl.items():
    k=s[:-6]; rows.append((k,[f'final/assets/dungeon/anim/slash/{k}_slash_base.png']+fs)); gif([Image.open(f).convert('RGBA') for f in fs],G+f'{s}_x4_8fps.gif')
sheet(rows,'showcase/contact_sheet_portraits_x2.png',2,180)
bs=sorted(glob.glob('final/bases/*_base.png')); rows=[(f'bases {i//8+1}',bs[i:i+8]) for i in range(0,len(bs),8)]
sheet(rows,'showcase/contact_sheet_bases_x1.png',1,90)
print('ok',len(ui),len(sl),len(bs))
