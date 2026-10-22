# Usage: tools/dev/install-hooks.ps1
# Points git at tools/hooks so the pre-commit guard runs on every commit in this clone.
. "$PSScriptRoot\_common.ps1"
$root = Get-RepoRoot
if (-not (Test-Path (Join-Path $root 'tools/hooks/pre-commit'))) { Write-Host "tools/hooks/pre-commit is missing on this branch."; exit 1 }
$r = Invoke-Git config core.hooksPath tools/hooks
if ($r.Code -ne 0) { Write-Host "git config failed."; exit 1 }
Write-Host "Hooks installed: core.hooksPath = tools/hooks"
exit 0
