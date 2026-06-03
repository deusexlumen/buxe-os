# BUXE_OS v24.0 -- HANDBOOK CORE

try {

function handbook {
    while ($true) {
    try { Clear-Host } catch {}
        Show-Frame "BUXE_OS HANDBUCH" -Double | Out-Null
        Write-Host ""
        Write-Host "  [1] Kampfsystem    [2] Elemente      [3] Status-Effekte" -ForegroundColor White
        Write-Host "  [4] Skills         [5] Equipment     [6] Casino" -ForegroundColor White
        Write-Host "  [7] Companion      [8] Commands      [Q] Zurueck" -ForegroundColor White
        $c = Read-Choice "Waehle" '^[1-8Q]$'
        switch ($c) {
            '1' { Show-HBCombat }
            '2' { Show-HBElements }
            '3' { Show-HBStatus }
            '4' { Show-HBSkills }
            '5' { Show-HBEquipment }
            '6' { Show-HBCasino }
            '7' { Show-HBCompanion }
            '8' { Show-HBCommands }
            'Q' { return }
        }
    }
}

} catch {
    Write-Host "[handbook-core] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
