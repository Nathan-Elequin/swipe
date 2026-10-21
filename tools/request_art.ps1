# Ping the Cursor automation "Swipe art request" webhook when cards need art.
# art-handoff.mdc: Pixel's Grok Bot routine is paused and does nothing useful.
# This script is the Cherry-side ping for that Cursor automation instead.
# Usage: tools\request_art.cmd <id>[=Name] [<id>[=Name] ...]
# Config: <repo>\.art-ping.env (gitignored). After you save the automation at
# https://cursor.com/automations, copy its webhook URL and API key:
#   ART_PING_URL=<webhook URL from the automation after save>
#   ART_PING_KEY=<webhook API key>
# Never put the URL or key in git. Missing config exits 0. Same id set within 10 min is skipped.
# POST JSON with Authorization: Bearer <ART_PING_KEY> (Cursor webhook docs).
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Cards)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root '.art-ping.env'
$lastFile = Join-Path $root '.art-ping.last'

if (-not $Cards -or $Cards.Count -eq 0) {
    Write-Host 'usage: tools\request_art.cmd <id>[=Name] [<id>[=Name] ...]'
    exit 2
}

if (-not (Test-Path -LiteralPath $envFile)) {
    Write-Host 'art ping not configured'
    exit 0
}

$cfg = @{}
foreach ($line in Get-Content -LiteralPath $envFile) {
    $l = $line.Trim()
    if ($l -eq '' -or $l.StartsWith('#')) { continue }
    $i = $l.IndexOf('=')
    if ($i -lt 1) { continue }
    $cfg[$l.Substring(0, $i).Trim()] = $l.Substring($i + 1).Trim().Trim('"')
}
$url = ([string]$cfg['ART_PING_URL']).Trim().Trim("`r", "`n")
$key = ([string]$cfg['ART_PING_KEY']).Trim().Trim("`r", "`n")
if ($url -eq '' -or $key -eq '') {
    Write-Host 'art ping not configured'
    exit 0
}

# Names from the catalog when not given as id=Name.
$names = @{}
try {
    $cat = Get-Content -LiteralPath (Join-Path $root 'data\catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($row in @($cat.items) + @($cat.monsters)) { if ($row.id) { $names[[string]$row.id] = [string]$row.name } }
} catch { }

$list = @()
foreach ($c in $Cards) {
    $parts = $c.Split('=', 2)
    $id = $parts[0].Trim()
    if ($id -eq '') { continue }
    $name = if ($parts.Count -gt 1 -and $parts[1].Trim() -ne '') { $parts[1].Trim() } elseif ($names.ContainsKey($id)) { $names[$id] } else { $id }
    $list += [ordered]@{ id = $id; name = $name }
}
if ($list.Count -eq 0) { Write-Host 'no card ids given'; exit 2 }

$setKey = (($list | ForEach-Object { $_.id } | Sort-Object -Unique) -join ',')
$now = Get-Date
if (Test-Path -LiteralPath $lastFile) {
    try {
        $last = Get-Content -LiteralPath $lastFile -Raw | ConvertFrom-Json
        if ($last.ids -eq $setKey -and ($now - [datetime]$last.when).TotalMinutes -lt 10) {
            Write-Host "art ping skipped: same cards pinged at $($last.when)"
            exit 0
        }
    } catch { }
}

$body = [ordered]@{ cards = $list; source = 'cursor'; when = $now.ToString('o') } | ConvertTo-Json -Depth 4 -Compress
$headers = @{ 'Authorization' = "Bearer $key" }

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $res = Invoke-WebRequest -Uri $url -Method Post -Headers $headers -ContentType 'application/json' -Body ([Text.Encoding]::UTF8.GetBytes($body)) -UseBasicParsing -TimeoutSec 20
    $code = [int]$res.StatusCode
} catch {
    $code = 0
    if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    $msg = $_.Exception.Message
    Write-Host "art ping failed: HTTP $code $msg"
    exit 1
}

Write-Host "art ping: HTTP $code ($setKey)"
if ($code -ge 200 -and $code -lt 300) {
    ([ordered]@{ ids = $setKey; when = $now.ToString('o') } | ConvertTo-Json -Compress) | Set-Content -LiteralPath $lastFile -Encoding UTF8
    exit 0
}
Write-Host "art ping failed: unexpected HTTP $code"
exit 1
