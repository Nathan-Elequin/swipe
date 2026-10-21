import sys,json; sys.path.insert(0,'<ART_KIT>/pixellab'); import pl
from PIL import Image, ImageDraw
pl.LOG='<ANIM_PITCH>/mockups/layouts/pl/calls.log'
O=(16,14,12); G=(255,216,74); GD=(216,168,64); BR=(59,38,24); BR2=(90,58,34); RD=(154,52,40); RD2=(94,28,24)
def new(w,h): return Image.new('RGBA',(w,h),(0,0,0,0))
def banner():
    im=new(64,16); d=ImageDraw.Draw(im)
    d.polygon([(0,3),(9,3),(9,13),(0,13),(4,8)],fill=RD2,outline=O); d.polygon([(63,3),(54,3),(54,13),(63,13),(59,8)],fill=RD2,outline=O)
    d.rectangle((6,1,57,14),fill=BR,outline=O); d.line((7,2,56,2),fill=G); d.line((7,13,56,13),fill=GD); d.line((7,3,7,12),fill=G); d.line((56,3,56,12),fill=GD)
    return im
def plate():
    im=new(24,24); d=ImageDraw.Draw(im); d.rounded_rectangle((0,0,23,23),radius=4,fill=BR,outline=O)
    d.rounded_rectangle((1,1,22,22),radius=3,outline=G); d.line((2,22,21,22),fill=GD); d.line((22,2,22,21),fill=GD); return im
def chip():
    im=new(16,16); d=ImageDraw.Draw(im); d.ellipse((0,0,15,15),fill=BR,outline=O); d.ellipse((1,1,14,14),outline=G); return im
def disc():
    im=new(16,16); d=ImageDraw.Draw(im); d.ellipse((0,0,15,15),fill=(168,120,40),outline=O); d.ellipse((2,2,13,13),fill=BR2,outline=G); return im
def atk():
    import math; im=new(16,16); d=ImageDraw.Draw(im); pts=[]
    for k in range(16):
        a=-math.pi/2+k*math.pi/8; r=7.5 if k%2==0 else 5.5; pts.append((7.5+math.cos(a)*r,7.5+math.sin(a)*r))
    d.polygon(pts,fill=(196,90,20),outline=O); return im
def hp():
    im=new(16,16); d=ImageDraw.Draw(im); d.ellipse((1,2,8,9),fill=(196,40,42)); d.ellipse((7,2,14,9),fill=(196,40,42)); d.polygon([(1,6),(14,6),(7.5,14)],fill=(196,40,42))
    return im
def icon(kind):
    im=new(16,16); d=ImageDraw.Draw(im)
    if kind=='horn': d.polygon([(2,10),(10,4),(14,3),(13,8),(5,13)],fill=(216,168,64),outline=O)
    if kind=='scales': d.line((8,2,8,13),fill=GD,width=2); d.line((2,5,14,5),fill=GD); d.polygon([(1,9),(5,9),(3,6)],fill=G,outline=O); d.polygon([(11,9),(15,9),(13,6)],fill=G,outline=O); d.rectangle((5,13,11,14),fill=GD)
    if kind=='bolt': d.polygon([(9,1),(3,9),(7,9),(5,15),(13,6),(9,6),(11,1)],fill=(248,230,160),outline=O)
    if kind=='fang': d.polygon([(3,2),(13,2),(11,8),(8,14),(5,8)],fill=(240,230,216),outline=O); d.ellipse((6,9,10,14),fill=(154,52,40))
    return im
JOBS={
 'banner':(banner,'horizontal pixel art nameplate banner, dark wooden plaque with thin gold trim and red cloth ribbon tails on both ends, plain empty center for text, game UI'),
 'plate9':(plate,'pixel art UI panel tile, dark brown plaque with thin gold bevel border, plain empty center, game UI nine-slice frame'),
 'chip':(chip,'small round pixel art UI chip, dark brown disc with gold rim, empty center'),
 'disc':(disc,'small round pixel art gold coin badge with dark empty center for a number, game UI'),
 'atk':(atk,'pixel art orange eight-point burst star badge, empty center for a number, attack stat icon, game UI'),
 'hp':(hp,'pixel art red heart badge, glossy highlight top left, empty center for a number, health stat icon, game UI'),
 'ic_horn':(lambda:icon('horn'),'pixel art war horn icon, brass horn, tiny game UI icon'),
 'ic_scales':(lambda:icon('scales'),'pixel art gold merchant balance scales icon, tiny game UI icon'),
 'ic_bolt':(lambda:icon('bolt'),'pixel art yellow lightning bolt icon, tiny game UI icon'),
 'ic_fang':(lambda:icon('fang'),'pixel art vampire fang with blood drop icon, tiny game UI icon'),
}

def sheet(fs):
    im=new(32,32)
    for k,f in enumerate(fs): im.alpha_composite(f(),((k%2)*16,(k//2)*16))
    return im
def plate32():
    im=new(32,32); d=ImageDraw.Draw(im); d.rounded_rectangle((0,0,31,31),radius=5,fill=BR,outline=O)
    d.rounded_rectangle((1,1,30,30),radius=4,outline=G); d.line((2,30,29,30),fill=GD); d.line((30,2,30,29),fill=GD); return im
JOBS.update({
 'plate9':(plate32,'pixel art UI panel tile, dark brown wooden plaque with thin gold bevel border, plain flat empty center, game UI nine-slice frame'),
 'sheet_badges':(lambda:sheet([chip,disc,atk,hp]),'pixel art game UI sprite sheet of four separate 16x16 badges in a 2x2 grid: dark round chip with gold rim, gold coin with dark empty center, orange spiky star badge, red heart badge; centers empty for numbers'),
 'sheet_icons':(lambda:sheet([lambda:icon('horn'),lambda:icon('scales'),lambda:icon('bolt'),lambda:icon('fang')]),'pixel art game UI sprite sheet of four separate 16x16 icons in a 2x2 grid: brass war horn, gold balance scales, yellow lightning bolt, white vampire fang with red blood drop'),
})

if __name__=='__main__':
    names=sys.argv[1:] or list(JOBS); floor=int(open('floor.txt').read())
    for n in names:
        f,desc=JOBS[n]; im=f(); im.save(f'init/{n}.png')
        pl.call('/create-image-pixflux',{'description':desc+', lit from the upper left, crisp pixels, no anti-aliasing','image_size':{'width':im.width,'height':im.height},
          'no_background':True,'init_image':pl.b64(im),'init_image_strength':350,'text_guidance_scale':8,'color_image':pl.b64(pl.palette_img()),
          'outline':'single color black outline','shading':'basic shading','detail':'medium detail','view':'side','seed':7},f'raw/{n}',floor)
