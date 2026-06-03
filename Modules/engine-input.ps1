# BUXE_OS v24.3 -- INPUT & GAME LOOP ENGINE
# Polling-basiertes Input-Handling mit Game Loop.
# Ersetzt blocking Read-Host in Spielen.

try {

# === MOCK INPUT ( fuer E2E-Tests ) ===
$script:MockInputEnabled = $false
$script:MockInputQueue = @()
$script:MockStringQueue = @()

function Enable-MockInput { $script:MockInputEnabled = $true; $script:MockInputQueue = @(); $script:MockStringQueue = @() }
function Disable-MockInput { $script:MockInputEnabled = $false; $script:MockInputQueue = @(); $script:MockStringQueue = @() }
function Queue-MockInput($chars) {
    foreach ($c in $chars.ToCharArray()) { $script:MockInputQueue += $c.ToString().ToUpper() }
}
function Queue-MockString($string) {
    $script:MockStringQueue += $string
}

# === INPUT EVENTS ===
# Normalisiert ConsoleKeyInfo zu einem einfachen Objekt.

function New-InputEvent($KeyInfo) {
    return @{
        Key = $KeyInfo.Key.ToString()
        Char = $KeyInfo.KeyChar
        Modifiers = $KeyInfo.Modifiers.ToString()
        IsQuit = ($KeyInfo.Key -eq 'Escape' -or $KeyInfo.Key -eq 'Q')
        IsEnter = ($KeyInfo.Key -eq 'Enter')
        IsArrow = ($KeyInfo.Key -in @('UpArrow','DownArrow','LeftArrow','RightArrow'))
        IsNumber = ($KeyInfo.Key -match '^D[0-9]$' -or $KeyInfo.Key -match '^NumPad[0-9]$')
        NumberValue = if ($KeyInfo.Key -match '^D([0-9])$') { [int]$Matches[1] } elseif ($KeyInfo.Key -match '^NumPad([0-9])$') { [int]$Matches[1] } else { $null }
    }
}

# === GAME LOOP ===
# Zentrale Schleife fuer alle Spiele.
# Init -> [Input -> Tick -> Render -> Sleep] -> Cleanup

function Invoke-GameLoop {
    param(
        [scriptblock]$Init = $null,          # Einmalig am Anfang
        [scriptblock]$Tick = $null,          # Jeder Frame (logik, animation, etc.)
        [scriptblock]$InputHandler = $null,  # Wird aufgerufen wenn Taste gedrueckt
        [scriptblock]$Render = $null,        # Wird aufgerufen nach Tick
        [scriptblock]$Cleanup = $null,       # Einmalig am Ende (auch bei Crash)
        [int]$FPS = 10                       # Ziel-FPS. Snake: 8-10, Slot: 5, Combat: 2
    )
    
    $running = $true
    $frameTimeMs = [math]::Floor(1000 / [math]::Max(1, $FPS))
    $tickCount = 0
    
    # Init
    if ($Init) { & $Init }
    
    $oldCursorVisible = $true
    try { $oldCursorVisible = [Console]::CursorVisible; [Console]::CursorVisible = $false } catch {}
    
    try {
        while ($running) {
            $frameStart = [DateTime]::Now
            
            # --- INPUT POLLING ---
            $inputEvents = @()
            if ($script:MockInputEnabled -and $script:MockInputQueue.Count -gt 0) {
                $char = $script:MockInputQueue[0]
                $script:MockInputQueue = $script:MockInputQueue | Select-Object -Skip 1
                $inputEvents += @{
                    Key = if ($char -eq ' ') { 'Spacebar' } else { $char }
                    Char = $char
                    Modifiers = ""
                    IsQuit = ($char -eq 'Q')
                    IsEnter = ($char -eq "`r")
                    IsArrow = $false
                    IsNumber = ($char -match '^[0-9]$')
                    NumberValue = if ($char -match '^[0-9]$') { [int]$char } else { $null }
                }
                if ($char -eq 'Q') { $running = $false; break }
            } else {
                while ([Console]::KeyAvailable) {
                    $keyInfo = [Console]::ReadKey($true)
                    $evt = New-InputEvent $keyInfo
                    $inputEvents += $evt
                    
                    # Global quit handler
                    if ($evt.IsQuit) {
                        $running = $false
                        break
                    }
                }
            }
            
            if (-not $running) { break }
            
            # --- INPUT HANDLER ---
            foreach ($evt in $inputEvents) {
                if ($InputHandler) {
                    $result = & $InputHandler $evt $tickCount
                    if ($result -eq 'QUIT') { $running = $false; break }
                }
            }
            
            if (-not $running) { break }
            
            # --- TICK (Logik) ---
            if ($Tick) {
                $result = & $Tick $tickCount
                if ($result -eq 'QUIT') { $running = $false; break }
            }
            
            # --- RENDER ---
            if ($Render) {
                & $Render $tickCount
            }
            
            $tickCount++
            
            # --- FRAME TIMING ---
            $elapsed = ([DateTime]::Now - $frameStart).TotalMilliseconds
            $sleep = $frameTimeMs - $elapsed
            if ($sleep -gt 0) {
                Start-Sleep -Milliseconds $sleep
            }
        }
    } catch {
        Write-Host "`n[GameLoop] CRITICAL: $_" -ForegroundColor Red
    } finally {
        try { [Console]::CursorVisible = $oldCursorVisible } catch {}
        if ($Cleanup) {
            try { & $Cleanup } catch { Write-Host "[GameLoop] Cleanup error: $_" -ForegroundColor DarkRed }
        }
    }
}

# === BLOCKING INPUT (Legacy Fallback) ===
# Fuer Menues die kein Game Loop brauchen.

function Read-GameInput($Prompt) {
    if ($script:MockInputEnabled -and $script:MockStringQueue.Count -gt 0) {
        $input = $script:MockStringQueue[0]
        $script:MockStringQueue = $script:MockStringQueue | Select-Object -Skip 1
        return $input
    }
    return Read-Host $Prompt
}

function Read-GameChoice($Prompt, $ValidPattern, $TimeoutSec = 0) {
    if ($script:MockInputEnabled -and $script:MockInputQueue.Count -gt 0) {
        $char = $script:MockInputQueue[0]
        $script:MockInputQueue = $script:MockInputQueue | Select-Object -Skip 1
        return $char
    }
    if ($TimeoutSec -gt 0) {
        $start = Get-Date
        while (((Get-Date) - $start).TotalSeconds -lt $TimeoutSec) {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                $char = $key.KeyChar.ToString().ToUpper()
                if ($char -match $ValidPattern) {
                    return $char
                }
            }
            Start-Sleep -Milliseconds 50
        }
        return $null
    } else {
        while ($true) {
            $key = [Console]::ReadKey($true)
            $char = $key.KeyChar.ToString().ToUpper()
            if ($char -match $ValidPattern) {
                return $char
            }
        }
    }
}

# === SOUND EFFECTS ===
# Non-interactive safe beep wrapper.

function Invoke-GameBeep($Frequency = 800, $Duration = 100) {
    try { [Console]::Beep($Frequency, $Duration) } catch {}
}

function Invoke-GameSound($Type) {
    switch ($Type) {
        'LineClear'  { Invoke-GameBeep 1000 100 }
        'GameOver'   { Invoke-GameBeep 200  300 }
        'Reveal'     { Invoke-GameBeep 800  50 }
        'Flag'       { Invoke-GameBeep 600  50 }
        'Explosion'  { Invoke-GameBeep 150  200 }
        'Win'        { Invoke-GameBeep 800  50; Start-Sleep -Milliseconds 30; Invoke-GameBeep 1200 100 }
        'Error'      { Invoke-GameBeep 300  150 }
        'Click'      { Invoke-GameBeep 900  30 }
        default      { Invoke-GameBeep 800  50 }
    }
}

} catch {
    Write-Host "[engine-input] CRITICAL ERROR: $_" -ForegroundColor Red
}
