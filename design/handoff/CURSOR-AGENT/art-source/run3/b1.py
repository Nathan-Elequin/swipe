from lib3 import *
R2='<ART_KIT>/pixellab/run2/final/'; CA='<ART_KIT>/cleanup-all/'
OG=R2+'mon_ogre_f0.png'
WOLF="lean menacing dire wolf in mid gallop, long legs outstretched, dark charcoal grey fur, pale grey belly, spiky raised hackles, bared white fangs, glowing yellow eye, bushy tail, side view facing right, dungeon monster game sprite, single color black outline, light from upper left"
HOR="exactly three separate big hornets flying to the right in a loose triangle, each hornet with bold yellow and black striped abdomen, pointed stinger, translucent pale wings, black head, side view, dungeon monster game sprite, black outline, light from upper left"
jobs=[J(pixflux,WOLF,32,'wolf_px_a',3),J(pixflux,WOLF,32,'wolf_px_b',17),J(bitforge,WOLF,32,'wolf_bf_a',5,OG,35),J(bitforge,WOLF,32,'wolf_bf_b',23,OG,35),
 J(pixflux,HOR,32,'hor_px_a',4),J(pixflux,HOR,32,'hor_px_b',19),J(bitforge,HOR,32,'hor_bf_a',8,OG,30),J(bitforge,HOR,32,'hor_bf_b',31,OG,30)]
M={'goblin':(32,"sneaky green goblin running, pointy ears, ragged brown loincloth, big grin, side view facing right"),
 'skeleton':(32,"skeleton warrior running, bone white, holding a small dagger forward, side view facing right"),
 'spider_queen':(48,"giant dark purple spider queen with red markings, small gold crown, many legs, side view facing right"),
 'dragon':(64,"red dragon with cream wings and belly, horns, long tail, walking, side view facing right")}
for k,(s,d) in M.items():
    d+=", dungeon monster game sprite, single color black outline, light from upper left"
    ini=CA+f'mon_{k}_f0_native{s}.png'
    jobs+=[J(pixflux,d,s,f'{k}_px',7,init=ini,init_s=250),J(bitforge,d,s,f'{k}_bf',9,OG,40,init=ini,init_s=200)]
I=", game item sprite, transparent background, single color black outline, light from upper left, warm parchment and gold"
jobs+=[J(pixflux,"rolled up parchment scroll tied with a red wax seal ribbon, lying horizontal"+I,48,'scroll_a',5),
 J(pixflux,"old brass hanging lantern with a glowing warm candle flame inside"+I,32,'lantern_a',5),
 J(pixflux,"old brass hanging lantern with a glowing warm candle flame inside"+I,32,'lantern_b',21),
 J(pixflux,"single shiny gold coin with a crown emblem, front view"+I,32,'coin_a',5),
 J(pixflux,"small pile of gold coins with a red ruby gem, loot treasure"+I,32,'coin_b',13),
 J(pixflux,"half open parchment scroll unrolled, a will document with lines of text and a red wax seal"+I,48,'scroll_b',9)]
par(jobs,3)
