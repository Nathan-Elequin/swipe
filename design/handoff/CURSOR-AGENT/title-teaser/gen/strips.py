"""Title-teaser world strips. Run: python3 strips.py  -> <TITLE_TEASER>/out/
hill_strip / hall_strip / hall_strip_b: 420x260 native, opaque RGB, floor y=161, seamless X,
shipped 1680x1040 (4x nearest) + Godot .import (lossless, no mipmaps). QA: python3 qa.py"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ship, IMPORT
import hill, hall
OUT = '<TITLE_TEASER>/out/'
os.makedirs(OUT, exist_ok=True)
for name, img in [('hill_strip', hill.build()), ('hall_strip', hall.build('a')), ('hall_strip_b', hall.build('b'))]:
    ship(img, OUT + name + '_native.png', OUT + name + '.png')
    open(OUT + name + '.png.import', 'w').write(IMPORT.format(name=name + '.png'))
    print(name, img.size)
