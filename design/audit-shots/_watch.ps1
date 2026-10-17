$src='C:\Users\Natha\Pictures\Screenshots'; $dst='C:\Users\Natha\Documents\boss-rush\design\audit-shots'
$seen=@{}; Get-ChildItem $src -File | % { $seen[$_.Name]=1 }
while ($true) { Start-Sleep 2; Get-ChildItem $src -File -Include *.png,*.jpg -Recurse | ? { -not $seen[$_.Name] } | % { Start-Sleep -Milliseconds 500; Copy-Item $_.FullName (Join-Path $dst $_.Name) -Force; $seen[$_.Name]=1 } }
