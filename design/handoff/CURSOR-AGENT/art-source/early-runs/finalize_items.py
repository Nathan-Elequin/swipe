from clean import *
import os
ids=['pocketwatch','lantern','grimoire','healing_potion','lucky_nickel','sledgehammer','da_boot','helmet']
pick={i:f'raw/pf180_{i}_0.png' for i in ids}
pick['pocketwatch']='raw/pixflux_pocketwatch_0.png'
if os.path.exists('raw/lantern2_0.png'): pick['lantern']='raw/lantern2_0.png'
os.makedirs('items',exist_ok=True)
BG=(26,22,18,255)
pairs=[]
for i in ids:
    im=clean(Image.open(pick[i])); im.save(f'items/item_{i}.png'); x(im,4).save(f'items/item_{i}_x4.png')
    pairs.append((Image.open(f'refs/{i}_24.png'),im))
# contact old vs new at 4x
cell=24*4; pad=8
W=pad+len(ids)*(cell+pad); Hh=pad+2*(cell+pad)
c=Image.new('RGBA',(W,Hh),BG)
for k,(o,n) in enumerate(pairs):
    X=pad+k*(cell+pad)
    for r,im in enumerate((o,n)):
        s=x(im,4); c.paste(s,(X,pad+r*(cell+pad)),s)
c.save('items/contact_old_vs_new_x4.png')
c=Image.new('RGBA',(pad+8*(cell+pad),cell+2*pad),BG)
for k,(o,n) in enumerate(pairs):
    s=x(n,4); c.paste(s,(pad+k*(cell+pad),pad),s)
c.save('items/all_items_new_x4.png')
for i in ids: print(i,pick[i],len(Image.open(f'items/item_{i}.png').getcolors()))
