import os,sys,json,numpy as np
sys.path.insert(0,'<ART_KIT>/cleanup-test'); sys.path.insert(0,'<ART_KIT>/pixellab')
from common import PAL,PAL_HEX,snap_idx
from clean import components,N4
from PIL import Image,ImageDraw
OUTI=PAL_HEX.index('100e0c'); DARK=[i for i,h in enumerate(PAL_HEX) if sum(int(h[j:j+2],16) for j in (0,2,4))<90]
def clean(im,bottom=True):
    a=np.array(im.convert('RGBA')); op=a[...,3]>=128
    idx=snap_idx(a[...,:3].astype(float),PAL); idx[~op]=-1
    lab,sz=components(op)
    if sz:
        big=max(sz,key=sz.get)
        for k,s in sz.items():
            if s<6 and k!=big: idx[lab==k]=-1
    op=idx>=0; idx[op&(N4(op)==0)]=-1; op=idx>=0
    body=op&~np.isin(idx,DARK); idx[(~op)&(N4(body)>0)]=OUTI   # 1px outline, outside only
    op=idx>=0
    if bottom and op.any():
        sh=idx.shape[0]-1-np.where(op.any(1))[0].max()
        if sh>0: idx=np.roll(idx,sh,0); idx[:sh]=-1
    out=np.zeros(a.shape,np.uint8); m=idx>=0; out[m,:3]=PAL[idx[m]].astype(np.uint8); out[m,3]=255
    return Image.fromarray(out)
def diff(a,b): return int((np.abs(np.array(a,int)-np.array(b,int)).sum(-1)>60).sum())
R=lambda a,i: Image.open(f'raw/{a}_{i}.png').convert('RGBA')
nibp=max([(i,j) for i in range(1,5) for j in range(i+1,5)],key=lambda p:diff(R('nib_lantern',p[0]),R('nib_lantern',p[1])))
GRAB=open('grab_choice.txt').read().strip(); SEAL=open('seal_choice.txt').read().strip()
# out stem, raw, frames, subdir, group, bottom-align, crop24
SPEC=[('sprout_run','sprout_run',[1,2,3,4],'','Sprout 48',1,0),
 ('sprout_grab',GRAB,[1,2,3,4],'','Sprout 48',1,0),
 ('sprout_throw','sprout_throw',[1,2,3,4],'','Sprout 48',1,0),
 ('sprout64_idle','s64_idle',[1,2,3,4],'sprout64/','Sprout 64',1,0),
 ('sprout64_34_idle','s64_34_idle',[1,2,3,4],'sprout64/','Sprout 64',1,0),
 ('sprout64_run','s64_run',[1,2,3,4],'sprout64/','Sprout 64',1,0),
 ('sprout64_grab','s64_grab',[1,2,3,4],'sprout64/','Sprout 64',1,0),
 ('sprout64_throw','s64_throw',[1,2,3,4],'sprout64/','Sprout 64',1,0),
 ('nib_lantern','nib_lantern',list(nibp),'','Nib',1,0),
 ('nib_lantern_4f','nib_lantern',[1,2,3,4],'extras/','Nib',1,0),
 ('mon_ogre','ogre_run',[1,2,3,4],'','Monsters',1,0),
 ('mon_dire_wolf','wolf_gallop',[1,2,3,4],'','Monsters',1,0),
 ('mon_hornet_swarm','hornet_fly',[1,2,3,4],'','Monsters',0,0),
 ('item_pocketwatch_glint','pocketwatch_glint',[1,2,3,4],'extras/','Items (24)',0,1),
 ('item_grimoire_glint','grimoire_glint',[1,2,3,4],'extras/','Items (24)',0,1)]
os.makedirs('showcase/gif',exist_ok=True); BG=(26,22,18,255); done=[]
def save(im,path):
    os.makedirs(os.path.dirname(path),exist_ok=True); im.save(path)
    n=im.size; x4=path.replace('final/','final/x4/'); os.makedirs(os.path.dirname(x4),exist_ok=True)
    im.resize((n[0]*4,n[1]*4),0).save(x4)
def gif(fr,path,bg=BG):
    g=[]
    for im in fr:
        b=Image.new('RGBA',(im.size[0]*4,im.size[1]*4),bg); b.alpha_composite(im.resize(b.size,0)); g.append(b.convert('RGB'))
    p=g[0].quantize(256); g=[x.quantize(palette=p,dither=0) for x in g]
    g[0].save(path,save_all=True,append_images=g[1:],duration=125,loop=0)
for stem,raw,ids,sub,grp,bot,c24 in SPEC:
    fr=[clean(R(raw,i),bot) for i in ids]
    if c24: fr=[f.crop((4,4,28,28)) for f in fr]
    for k,im in enumerate(fr): save(im,f'final/{sub}{stem}_f{k}.png')
    gif(fr,f'showcase/gif/{stem}_x4_8fps.gif'); done.append((grp,stem,fr))
# optional checklist glint frames = strongest glint
for it,raw in [('pocketwatch','pocketwatch_glint'),('grimoire','grimoire_glint')]:
    k=max(range(1,5),key=lambda i:diff(R(raw,0),R(raw,i)))
    save(clean(R(raw,k),False).crop((4,4,28,28)),f'final/item_{it}_f1.png')
# intro panels (opaque crops pasted into native 320x180 panels)
for stem,raw,panel,xy in [('intro_p1_candle','p1_candle','base/intro_p1_native.png',(0,116)),('intro_p3_seal',SEAL,'base/intro_p3_native.png',(176,112))]:
    P=Image.open(panel).convert('RGBA'); fr=[]; crops=[]
    for k,i in enumerate([1,2,3,4]):
        c=R(raw,i); q=P.copy(); q.alpha_composite(c,xy); save(q,f'final/intro/{stem}_f{k}.png'); fr.append(q); crops.append(c)
    g=[f.resize((1280,720),0).convert('RGB') for f in fr]; p=g[0].quantize(256)
    g=[x.quantize(palette=p,dither=0) for x in g]; g[0].save(f'showcase/gif/{stem}_panel_x4_8fps.gif',save_all=True,append_images=g[1:],duration=125,loop=0)
    done.append(('Intro (64 crop)',stem,crops))
# contact sheet
rows=[(g,s,f,f[0].size[0]*4) for g,s,f in done]
W=8+max(200+len(f)*(h+8) for _,_,f,h in rows); H=sum(h+16 for *_,h in rows)+20*7+16
sh=Image.new('RGBA',(W,H),BG); d=ImageDraw.Draw(sh); y=8; last=None
for g,s,f,h in rows:
    if g!=last: d.text((8,y),'== '+g,fill=(255,216,74,255)); y+=20; last=g
    d.text((8,y+h//2),s,fill=(255,243,214,255))
    for k,im in enumerate(f): sh.alpha_composite(im.resize((im.size[0]*4,im.size[1]*4),0),(200+k*(h+8),y))
    y+=h+16
sh.crop((0,0,W,y)).save('showcase/contact_sheet_x4.png')
print('nib pair',nibp,'grab',GRAB,'seal',SEAL)
