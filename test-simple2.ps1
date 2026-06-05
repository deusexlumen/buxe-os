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
    }
}
