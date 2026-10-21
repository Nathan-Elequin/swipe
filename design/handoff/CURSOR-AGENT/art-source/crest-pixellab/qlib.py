# Cleanup: palette quantize, hard alpha (no AA), enforce 1px #100e0c outline, slice sheets.
from PIL import Image
import collections
PAL=[tuple(int(h[i:i+2],16) for i in (0,2,4)) for h in open('<ART_KIT>/_reference/refs/spinheritance.hex').read().split()]
OUT=(16,14,12)
def q(c): return min(PAL,key=lambda p:(p[0]-c[0])**2*2+(p[1]-c[1])**2*4+(p[2]-c[2])**2*3)
def clean(im,outline=True):
    im=im.convert('RGBA'); W,H=im.size; px=im.load(); cache={}
    for y in range(H):
        for x in range(W):
            r,g,b,a=px[x,y]
            if a<128: px[x,y]=(0,0,0,0); continue
            k=(r,g,b); cache.setdefault(k,q(k)); px[x,y]=cache[k]+(255,)
    if outline:  # add a 1px #100e0c ring OUTSIDE any lit edge pixel (never paint over art)
        bb=im.getbbox(); pad=Image.new('RGBA',(W+2,H+2),(0,0,0,0)); pad.paste(im,(1,1)); im=pad; px=im.load(); s=im.copy().load()
        dark=lambda c: sum(c[:3])<120
        for y in range(H+2):
            for x in range(W+2):
                if s[x,y][3]: continue
                if any(0<=x+dx<W+2 and 0<=y+dy<H+2 and s[x+dx,y+dy][3] and not dark(s[x+dx,y+dy]) for dx,dy in((1,0),(-1,0),(0,1),(0,-1))):
                    px[x,y]=OUT+(255,)
        im=im.crop(im.getbbox())
    return im
def fill_inside(im,col):
    # flood transparent interior from the centre (plate9 r1 came back hollow)
    W,H=im.size; px=im.load(); st=[(W//2,H//2)]; seen=set()
    while st:
        x,y=st.pop()
        if (x,y) in seen or not(0<=x<W and 0<=y<H) or px[x,y][3]: continue
        seen.add((x,y)); px[x,y]=col+(255,); st+=[(x+1,y),(x-1,y),(x,y+1),(x,y-1)]
    return im
