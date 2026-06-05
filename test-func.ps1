function Start-PetFight {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { New-Pet; return }
    # Passive HP regeneration between fights (10% per hour, max 100%)
    $now = Get-Date
    if ($p.LastFightTime) {
        $hours = ($now - [datetime]$p.LastFightTime).TotalHours
        $regen = [math]::Min($p.MaxHP, [math]::Round($p.MaxHP * 0.1 * $hours))
        $p.HP = [math]::Min($p.MaxHP, $p.HP + $regen)
    }
    $p.LastFightTime = $now.ToString("yyyy-MM-dd HH:mm")
    $stats = Get-EffectiveStats $p $cp
    $p.HP = [math]::Min($p.HP, $stats.MaxHP)
    $isBoss = ($p.Wins -gt 0 -and $p.Wins % 5 -eq 0)
    $et = if ($isBoss) { @{ Name = "BOSS_OMEGA"; Type = "VIRUS"; HP = 150; ATK = 20; DEF = 15; SPD = 10 } } else { ($script:BPEnemies | Get-Random) }
    $sc = 1 + ($p.Level - 1) * 0.2
    $enemy = @{ Name = $et.Name; Type = $et.Type; HP = [math]::Round($et.HP * $sc); MaxHP = [math]::Round($et.HP * $sc); ATK = [math]::Round($et.ATK * $sc); DEF = [math]::Round($et.DEF * $sc); SPD = [math]::Round($et.SPD * $sc); Phase2Triggered = $false }
    # Companion combat ability
    if ($cp -and (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) {
        Use-CompanionCombatAbility $cp $p $stats $enemy
    }
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $playerScore = 0; $rivalScore = 0
    $insightLevel = if ($cp) { $cp.Skills.StrategyInsight } else { 0 }
    $insightChance = [math]::Min(50, $insightLevel * 5)
    for ($round = 1; $round -le 3; $round++) {
        try { Clear-Host } catch {}
        Show-PetFrame "KAMPF — Runde $round/3" -Double | Out-Null
        Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($stats.MaxHP) | [$($enemy.Name)] HP: $($enemy.HP)/$($enemy.MaxHP)" -ForegroundColor White
        if ($isBoss -and $enemy.HP -le ($enemy.MaxHP / 2) -and -not $enemy.Phase2Triggered) {
            $enemy.Phase2Triggered = $true
            $enemy.ATK = [math]::Round($enemy.ATK * 1.3)
            $enemy.SPD = [math]::Round($enemy.SPD * 1.2)
            Write-Host "  !!! BOSS PHASE 2 !!! ATK +30% | SPD +20%" -ForegroundColor Magenta
        }
        Write-Host "`n  [A]ngriff [V]erteidigung [S]pecial" -ForegroundColor White
        if ($insightChance -gt 0 -and (Get-Random -Maximum 100) -lt $insightChance) {
            Write-Host "  [INSIGHT] Gegner plant: $($moves[$rm])" -ForegroundColor Cyan
        }
        $pm = Read-Choice "Zug" '^[AVS]$'
        # If VERA used ability, reveal first round for free
        if ($cp -and $cp.Name -eq "VERA" -and $round -eq 1) {
            Write-Host "  [VERA PREDICT] Gegner wird waehlen: $($moves[$rm])" -ForegroundColor Cyan
        }
        $rm = @("A","V","S") | Get-Random
        Write-Host "`n  Du: $($moves[$pm]) | Gegner: $($moves[$rm])" -ForegroundColor DarkGray
        # Element modifier
        $playerMod = Get-ElementModifier $p.Type $enemy.Type
        $enemyMod = Get-ElementModifier $enemy.Type $p.Type
        if ($playerMod -gt 1.0) { Write-Host "  Typ-Vorteil!" -ForegroundColor Green }
        if ($playerMod -lt 1.0) { Write-Host "  Typ-Nachteil!" -ForegroundColor Red }
        if ($pm -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 1.5 * $playerMod) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg
            $eDmg = [math]::Max(1, [math]::Round(($enemy.ATK * $enemyMod) * (100 / (100 + $stats.DEF))))
            $p.HP -= $eDmg
            Write-Host "  Gleichstand! Beide treffen! -$dmg HP | -$eDmg HP!" -ForegroundColor Yellow
        } elseif ($beats[$pm] -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 2 * $playerMod) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $playerScore++
            Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Green
        } else {
            $eDmg = [math]::Max(1, [math]::Round(($enemy.ATK * $enemyMod) * (100 / (100 + $stats.DEF))))
            $p.HP -= $eDmg; $rivalScore++
            Write-Host "  Treffer erhalten! -$eDmg HP!" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 600
    }
    try { Clear-Host } catch {}
    if ($playerScore -gt $rivalScore) {
        $xp = if ($isBoss) { 50 } else { 20 + ($p.Level * 5) }
        $gold = Get-Random -Minimum 5 -Maximum 16
        if ($isBoss) { $gold += 25 }
        $p.Wins++; $p.XP += $xp; $p.HP = [math]::Min($p.HP + [math]::Round($stats.MaxHP * 0.2), $stats.MaxHP)
        $pet.Economy.Gold += $gold
        # Sync level up
        if ($cp) {
            $cp.Sync++
            if ($cp.Sync -in @(10,25,50,100)) {
                Write-Host "`n  SYNC LEVEL UP! $($cp.Sync) erreicht!" -ForegroundColor Magenta
            }
        }
        Write-Host "`n  SIEG! +$xp XP | +$gold G" -ForegroundColor Green
        Invoke-PetLevelUpCheck $p
        if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "fight_win") -Fast }
        Add-PetXP ($xp / 2) "Fight Win"
        Check-QuestProgress "fight"
    } elseif ($playerScore -lt $rivalScore) {
        $p.Losses++; $p.HP = [math]::Round($stats.MaxHP * 0.5)
        Write-Host "`n  NIEDERLAGE..." -ForegroundColor Red
        if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "fight_loss") -Fast }
        Add-PetXP 5 "Fight Loss"
    } else {
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        Add-PetXP 8 "Fight Draw"
    }
    $p.FoodBuffs = @(); Save-PetState $pet
    Wait-Enter
}
