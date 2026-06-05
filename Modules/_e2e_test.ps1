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
$required = @("status","bank","daily","achievements","ego","capsule","h","pet","companion","battlepet","snake","monkeytype","wordle","zork","hangman","minesweeper","tetris","breakout","blackjack","roulette","craps","hilo","baccarat","slot","poker","td","rogue","adv","insult","say","chuck","kimir","mem","sysinfo","uptime","weather","ip","port","reload","Invoke-BootSequence")
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

Write-Output ""
if ($e2eErrors.Count -gt 0) {
    Write-Output "=== E2E FAILURES: $($e2eErrors -join ', ') ==="
    exit 1
}
Write-Output "=== ALL E2E CHECKS PASSED ==="
