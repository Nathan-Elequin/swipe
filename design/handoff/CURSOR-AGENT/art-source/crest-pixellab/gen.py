import sys; from PIL import Image; from plg import gen, state
I='<ANIM_PITCH>/mockups/layouts/crest/init/'
s=state(); print('start balance',s['start'])
J={'tag_round':'pixel art game UI name tag plate, dark walnut center, bright gold bevelled rim, a round semicircular notch cut into the middle of the bottom border with a gold lip, crypt dungeon style',
   'tag_shield':'pixel art game UI name tag plate, dark walnut center, bright gold bevelled rim, a square socket notch cut into the middle of the bottom border with a gold lip, crypt dungeon style',
   'medallion':'pixel art game UI round medallion crest, gold coin with thick bevelled rim and dark recessed empty center, crypt dungeon style',
   'shield':'pixel art game UI small heraldic shield crest, bevelled gold border, crimson empty field, crypt dungeon style'}
for k in (sys.argv[1:] or J): gen(J[k],Image.open(I+k+'.png'),k)
