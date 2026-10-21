from lib4 import *
import functools; print=functools.partial(print,flush=True)
O=", game UI icon, bold simple shapes, 1px dark outline, no background"
I=", game item sprite, 1px dark outline, light from upper left, no background"
jobs=[J(pix,"dark red rounded shield-shaped badge, three bone-white diagonal claw rake marks across the top, plain dark empty centre"+O,32,32,'claw_idle',3),
 J(pix,"dark red rounded shield-shaped badge with a rim of orange fire flames, three bone-white claw rake marks on top, plain dark empty centre"+O,32,32,'claw_flame',5),
 J(pix,"row of four separate tiny icons evenly spaced left to right: steel shield, purple poison droplet, pair of footprints, gold plus sign"+O,128,32,'chips',7),
 J(pix,"row of five separate tiny icons evenly spaced left to right: red sword, green ghost wisp flame, purple droplet, grey padlock, steel shield"+O,160,32,'glyphs',7),
 J(pix,"round brass stamp ring, thick circle, empty transparent hole in the middle"+O,48,48,'token',3),
 J(pix,"gold fast-forward symbol, two right-pointing chevron triangles side by side"+O,48,32,'ff',3),
 J(pix,"small bright red heart"+O,48,48,'heart',3),
 J(pix,"gold four-point star sparkle, thin pointed rays"+O,32,32,'sparkle',3),
 J(pix,"vertical braided brown hemp rope segment, twisted strands, fills the full height"+O,16,64,'rope',3),
 J(pix,"single steel sai dagger, diagonal, grey blade with side prongs, wrapped brown handle"+I,48,48,'sai_single',5,init='base/init_sai48.png',init_s=220),
 J(pix,"two steel sai daggers crossed in an X, grey blades with side prongs, wrapped brown handles"+I,48,48,'sai_pair',5,init='base/init_saipair48.png',init_s=180),
 J(pix,"two glass marbles side by side: left one solid deep red, right one solid deep blue, each with a white highlight glint top left"+I,96,48,'marbles_rb',5,init='base/init_marbles96.png',init_s=180),
 J(pix,"round glass marble with a red and blue two-tone swirl inside, white highlight glint"+I,48,48,'marble_base',5,init='base/init_marble48.png',init_s=180),
 J(pix,"purple cat's-eye glass marble with a gold slit pupil band and tiny star sparkles inside"+I,48,48,'cat_base',5,init='base/init_cat48.png',init_s=200),
 J(pix,"iron grappling hook with three curved prongs on a short brown rope"+I,48,48,'hook_base',5,init='base/init_hook48.png',init_s=220),
 J(pix,"iron grappling hook caught and bitten in, three prongs dug deep, rope pulled taut to the left"+I,48,48,'hook_taut',9,init='base/init_hook48.png',init_s=120),
 J(pix,"round purple and green poison bubble, glossy, about to burst"+I,48,48,'pbubble',5),
 J(pix,"card-shaped grey stone shell slab, rough rock texture, rectangular, subtle cracks"+I,60,60,'stone',5)]
par(jobs,3)
