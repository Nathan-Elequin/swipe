@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0request_art.ps1" %*
exit /b %ERRORLEVEL%
