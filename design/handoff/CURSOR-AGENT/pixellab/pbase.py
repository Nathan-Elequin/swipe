# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os
import sys
from lib import *; from mons import *
import functools; print=functools.partial(print,flush=True)
import os
INIT_S=os.environ.get('SMOOTH')=='1'
import os
ids=sys.argv[1].split(','); seed=int(sys.argv[2]) if len(sys.argv)>2 else 11; strength=int(sys.argv[3]) if len(sys.argv)>3 else 160
def job(k):
    cv,n,act,desc,ref=M[k]; S=BASE[cv]
    D=f"full body {desc}, standing facing right, three-quarter side view, high detail pixel art monster, clean readable silhouette, crisp 1px dark outline, 3-4 tone shading lit from upper left, dark fantasy dungeon game"
    return pix(D,S,S,f'pb_{k}_s{seed}',seed) if os.environ.get('NOINIT')=='1' else pix(D,S,S,f'pb_{k}_s{seed}',seed,init=(f'base/pinit_s/{k}.png' if INIT_S else f'base/pinit/{k}.png'),init_s=strength)
par([J(job,k) for k in ids],int(sys.argv[4]) if len(sys.argv)>4 else 2)
