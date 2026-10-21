# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os
import sys,os,shutil; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from clean4 import *
from PIL import Image
U='final/assets/ui/anim/'; D='final/assets/dungeon/anim/'
for d in (U,D): os.makedirs(d,exist_ok=True)
W='work/ui/'
def cp(src,dst): Image.open(W+src+'.png').save(dst)
for n in ['intent_claw_idle','intent_claw_flame_idle','ticker_token_frame','ticker_ff']+[f'intent_chip_{c}' for c in ('shield','drop','flee','plus')]+[f'aura_glyph_{g}' for g in ('sword','wisp','drop','lock','shield')]:
    cp(n,U+n+'.png')
for n in ['sai_single','sai_pair','marble_red','marble_blue','hook_taut']: cp(n,D+n+'.png')
r=down(Image.open('raw/rope_r2_0.png').convert('RGBA'),8); r=clean(r,outline=False)
import numpy as np
a=np.array(r); a[:,0,:3]=(16,14,12); a[:,-1,:3]=(16,14,12); a[...,3]=255; Image.fromarray(a).crop((0,0,4,8)).save(D+'rope_tile.png')
A=[('claw_lit',U+'intent_claw_lit',[1,2,3,4],2),('claw_burst',U+'intent_claw_burst',[1,2,3,4],2),('flame_burst',U+'intent_claw_flame_burst',[1,2,3,4],2),
 ('stamp',U+'ticker_token_stamp',[1,2,3,4],3),('pdrip',U+'poison_badge_drip',[1,2,3,4],4),('pburst_r2',U+'poison_burst',[1,2,3,4],2),('hdrip_r2',U+'heart_drip',[1,2,3,4],3),
 ('sai_split_r2',D+'sai_split',[0,2,3,4,5,6,7,8],2),('marble_idle',D+'marble_idle',[1,2,3,4],2),('marble_swirl',D+'marble_swirl',[1,2,3,4,5,6],2),
 ('cat_idle',D+'marble_cat_idle',[1,2,3,4],2),('hook_throw',D+'hook_throw',[1,2,3,4,5,6],2),('petrify',U+'petrify_shatter',[0,1,2,3,4],2),('sparkle',U+'deadly_sparkle',[1,2,3,4],4)]
done=[]
for raw,stem,ids,f in A:
    if not all(os.path.exists(f'raw/{raw}_{i}.png') for i in ids): print('missing',raw); continue
    for k,i in enumerate(ids):
        im=clean(down(Image.open(f'raw/{raw}_{i}.png').convert('RGBA'),f),minblob=1 if 'burst' in raw or raw.split('_r')[0] in('petrify','pdrip','hdrip','sparkle') else 3)
        im.save(f'{stem}_f{k}.png')
    done.append(stem)
print(len(done),'anims')
