# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os
import sys,os,json,glob; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from clean4 import *; from mons import *
from PIL import Image
PC=json.load(open('pachoice.json')) if os.path.exists('pachoice.json') else {}
S='final/assets/dungeon/anim/slash/'; B='final/bases/'
os.makedirs(S,exist_ok=True); os.makedirs(B,exist_ok=True)
done=[]
for k in ORDER:
    cv,n,*_=M[k]
    if os.path.exists(f'work/pb/{k}.png'): Image.open(f'work/pb/{k}.png').save(B+f'{k}_base.png')
    if os.path.exists(f'work/crop/{k}.png'): Image.open(f'work/crop/{k}.png').save(S+f'{k}_slash_base.png')
    tag=PC.get(k,'a'); ids={4:[1,2,3,4],5:[0,1,2,3,4],6:[1,2,3,4,5,6]}[n]
    if not all(os.path.exists(f'raw/pa_{k}_{tag}_{i}.png') for i in ids): continue
    for p in glob.glob(S+f'{k}_slash_f*.png'): os.remove(p)
    for j,i in enumerate(ids):
        im=Image.open(f'work/crop/{k}.png') if i==0 else Image.open(f'raw/pa_{k}_{tag}_{i}.png')
        clean(im,minblob=2).save(S+f'{k}_slash_f{j}.png')
    done.append(k)
print(len(done),'portrait anims finalized')
