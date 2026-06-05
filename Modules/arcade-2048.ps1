# BUXE_OS v24.5 -- 2048 (TUI)
# Klassisches 2048. Verschiebe Kacheln, verbinde gleiche Werte, erreiche 2048.

try {

function Get-2048TileColor($value) {
    switch ($value) {
        2 { return 'White' }
        4 { return 'Gray' }
        8 { return 'Yellow' }
        16 { return 'DarkYellow' }
        32 { return 'Magenta' }
        64 { return 'Red' }
        default { return 'Cyan' }
    }
}

function New-2048Grid {
    $grid = @()
    for ($y = 0; $y -lt 4; $y++) {
        $grid += ,@(0, 0, 0, 0)
    }
    return $grid
}

function Add-2048Tile($grid) {
    $empty = @()
    for ($y = 0; $y -lt 4; $y++) {
        for ($x = 0; $x -lt 4; $x++) {
            if ($grid[$y][$x] -eq 0) { $empty += ,@($x, $y) }
        }
    }
    if ($empty.Count -eq 0) { return }
    $pos = $empty | Get-Random
    $grid[$pos[1]][$pos[0]] = if ((Get-Random -Maximum 10) -eq 0) { 4 } else { 2 }
}

function Process-2048Line($line, [ref]$scoreRef) {
    $nz = $line | Where-Object { $_ -ne 0 }
    $result = @()
    $i = 0
    while ($i -lt $nz.Count) {
        if ($i + 1 -lt $nz.Count -and $nz[$i] -eq $nz[$i + 1]) {
            $merged = $nz[$i] * 2
            $result += $merged
            $scoreRef.Value += $merged
            $i += 2
        } else {
            $result += $nz[$i]
            $i++
        }
    }
    while ($result.Count -lt 4) { $result += 0 }
    return $result
}

function Invoke-2048Move($grid, [string]$dir, [ref]$scoreRef) {
    $moved = $false
    for ($i = 0; $i -lt 4; $i++) {
        $line = @()
        for ($j = 0; $j -lt 4; $j++) {
            $x = if ($dir -in @('LEFT','RIGHT')) { $j } else { $i }
            $y = if ($dir -in @('LEFT','RIGHT')) { $i } else { $j }
            $line += $grid[$y][$x]
        }
        $needsReverse = ($dir -in @('RIGHT','DOWN'))
        if ($needsReverse) { $line = @($line[3], $line[2], $line[1], $line[0]) }
        $newLine = Process-2048Line $line $scoreRef
        if ($needsReverse) { $newLine = @($newLine[3], $newLine[2], $newLine[1], $newLine[0]) }
        for ($j = 0; $j -lt 4; $j++) {
            $x = if ($dir -in @('LEFT','RIGHT')) { $j } else { $i }
            $y = if ($dir -in @('LEFT','RIGHT')) { $i } else { $j }
            if ($grid[$y][$x] -ne $newLine[$j]) { $moved = $true }
            $grid[$y][$x] = $newLine[$j]
        }
    }
    return $moved
}

function Test-2048GameOver($grid) {
    for ($y = 0; $y -lt 4; $y++) {
        for ($x = 0; $x -lt 4; $x++) {
            if ($grid[$y][$x] -eq 0) { return $false }
            $v = $grid[$y][$x]
            if ($x -lt 3 -and $grid[$y][$x + 1] -eq $v) { return $false }
            if ($y -lt 3 -and $grid[$y + 1][$x] -eq $v) { return $false }
        }
    }
    return $true
}

function Get-2048BestTile($grid) {
    $best = 0
    for ($y = 0; $y -lt 4; $y++) {
        for ($x = 0; $x -lt 4; $x++) {
            if ($grid[$y][$x] -gt $best) { $best = $grid[$y][$x] }
        }
    }
    return $best
}

function Draw-2048Scene($grid, $score, $bestScore, $message) {
    $w = 36; $h = 16
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h "2048" 'Cyan' -Double
    Add-SceneText $s 2 1 "Score: $score  Best: $bestScore" 'Yellow'

    $top = "+-----+-----+-----+-----+"
    $mid = "+-----+-----+-----+-----+"
    $bot = "+-----+-----+-----+-----+"

    Add-SceneText $s 2 3 $top 'White'
    for ($y = 0; $y -lt 4; $y++) {
        $line = "|"
        for ($x = 0; $x -lt 4; $x++) {
            $val = $grid[$y][$x]
            $cell = if ($val -eq 0) { "     " } else { "{0,4} " -f $val }
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
    Add-SceneText $s 2 14 "[WASD] Move  [Q] Quit" 'DarkGray'
    Show-Scene $s -Force
}

function Start-Game2048 {
    try { Show-GameCompanionComment "game_2048_start" } catch {}

    $grid = New-2048Grid
    Add-2048Tile $grid
    Add-2048Tile $grid

    $score = 0
    $won = $false
    $gameOver = $false

    Load-State
    $bestScore = 0
    $stats = Get-ArcadeStats "Game2048"
    if ($stats -and $stats.BestScore) { $bestScore = $stats.BestScore }

    Reset-RenderBuffer

    while (-not $gameOver) {
        $msg = if ($won) { "2048 erreicht! Weiterspielen?" } else { $null }
        Draw-2048Scene $grid $score $bestScore $msg

        if (-not $won -and (Get-2048BestTile $grid) -ge 2048) {
            $won = $true
            Invoke-GameSound 'Win'
        }

        $act = Read-GameChoice "" "^[WASDQ]$"
        if ($act -eq 'Q') { break }

        $dir = switch ($act) { 'W' { 'UP' } 'S' { 'DOWN' } 'A' { 'LEFT' } 'D' { 'RIGHT' } }
        $scoreRef = [ref]$score
        $moved = Invoke-2048Move $grid $dir $scoreRef
        $score = $scoreRef.Value

        if ($moved) {
            Add-2048Tile $grid
            if (Test-2048GameOver $grid) {
                $gameOver = $true
                Invoke-GameSound 'GameOver'
            }
        }
    }

    # Save stats
    $bestTile = Get-2048BestTile $grid
    Load-State
    $stats = Get-ArcadeStats "Game2048"
    if (-not $stats.BestScore -or $score -gt $stats.BestScore) { $stats.BestScore = $score }
    if (-not $stats.BestTile -or $bestTile -gt $stats.BestTile) { $stats.BestTile = $bestTile }
    $stats.GamesPlayed++
    Set-ArcadeStats "Game2048" $stats

    if ($won) { Unlock-Achievement "2048 Master" }

    Draw-2048Scene $grid $score $bestScore $null
    if ($gameOver) {
        Write-Host "`n  GAME OVER! Keine Zuege mehr moeglich." -ForegroundColor Red
    } else {
        Write-Host "`n  Abgebrochen. Score: $score" -ForegroundColor DarkGray
    }
    Wait-Enter
}

} catch {
    Write-Host "[arcade-2048] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
