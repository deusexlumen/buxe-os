# BUXE_OS v24.2 - PET COMBAT v2.1
# RPS core + elemental types + companion skills + sync level + boss phases

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
    try { Clear-Host } catch {}
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

function Start-PetTutorialFight {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { New-Pet; $pet = Get-PetState; $p = $pet.Pet; $cp = $pet.Companion }
    
    $stats = Get-EffectiveStats $p $cp
    $p.HP = $stats.MaxHP
    $enemy = @{ Name = "SPAM_BOT"; Type = "NORM"; HP = 70; MaxHP = 70; ATK = 10; DEF = 6; SPD = 8; Phase2Triggered = $false }
    
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $playerScore = 0; $rivalScore = 0
    
    # Scripted rounds: Player always wins
    $scriptedPlayer = @("A","S","V")
    $scriptedEnemy = @("V","A","S")
    
    for ($round = 1; $round -le 3; $round++) {
        try { Clear-Host } catch {}
        Show-PetFrame "KAMPF — Runde $round/3" -Double | Out-Null
        Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($stats.MaxHP) | [$($enemy.Name)] HP: $($enemy.HP)/$($enemy.MaxHP)" -ForegroundColor White
        Write-Host "`n  [A]ngriff [V]erteidigung [S]pecial" -ForegroundColor White
        
        $pm = Read-Choice "Zug" '^[AVS]$'
        $rm = $scriptedEnemy[$round - 1]
        
        Write-Host "`n  Du: $($moves[$pm]) | Gegner: $($moves[$rm])" -ForegroundColor DarkGray
        
        $playerMod = Get-ElementModifier $p.Type $enemy.Type
        $enemyMod = Get-ElementModifier $enemy.Type $p.Type
        
        # Tutorial: always win regardless of choice, but show correct logic
        if ($beats[$pm] -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 2 * $playerMod) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $playerScore++
            Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Green
        } elseif ($pm -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 1.5 * $playerMod) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg
            $eDmg = [math]::Max(1, [math]::Round(($enemy.ATK * $enemyMod) * (100 / (100 + $stats.DEF))))
            $p.HP -= $eDmg
            $playerScore++; $rivalScore++
            Write-Host "  Gleichstand! Beide treffen! -$dmg HP | -$eDmg HP!" -ForegroundColor Yellow
        } else {
            # Tutorial safety net: enemy "glitches" and misses
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 2 * $playerMod) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $playerScore++
            Write-Host "  Der Gegner verpatzt seinen Zug! Treffer! -$dmg HP!" -ForegroundColor Green
        }
        
        # Companion combat commentary
        if ($cp -and $round -lt 3) {
            $comment = switch ($cp.Name) {
                "NEON" { @("Nicht schlecht. Fuer einen Anfaenger.","Mach weiter so. Oder nicht. Ist mir egal.") | Get-Random }
                "RAVEN" { @("Schwach. Aber ausreichend.","Der Gegner ist Pathetisch.") | Get-Random }
                "PIXEL" { @("D-du schaffst das!","Wow! So stark!") | Get-Random }
                "LUNA" { @("Gut gemacht!","Pass auf dich auf!") | Get-Random }
                "IVY" { @("... *nickt*","... *beobachtet*") | Get-Random }
                "VERA" { @("Effizienz: 87%. Akzeptabel.","Taktische Analyse: Korrekt.") | Get-Random }
                "JINX" { @("POW! BAM!","Das war fast so cool wie die Zahl 47!") | Get-Random }
                default { "..." }
            }
            Show-CompanionDialog $cp $comment -Fast
        }
        
        Start-Sleep -Milliseconds 600
    }
    
    try { Clear-Host } catch {}
    $xp = 20 + ($p.Level * 5)
    $gold = Get-Random -Minimum 10 -Maximum 21
    $p.Wins++; $p.XP += $xp; $p.HP = $stats.MaxHP
    $pet.Economy.Gold += $gold
    if ($cp) { $cp.Sync += 3 }
    Save-PetState $pet
    
    Write-Host "`n  SIEG! +$xp XP | +$gold G" -ForegroundColor Green
    Invoke-PetLevelUpCheck $p
    if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "fight_win") -Fast }
    Write-Host ""
    Wait-Enter
}

function Get-EffectiveStats($p, $companion = $null) {
    $eq = $p.Equipment
    $hp = 0; $atk = 0; $def = 0; $spd = 0
    # Resolve equipment from shop tables
    $allItems = @($script:PetShopItems) + @($script:RaidShopItems)
    foreach ($slot in @("Armor","Chip","Accessory")) {
        $itemName = $eq.$slot
        if ($itemName) {
            $item = $allItems | Where-Object { $_.Name -eq $itemName } | Select-Object -First 1
            if ($item) {
                if ($item.ATK) { $atk += $item.ATK }
                if ($item.DEF) { $def += $item.DEF }
                if ($item.HP) { $hp += $item.HP }
                if ($item.SPD) { $spd += $item.SPD }
            } else {
                # Fallback for unknown items
                if ($slot -eq "Armor") { $atk += 3; $hp += 10 }
                if ($slot -eq "Chip") { $atk += 3 }
                if ($slot -eq "Accessory") { $spd += 3 }
            }
        }
    }
    if ($p.Personality -eq "Aggressive") { $atk = [math]::Round($atk * 1.1) }
    if ($p.Personality -eq "Defensive") { $def = [math]::Round($def * 1.1) }
    if ($p.Personality -eq "Speedster") { $spd = [math]::Round($spd * 1.15) }
    # Companion sync bonuses
    if ($companion) {
        $sync = $companion.Sync
        if ($sync -ge 100) { $atk += 8; $def += 4; $spd += 4; $hp += 20 }
        elseif ($sync -ge 50) { $atk += 5; $def += 3; $spd += 3; $hp += 12 }
        elseif ($sync -ge 25) { $atk += 3; $def += 2; $spd += 2; $hp += 8 }
        elseif ($sync -ge 10) { $atk += 1; $def += 1; $spd += 1; $hp += 4 }
        # CombatBoost skill: +2% ATK per level
        if ($companion.Skills.CombatBoost -gt 0) {
            $atk += [math]::Round($p.ATK * ($companion.Skills.CombatBoost * 0.02))
        }
    }
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

function Use-CompanionCombatAbility($cp, $p, $stats, $enemy) {
    if (-not $cp) { return }
    try { Clear-Host } catch {}
    Show-PetFrame "COMPANION UNTERSTUETZUNG" -Double | Out-Null
    Write-Host ""
    switch ($cp.Name) {
        "NEON" {
            $stats.ATK += [math]::Round($stats.ATK * 0.2)
            Show-CompanionDialog $cp "*hackt deine Kampfroutinen* ATK +20% fuer diesen Kampf!"
        }
        "RAVEN" {
            $enemy.HP -= [math]::Max(1, [math]::Round($stats.ATK * 0.5))
            Show-CompanionDialog $cp "*ferngesteuertes Takedown* Gegner nimmt Schaden bevor der Kampf beginnt!"
        }
        "PIXEL" {
            $stats.DEF += [math]::Round($stats.DEF * 0.25)
            Show-CompanionDialog $cp "*baut schnell eine Schutzschicht* DEF +25% fuer diesen Kampf!"
        }
        "LUNA" {
            $heal = [math]::Round($stats.MaxHP * 0.25)
            $p.HP = [math]::Min($stats.MaxHP, $p.HP + $heal)
            Show-CompanionDialog $cp "*virtuelles Pflaster verteilt* +$heal HP geheilt!"
        }
        "IVY" {
            $enemy.DEF = [math]::Max(1, [math]::Round($enemy.DEF * 0.9))
            Show-CompanionDialog $cp "*löscht Gegner-Verteidigungsroutinen* Enemy DEF -10%!"
        }
        "VERA" {
            Show-CompanionDialog $cp "*scannt Gegner-Verhalten* Ich sehe seinen naechsten Zug. Nicht wirklich. Aber fast."
        }
        "JINX" {
            if ((Get-Random -Maximum 2) -eq 0) {
                $stats.ATK += [math]::Round($stats.ATK * 0.3)
                Show-CompanionDialog $cp "*wirft einen digitalen Glueckswuerfel* ATK +30%! Heute ist mein Tag!"
            } else {
                $stats.SPD = [math]::Max(1, [math]::Round($stats.SPD * 0.8))
                Show-CompanionDialog $cp "*wirft einen digitalen Glueckswuerfel* SPD -20%! Naja, Chaos ist auch eine Strategie."
            }
        }
    }
    Write-Host ""
    Wait-Enter
}

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
