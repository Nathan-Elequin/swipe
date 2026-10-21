import glob
from PIL import Image
CA='<ART_KIT>/cleanup-all/'
L=lambda p:[Image.open(f).convert('RGBA') for f in sorted(glob.glob(p))]
run=L('final/sprout_run_f?.png'); grab=L('final/sprout_grab_f?.png'); nib=L('final/nib_lantern_f?.png')
M=dict(ogre=L('final/mon_ogre_f?.png'),wolf=L('final/mon_dire_wolf_f?.png'),hor=L('final/mon_hornet_swarm_f?.png'),
 gob=L(CA+'mon_goblin_f?_native32.png'),skel=L(CA+'mon_skeleton_f?_native32.png'),spi=L(CA+'mon_spider_queen_f?_native48.png'),dra=L(CA+'mon_dragon_f?_native64.png'))
FL=644
hill=Image.open('<TITLE_TEASER>/out/hill_strip.png').convert('RGBA'); hall=Image.open('<TITLE_TEASER>/out/hall_strip.png').convert('RGBA')
def put(bg,im,x,feet=FL,top=None):
    s=im.resize((im.size[0]*4,im.size[1]*4),0); y=top if top is not None else feet-s.size[1]+1
    bg.alpha_composite(s,(int(x),int(y)))
frames=[]
for t in range(12):                      # hill: Nib waves Sprout on, Sprout runs right
    bg=hill.copy(); put(bg,nib[(t//2)%2],260); put(bg,run[t%4],420+t*48); frames.append(bg)
for t in range(16):                      # hall: Sprout runs/grabs, monsters chase
    bg=hall.copy(); sp=grab if 6<=t<10 else run; put(bg,sp[t%4],1180+10*(min(t,6)+max(0,t-10)))
    x0=-300+t*30
    for k,(m,dx) in enumerate([('dra',0),('spi',300),('ogre',520),('skel',740),('gob',890),('wolf',1030)]):
        put(bg,M[m][(t+k)%len(M[m])],x0+dx)
    put(bg,M['hor'][t%4],x0+780,top=300+(t%2)*8)
    frames.append(bg)
g=[f.convert('RGB').resize((840,520),Image.NEAREST) for f in frames]
p=g[0].quantize(256); p2=g[14].quantize(256)
g=[x.quantize(256,dither=0) for x in g]
g[0].save('showcase/teaser_preview.gif',save_all=True,append_images=g[1:],duration=125,loop=0,optimize=True)
s=Image.new('RGB',(840*2,520*2))
for i,k in enumerate([3,9,16,24]): s.paste(frames[k].convert('RGB').resize((840,520),0),((i%2)*840,(i//2)*520))
s.save('/tmp/teaser_check.png'); print(len(frames))
