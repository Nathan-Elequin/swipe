# Shared helpers for tools/dev/*.ps1 (dot-sourced). PowerShell 5.1 compatible, ASCII only.
$ErrorActionPreference = 'Continue'

function Invoke-Git {
	# Runs git, returns @{ Code = exit code; Out = string[] } with stderr merged as plain text.
	$out = & git @args 2>&1 | ForEach-Object { "$_" }
	return @{ Code = $LASTEXITCODE; Out = @($out) }
}

function Invoke-GitOut {
	# Runs git and returns stdout lines only (warnings on stderr, e.g. LF/CRLF notices, are dropped).
	$out = & git -c core.safecrlf=false @args 2>$null | ForEach-Object { "$_" }
	return @{ Code = $LASTEXITCODE; Out = @($out) }
}

function Get-RepoRoot {
	$r = Invoke-GitOut rev-parse --show-toplevel
	if ($r.Code -ne 0) { Write-Host "Not inside a git repo."; exit 1 }
	return $r.Out[0]
}

function Get-CurrentBranch {
	$r = Invoke-GitOut rev-parse --abbrev-ref HEAD
	return $r.Out[0]
}

function Test-Dirty {
	# Tracked changes only (staged or not). Untracked files are left where they are.
	$r = Invoke-GitOut status --porcelain --untracked-files=no
	return (@($r.Out | Where-Object { $_ -ne '' }).Count -gt 0)
}

function Save-Wip([string]$target) {
	# Stash tracked changes under a named stash. Returns the stash commit sha, or '' if clean.
	if (-not (Test-Dirty)) { return '' }
	$safe = ($target -replace '[^A-Za-z0-9._-]', '-')
	$name = "wip-before-$safe-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
	$r = Invoke-Git stash push -m $name
	if ($r.Code -ne 0) { Write-Host "Could not stash your changes. Nothing was switched."; $r.Out | Write-Host; exit 1 }
	$sha = (Invoke-GitOut rev-parse 'stash@{0}').Out[0]
	Write-Host "Saved your uncommitted changes as stash '$name'."
	return $sha
}

function Restore-Wip([string]$sha) {
	# Apply (not pop) so the stash stays as a backup. Returns $true on a clean apply.
	if ($sha -eq '') { return $true }
	$r = Invoke-Git stash apply $sha
	if ($r.Code -eq 0) {
		Write-Host "Re-applied your changes (stash kept as a backup)."
		return $true
	}
	$conf = (Invoke-GitOut diff --name-only --diff-filter=U).Out | Where-Object { $_ -ne '' }
	Write-Host "STOP: your changes did not re-apply cleanly. Nothing was discarded."
	if (@($conf).Count -gt 0) {
		Write-Host "Conflicts (fix the <<<<<<< markers in these files):"
		$conf | ForEach-Object { Write-Host "  $_" }
	} else {
		$r.Out | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
	}
	Write-Host "Your original edits are still in the stash: git stash list"
	return $false
}
