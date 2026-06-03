# BUXE_OS v24.0 -- HANDBOOK CASINO

try {

function Show-HBCasino {
    Clear-Host
    Show-Frame "CASINO" -Double | Out-Null
    Write-Host ""
    Write-Host "  6 Spiele verfuegbar. Alle nutzen dein Bank-Guthaben." -ForegroundColor DarkGray
    Write-Host "  Bei 0 Gold wird automatisch auf 100 G zurueckgesetzt (Bust)." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  BLACKJACK" -ForegroundColor Cyan
    Write-Host "    Hit, Stand, Double, Split, Insurance. Dealer zieht bei < 17." -ForegroundColor DarkGray
    Write-Host "    Blackjack zahlt 3:2." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ROULETTE" -ForegroundColor Cyan
    Write-Host "    Europaeisch (0-36). Rot/Schwarz, Gerade/Ungerade, Zahl," -ForegroundColor DarkGray
    Write-Host "    Dutzend, Strasse. Multiplikatoren: 1x bis 35x." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  CRAPS" -ForegroundColor Cyan
    Write-Host "    Pass/Don't Pass Line mit Point-Establishment." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  HILO" -ForegroundColor Cyan
    Write-Host "    Rate hoeher/tiefer. Multiplikator +0.5x pro Runde." -ForegroundColor DarkGray
    Write-Host "    Cash-out jederzeit moeglich." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  BACCARAT" -ForegroundColor Cyan
    Write-Host "    Player/Banker/Tie. 3rd-Card-Regeln automatisch." -ForegroundColor DarkGray
    Write-Host "    Banker: 5% Commission bei Gewinn." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  SLOT" -ForegroundColor Cyan
    Write-Host "    3-Walzen mit Animation. Jackpot/Match/Pair Auszahlungen." -ForegroundColor DarkGray
    Wait-Enter
}

} catch {
    Write-Host "[handbook-casino] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
