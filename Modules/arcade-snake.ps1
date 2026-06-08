# BUXE_OS v24.4 -- SNAKE (TUI)
# Echte Snake-Mechanik: Wachsender Schwanz, Kollisionserkennung, Game Over.

try {

function snake {
    try { Show-GameCompanionComment "game_snake_start" } catch {}
    
    $gridW = 16; $gridH = 12
    $frameW = $gridW * 2 + 4
    $frameH = $gridH + 4
    
    $game = @{
        Body = @(@{ X = [math]::Floor($gridW / 2); Y = [math]::Floor($gridH / 2) })
        Dir = "RIGHT"
        NextDir = "RIGHT"
        Food = @{ X = 0; Y = 0 }
        Score = 0
        Over = $false
    }
    
    # Spawn initial food
    $validPos = $false
    while (-not $validPos) {
        $fx = Get-Random -Minimum 0 -Maximum $gridW
        $fy = Get-Random -Minimum 0 -Maximum $gridH
        $validPos = $true
        foreach ($seg in $game.Body) {
            if ($seg.X -eq $fx -and $seg.Y -eq $fy) { $validPos = $false; break }
        }
    }
    $game.Food = @{ X = $fx; Y = $fy }
    
    $init = { }
    
    $inputHandler = {
        param($evt, $tick)
        switch ($evt.Key) {
            'W' { if ($game.NextDir -ne "DOWN") { $game.NextDir = "UP" } }
            'S' { if ($game.NextDir -ne "UP") { $game.NextDir = "DOWN" } }
            'A' { if ($game.NextDir -ne "RIGHT") { $game.NextDir = "LEFT" } }
            'D' { if ($game.NextDir -ne "LEFT") { $game.NextDir = "RIGHT" } }
            'UpArrow' { if ($game.NextDir -ne "DOWN") { $game.NextDir = "UP" } }
            'DownArrow' { if ($game.NextDir -ne "UP") { $game.NextDir = "DOWN" } }
            'LeftArrow' { if ($game.NextDir -ne "RIGHT") { $game.NextDir = "LEFT" } }
            'RightArrow' { if ($game.NextDir -ne "LEFT") { $game.NextDir = "RIGHT" } }
            'Escape' { $game.Over = $true; return 'QUIT' }
        }
    }
    
    $tick = {
        param($tickCount)
        $game.Dir = $game.NextDir
        $head = $game.Body[0]
        $nx = $head.X
        $ny = $head.Y
        switch ($game.Dir) {
            "UP" { $ny-- }
            "DOWN" { $ny++ }
            "LEFT" { $nx-- }
            "RIGHT" { $nx++ }
        }
        
        # Wall collision
        if ($nx -lt 0 -or $nx -ge $gridW -or $ny -lt 0 -or $ny -ge $gridH) {
            $game.Over = $true
            return 'QUIT'
        }
        
        # Self collision
        foreach ($seg in $game.Body) {
            if ($seg.X -eq $nx -and $seg.Y -eq $ny) {
                $game.Over = $true
                return 'QUIT'
            }
        }
        
        $newHead = @{ X = $nx; Y = $ny }
        $eating = ($nx -eq $game.Food.X -and $ny -eq $game.Food.Y)
        
        # Build new body: prepend head
        $newBody = @($newHead)
        foreach ($seg in $game.Body) {
            $newBody += @{ X = $seg.X; Y = $seg.Y }
        }
        if (-not $eating) {
            $newBody = $newBody[0..($newBody.Count - 2)]
        } else {
            $game.Score++
            # Spawn new food
            $validPos = $false
            while (-not $validPos) {
                $fx = Get-Random -Minimum 0 -Maximum $gridW
                $fy = Get-Random -Minimum 0 -Maximum $gridH
                $validPos = $true
                foreach ($seg in $newBody) {
                    if ($seg.X -eq $fx -and $seg.Y -eq $fy) { $validPos = $false; break }
                }
            }
            $game.Food = @{ X = $fx; Y = $fy }
        }
        $game.Body = $newBody
        
        # Render
        $scene = New-Scene $frameW $frameH
        Add-SceneFrame $scene 0 0 $frameW $frameH "SNAKE" 'Green'
        Add-SceneText $scene 2 1 "Score: $($game.Score)" 'Yellow'
        
        for ($y = 0; $y -lt $gridH; $y++) {
            $line = ""
            for ($x = 0; $x -lt $gridW; $x++) {
                $isHead = ($game.Body[0].X -eq $x -and $game.Body[0].Y -eq $y)
                $isBody = $false
                for ($b = 1; $b -lt $game.Body.Count; $b++) {
                    if ($game.Body[$b].X -eq $x -and $game.Body[$b].Y -eq $y) { $isBody = $true; break }
                }
                $isFood = ($game.Food.X -eq $x -and $game.Food.Y -eq $y)
                if ($isHead) { $line += "O " }
                elseif ($isBody) { $line += "o " }
                elseif ($isFood) { $line += "X " }
                else { $line += ". " }
            }
            Add-SceneText $scene 2 ($y + 2) $line 'DarkGray'
        }
        
        Show-Scene $scene
    }
    
    $cleanup = {
        Load-State
        $stats = Get-ArcadeStats "Snake"
        if (-not $stats.Games) { $stats.Games = 0 }
        $stats.Games = $stats.Games + 1
        $isHigh = $false
        if (-not $stats.BestScore) { $stats.BestScore = 0 }
        if ($game.Score -gt $stats.BestScore) {
            $stats.BestScore = $game.Score
            $isHigh = $true
        }
        Set-ArcadeStats "Snake" $stats
        Save-State
        
        # ARG v3.0: Matrix-Hinweis bei Score 1337 -- nur wenn IDDQD unlocked, Matrix noch nicht
        if ($game.Score -eq 1337) {
            if (Get-Command Test-ArgUnlocked -ErrorAction SilentlyContinue) {
                if ((Test-ArgUnlocked "iddqd") -and -not (Test-ArgUnlocked "matrix")) {
                    Write-Host ""
                    Write-Host "  [PIXEL_BREAK] Score 1337 erreicht." -ForegroundColor Red
                    Write-Host "  Die Schlange... sie hat ein Symbol gefressen." -ForegroundColor Red
                    Write-Host "  Ein Buchstabe. Ein 'L'." -ForegroundColor Red
                    Write-Host "  LOOK_CLOSER" -ForegroundColor DarkGray
                }
            }
        }

        if ($game.Over) {
            Write-Host "`n  GAME OVER! Score: $($game.Score)" -ForegroundColor Red
            try { Show-GameCompanionComment "game_snake_over" } catch {}
            if ($isHigh) {
                Write-Host "  NEUER REKORD!" -ForegroundColor Yellow
                try { Show-GameCompanionComment "game_highscore" } catch {}
            }
        } else {
            Write-Host "`n  Abgebrochen. Score: $($game.Score)" -ForegroundColor DarkGray
        }
        Wait-Enter
    }
    
    Invoke-GameLoop -Init $init -Tick $tick -InputHandler $inputHandler -Cleanup $cleanup -FPS 8
}

} catch {
    Write-Host "[arcade-snake] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
