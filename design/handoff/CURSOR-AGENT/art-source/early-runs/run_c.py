from pl import *
LP=open('../13_PIXELLAB_logo_wheel_dot/README.md').read().split('```')[1].strip()
call('/create-image-pixflux',{'description':LP,'image_size':{'width':32,'height':32},'no_background':True,'init_image':b64('logo/sketch_32.png'),'init_image_strength':200,
 'color_image':b64(palette_img()),'outline':'single color black outline','shading':'medium shading','detail':'low detail','view':'high top-down','seed':3},'raw/logoA_pixflux',20)
call('/create-image-bitforge',{'description':"big shaggy grey-blue wolf, dark blue-grey fur, light grey belly and muzzle, huge toothy grin, glowing yellow eyes, scarred ear, rusty orange iron collar with broken chain, four legs running, side view facing right, animal, dungeon monster sprite",
 'negative_description':'goblin, green skin, humanoid','text_guidance_scale':10,
 'image_size':{'width':32,'height':32},'no_background':True,'style_image':b64('../cleanup-all/mon_goblin_f0_native32.png'),'style_strength':15,
 'color_image':b64(palette_img()),'outline':'single color black outline','shading':'medium shading','detail':'medium detail','view':'side','direction':'east','seed':12},'raw/wolf2_bitforge',20)
call('/create-image-pixflux',{'description':"large black iron lantern with a ring handle on top, warm orange flame glowing inside glass panes, filling the frame, crisp pixel art game icon, single color black outline, light from upper left, flat colors, no text",
 'image_size':{'width':32,'height':32},'no_background':True,'color_image':b64(palette_img()),'outline':'single color black outline','shading':'medium shading','detail':'medium detail','view':'side','seed':31},'raw/lantern2',20)
