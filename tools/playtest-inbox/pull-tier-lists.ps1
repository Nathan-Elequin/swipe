# Pull D1 summary into playtest/tier-lists/snapshot.json
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Resolve-Path (Join-Path $here "..\..")
Set-Location $here
$cfgPath = Join-Path $root "data\playtest-inbox.json"
$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
$url = ($cfg.url.TrimEnd("/")) + "/?view=tier"
$headers = @{
  "X-Swipe-Playtest" = [string]$cfg.token
  "User-Agent" = "SwipeTierPull"
}
$destDir = Join-Path $root "playtest\tier-lists"
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$out = Join-Path $destDir "snapshot.json"
Write-Host "GET $url"
$json = Invoke-RestMethod -Method GET -Uri $url -Headers $headers
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($out, ($json | ConvertTo-Json -Depth 12), $utf8)
Write-Host "Wrote $out"
py -3 $here\card_names.py
