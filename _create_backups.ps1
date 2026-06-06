$stateFile = "$env:LOCALAPPDATA\buxe\buxe_state_v24.json"
$bak1 = "$stateFile.bak1"
$bak2 = "$stateFile.bak2"
$bak3 = "$stateFile.bak3"
$bak4 = "$stateFile.bak4"
$bak5 = "$stateFile.bak5"
if (-not (Test-Path $stateFile)) { '{"Version":24}' | Set-Content $stateFile }
Copy-Item $stateFile $bak1 -Force
Copy-Item $bak1 $bak2 -Force
Copy-Item $bak2 $bak3 -Force
Copy-Item $bak3 $bak4 -Force
Copy-Item $bak4 $bak5 -Force
Write-Host "Backups created"
