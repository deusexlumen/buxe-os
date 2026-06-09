# BUXE_OS v24.0 -- END-TO-END TEST
$ErrorActionPreference = 'Stop'
$profilePath = Join-Path $PSScriptRoot "..\Microsoft.PowerShell_profile.ps1"

Write-Output "=== LOADING PROFILE ==="
try {
    . $profilePath
    Write-Output "PROFILE LOADED SUCCESSFULLY"
} catch {
    Write-Output "PROFILE FAILED: $_"
    exit 1
}

Write-Output ""
Write-Output "=== VERIFYING FUNCTIONS ==="
$required = @("status","bank","daily","achievements","ego","capsule","h","pet","companion","battlepet","snake","monkeytype","wordle","zork","hangman","minesweeper","tetris","breakout","blackjack","roulette","craps","hilo","baccarat","slot","poker","td","rogue","adv","insult","say","chuck","mem","sysinfo","uptime","weather","ip","port","reload","Invoke-BootSequence")
$missing = @()
foreach ($fn in $required) {
    if (-not (Get-Command $fn -ErrorAction SilentlyContinue)) { $missing += $fn }
}
if ($missing.Count -eq 0) {
    Write-Output "ALL $($required.Count) FUNCTIONS AVAILABLE"
} else {
    Write-Output "MISSING: $($missing -join ', ')"
    exit 1
}

Write-Output ""
Write-Output "=== VERIFYING STATE ==="
$statePath = Join-Path $env:LOCALAPPDATA "buxe\buxe_state_v24.json"
if (Test-Path $statePath) {
    Write-Output "State file exists: $statePath"
    $size = (Get-Item $statePath).Length
    Write-Output "Size: $size bytes"
} else {
    Write-Output "State file MISSING!"
    exit 1
}

Write-Output ""
Write-Output "=== VERIFYING SessionStart ==="
if ($script:SessionStart) {
    $elapsed = (Get-Date) - $script:SessionStart
    Write-Output "SessionStart set: $([math]::Round($elapsed.TotalSeconds, 2)) seconds ago"
} else {
    Write-Output "SessionStart NOT SET!"
    exit 1
}

Write-Output ""
Write-Output "=== GAME FLOW TESTS ==="
$e2eErrors = @()

function Assert($condition, $message) {
    if (-not $condition) {
        Write-Host "  [FAIL] $message" -ForegroundColor Red
        $script:e2eErrors += $message
    }
}

# Test Zork (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { zork } catch { Write-Output "ZORK FAILED: $_"; $e2eErrors += "zork" }
Disable-MockInput
if ($e2eErrors -notcontains "zork") { Write-Output "ZORK: PASSED" }

# Test Rogue (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { rogue } catch { Write-Output "ROGUE FAILED: $_"; $e2eErrors += "rogue" }
Disable-MockInput
if ($e2eErrors -notcontains "rogue") { Write-Output "ROGUE: PASSED" }

# Helper: mock Read-Bet to return bet once then 0
function Mock-ReadBetOnce($bet) {
    $global:_MockBetCount = 0
    $global:_MockBetValue = $bet
    Set-Item function:Read-Bet {
        $global:_MockBetCount++
        if ($global:_MockBetCount -eq 1) { return $global:_MockBetValue }
        return 0
    }
}

# Test Hi-Lo with mocked bet + cashout
$origReadBet = (Get-Command Read-Bet).ScriptBlock
$origWaitEnter = (Get-Command Wait-Enter).ScriptBlock
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "C"
try { hilo } catch { Write-Output "HILO FAILED: $_"; Write-Output "STACK: $($_.ScriptStackTrace)"; $e2eErrors += "hilo" }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "HILO: PASSED"

# Test Slot with mocked bet + spin + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput " "
try { slot } catch { Write-Output "SLOT FAILED: $_"; $e2eErrors += "slot" }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "SLOT: PASSED"

# Test Minesweeper (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { minesweeper } catch { Write-Output "MINESWEEPER FAILED: $_"; $e2eErrors += "minesweeper" }
Disable-MockInput
Write-Output "MINESWEEPER: PASSED"

# Test Blackjack with mocked bet + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "Q"
try { blackjack } catch { Write-Output "BLACKJACK FAILED: $_"; $e2eErrors += "blackjack" }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "BLACKJACK: PASSED"

# Test Poker with mocked buy-in + fold
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "F"
try { poker } catch { Write-Output "POKER FAILED: $_"; $e2eErrors += "poker" }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "POKER: PASSED"

# Test Tower Defense (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { td } catch { Write-Output "TD FAILED: $_"; $e2eErrors += "td" }
Disable-MockInput
Write-Output "TD: PASSED"

# Test Roulette with mocked bet + red/black + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "3Q"
try { roulette } catch { Write-Output "ROULETTE FAILED: $_"; $e2eErrors += "roulette" }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "ROULETTE: PASSED"

# Test Craps with mocked bet + pass + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "PQ"
try { craps } catch { Write-Output "CRAPS FAILED: $_"; $e2eErrors += "craps" }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "CRAPS: PASSED"

# Test Baccarat with mocked bet + banker + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "BQ"
try { baccarat } catch { Write-Output "BACCARAT FAILED: $_"; $e2eErrors += "baccarat" }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "BACCARAT: PASSED"

# Test Snake (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { snake } catch { Write-Output "SNAKE FAILED: $_"; $e2eErrors += "snake" }
Disable-MockInput
Write-Output "SNAKE: PASSED"

# Test Wordle (quit on first guess)
Enable-MockInput
Queue-MockString "Q"
try { wordle } catch { Write-Output "WORDLE FAILED: $_"; $e2eErrors += "wordle" }
Disable-MockInput
Write-Output "WORDLE: PASSED"

# Test Monkeytype (quit on pre-game screen)
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "Q"
try { monkeytype } catch { Write-Output "MONKEYTYPE FAILED: $_"; $e2eErrors += "monkeytype" }
Disable-MockInput
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "MONKEYTYPE: PASSED"

Write-Output ""
# Test Tetris (quit on start screen)
Enable-MockInput
Queue-MockInput "Q"
try { tetris } catch { Write-Output "TETRIS FAILED: $_"; $e2eErrors += "tetris" }
Disable-MockInput
Write-Output "TETRIS: PASSED"

# Test Breakout (quit on start screen)
Enable-MockInput
Queue-MockInput "Q"
try { breakout } catch { Write-Output "BREAKOUT FAILED: $_"; $e2eErrors += "breakout" }
Disable-MockInput
Write-Output "BREAKOUT: PASSED"

# Test Adventure (quit immediately after intro)
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockString "quit"
try { adv } catch { Write-Output "ADVENTURE FAILED: $_"; $e2eErrors += "adventure" }
Disable-MockInput
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "ADVENTURE: PASSED"

# Test Insult Swordfighting (quit immediately - requires Bond 30)
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockString "q"
try { insult } catch { Write-Output "INSULT FAILED: $_"; $e2eErrors += "insult" }
Disable-MockInput
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "INSULT: PASSED"

# Test JINX exists in arrays
if ($script:CPNames -contains "JINX") {
    Write-Output "JINX COMPANION: PASSED"
} else {
    Write-Output "JINX COMPANION FAILED"
    exit 1
}

# Test insult pairs count = 29
if ($script:InsultPairs.Count -eq 29) {
    Write-Output "INSULT 29 PAIRS: PASSED"
} else {
    Write-Output "INSULT 29 PAIRS FAILED: $($script:InsultPairs.Count)"
    exit 1
}

# E2E: NEON Story Episode 1
Write-Output ""
Write-Output "[E2E] NEON Story Episode 1..."

$stateFile = Join-Path $env:LOCALAPPDATA "buxe\buxe_state_v24.json"
$stateBackup = $null
if (Test-Path $stateFile) {
    $stateBackup = Get-Content $stateFile -Raw
}

try {
    $pet = Get-PetState
    if (-not $pet.ContainsKey("CompanionStories")) {
        $pet.CompanionStories = @{
            NEON  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            RAVEN = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            PIXEL = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            LUNA  = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            IVY   = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            VERA  = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            JINX  = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
        }
    }
    $pet.Companion = @{
        Name = "NEON"; Bond = 50; Mood = "Curious"
        Gifts = 0; Dates = 0; WorkCount = 0; Trains = 0
        Headpats = 0; LastTalk = $null; LastWork = $null
        PunishCount = 0
        Skills = @{ CasinoLuck = 0; StrategyInsight = 0 }
    }
    $pet.CompanionStories.NEON.Episode = 1
    $pet.CompanionStories.NEON.Completed = $false
    Save-PetState $pet

    $origWaitEnterE2E = (Get-Command Wait-Enter).ScriptBlock
    Set-Item function:Wait-Enter { }

    $originalReadHost = Get-Command Read-Host -CommandType Cmdlet -ErrorAction SilentlyContinue
    if (-not $originalReadHost) { $originalReadHost = Get-Command Read-Host -CommandType Function -ErrorAction SilentlyContinue }

    $script:_ReadHostCount = 0
    Set-Item function:global:Read-Host {
        param([string]$Prompt)
        $script:_ReadHostCount++
        if ($script:_ReadHostCount -le 4) { return "A" }
        return "Q"
    }

    try {
        Invoke-CompanionEpisode -CompanionName "NEON"
    } catch {
        Write-Host "  [WARN] NEON Story Fehler: $_" -ForegroundColor Yellow
    }

    Set-Item function:Wait-Enter $origWaitEnterE2E
    if ($originalReadHost) {
        if ($originalReadHost.CommandType -eq 'Function') {
            Set-Item function:global:Read-Host $originalReadHost.ScriptBlock
        } else {
            Remove-Item function:global:Read-Host -ErrorAction SilentlyContinue
        }
    } else {
        Remove-Item function:Read-Host -ErrorAction SilentlyContinue
    }
    Remove-Variable _ReadHostCount -Scope Script -ErrorAction SilentlyContinue

    $pet = Get-PetState
    if ($pet.CompanionStories.NEON.Completed -eq $true) {
        Write-Output "  [PASS] NEON Story Episode 1 abgeschlossen"
    } else {
        Write-Output "  [FAIL] NEON Story Episode 1 nicht abgeschlossen!"
        $e2eErrors += "neon-episode"
    }
} finally {
    if ($null -ne $stateBackup) {
        $stateBackup | Set-Content $stateFile -NoNewline
    } elseif (Test-Path $stateFile) {
        Remove-Item $stateFile
    }
}

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
$pet.CompanionGames = @{ Wins = 0; Losses = 0 }
Save-PetState $pet

$stateFile = Join-Path $env:LOCALAPPDATA "buxe\buxe_state_v24.json"
$stateBackup = $null
if (Test-Path $stateFile) { $stateBackup = Get-Content $stateFile -Raw }

try {
    $originalWaitEnter = Get-Command Wait-Enter -CommandType Function
    Set-Item function:Wait-Enter {}

    # Mock Read-Choice: Enter for dice rolls, Q to quit result screen
    $script:_ccCount = 0
    $originalReadChoice = Get-Command Read-Choice -CommandType Function
    Set-Item function:global:Read-Choice {
        param($prompt, $pattern)
        $script:_ccCount++
        if ($script:_ccCount -le 3) { return "`r" }
        return "Q"
    }

    Play-ChaosChips $pet $pet.Companion

    if ($originalReadChoice.CommandType -eq 'Function') {
        Set-Item function:global:Read-Choice $originalReadChoice.ScriptBlock
    } else {
        Remove-Item function:global:Read-Choice -ErrorAction SilentlyContinue
    }
    Remove-Variable _ccCount -Scope Script -ErrorAction SilentlyContinue
    Set-Item function:Wait-Enter $originalWaitEnter.ScriptBlock

    $pet = Get-PetState
    if ($pet.CompanionGames.Wins -gt 0 -or $pet.CompanionGames.Losses -gt 0) {
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
$pet.CompanionGames = @{ Wins = 0; Losses = 0 }
Save-PetState $pet

$stateBackup = $null
if (Test-Path $stateFile) { $stateBackup = Get-Content $stateFile -Raw }

try {
    $originalWaitEnter = Get-Command Wait-Enter -CommandType Function
    Set-Item function:Wait-Enter {}

    # Mock Read-Host: guess 50, then Q to quit
    $script:_ftCount = 0
    $originalReadHost = Get-Command Read-Host -CommandType Cmdlet -ErrorAction SilentlyContinue
    if (-not $originalReadHost) { $originalReadHost = Get-Command Read-Host -CommandType Function -ErrorAction SilentlyContinue }
    Set-Item function:global:Read-Host {
        $script:_ftCount++
        if ($script:_ftCount -eq 1) { return "50" }
        return "Q"
    }

    Play-FortyTwoOr47 $pet $pet.Companion

    if ($originalReadHost.CommandType -eq 'Function') {
        Set-Item function:global:Read-Host $originalReadHost.ScriptBlock
    } else {
        Remove-Item function:global:Read-Host -ErrorAction SilentlyContinue
    }
    Remove-Variable _ftCount -Scope Script -ErrorAction SilentlyContinue
    Set-Item function:Wait-Enter $originalWaitEnter.ScriptBlock

    $pet = Get-PetState
    if ($pet.CompanionGames.Wins -gt 0 -or $pet.CompanionGames.Losses -gt 0) {
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

# E2E: Level-Up Beacon Flow
Write-Host "Testing Level-Up Beacon..." -NoNewline
$pet = Get-PetState
$originalLevel = $pet.Meta.Level
$originalXP = $pet.Meta.XP
$originalPending = $pet.Tutorial.PendingBeacons.Clone()
$originalShown = $pet.Tutorial.BeaconsShown.Clone()

$pet.Meta.Level = 2
$pet.Meta.XP = 15
$pet.Tutorial.Completed = $true
$pet.Tutorial.PendingBeacons = @()
$pet.Tutorial.BeaconsShown = @()
Save-PetState $pet

# Mock Invoke-PetLevelUp to avoid interactive dialog in E2E
$originalInvokePetLevelUp = Get-Command Invoke-PetLevelUp -CommandType Function -ErrorAction SilentlyContinue
Set-Item function:Invoke-PetLevelUp { }

# Simulate XP gain to level 3
Add-PetXP 30 "E2E Test"
$pet = Get-PetState
Assert ($pet.Tutorial.PendingBeacons -contains 3) "E2E: Lv 3 beacon queued via Add-PetXP"

# Restore Invoke-PetLevelUp
if ($originalInvokePetLevelUp) {
    Set-Item function:Invoke-PetLevelUp $originalInvokePetLevelUp.ScriptBlock
} else {
    Remove-Item function:Invoke-PetLevelUp -ErrorAction SilentlyContinue
}

# Cleanup
$pet.Meta.Level = $originalLevel
$pet.Meta.XP = $originalXP
$pet.Tutorial.PendingBeacons = $originalPending
$pet.Tutorial.BeaconsShown = $originalShown
Save-PetState $pet
Write-Host " OK" -ForegroundColor Green

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

Assert (Get-Command Invoke-TacticalCombat -ErrorAction SilentlyContinue) "E2E: Invoke-TacticalCombat exists"
Assert (Get-Command Show-CombatScreen -ErrorAction SilentlyContinue) "E2E: Show-CombatScreen exists"
Assert (Get-Command Get-CombatInitiative -ErrorAction SilentlyContinue) "E2E: Get-CombatInitiative exists"
Assert (Get-Command Resolve-PlayerAction -ErrorAction SilentlyContinue) "E2E: Resolve-PlayerAction exists"
Assert (Get-Command Resolve-EnemyAction -ErrorAction SilentlyContinue) "E2E: Resolve-EnemyAction exists"
Assert (Get-Command Apply-StatusEffects -ErrorAction SilentlyContinue) "E2E: Apply-StatusEffects exists"

Write-Host " OK" -ForegroundColor Green

Write-Output ""
if ($e2eErrors.Count -gt 0) {
    Write-Output "=== E2E FAILURES: $($e2eErrors -join ', ') ==="
    exit 1
}
Write-Output "=== ALL E2E CHECKS PASSED ==="
