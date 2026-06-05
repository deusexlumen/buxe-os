function Start-PetFight {
    $pet = @{ Pet = @{ Name = "TEST"; HP = 100; MaxHP = 100; Level = 1; Wins = 0; XP = 0; NextXP = 100; FoodBuffs = @(); LastFightTime = $null }; Companion = $null; Economy = @{ Gold = 0 } }
    $p = $pet.Pet
    $cp = $pet.Companion
    $stats = @{ MaxHP = 100; ATK = 10; DEF = 10; SPD = 10 }
    $isBoss = $false
    $playerScore = 1
    $rivalScore = 0
    try { Clear-Host } catch {}
    if ($playerScore -gt $rivalScore) {
        $xp = if ($isBoss) { 50 } else { 20 + ($p.Level * 5) }
        $gold = Get-Random -Minimum 5 -Maximum 16
        if ($isBoss) { $gold += 25 }
        $p.Wins++; $p.XP += $xp; $p.HP = [math]::Min($p.HP + [math]::Round($stats.MaxHP * 0.2), $stats.MaxHP)
        $pet.Economy.Gold += $gold
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

function Invoke-PetLevelUpCheck($p) {
    if ($p.XP -ge $p.NextXP) {
        $p.Level++; $p.XP -= $p.NextXP; $p.NextXP = [math]::Round($p.NextXP * 1.5)
        $p.MaxHP += 10; $p.ATK += 2; $p.DEF += 1; $p.SPD += 1
        $p.HP = $p.MaxHP
        Write-Host "`n  LEVEL UP! Lv.$($p.Level)! Stats +1!" -ForegroundColor Magenta
        $learn = @{ 2 = "Debug Patch"; 3 = "Plasma Lance"; 4 = "Ice Spike"; 5 = "System Purge"; 6 = "Water Cannon"; 7 = "Overclock"; 8 = "Shadow Claw"; 9 = "Firewall"; 10 = "Zero-Day" }
        if ($learn.ContainsKey($p.Level)) {
            $p.Attacks += $learn[$p.Level]
            Write-Host "  Neue Attacke gelernt: $($learn[$p.Level])!" -ForegroundColor Yellow
        }
    }
}
