import sys
from PIL import Image, ImageDraw, ImageFont
OUT = '<TITLE_TEASER>/out/'
still = Image.open(OUT + 'title_still_native.png').convert('RGBA')
LOGO = (85, 20, 250, 40); TAG = (65, 62, 290, 21)
bf = ImageFont.load_default_imagefont()
def comp(logo, tagline=True):
    im = still.copy()
    x = LOGO[0] + (LOGO[2] - logo.width) // 2; y = LOGO[1] + (LOGO[3] - logo.height) // 2
    im.alpha_composite(logo, (x, y))
    if tagline:
        d = ImageDraw.Draw(im); t = 'Use it, Lose it, or Lose your head'
        w = d.textlength(t, font=bf); tx = TAG[0] + (TAG[2] - w) // 2; ty = TAG[1] + 5
        d.text((tx + 1, ty + 1), t, font=bf, fill=(16, 14, 12)); d.text((tx, ty), t, font=bf, fill=(255, 243, 214))
    return im, (x, y)
def banner(im4, text):
    b = Image.new('RGBA', (im4.width, 44), (60, 16, 16, 255)); d = ImageDraw.Draw(b)
    d.text((12, 8), text, font=bf, fill=(255, 216, 74)); 
    b2 = b.resize((b.width, b.height), Image.NEAREST)
    out = Image.new('RGBA', (im4.width, im4.height + 44)); out.paste(im4, (0, 0)); out.paste(b2, (0, im4.height)); return out
if __name__ == '__main__':
    pick = sys.argv[1] if len(sys.argv) > 1 else 'C'
    sheet = Image.new('RGBA', (1680 + 20 + 420 * 2, 3 * (520 + 30) + 10), (40, 40, 40, 255))
    d = ImageDraw.Draw(sheet)
    for i, v in enumerate('ABC'):
        lg = Image.open(OUT + f'_logo_{v}_native.png')
        im, _ = comp(lg, tagline=False)
        sheet.paste(im.resize((840, 520), Image.NEAREST), (10, 10 + i * 550))
        th = im.convert('RGB').resize((210, 130), Image.BOX).resize((420, 260), Image.NEAREST)
        sheet.paste(th, (870, 10 + i * 550))
        # logo alone at 4x on night sky
        bg = Image.new('RGBA', (lg.width * 4 + 16, lg.height * 4 + 16), (18, 22, 32, 255)); bg.alpha_composite(lg.resize((lg.width * 4, lg.height * 4), Image.NEAREST), (8, 8))
        sheet.paste(bg.crop((0, 0, min(bg.width, 1250), bg.height)), (1300, 10 + i * 550))
        d.text((870, 280 + i * 550), f'variant {v}  {lg.width}x{lg.height} native' + ('   <- PICKED' if v == pick else ''), font=bf, fill=(255, 216, 74))
        d.text((870, 296 + i * 550), 'left: on still 2x | middle: 210x130 thumb (2x view) | right: logo 4x', font=bf, fill=(200, 200, 200))
    sheet.save(OUT + '_review_logo_variants.png')
    lg = Image.open(OUT + f'_logo_{pick}_native.png')
    im, pos = comp(lg, tagline=True)
    big = banner(im.resize((1680, 1040), Image.NEAREST), 'PREVIEW ONLY - logo.png composited in SCREEN logo rect; tagline is placeholder text (code draws it at runtime). Nothing baked into title_still.png.')
    big.convert('RGB').save(OUT + '_review_still_with_logo.png')
    im.convert('RGB').resize((210, 130), Image.BOX).save(OUT + '_review_still_with_logo_thumb_210x130.png')
    print('logo at native', pos, lg.size)
