@echo off
if /i not "%~1"=="stay" (
  cmd /k "%~f0" stay
  exit /b
)
setlocal
cd /d "%~dp0"

echo.
echo This window is already in the right folder. You do not need to type a path.
echo.
where npx >nul 2>&1
if errorlevel 1 (
  echo Node is not installed, so this window cannot continue.
  echo Install Node LTS from https://nodejs.org
  echo Check the "Add to PATH" box. Then close this window, reopen setup.cmd.
  echo.
  pause
  exit /b 1
)

echo --- 1 of 4: Cloudflare login ---
echo A browser tab will open. Sign in if asked, then click Allow.
echo.
pause
call npx --yes wrangler login
if errorlevel 1 (
  echo Login did not finish. Close this, double-click setup.cmd again.
  pause
  exit /b 1
)

echo.
echo --- 2 of 4: GitHub password ---
echo Paste the ghp_ string you copied from GitHub, then press Enter.
echo The window will hide the characters. That is normal.
echo.
call npx --yes wrangler secret put GITHUB_TOKEN
if errorlevel 1 (
  echo That paste did not take. Run setup.cmd again from this step onward, or start over.
  pause
  exit /b 1
)

echo.
echo --- 3 of 4: shared token ---
echo When it waits, paste this exactly, then Enter:
echo swipe-playtest-friends
echo.
call npx --yes wrangler secret put PLAYTEST_TOKEN
if errorlevel 1 (
  echo That paste did not take. Run setup.cmd again.
  pause
  exit /b 1
)

echo.
echo --- 4 of 4: publish ---
call npx --yes wrangler deploy
echo.
echo Look above for a line that starts with https:// and ends with workers.dev
echo Copy that URL. Paste it in the Cursor chat. I will put it in the game.
echo.
pause
