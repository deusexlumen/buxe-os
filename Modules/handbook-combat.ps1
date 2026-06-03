# BUXE_OS v24.0 -- HANDBOOK COMBAT

try {

function Show-HBCombat {
    Clear-Host
    Show-Frame "KAMPFSYSTEM" -Double | Out-Null
    Write-Host ""
    Write-Host "  TURN ORDER" -ForegroundColor Cyan
    Write-Host "  Jede Runde beginnt mit der Verarbeitung von Status-Effekten." -ForegroundColor DarkGray
    Write-Host "  Dann greift das schnellere Pokemon zuerst an (SPD-Stat)." -ForegroundColor DarkGray
    Write-Host "  Trickster-Persoenlichkeit gibt +10% SPD im Kampf." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  PERSONALITIES" -ForegroundColor Cyan
    Write-Host "    Aggressive: +10% ATK, -5% DEF | Defensive: -5% ATK, +10% DEF" -ForegroundColor White
    Write-Host "    Balanced: +5% Crit | Trickster: +10% SPD in combat" -ForegroundColor White
    Write-Host "    Berserker: +20% ATK wenn HP unter 50%" -ForegroundColor White
    Write-Host "    Healer: +30% Heal-Effektivitaet | Tank: +15% DEF" -ForegroundColor White
    Write-Host "    Speedster: +15% SPD (permanent)" -ForegroundColor White
    Write-Host ""
    Write-Host "  DAMAGE FORMULA" -ForegroundColor Cyan
    Write-Host "  Base = ATK * MovePower / 10" -ForegroundColor DarkGray
    Write-Host "  Mitigated = Base * (100 / (100 + DEF))" -ForegroundColor DarkGray
    Write-Host "  Final = Mitigated * ElementMod * BuffMod" -ForegroundColor DarkGray
    Write-Host "  DEF gibt abnehmende Rendite - je mehr DEF, desto weniger pro Punkt." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  CRITICAL HITS" -ForegroundColor Cyan
    Write-Host "  Base Crit: 10% | Chips koennen Crit erhoehen." -ForegroundColor DarkGray
    Write-Host "  Crit Damage: 1.5x | Accessories geben Crit Resist." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  LEVEL UP" -ForegroundColor Cyan
    Write-Host "  Level-Up bei XP >= NextXP. NextXP = Level * 50." -ForegroundColor DarkGray
    Write-Host "  Neue Attacken bei Lv 2,3,4,5,6,7,8,9,10,12." -ForegroundColor DarkGray
    Write-Host "  Skill-Lernchance: 25% pro Level-Up (max 4 Skills)." -ForegroundColor DarkGray
    Write-Host "  Evolution bei Lv.10 (Name +20 HP, +5 ATK, +3 DEF/SPD)." -ForegroundColor DarkGray
    Write-Host "  Tier 2 Evolution bei Lv.20 (Name +30 HP, +8 ATK, +5 DEF/SPD)." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  BOSS KAEMPFE" -ForegroundColor Cyan
    Write-Host "  Jeder 5. Sieg ist ein Boss-Kampf. Boss hat +30% Stats." -ForegroundColor DarkGray
    Write-Host "  Boss Phase 2 bei 50% HP: ATK +30%, SPD +20%." -ForegroundColor DarkGray
    Write-Host "  Bosse haben Special-Attacken mit 25-35% Chance." -ForegroundColor DarkGray
    Write-Host "  Boss-Sieg: +50 XP, +2 Potions, +Gold." -ForegroundColor DarkGray
    Write-Host "  Boss Bestiary: [B] im Battlepet-Menue zeigt alle besiegten Bosse." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  RAID DUNGEON" -ForegroundColor Magenta
    Write-Host "  [R] im Battlepet-Menue. 1x pro Tag. 3 Phasen." -ForegroundColor DarkGray
    Write-Host "  Phase 1: Cyber Golem | Phase 2: Net Titan | Phase 3: Omega Core" -ForegroundColor DarkGray
    Write-Host "  Belohnungen: 1/3/10 Raid Tokens. Best Phase wird gespeichert." -ForegroundColor DarkGray
    Write-Host "  Companion Sync-Level gibt Boni: HP/ATK/Heal/Crit." -ForegroundColor DarkGray
    Write-Host "  Raid-Shop: Exklusive Ausruestung fuer Tokens." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  PVP ARENA" -ForegroundColor Yellow
    Write-Host "  [4] im Battlepet-Menue. Turn-based, 10 Runden max." -ForegroundColor DarkGray
    Write-Host "  Ranks: Bronze -> Silver -> Gold -> Platinum -> Diamond -> Master" -ForegroundColor DarkGray
    Write-Host "  Rank-Up Belohnungen: Gold + exklusiver PvP-Titel" -ForegroundColor DarkGray
    Write-Host "  Silver: 50G | Gold: 100G | Platinum: 200G | Diamond: 350G | Master: 500G" -ForegroundColor White
    Wait-Enter
}

} catch {
    Write-Host "[handbook-combat] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
