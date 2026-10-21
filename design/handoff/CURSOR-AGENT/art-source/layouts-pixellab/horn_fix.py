# Hand fix (PixelLab missed the war horn twice: r1 + r2 read as feather/loaf).
from PIL import Image
M=['...........OO..',
   '..........OGDO.',
   'OOO......OGgDO.',
   'OGgOO...OGgbDDO',
   '.OGggOOOGgbbDDO',
   '..OgggggggbbDDO',
   '...ObbbbbbbbDDO',
   '....OOOOOObbDDO',
   '.........ObbDO.',
   '..........OOO..']
C={'O':(16,14,12),'G':(255,216,74),'g':(232,195,106),'b':(168,120,40),'D':(59,38,24)}
im=Image.new('RGBA',(15,10),(0,0,0,0))
for y,r in enumerate(M):
    for x,ch in enumerate(r):
        if ch in C: im.putpixel((x,y),C[ch]+(255,))
im.save('clean/ic_horn.png')
