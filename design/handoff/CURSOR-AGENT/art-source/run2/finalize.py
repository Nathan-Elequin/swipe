import os,glob,json,sys
from cf import cleanframe
from PIL import Image, ImageDraw
BG=(26,22,18,255)
os.makedirs('final',exist_ok=True); os.makedirs('final/extras',exist_ok=True); os.makedirs('gif',exist_ok=True)
THROW=open('throw_choice.txt').read().strip() if os.path.exists('throw_choice.txt') else 'sprout_throw'
SEAL=open('seal_choice.txt').read().strip() if os.path.exists('seal_choice.txt') else 'p3_seal'
GRAB=open('grab_choice.txt').read().strip() if os.path.exists('grab_choice.txt') else 'sprout_grab'
# (out_stem, raw_prefix, frame indices, folder, group, bottom)
SPEC=[('sprout_run','sprout_run',[1,2,3,4],'final','Sprout 48',True),
 ('sprout_grab',GRAB,[1,2,3,4],'final','Sprout 48',True),
 ('sprout_throw',THROW,[1,2,3,4],'final','Sprout 48',True),
 ('sprout_spin','sprout_spin',[1,2,3,4],'final/extras','Sprout 48',True),
 ('sprout_jump','sprout_jump',[1,2,3,4],'final/extras','Sprout 48',False),
 ('sprout64_idle','s64_idle',[1,2,3,4],'final/extras','Sprout 64 (hi-res)',True),
 ('sprout64_run','s64_run',[1,2,3,4],'final/extras','Sprout 64 (hi-res)',True),
 ('sprout64_grab','s64_grab',[1,2,3,4],'final/extras','Sprout 64 (hi-res)',True),
 ('sprout64_throw','s64_throw',[1,2,3,4],'final/extras','Sprout 64 (hi-res)',True),
 ('sprout64_34_idle','s64_34_idle',[1,2,3,4],'final/extras','Sprout 64 (hi-res)',True),
 ('nib_lantern','nib_lantern',[1,2],'final','Nib',True),
 ('nib_lantern_4f','nib_lantern',[1,2,3,4],'final/extras','Nib',True),
 ('nib_wave','nib_wave',[1,2,3,4],'final/extras','Nib',True),
 ('mon_ogre','ogre_run',[1,2,3,4],'final','Monsters',True),
 ('mon_ogre_swing','ogre_swing',[1,2,3,4],'final/extras','Monsters',True),
 ('mon_dire_wolf','wolf_gallop',[1,2,3,4],'final','Monsters',True),
 ('mon_hornet_swarm','hornet_fly',[1,2,3,4],'final','Monsters',False),
 ('item_pocketwatch_glint','pocketwatch_glint',[1,2,3,4],'final/extras','Items',False),
 ('item_grimoire_glint','grimoire_glint',[1,2,3,4],'final/extras','Items',False)]
done={}
for stem,raw,ids,folder,grp,bot in SPEC:
    fs=[f'raw/{raw}_{i}.png' for i in ids]
    if not all(os.path.exists(f) for f in fs): continue
    fr=[cleanframe(Image.open(f),bottom=bot) for f in fs]
    if not bot:  # keep a shared vertical offset: none
        pass
    for k,im in enumerate(fr): im.save(f'{folder}/{stem}_f{k}.png')
    N=fr[0].size[0]; g=[]
    for im in fr:
        b=Image.new('RGBA',(N*4,N*4),BG); b.alpha_composite(im.resize((N*4,N*4),0)); g.append(b.convert('P',palette=Image.ADAPTIVE))
    g[0].save(f'gif/{stem}_x4_8fps.gif',save_all=True,append_images=g[1:],duration=125,loop=0,disposal=2)
    done[stem]=(grp,fr)
# intro panels: paste animated crop back into native panel
for stem,raw,panel,xy in [('intro_p1_candle','p1_candle','base/intro_p1_native.png',(0,116)),('intro_p3_seal',SEAL,'base/intro_p3_native.png',(176,112))]:
    fs=[f'raw/{raw}_{i}.png' for i in (1,2,3,4)]
    if not all(os.path.exists(f) for f in fs): continue
    P=Image.open(panel).convert('RGBA'); g=[]; crops=[]
    for k,f in enumerate(fs):
        c=Image.open(f).convert('RGBA'); q=P.copy(); q.alpha_composite(c,xy)
        q.resize((1280,720),0).save(f'final/extras/{stem}_f{k}.png'); crops.append(c)
        g.append(q.resize((640,360),0).convert('P',palette=Image.ADAPTIVE))
    g[0].save(f'gif/{stem}_panel_x2_8fps.gif',save_all=True,append_images=g[1:],duration=125,loop=0)
    gc=[Image.alpha_composite(Image.new('RGBA',(256,256),BG),c.resize((256,256),0)).convert('P',palette=Image.ADAPTIVE) for c in crops]
    gc[0].save(f'gif/{stem}_crop_x4_8fps.gif',save_all=True,append_images=gc[1:],duration=125,loop=0)
    done[stem]=('Intro (crop 64)',crops)
# contact sheet grouped
groups=[]
for stem,(grp,fr) in done.items():
    groups.append((grp,stem,fr))
order=['Sprout 48','Sprout 64 (hi-res)','Nib','Monsters','Items','Intro (crop 64)']
groups.sort(key=lambda t:order.index(t[0]))
rows=[]; 
for grp,stem,fr in groups:
    N=fr[0].size[0]; rows.append((grp,stem,fr,N*4))
W=8+max(160+len(fr)*(h+8) for _,_,fr,h in rows); H=sum(h+24 for *_,h in rows)+8+ 24*len(order)
sheet=Image.new('RGBA',(W,H),BG); d=ImageDraw.Draw(sheet); y=8; last=None
for grp,stem,fr,h in rows:
    if grp!=last: d.text((8,y),'== '+grp,fill=(255,216,74,255)); y+=20; last=grp
    d.text((8,y+h//2),stem,fill=(255,243,214,255))
    for k,im in enumerate(fr):
        s=im.resize((im.size[0]*4,im.size[1]*4),0); sheet.alpha_composite(s,(160+k*(h+8),y))
    y+=h+16
sheet.crop((0,0,W,y+8)).save('showcase_contact_x4.png')
print(json.dumps({k:v[0] for k,v in done.items()}))
