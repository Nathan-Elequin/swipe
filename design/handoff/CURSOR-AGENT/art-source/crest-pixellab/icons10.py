# Hand-drawn 10px icon inits for the 18px medallion (nearest-shrinking the 13-15px icons broke the bolt and scales).
from PIL import Image
C={'O':(16,14,12),'G':(255,216,74),'g':(232,195,106),'b':(168,120,40),'D':(59,38,24),'w':(248,248,252),'s':(197,205,216),'r':(190,58,52),'R':(130,36,40)}
I={'horn':["........OO",
           "......OOGO",
           "OOOOOOGgDO",
           "OGgggggbDO",
           "OObbbbbbDO",
           "......OObO",
           "........OO"],
   'scales':["....OO....",
             "OOOOGGOOOO",
             "OGGGGgggbO",
             "OOOOgbOOOO",
             ".O..gb..O.",
             "OGO.gb.OGO",
             "ObO.gb.ObO",
             "...OgbO...",
             "..OGggbO..",
             "..OOOOOO.."],
   'bolt':["....OOO",
           "...OGGO",
           "..OGGO.",
           ".OGGOOO",
           "OGGGGGO",
           "OOOGGO.",
           "..OGO..",
           ".OGO...",
           ".OO...."],
   'fang':["OOOOOOO",
           "OwwwwsO",
           "OwwwwsO",
           ".OwwsO.",
           ".OwrsO.",
           "..OrO..",
           "..OrO..",
           "..ORO..",
           "...O..."]}
def get(k):
    rows=I[k]; im=Image.new('RGBA',(max(map(len,rows)),len(rows)),(0,0,0,0))
    for y,r in enumerate(rows):
        for x,ch in enumerate(r):
            if ch in C: im.putpixel((x,y),C[ch]+(255,))
    return im
