# BUXE_OS v24.0 -- HANDBOOK STATUS EFFECTS

try {

function Show-HBStatus {
    try { Clear-Host } catch {}
    Show-Frame "STATUS-EFFEKTE" -Double | Out-Null
    Write-Host ""
    Write-Host "  Status-Effekte werden am Anfang jeder Runde verarbeitet." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  BURN (Feuer)" -ForegroundColor Red
    Write-Host "    5% MaxHP Schaden pro Runde. Dauer: 3 Runden." -ForegroundColor DarkGray
    Write-Host "    Ausloeser: Plasma Lance, Shadow Claw." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  POISON (Virus)" -ForegroundColor Magenta
    Write-Host "    3% MaxHP Schaden pro Runde (stapelt mit BURN!)." -ForegroundColor DarkGray
    Write-Host "    Dauer: 3-4 Runden. Ausloeser: System Purge, Data Drain." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  STUN (Elektro/Eis)" -ForegroundColor Yellow
    Write-Host "    Ueberspringt die naechste Aktion. Dauer: 1 Runde." -ForegroundColor DarkGray
    Write-Host "    Ausloeser: Neural Overload, Ice Spike." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  REGEN (Heal)" -ForegroundColor Green
    Write-Host "    5% MaxHP Heilung pro Runde. Dauer: 3 Runden." -ForegroundColor DarkGray
    Write-Host "    Ausloeser: Debug Patch." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  BUFF (Elec/Water)" -ForegroundColor Cyan
    Write-Host "    +20% Schaden fuer den naechsten Angriff." -ForegroundColor DarkGray
    Write-Host "    Ausloeser: Overclock, Water Cannon, Firewall." -ForegroundColor DarkGray
    Wait-Enter
}

} catch {
    Write-Host "[handbook-status] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
