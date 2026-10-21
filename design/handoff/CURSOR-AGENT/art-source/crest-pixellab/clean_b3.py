from qlib import clean
from PIL import Image
RIM=(28,24,20,255); OUT=(16,14,12,255)
def flood(im,seed,col):
    W,H=im.size; px=im.load(); st=[seed]; seen=set()
    while st:
        x,y=st.pop()
        if (x,y) in seen or not(0<=x<W and 0<=y<H) or px[x,y][3]: continue
        seen.add((x,y)); px[x,y]=col; st+=[(x+1,y),(x-1,y),(x,y+1),(x,y-1)]
sh=Image.open('raw/b3_med_0.png').convert('RGBA')
for i,ic in enumerate(['horn','scales','bolt','fang']):
    src=Image.open('raw/b3_med_horn2_0.png').convert('RGBA') if ic=='horn' else sh.crop(((i%2)*32,(i//2)*32,(i%2)*32+32,(i//2)*32+32))
    c=clean(src,outline=True); c=c.crop(c.getbbox())
    # dark separation rim: 1px #1c1814 ring outside the #100e0c outline
    W,H=c.size; o=Image.new('RGBA',(W+2,H+2),(0,0,0,0)); o.paste(c,(1,1)); s=o.copy(); px=o.load(); sp=s.load()
    for y in range(H+2):
        for x in range(W+2):
            if sp[x,y][3]==0 and any(0<=x+dx<W+2 and 0<=y+dy<H+2 and sp[x+dx,y+dy][3] for dx,dy in((1,0),(-1,0),(0,1),(0,-1))): px[x,y]=RIM
    o.save(f'clean/med18_{ic}.png'); print(ic,c.size,'->',o.size)
t=Image.open('raw/tag_topnotch_0.png').convert('RGBA'); flood(t,(20,9),(28,24,20,255))   # hand fix: hollow centre
t=clean(t,outline=False); px=t.load(); W,H=t.size
for x in range(W):                                     # hand fix: solid #100e0c outer ring (outside the notch)
    if px[x,H-1][3]: px[x,H-1]=OUT
    if px[x,0][3] and not (36<=x<=59): px[x,0]=OUT
for y in range(H):
    for x in (0,W-1):
        if px[x,y][3]: px[x,y]=OUT
t.save('clean/tag_topnotch.png'); print('tag',t.size)

# hand fix (small): lift the horn's shadow tones one palette step so it reads on the dark field
im=Image.open('clean/med18_horn.png').convert('RGBA'); px=im.load(); W,H=im.size
MAP={(122,78,43):(184,115,58),(106,74,26):(168,120,40),(216,168,64):(255,216,74)}
for y in range(H):
    for x in range(W):
        if (x-9.5)**2+(y-9.5)**2<5.5**2 and px[x,y][:3] in MAP: px[x,y]=MAP[px[x,y][:3]]+(255,)
im.save('clean/med18_horn.png')
