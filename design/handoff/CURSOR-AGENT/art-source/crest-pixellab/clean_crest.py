from qlib import clean as pclean   # palette quantize + hard alpha + outside 1px #100e0c
from PIL import Image
def flood(im,seed,col):
    W,H=im.size; px=im.load(); st=[seed]; seen=set()
    while st:
        x,y=st.pop()
        if (x,y) in seen or not(0<=x<W and 0<=y<H) or px[x,y][3]: continue
        seen.add((x,y)); px[x,y]=col; st+=[(x+1,y),(x-1,y),(x,y+1),(x,y-1)]
for k in ['tag_round','tag_shield']:
    im=Image.open(f'raw/{k}_0.png').convert('RGBA'); px=im.load(); W,H=im.size
    # clear anything inside the notch below the gold lip (round notch came back grey)
    for y in range(H):
        for x in range(W):
            r,g,b,a=px[x,y]
            if a and abs(x-W//2)<=10 and y>=H-4 and not (r>150 and g>120): px[x,y]=(0,0,0,0)
    flood(im,(20,7),(28,24,20,255))      # hand fix: hollow centre -> #1c1814 (same as plate9)
    im=pclean(im,outline=False); im.save(f'clean/{k}.png'); print(k,im.size)
for k in ['medallion','shield']:
    im=pclean(Image.open(f'raw/{k}_0.png'),outline=False); bb=im.getbbox(); im=im.crop(bb); im.save(f'clean/{k}_frame.png'); print(k,bb,im.size)
