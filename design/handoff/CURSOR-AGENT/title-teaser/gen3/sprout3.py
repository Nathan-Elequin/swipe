"""Sprout, teaser-readable: the in-game run_grab_f0 goblin redrawn at 2x detail (48px)."""
from hifi import *
SK = dict(hi='#d4e994', l='#c4e07a', m='#8cbc48', d='#5a8a30', dd='#486e27')
HD = dict(hi='#a3c6b6', l='#86b4a4', m='#4f8a7c', d='#33605a', dd='#1f3d3a')
def sprout():
    a = hifi2('dungeon/hero_run/run_grab_f0.png')
    p = P(a)
    # --- eye: gold iris, pupil hard right (on the loot), cream glint, angled brow
    p.pts([(34, 19), (35, 19)], SK['dd']); p.row(36, 38, 19, '#100e0c')
    p.px(35, 20, '#fff3d6'); p.px(36, 20, '#f0c040'); p.px(37, 20, '#100e0c')
    p.px(35, 21, '#e8c36a'); p.px(36, 21, '#f0c040'); p.px(37, 21, '#100e0c')
    p.px(35, 22, SK['d']); p.px(36, 22, SK['m']); p.px(37, 22, SK['m'])
    p.px(34, 20, SK['d']); p.px(34, 21, SK['m'])
    # cheek wrinkle + nostril + nose ridge light
    p.px(39, 21, SK['d']); p.px(40, 22, SK['d'])
    p.px(46, 21, SK['dd']); p.row(42, 45, 20, SK['hi'])
    # grin: fang poking out at the mouth corner
    p.px(39, 24, '#fff3d6'); p.px(38, 24, '#100e0c')
    # ear tip notch / inner ear (back ear)
    p.pts([(9, 12), (10, 13), (11, 14), (12, 15), (13, 16)], SK['m']); p.pts([(11, 13), (12, 14), (13, 15)], '#b2763c')
    p.pts([(14, 17), (15, 17)], SK['d'])
    # hood folds + rim seam
    p.pts([(26, 12), (25, 13), (25, 14), (24, 15)], HD['l'])
    p.pts([(31, 13), (32, 14), (32, 15), (33, 16)], HD['d']); p.pts([(29, 22), (29, 23), (28, 24), (28, 25)], HD['d'])
    p.pts([(23, 20), (23, 21), (22, 22)], HD['d'])
    # sack: rope neck, patch with stitches, a gold coin peeking out of the top
    p.pts([(12, 19), (13, 19)], '#fff3d6'); p.px(14, 19, '#ffd84a'); p.px(14, 20, '#ffd84a'); p.px(13, 20, '#f09a34')
    p.row(11, 18, 22, '#74603e'); p.pts([(12, 23), (14, 23), (16, 23)], '#3e3321')
    p.pts([(9, 24), (9, 25), (10, 26), (11, 27), (12, 27), (13, 28)], '#74603e')   # sack seam
    p.pts([(9, 23), (10, 23), (8, 24)], '#d4ba8f')
    # scarf: knot + tail streaming back over the sack (he is lunging)
    p.pts([(20, 27), (21, 27)], '#de866d'); p.px(20, 28, '#d0644a')
    # belt buckle (Grandpa's? no: plain brass)
    p.rect(30, 33, 31, 34, '#e8c36a'); p.px(30, 33, '#fff3d6'); p.px(31, 34, '#b8731e')
    # hand: open claw, fingertips lit
    p.pts([(43, 24), (44, 24)], '#fff3d6')
    a = rim_light(p.a, (240, 154, 52), 'right', 0.35, 0.4)
    return crop(a)
if __name__ == '__main__':
    from gridview import gridview
    a = sprout(); save(a, '<TITLE_TEASER>/ref3/sprout3_8x.png', 8); gridview(a, '<TITLE_TEASER>/ref3/g_sprout3.png', 14); print(a.shape)
