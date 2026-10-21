import os,glob,re
from PIL import Image,ImageDraw
os.chdir('<ART_KIT>/pixellab/run3')
BG=(26,22,18,255)
for p in glob.glob('final/x4/*.png'):
    if not os.path.exists('final/'+os.path.basename(p)): os.remove(p)
for p in glob.glob('final/*.png'):
    im=Image.open(p); im.resize((im.size[0]*4,im.size[1]*4),0).save('final/x4/'+os.path.basename(p))
L=lambda n:[Image.open(f'final/{n}.png').convert('RGBA') for n in n]
def gif(fr,p):
    g=[]
    for im in fr:
        b=Image.new('RGBA',(im.size[0]*4,im.size[1]*4),BG); b.alpha_composite(im.resize(b.size,0)); g.append(b.convert('RGB'))
    pal=g[0].quantize(256); g=[x.quantize(palette=pal,dither=0) for x in g]
    g[0].save(p,save_all=True,append_images=g[1:],duration=125,loop=0)
G='showcase/gif/'
for a in ['mon_dire_wolf_gallop','sprout64_hurt','sprout64_victory','intro_scroll_unfurl']:
    gif(L([f'{a}_f{k}' for k in range(4)]),G+f'{a}_x4_8fps.gif')
gif(L(['sprout64_hurt_f0','sprout64_hurt_f1_flash','sprout64_hurt_f2','sprout64_hurt_f3']),G+'sprout64_hurt_flash_x4_8fps.gif')
gif(L(['sprout64_blink_f0']*7+['sprout64_blink_f1']),G+'sprout64_blink_x4_8fps.gif')
# contact sheet from final/
GR=[('Dire wolf','mon_dire_wolf'),('Hornet swarm','mon_hornet_swarm'),('Goblin','mon_goblin'),('Skeleton','mon_skeleton'),('Spider queen','mon_spider_queen'),
    ('Dragon','mon_dragon'),('Sprout 64','sprout64'),('Sprout hero (Pro Flash)','sprout_hero'),('Intro extras','intro_')]
rows=[]
for g,pre in GR:
    stems={}
    for p in sorted(glob.glob(f'final/{pre}*.png')):
        n=os.path.basename(p)[:-4]; m=re.match(r'(.*)_f\d+(_flash)?$',n); s=(m.group(1)+('_flash' if m.group(2) else '')) if m else n
        stems.setdefault(s,[]).append(Image.open(p).convert('RGBA'))
    for s,f in stems.items(): rows.append((g,s,f))
H=[max(i.size[1] for i in f)*4 for *_,f in rows]
W=8+max(230+sum(i.size[0]*4+8 for i in f) for *_,f in rows)
sh=Image.new('RGBA',(W,sum(h+16 for h in H)+20*len(GR)+16),BG); d=ImageDraw.Draw(sh); y=8; last=None
for (g,s,f),h in zip(rows,H):
    if g!=last: d.text((8,y),'== '+g,fill=(255,216,74,255)); y+=20; last=g
    d.text((8,y+h//2),s,fill=(255,243,214,255)); x=230
    for im in f: sh.alpha_composite(im.resize((im.size[0]*4,im.size[1]*4),0),(x,y)); x+=im.size[0]*4+8
    y+=h+16
sh.crop((0,0,W,y)).save('showcase/contact_sheet_x4.png'); print([r[1] for r in rows])
