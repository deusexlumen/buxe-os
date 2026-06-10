# BUXE_OS v24.3 -- ROGUE-LIKE DUNGEON (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function rogue {
    Load-State
    $stats = Get-StrategyStats "Rogue"
    
    Reset-RenderBuffer
    $w = 56; $h = 20
    
    # Pre-game
    $pre = New-Scene $w $h
    Add-SceneFrame $pre 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
    Add-SceneText $pre 4 2 "Ueberlebe so viele Etagen wie moeglich!" 'Cyan'
    Add-SceneText $pre 4 4 "[ENTER] Starten" 'Green'
    Add-SceneText $pre 4 5 "[Q] Quit" 'DarkGray'
    Show-Scene $pre -Force
    
    $act = Read-GameChoice "" "^[Q]$"
    if ($act -eq 'Q') { return }
    
    $entryFee = 50
    $br = Get-Bankroll
    if ($br -lt $entryFee) { Write-Host "`n  Nicht genug Gold! ($entryFee G)" -ForegroundColor Red; Wait-Enter; return }
    Spend-Gold $entryFee "Rogue Entry"
    
    $hero = @{ Name = "Hero"; HP = 100; MaxHP = 100; ATK = 15; DEF = 5; SPD = 10; Potions = 3; Level = 1; XP = 0 }
    $floor = 0; $maxFloor = 20
    
    while ($floor -lt $maxFloor -and $hero.HP -gt 0) {
        $floor++
        $room = @("Kampf", "Schatz", "Haendler", "Boss") | Get-Random
        
        switch ($room) {
            "Kampf" {
                $enemy = @{
                    Name = @("Goblin","Skeleton","Spider","Zombie","Ghost") | Get-Random
                    HP = 20 + $floor * 5; MaxHP = 20 + $floor * 5
                    ATK = 8 + $floor * 2; DEF = 2 + $floor; SPD = 5 + $floor
                }
                
                while ($hero.HP -gt 0 -and $enemy.HP -gt 0) {
                    $cs = New-Scene $w $h
                    Add-SceneFrame $cs 0 0 $w $h "ROGUE DUNGEON -- Etage $floor" 'Cyan' -Double
                    
                    # Hero stats
                    Add-SceneText $cs 4 2 "Hero Lv.$($hero.Level)" 'Cyan'
                    Add-SceneBar $cs 4 3 20 $hero.HP $hero.MaxHP 'Green' 'DarkGray'
                    Add-SceneText $cs 26 3 "$($hero.HP)/$($hero.MaxHP) HP" 'White'
                    Add-SceneText $cs 4 4 "ATK: $($hero.ATK) | DEF: $($hero.DEF) | Potions: $($hero.Potions)" 'DarkGray'
                    
                    # Enemy stats
                    Add-SceneText $cs 4 6 "$($enemy.Name)" 'Red'
                    Add-SceneBar $cs 4 7 20 $enemy.HP $enemy.MaxHP 'Red' 'DarkGray'
                    Add-SceneText $cs 26 7 "$($enemy.HP)/$($enemy.MaxHP) HP" 'White'
                    
                    Add-SceneText $cs 4 10 "[1] Angriff   [2] Heiltrank   [3] Verteidigen" 'White'
                    Add-SceneText $cs 4 11 "[Q] Quit" 'DarkGray'
                    Show-Scene $cs -Force
                    
                    $a = Read-GameChoice "" "^[123Q]$"
                    if ($a -eq 'Q') { return }
                    
                    if ($a -eq '2' -and $hero.Potions -gt 0) {
                        $hero.Potions--; $heal = 30
                        $hero.HP = [math]::Min($hero.MaxHP, $hero.HP + $heal)
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "+$heal HP!" 'Green'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 400
                    } elseif ($a -eq '3') {
                        $hero.TempDEF = 5
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "Du verteidigst dich!" 'Blue'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 400
                    } else {
                        $dmg = [math]::Max(1, [math]::Round($hero.ATK - ($enemy.DEF * 0.3)))
                        $enemy.HP -= $dmg
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "Du machst $dmg Schaden!" 'Green'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 400
                    }
                    
                    if ($enemy.HP -gt 0) {
                        $edmg = [math]::Max(1, [math]::Round($enemy.ATK - ($hero.DEF * 0.3) - ($hero.TempDEF)))
                        $hero.HP -= $edmg
                        $hero.TempDEF = 0
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "$($enemy.Name) macht $edmg Schaden!" 'Red'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 400
                    }
                }
                
                if ($hero.HP -gt 0) {
                    $reward = $floor * 10 + 20
                    Add-Gold $reward "Rogue"
                    $hero.XP += $floor * 5
                    $rs = New-Scene $w $h
                    Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                    Add-SceneText $rs 4 5 "Besiegt! +$reward G | +$($floor * 5) XP" 'Green'
                    Show-Scene $rs -Force
                    Start-Sleep -Milliseconds 500
                    
                    if ($hero.XP -ge $hero.Level * 50) {
                        $hero.XP -= $hero.Level * 50; $hero.Level++
                        $hero.MaxHP += 10; $hero.HP += 10; $hero.ATK += 3; $hero.DEF += 2
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "LEVEL UP! Lv.$($hero.Level)" 'Magenta'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 500
                    }
                }
            }
            "Schatz" {
                $tGold = Get-Random -Minimum 10 -Maximum 51
                Add-Gold $tGold "Rogue"
                $hero.Potions = [math]::Min(5, $hero.Potions + 1)
                $rs = New-Scene $w $h
                Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                Add-SceneText $rs 4 5 "Schatz gefunden!" 'Yellow'
                Add-SceneText $rs 4 6 "+$tGold G | +1 Trank" 'Green'
                Show-Scene $rs -Force
                Start-Sleep -Milliseconds 600
            }
            "Haendler" {
                while ($true) {
                    $hs = New-Scene $w $h
                    Add-SceneFrame $hs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                    Add-SceneText $hs 4 2 "Haendler" 'Cyan'
                    Add-SceneText $hs 4 4 "[1] HP +20    (30G)" 'Green'
                    Add-SceneText $hs 4 5 "[2] ATK +3    (50G)" 'Red'
                    Add-SceneText $hs 4 6 "[3] Potion    (20G)" 'Yellow'
                    Add-SceneText $hs 4 7 "Gold: $(Get-Bankroll) G" 'DarkGray'
                    Add-SceneText $hs 4 9 "[Q] Weiter" 'DarkGray'
                    Show-Scene $hs -Force
                    
                    $c = Read-GameChoice "" "^[123Q]$"
                    if ($c -eq 'Q') { break }
                    if ($c -eq '1' -and (Get-Bankroll) -ge 30) { 
                        Spend-Gold 30 "Shop"; $hero.MaxHP += 20; $hero.HP += 20 
                    } elseif ($c -eq '2' -and (Get-Bankroll) -ge 50) { 
                        Spend-Gold 50 "Shop"; $hero.ATK += 3 
                    } elseif ($c -eq '3' -and (Get-Bankroll) -ge 20) { 
                        Spend-Gold 20 "Shop"; $hero.Potions++ 
                    }
                }
            }
            "Boss" {
                $boss = @{ Name = "ETAGE $floor BOSS"; HP = 50 + $floor * 10; MaxHP = 50 + $floor * 10; ATK = 12 + $floor * 3; DEF = 5 + $floor; SPD = 8 + $floor }
                
                while ($hero.HP -gt 0 -and $boss.HP -gt 0) {
                    $bs = New-Scene $w $h
                    Add-SceneFrame $bs 0 0 $w $h "ROGUE DUNGEON -- BOSS" 'Red' -Double
                    
                    Add-SceneText $bs 4 2 "Hero Lv.$($hero.Level)" 'Cyan'
                    Add-SceneBar $bs 4 3 20 $hero.HP $hero.MaxHP 'Green' 'DarkGray'
                    Add-SceneText $bs 26 3 "$($hero.HP)/$($hero.MaxHP)" 'White'
                    
                    Add-SceneText $bs 4 6 "$($boss.Name)" 'Magenta'
                    Add-SceneBar $bs 4 7 20 $boss.HP $boss.MaxHP 'Red' 'DarkGray'
                    Add-SceneText $bs 26 7 "$($boss.HP)/$($boss.MaxHP)" 'White'
                    
                    Add-SceneText $bs 4 10 "[1] Angriff   [2] Heiltrank" 'White'
                    Show-Scene $bs -Force
                    
                    $a = Read-GameChoice "" "^[12]$"
                    if ($a -eq '2' -and $hero.Potions -gt 0) { 
                        $hero.Potions--; $hero.HP = [math]::Min($hero.MaxHP, $hero.HP + 30)
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "+30 HP!" 'Green'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 400
                    } else { 
                        $dmg = [math]::Max(1, [math]::Round($hero.ATK - $boss.DEF * 0.3))
                        $boss.HP -= $dmg
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "$dmg Schaden!" 'Green'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 400
                    }
                    
                    if ($boss.HP -gt 0) { 
                        $edmg = [math]::Max(1, [math]::Round($boss.ATK - $hero.DEF * 0.3))
                        $hero.HP -= $edmg
                        $rs = New-Scene $w $h
                        Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                        Add-SceneText $rs 4 5 "Boss macht $edmg Schaden!" 'Red'
                        Show-Scene $rs -Force
                        Start-Sleep -Milliseconds 400
                    }
                }
                
                if ($hero.HP -gt 0) {
                    $breward = $floor * 50
                    Add-Gold $breward "Boss"
                    $rs = New-Scene $w $h
                    Add-SceneFrame $rs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
                    Add-SceneText $rs 4 5 "BOSS BESIEGT! +$breward G" 'Magenta'
                    Show-Scene $rs -Force
                    Start-Sleep -Milliseconds 600
                }
            }
        }
    }
    
    if ($floor -ge $maxFloor) {
        $fs = New-Scene $w $h
        Add-SceneFrame $fs 0 0 $w $h "ROGUE DUNGEON" 'Magenta' -Double
        Add-SceneText $fs 4 5 "DU HAST DEN DUNGEON GEKLAERT!" 'Magenta'
        Add-SceneText $fs 4 6 "Etage $floor" 'Green'
        
        $insightMod = Get-StrategyInsightModifier
        $clearReward = [math]::Floor(500 * $insightMod)
        $bonus = $clearReward - 500
        Add-Gold $clearReward "Rogue Clear"
        Add-SceneText $fs 4 8 "+$clearReward G!" 'Green'
        if ($bonus -gt 0) { Add-SceneText $fs 4 9 "(+$bonus Strategy Insight)" 'Magenta' }
        Show-Scene $fs -Force
        Unlock-Achievement "Dungeon Master"
    } elseif ($hero.HP -le 0) {
        $fs = New-Scene $w $h
        Add-SceneFrame $fs 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
        Add-SceneText $fs 4 5 "Gestorben auf Etage $floor" 'Red'
        Show-Scene $fs -Force
    }
    
    # StrategyInsight skill progression
    $cp = Load-CompanionState
    if ($cp -and $cp.Skills -and $cp.Skills.StrategyInsight -lt 10) {
        $cp.Skills.StrategyInsightRuns = if ($cp.Skills.StrategyInsightRuns) { $cp.Skills.StrategyInsightRuns + 1 } else { 1 }
        if ($cp.Skills.StrategyInsightRuns -ge 5) {
            $cp.Skills.StrategyInsight++
            $cp.Skills.StrategyInsightRuns = 0
            $ss = New-Scene $w $h
            Add-SceneFrame $ss 0 0 $w $h "ROGUE DUNGEON" 'Cyan' -Double
            Add-SceneText $ss 4 5 "[SKILL UP] Strategy Insight Level $($cp.Skills.StrategyInsight)!" 'Magenta'
            Show-Scene $ss -Force
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
