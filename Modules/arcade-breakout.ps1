# BUXE_OS v24.5 -- BREAKOUT (TUI)
# Klassisches Breakout auf dem TUI-Framework.

try {

# === CONFIG ===
$script:BreakoutWidth = 50
$script:BreakoutHeight = 24
$script:PaddleWidth = 7
$script:BrickRows = 4
$script:BrickCols = 10
$script:BrickWidth = 4

# === GAME STATE ===

function New-BreakoutLevel($levelNum) {
    $bricks = @()
    $colors = @('Red','Yellow','Green','Cyan')
    for ($row = 0; $row -lt $script:BrickRows; $row++) {
        for ($col = 0; $col -lt $script:BrickCols; $col++) {
            $bricks += @{
                X = 2 + ($col * ($script:BrickWidth + 1))
                Y = 2 + $row
                Width = $script:BrickWidth
                Height = 1
                Color = $colors[$row]
                Strength = [math]::Max(1, $script:BrickRows - $row)
                Active = $true
            }
        }
    }
    return @{
        Bricks = $bricks
        PaddleX = [math]::Floor(($script:BreakoutWidth - $script:PaddleWidth) / 2)
        BallX = [math]::Floor($script:BreakoutWidth / 2)
        BallY = 18
        BallDX = if ((Get-Random -Maximum 2) -eq 0) { -0.6 } else { 0.6 }
        BallDY = -0.8
        Score = 0
        Lives = 3
        Level = $levelNum
        State = "PLAY"
    }
}

function Test-BoxCollision($ax, $ay, $aw, $ah, $bx, $by, $bw, $bh) {
    return ($ax -lt $bx + $bw -and $ax + $aw -gt $bx -and
            $ay -lt $by + $bh -and $ay + $ah -gt $by)
}

function Update-Breakout($game) {
    if ($game.State -ne "PLAY") { return }
    
    # Move ball
    $game.BallX += $game.BallDX
    $game.BallY += $game.BallDY
    
    # Wall collisions
    if ($game.BallX -le 0 -or $game.BallX -ge $script:BreakoutWidth - 1) {
        $game.BallDX = -$game.BallDX
        $game.BallX = [math]::Max(1, [math]::Min($script:BreakoutWidth - 2, $game.BallX))
        Invoke-GameSound 'Click'
    }
    if ($game.BallY -le 0) {
        $game.BallDY = -$game.BallDY
        $game.BallY = 1
        Invoke-GameSound 'Click'
    }
    
    # Paddle collision
    $px = $game.PaddleX
    $py = $script:BreakoutHeight - 2
    if (Test-BoxCollision $game.BallX $game.BallY 1 1 $px $py $script:PaddleWidth 1) {
        $game.BallDY = -[math]::Abs($game.BallDY)
        # Angle based on hit position
        $hitPos = ($game.BallX - $px) / $script:PaddleWidth
        $game.BallDX = ($hitPos - 0.5) * 1.5
        $game.BallY = $py - 1
        Invoke-GameSound 'Click'
    }
    
    # Brick collisions
    foreach ($brick in $game.Bricks) {
        if (-not $brick.Active) { continue }
        if (Test-BoxCollision $game.BallX $game.BallY 1 1 $brick.X $brick.Y $brick.Width $brick.Height) {
            $brick.Strength--
            if ($brick.Strength -le 0) {
                $brick.Active = $false
                $game.Score += 10 * $game.Level
                Invoke-GameSound 'LineClear'
                if ((Get-Random -Maximum 4) -eq 0) { Show-GameCompanionComment 'game_breakout' }
            } else {
                Invoke-GameSound 'Click'
            }
            # Determine bounce direction
            $bx = $game.BallX - $game.BallDX
            $by = $game.BallY - $game.BallDY
            if ($bx -lt $brick.X -or $bx -ge $brick.X + $brick.Width) {
                $game.BallDX = -$game.BallDX
            } else {
                $game.BallDY = -$game.BallDY
            }
            break
        }
    }
    
    # Check level complete
    $activeBricks = ($game.Bricks | Where-Object { $_.Active }).Count
    if ($activeBricks -eq 0) {
        $game.State = "LEVEL_UP"
        Invoke-GameSound 'Win'
        Show-GameCompanionComment 'game_breakout'
        return
    }
    
    # Check ball out
    if ($game.BallY -ge $script:BreakoutHeight) {
        $game.Lives--
        if ($game.Lives -le 0) {
            $game.State = "GAME_OVER"
            Invoke-GameSound 'GameOver'
            Show-GameCompanionComment 'game_breakout'
        } else {
            $game.BallX = [math]::Floor($script:BreakoutWidth / 2)
            $game.BallY = 18
            $game.BallDX = if ((Get-Random -Maximum 2) -eq 0) { -0.6 } else { 0.6 }
            $game.BallDY = -0.8
            Invoke-GameSound 'Error'
        }
    }
}

function Draw-Breakout($game) {
    $w = $script:BreakoutWidth
    $h = $script:BreakoutHeight
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h "BREAKOUT" 'Cyan' -Double
    
    # Bricks
    foreach ($brick in $game.Bricks) {
        if (-not $brick.Active) { continue }
        $c = if ($brick.Strength -gt 1) { $brick.Color } else { 'White' }
        for ($bx = 0; $bx -lt $brick.Width; $bx++) {
            Set-FrameChar $s.Frame ($brick.X + $bx) $brick.Y ([char]0x2588) $c
        }
    }
    
    # Paddle
    $px = $game.PaddleX
    $py = $script:BreakoutHeight - 2
    for ($i = 0; $i -lt $script:PaddleWidth; $i++) {
        Set-FrameChar $s.Frame ($px + $i) $py ([char]0x2588) 'White'
    }
    
    # Ball
    $bx = [math]::Floor($game.BallX)
    $by = [math]::Floor($game.BallY)
    if ($bx -ge 0 -and $bx -lt $w -and $by -ge 0 -and $by -lt $h) {
        Set-FrameChar $s.Frame $bx $by 'O' 'Yellow'
    }
    
    # UI
    Add-SceneText $s 2 ($h - 1) "Score: $($game.Score)  Lives: $($game.Lives)  Level: $($game.Level)" 'DarkGray'
    
    if ($game.State -eq "LEVEL_UP") {
        Add-SceneText $s 16 12 "LEVEL UP!" 'Green'
    } elseif ($game.State -eq "GAME_OVER") {
        Add-SceneText $s 16 12 "GAME OVER" 'Red'
        Add-SceneText $s 14 13 "Score: $($game.Score)" 'Yellow'
    }
    
    Show-Scene $s
}

# === MAIN GAME ===

function breakout {
    $level = 1
    $totalScore = 0
    
    Reset-RenderBuffer
    
    # Start screen
    $startScene = New-Scene 50 10
    Add-SceneFrame $startScene 0 0 50 10 "BREAKOUT" 'Cyan' -Double
    Add-SceneText $startScene 4 3 "Zerstoere alle Bloecke!" 'White'
    Add-SceneText $startScene 4 5 "[A]Left [D]Right [Q]Quit" 'DarkGray'
    Add-SceneText $startScene 4 6 "[ENTER] Starten" 'Green'
    Show-Scene $startScene -Force
    
    $act = Read-GameChoice "" "^[\rQAD]$"
    if ($act -eq 'Q') { return }
    
    while ($true) {
        $game = New-BreakoutLevel $level
        $game.Score = $totalScore
        $frameTime = [math]::Max(30, 60 - ($level * 5))
        
        while ($game.State -eq "PLAY") {
            # Input
            $inputEvents = @()
            if ($script:MockInputEnabled -and $script:MockInputQueue.Count -gt 0) {
                $char = $script:MockInputQueue[0]
                $script:MockInputQueue = $script:MockInputQueue | Select-Object -Skip 1
                $inputEvents += @{ Char = $char }
                if ($char -eq 'Q') { return }
            } else {
                while ([Console]::KeyAvailable) {
                    $key = [Console]::ReadKey($true)
                    $inputEvents += @{ Char = $key.KeyChar.ToString().ToUpper() }
                }
            }
            
            foreach ($evt in $inputEvents) {
                switch ($evt.Char) {
                    'A' { if ($game.PaddleX -gt 1) { $game.PaddleX -= 2 } }
                    'D' { if ($game.PaddleX -lt $script:BreakoutWidth - $script:PaddleWidth - 1) { $game.PaddleX += 2 } }
                    'Q' { return }
                }
            }
            
            Update-Breakout $game
            Draw-Breakout $game
            Start-Sleep -Milliseconds $frameTime
        }
        
        $totalScore = $game.Score
        
        if ($game.State -eq "GAME_OVER") {
            Draw-Breakout $game
            Start-Sleep -Milliseconds 2000
            break
        }
        
        if ($game.State -eq "LEVEL_UP") {
            Draw-Breakout $game
            Start-Sleep -Milliseconds 1500
            $level++
        }
    }
    
    # Save stats
    Load-State
    $stats = Get-ArcadeStats "Breakout"
    if ($totalScore -gt $stats.BestScore) { $stats.BestScore = $totalScore }
    $stats.GamesPlayed++
    Set-ArcadeStats "Breakout" $stats
    
    if ($level -ge 3) { Unlock-Achievement "Breakout Pro" }
    
    Wait-Enter
}

} catch {
    Write-Host "[arcade-breakout] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
