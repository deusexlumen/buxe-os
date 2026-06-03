# BUXE_OS v24.0 -- HANDBOOK EQUIPMENT

try {

function Show-HBEquipment {
    try { Clear-Host } catch {}
    Show-Frame "EQUIPMENT" -Double | Out-Null
    Write-Host ""
    Write-Host "  Jedes Pet kann 3 Ausruestungsslots tragen:" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  CHIP (ATK/Crit)" -ForegroundColor Yellow
    Write-Host "    Neural Chip:   +3 ATK      | 100 G" -ForegroundColor White
    Write-Host "    Quantum Chip:  +6 ATK, +5% Crit | 250 G" -ForegroundColor White
    Write-Host ""
    Write-Host "  ARMOR (DEF/HP)" -ForegroundColor Yellow
    Write-Host "    Plasma Armor:  +3 DEF, +10 HP  | 100 G" -ForegroundColor White
    Write-Host "    Aegis Plate:   +6 DEF, +20 HP  | 250 G" -ForegroundColor White
    Write-Host ""
    Write-Host "  ACCESSORY (SPD/CritRes)" -ForegroundColor Yellow
    Write-Host "    Speed Collar:  +3 SPD         | 100 G" -ForegroundColor White
    Write-Host "    Lucky Charm:   +10% Crit Resist | 250 G" -ForegroundColor White
    Write-Host ""
    Write-Host "  Equipment-Boni sind PERMANENT und stapeln!" -ForegroundColor Green
    Write-Host "  Ausruestung kann im Shop gekauft und ueberschrieben werden." -ForegroundColor DarkGray
    Wait-Enter
}

} catch {
    Write-Host "[handbook-equipment] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
