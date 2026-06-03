# BUXE_OS v24.0 -- HANDBOOK COMPANION

try {

function Show-HBCompanion {
    try { Clear-Host } catch {}
    Show-Frame "COMPANION" -Double | Out-Null
    Write-Host ""
    Write-Host "  5 Girls zur Auswahl. Jede hat eine einzigartige Persoenlichkeit." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  BOND LEVELS" -ForegroundColor Magenta
    Write-Host "    0-14   Stranger       | 15-29  Acquaintance" -ForegroundColor White
    Write-Host "    30-49  Friend         | 50-69  Close Friend" -ForegroundColor White
    Write-Host "    70-89  Partner        | 90-99  Soulmate" -ForegroundColor White
    Write-Host "    100    Spouse (Heirat moeglich)" -ForegroundColor White
    Write-Host ""
    Write-Host "  MOOD SYSTEM" -ForegroundColor Cyan
    Write-Host "    Jede Aktion aendert die Stimmung des Companions." -ForegroundColor DarkGray
    Write-Host "    Die Stimmung beeinflusst den Bond-Gewinn:" -ForegroundColor DarkGray
    Write-Host "    Happy   100% | Excited 120% | Loving  130%" -ForegroundColor Green
    Write-Host "    Tired    80% | Sad      70% | Angry    50%" -ForegroundColor Red
    Write-Host "    Punish macht wuetend. Gift/Date/Headpat macht gluecklich." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  SYNC LEVEL" -ForegroundColor Yellow
    Write-Host "    Steigt mit jedem Battlepet-Sieg um 1." -ForegroundColor DarkGray
    Write-Host "    Meilensteine: 10 (Rookie) | 25 (Veteran) | 50 (Master) | 100 (Soul Linked)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  AKTIONEN" -ForegroundColor Cyan
    Write-Host "    Talk:    +2 Bond | Gift:    +5 Bond" -ForegroundColor DarkGray
    Write-Host "    Date:    +4 Bond (ab 30) | Work:    Gold + Bond" -ForegroundColor DarkGray
    Write-Host "    Train:   +3 Bond, +Pet ATK | Story:   +2 Bond" -ForegroundColor DarkGray
    Write-Host "    Headpat: +1 Bond | Outfit:  Kosmetik" -ForegroundColor DarkGray
    Write-Host "    Punish:  Kein Bond, nur Fun" -ForegroundColor DarkGray
    Write-Host "    Confess: Ab 100 Bond | Marry: Ab 100 Bond" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  RIVAL SYSTEM" -ForegroundColor Red
    Write-Host "    Bei taeglichem Login: 20% Chance, dass ein Rival auftaucht." -ForegroundColor DarkGray
    Write-Host "    [V] Versus im Menue: 3-Runden-Kampf (Angriff/Verteidigung/Trick)." -ForegroundColor DarkGray
    Write-Host "    Sieg: +5 Bond, +2 Sync, Companion: Excited" -ForegroundColor Green
    Write-Host "    Niederlage: -3 Bond, Companion: Sad" -ForegroundColor Red
    Write-Host "    5 Siege = Achievement Rival Slayer" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  PET MILESTONES" -ForegroundColor Yellow
    Write-Host "    Automatisch beim Erreichen bestimmter Ziele." -ForegroundColor DarkGray
    Write-Host "    First Blood, Boss Slayer, Veteran (10), Champion (50), Legend (100)" -ForegroundColor White
    Write-Host "    Element Master (8 Typen), Evolution Complete, PvP Rookie, Raid Survivor" -ForegroundColor White
    Write-Host "    Werden im Pet Status angezeigt." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  MEMORIES" -ForegroundColor Magenta
    Write-Host "    Wichtige Momente werden automatisch gespeichert." -ForegroundColor DarkGray
    Write-Host "    [M] im Companion-Menue um sie anzusehen." -ForegroundColor DarkGray
    Write-Host "    Trigger: Evolution, Heirat, Confession, Boss, Raid, etc." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  COMPANION SKILLS" -ForegroundColor Green
    Write-Host "    Combat Boost:     +2G pro Level beim Battlepet-Sieg" -ForegroundColor DarkGray
    Write-Host "    Strategy Insight: +5 XP pro Level beim Battlepet-Sieg" -ForegroundColor DarkGray
    Write-Host "    Casino Luck:      +3% Gewinn pro Level in allen Casino-Spielen" -ForegroundColor DarkGray
    Write-Host "                      Slots: Gewichtete Symbol-Wahrscheinlichkeit" -ForegroundColor DarkGray
    Write-Host "    Max Level: 10 pro Skill | Kosten: 25G * (Level+1)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  COOKING" -ForegroundColor Green
    Write-Host "    Companion kann 4 Gerichte kochen (Cook im Menue)." -ForegroundColor DarkGray
    Write-Host "    Jeder Buff gilt fuer den naechsten Kampf:" -ForegroundColor DarkGray
    Write-Host "    Ramen: +10% MaxHP | Energy Drink: +20% SPD" -ForegroundColor White
    Write-Host "    Sushi Platter: +15% ATK | Golden Curry: +10% All Stats" -ForegroundColor White
    Write-Host "    Bei Bond 50+ Chance auf Mystery Stew (+5% All)." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  QUESTS" -ForegroundColor Yellow
    Write-Host "    Taeglich 3 zufaellige Quests. Belohnung: Gold + Bond." -ForegroundColor DarkGray
    Write-Host "    Progress wird automatisch beim Spielen gezaehlt." -ForegroundColor DarkGray
    Write-Host "    [C] im Quest-Menue um Belohnungen abzuholen." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  DAILY LOGIN" -ForegroundColor Yellow
    Write-Host "    Jeden Tag beim ersten Talk: +3-7 Bonus-Bond." -ForegroundColor DarkGray
    Write-Host "    Work: 1x pro Tag, 10-40G + Bond-Bonus." -ForegroundColor DarkGray
    Wait-Enter
}

} catch {
    Write-Host "[handbook-companion] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
