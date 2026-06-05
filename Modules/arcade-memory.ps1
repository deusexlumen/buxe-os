# BUXE_OS v24.5 -- MEMORY MATCH (TUI)
# Finde die 8 Symbolpaare. Merk dir die Positionen!

try {

$script:MemorySymbols = @('♠', '♥', '♦', '♣', '★', '☆', '♪', '♫')

function New-MemoryGrid {
    $pairs = @()
    foreach ($sym in $script:MemorySymbols) { $pairs += $sym; $pairs += $sym }
    # Shuffle
    $shuffled = @()
    while ($pairs.Count -gt 0) {
        $idx = Get-Random -Maximum $pairs.Count
        $shuffled += $pairs[$idx]
        $pairs = $pairs[0..($idx-1)] + $pairs[($idx+1)..($pairs.Count-1)]
    }
    $grid = @()
    $idx = 0
    for ($y = 0; $y -lt 4; $y++) {
        $row = @()
        for ($x = 0; $x -lt 4; $x++) {
            $row += @{
                Symbol = $shuffled[$idx]
                Revealed = $false
                Matched = $false
            }
            $idx++
        }
        $grid += ,$row
    }
    return $grid
}

function Draw-MemoryScene($grid, $cx, $cy, $moves, $elapsedSec, $message) {
    $w = 38; $h = 18
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h "MEMORY MATCH" 'Magenta' -Double
    Add-SceneText $s 2 1 "Moves: $moves  Time: ${elapsedSec}s" 'Yellow'

    $top = "+----+----+----+----+"
    $mid = "+----+----+----+----+"
    $bot = "+----+----+----+----+"

    Add-SceneText $s 2 3 $top 'White'
    for ($y = 0; $y -lt 4; $y++) {
        $line = "|"
        for ($x = 0; $x -lt 4; $x++) {
            $c = $grid[$y][$x]
            $isCursor = ($x -eq $cx -and $y -eq $cy)
            if ($c.Matched) {
                $cell = " {0}  " -f $c.Symbol
            } elseif ($c.Revealed) {
                $cell = " {0}  " -f $c.Symbol
            } else {
                $cell = " ?? "
            }
            if ($isCursor) {
                $cell = "[{0}]" -f ($c.Matched -or $c.Revealed ? $c.Symbol : "?")
            }
            $line += $cell + "|"
        }
        Add-SceneText $s 2 (4 + $y * 2) $line 'White'
        if ($y -lt 3) {
            Add-SceneText $s 2 (5 + $y * 2) $mid 'White'
        }
    }
    Add-SceneText $s 2 11 $bot 'White'

    if ($message) {
        Add-SceneText $s 2 13 $message 'Green'
    }
    Add-SceneText $s 2 14 "[WASD] Move  [ENTER] Umdrehen  [Q] Quit" 'DarkGray'
    Show-Scene $s -Force
}

function Start-MemoryMatch {
    try { Show-GameCompanionComment "game_memory_start" } catch {}

    $grid = New-MemoryGrid
    $cx = 0; $cy = 0
    $moves = 0
    $pairsFound = 0
    $revealed = @()
    $start = Get-Date
    $message = $null
    $won = $false

    Reset-RenderBuffer

    while (-not $won) {
        $elapsed = [math]::Floor(((Get-Date) - $start).TotalSeconds)
        Draw-MemoryScene $grid $cx $cy $moves $elapsed $message
        $message = $null

        $act = Read-GameChoice "" "^[WASDQ\r]$"
        if ($act -eq 'Q') { break }

        switch ($act) {
            'W' { if ($cy -gt 0) { $cy-- } }
            'A' { if ($cx -gt 0) { $cx-- } }
            'S' { if ($cy -lt 3) { $cy++ } }
            'D' { if ($cx -lt 3) { $cx++ } }
            "`r" {
                $card = $grid[$cy][$cx]
                if (-not $card.Revealed -and -not $card.Matched -and $revealed.Count -lt 2) {
                    $card.Revealed = $true
                    $revealed += ,@($cx, $cy)
                    Invoke-GameSound 'Click'

                    if ($revealed.Count -eq 2) {
                        $moves++
                        $r1 = $revealed[0]
                        $r2 = $revealed[1]
                        $c1 = $grid[$r1[1]][$r1[0]]
                        $c2 = $grid[$r2[1]][$r2[0]]

                        Draw-MemoryScene $grid $cx $cy $moves $elapsed $null
                        Start-Sleep -Milliseconds 800

                        if ($c1.Symbol -eq $c2.Symbol) {
                            $c1.Matched = $true
                            $c2.Matched = $true
                            $pairsFound++
                            Invoke-GameSound 'Win'
                            if ($pairsFound -eq 8) {
                                $won = $true
                            }
                        } else {
                            $c1.Revealed = $false
                            $c2.Revealed = $false
                            Invoke-GameSound 'Error'
                        }
                        $revealed = @()
                    }
                }
            }
        }
    }

    $elapsed = [math]::Floor(((Get-Date) - $start).TotalSeconds)
    Draw-MemoryScene $grid $cx $cy $moves $elapsed $null

    # Save stats
    Load-State
    $stats = Get-ArcadeStats "MemoryMatch"
    if ($won) {
        Invoke-GameSound 'Win'
        Write-Host "`n  GEWONNEN! Alle Paare gefunden in $moves Zuegen und ${elapsed}s." -ForegroundColor Green
        if (-not $stats.BestTime -or $elapsed -lt $stats.BestTime) { $stats.BestTime = $elapsed }
        if (-not $stats.BestMoves -or $moves -lt $stats.BestMoves) { $stats.BestMoves = $moves }
        Unlock-Achievement "Memory Master"
    } else {
        Write-Host "`n  Abgebrochen. $pairsFound/8 Paare gefunden." -ForegroundColor DarkGray
    }
    $stats.GamesPlayed++
    Set-ArcadeStats "MemoryMatch" $stats

    Wait-Enter
}

} catch {
    Write-Host "[arcade-memory] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
