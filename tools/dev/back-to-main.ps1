# Usage: tools/dev/back-to-main.ps1
# Stash uncommitted work, switch to main, pull --ff-only, re-apply the work.
. "$PSScriptRoot\_common.ps1"
$null = Get-RepoRoot

$f = Invoke-Git fetch origin --prune
if ($f.Code -ne 0) { Write-Host "git fetch failed:"; $f.Out | Write-Host; exit 1 }

$stash = Save-Wip 'main'
$c = Invoke-Git checkout main
if ($c.Code -ne 0) {
	Write-Host "Checkout main failed:"; $c.Out | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
	$null = Restore-Wip $stash
	exit 1
}
$p = Invoke-Git pull --ff-only origin main
$pulled = ($p.Code -eq 0)
if (-not $pulled) { Write-Host "WARNING: main could not fast-forward to origin/main (local commits?). Left as is." }
if (-not (Restore-Wip $stash)) { exit 2 }
$sha = (Invoke-GitOut rev-parse --short HEAD).Out[0]
Write-Host "On main ($sha). Press F5."
if (-not $pulled) { exit 3 }
exit 0
