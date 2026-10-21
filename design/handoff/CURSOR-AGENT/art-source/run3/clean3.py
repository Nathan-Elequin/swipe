import sys; sys.path.insert(0,'<ART_KIT>/pixellab/run2'); sys.path.insert(0,'<ART_KIT>/pixellab')
import importlib.util,numpy as np
from PIL import Image
src=open('<ART_KIT>/pixellab/run2/finalize2.py').read(); src=src[:src.index('def diff')]
g={}; exec(src,g); clean=g['clean']
def crop_canvas(im,N):
    # center horizontally, feet at bottom: fit object bbox in NxN
    bb=im.getbbox(); o=Image.new('RGBA',(N,N))
    if not bb: return o
    c=im.crop(bb); o.alpha_composite(c,((N-c.size[0])//2,N-c.size[1])); return o
