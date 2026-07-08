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
    $sc = 1 + ($PetLevel - 1) * 0.32
    if ($IsBoss) { $sc = 1 + ($PetLevel - 1) * 0.38 }
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
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * $playerMod) * (1 - ($enemy.DEF / ($enemy.DEF + 20)))))
            $enemy.HP -= $dmg; $playerScore++
            Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Green
        } elseif ($pm -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 1.5 * $playerMod) * (1 - ($enemy.DEF / ($enemy.DEF + 20)))))
            $enemy.HP -= $dmg
            $eDmg = [math]::Max(1, [math]::Round(($enemy.ATK * $enemyMod) * (1 - ($stats.DEF / ($stats.DEF + 20)))))
            $p.HP -= $eDmg
            $playerScore++; $rivalScore++
            Write-Host "  Gleichstand! Beide treffen! -$dmg HP | -$eDmg HP!" -ForegroundColor Yellow
        } else {
            # Tutorial safety net: enemy "glitches" and misses
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * $playerMod) * (1 - ($enemy.DEF / ($enemy.DEF + 20)))))
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

# BUXE_OS v25.0 -- Companion Pre-Fight Ability fuer Reducer (Phase 2)
# Wandelt ATK/DEF/SPD-Buffs in Status-Effekte um, statt einen Snapshot zu mutieren.
function Use-CompanionCombatAbilityV3($cp, $player, $enemy) {
    if (-not $cp) { return }
    try { Clear-Host } catch {}
    Show-PetFrame "COMPANION UNTERSTUETZUNG" -Double | Out-Null
    Write-Host ""
    # Status-Effekte muessen als Generic.List vorliegen
    if (-not ($player.Effects -is [System.Collections.Generic.List[object]])) { $player.Effects = [System.Collections.Generic.List[object]]::new() }
    if (-not ($enemy.Effects -is [System.Collections.Generic.List[object]])) { $enemy.Effects = [System.Collections.Generic.List[object]]::new() }
    switch ($cp.Name) {
        "NEON" {
            $player.Effects.Add(@{ Type = "ATK-Up"; Turns = 3; Intensity = $null })
            Show-CompanionDialog $cp "*hackt deine Kampfroutinen* ATK +50% fuer 3 Runden!" -Fast
        }
        "RAVEN" {
            $preDmg = [math]::Max(1, [math]::Round($player.ATK * 0.5))
            $enemy.HP -= $preDmg
            Show-CompanionDialog $cp "*ferngesteuertes Takedown* Gegner nimmt $preDmg Schaden bevor der Kampf beginnt!" -Fast
        }
        "PIXEL" {
            $player.Effects.Add(@{ Type = "DEF-Up"; Turns = 3; Intensity = $null })
            Show-CompanionDialog $cp "*baut schnell eine Schutzschicht* DEF +40% fuer 3 Runden!" -Fast
        }
        "LUNA" {
            $heal = [math]::Round($player.MaxHP * 0.25)
            $player.HP = [math]::Min($player.MaxHP, $player.HP + $heal)
            Show-CompanionDialog $cp "*virtuelles Pflaster verteilt* +$heal HP geheilt!" -Fast
        }
        "IVY" {
            $enemy.Effects.Add(@{ Type = "DEF-Down"; Turns = 3; Intensity = $null })
            Show-CompanionDialog $cp "*löscht Gegner-Verteidigungsroutinen* Gegner-DEF -30% fuer 3 Runden!" -Fast
        }
        "VERA" {
            Show-CompanionDialog $cp "*scannt Gegner-Verhalten* Ich sehe seinen naechsten Zug. Nicht wirklich. Aber fast." -Fast
        }
        "JINX" {
            if ((Get-Random -Maximum 2) -eq 0) {
                $player.Effects.Add(@{ Type = "ATK-Up"; Turns = 2; Intensity = $null })
                Show-CompanionDialog $cp "*wirft einen digitalen Glueckswuerfel* ATK +50%! Heute ist mein Tag!" -Fast
            } else {
                # Chaos: Gegner bekommt zufaelligen DoT
                $chaos = @("Burn","Poison","Paralyze") | Get-Random
                $enemy.Effects.Add(@{ Type = $chaos; Turns = 2; Intensity = $null })
                Show-CompanionDialog $cp "*wirft einen digitalen Glueckswuerfel* Gegner erhaelt $chaos! Chaos ist auch eine Strategie." -Fast
            }
        }
    }
    Write-Host ""
    Wait-Enter
}

function Get-CombatInitiative($playerStats, $enemyStats, $playerStance = "Balanced") {
    $stance = Get-StanceModifier $playerStance
    $pInit = (Get-Random -Minimum 1 -Maximum 100) + ($playerStats.SPD * $stance.SPD)
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
        PlayerAction = $null
        EnemyAction = $null
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

function Get-EnemyAction($enemy, $combatState, $isBoss = $false) {
    $behavior = "Random"
    if ($isBoss -and $enemy.BossPattern) {
        $currentPhase = $enemy.BossPattern.Phases | Where-Object { ($enemy.HP / $enemy.MaxHP * 100) -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase) { $behavior = $currentPhase.Behavior }
    }
    $actions = @("A","V","S")
    $weights = switch ($behavior) {
        "Aggressive" { @(60, 20, 20) }
        "Defensive"  { @(20, 60, 20) }
        "Desperate"  { @(30, 10, 60) }
        default        { @(33, 33, 34) }
    }
    $rand = Get-Random -Minimum 1 -Maximum 101
    $cum = 0
    for ($i = 0; $i -lt $actions.Count; $i++) {
        $cum += $weights[$i]
        if ($rand -le $cum) { return $actions[$i] }
    }
    return "A"
}

function Resolve-AVS($playerAction, $enemyAction) {
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    if ($playerAction -eq $enemyAction) {
        return @{ Winner = "Tie"; PlayerMultiplier = 1.0; EnemyMultiplier = 1.0 }
    }
    if ($beats[$playerAction] -eq $enemyAction) {
        return @{ Winner = "Player"; PlayerMultiplier = 1.5; EnemyMultiplier = 0.5 }
    }
    return @{ Winner = "Enemy"; PlayerMultiplier = 0.5; EnemyMultiplier = 1.5 }
}

function Invoke-TacticalCombat($playerPet, $companion, $isBoss = $false) {
    $stats = Get-EffectiveStats $playerPet $companion
    $playerPet.HP = [math]::Min($playerPet.HP, $stats.MaxHP)

    $isElite = (-not $isBoss) -and ($playerPet.Level -ge 5) -and ((Get-Random -Maximum 100) -lt 30)
    if ($isBoss) {
        $et = @{ Name = "BOSS_OMEGA"; Type = "VIRUS"; HP = 150; MaxHP = 150; ATK = 20; DEF = 15; SPD = 10 }
        $enemyTemplate = Get-ScaledEnemyStats -Template $et -PetLevel $playerPet.Level -IsBoss
    } else {
        $et = ($script:BPEnemies | Get-Random)
        $enemyTemplate = Get-ScaledEnemyStats -Template $et -PetLevel $playerPet.Level -IsElite:$isElite
    }

    # Reducer-kompatible Player/Enemy-Objekte
    $player = @{
        Name = $playerPet.Name; Type = $playerPet.Type; Level = $playerPet.Level
        HP = $playerPet.HP; MaxHP = $stats.MaxHP
        ATK = $stats.ATK; DEF = $stats.DEF; SPD = $stats.SPD; Crit = $stats.Crit
        Attacks = $playerPet.Attacks; LimitBreakUnlocked = $playerPet.LimitBreakUnlocked
        Effects = [System.Collections.Generic.List[object]]::new()
    }
    $enemy = @{
        Name = $enemyTemplate.Name; Type = $enemyTemplate.Type; Level = $playerPet.Level
        HP = $enemyTemplate.HP; MaxHP = $enemyTemplate.MaxHP
        ATK = $enemyTemplate.ATK; DEF = $enemyTemplate.DEF; SPD = $enemyTemplate.SPD
        Archetype = if ($isBoss) { "Berserker" } else { "Drone" }
        IsBoss = [bool]$isBoss; IsElite = [bool]$isElite
        BossPattern = $enemyTemplate.BossPattern
        Effects = [System.Collections.Generic.List[object]]::new()
    }

    $state = New-CombatStateV3 -Player $player -Enemy $enemy

    # Pre-fight companion ability (jetzt als Status-Effekte, keine Snapshot-Mutation)
    if ($companion) {
        Use-CompanionCombatAbilityV3 $companion $player $enemy
    }

    # Kampf-Loop
    while ($state.Phase -eq "Active") {
        $lbAvailable = ($player.LimitBreakUnlocked -and -not $state.LimitBreakUsed -and ($player.HP / $player.MaxHP) -le 0.25)

        Show-CombatV3 -State $state -companion $companion -isBoss $isBoss

        $baseValid = "A|V|S|M|Q|F1|F2|F3|F4"
        if ($lbAvailable) { $baseValid += "|L" }
        $validPattern = "^($baseValid)$"
        $action = Read-Choice "Aktion" $validPattern

        # Stance ist kostenlos
        if ($action -match "^F[1-4]$") {
            $stanceName = switch ($action) { "F1" { "Aggressiv" } "F2" { "Defensiv" } "F3" { "Speed" } "F4" { "Balanced" } }
            $r = Invoke-CombatReducer -State $state -Action @{ Kind = "Stance"; Stance = $stanceName }
            $state = $r.State
            continue
        }

        # Flucht
        if ($action -eq "Q") {
            $r = Invoke-CombatReducer -State $state -Action @{ Kind = "Flee" }
            $state = $r.State
            Show-CombatV3 -State $state -Events $r.Events -companion $companion -isBoss $isBoss
            Wait-Enter
            break
        }

        # Aktion an Reducer uebergeben
        $reducerAction = @{ Kind = "Attack" }
        if ($action -eq "M") {
            $moveName = Select-PlayerAttack $playerPet
            if (-not $moveName) { continue }
            $reducerAction = @{ Kind = "Move"; MoveName = $moveName }
        } elseif ($action -eq "L") {
            $reducerAction = @{ Kind = "LimitBreak" }
        } elseif ($action -eq "V") {
            $reducerAction = @{ Kind = "Vanguard" }
        } elseif ($action -eq "S") {
            $reducerAction = @{ Kind = "Stealth" }
        }

        $r = Invoke-CombatReducer -State $state -Action $reducerAction
        $state = $r.State

        Show-CombatV3 -State $state -Events $r.Events -companion $companion -isBoss $isBoss
        if ($state.Phase -eq "Active") {
            Write-Host "`n  [Enter] fuer naechste Runde..." -ForegroundColor DarkGray
            Read-Host
        }
    }

    # HP zurueck ins Pet-Objekt synchronisieren (Reducer arbeitet auf lokaler Kopie)
    $playerPet.HP = $player.HP

    # Kampfende: Reward-Logik direkt aufrufen (Subscriber wuerden stale HP sehen)
    $result = $state.Phase.ToString().ToLower()
    Resolve-CombatEndV3 -playerPet $playerPet -companion $companion -isBoss $isBoss -result $result

    # Memory-Events veroeffentlichen
    $enemyName = $enemyTemplate.Name
    if ($result -eq "won") {
        Publish-BuxeEvent -Topic "combat.won" -Data @{ Enemy = $enemyName; IsBoss = $isBoss }
    } elseif ($result -eq "lost") {
        Publish-BuxeEvent -Topic "combat.lost" -Data @{ Enemy = $enemyName; IsBoss = $isBoss }
    }
    if (Get-Command Invoke-PetMemoryRecall -ErrorAction SilentlyContinue) { Invoke-PetMemoryRecall "Combat" }

    # Finaler Screen nur bei Sieg/Niederlage (Flucht wurde bereits angezeigt)
    if ($result -ne "fled") {
        Show-CombatV3 -State $state -companion $companion -isBoss $isBoss -Final
        Wait-Enter
    }
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
        $level = $playerPet.Level
        $gold = Get-Random -Minimum (10 + $level * 2) -Maximum (20 + $level * 3 + 1)
        if ($isBoss) { $gold += 25 + $level * 3 }
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

# BUXE_OS v25.0 -- Kampfende-Logik fuer den Reducer (Phase 2)
# Wird von world-events.ps1 via combat.won/lost/fled Events aufgerufen.
# KEIN UI-Blocking (kein Wait-Enter), nur State-Mutation + Ausgabe.
function Resolve-CombatEndV3($playerPet, $companion, $isBoss, $result) {
    $pet = Get-PetState
    $playerStats = Get-EffectiveStats $playerPet $companion

    switch ($result) {
        "fled" {
            try { Clear-Host } catch {}
            Show-PetFrame "FLUCHT" -Double | Out-Null
            Write-Host "`n  Du bist erfolgreich geflohen!" -ForegroundColor Yellow
            $playerPet.HP = [math]::Round($playerStats.MaxHP * 0.5)
            Save-PetState $pet
            return
        }
        "lost" {
            try { Clear-Host } catch {}
            Show-PetFrame "NIEDERLAGE" -Double | Out-Null
            $playerPet.Losses++
            $playerPet.HP = [math]::Round($playerStats.MaxHP * 0.3)
            Write-Host "`n  NIEDERLAGE..." -ForegroundColor Red
            if ($companion) { Show-CompanionDialog $companion (Get-CompanionLine $companion "fight_loss") -NoWait }
            Add-PetXP 5 "Fight Loss"
        }
        "won" {
            try { Clear-Host } catch {}
            Show-PetFrame "SIEG" -Double | Out-Null
            $xp = if ($isBoss) { 50 + ($playerPet.Level * 10) } else { 20 + ($playerPet.Level * 5) }
            $level = $playerPet.Level
            $gold = Get-Random -Minimum (10 + $level * 2) -Maximum (20 + $level * 3 + 1)
            if ($isBoss) { $gold += 25 + $level * 3 }
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
    }

    # Equipment durability degradation (nur bei Sieg/Niederlage, nicht Flucht)
    if ($result -in @("won","lost")) {
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
    }

    $playerPet.FoodBuffs = @()
    Save-PetState $pet
    Invoke-Layer47Check
}

function Start-PetFight {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { New-Pet; return }
    
    # Combat entry fee (scales with pet level)
    $entryFee = 2 + $p.Level
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

    $isBoss = ($p.Wins -gt 0 -and $p.Wins % 5 -eq 0 -and $p.Level -ge 5)
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
    Write-Host "  [Q] Flucht" -ForegroundColor DarkGray
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

function Resolve-PlayerAction($action, $playerPet, $enemy, $companion, $combatState, $playerStats, $enemyStats, $avsMultiplier = 1.0) {
    $stanceMod = Get-StanceModifier $combatState.PlayerStance
    $moves = @{ "A" = "Angriff"; "V" = "Vanguard"; "S" = "Stealth" }

    $narrative = ""
    $damageDealt = 0
    $damageTaken = 0
    $effectApplied = $null

    switch ($action) {
        "A" { # Angriff: normaler Schaden
            $narrative = "$($playerPet.Name) setzt $($moves[$action]) ein!"
            $baseDmg = $playerStats.ATK
            $critBonus = 0
            $damageDealt = Invoke-PlayerAttack $playerPet $enemy $combatState $playerStats $enemyStats $baseDmg $critBonus $avsMultiplier $stanceMod ([ref]$narrative)
        }
        "V" { # Vanguard: 50% Schadensreduktion, 25% Konterchance
            $combatState.Defending = $true
            $narrative = "$($playerPet.Name) nimmt Vanguard-Stance ein! Einkommender Schaden -50%, 25% Konterchance!"
        }
        "S" { # Stealth: +30% Schaden, +10% Crit, +25% Schaden wenn getroffen
            $narrative = "$($playerPet.Name) schaltet Stealth-Modus ein!"
            $baseDmg = $playerStats.ATK * 1.3
            $critBonus = 10
            $damageDealt = Invoke-PlayerAttack $playerPet $enemy $combatState $playerStats $enemyStats $baseDmg $critBonus $avsMultiplier $stanceMod ([ref]$narrative)
        }
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

function Invoke-PlayerAttack($playerPet, $enemy, $combatState, $playerStats, $enemyStats, $baseDmg, $critBonus, $avsMultiplier, $stanceMod, [ref]$narrativeRef) {
    Add-ComboElement $combatState $playerPet.Type
    $combo = Test-ElementCombo $combatState
    $playerMod = Get-ElementModifier $playerPet.Type $enemy.Type

    $effectiveAtk = $playerStats.ATK
    $atkUp = $combatState.StatusEffects | Where-Object { $_.Target -eq "player" -and $_.Type -eq "ATK-Up" } | Select-Object -First 1
    if ($atkUp) { $effectiveAtk = [math]::Round($effectiveAtk * (1 + $atkUp.Value)) }

    $effectiveDef = $enemy.DEF
    $defDown = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "DEF-Down" } | Select-Object -First 1
    if ($defDown) { $effectiveDef = [math]::Max(1, [math]::Round($effectiveDef * (1 - $defDown.Value))) }

    $skillCritBonus = (Get-TotalPetSkillBonus -Branch 'Combat') * 20
    $critUp = $combatState.StatusEffects | Where-Object { $_.Target -eq "player" -and $_.Type -eq "Crit-Up" } | Select-Object -First 1
    $critChance = $stanceMod.Crit + $skillCritBonus + $playerStats.Crit + $critBonus
    if ($critUp) { $critChance += [math]::Round($critUp.Value * 100) }
    $critRoll = Get-Random -Minimum 1 -Maximum 101
    $crit = ($critRoll -le [math]::Max(0, [math]::Round($critChance)))
    $critMod = if ($crit) { 1.5 } else { 1.0 }

    $comboMod = 1.0
    if ($combo) {
        $comboMod = $combo.Multiplier
        $narrativeRef.Value += " [$($combo.Name)]!"
    }

    $totalBase = $baseDmg * $stanceMod.ATK * $playerMod * $critMod * $comboMod * $avsMultiplier
    $dmg = [math]::Max(1, [math]::Round($totalBase * (1 - ($effectiveDef / ($effectiveDef + 20)))))
    $enemy.HP -= $dmg

    if ($playerMod -gt 1.0) { $narrativeRef.Value += " Typ-Vorteil!" }
    if ($playerMod -lt 1.0) { $narrativeRef.Value += " Typ-Nachteil..." }
    if ($crit) { $narrativeRef.Value += " KRITISCH!" }
    $narrativeRef.Value += " Treffer! -$dmg HP!"

    return $dmg
}

function Resolve-EnemyAction($enemy, $playerPet, $combatState, $playerStats, $enemyStats, $isBoss, $avsMultiplier = 1.0, $chosenAction = $null, $charging = $false) {
    $narrative = ""
    $damageDealt = 0

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

    if (-not $chosenAction) { $chosenAction = Get-EnemyAction $enemy $combatState $isBoss }
    $moves = @{ "A" = "Angriff"; "V" = "Vanguard"; "S" = "Stealth" }

    # Silence blockiert Stealth-Attacken des Gegners
    $silence = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "Silence" } | Select-Object -First 1
    if ($silence -and $chosenAction -eq "S") {
        $chosenAction = "A"
        $narrative = "$($enemy.Name) ist silenced! Stealth blockiert!"
    } else {
        $narrative = "$($enemy.Name) setzt $($moves[$chosenAction]) ein!"
    }

    if ($chosenAction -eq "A" -or $chosenAction -eq "S") {
        $enemyMod = Get-ElementModifier $enemy.Type $playerPet.Type
        $multiplier = if ($chosenAction -eq "S") { 1.3 } else { 1.0 }
        $baseDmg = $enemyStats.ATK * $multiplier

        # Boss charging attack: V reduziert um 75%, sonst 2x Schaden
        $chargeMod = 1.0
        if ($charging) {
            if ($combatState.PlayerAction -eq "V") {
                $chargeMod = 0.25
                $narrative += " [Ladung abgefangen! -75% Schaden!]"
            } else {
                $chargeMod = 2.0
                $narrative += " [LADUNGS-ANGRIFF! 2x Schaden!]"
            }
        }

        # Vanguard des Spielers reduziert einkommenden Schaden um 50%
        $defendMod = 1.0
        if ($combatState.Defending -eq $true) { $defendMod = 0.5 }

        # Stealth des Spielers erhoeht einkommenden Schaden um 25%
        $stealthMod = 1.0
        if ($combatState.PlayerAction -eq "S") { $stealthMod = 1.25 }

        # DEF-Up des Spielers verringert einkommenden Schaden
        $effectiveDef = $playerStats.DEF
        $defUp = $combatState.StatusEffects | Where-Object { $_.Target -eq "player" -and $_.Type -eq "DEF-Up" } | Select-Object -First 1
        if ($defUp) { $effectiveDef = [math]::Max(1, [math]::Round($effectiveDef * (1 + $defUp.Value))) }

        $stance = Get-StanceModifier $combatState.PlayerStance
        $blockRoll = Get-Random -Minimum 1 -Maximum 101
        $blocked = ($blockRoll -le $stance.Block)
        $blockMod = if ($blocked) { 0.0 } else { 1.0 }

        $totalBase = $baseDmg * $enemyMod * $defendMod * $stealthMod * $chargeMod * $avsMultiplier * $blockMod
        $dmg = [math]::Max(0, [math]::Round($totalBase * (1 - ($effectiveDef / ($effectiveDef + 20)))))
        $damageDealt = $dmg
        $playerPet.HP -= $dmg
        if ($blocked) {
            $narrative += " BLOCKIERT! Kein Schaden!"
        } else {
            $narrative += " Treffer! -$dmg HP!"
        }

        # Vanguard-Konter: 25% Chance bei Treffer Schaden zurueckzugeben
        if ($combatState.PlayerAction -eq "V" -and $dmg -gt 0 -and (Get-Random -Minimum 1 -Maximum 101) -le 25) {
            $counterBase = $playerStats.ATK * $stance.ATK * $enemyMod
            $counterDmg = [math]::Max(1, [math]::Round($counterBase * (1 - ($enemy.DEF / ($enemy.DEF + 20)))))
            $enemy.HP -= $counterDmg
            $narrative += " KONTER! -$counterDmg HP!"
        }
    } else {
        $narrative += " Der Gegner nimmt Vanguard-Stance ein!"
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
    $dmg = [math]::Max(1, [math]::Round(($baseDmg * $playerMod * 2) * (1 - ($enemy.DEF / ($enemy.DEF + 20)))))
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
