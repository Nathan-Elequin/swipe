# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os,sys,json,base64,time,io,requests
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from paths import PALETTE_HEX
from PIL import Image
API='https://api.pixellab.ai/v2'
_TOK=os.environ.get('PIXELLAB_API_TOKEN','')
if not _TOK: sys.exit('PIXELLAB_API_TOKEN is not set (Cursor cloud secret / local env). Never hardcode it.')
H={'Authorization':'Bearer '+_TOK}
LOG='calls.log'
def b64(path_or_im):
    if isinstance(path_or_im,str): data=open(path_or_im,'rb').read()
    else:
        bio=io.BytesIO(); path_or_im.save(bio,'PNG'); data=bio.getvalue()
    return {'type':'base64','base64':base64.b64encode(data).decode(),'format':'png'}
def balance():
    return requests.get(API+'/balance',headers=H).json()['subscription']['generations']
def palette_img():
    cols=[l.strip() for l in open(PALETTE_HEX) if l.strip()]
    im=Image.new('RGB',(8,8))
    for i,c in enumerate(cols): im.putpixel((i%8,i//8),tuple(int(c[j:j+2],16) for j in (0,2,4)))
    return im
def save_images(obj,prefix,out):
    n=0
    def walk(o):
        nonlocal n
        if isinstance(o,dict):
            if o.get('type')=='base64' and 'base64' in o:
                s=o['base64'].split(',')[-1]; fn=f'{prefix}_{n}.png'; open(fn,'wb').write(base64.b64decode(s)); out.append(fn); n+=1; return
            for k,v in o.items():
                if k=='base64' and isinstance(v,str) and len(v)>100:
                    fn=f'{prefix}_{n}.png'; open(fn,'wb').write(base64.b64decode(v.split(',')[-1])); out.append(fn); n+=1
                else: walk(v)
        elif isinstance(o,list):
            for v in o: walk(v)
    walk(obj)
def call(endpoint,payload,prefix,budget_floor):
    b0=balance()
    if b0-1 < budget_floor: sys.exit(f'STOP: balance {b0} would go below floor {budget_floor}')
    for _ in range(4):
        r=requests.post(API+endpoint,headers=H,json=payload,timeout=300)
        if r.status_code!=429: break
        time.sleep(20)
    try: j=r.json()
    except Exception: j={'raw':r.text[:500]}
    if 'background_job_id' in json.dumps(j)[:2000] and r.ok:
        jid=j.get('background_job_id')
        while True:
            time.sleep(6); j=requests.get(f'{API}/background-jobs/{jid}',headers=H).json()
            if j.get('status')!='processing': break
    out=[]; save_images(j,prefix,out)
    def strip(o):
        if isinstance(o,dict): return {k:('<b64>' if k=='base64' else strip(v)) for k,v in o.items()}
        if isinstance(o,list): return [strip(v) for v in o]
        return o
    b1=balance()
    rec={'t':time.strftime('%H:%M:%S'),'endpoint':endpoint,'prefix':prefix,'status':r.status_code,'bal_before':b0,'bal_after':b1,'files':out,'resp':strip(j)}
    open(LOG,'a').write(json.dumps(rec)[:3000]+'\n')
    print(json.dumps({k:rec[k] for k in ('endpoint','prefix','status','bal_before','bal_after','files')}), json.dumps(rec['resp'])[:600])
    return out
