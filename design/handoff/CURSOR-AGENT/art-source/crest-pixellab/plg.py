# Guarded wrapper: my own gens counted from usage (cap 30); hard backstop on shared balance.
import sys,json,os; sys.path.insert(0,'<ART_KIT>/pixellab'); import pl
D='<ANIM_PITCH>/mockups/layouts/crest/'; pl.LOG=D+'calls.log'; CAP=30
def state():
    if os.path.exists(D+'start.json'): return json.load(open(D+'start.json'))
    s={'start':pl.balance(),'used':0}; json.dump(s,open(D+'start.json','w')); return s
def gen(desc,im,prefix,nobg=True,strength=350,seed=7,shading='basic shading',detail='medium detail'):
    s=state()
    if s['used']+1>CAP: sys.exit(f"STOP: own cap {CAP} reached ({s['used']})")
    floor=s['start']-CAP-120   # backstop only; the other batch drains the shared pool
    out=pl.call('/create-image-pixflux',{'description':desc+', lit from the upper left, crisp pixels, no anti-aliasing',
      'image_size':{'width':im.width,'height':im.height},'no_background':nobg,'init_image':pl.b64(im),'init_image_strength':strength,
      'text_guidance_scale':8,'color_image':pl.b64(pl.palette_img()),'outline':'single color black outline','shading':shading,
      'detail':detail,'view':'side','seed':seed},D+'raw/'+prefix,floor)
    rec=json.loads(open(pl.LOG).read().strip().splitlines()[-1])
    u=(rec.get('resp') or {}).get('usage',{}).get('generations',0) if rec.get('status')==200 else 0
    s['used']+=u; json.dump(s,open(D+'start.json','w')); print('own used',s['used'])
    return out
