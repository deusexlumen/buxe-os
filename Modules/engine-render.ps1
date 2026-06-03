# BUXE_OS v24.3 -- RENDER ENGINE
# Frame-basiertes Rendering mit Double-Buffering.
# Kein Clear-Host mehr. Kein Write-Host mehr in Spielen.

try {

# === FRAME BUFFER ===
# Ein Frame ist ein 2D-Array von Cells: @{ Char = ' '; Color = 'Gray'; BgColor = $null }

function New-Frame($Width = $null, $Height = $null) {
    if (-not $Width) { $Width = $Host.UI.RawUI.WindowSize.Width }
    if (-not $Height) { $Height = $Host.UI.RawUI.WindowSize.Height }
    # Safety margin for scrollbar/padding
    $Width = [math]::Max(1, $Width - 1)
    $Height = [math]::Max(1, $Height - 1)
    
    $frame = @{ Width = $Width; Height = $Height; Cells = @() }
    for ($y = 0; $y -lt $Height; $y++) {
        $row = @()
        for ($x = 0; $x -lt $Width; $x++) {
            $row += @{ Char = ' '; Color = 'Gray'; BgColor = $null }
        }
        $frame.Cells += ,$row
    }
    return $frame
}

function Clear-Frame($Frame, $Char = ' ', $Color = 'Gray') {
    for ($y = 0; $y -lt $Frame.Height; $y++) {
        for ($x = 0; $x -lt $Frame.Width; $x++) {
            $Frame.Cells[$y][$x].Char = $Char
            $Frame.Cells[$y][$x].Color = $Color
            $Frame.Cells[$y][$x].BgColor = $null
        }
    }
}

function Set-FrameChar($Frame, $X, $Y, $Char, $Color = 'White', $BgColor = $null) {
    if ($Y -lt 0 -or $Y -ge $Frame.Height -or $X -lt 0 -or $X -ge $Frame.Width) { return }
    $Frame.Cells[$Y][$X].Char = $Char
    $Frame.Cells[$Y][$X].Color = $Color
    if ($BgColor) { $Frame.Cells[$Y][$X].BgColor = $BgColor }
}

function Set-FrameText($Frame, $X, $Y, $Text, $Color = 'White', $BgColor = $null) {
    for ($i = 0; $i -lt $Text.Length; $i++) {
        Set-FrameChar $Frame ($X + $i) $Y $Text[$i] $Color $BgColor
    }
}

function Set-FrameBlock($Frame, $X, $Y, $Width, $Height, $Char = ' ', $Color = 'White', $BgColor = $null) {
    for ($yy = 0; $yy -lt $Height; $yy++) {
        for ($xx = 0; $xx -lt $Width; $xx++) {
            Set-FrameChar $Frame ($X + $xx) ($Y + $yy) $Char $Color $BgColor
        }
    }
}

# === DRAW PRIMITIVES ===

function Draw-FrameBorder($Frame, $X, $Y, $Width, $Height, $Color = 'Cyan', [switch]$Double) {
    $hc = if ($Double) { [char]0x2550 } else { [char]0x2500 } # ─ / ═
    $vc = if ($Double) { [char]0x2551 } else { [char]0x2502 } # │ / ║
    $tl = if ($Double) { [char]0x2554 } else { [char]0x250C } # ┌ / ╔
    $tr = if ($Double) { [char]0x2557 } else { [char]0x2510 } # ┐ / ╗
    $bl = if ($Double) { [char]0x255A } else { [char]0x2514 } # └ / ╚
    $br = if ($Double) { [char]0x255D } else { [char]0x2518 } # ┘ / ╝
    
    if ($Width -lt 2 -or $Height -lt 2) { return }
    
    # Top
    Set-FrameChar $Frame $X $Y $tl $Color
    for ($i = 1; $i -lt $Width - 1; $i++) { Set-FrameChar $Frame ($X + $i) $Y $hc $Color }
    Set-FrameChar $Frame ($X + $Width - 1) $Y $tr $Color
    
    # Sides
    for ($i = 1; $i -lt $Height - 1; $i++) {
        Set-FrameChar $Frame $X ($Y + $i) $vc $Color
        Set-FrameChar $Frame ($X + $Width - 1) ($Y + $i) $vc $Color
    }
    
    # Bottom
    Set-FrameChar $Frame $X ($Y + $Height - 1) $bl $Color
    for ($i = 1; $i -lt $Width - 1; $i++) { Set-FrameChar $Frame ($X + $i) ($Y + $Height - 1) $hc $Color }
    Set-FrameChar $Frame ($X + $Width - 1) ($Y + $Height - 1) $br $Color
}

function Draw-FrameTitle($Frame, $X, $Y, $Width, $Title, $Color = 'Cyan') {
    if ($Width -lt 4) { return }
    $pad = [math]::Max(0, $Width - 2 - $Title.Length)
    $leftPad = [math]::Floor($pad / 2)
    $rightPad = $pad - $leftPad
    Set-FrameText $Frame ($X + 1 + $leftPad) $Y $Title $Color
}

function Draw-Bar($Frame, $X, $Y, $Width, $Current, $Max, $Color = 'Green', $EmptyColor = 'DarkGray') {
    if ($Max -le 0) { $Max = 1 }
    $filled = [math]::Min($Width, [math]::Floor(($Current / $Max) * $Width))
    for ($i = 0; $i -lt $Width; $i++) {
        $c = if ($i -lt $filled) { [char]0x2588 } else { [char]0x2591 } # █ / ░
        $col = if ($i -lt $filled) { $Color } else { $EmptyColor }
        Set-FrameChar $Frame ($X + $i) $Y $c $col
    }
}

# === RENDERER ===
# Double-buffered: wir speichern den letzten Frame und rendern nur Deltas.
# Falls der Terminal resized wurde, rendern wir komplett neu.

$script:LastRenderedFrame = $null
$script:LastTerminalWidth = 0
$script:LastTerminalHeight = 0

function Reset-RenderBuffer {
    $script:LastRenderedFrame = $null
    $script:LastTerminalWidth = 0
    $script:LastTerminalHeight = 0
}

function Render-Frame($Frame, [switch]$ForceFull) {
    $termWidth = $Host.UI.RawUI.WindowSize.Width
    $termHeight = $Host.UI.RawUI.WindowSize.Height
    
    # Detect resize
    $resized = ($termWidth -ne $script:LastTerminalWidth) -or ($termHeight -ne $script:LastTerminalHeight)
    if ($resized) { $ForceFull = $true }
    $script:LastTerminalWidth = $termWidth
    $script:LastTerminalHeight = $termHeight
    
    if ($ForceFull -or -not $script:LastRenderedFrame) {
        # Full render
        try { [Console]::CursorVisible = $false } catch {}
        try { [Console]::SetCursorPosition(0, 0) } catch {}
        for ($y = 0; $y -lt $Frame.Height; $y++) {
            $line = ""
            $currentColor = $null
            $currentBg = $null
            for ($x = 0; $x -lt $Frame.Width; $x++) {
                $cell = $Frame.Cells[$y][$x]
                if ($cell.Color -ne $currentColor -or $cell.BgColor -ne $currentBg) {
                    if ($line -ne "") { Write-Host $line -NoNewline -ForegroundColor $currentColor }
                    $currentColor = $cell.Color
                    $currentBg = $cell.BgColor
                    $line = ""
                }
                $line += $cell.Char
            }
            if ($line -ne "") { Write-Host $line -NoNewline -ForegroundColor $currentColor }
            # Clear rest of line
            if ($Frame.Width -lt $termWidth) {
                Write-Host (" " * ($termWidth - $Frame.Width)) -NoNewline
            }
            if ($y -lt $Frame.Height - 1) { Write-Host "" }
        }
        # Clear remaining lines
        for ($y = $Frame.Height; $y -lt $termHeight; $y++) {
            if ($y -lt $termHeight - 1) { Write-Host "" }
        }
    } else {
        # Delta render
        for ($y = 0; $y -lt $Frame.Height; $y++) {
            for ($x = 0; $x -lt $Frame.Width; $x++) {
                $cell = $Frame.Cells[$y][$x]
                $last = $script:LastRenderedFrame.Cells[$y][$x]
                if ($cell.Char -ne $last.Char -or $cell.Color -ne $last.Color -or $cell.BgColor -ne $last.BgColor) {
                    try { [Console]::SetCursorPosition($x, $y) } catch {}
                    Write-Host $cell.Char -NoNewline -ForegroundColor $cell.Color
                }
            }
        }
    }
    
    # Deep-copy frame for next delta comparison
    $script:LastRenderedFrame = @{ Width = $Frame.Width; Height = $Frame.Height; Cells = @() }
    for ($y = 0; $y -lt $Frame.Height; $y++) {
        $row = @()
        for ($x = 0; $x -lt $Frame.Width; $x++) {
            $c = $Frame.Cells[$y][$x]
            $row += @{ Char = $c.Char; Color = $c.Color; BgColor = $c.BgColor }
        }
        $script:LastRenderedFrame.Cells += ,$row
    }
}

# === LEGACY COMPATIBILITY ===
# Show-Frame und Show-Bar existieren weiterhin, nutzen aber den Renderer.

function Show-FrameLegacy($Title, [switch]$Double) {
    $w = [math]::Min(50, $Host.UI.RawUI.WindowSize.Width - 4)
    $h = 3
    $f = New-Frame $w $h
    Draw-FrameBorder $f 0 0 $w $h 'Cyan' -Double:$Double
    Draw-FrameTitle $f 0 0 $w $Title 'Cyan'
    Render-Frame $f -ForceFull
}

} catch {
    Write-Host "[engine-render] CRITICAL ERROR: $_" -ForegroundColor Red
}
