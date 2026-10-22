# Usage: tools/dev/load-pr.ps1 <pr-number|branch>
# Fetch, stash uncommitted work, check out the PR branch (tracking origin), re-apply the work.
param([Parameter(Mandatory = $true)][string]$Target)
. "$PSScriptRoot\_common.ps1"
$null = Get-RepoRoot

$branch = $Target
if ($Target -match '^#?\d+$') {
	$n = $Target.TrimStart('#')
	$b = & gh pr view $n --json headRefName --jq .headRefName 2>$null
	if ($LASTEXITCODE -ne 0 -or -not $b) { Write-Host "Could not find PR #$n with gh."; exit 1 }
	$branch = "$b".Trim()
}

$f = Invoke-Git fetch origin --prune
if ($f.Code -ne 0) { Write-Host "git fetch failed:"; $f.Out | Write-Host; exit 1 }
if ((Invoke-GitOut rev-parse --verify --quiet "refs/remotes/origin/$branch").Code -ne 0) {
	Write-Host "No branch origin/$branch."; exit 1
}
# Never throw away local commits that are not on origin yet.
if ((Invoke-GitOut rev-parse --verify --quiet "refs/heads/$branch").Code -eq 0) {
	$ahead = (Invoke-GitOut rev-list --count "origin/$branch..$branch").Out[0]
	if ([int]$ahead -gt 0) {
		Write-Host "STOP: local $branch has $ahead commit(s) not on origin. Push or merge them first."; exit 1
	}
}

$stash = Save-Wip $branch
$c = Invoke-Git checkout -B $branch --track "origin/$branch"
if ($c.Code -ne 0) {
	Write-Host "Checkout failed:"; $c.Out | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
	$null = Restore-Wip $stash
	exit 1
}
if (-not (Restore-Wip $stash)) { exit 2 }
$sha = (Invoke-GitOut rev-parse --short HEAD).Out[0]
Write-Host "On $branch ($sha). Press F5."
exit 0
