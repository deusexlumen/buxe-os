# BUXE_OS v24.2 — PET COMBAT v2.0

try {

$script:BPStarters = @(
    @{ Name = "GLITCH_WOLF"; Type = "VIRUS"; HP = 100; ATK = 14; DEF = 7; SPD = 12; Color = "Magenta"; EvolveAt = 10 }
    @{ Name = "CYBER_RAPTOR"; Type = "ELEC"; HP = 80; ATK = 18; DEF = 5; SPD = 15; Color = "Cyan"; EvolveAt = 10 }
    @{ Name = "VOID_TURTLE"; Type = "DARK"; HP = 130; ATK = 10; DEF = 14; SPD = 6; Color = "DarkGray"; EvolveAt = 10 }
    @{ Name = "FLAME_FOX"; Type = "FIRE"; HP = 90; ATK = 16; DEF = 6; SPD = 13; Color = "Red"; EvolveAt = 10 }
    @{ Name = "FROST_BUNNY"; Type = "ICE"; HP = 75; ATK = 15; DEF = 5; SPD = 16; Color = "Blue"; EvolveAt = 10 }
)
$script:BPEnemies = @(
    @{ Name = "SPAM_BOT"; Type = "NORM"; HP = 70; ATK = 10; DEF = 6; SPD = 8 }
    @{ Name = "TROJAN_HORSE"; Type = "VIRUS"; HP = 95; ATK = 13; DEF = 9; SPD = 5 }
    @{ Name = "PHISHING_WORM"; Type = "DARK"; HP = 60; ATK = 11; DEF = 4; SPD = 14 }
    @{ Name = "DDOS_SWARM"; Type = "ELEC"; HP = 50; ATK = 15; DEF = 3; SPD = 18 }
    @{ Name = "FIREWALL_DRAGON"; Type = "FIRE"; HP = 100; ATK = 14; DEF = 10; SPD = 9 }
    @{ Name = "ICE_GOLEM"; Type = "ICE"; HP = 115; ATK = 11; DEF = 13; SPD = 4 }
    @{ Name = "HYDRA_WORM"; Type = "WATER"; HP = 80; ATK = 13; DEF = 7; SPD = 11 }
    @{ Name = "SHADOW_DEMON"; Type = "DARK"; HP = 90; ATK = 15; DEF = 8; SPD = 12 }
)

function New-Pet {
    Clear-Host
    Show-PetFrame "BATTLEPET INITIALISIERUNG" -Double | Out-Null
    Write-Host ""
    for ($i = 0; $i -lt $script:BPStarters.Count; $i++) {
        $s = $script:BPStarters[$i]
        Write-Host "  [$($i+1)] $($s.Name) [$($s.Type)] HP:$($s.HP) ATK:$($s.ATK) DEF:$($s.DEF) SPD:$($s.SPD)" -ForegroundColor $s.Color
    }
    $c = Read-Choice "Waehle" '^[1-5]$'
    $st = $script:BPStarters[[int]$c - 1]
    $pet = Get-PetState
    $pet.Pet = @{
        Name = $st.Name; Type = $st.Type; Level = 1; XP = 0; NextXP = 50
        HP = $st.HP; MaxHP = $st.HP; ATK = $st.ATK; DEF = $st.DEF; SPD = $st.SPD
        Color = $st.Color; Attacks = @("Neural Overload","Bit Crusher")
        Wins = 0; Losses = 0; Evolved = $false; Personality = "Balanced"
        Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }
        FoodBuffs = @()
    }
    Save-PetState $pet
    Write-Host "`n  $($st.Name) initialisiert." -ForegroundColor $st.Color
    Wait-Enter
}

function Get-EffectiveStats($p) {
    $eq = $p.Equipment
    $hp = 0; $atk = 0; $def = 0; $spd = 0
    if ($eq.Armor) { $atk += 3; $hp += 10 }
    if ($eq.Chip) { $atk += 3 }
    if ($eq.Accessory) { $spd += 3 }
    if ($p.Personality -eq "Aggressive") { $atk = [math]::Round($atk * 1.1) }
    if ($p.Personality -eq "Defensive") { $def = [math]::Round($def * 1.1) }
    if ($p.Personality -eq "Speedster") { $spd = [math]::Round($spd * 1.15) }
    $fMaxHP = $p.MaxHP + $hp; $fATK = $p.ATK + $atk; $fDEF = $p.DEF + $def; $fSPD = $p.SPD + $spd
    foreach ($buff in $p.FoodBuffs) {
        if ($buff.Stat -eq "MaxHP") { $fMaxHP += [math]::Round($fMaxHP * $buff.Value) }
        if ($buff.Stat -eq "ATK")   { $fATK += [math]::Round($fATK * $buff.Value) }
        if ($buff.Stat -eq "DEF")   { $fDEF += [math]::Round($fDEF * $buff.Value) }
        if ($buff.Stat -eq "SPD")   { $fSPD += [math]::Round($fSPD * $buff.Value) }
        if ($buff.Stat -eq "ALL")   { $fMaxHP += [math]::Round($fMaxHP * $buff.Value); $fATK += [math]::Round($fATK * $buff.Value); $fDEF += [math]::Round($fDEF * $buff.Value); $fSPD += [math]::Round($fSPD * $buff.Value) }
    }
    return @{ MaxHP = $fMaxHP; ATK = $fATK; DEF = $fDEF; SPD = $fSPD }
}

function Start-PetFight {
    $pet = Get-PetState
    $p = $pet.Pet
    if (-not $p) { New-Pet; return }
    $stats = Get-EffectiveStats $p
    $p.HP = [math]::Min($p.HP, $stats.MaxHP)
    $isBoss = ($p.Wins -gt 0 -and $p.Wins % 5 -eq 0)
    $et = if ($isBoss) { @{ Name = "BOSS_OMEGA"; Type = "VIRUS"; HP = 150; ATK = 20; DEF = 15; SPD = 10 } } else { ($script:BPEnemies | Get-Random) }
    $sc = 1 + ($p.Level - 1) * 0.2
    $enemy = @{ Name = $et.Name; Type = $et.Type; HP = [math]::Round($et.HP * $sc); MaxHP = [math]::Round($et.HP * $sc); ATK = [math]::Round($et.ATK * $sc); DEF = [math]::Round($et.DEF * $sc); SPD = [math]::Round($et.SPD * $sc) }
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $playerScore = 0; $rivalScore = 0
    for ($round = 1; $round -le 3; $round++) {
        Clear-Host
        Show-PetFrame "KAMPF — Runde $round/3" -Double | Out-Null
        Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($stats.MaxHP) | [$($enemy.Name)] HP: $($enemy.HP)/$($enemy.MaxHP)" -ForegroundColor White
        Write-Host "`n  [A]ngriff [V]erteidigung [S]pecial" -ForegroundColor White
        $pm = Read-Choice "Zug" '^[AVS]$'
        $rm = @("A","V","S") | Get-Random
        Write-Host "`n  Du: $($moves[$pm]) | Gegner: $($moves[$rm])" -ForegroundColor DarkGray
        if ($pm -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 1.5) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $p.HP -= [math]::Max(1, [math]::Round($enemy.ATK * (100 / (100 + $stats.DEF))))
            Write-Host "  Gleichstand! Beide treffen! -$dmg HP!" -ForegroundColor Yellow
        } elseif ($beats[$pm] -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 2) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $playerScore++
            Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Green
        } else {
            $dmg = [math]::Max(1, [math]::Round($enemy.ATK * (100 / (100 + $stats.DEF))))
            $p.HP -= $dmg; $rivalScore++
            Write-Host "  Treffer erhalten! -$dmg HP!" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 600
    }
    Clear-Host
    if ($playerScore -gt $rivalScore) {
        $xp = if ($isBoss) { 50 } else { 20 + ($p.Level * 5) }
        $gold = Get-Random -Minimum 5 -Maximum 16
        $p.Wins++; $p.XP += $xp; $p.HP = [math]::Min($p.HP + [math]::Round($stats.MaxHP * 0.2), $stats.MaxHP)
        $pet.Economy.Gold += $gold
        Write-Host "`n  SIEG! +$xp XP | +$gold G" -ForegroundColor Green
        Invoke-PetLevelUpCheck $p
        if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "fight_win") -Fast }
        Add-PetXP ($xp / 2) "Fight Win"
    } elseif ($playerScore -lt $rivalScore) {
        $p.Losses++; $p.HP = [math]::Round($stats.MaxHP * 0.3)
        Write-Host "`n  NIEDERLAGE..." -ForegroundColor Red
        if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "fight_loss") -Fast }
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

} catch {
    Write-Host "[pet/combat] CRITICAL ERROR: $_" -ForegroundColor Red
}
