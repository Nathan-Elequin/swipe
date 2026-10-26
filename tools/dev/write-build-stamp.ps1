# Writes data/build_stamp.txt from the real git commit.
# F5 does not need this. Editor play reads git at startup.
# Run it only for a build that cannot see .git and is not going through
# the editor export plugin (addons/build_stamp), which bakes the same string.
# Prints the stamp. A trailing * means the worktree had changes.
# Usage: powershell -ExecutionPolicy Bypass -File tools/dev/write-build-stamp.ps1
. "$PSScriptRoot\_common.ps1"
$root = Get-RepoRoot
Set-Location $root
$sha = Invoke-GitOut rev-parse --short HEAD
if ($sha.Code -ne 0 -or @($sha.Out).Count -lt 1 -or [string]::IsNullOrWhiteSpace($sha.Out[0])) {
	Write-Host "git rev-parse --short HEAD failed"
	exit 1
}
$text = $sha.Out[0].Trim()
$dirty = Invoke-GitOut status --porcelain --untracked-files=normal
$lines = @($dirty.Out | Where-Object { $_ -ne '' -and $_ -notmatch 'data/build_stamp.txt$' })
if ($lines.Count -gt 0) { $text += '*' }
$path = Join-Path $root 'data/build_stamp.txt'
[System.IO.File]::WriteAllText($path, $text + "`n")
Write-Host $text
exit 0
