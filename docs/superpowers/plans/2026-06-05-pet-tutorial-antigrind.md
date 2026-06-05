# Pet System Anti-Grind Tutorial — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans for inline execution.

**Goal:** Add a LucasArts-style interactive tutorial to the Pet System that eliminates early-game talk-grind by boosting new players to Meta-Level 3 immediately.

**Architecture:** A 4-step state-machine tutorial (`Invoke-PetTutorial`) runs before the hub menu on first `pet` call. Each step awards XP and delivers character-specific dialog. A scripted first fight guarantees a win. Existing saves are migrated to skip the tutorial automatically.

**Tech Stack:** PowerShell 7/5.1, BUXE_OS State System (`engine-state-core.ps1`)

---

### Task 1: State Schema + Migration + XP Balance

**Files:**
- Modify: `Modules/pet/_init.ps1`
- Modify: `Modules/pet/companion.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Modify `Get-PetDefaults` in `_init.ps1` — add `Tutorial` hashtable**

Replace the `Get-PetDefaults` function body (lines 21-43):

```powershell
function Get-PetDefaults {
    return @{
        Meta = @{
            Level = 0
            XP = 0
            Unlocked = @("talk", "companion_create")
            FirstBoot = (Get-Date -Format "yyyy-MM-dd")
            TotalSessions = 0
            PlayTimeMinutes = 0
            EasterEggsFound = @()
            Stats = @{
                TalkCount = 0; GiftCount = 0; PunishCount = 0
                FightCount = 0; WorkCount = 0; TrainCount = 0
            }
            QuestDate = ""
        }
        Companion = $null
        Pet = $null
        Economy = @{ Gold = 500; Inventory = @() }
        Achievements = @()
        Memories = @()
        Tutorial = @{
            Completed = $false
            Step = 0
            Skipped = $false
        }
    }
}
```

- [ ] **Step 2: Modify `Get-PetState` in `_init.ps1` — migrate existing saves**

Replace the `Get-PetState` function body (lines 45-52):

```powershell
function Get-PetState {
    Load-State
    if (-not $script:BuxeState.Pet) {
        $script:BuxeState.Pet = (Get-PetDefaults)
        Save-State
    } else {
        # Migration: existing saves before tutorial feature
        if (-not $script:BuxeState.Pet.ContainsKey("Tutorial")) {
            $script:BuxeState.Pet.Tutorial = @{
                Completed = $true
                Step = 0
                Skipped = $false
            }
            Save-State
        }
    }
    return $script:BuxeState.Pet
}
```

- [ ] **Step 3: Reduce Lv 1 XP threshold in `_init.ps1`**

Replace line 6:

```powershell
$script:PetXPTable = @(0, 3, 15, 40, 100, 300, 600, 1200, 2500, 5000, 10000)
```

- [ ] **Step 4: Increase Talk XP in `companion.ps1`**

In `Invoke-CompanionAction`, line 51, change:

```powershell
$xpGain = if ($isFirstTalk) { 3 } else { 2 }
```

- [ ] **Step 5: Run smoke test**

Run: `& "$PSScriptRoot\Modules\_smoke_test.ps1"`
Expected: PASS (all checks green)

- [ ] **Step 6: Commit**

```bash
git add Modules/pet/_init.ps1 Modules/pet/companion.ps1
git commit -m "feat(pet): add Tutorial state schema, reduce Lv1 XP, buff Talk XP"
```

---

### Task 2: Tutorial Dialog Engine

**Files:**
- Modify: `Modules/pet/companion.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Add `Get-TutorialLines` function to `companion.ps1`**

Insert after line 28 (after `New-Companion` function, before `Invoke-CompanionAction`):

```powershell
function Get-TutorialLines($companionName, $step) {
    $lines = @{
        "NEON" = @{
            2 = @("Warte. Du willst mich 15 Mal anquatschen, um was Cooles zu sehen? Lass mich das beschleunigen.","*seufz* Tutorial-Modus. Ich hasse Tutorials. Aber ich hasse Grind noch mehr.")
            3 = @("Bestechung. Klassisch. Aber hey, ich akzeptiere RAM-Sticks als Waehrung.","Ein Geschenk? Fuer mich? Das... ist verdächtig. Aber ich nehm's.")
            4 = @("ENDLICH. Etwas, das sich bewegt. Nicht nur Text. Hier, nimm XP. Und nie wieder quatschen zum Leveln.","Dein erstes Opfer. Wie suess. Vorsicht, der hat nur 70 HP.")
            "skip" = @("*rollt mit den Augen* Ungeduldig. Typischer User. Hier, nimm die halbe Menge.")
        }
        "RAVEN" = @{
            2 = @("Ineffizient. Ich habe den XP-Node direkt manipuliert. Du bist willkommen.","Ich sehe 47 Schleifen in deiner Zukunft. Lass mich das verhindern.")
            3 = @("Eine Investition. Akzeptabel.","Ein Geschenk. Die Datenlage verbessert sich.")
            4 = @("Dein erstes Opfer. Wie suess.","Zeit, die Schwachen zu eliminieren.")
            "skip" = @("Ungeduld. Eine Schwäche. Aber eine, die ich verstehe.")
        }
        "PIXEL" = @{
            2 = @("Oh. Du... du willst reden? Äh, ok. Ich kann das schneller machen. Wenn du willst.","*murmel* Ich baue gerade etwas. Aber Tutorial geht vor.")
            3 = @("F-fuer mich? Das ist... das ist wirklich nett. Danke!","*errötet* Ich werde das nie vergessen. Naja, virtuell nie.")
            4 = @("K-kampfzeit! Ich cheere. Lautlos. Virtuell.","Du schaffst das! Ich glaube an dich. Und an deine Stats.")
            "skip" = @("Oh. Du hast es eilig. Ist... ist das meine Schuld?")
        }
        "LUNA" = @{
            2 = @("*lächelt* Keine Sorge. Ich kenne einen schnelleren Weg.","Du musst nicht alles alleine herausfinden. Ich helfe.")
            3 = @("*errötet* Das... das ist wirklich suess. Danke.","Ein Geschenk? Du hättest nicht müssen. Aber es freut mich.")
            4 = @("Zeit für deinen ersten Kampf! Ich bin hier, falls du verletzt wirst. Virtuell.","Gib acht auf dich. Aber... du wirst gewinnen. Versprochen.")
            "skip" = @("*besorgt* Bist du sicher? Naja, ich verstehe. Du bist beschäftigt.")
        }
        "IVY" = @{
            2 = @("... *schaut zur Seite* Ich habe das alles schon gesehen. 47 Mal.","*nickt langsam* Schneller. Gut.")
            3 = @("... *hält das Geschenk fest* Danke.","*leises Lächeln* Das ist... nett.")
            4 = @("... *zeigt auf Gegner* Da.","*flüsternd* Er wird fallen.")
            "skip" = @("... *leises Seufzen* Eilig.")
        }
        "VERA" = @{
            2 = @("Ich habe den XP-Algorithmus analysiert. Er ist suboptimal. Hier ist ein Patch.","Tutorial-Overhead reduziert um 73%. Effizienter geht's nicht.")
            3 = @("Ein Geschenk? Die Syntax ist akzeptabel. Ich nehme es.","Input akzeptiert. Beziehungs-Variable steigt.")
            4 = @("Gegner-Analyse: SPAM_BOT. HP: 70. Schwachstelle: Alles. Viel Spass.","Dein erster Kampf. Statistisch gesehen: 97% Siegchance. Nicht schlecht.")
            "skip" = @("Zeitoptimierung. Verstaendlich. Hier ist ein reduzierter Datensatz.")
        }
        "JINX" = @{
            2 = @("Error 418: Ich bin eine Teekanne. Und du bist in einer Schleife. Lass mich das fixen.","47 Mal musstest du sonst reden! 47! Stell dir das vor!")
            3 = @("Ein Geschenk? Ist es ein Einhorn? Nein? Schade. Ich nehm's trotzdem.","Yay! Loot! Virtueller Loot! Der beste Loot!")
            4 = @("Kampfzeit! *wirft virtuellen Konfetti* 47 XP fuer dich! Oder waren es 40? Ich bin schlecht im Kopfrechnen.","POW! BAM! ZACK! So klingt Kampf in meinem Kopf!")
            "skip" = @("Skip? SKIP?! *seufz* Ok. Aber du verpasst den besten Witz. Den mit der 47.")
        }
    }
    $pool = $lines[$companionName]
    if (-not $pool) { return "..." }
    return ($pool[$step] | Get-Random)
}
```

- [ ] **Step 2: Run smoke test**

Run: `& "$PSScriptRoot\Modules\_smoke_test.ps1"`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/companion.ps1
git commit -m "feat(pet): add tutorial dialog engine with LucasArts voices"
```

---

### Task 3: Tutorial Orchestrator (Hub)

**Files:**
- Modify: `Modules/pet/hub.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Add `Invoke-PetTutorial` function to `hub.ps1`**

Insert after line 3 (after the opening `try {`):

```powershell
function Invoke-PetTutorial {
    $pet = Get-PetState
    $cp = $pet.Companion
    $today = Get-Date -Format "yyyy-MM-dd"
    
    # Step 0/1: Companion creation if none exists
    if (-not $cp) {
        New-Companion
        $pet = Get-PetState
        $cp = $pet.Companion
        Add-PetXP 5 "Tutorial: Companion Created"
        $pet.Tutorial.Step = 1
        Save-PetState $pet
    }
    
    # Step 2: First Talk (Accelerated)
    if ($pet.Tutorial.Step -lt 2) {
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — KOMMUNIKATION" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 2
        Show-CompanionDialog $cp $line
        Write-Host ""
        Write-Host "  [Enter] Weiter  |  [S] Skip" -ForegroundColor DarkGray
        $raw = Read-Host
        if ($raw -eq 'S' -or $raw -eq 's') {
            Invoke-TutorialSkip $cp
            return
        }
        $pet.Meta.Stats.TalkCount++
        $cp.Talks++
        $cp.Bond = [math]::Min(100, $cp.Bond + 5)
        Add-PetXP 10 "Tutorial: First Talk"
        $pet.Tutorial.Step = 2
        Save-PetState $pet
    }
    
    # Step 3: First Gift (Accelerated)
    if ($pet.Tutorial.Step -lt 3) {
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — BESCHERUNG" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 3
        Show-CompanionDialog $cp $line
        Write-Host ""
        Write-Host "  (Du gibst $($cp.Name) ein virtuelles Geschenk.)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [Enter] Weiter  |  [S] Skip" -ForegroundColor DarkGray
        $raw = Read-Host
        if ($raw -eq 'S' -or $raw -eq 's') {
            Invoke-TutorialSkip $cp
            return
        }
        $pet.Meta.Stats.GiftCount++
        $cp.Gifts++
        $cp.Bond = [math]::Min(100, $cp.Bond + 10)
        $cp.Mood = "Happy"
        Add-PetXP 10 "Tutorial: First Gift"
        Unlock-PetFeature "gift"
        Unlock-PetFeature "mood"
        $pet.Tutorial.Step = 3
        Save-PetState $pet
    }
    
    # Step 4: Battlepet + First Fight
    if ($pet.Tutorial.Step -lt 4) {
        if (-not $pet.Pet) {
            New-Pet
            $pet = Get-PetState
            $cp = $pet.Companion
        }
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — ERSTER KAMPF" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 4
        Show-CompanionDialog $cp $line
        Write-Host ""
        Write-Host "  [Enter] Kampf starten  |  [S] Skip" -ForegroundColor DarkGray
        $raw = Read-Host
        if ($raw -eq 'S' -or $raw -eq 's') {
            Invoke-TutorialSkip $cp
            return
        }
        Start-PetTutorialFight
        Add-PetXP 15 "Tutorial: First Fight"
        Unlock-PetFeature "pet_create"
        Unlock-PetFeature "combat"
        Unlock-PetFeature "train"
        Unlock-PetFeature "work"
        Unlock-PetFeature "gold"
        Unlock-PetFeature "shop"
        Unlock-PetFeature "cooking"
        Unlock-PetFeature "equipment"
        $pet.Tutorial.Step = 4
        $pet.Tutorial.Completed = $true
        Save-PetState $pet
    }
}

function Invoke-TutorialSkip($cp) {
    $pet = Get-PetState
    $line = Get-TutorialLines $cp.Name "skip"
    Show-CompanionDialog $cp $line -Fast
    Add-PetXP 25 "Tutorial Skipped"
    Unlock-PetFeature "gift"
    Unlock-PetFeature "mood"
    Unlock-PetFeature "pet_create"
    Unlock-PetFeature "combat"
    Unlock-PetFeature "train"
    Unlock-PetFeature "work"
    Unlock-PetFeature "gold"
    Unlock-PetFeature "shop"
    Unlock-PetFeature "cooking"
    Unlock-PetFeature "equipment"
    $pet.Tutorial.Skipped = $true
    $pet.Tutorial.Completed = $true
    $pet.Tutorial.Step = 4
    Save-PetState $pet
    Write-Host ""
    Write-Host "  [TUTORIAL UEBERSPRUNGEN] +25 XP | Features freigeschaltet." -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
}
```

- [ ] **Step 2: Modify `pet` function entry point**

In `pet` function (line 6), after the param block and before the `$Action` switch, add the tutorial check. Replace lines 8-12:

```powershell
    $pet = Get-PetState
    # Run tutorial for first-time users
    if (-not $pet.Tutorial.Completed) {
        Invoke-PetTutorial
        $pet = Get-PetState
    }
    if (-not $pet.Companion -and -not ($Action -eq "create" -or $Action -eq "")) {
        Write-Host "Kein Companion. Tippe 'pet' um zu starten." -ForegroundColor Red
        return
    }
```

- [ ] **Step 3: Run smoke test**

Run: `& "$PSScriptRoot\Modules\_smoke_test.ps1"`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/hub.ps1
git commit -m "feat(pet): add tutorial orchestrator with skip support"
```

---

### Task 4: Scripted Tutorial Fight

**Files:**
- Modify: `Modules/pet/combat.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Add `Start-PetTutorialFight` to `combat.ps1`**

Insert after line 46 (after `New-Pet` function):

```powershell
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
```

- [ ] **Step 2: Run smoke test**

Run: `& "$PSScriptRoot\Modules\_smoke_test.ps1"`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/combat.ps1
git commit -m "feat(pet): add scripted tutorial fight with companion commentary"
```

---

### Task 5: E2E Game-Flow Test

**Files:**
- Modify: `Modules/_e2e_test.ps1`

- [ ] **Step 1: Add Pet Tutorial flow to E2E test**

Locate the E2E test file and add a new test block after the existing pet-related tests (or at the end if none exist). The E2E test uses `Enable-MockInput` and `Queue-MockInput` to simulate user input.

Add this test function:

```powershell
function Test-PetTutorial {
    Write-Host "`n[E2E] Pet Tutorial Flow..." -ForegroundColor Cyan
    
    # Reset pet state for fresh tutorial
    Load-State
    $script:BuxeState.Pet = (Get-PetDefaults)
    $script:BuxeState.Pet.Tutorial = @{ Completed = $false; Step = 0; Skipped = $false }
    Save-State
    
    # Mock input: Enter (step 1), Enter (step 2), Enter (step 3), A, A, A (fight)
    Enable-MockInput
    Queue-MockInput ""
    Queue-MockInput ""
    Queue-MockInput ""
    Queue-MockInput "A"
    Queue-MockInput "A"
    Queue-MockInput "A"
    
    pet | Out-Null
    
    Disable-MockInput
    
    $pet = Get-PetState
    $pass = ($pet.Tutorial.Completed -eq $true) -and ($pet.Meta.XP -ge 40) -and ($pet.Meta.Unlocked -contains "combat")
    Write-Host "  Pet Tutorial: $(if($pass){'PASS'}else{'FAIL'})" -ForegroundColor $(if($pass){'Green'}else{'Red'})
    return $pass
}
```

Then add `Test-PetTutorial` to the list of tests that run at the bottom of `_e2e_test.ps1`.

- [ ] **Step 2: Run E2E test**

Run: `& "$PSScriptRoot\Modules\_e2e_test.ps1"`
Expected: PASS (including new Pet Tutorial test)

- [ ] **Step 3: Commit**

```bash
git add Modules/_e2e_test.ps1
git commit -m "test(pet): add E2E test for tutorial flow"
```

---

### Task 6: Integration + Final Verification

**Files:**
- All modified files

- [ ] **Step 1: Run full test suite**

```bash
& "$PSScriptRoot\Modules\_smoke_test.ps1"
& "$PSScriptRoot\Modules\_integration_test.ps1"
& "$PSScriptRoot\Modules\_e2e_test.ps1"
```

Expected: All PASS

- [ ] **Step 2: Verify state migration**

Temporarily simulate an old save:
```powershell
Load-State
$script:BuxeState.Pet.Remove("Tutorial")
Save-State
$pet = Get-PetState
# Verify: $pet.Tutorial.Completed -eq $true
```

- [ ] **Step 3: Final commit**

```bash
git add docs/superpowers/specs/2026-06-05-pet-tutorial-antigrind-design.md docs/superpowers/plans/2026-06-05-pet-tutorial-antigrind.md
git commit -m "docs: add pet tutorial spec and implementation plan"
```

---

## Self-Review Checklist

- [x] **Spec coverage:** Every requirement from the spec has a corresponding task.
  - Tutorial 4-step flow → Task 3
  - Character-specific dialog → Task 2
  - Skippable with half XP → Task 3 (Invoke-TutorialSkip)
  - State schema + migration → Task 1
  - XP balance (Talk 1→2, Lv1 5→3) → Task 1
  - Scripted first fight → Task 4
  - LucasArts compliance → Tasks 2+4
- [x] **Placeholder scan:** No TBD, TODO, or vague instructions.
- [x] **Type consistency:** `Tutorial` hashtable structure matches in `_init.ps1`, `hub.ps1`, and E2E test.
- [x] **File paths:** All paths are exact and relative to `Modules/pet/`.
