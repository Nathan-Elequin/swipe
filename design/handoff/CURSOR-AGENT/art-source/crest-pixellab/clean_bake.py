# Pick per crest: PixelLab bake pass (pl) or the native composite init (in) where PL blurred the icon.
from qlib import clean
from PIL import Image
ICONS=['horn','scales','bolt','fang']
PICK={'medallion':['pl','pl','pl','pl'],'shield':['pl','in','in','pl']}
for kind,picks in PICK.items():
    srcs={'pl':Image.open(f'raw/bake_{kind}_0.png').convert('RGBA'),'in':Image.open(f'init/bake_{kind}.png').convert('RGBA')}
    for i,ic in enumerate(ICONS):
        cell=srcs[picks[i]].crop(((i%2)*32,(i//2)*32,(i%2)*32+32,(i//2)*32+32))
        c=clean(cell,outline=False); bb=c.getbbox(); c=c.crop(bb)
        # outer ring of the crest must be #100e0c (Crypt Classic); re-ring if PL lightened it
        c=clean(c.crop((1,1,c.width-1,c.height-1)),outline=True) if c.getpixel((c.width//2,0))[:3]!=(16,14,12) else c
        c.save(f'clean/{kind}_{ic}.png'); print(kind,ic,picks[i],c.size)
