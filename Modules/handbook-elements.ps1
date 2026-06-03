# BUXE_OS v24.0 -- HANDBOOK ELEMENTS

try {

function Show-HBElements {
    try { Clear-Host } catch {}
    Show-Frame "ELEMENTE" -Double | Out-Null
    Write-Host ""
    Write-Host "  Elemente bestimmen den Schadensmultiplikator im Kampf." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  SUPER EFFECTIVE (1.5x Schaden):" -ForegroundColor Green
    Write-Host "    FEUER  > EIS      EIS    > ELEKTRISCH" -ForegroundColor White
    Write-Host "    ELEKTRISCH > WASSER   WASSER > FEUER" -ForegroundColor White
    Write-Host "    VIRUS  > ELEKTRISCH   DARK   > NORMAL" -ForegroundColor White
    Write-Host "    HACK   > VIRUS" -ForegroundColor White
    Write-Host ""
    Write-Host "  NOT VERY EFFECTIVE (0.5x Schaden):" -ForegroundColor Red
    Write-Host "    FEUER  < WASSER   EIS    < FEUER" -ForegroundColor White
    Write-Host "    ELEKTRISCH < EIS     WASSER < ELEKTRISCH" -ForegroundColor White
    Write-Host "    VIRUS  < FEUER    DARK   < ELEKTRISCH" -ForegroundColor White
    Write-Host "    HACK   < DARK" -ForegroundColor White
    Write-Host ""
    Write-Host "  NEUTRAL (1.0x Schaden):" -ForegroundColor DarkGray
    Write-Host "    Alles andere, inkl. NORMAL-Angriffe auf alles." -ForegroundColor White
    Write-Host "    NORMAL und HACK haben keine natuerlichen Staerken." -ForegroundColor White
    Wait-Enter
}

} catch {
    Write-Host "[handbook-elements] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
