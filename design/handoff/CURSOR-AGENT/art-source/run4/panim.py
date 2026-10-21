import sys,os
from lib4 import *; from mons import *
import functools; print=functools.partial(print,flush=True)
ids=sys.argv[1].split(','); seed=int(sys.argv[2]) if len(sys.argv)>2 else 11; tag=sys.argv[3] if len(sys.argv)>3 else 'a'
def job(k):
    cv,n,act,desc,ref=M[k]
    return anim(f'work/crop/{k}.png',f"close-up anime cut-in portrait of the {desc}: {act}; dramatic, keeps the same character design",f'pa_{k}_{tag}',seed=seed,n=6 if n==6 else 4)
par([J(job,k) for k in ids],int(os.environ.get('PAR','3')))
