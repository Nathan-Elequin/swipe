import plg; plg.CAP=15
from PIL import Image; import gen_b3, icons10
cell=Image.new('RGBA',(32,32),(0,0,0,0)); cell.alpha_composite(gen_b3.med18(),(7,7)); ic=icons10.get('horn'); cell.alpha_composite(ic,(16-(ic.width+1)//2,16-(ic.height+1)//2))
cell.save('init/b3_med_horn2.png')
plg.gen('pixel art game UI small round gold medallion crest with bevelled rim, dark center holding one tiny brass war horn with a flared bell pointing right',cell,'b3_med_horn2',strength=500)
