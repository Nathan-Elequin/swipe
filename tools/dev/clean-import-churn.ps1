# Usage: tools/dev/clean-import-churn.ps1
# Restores tracked *.import files whose only change is Godot's uid rewrite and/or LF/CRLF.
# New (untracked) .import files and every non-.import file are left alone.
. "$PSScriptRoot\_common.ps1"
$root = Get-RepoRoot
Push-Location $root
try {
	# Worktree-modified tracked .import files ("XY path", Y = M). git status also lists files whose
	# bytes match the index (line-ending/stat churn) that a plain git diff does not show.
	$changed = @((Invoke-GitOut status --porcelain --untracked-files=no -- '*.import').Out |
		Where-Object { $_.Length -gt 3 -and $_.Substring(1, 1) -eq 'M' } | ForEach-Object { $_.Substring(3).Trim('"') })
	if ($changed.Count -eq 0) { Write-Host "Import churn: restored 0 files."; exit 0 }
	# One diff for all of them, ignoring CR at EOL. Files absent from it differ only by line endings.
	$diff = (Invoke-GitOut diff --ignore-cr-at-eol -U0 --no-color -- '*.import').Out
	$real = @{}
	$seen = @{}
	$cur = ''
	foreach ($l in $diff) {
		if ($l -like 'diff --git *') { $cur = ''; continue }
		if ($l -like '+++ b/*') { $cur = $l.Substring(6); $seen[$cur] = $true; continue }
		if ($l -like '--- *' -or $l -like '@@*' -or $l -like 'index *' -or $cur -eq '') { continue }
		if ($l -match '^[+-]') {
			if ($l -notmatch '^[+-]uid="uid://[A-Za-z0-9]*"\s*$') { $real[$cur] = $true }
		}
	}
	$restore = @($changed | Where-Object { -not $real.ContainsKey($_) })
	for ($i = 0; $i -lt $restore.Count; $i += 100) {
		$chunk = $restore[$i..([Math]::Min($i + 99, $restore.Count - 1))]
		$r = Invoke-GitOut checkout -- @chunk
		if ($r.Code -ne 0) { Write-Host "git checkout failed on a batch:"; $r.Out | Select-Object -First 3 | Write-Host; exit 1 }
	}
	$kept = $changed.Count - $restore.Count
	Write-Host "Import churn: restored $($restore.Count) files; kept $kept .import file(s) with real changes."
	exit 0
} finally { Pop-Location }
