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

# === CLEAR SCREEN WRAPPER ===
function Clear-Screen($Title) {
    try { Clear-Host } catch {}
    if ($Title) { Show-Frame $Title -Double | Out-Null }
}

# === BANK DISPLAY ===
function Show-Bankroll {
    Load-State
    $br = $script:BuxeState.Bank.Gold
    Write-Host "  Bank: $br G" -ForegroundColor Yellow
    return $br
}

} catch {
    Write-Host "[engine-ui] CRITICAL ERROR: $_" -ForegroundColor Red
}
