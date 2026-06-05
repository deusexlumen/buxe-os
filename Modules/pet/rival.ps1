# BUXE_OS v24.2 — PET RIVAL v2.0

try {

$script:PetRivalNames = @("GLITCH","VORTEX","SHADE","REAPER","PHANTOM")

function Check-PetRival {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp -or $cp.Mood -in @("Sad","Angry")) { return $false }
    if (-not $pet.Meta.RivalActive) { $pet.Meta.RivalActive = $false }
    if ($pet.Meta.RivalActive) { return $true }
    if ((Get-Random -Maximum 5) -eq 0) {
        $pet.Meta.RivalName = ($script:PetRivalNames | Get-Random) + "_" + (Get-Random -Maximum 999)
        $pet.Meta.RivalActive = $true
        Save-PetState $pet
        return $true
    }
    return $false
}

function Invoke-PetRivalBattle {
    $pet = Get-PetState
    $cp = $pet.Companion
    $p = $pet.Pet
    $rn = $pet.Meta.RivalName
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    try { Clear-Host } catch {}
    Show-PetFrame "RIVAL ENCOUNTER" -Double | Out-Null
    Write-Host "`n  Ein Rivale namens $rn fordert dich heraus!" -ForegroundColor Red
    # Generate rival stats based on pet level
    $rLvl = [math]::Max(1, $p.Level + (Get-Random -Minimum -2 -Maximum 3))
    $rStats = @{
        HP = [math]::Round((80 + $rLvl * 15) * (1 + ($rLvl - 1) * 0.2))
        ATK = [math]::Round((12 + $rLvl * 3) * (1 + ($rLvl - 1) * 0.2))
        DEF = [math]::Round((7 + $rLvl * 2) * (1 + ($rLvl - 1) * 0.2))
        SPD = [math]::Round((10 + $rLvl * 2) * (1 + ($rLvl - 1) * 0.2))
    }
    $rStats.MaxHP = $rStats.HP
    $stats = Get-EffectiveStats $p
    $p.HP = $stats.MaxHP
    Write-Host "  Rivale Lv.$rLvl | HP:$($rStats.MaxHP) ATK:$($rStats.ATK) DEF:$($rStats.DEF) SPD:$($rStats.SPD)" -ForegroundColor DarkGray
    Write-Host "`n  3 Runden. A > V > S > A" -ForegroundColor DarkGray
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $ps = 0; $rs = 0
    for ($r = 1; $r -le 3; $r++) {
        try { Clear-Host } catch {}
        Show-PetFrame "RIVAL — Runde $r/3" -Double | Out-Null
        Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($stats.MaxHP) | [$rn] HP: $($rStats.HP)/$($rStats.MaxHP)" -ForegroundColor White
        Write-Host "`n  [A]ngriff [V]erteidigung [S]pecial" -ForegroundColor White
        $pm = Read-Choice "Zug [A/V/S]" '^[AVS]$'
        $rm = @("A","V","S") | Get-Random
        Write-Host "`n  Du: $($moves[$pm]) | Rival: $($moves[$rm])" -ForegroundColor DarkGray
        if ($pm -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 1.5) * (100 / (100 + $rStats.DEF))))
            $rStats.HP -= $dmg; $p.HP -= [math]::Max(1, [math]::Round($rStats.ATK * (100 / (100 + $stats.DEF))))
            Write-Host "  Gleichstand! Beide treffen! -$dmg HP" -ForegroundColor Yellow
        } elseif ($beats[$pm] -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 2) * (100 / (100 + $rStats.DEF))))
            $rStats.HP -= $dmg; $ps++
            Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Green
        } else {
            $dmg = [math]::Max(1, [math]::Round($rStats.ATK * (100 / (100 + $stats.DEF))))
            $p.HP -= $dmg; $rs++
            Write-Host "  Treffer erhalten! -$dmg HP!" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 500
    }
    try { Clear-Host } catch {}
    if ($ps -gt $rs) {
        $gold = Get-Random -Minimum 20 -Maximum 41
        $pet.Economy.Gold += $gold
        $pet.Meta.RivalActive = $false; $cp.Bond = [math]::Min(100, $cp.Bond + 5); $cp.Mood = "Excited"
        if (-not $pet.Meta.RivalWins) { $pet.Meta.RivalWins = 0 }
        $pet.Meta.RivalWins++
        Write-Host "`n  SIEG! +$gold G | Rival-Siege: $($pet.Meta.RivalWins)" -ForegroundColor Green
        if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "fight_win") -Fast }
        Add-PetXP 20 "Rival Win"
    } elseif ($ps -lt $rs) {
        $pet.Meta.RivalActive = $false; $cp.Mood = "Sad"
        Write-Host "`n  NIEDERLAGE..." -ForegroundColor Red
        if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "fight_loss") -Fast }
        Add-PetXP 5 "Rival Loss"
    } else {
        $pet.Meta.RivalActive = $false
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        Add-PetXP 10 "Rival Draw"
    }
    Save-PetState $pet
    Wait-Enter
}

} catch {
    Write-Host "[pet/rival] CRITICAL ERROR: $_" -ForegroundColor Red
}
