$r='C:\Users\Natha\Documents\spinheritance-art-kit\returns\pixellab\run3'
Expand-Archive -Force ($r+'\touchup.zip') $r
Remove-Item ($r+'\touchup.zip')
New-Item -ItemType Directory -Force ($r+'\final\_pre_touchup\x4') | Out-Null
foreach($k in 2,3){
  $f=$r+'\final\sprout64_blink_f'+$k+'.png'; if(Test-Path $f){Remove-Item $f}
  $g=$r+'\final\x4\sprout64_blink_f'+$k+'.png'; if(Test-Path $g){Move-Item -Force $g ($r+'\final\_pre_touchup\x4\')}
}
(Get-ChildItem -Recurse -File $r).Count
