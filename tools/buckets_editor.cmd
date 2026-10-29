@echo off
cd /d "%~dp0.."
echo Open http://127.0.0.1:8767/pools.html
py -3 tools\buckets_editor_server.py
