# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import sys,os,json,time,threading
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from paths import RUN_DIR,PALETTE_HEX
os.makedirs(RUN_DIR,exist_ok=True); os.chdir(RUN_DIR); os.makedirs('raw',exist_ok=True)
import pl; pl.LOG=os.path.join(RUN_DIR,'calls.log')
from pl import b64,palette_img,balance
from concurrent.futures import ThreadPoolExecutor
FLOOR=0
BUDGET=int(os.environ.get('PL_BUDGET','40'))  # per-batch cap counted from calls.log; raise deliberately
import requests
LOCK=threading.Lock()
def bal():
    for i in range(8):
        try:
            r=requests.get(pl.API+'/balance',headers=pl.H,timeout=30)
            if r.ok: return r.json()['subscription']['generations']
        except Exception: pass
        time.sleep(10)
    return None
def spent():
    import re
    try: return sum(float(m.group(1)) for l in open(pl.LOG) for m in [re.search(r'"usage_gens": ([0-9.]+)',l)] if m)
    except FileNotFoundError: return 0.0
def call(ep,payload,prefix):
    prefix='raw/'+prefix
    with LOCK:
        if spent()+1>BUDGET-INFLIGHT[0]: print('STOP budget',prefix); return []
        INFLIGHT[0]+=1
    try:
        for i in range(6):
            try: r=requests.post(pl.API+ep,headers=pl.H,json=payload,timeout=300)
            except Exception as e: print('post exc',e); time.sleep(15); continue
            if r.status_code in (429,502,503,504) or (r.status_code==500 and "detail" not in r.text): print(prefix,'retry',r.status_code); time.sleep(20*(i+1)); continue
            break
        try: j=r.json()
        except Exception: j={'raw':r.text[:300]}
        if r.ok and j.get('background_job_id'):
            jid=j['background_job_id']
            while True:
                time.sleep(8)
                try: j=requests.get(f'{pl.API}/background-jobs/{jid}',headers=pl.H,timeout=60).json()
                except Exception: continue
                if j.get('status') not in ('processing','pending','queued'): break
        out=[]; pl.save_images(j,prefix,out)
        def strip(o):
            if isinstance(o,dict): return {k:('<b64>' if k=='base64' else strip(v)) for k,v in o.items()}
            if isinstance(o,list): return [strip(v) for v in o]
            return o
        u=(j.get('usage') or {}).get('generations')
        if u is None and out and r.ok: u=1
        if not r.ok: u=0
        rec={'t':time.strftime('%H:%M:%S'),'endpoint':ep,'prefix':prefix,'status':r.status_code,'usage':j.get('usage'),'usage_gens':u or 0,'files':out,'resp':json.dumps(strip(j))[:1500]}
        with LOCK: open(pl.LOG,'a').write(json.dumps(rec)+'\n')
        print(prefix,r.status_code,u,len(out),json.dumps(rec['resp'])[:200] if not out else '')
        return out
    finally:
        with LOCK: INFLIGHT[0]-=1
INFLIGHT=[0]
def anim(base,action,prefix,seed=11,nb=True,n=4,last=None):
    p={'first_frame':b64(base),'action':action,'frame_count':n,'no_background':nb,'seed':seed}
    if last: p['last_frame']=b64(last)
    return call('/animate-with-text-v3',p,prefix)
STY=dict(outline='single color black outline',shading='medium shading',detail='medium detail',view='side',direction='east')
def pixflux(desc,size,prefix,seed,init=None,init_s=150,**kw):
    p={'description':desc,'image_size':{'width':size,'height':size},'no_background':True,'color_image':b64(palette_img()),'text_guidance_scale':8,'seed':seed,**STY,**kw}
    if init: p['init_image']=b64(init); p['init_image_strength']=init_s
    return call('/create-image-pixflux',p,prefix)
def bitforge(desc,size,prefix,seed,style,style_s=40,init=None,init_s=150,**kw):
    p={'description':desc,'image_size':{'width':size,'height':size},'no_background':True,'color_image':b64(palette_img()),'style_image':b64(style),'style_strength':style_s,'seed':seed,**STY,**kw}
    if init: p['init_image']=b64(init); p['init_image_strength']=init_s
    return call('/create-image-bitforge',p,prefix)
def par(jobs,n=3):
    with ThreadPoolExecutor(n) as ex:
        fs=[ex.submit(f,*a,**k) for f,a,k in jobs]
        out=[]
        for f in fs:
            try: out.append(f.result())
            except BaseException as e: print('ERR',repr(e)); out.append(None)
        return out
J=lambda f,*a,**k:(f,a,k)
from PIL import Image as _I
TOK=['8b1e1e','6a1c14','e07a7a','8dcb8d','d4894e','f4f7fb','ffe6a8','aaa2c6','7a6aa8','766e9a','4a446a','4a3a78','2e2450']
def palette_img():
    cols=[l.strip() for l in open(PALETTE_HEX) if l.strip()]+TOK
    im=_I.new('RGB',(10,8))
    for i,c in enumerate(cols): im.putpixel((i%10,i//10),tuple(int(c[j:j+2],16) for j in (0,2,4)))
    return im
def pix(desc,w,h,prefix,seed,init=None,init_s=150,**kw):
    p={'description':desc,'image_size':{'width':w,'height':h},'no_background':True,'color_image':b64(palette_img()),'text_guidance_scale':8,'seed':seed,**STY,**kw}
    if init: p['init_image']=b64(init); p['init_image_strength']=init_s
    return call('/create-image-pixflux',p,prefix)
