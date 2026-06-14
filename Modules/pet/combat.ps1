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

$script:BPAttacks = @{
    "Neural Overload" = @{ Type = "VIRUS"; Power = 40; Accuracy = 95; Effect = "Poison"; EffectChance = 35 }
    "Bit Crusher"     = @{ Type = "NORM";  Power = 35; Accuracy = 100; Effect = $null; EffectChance = 0 }
    "Debug Patch"     = @{ Type = "NORM";  Power = 30; Accuracy = 100; Effect = "Heal"; EffectChance = 100 }
    "Plasma Lance"    = @{ Type = "FIRE";  Power = 50; Accuracy = 85;  Effect = "Burn"; EffectChance = 30 }
    "Ice Spike"       = @{ Type = "ICE";   Power = 45; Accuracy = 90;  Effect = "Freeze"; EffectChance = 25 }
    "System Purge"    = @{ Type = "VIRUS"; Power = 55; Accuracy = 80;  Effect = "Poison"; EffectChance = 40 }
    "Water Cannon"    = @{ Type = "WATER"; Power = 45; Accuracy = 90;  Effect = $null; EffectChance = 0 }
    "Overclock"       = @{ Type = "ELEC";  Power = 60; Accuracy = 75;  Effect = "Paralyze"; EffectChance = 20 }
    "Shadow Claw"     = @{ Type = "DARK";  Power = 50; Accuracy = 85;  Effect = "DEF-Down"; EffectChance = 40 }
    "Firewall"        = @{ Type = "FIRE";  Power = 40; Accuracy = 95;  Effect = "Burn"; EffectChance = 35 }
    "Zero-Day"        = @{ Type = "VIRUS"; Power = 70; Accuracy = 70;  Effect = "Poison"; EffectChance = 50 }
}

$script:BossPatterns = @{
    "BOSS_OMEGA" = @{
        Phases = @(
            @{ HPPercent = 100; Behavior = "Random"; Tell = $null; WarnTurns = 0 }
            @{ HPPercent = 50;  Behavior = "Aggressive"; Tell = "Der BOSS_OMEGA laedt seinen OMEGA-BEAM auf..."; WarnTurns = 1 }
            @{ HPPercent = 25;  Behavior = "Desperate"; Tell = "BOSS_OMEGA ueberhitzt! Kerninstabilitaet erkannt!"; WarnTurns = 1 }
        )
    }
}

$script:CombatStances = @{
    "Balanced"  = @{ ATK = 1.0; DEF = 1.0; SPD = 1.0; Crit = 5;  Block = 5;  Label = "BAL" }
    "Aggressiv" = @{ ATK = 1.5; DEF = 0.7; SPD = 1.0; Crit = 15; Block = 0;  Label = "AGGR" }
    "Defensiv"  = @{ ATK = 0.7; DEF = 1.5; SPD = 1.0; Crit = 0;  Block = 20; Label = "DEF" }
    "Speed"     = @{ ATK = 1.0; DEF = 0.85; SPD = 1.4; Crit = 10; Block = 5;  Label = "SPD" }
}

$script:PetTalents = @(
    @{ ID = "crit5";  Name = "Sharp Bits";        Description = "Crit +5%";                    Effect = "Crit";  Value = 5 }
    @{ ID = "hp5";    Name = "Overclocked Core";  Description = "MaxHP +5%";                   Effect = "MaxHP"; Value = 0.05 }
    @{ ID = "atk3";   Name = "Razor Code";        Description = "ATK +3";                      Effect = "ATK";   Value = 3 }
    @{ ID = "spd2";   Name = "Fast Compiler";     Description = "SPD +2";                      Effect = "SPD";   Value = 2 }
    @{ ID = "def2";   Name = "Firewall Patch";    Description = "DEF +2";                      Effect = "DEF";   Value = 2 }
    @{ ID = "regen1"; Name = "Self-Repair";       Description = "Regen 1% HP pro Runde";       Effect = "Regen"; Value = 0.01 }
)

function Get-StanceModifier($Stance) {
    if ($script:CombatStances.ContainsKey($Stance)) { return $script:CombatStances[$Stance] }
    return $script:CombatStances["Balanced"]
}

function Get-StanceDescription($Stance) {
    $m = Get-StanceModifier $Stance
    $parts = @()
    if ($m.ATK -ne 1.0) { $parts += "ATK x$($m.ATK)" }
    if ($m.DEF -ne 1.0) { $parts += "DEF x$($m.DEF)" }
    if ($m.SPD -ne 1.0) { $parts += "SPD x$($m.SPD)" }
    if ($m.Crit -gt 0) { $parts += "Crit +$($m.Crit)%" }
    if ($m.Block -gt 0) { $parts += "Block +$($m.Block)%" }
    if ($parts.Count -eq 0) { return "Ausgewogen. Keine Boni, keine Nachteile." }
    return ($parts -join " | ")
}

function Get-AvailableTalents($Pet) {
    $owned = @($Pet.Talents)
    $all = $script:PetTalents | Where-Object { $owned -notcontains $_.ID }
    return $all | Get-Random -Count ([math]::Min(3, $all.Count))
}

function Add-PetTalent($Pet, $TalentId) {
    $talent = $script:PetTalents | Where-Object { $_.ID -eq $TalentId } | Select-Object -First 1
    if (-not $talent) { return $false }
    if (-not $Pet.Talents) { $Pet.Talents = @() }
    if ($Pet.Talents -contains $TalentId) { return $false }
    $Pet.Talents += $TalentId
    return $true
}

function Invoke-PetTalentMenu($Pet) {
    try { Clear-Host } catch {}
    Show-PetFrame "TALENT FREIGESCHALTET — Lv.$($Pet.Level)" -Double | Out-Null
    Write-Host ""
    $choices = Get-AvailableTalents $Pet
    if ($choices.Count -eq 0) {
        Write-Host "  Keine neuen Talente verfuegbar." -ForegroundColor DarkGray
        Wait-Enter
        return
    }
    for ($i = 0; $i -lt $choices.Count; $i++) {
        Write-Host "  [$($i+1)] $($choices[$i].Name): $($choices[$i].Description)" -ForegroundColor Cyan
    }
    Write-Host ""
    $valid = "^[1-$($choices.Count)]$"
    $c = Read-Choice "Talent" $valid
    $selected = $choices[[int]$c - 1]
    if (Add-PetTalent $Pet $selected.ID) {
        Write-Host "  Talent erlernt: $($selected.Name)!" -ForegroundColor Green
    } else {
        Write-Host "  Talent bereits bekannt oder ungueltig." -ForegroundColor Red
    }
    Wait-Enter
}

function Add-ComboElement($CombatState, $Element) {
    $CombatState.ComboHistory += $Element
    if ($CombatState.ComboHistory.Count -gt 3) {
        $CombatState.ComboHistory = $CombatState.ComboHistory | Select-Object -Last 3
    }
}

function Test-ElementCombo($CombatState) {
    $h = $CombatState.ComboHistory
    if ($h.Count -lt 3) { return $null }
    $last3 = @($h[-3]; $h[-2]; $h[-1])
    $unique = @($last3 | Sort-Object -Unique)
    if ($unique.Count -eq 1) {
        return @{ Name = "Triad Surge"; Multiplier = 1.5; Color = "Magenta" }
    }
    if ($unique.Count -eq 3) {
        return @{ Name = "Prism Burst"; Multiplier = 1.3; Color = "Cyan" }
    }
    return $null
}

function Get-ScaledEnemyStats($Template, $PetLevel, [switch]$IsElite, [switch]$IsBoss) {
    $sc = 1 + ($PetLevel - 1) * 0.25
    if ($IsBoss) { $sc += 0.5 }
    if ($IsElite) { $sc *= 1.2 }
    $name = $Template.Name
    if ($IsElite) { $name = "ELITE $name" }
    return @{
        Name = $name; Type = $Template.Type
        HP = [math]::Round($Template.HP * $sc); MaxHP = [math]::Round($Template.HP * $sc)
        ATK = [math]::Round($Template.ATK * $sc); DEF = [math]::Round($Template.DEF * $sc); SPD = [math]::Round($Template.SPD * $sc)
        IsElite = [bool]$IsElite; IsBoss = [bool]$IsBoss
        BossPattern = if ($IsBoss) { $script:BossPatterns[$name] } else { $null }
    }
}

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
        LimitBreakUnlocked = $false
        Wins = 0; Losses = 0; Evolved = $false; Personality = "Balanced"
        Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }
        FoodBuffs = @()
        Talents = @()
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
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * $playerMod) * (100 / (100 + $enemy.DEF))))
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
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * $playerMod) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $playerScore++
            Write-Host "  Der Gegner verpatzt seinen Zug! Treffer! -$dmg HP!" -ForegroundColor Green
        }
        
        # Companion combat commentary
        if ($cp -and $round -lt 3) {
            Show-CompanionDialog $cp (Get-CompanionLine $cp "tutorial_fight") -Fast
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
    Invoke-Layer47Check
    Wait-Enter
}

function Get-EffectiveStats($p, $companion = $null) {
    $eq = $p.Equipment
    $hp = 0; $atk = 0; $def = 0; $spd = 0
    # Resolve equipment from shop tables
    $allItems = @($script:PetShopItems) + @($script:RaidShopItems) + @($script:CraftedItems)
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
    # Skill Tree: Combat branch bonuses apply to base ATK
    $combatBonus = Get-TotalPetSkillBonus -Branch 'Combat'
    if ($combatBonus -gt 0) {
        $atk += [math]::Round($p.ATK * $combatBonus)
    }
    $fMaxHP = $p.MaxHP + $hp; $fATK = $p.ATK + $atk; $fDEF = $p.DEF + $def; $fSPD = $p.SPD + $spd; $fCrit = 0
    foreach ($buff in $p.FoodBuffs) {
        if ($buff.Stat -eq "MaxHP") { $fMaxHP += [math]::Round($fMaxHP * $buff.Value) }
        if ($buff.Stat -eq "ATK")   { $fATK += [math]::Round($fATK * $buff.Value) }
        if ($buff.Stat -eq "DEF")   { $fDEF += [math]::Round($fDEF * $buff.Value) }
        if ($buff.Stat -eq "SPD")   { $fSPD += [math]::Round($fSPD * $buff.Value) }
        if ($buff.Stat -eq "ALL")   { $fMaxHP += [math]::Round($fMaxHP * $buff.Value); $fATK += [math]::Round($fATK * $buff.Value); $fDEF += [math]::Round($fDEF * $buff.Value); $fSPD += [math]::Round($fSPD * $buff.Value) }
    }
    # Talente anwenden
    if ($p.Talents) {
        foreach ($tid in $p.Talents) {
            $t = $script:PetTalents | Where-Object { $_.ID -eq $tid } | Select-Object -First 1
            if (-not $t) { continue }
            switch ($t.Effect) {
                "MaxHP" { $fMaxHP += [math]::Round($fMaxHP * $t.Value) }
                "ATK"   { $fATK += $t.Value }
                "DEF"   { $fDEF += $t.Value }
                "SPD"   { $fSPD += $t.Value }
                "Crit"  { $fCrit += $t.Value }
            }
        }
    }
    return @{ MaxHP = $fMaxHP; ATK = $fATK; DEF = $fDEF; SPD = $fSPD; Crit = $fCrit }
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

function Get-CombatInitiative($playerStats, $enemyStats) {
    $pInit = (Get-Random -Minimum 1 -Maximum 100) + $playerStats.SPD
    $eInit = (Get-Random -Minimum 1 -Maximum 100) + $enemyStats.SPD
    if ($pInit -eq $eInit) {
        return (Get-Random -Maximum 2) -eq 0
    }
    return $pInit -gt $eInit
}

function New-CombatState($playerPet, $companion) {
    return @{
        Round = 1
        PlayerStance = "Balanced"
        StatusEffects = @()
        ComboHistory = @()
        CompanionCooldowns = @{}
        LimitBreakUsed = $false
        BattleLog = @()
        PlayerPetIndex = 0
        FleeAttempted = $false
        Defending = $false
    }
}

function Invoke-TacticalCombat($playerPet, $companion, $isBoss = $false) {
    $stats = Get-EffectiveStats $playerPet $companion
    $playerPet.HP = [math]::Min($playerPet.HP, $stats.MaxHP)
    
    $isElite = (-not $isBoss) -and ($playerPet.Level -ge 5) -and ((Get-Random -Maximum 100) -lt 30)
    if ($isBoss) {
        $et = @{ Name = "BOSS_OMEGA"; Type = "VIRUS"; HP = 150; MaxHP = 150; ATK = 20; DEF = 15; SPD = 10 }
        $enemy = Get-ScaledEnemyStats -Template $et -PetLevel $playerPet.Level -IsBoss
    } else {
        $et = ($script:BPEnemies | Get-Random)
        $enemy = Get-ScaledEnemyStats -Template $et -PetLevel $playerPet.Level -IsElite:$isElite
    }
    
    $enemyStats = @{ MaxHP = $enemy.MaxHP; ATK = $enemy.ATK; DEF = $enemy.DEF; SPD = $enemy.SPD }
    $combatState = New-CombatState $playerPet $companion
    
    # Pre-fight companion ability
    if ($companion) {
        Use-CompanionCombatAbility $companion $playerPet $stats $enemy
        $stats = Get-EffectiveStats $playerPet $companion
    }
    
    # Combat loop
    while ($playerPet.HP -gt 0 -and $enemy.HP -gt 0 -and -not $combatState.FleeAttempted) {
        Show-CombatScreen $playerPet $enemy $companion $combatState $stats $enemyStats $isBoss
        
        # Limit Break check
        $lbResult = Invoke-LimitBreak $playerPet $enemy $combatState $stats $companion
        if ($combatState.FleeAttempted) { break }
        
        # Get player action
        $validActions = "^(1|2|3|4|5|6|F1|F2|F3|F4)$"
        $action = Read-Choice "Aktion" $validActions

        # Defend-Flag vor Initiative setzen, damit Schadensreduktion unabhaengig von der Reihenfolge wirkt
        $combatState.Defending = ($action -eq "2")

        # Determine initiative
        $playerFirst = Get-CombatInitiative $stats $enemyStats
        
        # Execute actions
        if ($playerFirst) {
            $pResult = Resolve-PlayerAction $action $playerPet $enemy $companion $combatState $stats $enemyStats
            if ($pResult -and $pResult.ActionType -eq "6" -and $combatState.FleeAttempted) { break }
            if ($pResult -and $pResult.ActionType -ne "3") {
                if ($enemy.HP -gt 0) {
                    $eResult = Resolve-EnemyAction $enemy $playerPet $combatState $stats $enemyStats $isBoss
                    if ($eResult.Narrative) {
                        Write-Host "  $($eResult.Narrative)" -ForegroundColor Red
                        Wait-Enter
                    }
                }
            }
        } else {
            $eResult = Resolve-EnemyAction $enemy $playerPet $combatState $stats $enemyStats $isBoss
            if ($eResult.Narrative) {
                Write-Host "  $($eResult.Narrative)" -ForegroundColor Red
                Wait-Enter
            }
            if ($playerPet.HP -gt 0) {
                $pResult = Resolve-PlayerAction $action $playerPet $enemy $companion $combatState $stats $enemyStats
                if ($pResult -and $pResult.ActionType -eq "6" -and $combatState.FleeAttempted) { break }
            }
        }
        
        # Apply status effects
        $seMessages = Apply-StatusEffects $combatState $playerPet $enemy $stats $enemyStats
        foreach ($msg in $seMessages) {
            Write-Host "  $msg" -ForegroundColor Yellow
        }
        if ($seMessages.Count -gt 0) { Wait-Enter }
        
        # Decrement companion cooldowns
        foreach ($key in @($combatState.CompanionCooldowns.Keys)) {
            if ($combatState.CompanionCooldowns[$key] -gt 0) {
                $combatState.CompanionCooldowns[$key]--
            }
        }
        
        # Defending flag gilt nur eine Runde
        $combatState.Defending = $false
        
        # Log round
        $combatState.BattleLog += "R$($combatState.Round): $($playerPet.Name) vs $($enemy.Name)"
        $combatState.Round++
        
        if ($playerPet.HP -le 0 -or $enemy.HP -le 0) { break }
        
        if (-not $combatState.FleeAttempted) {
            Write-Host "`n  [Enter] fuer naechste Runde..." -ForegroundColor DarkGray
            Read-Host
        }
    }
    
    Resolve-CombatEnd $playerPet $enemy $companion $combatState $stats $isBoss
}

function Resolve-CombatEnd($playerPet, $enemy, $companion, $combatState, $playerStats, $isBoss) {
    try { Clear-Host } catch {}
    $pet = Get-PetState
    
    if ($combatState.FleeAttempted) {
        Show-PetFrame "FLUCHT" -Double | Out-Null
        Write-Host "`n  Du bist erfolgreich geflohen!" -ForegroundColor Yellow
        $playerPet.HP = [math]::Round($playerStats.MaxHP * 0.5)
        Save-PetState $pet
        Wait-Enter
        return
    }
    
    if ($playerPet.HP -le 0) {
        Show-PetFrame "NIEDERLAGE" -Double | Out-Null
        $playerPet.Losses++
        $playerPet.HP = [math]::Round($playerStats.MaxHP * 0.3)
        Write-Host "`n  NIEDERLAGE..." -ForegroundColor Red
        if ($companion) { Show-CompanionDialog $companion (Get-CompanionLine $companion "fight_loss") -NoWait }
        Add-PetXP 5 "Fight Loss"
    } elseif ($enemy.HP -le 0) {
        Show-PetFrame "SIEG" -Double | Out-Null
        $xp = if ($isBoss) { 50 + ($playerPet.Level * 10) } else { 20 + ($playerPet.Level * 5) }
        $gold = Get-Random -Minimum 5 -Maximum 16
        if ($isBoss) { $gold += 25 }
        $playerPet.Wins++
        $playerPet.XP += $xp
        $playerPet.HP = [math]::Min($playerPet.HP + [math]::Round($playerStats.MaxHP * 0.2), $playerStats.MaxHP)
        $pet.Economy.Gold += $gold
        
        $lootChance = if ($isBoss) { 40 } else { 15 }
        $lootText = ""
        if ((Get-Random -Maximum 100) -lt $lootChance) {
            $lootItems = @("Scrap Metal","Data Shard","Energy Cell")
            if ($isBoss) { $lootItems += @("Rare Chip","Boss Core") }
            $loot = $lootItems | Get-Random
            $pet.Economy.Inventory += $loot
            $lootText = " | Loot: $loot"
        }
        
        if ($companion) {
            $companion.Sync++
            if ($companion.Sync -in @(10,25,50,100)) {
                Write-Host "`n  SYNC LEVEL UP! $($companion.Sync) erreicht!" -ForegroundColor Magenta
            }
        }
        
        Write-Host "`n  SIEG! +$xp XP | +$gold G$lootText" -ForegroundColor Green
        Invoke-PetLevelUpCheck $playerPet
        if ($companion) { Show-CompanionDialog $companion (Get-CompanionLine $companion "fight_win") -NoWait }
        Add-PetXP ($xp / 2) "Fight Win"
    }
    
    # Equipment durability degradation
    foreach ($slot in @("chip","armor","accessory")) {
        $eq = $playerPet.Equipment.$slot
        if ($eq) {
            $durKey = "Dur_$slot"
            if (-not $playerPet.$durKey) { $playerPet.$durKey = 10 }
            $playerPet.$durKey--
            if ($playerPet.$durKey -le 0) {
                $playerPet.Equipment.$slot = $null
                Write-Host "  $eq ist zerbrochen!" -ForegroundColor Red
                $playerPet.$durKey = 0
            } else {
                Write-Host "  $eq Haltbarkeit: $($playerPet.$durKey)" -ForegroundColor DarkGray
            }
        }
    }
    
    $playerPet.FoodBuffs = @(); Save-PetState $pet
    Invoke-Layer47Check
    Wait-Enter
}

function Start-PetFight {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { New-Pet; return }
    
    # Combat entry fee (scales with pet level)
    $entryFee = 5 + ($p.Level * 2)
    if ($pet.Economy.Gold -lt $entryFee) {
        Write-Host "`n  Nicht genug Gold fuer den Kampf! ($entryFee G benoetigt)" -ForegroundColor Red
        Wait-Enter; return
    }
    $pet.Economy.Gold -= $entryFee
    Save-PetState $pet
    
    # Passive HP regeneration between fights (10% per hour, max 100%)
    $now = Get-Date
    if ($p.LastFightTime) {
        $hours = ($now - [datetime]$p.LastFightTime).TotalHours
        $regen = [math]::Min($p.MaxHP, [math]::Round($p.MaxHP * 0.1 * $hours))
        $p.HP = [math]::Min($p.MaxHP, $p.HP + $regen)
    }
    $p.LastFightTime = $now.ToString("yyyy-MM-dd HH:mm")
    Save-PetState $pet
    
    $isBoss = ($p.Wins -gt 0 -and $p.Wins % 5 -eq 0)
    Invoke-TacticalCombat $p $cp $isBoss
}

function Invoke-PetLevelUpCheck($p) {
    $learn = @{ 2 = "Debug Patch"; 3 = "Plasma Lance"; 4 = "Ice Spike"; 5 = "System Purge"; 6 = "Water Cannon"; 7 = "Overclock"; 8 = "Shadow Claw"; 9 = "Firewall"; 10 = "Zero-Day" }
    while ($p.XP -ge $p.NextXP) {
        $oldLevel = $p.Level
        $p.Level++; $p.XP -= $p.NextXP; $p.NextXP = [math]::Round($p.NextXP * 1.5)
        $p.MaxHP += 10; $p.ATK += 2; $p.DEF += 1; $p.SPD += 1
        $p.HP = $p.MaxHP
        Write-Host "`n  LEVEL UP! Lv.$($p.Level)! Stats +1!" -ForegroundColor Magenta
        if ($learn.ContainsKey($p.Level)) {
            $p.Attacks += $learn[$p.Level]
            Write-Host "  Neue Attacke gelernt: $($learn[$p.Level])!" -ForegroundColor Yellow
        }
        if ($p.Level -eq 5 -and -not $p.LimitBreakUnlocked) {
            $p.LimitBreakUnlocked = $true
            Write-Host "  LIMIT BREAK freigeschaltet!" -ForegroundColor Magenta
        }
        if ($p.Level % 3 -eq 0) {
            Invoke-PetTalentMenu $p
        }
    }
}

function Get-CompanionCommandName($cpName) {
    switch ($cpName) {
        "NEON"  { "Hack" }
        "RAVEN" { "Predator Eye" }
        "PIXEL" { "Shield Deploy" }
        "LUNA"  { "Heal" }
        "IVY"   { "Silence" }
        "VERA"  { "Predict" }
        "JINX"  { "Chaos Roll" }
        default { "Support" }
    }
}

function Show-CombatScreen($playerPet, $enemy, $companion, $combatState, $playerStats, $enemyStats, $isBoss) {
    try { [Console]::CursorVisible = $false } catch {}
    Show-CombatScene $playerPet $enemy $companion $combatState $playerStats $enemyStats $isBoss
    if ($isBoss -and $enemy.BossPattern) {
        $currentPhase = $enemy.BossPattern.Phases | Where-Object { ($enemy.HP / $enemy.MaxHP * 100) -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase -and $currentPhase.Tell -and $currentPhase.WarnTurns -gt 0 -and $companion) {
            Show-CompanionDialog $companion (Get-CompanionLine $companion "boss_warning") -Fast
        }
    }
    if ($companion) {
        $cd = if ($combatState.CompanionCooldowns.ContainsKey($companion.Name)) { $combatState.CompanionCooldowns[$companion.Name] } else { 0 }
        $cdText = if ($cd -gt 0) { " [CD: $cd]" } else { "" }
        Write-Host "  Companion: $($companion.Name): $(Get-CompanionCommandName $companion.Name)$cdText" -ForegroundColor DarkGray
    }
    $fleeChance = [math]::Min(95, [math]::Round(($playerStats.SPD / ($playerStats.SPD + $enemyStats.SPD)) * 100))
    Write-Host "  Flee-Chance: $fleeChance%" -ForegroundColor DarkGray
    Write-Host ""
}
function Select-PlayerAttack($playerPet) {
    $pet = Get-PetState
    if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "attack_select") -Fast }
    Write-Host "`n  Verfuegbare Attacken:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $playerPet.Attacks.Count; $i++) {
        $atkName = $playerPet.Attacks[$i]
        $atk = $script:BPAttacks[$atkName]
        if ($atk) {
            Write-Host "    [$($i+1)] $atkName [$($atk.Type)] Pwr:$($atk.Power) Acc:$($atk.Accuracy)%" -ForegroundColor White
        } else {
            Write-Host "    [$($i+1)] $atkName [?]" -ForegroundColor White
        }
    }
    Write-Host "    [Q] Zurueck" -ForegroundColor DarkGray
    $choice = Read-Choice "Attacke" "^([1-$($playerPet.Attacks.Count)]|Q)$"
    if ($choice -eq 'Q') { return $null }
    return $playerPet.Attacks[[int]$choice - 1]
}

function Get-CompanionCooldown($cpName) {
    switch ($cpName) {
        "NEON"  { 3 }
        "RAVEN" { 2 }
        "PIXEL" { 3 }
        "LUNA"  { 3 }
        "IVY"   { 4 }
        "VERA"  { 2 }
        "JINX"  { 1 }
        default { 3 }
    }
}

function Resolve-PlayerAction($action, $playerPet, $enemy, $companion, $combatState, $playerStats, $enemyStats) {
    $stanceMod = switch ($combatState.PlayerStance) {
        "Aggressiv" { @{ ATK = 1.5; DEF = 0.5 } }
        "Defensiv"  { @{ ATK = 0.5; DEF = 1.5 } }
        "Speed"     { @{ ATK = 1.0; DEF = 1.0; SPD = 1.5 } }
        default     { @{ ATK = 1.0; DEF = 1.0 } }
    }
    
    $narrative = ""
    $damageDealt = 0
    $damageTaken = 0
    $effectApplied = $null
    
    switch ($action) {
        "1" { # Attack
            $attackName = Select-PlayerAttack $playerPet
            if (-not $attackName) { return $null }
            $attack = $script:BPAttacks[$attackName]
            $narrative = "Dein $($playerPet.Name) setzt $attackName ein!"
            
            $accRoll = Get-Random -Minimum 1 -Maximum 101
            if ($accRoll -le $attack.Accuracy) {
                Add-ComboElement $combatState $attack.Type
                $combo = Test-ElementCombo $combatState

                $playerMod = Get-ElementModifier $attack.Type $enemy.Type

                # Status-Effekte in Schadensberechnung einfliessen lassen
                $effectiveAtk = $playerStats.ATK
                $atkUp = $combatState.StatusEffects | Where-Object { $_.Target -eq "player" -and $_.Type -eq "ATK-Up" } | Select-Object -First 1
                if ($atkUp) { $effectiveAtk = [math]::Round($effectiveAtk * (1 + $atkUp.Value)) }

                $effectiveDef = $enemy.DEF
                $defDown = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "DEF-Down" } | Select-Object -First 1
                if ($defDown) { $effectiveDef = [math]::Max(1, [math]::Round($effectiveDef * (1 - $defDown.Value))) }

                $baseDmg = $attack.Power + $effectiveAtk
                $skillCritBonus = (Get-TotalPetSkillBonus -Branch 'Combat') * 20
                $critUp = $combatState.StatusEffects | Where-Object { $_.Target -eq "player" -and $_.Type -eq "Crit-Up" } | Select-Object -First 1
                $critChance = $stanceMod.Crit + $skillCritBonus + $playerStats.Crit
                if ($critUp) { $critChance += [math]::Round($critUp.Value * 100) }
                $critRoll = Get-Random -Minimum 1 -Maximum 101
                $crit = ($critRoll -le [math]::Max(0, [math]::Round($critChance)))
                $critMod = if ($crit) { 1.5 } else { 1.0 }
                $comboMod = 1.0
                if ($combo) {
                    $comboMod = $combo.Multiplier
                    $narrative += " [$($combo.Name)]!"
                }
                $dmg = [math]::Max(1, [math]::Round(($baseDmg * $stanceMod.ATK * $playerMod * $critMod * $comboMod) * (100 / (100 + $effectiveDef))))
                $damageDealt = $dmg
                $enemy.HP -= $dmg

                if ($playerMod -gt 1.0) { $narrative += " Typ-Vorteil!" }
                if ($playerMod -lt 1.0) { $narrative += " Typ-Nachteil..." }
                if ($crit) { $narrative += " KRITISCH!" }
                $narrative += " Treffer! -$dmg HP!"

                if ($attack.Effect -and (Get-Random -Minimum 1 -Maximum 101) -le $attack.EffectChance) {
                    $effectApplied = $attack.Effect
                    $turns = if ($attack.Effect -eq "Freeze") { 1 } elseif ($attack.Effect -eq "Paralyze") { 2 } else { 3 }
                    $val = if ($attack.Effect -eq "Poison") { 0.03 } elseif ($attack.Effect -eq "Burn") { 0.05 } else { 0 }
                    $combatState.StatusEffects += @{
                        Target = "enemy"; Type = $attack.Effect; Turns = $turns; Value = $val
                    }
                    $narrative += " [$($attack.Effect)!]"
                }
            } else {
                $narrative += " Verfehlt!"
            }
        }
        "2" { # Defend
            $narrative = "$($playerPet.Name) nimmt Defensiv-Stance ein! Einkommender Schaden halbiert!"
        }
        "3" { # Switch
            $narrative = "Du wechselst das Pet! (Diese Runde greift der Gegner frei an.)"
        }
        "4" { # Companion
            if ($companion) {
                $cd = if ($combatState.CompanionCooldowns.ContainsKey($companion.Name)) { $combatState.CompanionCooldowns[$companion.Name] } else { 0 }
                if ($cd -gt 0) {
                    $narrative = "$($companion.Name) ist noch auf Cooldown ($cd Runden)!"
                } else {
                    $narrative = Use-CompanionCommand $companion $playerPet $enemy $combatState $playerStats
                    $combatState.CompanionCooldowns[$companion.Name] = Get-CompanionCooldown $companion.Name
                }
            } else {
                $narrative = "Kein Companion verfuegbar!"
            }
        }
        "5" { # Item
            $narrative = Use-CombatItem $playerPet $combatState
        }
        "6" { # Flee
            $fleeChance = [math]::Min(95, [math]::Round(($playerStats.SPD / ($playerStats.SPD + $enemyStats.SPD)) * 100))
            $fleeRoll = Get-Random -Minimum 1 -Maximum 101
            if ($fleeRoll -le $fleeChance) {
                $narrative = "Flucht erfolgreich! Du bist entkommen!"
                $combatState.FleeAttempted = $true
            } else {
                $narrative = "Flucht fehlgeschlagen! Der Gegner blockiert den Weg!"
            }
        }
        "F1" { $combatState.PlayerStance = "Aggressiv"; $narrative = "Stance gewechselt: Aggressiv! ATK x1.5, DEF x0.5" }
        "F2" { $combatState.PlayerStance = "Defensiv";  $narrative = "Stance gewechselt: Defensiv! DEF x1.5, ATK x0.5" }
        "F3" { $combatState.PlayerStance = "Speed";     $narrative = "Stance gewechselt: Speed! SPD x1.5" }
        "F4" { $combatState.PlayerStance = "Balanced"; $narrative = "Stance gewechselt: Balanced! Keine Modifikation." }
    }
    
    if ($narrative) {
        Write-Host "`n  $narrative" -ForegroundColor White
    }
    
    return @{
        DamageDealt = $damageDealt
        DamageTaken = $damageTaken
        EffectApplied = $effectApplied
        ActionType = $action
    }
}

function Resolve-EnemyAction($enemy, $playerPet, $combatState, $playerStats, $enemyStats, $isBoss) {
    $narrative = ""
    $damageDealt = 0
    
    $behavior = "Random"
    if ($isBoss -and $enemy.BossPattern) {
        $currentPhase = $enemy.BossPattern.Phases | Where-Object { ($enemy.HP / $enemy.MaxHP * 100) -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase) { $behavior = $currentPhase.Behavior }
    }
    
    $paraEffect = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "Paralyze" } | Select-Object -First 1
    if ($paraEffect -and (Get-Random -Maximum 2) -eq 0) {
        $narrative = "$($enemy.Name) ist paralysiert und kann nicht angreifen!"
        return @{ DamageDealt = 0; Narrative = $narrative }
    }
    
    $freezeEffect = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "Freeze" } | Select-Object -First 1
    if ($freezeEffect) {
        $narrative = "$($enemy.Name) ist eingefroren und ueberspringt die Runde!"
        return @{ DamageDealt = 0; Narrative = $narrative }
    }
    
    $stunEffect = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "Stun" } | Select-Object -First 1
    if ($stunEffect) {
        $narrative = "$($enemy.Name) ist gestuned und kann nicht angreifen!"
        return @{ DamageDealt = 0; Narrative = $narrative }
    }
    
    $actions = @("A","V","S")
    $weights = switch ($behavior) {
        "Aggressive"   { @(60, 20, 20) }
        "Defensive"    { @(20, 60, 20) }
        "Desperate"    { @(30, 10, 60) }
        default        { @(33, 33, 34) }
    }
    $rand = Get-Random -Minimum 1 -Maximum 101
    $cum = 0
    $chosenAction = "A"
    for ($i = 0; $i -lt $actions.Count; $i++) {
        $cum += $weights[$i]
        if ($rand -le $cum) { $chosenAction = $actions[$i]; break }
    }
    
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }

    # Silence blockiert Special-Attacken des Gegners
    $silence = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "Silence" } | Select-Object -First 1
    if ($silence -and $chosenAction -eq "S") {
        $chosenAction = "A"
        $narrative = "$($enemy.Name) ist silenced! Special blockiert!"
    } else {
        $narrative = "$($enemy.Name) setzt $($moves[$chosenAction]) ein!"
    }

    if ($chosenAction -eq "A" -or $chosenAction -eq "S") {
        $enemyMod = Get-ElementModifier $enemy.Type $playerPet.Type
        $multiplier = if ($chosenAction -eq "S") { 1.5 } else { 1.0 }
        $baseDmg = $enemyStats.ATK * $multiplier

        # Defend-Flag halbiert einkommenden Schaden fuer eine Runde
        $defendMod = 1.0
        if ($combatState.Defending -eq $true) { $defendMod = 0.5 }

        # DEF-Up des Spielers verringert einkommenden Schaden
        $effectiveDef = $playerStats.DEF
        $defUp = $combatState.StatusEffects | Where-Object { $_.Target -eq "player" -and $_.Type -eq "DEF-Up" } | Select-Object -First 1
        if ($defUp) { $effectiveDef = [math]::Max(1, [math]::Round($effectiveDef * (1 + $defUp.Value))) }

        $stance = Get-StanceModifier $combatState.PlayerStance
        $blockRoll = Get-Random -Minimum 1 -Maximum 101
        $blocked = ($blockRoll -le $stance.Block)
        $blockMod = if ($blocked) { 0.0 } else { 1.0 }

        $dmg = [math]::Max(0, [math]::Round(($baseDmg * $enemyMod * $defendMod * $blockMod) * (100 / (100 + $effectiveDef))))
        $damageDealt = $dmg
        $playerPet.HP -= $dmg
        if ($blocked) {
            $narrative += " BLOCKIERT! Kein Schaden!"
        } else {
            $narrative += " Treffer! -$dmg HP!"
        }
    } else {
        $narrative += " Der Gegner nimmt Defensive-Stance ein!"
    }
    
    return @{ DamageDealt = $damageDealt; Narrative = $narrative }
}

function Use-CompanionCommand($companion, $playerPet, $enemy, $combatState, $playerStats) {
    $narrative = ""
    switch ($companion.Name) {
        "NEON" {
            $enemy.DEF = [math]::Max(1, [math]::Round($enemy.DEF * 0.7))
            $narrative = "NEON hackt die Firewall-Routinen des Gegners! Gegner-DEF -30% fuer 2 Runden!"
            $combatState.StatusEffects += @{ Target = "enemy"; Type = "DEF-Down"; Turns = 2; Value = 0.3 }
        }
        "RAVEN" {
            $narrative = "RAVEN analysiert den Gegner! Naechster Zug: Angriff (voraussichtlich)"
        }
        "PIXEL" {
            $combatState.StatusEffects += @{ Target = "player"; Type = "DEF-Up"; Turns = 2; Value = 0.4 }
            $narrative = "PIXEL deployt eine Schutzschicht! Pet-DEF +40% fuer 2 Runden!"
        }
        "LUNA" {
            $heal = [math]::Round($playerStats.MaxHP * 0.25)
            $playerPet.HP = [math]::Min($playerStats.MaxHP, $playerPet.HP + $heal)
            $narrative = "LUNA heilt dein Pet! +$heal HP!"
        }
        "IVY" {
            $combatState.StatusEffects += @{ Target = "enemy"; Type = "Silence"; Turns = 2; Value = 0 }
            $narrative = "IVY unterbricht die Gegner-Kommunikation! Special-Attacken blockiert fuer 2 Runden!"
        }
        "VERA" {
            $weakness = Get-ElementModifier $playerPet.Type $enemy.Type
            $weakText = if ($weakness -gt 1.0) { "Dein $($playerPet.Type) ist SEHR EFFEKTIV!" } elseif ($weakness -lt 1.0) { "Dein $($playerPet.Type) ist nicht effektiv..." } else { "Neutraler Typ-Matchup." }
            $narrative = "VERA scannt den Gegner! $weakText | Gegner HP: $($enemy.HP)/$($enemy.MaxHP) | ATK: $($enemyStats.ATK)"
        }
        "JINX" {
            $roll = Get-Random -Maximum 3
            switch ($roll) {
                0 { $playerStats.ATK = [math]::Round($playerStats.ATK * 1.3); $narrative = "JINX wirft den Glueckswuerfel! ATK +30%! Heute ist mein Tag!" }
                1 { $playerStats.SPD = [math]::Max(1, [math]::Round($playerStats.SPD * 0.8)); $narrative = "JINX wirft den Glueckswuerfel! SPD -20%! Chaos ist auch eine Strategie." }
                2 { $playerStats.ATK = [math]::Round($playerStats.ATK * 1.3); $playerStats.SPD = [math]::Max(1, [math]::Round($playerStats.SPD * 0.8)); $narrative = "JINX wirft den Glueckswuerfel! ATK +30% UND SPD -20%! 47% mehr Chaos!" }
            }
        }
        default { $narrative = "$($companion.Name) unterstuetzt das Team!" }
    }
    
    Show-CompanionDialog $companion $narrative -NoWait
    return $narrative
}

function Use-CombatItem($playerPet, $combatState) {
    $pet = Get-PetState
    $inventory = $pet.Economy.Inventory
    if (-not $inventory -or $inventory.Count -eq 0) {
        return "Keine Items im Inventar!"
    }
    Write-Host "`n  Verfuegbare Items:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $inventory.Count; $i++) {
        Write-Host "    [$($i+1)] $($inventory[$i])" -ForegroundColor White
    }
    Write-Host "    [Q] Zurueck" -ForegroundColor DarkGray
    $choice = Read-Choice "Item" "^([1-$($inventory.Count)]|Q)$"
    if ($choice -eq 'Q') { return "Item-Nutzung abgebrochen." }
    
    $item = $inventory[[int]$choice - 1]
    $narrative = ""
    
    switch -Regex ($item) {
        "Heiltrank" {
            $heal = [math]::Round($playerPet.MaxHP * 0.3)
            $playerPet.HP = [math]::Min($playerPet.MaxHP, $playerPet.HP + $heal)
            $narrative = "Heiltrank genutzt! +$heal HP!"
        }
        "Overclock" {
            $combatState.StatusEffects += @{ Target = "player"; Type = "ATK-Up"; Turns = 1; Value = 0.5 }
            $narrative = "Overclock aktiviert! ATK +50% diese Runde! Aber -20% MaxHP nach Kampf..."
        }
        "EMP" {
            $combatState.StatusEffects += @{ Target = "enemy"; Type = "Silence"; Turns = 2; Value = 0 }
            $narrative = "EMP detoniert! Gegner-Special-Attacken blockiert fuer 2 Runden!"
        }
        "Smoke Bomb" {
            $combatState.FleeAttempted = $true
            $narrative = "Smoke Bomb geworfen! Fluchtchance +40%!"
        }
        "Data Shard" {
            $weak = Get-ElementModifier $playerPet.Type $enemy.Type
            $weakStr = if ($weak -gt 1.0) { "SEHR EFFEKTIV (+$([math]::Round(($weak-1)*100))%)" } elseif ($weak -lt 1.0) { "nicht effektiv (-$([math]::Round((1-$weak)*100))%)" } else { "neutral" }
            $narrative = "Data Shard analysiert den Gegner... Typ-Matchup: $weakStr | HP: $($enemy.HP)/$($enemy.MaxHP)"
        }
        default { $narrative = "$item genutzt! Effekt unklar..." }
    }
    
    $inventory.RemoveAt([int]$choice - 1)
    Save-PetState $pet
    return $narrative
}

function Apply-StatusEffects($combatState, $playerPet, $enemy, $playerStats, $enemyStats) {
    $messages = @()
    $effectsToRemove = @()
    
    for ($i = 0; $i -lt $combatState.StatusEffects.Count; $i++) {
        $se = $combatState.StatusEffects[$i]
        $se.Turns--
        
        if ($se.Turns -lt 0) {
            $effectsToRemove += $i
            continue
        }
        
        switch ($se.Type) {
            "Burn" {
                if ($se.Target -eq "enemy") {
                    $dmg = [math]::Max(1, [math]::Round($enemy.MaxHP * $se.Value))
                    $enemy.HP -= $dmg
                    $messages += "$($enemy.Name) erleidet BURN! -$dmg HP!"
                } else {
                    $dmg = [math]::Max(1, [math]::Round($playerPet.MaxHP * $se.Value))
                    $playerPet.HP -= $dmg
                    $messages += "$($playerPet.Name) erleidet BURN! -$dmg HP!"
                }
            }
            "Poison" {
                if ($se.Target -eq "enemy") {
                    $dmg = [math]::Max(1, [math]::Round($enemy.MaxHP * $se.Value))
                    $enemy.HP -= $dmg
                    $messages += "$($enemy.Name) erleidet POISON! -$dmg HP!"
                } else {
                    $dmg = [math]::Max(1, [math]::Round($playerPet.MaxHP * $se.Value))
                    $playerPet.HP -= $dmg
                    $messages += "$($playerPet.Name) erleidet POISON! -$dmg HP!"
                }
            }
            "Regen" {
                if ($se.Target -eq "player") {
                    $heal = [math]::Max(1, [math]::Round($playerStats.MaxHP * $se.Value))
                    $playerPet.HP = [math]::Min($playerStats.MaxHP, $playerPet.HP + $heal)
                    $messages += "$($playerPet.Name) regeneriert! +$heal HP!"
                } else {
                    $heal = [math]::Max(1, [math]::Round($enemyStats.MaxHP * $se.Value))
                    $enemy.HP = [math]::Min($enemyStats.MaxHP, $enemy.HP + $heal)
                    $messages += "$($enemy.Name) regeneriert! +$heal HP!"
                }
            }
            "Stun"     { }
            "DEF-Down" { }
            "DEF-Up"   { }
            "ATK-Up"   { }
            "Silence"  { }
            "Crit-Up"  { }
        }
    }
    
    for ($i = $effectsToRemove.Count - 1; $i -ge 0; $i--) {
        $idx = $effectsToRemove[$i]
        $combatState.StatusEffects = $combatState.StatusEffects | Where-Object { $_ -ne $combatState.StatusEffects[$idx] }
    }
    
    return $messages
}

function Invoke-LimitBreak($playerPet, $enemy, $combatState, $playerStats, $companion) {
    if ($combatState.LimitBreakUsed) { return $null }
    if (-not $playerPet.LimitBreakUnlocked) { return $null }
    $hpRatio = $playerPet.HP / $playerStats.MaxHP
    if ($hpRatio -gt 0.25) { return $null }
    
    Write-Host "`n  LIMIT BREAK VERFUEGBAR!" -ForegroundColor Magenta
    Write-Host "  [L] Aktivieren  |  [Enter] Ignorieren" -ForegroundColor DarkGray
    $choice = Read-Host
    if ($choice -ne 'L' -and $choice -ne 'l') { return $null }
    
    $combatState.LimitBreakUsed = $true
    $attackName = $playerPet.Attacks | Get-Random
    $narrative = "LIMIT BREAK: $($playerPet.Name) entfesselt OMEGA-$attackName!"
    
    $baseDmg = ($script:BPAttacks[$attackName].Power + $playerStats.ATK) * 2.5
    $playerMod = Get-ElementModifier $playerPet.Type $enemy.Type
    $dmg = [math]::Max(1, [math]::Round(($baseDmg * $playerMod * 2) * (100 / (100 + $enemy.DEF))))
    $enemy.HP -= $dmg
    
    $narrative += " MEGA-Treffer! -$dmg HP! [Garantierter Status Effect!]"
    
    $effects = @("Burn","Poison","Paralyze","DEF-Down")
    $guaranteedEffect = $effects | Get-Random
    $combatState.StatusEffects += @{
        Target = "enemy"; Type = $guaranteedEffect; Turns = 3
        Value = if ($guaranteedEffect -eq "Poison") { 0.05 } elseif ($guaranteedEffect -eq "Burn") { 0.08 } else { 0 }
    }
    
    if ($companion) {
        Show-CompanionDialog $companion (Get-CompanionLine $companion "limit_break") -NoWait
    }
    
    Write-Host "`n  $narrative" -ForegroundColor Magenta
    Wait-Enter
    return $narrative
}

} catch {
    Write-Host "[pet/combat] CRITICAL ERROR: $_" -ForegroundColor Red
}
