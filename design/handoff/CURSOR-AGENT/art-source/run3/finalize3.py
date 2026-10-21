import sys,os,glob,json,numpy as np
sys.path.insert(0,'.'); from clean3 import clean
from PIL import Image,ImageDraw,ImageOps
os.chdir('<ART_KIT>/pixellab/run3')
CH=json.load(open('choices.json'))  # name -> raw stem (and optional 'mirror')
# stem, raw key, out size, group, align: 'each' (feet per-frame), 'union' (common shift, keeps hops), 'none'
SPEC=[('mon_dire_wolf_gallop','wolf',32,'Dire wolf','each'),
 ('mon_hornet_swarm_fly','hornet',32,'Hornet swarm','none'),
 ('mon_goblin_run','goblin',32,'Goblin','each'),('mon_skeleton_run','skeleton',32,'Skeleton','each'),
 ('mon_spider_queen_move','spider',48,'Spider queen','each'),('mon_dragon_move','dragon',64,'Dragon','each'),
 ('sprout64_hurt','hurt',64,'Sprout 64','union'),('sprout64_victory','victory',64,'Sprout 64','union'),
 ('sprout64_defeat','defeat',64,'Sprout 64','each'),('sprout64_blink','blink',64,'Sprout 64','union'),
 ('intro_lantern_flicker','lantern',32,'Intro extras','union'),('intro_coin_glint','coin',32,'Intro extras','union'),
 ('intro_scroll_unfurl','scroll',48,'Intro extras','union')]
BASES=[('mon_dire_wolf_base','base/wolf32_R.png','Dire wolf'),('mon_hornet_swarm_base','base/hornet32.png','Hornet swarm'),('mon_goblin_base','base/goblin32.png','Goblin'),
 ('mon_skeleton_base','base/skeleton32.png','Skeleton'),('mon_spider_queen_base','base/spider48.png','Spider queen'),('mon_dragon_base','base/dragon64.png','Dragon')]
def fit(frames,N,align):
    # frames: cleaned RGBA (no bottom shift). place into NxN with one common x-shift.
    bbs=[f.getbbox() for f in frames]; x0=min(b[0] for b in bbs); x1=max(b[2] for b in bbs)
    y0=min(b[1] for b in bbs); y1=max(b[3] for b in bbs)
    dx=(N-(x1-x0))//2-x0; out=[]
    for f,b in zip(frames,bbs):
        if align=='each': dy=N-b[3]
        elif align=='union': dy=N-y1
        else: dy=(N-(y1-y0))//2-y0
        o=Image.new('RGBA',(N,N)); o.alpha_composite(f,(0,0)) if False else None
        o.paste(f,(dx,dy),f); out.append(o)
    return out
BG=(26,22,18,255)
def save(im,p):
    im.save('final/'+p); im.resize((im.size[0]*4,im.size[1]*4),0).save('final/x4/'+p)
def gif(fr,p):
    g=[]
    for im in fr:
        b=Image.new('RGBA',(im.size[0]*4,im.size[1]*4),BG); b.alpha_composite(im.resize(b.size,0)); g.append(b.convert('RGB'))
    pal=g[0].quantize(256); g=[x.quantize(palette=pal,dither=0) for x in g]
    g[0].save(p,save_all=True,append_images=g[1:],duration=125,loop=0)
os.makedirs('final/x4',exist_ok=True); os.makedirs('showcase/gif',exist_ok=True)
rows=[]; report={}
for stem,key,N,grp,al in SPEC:
    c=CH.get(key)
    if not c: continue
    raw=c['raw']; ids=c.get('frames',[1,2,3,4])
    if not all(os.path.exists(f'raw/{raw}_{i}.png') for i in ids): print('missing',raw); continue
    fr=[clean(Image.open(f'raw/{raw}_{i}.png'),bottom=False) for i in ids]
    if c.get('mirror'): fr=[ImageOps.mirror(f) for f in fr]
    fr=fit(fr,N,al)
    for k,im in enumerate(fr): save(im,f'{stem}_f{k}.png')
    gif(fr,f'showcase/gif/{stem}_x4_8fps.gif'); rows.append((grp,stem,fr))
    bb=[f.getbbox() for f in fr]; report[stem]={'bbox':bb,'edge_touch':any(b[0]==0 or b[2]==N or b[1]==0 for b in bb)}
for stem,p,grp in BASES:
    im=fit([clean(Image.open(p),bottom=False)],Image.open(p).size[0],'each')[0]; save(im,f'{stem}.png'); rows.append((grp,stem,[im]))
if os.path.exists('raw_c/hero128.png'):
    im=Image.open('raw_c/hero128.png'); save(im,'sprout_hero128.png'); rows.append(('Sprout hero (Pro Flash)','sprout_hero128',[im]))
order=['Dire wolf','Hornet swarm','Goblin','Skeleton','Spider queen','Dragon','Sprout 64','Sprout hero (Pro Flash)','Intro extras']
rows.sort(key=lambda r:order.index(r[0]))
H=[max(i.size[1] for i in f)*4 for *_,f in rows]
W=8+max(230+sum(i.size[0]*4+8 for i in f) for *_,f in rows); TH=sum(h+16 for h in H)+20*len(order)+16
sh=Image.new('RGBA',(W,TH),BG); d=ImageDraw.Draw(sh); y=8; last=None
for (g,s,f),h in zip(rows,H):
    if g!=last: d.text((8,y),'== '+g,fill=(255,216,74,255)); y+=20; last=g
    d.text((8,y+h//2),s,fill=(255,243,214,255)); x=230
    for im in f: sh.alpha_composite(im.resize((im.size[0]*4,im.size[1]*4),0),(x,y)); x+=im.size[0]*4+8
    y+=h+16
sh.crop((0,0,W,y)).save('showcase/contact_sheet_x4.png'); print(json.dumps(report))
