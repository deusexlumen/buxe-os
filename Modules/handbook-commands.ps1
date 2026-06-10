# BUXE_OS v24.0 -- HANDBOOK COMMANDS

try {

function Show-HBCommands {
    try { Clear-Host } catch {}
    Show-Frame "COMMANDS" -Double | Out-Null
    Write-Host ""
    Write-Host "  CORE" -ForegroundColor Cyan
    Write-Host "    status    Full Dashboard | bank      Kontostand" -ForegroundColor DarkGray
    Write-Host "    daily     Tagesbonus     | h         Alle Commands" -ForegroundColor DarkGray
    Write-Host "    handbook  Dieses Handbuch" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  PET HUB" -ForegroundColor Magenta
    Write-Host "    pet              Pet-Hub Menu (v2.0)" -ForegroundColor DarkGray
    Write-Host "    pet <action>     Direkte Aktion (talk/fight/etc.)" -ForegroundColor DarkGray
    Write-Host "    pet status       Status-Uebersicht" -ForegroundColor DarkGray
    Write-Host "    pet-transfer     Pet-Gold -> Bank (50% Steuer)" -ForegroundColor DarkGray
    Write-Host "    achievements     Alle Achievements anzeigen" -ForegroundColor DarkGray
    Write-Host "    pet strategy     Strategy-Spiele Stats" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  CASINO" -ForegroundColor Yellow
    Write-Host "    blackjack, roulette, craps, hilo, baccarat, slot" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ARCADE" -ForegroundColor Green
    Write-Host "    snake, monkeytype, wordle, zork, hangman" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  STRATEGY" -ForegroundColor Red
    Write-Host "    poker, td, rogue" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  STATE" -ForegroundColor DarkGray
    Write-Host "    pet export     State als JSON exportieren" -ForegroundColor DarkGray
    Write-Host "    pet import     State aus JSON importieren" -ForegroundColor DarkGray
    Write-Host "    Export/Import auch im Pet-Hub unter [E] / [I]" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  SYSTEM" -ForegroundColor DarkGray
    Write-Host "    mem, sysinfo, uptime, weather, ip, reload" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  TTS (SPRACHE)" -ForegroundColor Cyan
    Write-Host "    voices        Alle Stimmen anzeigen (EN + Multilingual)" -ForegroundColor DarkGray
    Write-Host "    svoice EN 3   Stimme waehlen (EN=English, ML=Multilingual)" -ForegroundColor DarkGray
    Write-Host "    Say 'Text'    Text mit aktiver Stimme vorlesen" -ForegroundColor DarkGray
    Write-Host "    Say 'Text' -W Wartet bis Audio fertig ist" -ForegroundColor DarkGray
    Write-Host "    clip-say      Vorlesen aus der Zwischenablage" -ForegroundColor DarkGray
    Wait-Enter
}

} catch {
    Write-Host "[handbook-commands] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
