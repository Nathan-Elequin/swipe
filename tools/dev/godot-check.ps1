# Usage: tools/dev/godot-check.ps1 [project path]   (default: this repo)
# Headless --import (retried once on a crash), then --quit, at BelowNormal priority.
# Counts real "SCRIPT ERROR" / "Parse Error" lines. Leak-at-exit and port-in-use noise is ignored.
param([string]$Path = '')
. "$PSScriptRoot\_common.ps1"
$Godot = 'C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
if ($Path -eq '') { $Path = Get-RepoRoot }
$Path = (Resolve-Path $Path).Path
if (-not (Test-Path (Join-Path $Path 'project.godot'))) { Write-Host "No project.godot in $Path"; exit 1 }
if (-not (Test-Path $Godot)) { Write-Host "Godot not found: $Godot"; exit 1 }

$tmp = Join-Path $env:TEMP ("godot-check-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $tmp | Out-Null

function Invoke-Godot([string]$mode, [string]$tag) {
	$o = Join-Path $tmp "$tag.out"; $e = Join-Path $tmp "$tag.err"
	$p = Start-Process -FilePath $Godot -ArgumentList @('--headless', '--path', "`"$Path`"", $mode) `
		-RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru
	$null = $p.Handle  # cache the handle so ExitCode is readable after exit (PS 5.1 quirk)
	try { $p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal } catch { }
	$p.WaitForExit()
	$code = $p.ExitCode
	if ($null -eq $code) { $code = -1 }
	return @{ Code = $code; Files = @($o, $e) }
}

$imp = Invoke-Godot '--import' 'import1'
if ($imp.Code -ne 0) {
	Write-Host "Godot --import exited with $($imp.Code); retrying once."
	$imp = Invoke-Godot '--import' 'import2'
	if ($imp.Code -ne 0) { Write-Host "Godot --import crashed twice (exit $($imp.Code)). Logs: $tmp"; Write-Host "Godot: import failed"; exit 2 }
}
$quit = Invoke-Godot '--quit' 'quit'

$files = @($imp.Files + $quit.Files) | Where-Object { Test-Path $_ }
$errs = @(Select-String -Path $files -Pattern 'SCRIPT ERROR|Parse Error' | ForEach-Object { $_.Line })
$errs | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
Write-Host "Godot: $($errs.Count) errors"
if ($errs.Count -eq 0) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue; exit 0 }
Write-Host "Logs: $tmp"
exit 1
