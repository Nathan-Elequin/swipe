# Usage: tools/dev/ready-prs.ps1
# One gh call. Prints nothing when no PR is labeled ready-to-test, else one line per PR.
$json = & gh pr list --repo Nathan-Elequin/swipe --label ready-to-test --json number,title,headRefName,url 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "gh pr list failed (is gh logged in?)"; exit 1 }
$prs = ("$json" | ConvertFrom-Json)
foreach ($p in $prs) {
	if ($null -eq $p -or $null -eq $p.number) { continue }
	Write-Host ("#{0} [{1}] {2} {3}" -f $p.number, $p.headRefName, $p.title, $p.url)
}
exit 0
