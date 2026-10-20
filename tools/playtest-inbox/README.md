# Playtest inbox setup (click this, then that)

Friends hit **Send** in the playtest build. A tiny Cloudflare page then opens a GitHub Issue on `Nathan-Elequin/swipe` so Cursor can read it.

You do this **once**. Two websites (GitHub, Cloudflare) plus a terminal in this folder. Nothing gets installed into the game except a URL at the end.

A **PAT** is just a password GitHub prints once, so that Cloudflare page can open Issues as you. It is not a repo setting. You will copy it, paste it into Cloudflare, and never put it in the game.

---

## 1. GitHub: make the password (PAT)

1. Open this page while logged into GitHub: [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new)
2. If GitHub asks you to pick a token type, choose **Generate new token (classic)**.
3. **Note:** `swipe playtest inbox`
4. **Expiration:** `90 days` (fine). `No expiration` is also fine if you do not want to redo this.
5. Scroll to **repo**. Check **only** `public_repo`. Leave everything else unchecked.
6. Scroll to the bottom. Click **Generate token**.
7. GitHub shows a string that starts with `ghp_`. **Copy it now.** You will not see it again.
8. Paste it into a notepad for two minutes. You will use it in step 3.

If the page says you need to confirm your password, do that, then Generate token again.

---

## 2. Cloudflare: make a free account

1. Open [https://dash.cloudflare.com/sign-up](https://dash.cloudflare.com/sign-up)
2. Sign up with the email you actually check. Free plan. You do not need a domain.
3. If it asks you to add a website, skip / choose **I'm not adding a site** / go to the dashboard anyway.

---

## 3. Double-click the setup file (no typing a path)

You do not need to "open a terminal at a folder."

1. Press **Win + E** (File Explorer).
2. Click the address bar at the top (the long bar that shows a path).
3. Paste this and press Enter:

`C:\Users\Natha\Documents\boss-rush\tools\playtest-inbox`

4. Double-click **`setup.cmd`**. If Windows says the file is unsafe, click **More info → Run anyway**.
5. A black window opens. Read it. Press a key when it says to.
6. When it asks for the GitHub password, paste the `ghp_…` string and press Enter. The letters will not show. That is normal.
7. When it asks for the shared token, paste `swipe-playtest-friends` and press Enter.
8. At the end, copy the `https://….workers.dev` line. Paste that URL in the Cursor chat.

If double-click does nothing useful, in that same Explorer window click the address bar, type `powershell`, press Enter, then paste:

`.\setup.cmd`

---

## 4. Put the URL in the game

Open `data/playtest-inbox.json`. Set `"url"` to the workers.dev address from step 3D. Leave `"token"` as `swipe-playtest-friends`.

Or paste the URL in chat and I will write the file.

---

## 5. GitHub: make the `playtest` label once

1. Open [https://github.com/Nathan-Elequin/swipe/labels](https://github.com/Nathan-Elequin/swipe/labels)
2. **New label**
3. Name: `playtest`
4. Create label

If Issues already let you type a new label when creating one, you can skip this. Doing it now avoids a failed first Send.

---

## 6. itch: a second, unlisted page

Do **not** upload to https://nathan-elequin.itch.io/swipe. Push only https://nathan-elequin.itch.io/swipe-playtest

1. [https://itch.io/game/new](https://itch.io/game/new)
2. Title: `Swipe Playtest` (or similar)
3. **Visibility:** Restricted / unlisted / draft — friends need the link, strangers should not find it
4. Kind of project: **HTML**
5. In Godot: **Project → Export → Web Playtest → Export Project** to `build/web-playtest/index.html`
6. Zip the **contents** of `build/web-playtest` (the folder that has `index.html` in it)
7. Upload that zip on the new itch page. Save. Copy the itch URL. That is what friends open.

---

## Check that Send works

In a terminal (replace the URL):

```
curl -X POST https://YOUR-workers.dev-URL -H "Content-Type: application/json" -H "X-Swipe-Playtest: swipe-playtest-friends" -d "{\"note\":\"hello from Nathan\",\"card_name\":\"Healing Potion\"}"
```

Then open [https://github.com/Nathan-Elequin/swipe/issues?q=label%3Aplaytest](https://github.com/Nathan-Elequin/swipe/issues?q=label%3Aplaytest). You should see `[playtest] Healing Potion`.

If Send in the game says it copied to the clipboard instead, the workers.dev URL is missing from `data/playtest-inbox.json`, or you exported before saving that file.

---

## If you get stuck

- **`npx` is not recognized** — install Node LTS from https://nodejs.org then reopen the terminal.
- **GitHub token page wants Fine-grained** — click the **classic** option on that same tokens area, or go to [https://github.com/settings/tokens](https://github.com/settings/tokens) → **Generate new token** → **Generate new token (classic)**.
- **Deploy prints an error about login** — run `npx wrangler login` again, click Allow, then `npx wrangler deploy`.
- **Issue is not created** — the `ghp_` paste in `GITHUB_TOKEN` is wrong, or the `playtest` label is missing. Do not put `ghp_` in `playtest-inbox.json`.
