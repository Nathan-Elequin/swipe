from playwright.sync_api import sync_playwright
import pathlib
p=pathlib.Path('src/design/visual/title-teaser/storyboard.html').resolve()
with sync_playwright() as pw:
    b=pw.chromium.launch(); pg=b.new_page(viewport={'width':1180,'height':900},device_scale_factor=1)
    pg.goto(p.as_uri()); pg.wait_for_timeout(300)
    pg.screenshot(path='board/storyboard_full.png',full_page=True)
    beats=pg.query_selector_all('article.beat')
    names=['1_threshold','2_grab','3_spend','4_swirl','5_whiteout_still']
    for n,el in zip(names,beats): el.screenshot(path=f'board/beat_{n}.png')
    pg.query_selector('table').screenshot(path='board/table_what_pixel_draws.png')
    b.close()
