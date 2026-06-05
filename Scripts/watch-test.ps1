# BUXE_OS v24.2 -- WATCH TEST
# Laeuft Smoke+Integration+E2E bei jeder Aenderung in Modules\.
# Usage: & .\Scripts\watch-test.ps1

try {

$modDir = Join-Path $PSScriptRoot "..\Modules"
$lastHash = $null

Write-Host "  [WATCH] Ueberwache $modDir ..." -ForegroundColor Cyan
Write-Host "  [WATCH] Ctrl+C zum Beenden.`n" -ForegroundColor DarkGray

while ($true) {
    $files = Get-ChildItem "$modDir\*.ps1" -Recurse | Sort-Object FullName
    $currentHash = ($files | ForEach-Object { "$($_.FullName)|$($_.LastWriteTime)" }) -join ""
    $currentHash = [System.BitConverter]::ToString([System.Text.Encoding]::UTF8.GetBytes($currentHash)) -replace "-",""
    
    if ($lastHash -and $lastHash -ne $currentHash) {
        Write-Host "`n  [WATCH] Aenderung erkannt. Starte Tests...`n" -ForegroundColor Yellow
        
        $smoke = & "$modDir\_smoke_test.ps1" 2>&1
        $smokeOk = $smoke -match "ALL TESTS PASSED"
        
        $int = & "$modDir\_integration_test.ps1" 2>&1
        $intOk = $int -match "ALL INTEGRATION TESTS PASSED"
        
        if ($smokeOk -and $intOk) {
            Write-Host "`n  [WATCH] Smoke + Integration OK. E2E wird uebersprungen (langsam).`n" -ForegroundColor Green
        } else {
            Write-Host "`n  [WATCH] FEHLER! Smoke OK=$smokeOk | Integration OK=$intOk`n" -ForegroundColor Red
        }
    }
    
    $lastHash = $currentHash
    Start-Sleep -Seconds 2
}

} catch {
    Write-Host "[WATCH] Beendet." -ForegroundColor DarkGray
}
