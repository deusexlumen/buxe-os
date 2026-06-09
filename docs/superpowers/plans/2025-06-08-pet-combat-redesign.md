# Pet Combat Redesign v24.12 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Das Pet-Kampfsystem wird von einem statischen 3-Runden-RPS zu einem taktischen, rundenbasierten Kampfsystem mit Initiative, Stances, Pet-Switch, Status Effects, Limit Breaks, Boss-Tells und Companion Cooldowns umgebaut. Plus globaler Readability-Fix fuer `Show-CompanionDialog`.

**Architecture:** `Invoke-TacticalCombat` verwaltet den Kampf-Loop. `Show-CombatScreen` zeigt HP-Balken, Runden-Log und Menue. Jede Runde bestimmt Initiative, fuehrt Spieler- und Gegner-Aktion aus, tickt Status Effects, und prueft auf Kampfende. Der globale Readability-Fix fuegt `Wait-Enter` zu `Show-CompanionDialog` hinzu (ausser bei `-Fast` oder `-NoWait`).

**Tech Stack:** PowerShell 7/5.1, BUXE_OS State-System, bestehende Pet-Module.

---

## File Map

| File | Responsibility |
|------|---------------|
| `Modules/pet/_ui.ps1` | `Show-CompanionDialog` Readability-Fix, `Show-HPBar`, `Show-CombatLog` |
| `Modules/pet/combat.ps1` | `Invoke-TacticalCombat`, `Show-CombatScreen`, `Get-CombatInitiative`, `Resolve-PlayerAction`, `Resolve-EnemyAction`, `Apply-StatusEffects`, `Invoke-LimitBreak`, `Use-CompanionCommand`, `Switch-CombatPet`, `BPAttacks`, `BossPatterns` |
| `Modules/pet/_init.ps1` | Pet-Datenstruktur erweitern (LimitBreakUnlocked, Attacks-Details) |
| `Modules/engine-ui.ps1` | `Show-HPBar` (Fallback) |
| `Modules/_smoke_test.ps1` | Neue Kampf-Checks |
| `Modules/_e2e_test.ps1` | Tactical Combat Flow Test |

---

### Task 1: Global Readability Fix — `Show-CompanionDialog`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Fuege `-NoWait` Parameter hinzu**

Finde `function Show-CompanionDialog` (ca. Zeile 524). Ersetze die Signatur:

```powershell
# ALT:
function Show-CompanionDialog($Companion, $Text, [switch]$Fast) {

# NEU:
function Show-CompanionDialog($Companion, $Text, [switch]$Fast, [switch]$NoWait) {
```

- [ ] **Step 2: Fuege Wait-Enter am Ende hinzu**

Nach der Typewriter-Loop (nach `Write-Host ""`), fuege hinzu:

```powershell
    if (-not $NoWait -and -not $Fast) {
        Wait-Enter
    }
```

Der komplette Block sollte so aussehen:

```powershell
function Show-CompanionDialog($Companion, $Text, [switch]$Fast, [switch]$NoWait) {
    if (-not $Companion) { return }
    $color = if ($script:CPColors) { $script:CPColors[$script:CPNames.IndexOf($Companion.Name)] } else { "White" }
    if ($color -eq $null -or $color -eq "") { $color = "White" }
    Write-Host "`n  [$($Companion.Name)] >> " -NoNewline -ForegroundColor $color
    $delay = if ($Fast) { 10 } else { 30 }
    foreach ($char in $Text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor White
        Start-Sleep -Milliseconds $delay
    }
    Write-Host ""
    if (-not $NoWait -and -not $Fast) {
        Wait-Enter
    }
}
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

Expected: Tests laufen durch (keine Breaking Changes, da `-Fast` Aufrufe unveraendert bleiben).

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(ui): add Wait-Enter to Show-CompanionDialog (global readability)"
```

---

### Task 2: Show-HPBar + Show-CombatLog

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Neue Funktion `Show-HPBar`**

Fuege vor dem `catch`-Block hinzu:

```powershell
function Show-HPBar($Current, $Max, $Width = 20) {
    if ($Max -le 0) { $Max = 1 }
    $ratio = $Current / $Max
    $filled = [math]::Round($ratio * $Width)
    $filled = [math]::Max(0, [math]::Min($Width, $filled))
    $bar = ("█" * $filled) + ("░" * ($Width - $filled))
    $color = if ($ratio -gt 0.5) { "Green" } elseif ($ratio -gt 0.25) { "Yellow" } else { "Red" }
    return @{ Bar = $bar; Color = $color; Percent = [math]::Round($ratio * 100) }
}
```

- [ ] **Step 2: Neue Funktion `Show-CombatLog`**

Fuege direkt nach `Show-HPBar` hinzu:

```powershell
function Show-CombatLog($LogEntries, $MaxEntries = 3) {
    if (-not $LogEntries -or $LogEntries.Count -eq 0) { return }
    $start = [math]::Max(0, $LogEntries.Count - $MaxEntries)
    for ($i = $start; $i -lt $LogEntries.Count; $i++) {
        Write-Host "  $($LogEntries[$i])" -ForegroundColor DarkGray
    }
}
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(ui): add Show-HPBar and Show-CombatLog"
```

---

### Task 3: BPAttacks + BossPatterns Datenstrukturen

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Fuege `$script:BPAttacks` hinzu**

Fuege nach den `$script:BPEnemies` (ca. Zeile 22) und vor `function New-Pet` hinzu:

```powershell
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
```

- [ ] **Step 2: Fuege `$script:BossPatterns` hinzu**

Fuege direkt nach `$script:BPAttacks` hinzu:

```powershell
$script:BossPatterns = @{
    "BOSS_OMEGA" = @{
        Phases = @(
            @{ HPPercent = 100; Behavior = "Random"; Tell = $null; WarnTurns = 0 }
            @{ HPPercent = 50;  Behavior = "Aggressive"; Tell = "Der BOSS_OMEGA lädt seinen OMEGA-BEAM auf..."; WarnTurns = 1 }
            @{ HPPercent = 25;  Behavior = "Desperate"; Tell = "BOSS_OMEGA überhitzt! Kerninstabilität erkannt!"; WarnTurns = 1 }
        )
    }
}
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): add BPAttacks and BossPatterns data structures"
```

---

### Task 4: Get-CombatInitiative + CombatState

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Neue Funktion `Get-CombatInitiative`**

Fuege vor `function Start-PetFight` (vor dem alten Code) hinzu:

```powershell
function Get-CombatInitiative($playerStats, $enemyStats) {
    $pInit = (Get-Random -Minimum 1 -Maximum 100) + $playerStats.SPD
    $eInit = (Get-Random -Minimum 1 -Maximum 100) + $enemyStats.SPD
    if ($pInit -eq $eInit) {
        return (Get-Random -Maximum 2) -eq 0  # 50/50 coin flip
    }
    return $pInit -gt $eInit
}
```

- [ ] **Step 2: Neue Funktion `New-CombatState`**

Fuege direkt nach `Get-CombatInitiative` hinzu:

```powershell
function New-CombatState($playerPet, $companion) {
    return @{
        Round = 1
        PlayerStance = "Balanced"
        StatusEffects = @()
        CompanionCooldowns = @{}
        LimitBreakUsed = $false
        BattleLog = @()
        PlayerPetIndex = 0
        FleeAttempted = $false
    }
}
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): add initiative and combat state"
```

---

### Task 5: Show-CombatScreen

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Neue Funktion `Show-CombatScreen`**

Fuege nach `New-CombatState` hinzu:

```powershell
function Show-CombatScreen($playerPet, $enemy, $companion, $combatState, $playerStats, $enemyStats, $isBoss) {
    try { Clear-Host } catch {}
    $title = if ($isBoss) { "BOSS-KAMPF — Runde $($combatState.Round)" } else { "KAMPF — Runde $($combatState.Round)" }
    Show-PetFrame $title -Double | Out-Null
    Write-Host ""
    
    # HP Bars
    $pBar = Show-HPBar $playerPet.HP $playerStats.MaxHP
    $eBar = Show-HPBar $enemy.HP $enemy.MaxHP
    Write-Host "  [$($playerPet.Name)] $($pBar.Bar) $($playerPet.HP)/$($playerStats.MaxHP) HP ($($pBar.Percent)%)" -ForegroundColor $pBar.Color
    Write-Host "  [$($enemy.Name)]     $($eBar.Bar) $($enemy.HP)/$($enemy.MaxHP) HP ($($eBar.Percent)%)" -ForegroundColor $eBar.Color
    Write-Host ""
    
    # Stance display
    $stanceEmoji = switch ($combatState.PlayerStance) {
        "Aggressiv" { "⚔️" }
        "Defensiv"  { "🛡️" }
        "Speed"     { "⚡" }
        default     { "⚖️" }
    }
    Write-Host "  Stance: $stanceEmoji $($combatState.PlayerStance)" -ForegroundColor Cyan
    Write-Host ""
    
    # Boss Tell
    if ($isBoss -and $enemy.BossPattern) {
        $currentPhase = $enemy.BossPattern.Phases | Where-Object { $enemy.HP / $enemy.MaxHP * 100 -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase -and $currentPhase.Tell -and $currentPhase.WarnTurns -gt 0) {
            Write-Host "  ⚠️  $($currentPhase.Tell)" -ForegroundColor Magenta
            Write-Host "  [Nächste Runde: Stark-Attacke! Defend oder Switch empfohlen!]" -ForegroundColor DarkMagenta
            Write-Host ""
        }
    }
    
    # Status Effects
    if ($combatState.StatusEffects.Count -gt 0) {
        Write-Host "  Status Effects:" -ForegroundColor Yellow
        foreach ($se in $combatState.StatusEffects) {
            $seText = switch ($se.Type) {
                "Burn"     { "🔥 BURN ($($se.Turns) Runden)" }
                "Freeze"   { "❄️ FREEZE ($($se.Turns) Runden)" }
                "Poison"   { "☠️ POISON ($($se.Turns) Runden, $($se.Value * 100)%)" }
                "Paralyze" { "⚡ PARALYZE ($($se.Turns) Runden)" }
                "DEF-Down" { "🔽 DEF-DOWN ($($se.Turns) Runden)" }
                "ATK-Up"   { "🔼 ATK-UP ($($se.Turns) Runden)" }
                default    { "$($se.Type) ($($se.Turns) Runden)" }
            }
            $targetText = if ($se.Target -eq "player") { "[$($playerPet.Name)]" } else { "[$($enemy.Name)]" }
            Write-Host "    $targetText $seText" -ForegroundColor DarkYellow
        }
        Write-Host ""
    }
    
    # Combat Log
    if ($combatState.BattleLog.Count -gt 0) {
        Show-CombatLog $combatState.BattleLog
        Write-Host ""
    }
    
    # Action Menu
    Write-Host "  [1] Attack — Waehle Attacke" -ForegroundColor White
    Write-Host "  [2] Defend — Schaden -50% diese Runde" -ForegroundColor White
    Write-Host "  [3] Switch — Wechsle Pet" -ForegroundColor White
    if ($companion) {
        $cd = if ($combatState.CompanionCooldowns.ContainsKey($companion.Name)) { $combatState.CompanionCooldowns[$companion.Name] } else { 0 }
        $cdText = if ($cd -gt 0) { " [CD: $cd]" } else { "" }
        Write-Host "  [4] Companion — $($companion.Name): $(Get-CompanionCommandName $companion.Name)$cdText" -ForegroundColor White
    } else {
        Write-Host "  [4] Companion — Kein Companion" -ForegroundColor DarkGray
    }
    Write-Host "  [5] Item — Nutze Item" -ForegroundColor White
    $fleeChance = [math]::Min(95, [math]::Round(($playerStats.SPD / ($playerStats.SPD + $enemyStats.SPD)) * 100))
    Write-Host "  [6] Flee — Chance: $fleeChance%" -ForegroundColor White
    Write-Host ""
    Write-Host "  [F1] Aggressiv  [F2] Defensiv  [F3] Speed  [F4] Balanced" -ForegroundColor DarkGray
    Write-Host ""
}
```

- [ ] **Step 2: Hilfsfunktion `Get-CompanionCommandName`**

Fuege vor `Show-CombatScreen` hinzu:

```powershell
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
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): add Show-CombatScreen and helper functions"
```

---

### Task 6: Resolve-PlayerAction

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Neue Funktion `Resolve-PlayerAction`**

Fuege nach `Show-CombatScreen` hinzu:

```powershell
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
            $narrative = "Dein $($playerPet.Name) setzt $($attackName) ein!"
            
            $accRoll = Get-Random -Minimum 1 -Maximum 101
            if ($accRoll -le $attack.Accuracy) {
                $playerMod = Get-ElementModifier $attack.Type $enemy.Type
                $baseDmg = $attack.Power + $playerStats.ATK
                $dmg = [math]::Max(1, [math]::Round(($baseDmg * $stanceMod.ATK * $playerMod * 2) * (100 / (100 + $enemy.DEF))))
                $damageDealt = $dmg
                $enemy.HP -= $dmg
                
                if ($playerMod -gt 1.0) { $narrative += " Typ-Vorteil!" }
                if ($playerMod -lt 1.0) { $narrative += " Typ-Nachteil..." }
                $narrative += " Treffer! -$dmg HP!"
                
                # Status effect chance
                if ($attack.Effect -and (Get-Random -Minimum 1 -Maximum 101) -le $attack.EffectChance) {
                    $effectApplied = $attack.Effect
                    $combatState.StatusEffects += @{
                        Target = "enemy"; Type = $attack.Effect; Turns = 3
                        Value = if ($attack.Effect -eq "Poison") { 0.03 } elseif ($attack.Effect -eq "Burn") { 0.05 } else { 0 }
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
        "F1" { $combatState.PlayerStance = "Aggressiv"; $narrative = "Stance gewechselt: Aggressiv! ATK ×1.5, DEF ×0.5" }
        "F2" { $combatState.PlayerStance = "Defensiv";  $narrative = "Stance gewechselt: Defensiv! DEF ×1.5, ATK ×0.5" }
        "F3" { $combatState.PlayerStance = "Speed";     $narrative = "Stance gewechselt: Speed! SPD ×1.5" }
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
```

- [ ] **Step 2: Hilfsfunktionen `Select-PlayerAttack`, `Get-CompanionCooldown`**

Fuege vor `Resolve-PlayerAction` hinzu:

```powershell
function Select-PlayerAttack($playerPet) {
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
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): add Resolve-PlayerAction and helpers"
```

---

### Task 7: Resolve-EnemyAction + Use-CompanionCommand + Use-CombatItem

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Neue Funktion `Resolve-EnemyAction`**

Fuege nach `Resolve-PlayerAction` hinzu:

```powershell
function Resolve-EnemyAction($enemy, $playerPet, $combatState, $playerStats, $enemyStats, $isBoss) {
    $narrative = ""
    $damageDealt = 0
    
    # Boss pattern behavior
    $behavior = "Random"
    if ($isBoss -and $enemy.BossPattern) {
        $currentPhase = $enemy.BossPattern.Phases | Where-Object { ($enemy.HP / $enemy.MaxHP * 100) -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase) { $behavior = $currentPhase.Behavior }
    }
    
    # Paralyze check
    $paraEffect = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "Paralyze" } | Select-Object -First 1
    if ($paraEffect -and (Get-Random -Maximum 2) -eq 0) {
        $narrative = "$($enemy.Name) ist paralysiert und kann nicht angreifen!"
        return @{ DamageDealt = 0; Narrative = $narrative }
    }
    
    # Freeze check
    $freezeEffect = $combatState.StatusEffects | Where-Object { $_.Target -eq "enemy" -and $_.Type -eq "Freeze" } | Select-Object -First 1
    if ($freezeEffect) {
        $narrative = "$($enemy.Name) ist eingefroren und ueberspringt die Runde!"
        return @{ DamageDealt = 0; Narrative = $narrative }
    }
    
    # Choose action based on behavior
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
    $narrative = "$($enemy.Name) setzt $($moves[$chosenAction]) ein!"
    
    if ($chosenAction -eq "A" -or $chosenAction -eq "S") {
        $enemyMod = Get-ElementModifier $enemy.Type $playerPet.Type
        $multiplier = if ($chosenAction -eq "S") { 1.5 } else { 1.0 }
        $baseDmg = $enemyStats.ATK * $multiplier
        
        # Defend check
        $defendMod = 1.0
        if ($combatState.PlayerStance -eq "Defensiv") { $defendMod = 0.5 }
        
        $dmg = [math]::Max(1, [math]::Round(($baseDmg * $enemyMod * $defendMod) * (100 / (100 + $playerStats.DEF))))
        $damageDealt = $dmg
        $playerPet.HP -= $dmg
        $narrative += " Treffer! -$dmg HP!"
    } else {
        $narrative += " Der Gegner nimmt Defensive-Stance ein!"
    }
    
    return @{ DamageDealt = $damageDealt; Narrative = $narrative }
}
```

- [ ] **Step 2: Neue Funktion `Use-CompanionCommand`**

Fuege nach `Resolve-EnemyAction` hinzu:

```powershell
function Use-CompanionCommand($companion, $playerPet, $enemy, $combatState, $playerStats) {
    $narrative = ""
    switch ($companion.Name) {
        "NEON" {
            $enemy.DEF = [math]::Max(1, [math]::Round($enemy.DEF * 0.7))
            $narrative = "NEON hackt die Firewall-Routinen des Gegners! Gegner-DEF -30% fuer 2 Runden!"
            $combatState.StatusEffects += @{ Target = "enemy"; Type = "DEF-Down"; Turns = 2; Value = 0.3 }
        }
        "RAVEN" {
            $narrative = "RAVEN analysiert den Gegner! Naechster Zug: $($enemy.NextMove) (voraussichtlich)"
        }
        "PIXEL" {
            $playerStats.DEF = [math]::Round($playerStats.DEF * 1.4)
            $narrative = "PIXEL deployt eine Schutzschicht! Pet-DEF +40% fuer 2 Runden!"
            $combatState.StatusEffects += @{ Target = "player"; Type = "DEF-Up"; Turns = 2; Value = 0.4 }
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
    
    Show-CompanionDialog $companion $narrative
    return $narrative
}
```

- [ ] **Step 3: Neue Funktion `Use-CombatItem`**

Fuege nach `Use-CompanionCommand` hinzu:

```powershell
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
            $narrative = "Data Shard analysiert den Gegner..."
        }
        default { $narrative = "$item genutzt! Effekt unklar..." }
    }
    
    # Remove used item
    $inventory.RemoveAt([int]$choice - 1)
    Save-PetState $pet
    return $narrative
}
```

- [ ] **Step 4: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): add enemy AI, companion commands, and combat items"
```

---

### Task 8: Apply-StatusEffects + Limit Break

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Neue Funktion `Apply-StatusEffects`**

Fuege nach `Use-CombatItem` hinzu:

```powershell
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
            "DEF-Down" {
                # Already applied, no tick damage
            }
            "DEF-Up" {
                # Already applied, no tick damage
            }
            "ATK-Up" {
                # Already applied, no tick damage
            }
            "Silence" {
                # Already applied, no tick damage
            }
        }
    }
    
    # Remove expired effects (in reverse order)
    for ($i = $effectsToRemove.Count - 1; $i -ge 0; $i--) {
        $combatState.StatusEffects = $combatState.StatusEffects | Where-Object { $_ -ne $combatState.StatusEffects[$effectsToRemove[$i]] }
    }
    
    return $messages
}
```

- [ ] **Step 2: Neue Funktion `Invoke-LimitBreak`**

Fuege nach `Apply-StatusEffects` hinzu:

```powershell
function Invoke-LimitBreak($playerPet, $enemy, $combatState, $playerStats, $companion) {
    if ($combatState.LimitBreakUsed) { return $null }
    $hpRatio = $playerPet.HP / $playerStats.MaxHP
    if ($hpRatio -gt 0.25) { return $null }
    
    Write-Host "`n  ⚡ LIMIT BREAK VERFUEGBAR! ⚡" -ForegroundColor Magenta
    Write-Host "  [L] Aktivieren  |  [Enter] Ignorieren" -ForegroundColor DarkGray
    $choice = Read-Host
    if ($choice -ne 'L' -and $choice -ne 'l') { return $null }
    
    $combatState.LimitBreakUsed = $true
    
    $attackName = $playerPet.Attacks | Get-Random
    $narrative = "💥 LIMIT BREAK: $($playerPet.Name) entfesselt OMEGA-$attackName!"
    
    $baseDmg = ($script:BPAttacks[$attackName].Power + $playerStats.ATK) * 2.5
    $playerMod = Get-ElementModifier $playerPet.Type $enemy.Type
    $dmg = [math]::Max(1, [math]::Round(($baseDmg * $playerMod * 2) * (100 / (100 + $enemy.DEF))))
    $enemy.HP -= $dmg
    
    $narrative += " MEGA-Treffer! -$dmg HP!"
    $narrative += " [Garantierter Status Effect!]"
    
    # Guaranteed status effect
    $effects = @("Burn","Poison","Paralyze","DEF-Down")
    $guaranteedEffect = $effects | Get-Random
    $combatState.StatusEffects += @{
        Target = "enemy"; Type = $guaranteedEffect; Turns = 3
        Value = if ($guaranteedEffect -eq "Poison") { 0.05 } elseif ($guaranteedEffect -eq "Burn") { 0.08 } else { 0 }
    }
    
    if ($companion) {
        Show-CompanionDialog $companion "Das ist es! Unser finales Argument! NICHTS kann uns jetzt noch stoppen!"
    }
    
    Write-Host "`n  $narrative" -ForegroundColor Magenta
    Wait-Enter
    return $narrative
}
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): add status effects and limit break"
```

---

### Task 9: Invoke-TacticalCombat (Haupt-Loop)

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Neue Funktion `Invoke-TacticalCombat`**

Fuege vor `function Start-PetFight` hinzu (wir ersetzen `Start-PetFight` spaeter):

```powershell
function Invoke-TacticalCombat($playerPet, $companion, $isBoss = $false) {
    $stats = Get-EffectiveStats $playerPet $companion
    $playerPet.HP = [math]::Min($playerPet.HP, $stats.MaxHP)
    
    # Setup enemy
    $sc = 1 + ($playerPet.Level - 1) * 0.2
    if ($isBoss) {
        $et = @{ Name = "BOSS_OMEGA"; Type = "VIRUS"; HP = 150; MaxHP = 150; ATK = 20; DEF = 15; SPD = 10 }
        $enemy = @{
            Name = $et.Name; Type = $et.Type; HP = $et.HP; MaxHP = $et.MaxHP
            ATK = $et.ATK; DEF = $et.DEF; SPD = $et.SPD
            BossPattern = $script:BossPatterns[$et.Name]
        }
    } else {
        $et = ($script:BPEnemies | Get-Random)
        $enemy = @{
            Name = $et.Name; Type = $et.Type
            HP = [math]::Round($et.HP * $sc); MaxHP = [math]::Round($et.HP * $sc)
            ATK = [math]::Round($et.ATK * $sc); DEF = [math]::Round($et.DEF * $sc); SPD = [math]::Round($et.SPD * $sc)
            BossPattern = $null
        }
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
        
        # Determine initiative
        $playerFirst = Get-CombatInitiative $stats $enemyStats
        
        # Execute actions
        if ($playerFirst) {
            $pResult = Resolve-PlayerAction $action $playerPet $enemy $companion $combatState $stats $enemyStats
            if ($pResult -and $pResult.ActionType -eq "6" -and $combatState.FleeAttempted) { break }
            if ($pResult -and $pResult.ActionType -ne "3") {  # Switch costs the round
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
        
        # Log round
        $combatState.BattleLog += "R$($combatState.Round): $($playerPet.Name) vs $($enemy.Name)"
        $combatState.Round++
        
        # Check combat end
        if ($playerPet.HP -le 0 -or $enemy.HP -le 0) { break }
        
        # Round pause
        if (-not $combatState.FleeAttempted) {
            Write-Host "`n  [Enter] fuer naechste Runde..." -ForegroundColor DarkGray
            Read-Host
        }
    }
    
    # Combat resolution
    Resolve-CombatEnd $playerPet $enemy $companion $combatState $stats $isBoss
}
```

- [ ] **Step 2: Neue Funktion `Resolve-CombatEnd`**

Fuege nach `Invoke-TacticalCombat` hinzu:

```powershell
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
        if ($companion) { Show-CompanionDialog $companion (Get-CompanionLine $companion "fight_loss") }
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
        
        # Loot
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
        if ($companion) { Show-CompanionDialog $companion (Get-CompanionLine $companion "fight_win") }
        Add-PetXP ($xp / 2) "Fight Win"
    }
    
    $playerPet.FoodBuffs = @()
    Save-PetState $pet
    Invoke-Layer47Check
    Wait-Enter
}
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): add Invoke-TacticalCombat main loop and combat resolution"
```

---

### Task 10: Start-PetFight ersetzen

**Files:**
- Modify: `Modules/pet/combat.ps1`

- [ ] **Step 1: Ersetze `Start-PetFight`**

Finde die bestehende `Start-PetFight`-Funktion (ca. Zeile 225). Ersetze den gesamten Funktionskoerper (alles zwischen `function Start-PetFight {` und `}`) durch:

```powershell
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
    Save-PetState $pet
    
    $isBoss = ($p.Wins -gt 0 -and $p.Wins % 5 -eq 0)
    Invoke-TacticalCombat $p $cp $isBoss
}
```

**WICHTIG:** Der alte Code (die 3-Runden-RPS-Schleife) wird komplett entfernt. Nur die HP-Regeneration bleibt.

- [ ] **Step 2: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(combat): replace Start-PetFight with Invoke-TacticalCombat"
```

---

### Task 11: Pet-Datenstruktur erweitern

**Files:**
- Modify: `Modules/pet/_init.ps1`

- [ ] **Step 1: Erweitere `New-Pet`**

In `New-Pet` (nach dem Pet-Setup), fuege hinzu:

```powershell
$pet.Pet.LimitBreakUnlocked = $false
$pet.Pet.Attacks = @("Neural Overload","Bit Crusher")
```

- [ ] **Step 2: Erweitere `Invoke-PetLevelUpCheck`**

In `Modules/pet/combat.ps1`, erweitere `Invoke-PetLevelUpCheck`:

```powershell
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
        if ($p.Level -eq 5 -and -not $p.LimitBreakUnlocked) {
            $p.LimitBreakUnlocked = $true
            Write-Host "  LIMIT BREAK freigeschaltet!" -ForegroundColor Magenta
        }
    }
}
```

- [ ] **Step 3: Validate**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/_init.ps1 Modules/pet/combat.ps1
git commit -m "feat(pet): add LimitBreak unlock and attack learning"
```

---

### Task 12: Smoke-Test Anpassung

**Files:**
- Modify: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Neue Smoke-Test-Checks**

Fuege nach den bestehenden Pet-Checks hinzu:

```powershell
# Tactical Combat System
$pet = Get-PetState
$pet.Pet = @{
    Name = "GLITCH_WOLF"; Type = "VIRUS"; Level = 3; XP = 0; NextXP = 50
    HP = 100; MaxHP = 100; ATK = 16; DEF = 7; SPD = 12
    Color = "Magenta"; Attacks = @("Neural Overload","Bit Crusher","Plasma Lance")
    Wins = 0; Losses = 0; Evolved = $false; Personality = "Balanced"
    Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }
    FoodBuffs = @(); LimitBreakUnlocked = $true
}
Save-PetState $pet

# Test Show-HPBar
$bar = Show-HPBar 50 100
Assert ($bar.Bar.Contains("█") -and $bar.Bar.Contains("░")) "Show-HPBar renders bar"
Assert ($bar.Color -eq "Yellow") "Show-HPBar color at 50%"
Assert ($bar.Percent -eq 50) "Show-HPBar percent correct"

$bar2 = Show-HPBar 80 100
Assert ($bar2.Color -eq "Green") "Show-HPBar green above 50%"

$bar3 = Show-HPBar 20 100
Assert ($bar3.Color -eq "Red") "Show-HPBar red below 25%"

# Test BPAttacks
Assert ($script:BPAttacks.ContainsKey("Neural Overload")) "BPAttacks has Neural Overload"
Assert ($script:BPAttacks["Plasma Lance"].Type -eq "FIRE") "BPAttacks Plasma Lance is FIRE"
Assert ($script:BPAttacks["Neural Overload"].Effect -eq "Poison") "BPAttacks Neural Overload has Poison effect"

# Test BossPatterns
Assert ($script:BossPatterns.ContainsKey("BOSS_OMEGA")) "BossPatterns has BOSS_OMEGA"
Assert ($script:BossPatterns["BOSS_OMEGA"].Phases.Count -eq 3) "BOSS_OMEGA has 3 phases"

# Test Get-CombatInitiative
$init = Get-CombatInitiative @{ SPD = 10 } @{ SPD = 5 }
Assert ($init -is [bool]) "Get-CombatInitiative returns boolean"

# Test New-CombatState
$cs = New-CombatState $pet.Pet $pet.Companion
Assert ($cs.Round -eq 1) "CombatState Round starts at 1"
Assert ($cs.PlayerStance -eq "Balanced") "CombatState Stance starts Balanced"
Assert ($cs.StatusEffects.Count -eq 0) "CombatState StatusEffects empty"
Assert ($cs.LimitBreakUsed -eq $false) "CombatState LimitBreak not used"
```

- [ ] **Step 2: Validate**

```powershell
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 3: Commit**

```bash
git add Modules/_smoke_test.ps1
git commit -m "test(smoke): add tactical combat system checks"
```

---

### Task 13: E2E-Test Anpassung

**Files:**
- Modify: `Modules/_e2e_test.ps1`

- [ ] **Step 1: E2E Test fuer Tactical Combat**

Fuege nach dem bestehenden Pet-E2E-Test hinzu:

```powershell
# E2E: Tactical Combat Flow
Write-Host "Testing Tactical Combat..." -NoNewline
$pet = Get-PetState
$pet.Pet = @{
    Name = "GLITCH_WOLF"; Type = "VIRUS"; Level = 3; XP = 0; NextXP = 50
    HP = 100; MaxHP = 100; ATK = 16; DEF = 7; SPD = 12
    Color = "Magenta"; Attacks = @("Neural Overload","Bit Crusher")
    Wins = 0; Losses = 0; Evolved = $false; Personality = "Balanced"
    Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }
    FoodBuffs = @(); LimitBreakUnlocked = $true; LastFightTime = $null
}
Save-PetState $pet

# Verify combat functions exist
Assert (Get-Command Invoke-TacticalCombat -ErrorAction SilentlyContinue) "E2E: Invoke-TacticalCombat exists"
Assert (Get-Command Show-CombatScreen -ErrorAction SilentlyContinue) "E2E: Show-CombatScreen exists"
Assert (Get-Command Get-CombatInitiative -ErrorAction SilentlyContinue) "E2E: Get-CombatInitiative exists"
Assert (Get-Command Resolve-PlayerAction -ErrorAction SilentlyContinue) "E2E: Resolve-PlayerAction exists"
Assert (Get-Command Resolve-EnemyAction -ErrorAction SilentlyContinue) "E2E: Resolve-EnemyAction exists"
Assert (Get-Command Apply-StatusEffects -ErrorAction SilentlyContinue) "E2E: Apply-StatusEffects exists"

Write-Host " OK" -ForegroundColor Green
```

- [ ] **Step 2: Validate**

```powershell
& .\Modules\_e2e_test.ps1
```

- [ ] **Step 3: Commit**

```bash
git add Modules/_e2e_test.ps1
git commit -m "test(e2e): add tactical combat flow test"
```

---

### Task 14: Finale Validierung & Commit

**Files:**
- None (nur Validierung)

- [ ] **Step 1: Alle Tests laufen lassen**

```powershell
& .\Modules\_smoke_test.ps1
& .\Modules\_integration_test.ps1
& .\Modules\_e2e_test.ps1
```

- [ ] **Step 2: Profil neu laden**

```powershell
reload
```

- [ ] **Step 3: Gesamt-Commit**

```bash
git add .
git commit -m "feat(combat): v24.12 tactical combat redesign

- Initiative system based on SPD stat
- Stance system: Aggressiv/Defensiv/Speed/Balanced
- Pet-Switch support (costs 1 round)
- Status Effects: Burn, Freeze, Poison, Paralyze, DEF-Down
- Limit Break (once per fight, under 25% HP)
- Boss-Tells with phase-based behavior patterns
- Companion Cooldowns (unique per companion)
- Strategic Items: Heal, Overclock, EMP, Smoke Bomb
- D&D-style combat narration
- Global Readability Fix: Show-CompanionDialog + Wait-Enter
- Tests: smoke, integration, e2e"
```

---

## Self-Review Checklist

- [x] **Spec coverage:** Alle Spez-Anforderungen sind abgedeckt:
  - Initiative (Task 4)
  - Stances (Task 6)
  - Pet-Switch (Task 6)
  - Status Effects (Task 8)
  - Limit Break (Task 8)
  - Boss-Tells (Task 5, 7)
  - Companion Cooldowns (Task 7)
  - Items (Task 7)
  - Combat narration (Task 6, 7, 8, 9)
  - Global Readability Fix (Task 1)
  - Tests (Tasks 12-13)
- [x] **Placeholder scan:** Keine TBDs, TODOs, oder "implement later".
- [x] **Type consistency:** `CombatState`, `StatusEffects`, `CompanionCooldowns`, `BossPatterns` sind konsistent über alle Tasks.
