function Start-PetFight {
    $pet = @{ Pet = @{ Name = "TEST"; HP = 100; MaxHP = 100; Level = 1; Wins = 0; XP = 0; NextXP = 100; FoodBuffs = @(); LastFightTime = $null }; Companion = $null; Economy = @{ Gold = 0 } }
    $p = $pet.Pet
    $cp = $pet.Companion
    $stats = @{ MaxHP = 100; ATK = 10; DEF = 10; SPD = 10 }
    $isBoss = $false
    $et = @{ Name = "FOE"; Type = "FIRE"; HP = 100; ATK = 10; DEF = 10; SPD = 10 }
    $sc = 1
    $enemy = @{ Name = $et.Name; Type = $et.Type; HP = [math]::Round($et.HP * $sc); MaxHP = [math]::Round($et.HP * $sc); ATK = [math]::Round($et.ATK * $sc); DEF = [math]::Round($et.DEF * $sc); SPD = [math]::Round($et.SPD * $sc); Phase2Triggered = $false }
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $playerScore = 0; $rivalScore = 0
    $insightLevel = 0
    $insightChance = [math]::Min(50, $insightLevel * 5)
    for ($round = 1; $round -le 3; $round++) {
        try { Clear-Host } catch {}
        Show-PetFrame "KAMPF - Runde $round/3" -Double | Out-Null
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
        $pm = "A"
        # If VERA used ability, reveal first round for free
        if ($cp -and $cp.Name -eq "VERA" -and $round -eq 1) {
            Write-Host "  [VERA PREDICT] Gegner wird waehlen: $($moves[$rm])" -ForegroundColor Cyan
        }
        $rm = @("A","V","S") | Get-Random
        Write-Host "`n  Du: $($moves[$pm]) | Gegner: $($moves[$rm])" -ForegroundColor DarkGray
        $playerMod = 1.0
        $enemyMod = 1.0
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
}
