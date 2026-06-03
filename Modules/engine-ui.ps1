# BUXE_OS v24.0 -- UI FRAMEWORK
# Einheitliches UI-Framework f??r alle Module.

try {

# === FRAME ===
function Show-Frame($Title, [int]$Width = 42, [switch]$Double) {
    $hc = if ($Double) { "=" } else { "-" }
    $tl = if ($Double) { "#" } else { "+" }
    $tr = if ($Double) { "#" } else { "+" }
    $bl = if ($Double) { "#" } else { "+" }
    $br = if ($Double) { "#" } else { "+" }
    $line = $hc * $Width
    if ($Title) {
        $t = " $Title "
        $pad = [math]::Max(0, $Width - $t.Length)
        $left = [math]::Floor($pad / 2)
        $right = $pad - $left
        $topLine = $tl + ($hc * $left) + $t + ($hc * $right) + $tr
    } else {
        $topLine = $tl + $line + $tr
    }
    $botLine = $bl + $line + $br
    Write-Host $topLine -ForegroundColor Cyan
    return $botLine
}

# === PROGRESS BAR ===
function Show-Bar($Current, $Max, $Width = 20, $Style = "Classic") {
    $f = [math]::Round(($Current / [math]::Max(1,$Max)) * $Width)
    switch ($Style) {
        "Retro"   { return ("#" * $f) + ("-" * ($Width - $f)) }
        "Minimal" { return ("*" * $f) + ("." * ($Width - $f)) }
        default   { return ("#" * $f) + (":" * ($Width - $f)) }
    }
}

# === MENU ===
function Show-Menu($Title, [array]$Options, [switch]$Clear) {
    if ($Clear) { Clear-Host }
    if ($Title) {
        $bot = Show-Frame $Title -Double
    } else {
        $bot = Show-Frame "MENU" -Double
    }
    Write-Host ""
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$($i+1)] $($Options[$i])" -ForegroundColor White
    }
    Write-Host "  [Q] Zur??ck / Quit" -ForegroundColor DarkGray
    Write-Host ""
    return $bot
}

# === INPUT ===
function Wait-Enter {
    Write-Host "`n  [Enter] dr??cken zum Fortfahren..." -ForegroundColor DarkGray
    $null = Read-Host
}

function Read-Choice($Prompt, $ValidPattern, $QuitChar = 'Q') {
    while ($true) {
        $in = Read-Host "  $Prompt"
        if ($in -eq $QuitChar) { return $QuitChar }
        if ($in -match $ValidPattern) { return $in }
        Write-Host "  Ung??ltige Eingabe." -ForegroundColor Red
    }
}

# === BET INPUT ===
function Read-Bet($Max, $Prompt = "Einsatz", $AllowAllIn = $true) {
    while ($true) {
        $hint = if ($AllowAllIn) { " (oder 'all' f??r All-In, 'Q' f??r Zur??ck)" } else { " (oder 'Q' f??r Zur??ck)" }
        $in = Read-Host "  $Prompt$hint"
        if ($in -eq 'Q') { return 0 }
        if ($AllowAllIn -and $in -eq 'all') { return $Max }
        $bet = 0
        if ([int]::TryParse($in, [ref]$bet)) {
            if ($bet -le 0) { Write-Host "  Einsatz muss positiv sein." -ForegroundColor Red; continue }
            if ($bet -gt $Max) { Write-Host "  Nicht genug Gold! (Max: $Max G)" -ForegroundColor Red; continue }
            return $bet
        }
        Write-Host "  Ung??ltige Eingabe." -ForegroundColor Red
    }
}

# === BUST HANDLING ===
function Confirm-Bust($gameName) {
    Load-State
    $br = $script:BuxeState.Bank.Gold
    if ($br -gt 0) { return $br }
    Write-Host "`n  [BANKROTT] Du hast kein Gold mehr!" -ForegroundColor Red
    Write-Host "  Die Bank gibt dir einen Neuanfang: +100 G" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
    $script:BuxeState.Bank.Gold = 100
    Save-State
    Unlock-Achievement "Bankrupt"
    return 100
}

# === ANIMATION ===
function Show-Animation($Frames, $DelayMs = 100) {
    foreach ($frame in $Frames) {
        Write-Host $frame -ForegroundColor Magenta
        Start-Sleep -Milliseconds $DelayMs
        if ($Frames.IndexOf($frame) -lt $Frames.Count - 1) {
            [Console]::SetCursorPosition(0, [Console]::CursorTop - 1)
            Write-Host (" " * $frame.Length)
            [Console]::SetCursorPosition(0, [Console]::CursorTop - 1)
        }
    }
}

# === SLOT SPIN ANIMATION ===
function Show-SlotSpin($symbols, $colors, $final, $spins = 10) {
    for ($i = 0; $i -lt $spins; $i++) {
        $r1 = $symbols | Get-Random
        $r2 = $symbols | Get-Random
        $r3 = $symbols | Get-Random
        Write-Host "  | " -NoNewline
        Write-Host $r1 -ForegroundColor $colors[$r1] -NoNewline
        Write-Host " | " -NoNewline
        Write-Host $r2 -ForegroundColor $colors[$r2] -NoNewline
        Write-Host " | " -NoNewline
        Write-Host $r3 -ForegroundColor $colors[$r3] -NoNewline
        Write-Host " |" -NoNewline
        [Console]::SetCursorPosition(0, [Console]::CursorTop)
        Start-Sleep -Milliseconds (80 + ($i * 40))
    }
    Write-Host "  | $($final[0]) | $($final[1]) | $($final[2]) |`n" -ForegroundColor White
}

# === CARD RENDERING ===
function Show-Card($Card, [switch]$Hidden) {
    if ($Hidden) {
        Write-Host "  +---+ " -NoNewline -ForegroundColor White
        return
    }
    $s = $Card.Suit
    $r = $Card.Rank.PadLeft(2).PadRight(3)
    $c = if ($s -in @("H","D")) { "Red" } else { "White" }
    Write-Host "  +---+ " -NoNewline -ForegroundColor White
    Write-Host "|$r| " -NoNewline -ForegroundColor $c
    Write-Host "| $s | " -NoNewline -ForegroundColor $c
    Write-Host "+---+ " -NoNewline -ForegroundColor White
}

function Show-CardHand($hand, [switch]$HideLast) {
    $top = ""; $mid = ""; $sui = ""; $bot = ""
    for ($i = 0; $i -lt $hand.Count; $i++) {
        if ($HideLast -and $i -eq $hand.Count - 1) {
            $top += "+---+ "; $mid += "| ? | "; $sui += "| ? | "; $bot += "+---+ "
        } else {
            $r = $hand[$i].Rank.PadLeft(2).PadRight(3)
            $s = $hand[$i].Suit
            $top += "+---+ "; $mid += "|$r| "; $sui += "| $s | "; $bot += "+---+ "
        }
    }
    Write-Host "  $top" -ForegroundColor White
    Write-Host "  $mid" -ForegroundColor White
    Write-Host "  $sui" -ForegroundColor White
    Write-Host "  $bot" -ForegroundColor White
}

# === DICE ROLL ===
function Show-DiceRoll($count = 2, $sides = 6, $delay = 300) {
    $results = @()
    for ($i = 0; $i -lt $count; $i++) {
        $r = Get-Random -Minimum 1 -Maximum ($sides + 1)
        $results += $r
        Write-Host "  [W??rfel $($i+1)] " -NoNewline -ForegroundColor Cyan
        for ($s = 0; $s -lt 3; $s++) {
            $temp = Get-Random -Minimum 1 -Maximum ($sides + 1)
            Write-Host "$temp " -NoNewline -ForegroundColor DarkGray
            Start-Sleep -Milliseconds 100
            Write-Host "`b`b  " -NoNewline
        }
        Write-Host "$r " -ForegroundColor Yellow
        Start-Sleep -Milliseconds $delay
    }
    return $results
}

# === CLEAR SCREEN WRAPPER ===
function Clear-Screen($Title) {
    Clear-Host
    if ($Title) { Show-Frame $Title -Double | Out-Null }
}

# === BANK DISPLAY ===
function Show-Bankroll {
    Load-State
    $br = $script:BuxeState.Bank.Gold
    Write-Host "  Bank: $br G" -ForegroundColor Yellow
    return $br
}

# === STATUS BAR ===
function Show-StatusBar {
    Load-State
    $br = $script:BuxeState.Bank.Gold
    $ach = ($script:BuxeState.Achievements | Get-Member -MemberType NoteProperty | Measure-Object).Count
    $line = "  [Bank: $br G | Achievements: $ach"
    if ($script:BuxeState.Companion) { $line += " | Companion: $($script:BuxeState.Companion.Name)" }
    if ($script:BuxeState.Battlepet -and $script:BuxeState.Battlepet.Pets.Count -gt 0) {
        $ap = $script:BuxeState.Battlepet.Pets[$script:BuxeState.Battlepet.ActivePet]
        $line += " | Pet: $($ap.Name)"
    }
    $line += "]"
    Write-Host $line -ForegroundColor DarkGray
}

} catch {
    Write-Host "[engine-ui] CRITICAL ERROR: $_" -ForegroundColor Red
}
