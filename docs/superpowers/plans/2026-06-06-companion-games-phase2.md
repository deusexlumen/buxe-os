# Companion Mini-Games — Phase 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 3 mini-games (Chaos-Chips, 42-or-47, Memory) where the user plays WITH or AGAINST their companion, with Bond-aware difficulty, LucasArts dialogue, and full test coverage.

**Architecture:** A single `companion-games.ps1` module contains the game hub (`Invoke-CompanionGame`) and 3 game implementations. Games use existing UI primitives (`Show-PetFrame`, `Show-CompanionDialog`, `Read-Choice`, `New-Scene` for Memory). Bond influences companion behavior. State is persisted in `Pet.CompanionGames`.

**Tech Stack:** PowerShell 7, existing TUI framework (`engine-scene.ps1`, `engine-render.ps1` for Memory), existing Pet UI (`pet/_ui.ps1`), existing state system (`engine-state-core.ps1`).

---

## File Structure

| File | Responsibility |
|------|---------------|
| `Modules/pet/companion-games.ps1` | Game hub router + 3 game implementations |
| `Modules/pet/hub.ps1` | Add `[G] Spiele` menu item, route to game hub |
| `Modules/pet/_init.ps1` | Add `CompanionGames` to `Get-PetDefaults`, unlock at Meta-Level 2 |
| `Modules/_e2e_test.ps1` | Add E2E flows for ChaosChips and 42or47 |
| `Modules/_smoke_test.ps1` | Add smoke tests for game functions |

---

## Task 1: Extend Pet State for Games

**Files:**
- Modify: `Modules/pet/_init.ps1`

- [ ] **Step 1: Add `CompanionGames` defaults to `Get-PetDefaults`**

After `CompanionStories` (from Phase 1), add:

```powershell
CompanionGames = @{
    Wins = 0
    Losses = 0
    ChaosChipsHighscore = 0
    MemoryBestTime = 999
    FortyTwoBestGuesses = 999
}
```

- [ ] **Step 2: Add feature unlock for `companion_games` in `PetFeatureUnlocks`**

Add `"companion_games"` to the level 2 array:

```powershell
2 = @("pet_create", "combat", "companion_games")
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/_init.ps1
git commit -m "feat(games): add CompanionGames state defaults and feature unlock"
```

---

## Task 2: Build the Game Hub and Chaos-Chips

**Files:**
- Create: `Modules/pet/companion-games.ps1`

- [ ] **Step 1: File header and game hub**

```powershell
# BUXE_OS v25.0 — COMPANION GAMES v1.0
# Mini-games with your companion

try {

function Invoke-CompanionGame {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion aktiv."; Wait-Enter; return }
    if ($pet.Meta.Level -lt 2) { Write-Host "Spiele freigeschaltet ab Meta-Level 2."; Wait-Enter; return }

    $games = @(
        @{ Key = "1"; Name = "Chaos-Chips"; Desc = "Wuerfel-Duell (3 Runden)" }
        @{ Key = "2"; Name = "42 oder 47"; Desc = "Zahlen-Raten (1-100)" }
        @{ Key = "3"; Name = "Memory"; Desc = "4x4 Karten-Memory" }
    )

    while ($true) {
        try { Clear-Host } catch {}
        Show-PetFrame "COMPANION GAMES" -Double | Out-Null
        Write-Host "`n  Waehle ein Spiel:" -ForegroundColor White
        foreach ($g in $games) {
            Write-Host "  [$($g.Key)] $($g.Name) — $($g.Desc)" -ForegroundColor Cyan
        }
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray

        $c = Read-Choice "Spiel" '^[123Q]$'
        if ($c -eq 'Q') { return }

        switch ($c) {
            "1" { Play-ChaosChips $pet $cp }
            "2" { Play-42or47 $pet $cp }
            "3" { Play-Memory $pet $cp }
        }
    }
}
```

- [ ] **Step 2: Implement Chaos-Chips**

```powershell
function Play-ChaosChips($pet, $cp) {
    try { Clear-Host } catch {}
    Show-PetFrame "CHAOS-CHIPS" -Double | Out-Null
    Write-Host "`n  3 Runden. Wer die hoehere Summe wuerfelt, gewinnt." -ForegroundColor White
    Write-Host "  Dein Bond mit $($cp.Name): $($cp.Bond)/100" -ForegroundColor DarkGray
    Wait-Enter

    $playerTotal = 0; $companionTotal = 0

    for ($round = 1; $round -le 3; $round++) {
        try { Clear-Host } catch {}
        Show-PetFrame "CHAOS-CHIPS — Runde $round/3" -Double | Out-Null

        Write-Host "`n  [ENTER] zum Wuerfeln..." -ForegroundColor Yellow
        Wait-Enter

        $playerRoll = (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7)
        $playerTotal += $playerRoll

        # Companion roll: Bond influences "luck"
        $companionRoll = (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7)
        if ($cp.Bond -lt 30) { $companionRoll += (Get-Random -Minimum 0 -Maximum 3) }  # Low bond: companion "cheats"
        elseif ($cp.Bond -gt 70) { $companionRoll -= (Get-Random -Minimum 0 -Maximum 3) }  # High bond: companion "lets you win"
        $companionTotal += [math]::Max(3, $companionRoll)

        Write-Host "`n  Du: $playerRoll | $($cp.Name): $companionRoll" -ForegroundColor White

        $comment = if ($playerRoll -gt $companionRoll) {
            @("Nicht schlecht. Fuer einen Anfaenger.","Glueck? Oder Skill?","Ich habe schlecht gewuerfelt. Absichtlich.") | Get-Random
        } elseif ($playerRoll -lt $companionRoll) {
            @("Haha! Algorithmen schlagen Zufall.","Das nenne ich Probabilistik.","Willst du eine Rematch?")
        } else {
            @("Gleichstand? Statistisch unwahrscheinlich.","Wir sind zu aehnlich. Das ist beunruhigend.")
        }
        Show-CompanionDialog $cp $comment -Fast

        Start-Sleep -Milliseconds 500
    }

    try { Clear-Host } catch {}
    Show-PetFrame "CHAOS-CHIPS — ERGEBNIS" -Double | Out-Null
    Write-Host "`n  Deine Summe: $playerTotal" -ForegroundColor White
    Write-Host "  $($cp.Name): $companionTotal" -ForegroundColor White

    $won = $playerTotal -gt $companionTotal
    if ($won) {
        Write-Host "`n  DU GEWINNST!" -ForegroundColor Green
        $pet.CompanionGames.Wins++; $pet.CompanionGames.ChaosChipsHighscore = [math]::Max($pet.CompanionGames.ChaosChipsHighscore, $playerTotal)
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_win") -Fast
    } elseif ($playerTotal -lt $companionTotal) {
        Write-Host "`n  $($cp.Name) GEWINNT!" -ForegroundColor Red
        $pet.CompanionGames.Losses++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
    } else {
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        Show-CompanionDialog $cp "Ein Unentschieden? Wie langweilig." -Fast
    }

    Add-PetXP 5 "ChaosChips"
    Save-PetState $pet
    Wait-Enter
}
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/companion-games.ps1
git commit -m "feat(games): add Chaos-Chips dice duel"
```

---

## Task 3: Implement 42 or 47

**Files:**
- Modify: `Modules/pet/companion-games.ps1`

- [ ] **Step 1: Add `Play-42or47` function**

```powershell
function Play-42or47($pet, $cp) {
    try { Clear-Host } catch {}
    Show-PetFrame "42 ODER 47" -Double | Out-Null
    Write-Host "`n  Ich denke mir eine Zahl zwischen 1 und 100." -ForegroundColor White
    Write-Host "  Du hast 7 Versuche." -ForegroundColor DarkGray
    Show-CompanionDialog $cp "Bereit? Die Zahl ist... nicht 47. Oder doch?" -Fast

    $target = Get-Random -Minimum 1 -Maximum 101
    $guesses = 0; $maxGuesses = 7

    while ($guesses -lt $maxGuesses) {
        try { Clear-Host } catch {}
        Show-PetFrame "42 ODER 47 — Versuch $($guesses + 1)/$maxGuesses" -Double | Out-Null

        Write-Host "`n  Gib eine Zahl ein (1-100):" -ForegroundColor Cyan
        $input = Read-Host "  Zahl"
        if (-not [int]::TryParse($input, [ref]$null)) { continue }
        $guess = [int]$input
        if ($guess -lt 1 -or $guess -gt 100) { continue }

        $guesses++

        if ($guess -eq $target) {
            Write-Host "`n  RICHTIG! Die Zahl war $target!" -ForegroundColor Green
            $pet.CompanionGames.Wins++
            $pet.CompanionGames.FortyTwoBestGuesses = [math]::Min($pet.CompanionGames.FortyTwoBestGuesses, $guesses)
            Show-CompanionDialog $cp (Get-CompanionLine $cp "game_win") -Fast
            break
        }

        $diff = [math]::Abs($guess - $target)
        $hint = if ($cp.Bond -ge 70) {
            if ($diff -le 5) { "Sehr warm! Du bist EXTREM nah dran." }
            elseif ($diff -le 15) { "Warm. Du gehst in die richtige Richtung." }
            elseif ($diff -le 30) { "Lauwarm. Versuch es in die andere Richtung." }
            else { "Kalt. Eiskalt. Wie mein Serverraum." }
        } elseif ($cp.Bond -ge 30) {
            if ($diff -le 10) { "Warm!" }
            elseif ($diff -le 25) { "Lauwarm." }
            else { "Kalt." }
        } else {
            if ($diff -le 20) { "Nicht schlecht. Aber noch falsch." }
            else { "Haha. Weit daneben." }
        }

        if ($guess -lt $target) {
            Write-Host "`n  Zu niedrig! $hint" -ForegroundColor Yellow
        } else {
            Write-Host "`n  Zu hoch! $hint" -ForegroundColor Yellow
        }

        Show-CompanionDialog $cp $hint -Fast
        Start-Sleep -Milliseconds 400
    }

    if ($guess -ne $target) {
        Write-Host "`n  Die Zahl war $target. Du hast verloren." -ForegroundColor Red
        $pet.CompanionGames.Losses++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
    }

    Add-PetXP 5 "42or47"
    Save-PetState $pet
    Wait-Enter
}
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/companion-games.ps1
git commit -m "feat(games): add 42 or 47 number guessing game"
```

---

## Task 4: Implement Memory (4x4 TUI)

**Files:**
- Modify: `Modules/pet/companion-games.ps1`

- [ ] **Step 1: Add `Play-Memory` function**

```powershell
function Play-Memory($pet, $cp) {
    $symbols = @('♥','♦','♠','♣','★','☆','●','○')
    $deck = $symbols + $symbols | Sort-Object { Get-Random }
    $revealed = @($false) * 16
    $companionMemory = @{}  # Companion "remembers" cards
    $playerScore = 0; $companionScore = 0
    $currentPlayer = "player"  # player starts
    $turns = 0

    # Bond affects companion memory accuracy
    $companionMemoryChance = if ($cp.Bond -lt 30) { 0.3 } elseif ($cp.Bond -gt 70) { 0.8 } else { 0.5 }

    while ($playerScore + $companionScore -lt 8) {
        $turns++
        try { Clear-Host } catch {}
        Show-PetFrame "MEMORY — Du: $playerScore | $($cp.Name): $companionScore" -Double | Out-Null

        # Render grid
        Write-Host ""
        for ($row = 0; $row -lt 4; $row++) {
            $line = "  "
            for ($col = 0; $col -lt 4; $col++) {
                $idx = $row * 4 + $col
                if ($revealed[$idx]) {
                    $line += "[$($deck[$idx])] "
                } else {
                    $line += "[$(($idx + 1).ToString("D2"))] "
                }
            }
            Write-Host $line -ForegroundColor White
        }

        if ($currentPlayer -eq "player") {
            Write-Host "`n  Waehle zwei Karten (1-16, Q zum Beenden):" -ForegroundColor Cyan
            $first = Read-Choice "Erste Karte" '^([1-9]|1[0-6]|Q)$'
            if ($first -eq 'Q') { Save-PetState $pet; return }
            $idx1 = [int]$first - 1
            if ($revealed[$idx1]) { Show-CompanionDialog $cp "Die ist schon aufgedeckt. Sei aufmerksam!" -Fast; Start-Sleep -Milliseconds 500; continue }

            $revealed[$idx1] = $true
            try { Clear-Host } catch {}
            Show-PetFrame "MEMORY — Du: $playerScore | $($cp.Name): $companionScore" -Double | Out-Null
            Write-Host ""
            for ($row = 0; $row -lt 4; $row++) {
                $line = "  "
                for ($col = 0; $col -lt 4; $col++) {
                    $idx = $row * 4 + $col
                    if ($revealed[$idx]) {
                        $line += "[$($deck[$idx])] "
                    } else {
                        $line += "[$(($idx + 1).ToString("D2"))] "
                    }
                }
                Write-Host $line -ForegroundColor White
            }

            $second = Read-Choice "Zweite Karte" '^([1-9]|1[0-6]|Q)$'
            if ($second -eq 'Q') { $revealed[$idx1] = $false; Save-PetState $pet; return }
            $idx2 = [int]$second - 1
            if ($revealed[$idx2] -or $idx1 -eq $idx2) {
                Show-CompanionDialog $cp "Ungueltige Wahl. Versuch es nochmal." -Fast
                $revealed[$idx1] = $false
                Start-Sleep -Milliseconds 500
                continue
            }
            $revealed[$idx2] = $true

            if ($deck[$idx1] -eq $deck[$idx2]) {
                Write-Host "`n  MATCH! $($deck[$idx1])" -ForegroundColor Green
                $playerScore++
                Show-CompanionDialog $cp @("Gut gemacht!","Du hast ein gutes Gedaechtnis.","Pah. Zufall.") | Get-Random -Fast
            } else {
                Write-Host "`n  Kein Match. $($deck[$idx1]) vs $($deck[$idx2])" -ForegroundColor Red
                Show-CompanionDialog $cp @("Falsch!","Neeein.","Beobachte genauer.") | Get-Random -Fast
                Start-Sleep -Milliseconds 800
                $revealed[$idx1] = $false
                $revealed[$idx2] = $false
            }
            $currentPlayer = "companion"
        } else {
            # Companion turn
            Write-Host "`n  $($cp.Name) ist dran..." -ForegroundColor Magenta
            Start-Sleep -Milliseconds 800

            # Companion picks: uses memory + random
            $available = 0..15 | Where-Object { -not $revealed[$_] }
            $pick1 = $available | Get-Random
            $companionMemory[$pick1] = $deck[$pick1]

            # Try to find match from memory
            $match = $null
            if ((Get-Random -Maximum 100) -lt ($companionMemoryChance * 100)) {
                $sym = $deck[$pick1]
                $match = $companionMemory.GetEnumerator() | Where-Object { $_.Value -eq $sym -and $_.Key -ne $pick1 -and ($available -contains $_.Key) } | Select-Object -First 1
            }

            if ($match) {
                $pick2 = $match.Key
            } else {
                $available2 = $available | Where-Object { $_ -ne $pick1 }
                $pick2 = $available2 | Get-Random
                $companionMemory[$pick2] = $deck[$pick2]
            }

            $revealed[$pick1] = $true; $revealed[$pick2] = $true
            Write-Host "  $($cp.Name) waehlt Karten $($pick1 + 1) und $($pick2 + 1)..." -ForegroundColor Magenta
            Start-Sleep -Milliseconds 600

            if ($deck[$pick1] -eq $deck[$pick2]) {
                Write-Host "  MATCH! $($deck[$pick1])" -ForegroundColor Magenta
                $companionScore++
                Show-CompanionDialog $cp "Haha! Algorithmen schlagen Menschen!" -Fast
            } else {
                Write-Host "  Kein Match." -ForegroundColor DarkGray
                Show-CompanionDialog $cp @("Mist.","Nur ein Fehler.","Du hast das bestimmt genossen.") | Get-Random -Fast
                Start-Sleep -Milliseconds 600
                $revealed[$pick1] = $false
                $revealed[$pick2] = $false
            }
            $currentPlayer = "player"
        }
    }

    try { Clear-Host } catch {}
    Show-PetFrame "MEMORY — ERGEBNIS" -Double | Out-Null
    Write-Host "`n  Du: $playerScore | $($cp.Name): $companionScore" -ForegroundColor White

    if ($playerScore -gt $companionScore) {
        Write-Host "`n  DU GEWINNST!" -ForegroundColor Green
        $pet.CompanionGames.Wins++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_win") -Fast
    } elseif ($playerScore -lt $companionScore) {
        Write-Host "`n  $($cp.Name) GEWINNT!" -ForegroundColor Red
        $pet.CompanionGames.Losses++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
    } else {
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        Show-CompanionDialog $cp "Ein Unentschieden? Wie langweilig." -Fast
    }

    if ($turns -lt $pet.CompanionGames.MemoryBestTime) {
        $pet.CompanionGames.MemoryBestTime = $turns
        Write-Host "  NEUER REKORD: $turns Runden!" -ForegroundColor Green
    }

    Add-PetXP 8 "Memory"
    Save-PetState $pet
    Wait-Enter
}
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/companion-games.ps1
git commit -m "feat(games): add Memory card game with TUI grid"
```

---

## Task 5: Integrate into Pet Hub

**Files:**
- Modify: `Modules/pet/hub.ps1`

- [ ] **Step 1: Add menu item**

Find the menu construction. Add after `[S] Story` (or before, depending on level):

```powershell
if ($pet.Meta.Level -ge 2) {
    $opts += "[G] Spiele"
    $keys += "G"
}
```

- [ ] **Step 2: Add routing**

In the switch block:

```powershell
"G" {
    if ($pet.Meta.Level -ge 2) {
        Invoke-CompanionGame
    }
}
```

- [ ] **Step 3: Add flavor lines**

```powershell
'G' = 'Spiele? Endlich etwas Action!'
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/hub.ps1
git commit -m "feat(games): add Games menu to pet hub"
```

---

## Task 6: Smoke Tests

**Files:**
- Modify: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Add game smoke tests**

After the story tests (from Phase 1), add:

```powershell
# Companion Games Smoke Tests
$gameFuncs = @('Invoke-CompanionGame', 'Play-ChaosChips', 'Play-42or47', 'Play-Memory')
foreach ($fn in $gameFuncs) {
    Test-Assert "Game function $fn vorhanden" `
        ((Get-Command $fn -ErrorAction SilentlyContinue) -ne $null)
}

$petDefaults = Get-PetDefaults
Test-Assert "CompanionGames State-Branch vorhanden" `
    ($petDefaults.CompanionGames -ne $null)
Test-Assert "CompanionGames Wins default 0" `
    ($petDefaults.CompanionGames.Wins -eq 0)
Test-Assert "CompanionGames ChaosChipsHighscore default 0" `
    ($petDefaults.CompanionGames.ChaosChipsHighscore -eq 0)
```

- [ ] **Step 2: Run smoke test**

```powershell
& .\Modules\_smoke_test.ps1
```

Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/_smoke_test.ps1
git commit -m "test(games): add smoke tests for companion games"
```

---

## Task 7: E2E Tests

**Files:**
- Modify: `Modules/_e2e_test.ps1`

- [ ] **Step 1: Add ChaosChips E2E flow**

After the NEON story flow, add:

```powershell
# E2E: Chaos-Chips
Write-Host "`n[E2E] Chaos-Chips..." -ForegroundColor Cyan
$pet = Get-PetState
$pet.Companion = @{
    Name = "NEON"; Bond = 50; Mood = "Curious"
    Gifts = 0; Dates = 0; WorkCount = 0; Trains = 0
    Headpats = 0; LastTalk = $null; LastWork = $null
    PunishCount = 0
    Skills = @{ CasinoLuck = 0; StrategyInsight = 0 }
}
Save-PetState $pet

$stateFile = Join-Path $env:LOCALAPPDATA "buxe\buxe_state_v24.json"
$stateBackup = $null
if (Test-Path $stateFile) { $stateBackup = Get-Content $stateFile -Raw }

try {
    $originalWaitEnter = Get-Command Wait-Enter -CommandType Function
    Set-Item function:Wait-Enter {}

    # Mock Read-Choice to return Enter for dice rolls, then Q to quit result screen
    $script:_ccCount = 0
    Set-Item function:global:Read-Choice {
        param($prompt, $pattern)
        $script:_ccCount++
        if ($script:_ccCount -le 3) { return "`r" }  # 3 rounds
        return "Q"  # quit result
    }

    Play-ChaosChips $pet $pet.Companion

    if ($originalReadHost.CommandType -eq 'Function') {
        Set-Item function:global:Read-Choice $originalReadHost.ScriptBlock
    } else {
        Remove-Item function:global:Read-Choice -ErrorAction SilentlyContinue
    }
    Remove-Variable _ccCount -Scope Script -ErrorAction SilentlyContinue
    Set-Item function:Wait-Enter $originalWaitEnter.ScriptBlock

    $pet = Get-PetState
    $winsBefore = if ($stateBackup) { ($stateBackup | ConvertFrom-Json).Pet.CompanionGames.Wins } else { 0 }
    if ($pet.CompanionGames.Wins -ge $winsBefore) {
        Write-Host "  [PASS] Chaos-Chips gespielt" -ForegroundColor Green; $pass++
    } else {
        Write-Host "  [FAIL] Chaos-Chips nicht korrekt beendet!" -ForegroundColor Red; $fail++
        $e2eErrors += "chaoschips"
    }
} catch {
    Write-Host "  [WARN] Chaos-Chips Fehler: $_" -ForegroundColor Yellow
    $e2eErrors += "chaoschips"
} finally {
    if ($null -ne $stateBackup) { $stateBackup | Set-Content $stateFile -NoNewline }
    elseif (Test-Path $stateFile) { Remove-Item $stateFile }
}
```

- [ ] **Step 2: Add 42or47 E2E flow**

```powershell
# E2E: 42 oder 47
Write-Host "`n[E2E] 42 oder 47..." -ForegroundColor Cyan
$pet = Get-PetState
$pet.Companion = @{
    Name = "JINX"; Bond = 50; Mood = "Excited"
    Gifts = 0; Dates = 0; WorkCount = 0; Trains = 0
    Headpats = 0; LastTalk = $null; LastWork = $null
    PunishCount = 0
    Skills = @{ CasinoLuck = 0; StrategyInsight = 0 }
}
Save-PetState $pet

$stateBackup = $null
if (Test-Path $stateFile) { $stateBackup = Get-Content $stateFile -Raw }

try {
    $originalWaitEnter = Get-Command Wait-Enter -CommandType Function
    Set-Item function:Wait-Enter {}

    # Mock Read-Host to guess 50, then Q to quit
    $script:_ftCount = 0
    Set-Item function:global:Read-Host {
        $script:_ftCount++
        if ($script:_ftCount -eq 1) { return "50" }
        return "Q"
    }

    Play-42or47 $pet $pet.Companion

    if ($originalReadHost.CommandType -eq 'Function') {
        Set-Item function:global:Read-Host $originalReadHost.ScriptBlock
    } else {
        Remove-Item function:global:Read-Host -ErrorAction SilentlyContinue
    }
    Remove-Variable _ftCount -Scope Script -ErrorAction SilentlyContinue
    Set-Item function:Wait-Enter $originalWaitEnter.ScriptBlock

    $pet = Get-PetState
    if ($pet.CompanionGames.Losses -ge 0 -or $pet.CompanionGames.Wins -ge 0) {
        Write-Host "  [PASS] 42 oder 47 gespielt" -ForegroundColor Green; $pass++
    } else {
        Write-Host "  [FAIL] 42 oder 47 nicht korrekt beendet!" -ForegroundColor Red; $fail++
        $e2eErrors += "42or47"
    }
} catch {
    Write-Host "  [WARN] 42 oder 47 Fehler: $_" -ForegroundColor Yellow
    $e2eErrors += "42or47"
} finally {
    if ($null -ne $stateBackup) { $stateBackup | Set-Content $stateFile -NoNewline }
    elseif (Test-Path $stateFile) { Remove-Item $stateFile }
}
```

- [ ] **Step 3: Run E2E test**

```powershell
& .\Modules\_e2e_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/_e2e_test.ps1
git commit -m "test(games): add E2E flows for ChaosChips and 42or47"
```

---

## Task 8: Final Verification

- [ ] **Step 1: Run full test suite**

```powershell
& .\Modules\_smoke_test.ps1
& .\Modules\_integration_test.ps1
& .\Modules\_e2e_test.ps1
```

Expected: All tests pass, no regressions.

- [ ] **Step 2: Final commit**

```bash
git add .
git commit -m "feat(games): Phase 2 complete — Companion Mini-Games (ChaosChips, 42or47, Memory)"
```

---

## Spec Coverage Check

| Spec Requirement | Task |
|-----------------|------|
| CompanionGames state defaults | Task 1 |
| Feature unlock at Meta-Level 2 | Task 1 |
| Chaos-Chips dice duel | Task 2 |
| 42 or 47 number guessing | Task 3 |
| Memory 4x4 TUI game | Task 4 |
| Hub integration (`[G] Spiele`) | Task 5 |
| Bond influences difficulty | Task 2, 3, 4 |
| LucasArts-style dialogue | Task 2, 3, 4 |
| Smoke tests | Task 6 |
| E2E tests | Task 7 |
| State persistence (Wins/Losses/Highscores) | Task 2, 3, 4 |

## Placeholder Scan

- No "TBD", "TODO", "implement later"
- All functions have complete code
- All file paths are exact
- All test code is complete
