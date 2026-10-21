# Platforms (verified 20 Oct 2026, short version)

Rule: free tiers change often; the in-app counter is the truth. Everything below was checked on the vendor pages on 20 Oct 2026.

| Platform | Free allowance | Reference images | True pixel grid / sprite sheets / transparent | Commercial use on free | Sign-up |
|---|---|---|---|---|---|
| **Gemini app — Nano Banana 2** | Yes, compute-based meter; refreshes every 5 h up to a weekly cap. No published number (last published figure, May 2026: up to 20 images/day). Nano Banana Pro is paid-only. [limits](https://support.google.com/gemini/answer/16275805) · [image help](https://support.google.com/gemini/answer/14286560) | Yes, multiple | Pixel *style* only (needs downscale). Will lay out sheets in a grid. No real transparency → use flat magenta bg | Google doesn't claim ownership of outputs; normal Google ToS | Google account, 18+ for editing |
| **ChatGPT Images 2.0** | "Limited" on Free; separate image cap, reset time shown in-app (no published number). [pricing](https://chatgpt.com/pricing/) · [Images help](https://help.openai.com/en/articles/11084440) · [Free FAQ](https://help.openai.com/en/articles/9275245-chatgpt-free-tier-faq) | Yes (uploads, also capped) | Pixel style only; can make transparent backgrounds; good at grids | Outputs are yours under OpenAI terms | OpenAI account |
| **PixelLab** | Free trial: 40 fast gens, then 5 slower/day (bank up to 20), max 200×200, no card. Animation + maps listed from the $12 tier. [pricing](https://www.pixellab.ai/pricing) · [FAQ](https://www.pixellab.ai/docs/faq) | Yes (style/reference sprite) | **True pixels** at exact size, transparent bg | Yes on free ("user owns the generations"; no model training) | Email/Google, no card |
| **Retro Diffusion** | Starter balance "enough for dozens of RD Fast gens", no card. RD Fast ~$0.03, RD Plus ~$0.06, RD Pro $0.18 (up to 9 refs), animations $0.07+. [site](https://retrodiffusion.ai/) · [API price list](https://github.com/Retro-Diffusion/api-examples/blob/main/README.md) · [Replicate](https://replicate.com/retro-diffusion/rd-plus) (paid after a few free runs) | Yes (Pro: 9) + **palette input** | **True pixels** 12–384 px, bg removal, tiling, item sheets | Yes ("everything you generate is yours") | Account, no card |
| Bing Image Creator (spare) | 15 fast boosts/day then slow. [page](https://www.microsoft.com/en-us/bing/features/bing-image-creator) | No | Pixel style only | Terms say "for entertainment purposes"; Microsoft gets a broad licence. [ToS](https://edgeservices.bing.com/new/termsofuseimagecreator?FORM=GENTOS) — avoid for finals | Microsoft account |

Checked and **not** recommended for finals: Leonardo (150 tokens/day, but free outputs are public and Leonardo holds rights — [pricing](https://www.leonardo.ai/pricing)); Ideogram (30 credits/week only via Google/Apple/MS login, all public — [plans](https://docs.ideogram.ai/plans-and-billing/available-plans)); Recraft (30 credits/day, free outputs owned by Recraft, no commercial use — [pricing](https://www.recraft.ai/pricing)); Krea (100 units/day; commercial licence only on paid — [pricing](https://www.krea.ai/pricing)); Adobe Firefly (25 credits/month — too few); Hugging Face pixel-LoRA Spaces (the pixel-sprite FLUX Spaces found were paused/sleeping; unreliable).

## Picks
| Asset | Primary | Backup |
|---|---|---|
| Title still v3 (420×260) | Gemini (multi-ref composition, roomy free meter) | ChatGPT Images |
| Sprout / Nib animation sheets | Gemini (one sheet per animation keeps frames consistent) | PixelLab (true-pixel single poses from the ref; animation tool is paid tier) |
| Item floaters (24×24) | PixelLab (true pixels, exact size, transparent) | Retro Diffusion RD Plus with palette strip |
| Monster run sheets | Gemini | ChatGPT Images |
| Logo | **No AI lettering.** Pixel keeps the hand-set "Spinheritance" letters from logo C, makes the p plain, and drops in an AI-made i-dot. Dot: PixelLab (16×16 true pixels) | Gemini large concept of the dot; Pixel re-pixels it |

## What Pixel does on return (free tools)
1. Grid detect + downscale to native (420×260, 48, 32, 24…): [Unfaker / unfake.js](https://github.com/jenissimo/unfake.js/) (browser) or [proper-pixel-art](https://github.com/KennethJAllen/proper-pixel-art/) (Python) + nearest-neighbour.
2. Palette snap to `refs\spinheritance.gpl` / `.hex` (64 colours from the repo PNGs).
3. Kill anti-aliasing and stray half-tones; key out the #FF00FF background to alpha 0/255.
4. Re-draw the 1px `#100e0c` outline; light from upper-left; 3–4 tone ramps.
5. Slice sheets to `_f0.._fN`, align feet to the bottom-centre pivot, 4× nearest export.
Editors: [LibreSprite](https://libresprite.github.io/) or [Pixelorama](https://github.com/Orama-Interactive/Pixelorama) (both free; Aseprite is paid).
