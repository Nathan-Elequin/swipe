import sys; sys.path.insert(0,'.'); from gen import *
floor=int(open('floor.txt').read())
R2={'banner':('banner',False,220,'pixel art game UI nameplate banner, dark carved walnut wood plaque with subtle wood grain, bright gold bevelled trim, crimson cloth ribbon tails with folds on both ends, flat empty center for text, crypt dungeon style'),
    'plate9':('plate9',False,220,'pixel art game UI nine-slice panel, dark carved walnut wood plaque filled solid brown, subtle wood grain, bright gold bevelled border with corner rivets, flat empty center, crypt dungeon style'),
    'sheet_badges':('sheet_badges',True,220,'pixel art game UI sprite sheet, 2x2 grid of separate 16x16 badges: dark round chip with gold rim; gold coin with dark recessed center; bright orange eight-point burst star with yellow highlight; glossy red heart with white highlight top left; centers plain for numbers'),
    'sheet_icons':('sheet_icons',True,220,'pixel art game UI sprite sheet, 2x2 grid of separate 16x16 icons: curved brass war horn with dark bell; gold balance scales; yellow lightning bolt; white vampire fang dripping red blood')}
for k,(src,nobg,st,desc) in R2.items():
    f,_=JOBS[src]; im=f()
    pl.call('/create-image-pixflux',{'description':desc+', lit from the upper left, crisp pixels, no anti-aliasing','image_size':{'width':im.width,'height':im.height},
      'no_background':nobg,'init_image':pl.b64(im),'init_image_strength':st,'text_guidance_scale':9,'color_image':pl.b64(pl.palette_img()),
      'outline':'single color black outline','shading':'medium shading','detail':'highly detailed','view':'side','seed':11},f'raw/{k}_r2',floor)
