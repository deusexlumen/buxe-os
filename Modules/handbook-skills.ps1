# BUXE_OS v24.0 -- HANDBOOK SKILLS

try {

function Show-HBSkills {
    Clear-Host
    Show-Frame "SKILLS" -Double | Out-Null
    Write-Host ""
    Write-Host "  Passive Skills werden automatisch im Kampf angewendet." -ForegroundColor DarkGray
    Write-Host "  Max 4 Skills pro Pet. Lernchance: 25% pro Level-Up." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Regeneration" -ForegroundColor Green
    Write-Host "    Heilt 1% MaxHP am Ende jeder Runde (nach Status-Effekten)." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Critical Master" -ForegroundColor Magenta
    Write-Host "    +15% Crit-Chance. Stapelbar mit Chip-Boni." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Life Steal" -ForegroundColor Red
    Write-Host "    Heilt 10% des verursachten Schadens bei jedem Treffer." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Iron Will" -ForegroundColor Cyan
    Write-Host "    +20% DEF wenn HP unter 30%. Automatisch aktiv." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  PERSOENLICHKEITEN" -ForegroundColor Yellow
    Write-Host "    Aggressive: +10% ATK, -5% DEF" -ForegroundColor DarkGray
    Write-Host "    Defensive: -5% ATK, +10% DEF" -ForegroundColor DarkGray
    Write-Host "    Balanced: +5% Crit-Chance" -ForegroundColor DarkGray
    Write-Host "    Trickster: +10% SPD, +10% Status-Chance" -ForegroundColor DarkGray
    Write-Host "    Berserker: +20% ATK unter 50% HP" -ForegroundColor DarkGray
    Wait-Enter
}

} catch {
    Write-Host "[handbook-skills] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
