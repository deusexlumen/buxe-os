# BUXE_OS v24.0 -- UI FRAMEWORK
# Einheitliches UI-Framework fuer alle Module.

try {

# === FRAME ===
function Show-Frame($Title, [int]$Width = 42, [switch]$Double) {
    # Meta 15: Architect Theme — cached to avoid repeated hashtable lookups
    $theme = if ($script:CachedFrameTheme) { $script:CachedFrameTheme } else { "Default" }
    switch ($theme) {
        "Neon" { $hc = if ($Double) { "=" } else { "-" }; $tl = "+"; $tr = "+"; $bl = "+"; $br = "+"; $fg = "Magenta" }
        "Matrix" { $hc = if ($Double) { "=" } else { "-" }; $tl = "+"; $tr = "+"; $bl = "+"; $br = "+"; $fg = "Green" }
        "Retro" { $hc = if ($Double) { "=" } else { "=" }; $tl = "+"; $tr = "+"; $bl = "+"; $br = "+"; $fg = "Yellow" }
        "Minimal" { $hc = if ($Double) { "=" } else { "-" }; $tl = "+"; $tr = "+"; $bl = "+"; $br = "+"; $fg = "White" }
        default { $hc = if ($Double) { "=" } else { "-" }; $tl = "+"; $tr = "+"; $bl = "+"; $br = "+"; $fg = "Cyan" }
    }
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
    Write-Host $topLine -ForegroundColor $fg
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
    Write-Host "  [Q] Zurueck / Quit" -ForegroundColor DarkGray
    Write-Host ""
    return $bot
}

# === EXTENDED MENU (letter + number support) ===
function Show-MenuEx($Title, [array]$Items, [switch]$Clear) {
    if ($Clear) { try { Clear-Host } catch {} }
    if ($Title) { Show-Frame $Title -Double | Out-Null } else { Show-Frame "MENU" -Double | Out-Null }
    Write-Host ""

    if ($Items -and $Items.Count -gt 0) {
        $cellStrings = foreach ($it in $Items) { "  [$($it.Key)] $($it.Label)" }
        $maxLen = ($cellStrings | Measure-Object -Property Length -Maximum).Maximum
        $quitLen = "  [Q] Zurueck / Quit".Length
        if ($quitLen -gt $maxLen) { $maxLen = $quitLen }
        $colWidth = $maxLen + 2

        $rows = [math]::Ceiling($Items.Count / 3)
        for ($r = 0; $r -lt $rows; $r++) {
            for ($c = 0; $c -lt 3; $c++) {
                $idx = $r * 3 + $c
                if ($idx -lt $Items.Count) {
                    $it = $Items[$idx]
                    $s = "  [$($it.Key)] $($it.Label)"
                    $color = if ($it.Color) { $it.Color } else { "White" }
                    Write-Host $s.PadRight($colWidth) -NoNewline -ForegroundColor $color
                }
            }
            Write-Host ""
        }
    }

    Write-Host "  [Q] Zurueck / Quit" -ForegroundColor DarkGray
    Write-Host ""

    $validKeys = @('Q')
    if ($Items) {
        $validKeys += foreach ($it in $Items) { ($it.Key -as [string]).ToUpper() }
    }
    $escaped = foreach ($k in $validKeys) { [regex]::Escape($k) }
    $pattern = '^[' + ($escaped -join '') + ']$'

    while ($true) {
        $in = Read-Host "  Deine Wahl"
        $sel = ($in -as [string]).ToUpper()
        if ($sel -match $pattern) { return $sel }
        Write-Host "  Ungueltige Eingabe." -ForegroundColor Red
    }
}

# === INPUT ===
function Wait-Enter {
    Write-Host "`n  [Enter] druecken zum Fortfahren..." -ForegroundColor DarkGray
    $null = Read-Host
    if (Get-Command Flush-State -ErrorAction SilentlyContinue) { Flush-State }
}

function Read-Choice($Prompt, $ValidPattern, $QuitChar = 'Q') {
    $emptyCount = 0
    while ($true) {
        $in = Read-Host "  $Prompt"
        if ($in -eq $QuitChar) { return $QuitChar }
        if ($in -match $ValidPattern) { return $in }
        Write-Host "  Ungueltige Eingabe." -ForegroundColor Red
        if ([string]::IsNullOrEmpty($in)) {
            $emptyCount++
            if ($emptyCount -gt 10) { return $QuitChar }
        }
    }
}

# === BET INPUT ===
function Read-Bet($Max, $Prompt = "Einsatz", $AllowAllIn = $true) {
    while ($true) {
        $hint = if ($AllowAllIn) { " (oder 'all' fuer All-In, 'Q' fuer Zurueck)" } else { " (oder 'Q' fuer Zurueck)" }
        $in = Read-Host "  $Prompt$hint"
        if ($in -eq 'Q') { return 0 }
        if ($AllowAllIn -and $in -eq 'all') { return $Max }
        $bet = 0
        if ([int]::TryParse($in, [ref]$bet)) {
            if ($bet -le 0) { Write-Host "  Einsatz muss positiv sein." -ForegroundColor Red; continue }
            if ($bet -gt $Max) { Write-Host "  Nicht genug Gold! (Max: $Max G)" -ForegroundColor Red; continue }
            return $bet
        }
        Write-Host "  Ungueltige Eingabe." -ForegroundColor Red
    }
}

# === BUST HANDLING ===
function Confirm-Bust($gameName) {
    Load-State
    $br = $script:BuxeState.Bank.Gold
    if ($br -gt 0) { return $br }
    
    # Bailout cooldown: once per hour
    $now = Get-Date
    $lastBust = $script:BuxeState.Bank.LastBustReset
    if ($lastBust) {
        $hoursSince = ($now - [datetime]$lastBust).TotalHours
        if ($hoursSince -lt 1) {
            $mins = [math]::Ceiling(60 - $hoursSince * 60)
            Write-Host "`n  [BANKROTT] Du hast kein Gold mehr!" -ForegroundColor Red
            Write-Host "  Bailout nicht verfuegbar. Naechste Chance in $mins Minuten." -ForegroundColor DarkGray
            return 0
        }
    }
    
    Write-Host "`n  [BANKROTT] Du hast kein Gold mehr!" -ForegroundColor Red
    Write-Host "  Die Bank gibt dir einen Neuanfang: +100 G" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
    $script:BuxeState.Bank.Gold = 100
    $script:BuxeState.Bank.LastBustReset = $now.ToString("yyyy-MM-dd HH:mm")
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

function Show-GameCompanionComment($Companion, $GameName, $Context) {
    if (-not (Get-Command Get-PetState -ErrorAction SilentlyContinue)) { return }
    $pet = Get-PetState
    $cp = if ($pet) { $pet.Companion } else { $null }
    if (-not $cp) { return }
    # Single-argument calls pass the context directly (e.g. "game_snake_start")
    if ($Context -eq $null -and $GameName -eq $null) {
        $Context = $Companion
    }
    if (-not $Context) { return }
    if (-not (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) { return }
    if (-not (Get-Command Get-CompanionLine -ErrorAction SilentlyContinue)) { return }
    $comment = Get-CompanionLine $cp $Context
    if ($comment -and $comment -ne "Ich bin nur ein Bug in der Matrix. Hallo.") {
        Show-CompanionDialog $cp $comment -Fast
    }
}

} catch {
    Write-Host "[engine-ui] CRITICAL ERROR: $_" -ForegroundColor Red
}
