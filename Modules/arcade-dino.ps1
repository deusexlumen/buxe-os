# BUXE_OS v24.5 -- DINO JUMP (TUI)
# Chrome-Dino-Style Endless Runner. Springe ueber Kakteen und Voegel.

try {

function Start-DinoJump {
    try { Show-GameCompanionComment "game_dino_start" } catch {}

    $width = 50
    $height = 12
    $groundY = $height - 3
    $dinoX = 3
    $jumpForce = -2.2
    $gravity = 0.35

    $game = @{
        DinoY = $groundY
        DinoVY = 0.0
        IsJumping = $false
        Score = 0
        Obstacles = @()
        Speed = 0.5
        Frame = 0
        Over = $false
    }

    Reset-RenderBuffer

    # Start screen
    $startScene = New-Scene $width $height
    Add-SceneFrame $startScene 0 0 $width $height "DINO JUMP" 'Green' -Double
    Add-SceneText $startScene 4 3 "Weiche den Hindernissen aus!" 'White'
    Add-SceneText $startScene 4 5 "[SPACE/W/UP] Springen" 'DarkGray'
    Add-SceneText $startScene 4 6 "[ENTER] Starten  [Q] Quit" 'DarkGray'
    Show-Scene $startScene -Force

    $act = Read-GameChoice "" "^[\rQ ]$"
    if ($act -eq 'Q') { return }

    $init = { }

    $inputHandler = {
        param($evt, $tick)
        if (($evt.Key -eq 'Spacebar' -or $evt.Key -eq 'W' -or $evt.Key -eq 'UpArrow') -and -not $game.IsJumping) {
            $game.IsJumping = $true
            $game.DinoVY = $jumpForce
        }
        if ($evt.IsQuit) { $game.Over = $true; return 'QUIT' }
    }

    $tick = {
        param($tickCount)
        $game.Frame++

        # Gravity
        if ($game.IsJumping) {
            $game.DinoY += $game.DinoVY
            $game.DinoVY += $gravity
            if ($game.DinoY -ge $groundY) {
                $game.DinoY = $groundY
                $game.IsJumping = $false
                $game.DinoVY = 0
            }
        }

        # Spawn obstacles
        $spawnRate = [math]::Max(25, 70 - [math]::Floor($game.Score / 8))
        if ($game.Frame % $spawnRate -eq 0) {
            $type = if ((Get-Random -Maximum 4) -eq 0) { 'BIRD' } else { 'CACTUS' }
            $y = if ($type -eq 'BIRD') { $groundY - 2 } else { $groundY }
            $game.Obstacles += @{
                X = [double]($width - 3)
                Y = $y
                Type = $type
            }
        }

        # Move obstacles
        $newObstacles = @()
        foreach ($obs in $game.Obstacles) {
            $obs.X -= $game.Speed
            if ($obs.X -ge -1) {
                $newObstacles += $obs
            } else {
                $game.Score++
            }
        }
        $game.Obstacles = $newObstacles

        # Increase speed
        $game.Speed = 0.5 + [math]::Floor($game.Score / 15) * 0.12

        # Collision
        $dinoYInt = [math]::Floor($game.DinoY)
        foreach ($obs in $game.Obstacles) {
            $ox = [math]::Floor($obs.X)
            $oy = $obs.Y
            if ([math]::Abs($ox - $dinoX) -le 1 -and $oy -eq $dinoYInt) {
                $game.Over = $true
                Invoke-GameSound 'GameOver'
                return 'QUIT'
            }
        }

        # Render
        $f = New-Frame $width $height
        Clear-Frame $f
        Draw-FrameBorder $f 0 0 $width $height 'Green' -Double
        Draw-FrameTitle $f 0 0 $width "DINO JUMP" 'Green'

        # Ground
        for ($x = 1; $x -lt $width - 1; $x++) {
            Set-FrameChar $f $x $groundY ([char]0x2550) 'DarkGray'
        }

        # Dino
        Set-FrameChar $f $dinoX $dinoYInt 'D' 'Green'

        # Obstacles
        foreach ($obs in $game.Obstacles) {
            $ox = [math]::Floor($obs.X)
            $ch = if ($obs.Type -eq 'BIRD') { 'v' } else { ([char]0x25B2) }
            $col = if ($obs.Type -eq 'BIRD') { 'Yellow' } else { 'Green' }
            if ($ox -gt 0 -and $ox -lt $width - 1 -and $obs.Y -gt 0 -and $obs.Y -lt $height - 1) {
                Set-FrameChar $f $ox $obs.Y $ch $col
            }
        }

        Set-FrameText $f 2 ($height - 1) "Score: $($game.Score)  Speed: $([math]::Round($game.Speed,1))" 'Yellow'
        Render-Frame $f
    }

    $cleanup = {
        Load-State
        $stats = Get-ArcadeStats "DinoJump"
        if (-not $stats.BestScore -or $game.Score -gt $stats.BestScore) { $stats.BestScore = $game.Score }
        $stats.GamesPlayed++
        Set-ArcadeStats "DinoJump" $stats
        $reward = [math]::Floor($game.Score / 2)
        if ($reward -gt 0 -and $game.Score -eq $stats.BestScore) { Add-Gold $reward "Dino Highscore"; Write-Host "  Highscore-Bonus: +$reward G" -ForegroundColor Green }

        if ($game.Over) {
            Write-Host "`n  GAME OVER! Score: $($game.Score)" -ForegroundColor Red
            if ($game.Score -ge 50) { Unlock-Achievement "Dino Runner" }
        } else {
            Write-Host "`n  Abgebrochen. Score: $($game.Score)" -ForegroundColor DarkGray
        }
        Wait-Enter
    }

    Invoke-GameLoop -Init $init -Tick $tick -InputHandler $inputHandler -Cleanup $cleanup -FPS 10
}

} catch {
    Write-Host "[arcade-dino] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
