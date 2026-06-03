# BUXE_OS v24.0 -- ROGUE-LIKE DUNGEON

try {

function rogue {
    Load-State
    $stats = Get-StrategyStats "Rogue"
    
    Clear-Screen "ROGUE DUNGEON"
    Show-Bankroll
    Write-Host "`n  Ueberlebe so viele Etagen wie moeglich!" -ForegroundColor Cyan
    Write-Host "  [Enter] zum Starten..." -ForegroundColor DarkGray
    Read-Host
    
    $hero = @{ Name = "Hero"; HP = 100; MaxHP = 100; ATK = 15; DEF = 5; SPD = 10; Potions = 3; Level = 1; XP = 0 }
    $floor = 0; $maxFloor = 20
    
    while ($floor -lt $maxFloor -and $hero.HP -gt 0) {
        $floor++
        Clear-Screen "ROGUE DUNGEON -- Etage $floor"
        Write-Host "  HP: $($hero.HP)/$($hero.MaxHP) | ATK: $($hero.ATK) | DEF: $($hero.DEF) | Potions: $($hero.Potions)" -ForegroundColor Cyan
        
        $room = @("Kampf", "Schatz", "Haendler", "Boss") | Get-Random
        switch ($room) {
            "Kampf" {
                $enemy = @{
                    Name = @("Goblin","Skeleton","Spider","Zombie","Ghost") | Get-Random
                    HP = 20 + $floor * 5; MaxHP = 20 + $floor * 5
                    ATK = 8 + $floor * 2; DEF = 2 + $floor; SPD = 5 + $floor
                }
                Write-Host "`n  Ein $($enemy.Name) greift an!" -ForegroundColor Red
                
                while ($hero.HP -gt 0 -and $enemy.HP -gt 0) {
                    Write-Host "`n  [1] Angriff [2] Heiltrank [3] Verteidigen" -ForegroundColor White
                    $a = Read-Host "  Aktion"
                    if ($a -eq '2' -and $hero.Potions -gt 0) {
                        $hero.Potions--; $heal = 30
                        $hero.HP = [math]::Min($hero.MaxHP, $hero.HP + $heal)
                        Write-Host "  +$heal HP!" -ForegroundColor Green
                    } elseif ($a -eq '3') {
                        Write-Host "  Du verteidigst dich!" -ForegroundColor Blue
                        $hero.TempDEF = 5
                    } else {
                        $dmg = [math]::Max(1, [math]::Round($hero.ATK - ($enemy.DEF * 0.3)))
                        $enemy.HP -= $dmg
                        Write-Host "  Du machst $dmg Schaden!" -ForegroundColor Green
                    }
                    if ($enemy.HP -gt 0) {
                        $edmg = [math]::Max(1, [math]::Round($enemy.ATK - ($hero.DEF * 0.3) - ($hero.TempDEF)))
                        $hero.HP -= $edmg
                        Write-Host "  $($enemy.Name) macht $edmg Schaden!" -ForegroundColor Red
                        $hero.TempDEF = 0
                    }
                }
                if ($hero.HP -gt 0) {
                    $reward = $floor * 10 + 20
                    Add-Gold $reward "Rogue"
                    $hero.XP += $floor * 5
                    Write-Host "`n  Besiegt! +$reward G | +$($floor * 5) XP" -ForegroundColor Green
                    if ($hero.XP -ge $hero.Level * 50) {
                        $hero.XP -= $hero.Level * 50; $hero.Level++
                        $hero.MaxHP += 10; $hero.ATK += 3; $hero.DEF += 2
                        Write-Host "  LEVEL UP! Lv.$($hero.Level)" -ForegroundColor Magenta
                    }
                }
            }
            "Schatz" {
                $gold = Get-Random -Minimum 10 -Maximum 51
                Add-Gold $gold "Rogue"
                $hero.Potions = [math]::Min(5, $hero.Potions + 1)
                Write-Host "`n  Schatz gefunden! +$gold G | +1 Trank" -ForegroundColor Yellow
            }
            "Haendler" {
                Write-Host "`n  Haendler: HP +20 (30G) | ATK +3 (50G) | Potion (20G) | [Q] Weg" -ForegroundColor Cyan
                $c = Read-Host "  Kauf"
                if ($c -eq '1' -and (Get-Bankroll) -ge 30) { Spend-Gold 30 "Shop"; $hero.MaxHP += 20; $hero.HP += 20 }
                elseif ($c -eq '2' -and (Get-Bankroll) -ge 50) { Spend-Gold 50 "Shop"; $hero.ATK += 3 }
                elseif ($c -eq '3' -and (Get-Bankroll) -ge 20) { Spend-Gold 20 "Shop"; $hero.Potions++ }
            }
            "Boss" {
                $boss = @{ Name = "ETAGE $floor BOSS"; HP = 50 + $floor * 10; ATK = 12 + $floor * 3; DEF = 5 + $floor; SPD = 8 + $floor }
                Write-Host "`n  BOSS KAMPF: $($boss.Name)!" -ForegroundColor Magenta -BackgroundColor DarkRed
                while ($hero.HP -gt 0 -and $boss.HP -gt 0) {
                    Write-Host "`n  [1] Angriff [2] Heiltrank" -ForegroundColor White
                    $a = Read-Host "  Aktion"
                    if ($a -eq '2' -and $hero.Potions -gt 0) { $hero.Potions--; $hero.HP = [math]::Min($hero.MaxHP, $hero.HP + 30); Write-Host "  +30 HP!" -ForegroundColor Green }
                    else { $dmg = [math]::Max(1, [math]::Round($hero.ATK - $boss.DEF * 0.3)); $boss.HP -= $dmg; Write-Host "  $dmg Schaden!" -ForegroundColor Green }
                    if ($boss.HP -gt 0) { $edmg = [math]::Max(1, [math]::Round($boss.ATK - $hero.DEF * 0.3)); $hero.HP -= $edmg; Write-Host "  Boss macht $edmg Schaden!" -ForegroundColor Red }
                }
                if ($hero.HP -gt 0) {
                    $breward = $floor * 50
                    Add-Gold $breward "Boss"
                    Write-Host "`n  BOSS BESIEGT! +$breward G" -ForegroundColor Magenta
                }
            }
        }
        Start-Sleep -Milliseconds 600
    }
    
    if ($floor -ge $maxFloor) {
        Write-Host "`n  DU HAST DEN DUNGEON GEKLAERT! Etage $floor" -ForegroundColor Magenta
        $insightMod = Get-StrategyInsightModifier
        $clearReward = [math]::Floor(500 * $insightMod)
        $bonus = $clearReward - 500
        Add-Gold $clearReward "Rogue Clear"
        if ($bonus -gt 0) { Write-Host "  (+$bonus Strategy Insight)" -ForegroundColor Magenta }
        Unlock-Achievement "Dungeon Master"
    } elseif ($hero.HP -le 0) {
        Write-Host "`n  Gestorben auf Etage $floor" -ForegroundColor Red
    }
    
    # StrategyInsight skill progression
    $cp = Load-CompanionState
    if ($cp -and $cp.Skills -and $cp.Skills.StrategyInsight -lt 10) {
        $cp.Skills.StrategyInsightRuns = if ($cp.Skills.StrategyInsightRuns) { $cp.Skills.StrategyInsightRuns + 1 } else { 1 }
        if ($cp.Skills.StrategyInsightRuns -ge 5) {
            $cp.Skills.StrategyInsight++
            $cp.Skills.StrategyInsightRuns = 0
            Write-Host "  [SKILL UP] Strategy Insight ist jetzt Level $($cp.Skills.StrategyInsight)!" -ForegroundColor Magenta
            Save-CompanionState $cp
        }
    }
    
    $stats.Runs++; if ($floor -gt $stats.BestFloor) { $stats.BestFloor = $floor }
    Set-StrategyStats "Rogue" $stats
    Wait-Enter
}

} catch {
    Write-Host "[strategy-rogue] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
