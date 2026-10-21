import os,glob
from PIL import Image, ImageChops
CA='<ART_KIT>/cleanup-all/'
def seq(pattern):
    fs=sorted(glob.glob(pattern)); return [Image.open(f).convert('RGBA') for f in fs]
def F(stem,folder='final'): return seq(f'{folder}/{stem}_f[0-9].png')
run=F('sprout_run'); grab=F('sprout_grab'); nib=F('nib_lantern')
gob=seq(CA+'mon_goblin_f[0-9]_native32.png'); skel=seq(CA+'mon_skeleton_f[0-9]_native32.png')
wolf=F('mon_dire_wolf'); ogre=F('mon_ogre'); hor=F('mon_hornet_swarm')
items=[Image.open(f'../items/item_{i}.png') for i in ('pocketwatch','lantern','grimoire','healing_potion')]
FLOOR=161
def put(bg,im,x,feet=None,top=None):
    y=(FLOOR-im.size[1]+1) if feet is None and top is None else (feet-im.size[1]+1 if feet is not None else top)
    bg.alpha_composite(im,(int(x),int(y)))
def scroll(strip,dx):
    w=strip.size[0]; dx%=w; return ImageChops.offset(strip,-dx,0)
frames=[]
hill=Image.open('<TITLE_TEASER>/out/hill_strip_native.png').convert('RGBA')
hall=Image.open('<TITLE_TEASER>/out/hall_strip_native.png').convert('RGBA')
for t in range(16):
    bg=scroll(hill,t*3)
    if nib: put(bg,nib[(t//2)%len(nib)],70-t*3)
    if run: put(bg,run[t%len(run)],170+t*2)
    frames.append(bg)
for t in range(24):
    bg=scroll(hall,t*4)
    sp=(grab if (8<=t<12 and grab) else run)
    if sp: put(bg,sp[t%len(sp)],200)
    for k,(m,x) in enumerate([(gob,30),(wolf,80),(skel,130)]):
        if m: put(bg,m[t%len(m)],x+t*0.5)
    if hor: put(bg,hor[t%len(hor)],10+t,top=70+(t%2))
    if ogre: put(bg,ogre[t%len(ogre)],-40+t*1.5)
    for k,it in enumerate(items):
        bob=[0,-1,-2,-1][(t+k)%4]
        x=280+k*34-t*3
        if 8<=t<12 and k==0: continue
        if x>-24: put(bg,it,x,top=118+bob)
    frames.append(bg)
g=[f.resize((840,520),0).convert('P',palette=Image.ADAPTIVE) for f in frames]
g[0].save('teaser_preview_x2_8fps.gif',save_all=True,append_images=g[1:],duration=125,loop=0)
strip=Image.new('RGBA',(420*4,260),(0,0,0,255))
for i,k in enumerate([2,10,20,30]): strip.paste(frames[k],(i*420,0))
strip.resize((420*4*2,520),0).save('teaser_preview_strip_x2.png')
print(len(frames))
