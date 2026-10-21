import sys,math,numpy as np; sys.path.insert(0,'.')
from clean4 import *
from PIL import Image
def segs(im,n):
    a=np.array(im)[...,3]>0; cols=a.any(0); s=[];x=0;W=len(cols)
    while x<W:
        if cols[x]:
            x0=x
            while x<W and cols[x]: x+=1
            s.append((x0,x))
        x+=1
    s=sorted(sorted(s,key=lambda t:-(t[1]-t[0]))[:n]); return [im.crop((a,0,b,im.size[1])) for a,b in s]
def shrink(im,T,TH=None,pad=0):
    TH=TH or T; im=im.crop(im.getbbox()); w,h=im.size
    f=max(1,math.ceil(max(w/(T-pad),h/(TH-pad))))
    if f>1:
        W2,H2=math.ceil(w/f)*f,math.ceil(h/f)*f; c=Image.new('RGBA',(W2,H2)); c.paste(im,((W2-w)//2,(H2-h)//2)); im=down(c,f)
    return fit(clean(im),T,TH,False)
def proc_all():
    L=lambda n:Image.open(f'raw/{n}_0.png').convert('RGBA'); out={}
    out['intent_claw_idle']=shrink(L('claw_idle_r2'),16); out['intent_claw_flame_idle']=shrink(L('claw_flame'),16)
    for nm,im in zip(['shield','drop','flee','plus'],segs(L('chips'),4)): out['intent_chip_'+nm]=shrink(im,8)
    for nm,im in zip(['sword','wisp','drop','lock','shield'],segs(L('glyphs'),5)): out['aura_glyph_'+nm]=shrink(im,8)
    out['ticker_token_frame']=shrink(L('token'),12); out['ticker_ff']=shrink(L('ff'),12,8); out['heart12']=shrink(L('heart'),12)
    out['sparkle8']=shrink(L('sparkle'),8)
    r=clean(down(L('rope'),4)); out['rope_tile']=r.crop((0,4,4,12))
    for a,b in [('sai_single','sai_single'),('sai_pair_r2','sai_pair'),('marble_base','marble_base'),('cat_base','cat_base'),('hook_base','hook_base'),('hook_taut','hook_taut'),('pbubble_r2','pbubble')]:
        out[b]=shrink(L(a),24)
    for nm,im in zip(['marble_red','marble_blue'],segs(L('marbles_rb'),2)): out[nm]=shrink(im,24)
    out['stone30']=shrink(L('stone'),30)
    rec(out['aura_glyph_sword'],['f4f7fb','dce0e4','e26246','be3a34','8b1e1e','5e1c18'])
    for d in ('aura_glyph_drop','intent_chip_drop'): rec(out[d],['aaa2c6','7a6aa8','4a3a78','2e2450'])
    return out
def rec(im,ramp):
    a=np.array(im); R=[tuple(int(h[i:i+2],16) for i in (0,2,4)) for h in ramp]; lum=lambda c:0.3*c[0]+0.59*c[1]+0.11*c[2]
    for y,x in zip(*np.where(a[...,3]>0)):
        c=a[y,x,:3].astype(int)
        if max(c)-min(c)<25: continue
        a[y,x,:3]=min(R,key=lambda r:abs(lum(r)-lum(c)))
    im.paste(Image.fromarray(a))
if __name__=='__main__':
    import os; os.makedirs('work/ui',exist_ok=True)
    o=proc_all()
    for k,v in o.items(): v.save(f'work/ui/{k}.png')
    print(len(o))
