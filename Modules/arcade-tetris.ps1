# BUXE_OS v24.4 -- TETRIS (TUI)
# Klassisches Tetris auf dem TUI-Framework.

try {

# === TETROMINO DEFINITIONS ===
# 7 Pieces mit 4 Rotationen (0-3). '.' = leer, '#' = Block.

$script:TetrisPieces = @{
    I = @(
        @("....","####","....","...."),
        @("..#.","..#.","..#.","..#."),
        @("....","....","####","...."),
        @(".#..",".#..",".#..",".#..")
    )
    O = @(
        @("....",".##.",".##.","...."),
        @("....",".##.",".##.","...."),
        @("....",".##.",".##.","...."),
        @("....",".##.",".##.","....")
    )
    T = @(
        @("....",".#..","###.","...."),
        @("....",".#..",".##.",".#.."),
        @("....","....","###.",".#.."),
        @("....",".#..","##..",".#..")
    )
    S = @(
        @("....",".##.","##..","...."),
        @("....",".#..",".##.","..#."),
        @("....","....",".##.","##.."),
        @("....","#...","##..",".#..")
    )
    Z = @(
        @("....","##..",".##.","...."),
        @("....","..#.",".##.",".#.."),
        @("....","....","##..",".##."),
        @("....",".#..",".##.","#...")
    )
    J = @(
        @("....","#...","###.","...."),
        @("....",".##.",".#..",".#.."),
        @("....","....","###.","..#."),
        @("....","..#.","..#.",".##.")
    )
    L = @(
        @("....","..#.","###.","...."),
        @("....",".#..",".#..",".##."),
        @("....","....","###.","#..."),
        @("....",".##.","..#.","..#.")
    )
}

$script:TetrisPieceOrder = @("I","O","T","S","Z","J","L")

# === BOARD ===

function New-TetrisBoard($width = 10, $height = 20) {
    $board = @()
    for ($y = 0; $y -lt $height; $y++) {
        $row = @()
        for ($x = 0; $x -lt $width; $x++) { $row += '.' }
        $board += ,$row
    }
    return $board
}

function New-TetrisPiece {
    $type = $script:TetrisPieceOrder | Get-Random
    return @{ Type = $type; X = 3; Y = 0; Rotation = 0 }
}

function Get-NextTetrisPiece($currentType) {
    $remaining = $script:TetrisPieceOrder | Where-Object { $_ -ne $currentType }
    $type = $remaining | Get-Random
    return @{ Type = $type; X = 3; Y = 0; Rotation = 0 }
}

function Test-TetrisCollision($board, $piece, $newX, $newY, $newRot) {
    $shape = $script:TetrisPieces[$piece.Type][$newRot]
    for ($sy = 0; $sy -lt 4; $sy++) {
        for ($sx = 0; $sx -lt 4; $sx++) {
            if ($shape[$sy][$sx] -eq '#') {
                $bx = $newX + $sx
                $by = $newY + $sy
                if ($bx -lt 0 -or $bx -ge 10 -or $by -ge 20) { return $true }
                if ($by -ge 0 -and $board[$by][$bx] -ne '.') { return $true }
            }
        }
    }
    return $false
}

function Lock-TetrisPiece($board, $piece) {
    $shape = $script:TetrisPieces[$piece.Type][$piece.Rotation]
    for ($sy = 0; $sy -lt 4; $sy++) {
        for ($sx = 0; $sx -lt 4; $sx++) {
            if ($shape[$sy][$sx] -eq '#') {
                $bx = $piece.X + $sx
                $by = $piece.Y + $sy
                if ($bx -ge 0 -and $bx -lt 10 -and $by -ge 0 -and $by -lt 20) {
                    $board[$by][$bx] = '#'
                }
            }
        }
    }
}

function Clear-TetrisLines($board) {
    $cleared = 0
    $newBoard = @()
    for ($y = 0; $y -lt 20; $y++) {
        $isFull = $true
        for ($x = 0; $x -lt 10; $x++) {
            if ($board[$y][$x] -eq '.') { $isFull = $false; break }
        }
        if ($isFull) {
            $cleared++
        } else {
            $newBoard += ,$board[$y]
        }
    }
    # Add empty lines at top
    for ($i = 0; $i -lt $cleared; $i++) {
        $row = @()
        for ($x = 0; $x -lt 10; $x++) { $row += '.' }
        $newBoard = ,$row + $newBoard
    }
    # Replace board contents
    for ($y = 0; $y -lt 20; $y++) {
        $board[$y] = $newBoard[$y]
    }
    return $cleared
}

function Get-TetrisDropInterval($level) {
    # Level 0: 1000ms, Level 1: 800ms, ... Level 10: 100ms
    $interval = [math]::Max(100, 1000 - ($level * 90))
    return $interval
}

function Draw-TetrisScene($board, $piece, $nextPiece, $score, $lines, $level, $gameOver) {
    $w = 50; $h = 22
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h "TETRIS" 'Cyan' -Double
    
    # Draw board border
    for ($y = 0; $y -lt 20; $y++) {
        Add-SceneText $s 2 ($y + 1) "|" 'DarkGray'
        Add-SceneText $s 13 ($y + 1) "|" 'DarkGray'
    }
    Add-SceneText $s 2 21 "+----------+" 'DarkGray'
    
    # Draw board contents + active piece
    for ($y = 0; $y -lt 20; $y++) {
        $line = ""
        for ($x = 0; $x -lt 10; $x++) {
            $isPiece = $false
            $shape = $script:TetrisPieces[$piece.Type][$piece.Rotation]
            for ($sy = 0; $sy -lt 4; $sy++) {
                for ($sx = 0; $sx -lt 4; $sx++) {
                    if ($shape[$sy][$sx] -eq '#') {
                        if ($piece.X + $sx -eq $x -and $piece.Y + $sy -eq $y) {
                            $isPiece = $true
                        }
                    }
                }
            }
            if ($isPiece) {
                $line += [char]0x2588  # Full block
            } elseif ($board[$y][$x] -eq '#') {
                $line += [char]0x2588
            } else {
                $line += " "
            }
        }
        Add-SceneText $s 3 ($y + 1) $line 'White'
    }
    
    # UI Panel
    Add-SceneText $s 16 2 "Score:" 'White'
    Add-SceneText $s 16 3 "$score" 'Yellow'
    Add-SceneText $s 16 5 "Level:" 'White'
    Add-SceneText $s 16 6 "$level" 'Cyan'
    Add-SceneText $s 16 8 "Lines:" 'White'
    Add-SceneText $s 16 9 "$lines" 'Green'
    
    # Next piece preview
    Add-SceneText $s 16 11 "Next:" 'White'
    $np = $script:TetrisPieces[$nextPiece.Type][0]
    for ($ny = 0; $ny -lt 4; $ny++) {
        $pline = ""
        for ($nx = 0; $nx -lt 4; $nx++) {
            if ($np[$ny][$nx] -eq '#') { $pline += [char]0x2588 } else { $pline += " " }
        }
        Add-SceneText $s 16 (12 + $ny) $pline 'DarkGray'
    }
    
    # Controls
    Add-SceneText $s 16 18 "[A]Left [D]Right" 'DarkGray'
    Add-SceneText $s 16 19 "[W]Rot  [S]Drop" 'DarkGray'
    Add-SceneText $s 16 20 "[Q]Quit" 'DarkGray'
    
    if ($gameOver) {
        Add-SceneText $s 4 10 " GAME OVER " 'Red'
        Add-SceneText $s 4 11 "Score: $score" 'Yellow'
    }
    
    Show-Scene $s
}

# === MAIN GAME ===

function tetris {
    $board = New-TetrisBoard
    $piece = New-TetrisPiece
    $nextPiece = Get-NextTetrisPiece $piece.Type
    $score = 0
    $lines = 0
    $level = 0
    $gameOver = $false
    $dropTimer = 0
    $dropInterval = Get-TetrisDropInterval 0
    
    Reset-RenderBuffer
    
    # Show start screen
    $startScene = New-Scene 50 10
    Add-SceneFrame $startScene 0 0 50 10 "TETRIS" 'Cyan' -Double
    Add-SceneText $startScene 4 3 "Vollstaendige Zeilen fuer Punkte!" 'White'
    Add-SceneText $startScene 4 5 "[ENTER] Starten" 'Green'
    Add-SceneText $startScene 4 6 "[Q] Quit" 'DarkGray'
    Show-Scene $startScene -Force
    
    $act = Read-GameChoice "" "^[\rQ]$"
    if ($act -eq 'Q') { return }
    
    $lastDrop = Get-Date
    
    while (-not $gameOver) {
        # --- INPUT ---
        $inputEvents = @()
        if ($script:MockInputEnabled -and $script:MockInputQueue.Count -gt 0) {
            $char = $script:MockInputQueue[0]
            $script:MockInputQueue = $script:MockInputQueue | Select-Object -Skip 1
            $inputEvents += @{ Char = $char }
            if ($char -eq 'Q') { break }
        } else {
            while ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                $inputEvents += @{ Char = $key.KeyChar.ToString().ToUpper() }
            }
        }
        
        $moved = $false
        foreach ($evt in $inputEvents) {
            switch ($evt.Char) {
                'A' {
                    if (-not (Test-TetrisCollision $board $piece ($piece.X - 1) $piece.Y $piece.Rotation)) {
                        $piece.X--; $moved = $true
                    }
                }
                'D' {
                    if (-not (Test-TetrisCollision $board $piece ($piece.X + 1) $piece.Y $piece.Rotation)) {
                        $piece.X++; $moved = $true
                    }
                }
                'W' {
                    $newRot = ($piece.Rotation + 1) % 4
                    if (-not (Test-TetrisCollision $board $piece $piece.X $piece.Y $newRot)) {
                        $piece.Rotation = $newRot; $moved = $true
                    }
                }
                'S' {
                    if (-not (Test-TetrisCollision $board $piece $piece.X ($piece.Y + 1) $piece.Rotation)) {
                        $piece.Y++; $score++; $moved = $true
                    }
                }
                'Q' { return }
            }
        }
        
        # --- DROP LOGIC ---
        $now = Get-Date
        $elapsed = ($now - $lastDrop).TotalMilliseconds
        if ($elapsed -ge $dropInterval) {
            if (-not (Test-TetrisCollision $board $piece $piece.X ($piece.Y + 1) $piece.Rotation)) {
                $piece.Y++
            } else {
                # Lock piece
                Lock-TetrisPiece $board $piece
                $cleared = Clear-TetrisLines $board
                if ($cleared -gt 0) {
                    Invoke-GameSound 'LineClear'
                    if ((Get-Random -Maximum 3) -eq 0) { Show-GameCompanionComment 'game_tetris' }
                    $lines += $cleared
                    $score += switch ($cleared) {
                        1 { 100 }
                        2 { 300 }
                        3 { 500 }
                        4 { 800 }
                    }
                    $newLevel = [math]::Floor($lines / 10)
                    if ($newLevel -gt $level) {
                        $level = $newLevel
                        $dropInterval = Get-TetrisDropInterval $level
                    }
                }
                
                # Spawn new piece
                $piece = $nextPiece
                $nextPiece = Get-NextTetrisPiece $piece.Type
                
                # Game over check
                if (Test-TetrisCollision $board $piece $piece.X $piece.Y $piece.Rotation) {
                    $gameOver = $true
                    Invoke-GameSound 'GameOver'
                    Show-GameCompanionComment 'game_tetris'
                }
            }
            $lastDrop = $now
        }
        
        # --- RENDER ---
        Draw-TetrisScene $board $piece $nextPiece $score $lines $level $gameOver
        
        if (-not $gameOver) {
            Start-Sleep -Milliseconds 50
        }
    }
    
    # Game over screen
    Draw-TetrisScene $board $piece $nextPiece $score $lines $level $gameOver
    
    # Save stats
    Load-State
    $stats = Get-ArcadeStats "Tetris"
    if ($score -gt $stats.BestScore) { $stats.BestScore = $score }
    if ($lines -gt $stats.BestLines) { $stats.BestLines = $lines }
    $stats.GamesPlayed++
    Set-ArcadeStats "Tetris" $stats
    
    if ($lines -ge 10) { Unlock-Achievement "Tetris Master" }
    
    Show-Scene $startScene -Force
    Wait-Enter
}

} catch {
    Write-Host "[arcade-tetris] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
