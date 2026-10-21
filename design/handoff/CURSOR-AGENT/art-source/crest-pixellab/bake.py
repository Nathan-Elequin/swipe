# Bake each ability icon into each crest at native scale (init sheet), PixelLab redraws the 2x2 sheet.
import sys; from PIL import Image
P='<ANIM_PITCH>/mockups/layouts/pl/clean/'
ICONS=['ic_horn','ic_scales','ic_bolt','ic_fang']
def fit(im,m):
    s=min(m/im.width,m/im.height,1); return im.resize((max(1,round(im.width*s)),max(1,round(im.height*s))),Image.NEAREST)
def sheet(kind):
    fr=Image.open(f'clean/{kind}_frame.png'); sh=Image.new('RGBA',(64,64),(0,0,0,0))
    for i,ic in enumerate(ICONS):
        cell=Image.new('RGBA',(32,32),(0,0,0,0)); ox,oy=(32-fr.width)//2,(32-fr.height)//2; cell.alpha_composite(fr,(ox,oy))
        icon=fit(Image.open(P+ic+'.png').convert('RGBA'),11 if kind=='medallion' else 10)
        cx,cy=(ox+fr.width//2, oy+fr.height//2) if kind=='medallion' else (ox+fr.width//2, oy+10)
        cell.alpha_composite(icon,(cx-icon.width//2,cy-icon.height//2)); sh.alpha_composite(cell,((i%2)*32,(i//2)*32))
    sh.save(f'init/bake_{kind}.png'); return sh
if __name__=='__main__':
    from plg import gen
    D={'medallion':'pixel art game UI sprite sheet, 2x2 grid of four separate round gold medallion crests with bevelled rims, dark centers each holding one small icon: brass war horn, gold balance scales, yellow lightning bolt, white fang with red blood',
       'shield':'pixel art game UI sprite sheet, 2x2 grid of four separate small heraldic shield crests, bevelled gold borders, crimson fields each holding one small icon: brass war horn, gold balance scales, yellow lightning bolt, white fang with red blood'}
    for k in (sys.argv[1:] or D):
        gen(D[k],sheet(k),'bake_'+k,strength=450)
