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
$required = @("status","bank","daily","achievements","ego","capsule","h","pet","companion","battlepet","snake","monkeytype","wordle","zork","hangman","minesweeper","tetris","breakout","blackjack","roulette","craps","hilo","baccarat","slot","poker","td","rogue","say","chuck","kimir","mem","sysinfo","uptime","weather","ip","port","reload","Invoke-BootSequence")
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

# Test Zork (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { zork } catch { Write-Output "ZORK FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "ZORK: PASSED"

# Test Rogue (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { rogue } catch { Write-Output "ROGUE FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "ROGUE: PASSED"

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
try { hilo } catch { Write-Output "HILO FAILED: $_"; Write-Output "STACK: $($_.ScriptStackTrace)"; exit 1 }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "HILO: PASSED"

# Test Slot with mocked bet + spin + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput " "
try { slot } catch { Write-Output "SLOT FAILED: $_"; exit 1 }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "SLOT: PASSED"

# Test Minesweeper (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { minesweeper } catch { Write-Output "MINESWEEPER FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "MINESWEEPER: PASSED"

# Test Blackjack with mocked bet + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "Q"
try { blackjack } catch { Write-Output "BLACKJACK FAILED: $_"; exit 1 }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "BLACKJACK: PASSED"

# Test Poker with mocked buy-in + fold
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "F"
try { poker } catch { Write-Output "POKER FAILED: $_"; exit 1 }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "POKER: PASSED"

# Test Tower Defense (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { td } catch { Write-Output "TD FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "TD: PASSED"

# Test Roulette with mocked bet + red/black + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "1Q"
try { roulette } catch { Write-Output "ROULETTE FAILED: $_"; exit 1 }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "ROULETTE: PASSED"

# Test Craps with mocked bet + pass + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "PQ"
try { craps } catch { Write-Output "CRAPS FAILED: $_"; exit 1 }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "CRAPS: PASSED"

# Test Baccarat with mocked bet + banker + quit
Mock-ReadBetOnce 10
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "BQ"
try { baccarat } catch { Write-Output "BACCARAT FAILED: $_"; exit 1 }
Disable-MockInput
Set-Item function:Read-Bet $origReadBet
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "BACCARAT: PASSED"

# Test Snake (quit immediately)
Enable-MockInput
Queue-MockInput "Q"
try { snake } catch { Write-Output "SNAKE FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "SNAKE: PASSED"

# Test Wordle (quit on first guess)
Enable-MockInput
Queue-MockString "Q"
try { wordle } catch { Write-Output "WORDLE FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "WORDLE: PASSED"

# Test Monkeytype (quit on pre-game screen)
Set-Item function:Wait-Enter { }
Enable-MockInput
Queue-MockInput "Q"
try { monkeytype } catch { Write-Output "MONKEYTYPE FAILED: $_"; exit 1 }
Disable-MockInput
Set-Item function:Wait-Enter $origWaitEnter
Write-Output "MONKEYTYPE: PASSED"

Write-Output ""
# Test Tetris (quit on start screen)
Enable-MockInput
Queue-MockInput "Q"
try { tetris } catch { Write-Output "TETRIS FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "TETRIS: PASSED"

# Test Breakout (quit on start screen)
Enable-MockInput
Queue-MockInput "Q"
try { breakout } catch { Write-Output "BREAKOUT FAILED: $_"; exit 1 }
Disable-MockInput
Write-Output "BREAKOUT: PASSED"

Write-Output ""
Write-Output "=== ALL E2E CHECKS PASSED ==="
