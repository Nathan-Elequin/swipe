# Opens the Script desk in Zen. Starts the local writer on 127.0.0.1:8765 if it is not already up.
$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repo
$url = "http://127.0.0.1:8765/#tutorial"
$task = "Swipe Script Desk"

function Test-Desk {
    try {
        Invoke-WebRequest -Uri "http://127.0.0.1:8765/api/pack" -UseBasicParsing -TimeoutSec 2 | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Desk)) {
    # The logon task owns the process, so a chat or a closed window does not take the server with it.
    schtasks /Run /TN $task 2>$null | Out-Null
    Start-Sleep -Milliseconds 400
    if (-not (Test-Desk)) {
        $ps = (Get-Command powershell.exe).Source
        $arg = @("-NoProfile", "-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-File", (Join-Path $PSScriptRoot "script-desk-serve.ps1"))
        Start-Process -FilePath $ps -ArgumentList $arg -WorkingDirectory $repo -WindowStyle Hidden
    }
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
