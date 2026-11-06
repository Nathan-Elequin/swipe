# Keeps the Script desk server on http://127.0.0.1:8765/
# If it is already answering, this exits. If it dies, this starts it again.
$ErrorActionPreference = "Continue"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repo

function Test-Desk {
    try {
        Invoke-WebRequest -Uri "http://127.0.0.1:8765/api/pack" -UseBasicParsing -TimeoutSec 2 | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (Test-Desk) { exit 0 }

$py = Get-Command py -ErrorAction SilentlyContinue
if ($py) {
    $python = $py.Source
    $pyArgs = @("-3", "tools\script-desk-server.py")
} else {
    $python = (Get-Command python).Source
    $pyArgs = @("tools\script-desk-server.py")
}

while ($true) {
    if (Test-Desk) { exit 0 }
    & $python @pyArgs
    Start-Sleep -Seconds 2
}
