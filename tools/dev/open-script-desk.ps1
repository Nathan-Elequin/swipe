# Opens the Script desk in Zen. Starts the local writer on 127.0.0.1:8765 if it is not already up.
$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repo
$url = "http://127.0.0.1:8765/"

function Test-Desk {
    try {
        Invoke-WebRequest -Uri ($url + "api/pack") -UseBasicParsing -TimeoutSec 2 | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Desk)) {
    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($py) {
        $python = $py.Source
        $arg = @("-3", "tools\script-desk-server.py")
    } else {
        $python = (Get-Command python).Source
        $arg = @("tools\script-desk-server.py")
    }
    Start-Process -FilePath $python -ArgumentList $arg -WorkingDirectory $repo -WindowStyle Minimized
    $ok = $false
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Milliseconds 250
        if (Test-Desk) { $ok = $true; break }
    }
    if (-not $ok) {
        Write-Error "Script desk server did not start on $url"
        exit 1
    }
}

$zen = "C:\Program Files\Zen Browser\zen.exe"
if (Test-Path $zen) {
    Start-Process $zen $url
} else {
    Start-Process $url
}
Write-Host "Script desk $url"
exit 0
