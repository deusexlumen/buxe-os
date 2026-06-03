# BUXE_OS v24.3 -- SNAKE (Frame-basiert)
# Pilot fuer das neue TUI-Framework.

try {

function snake {
    $score = 0; $maxScore = 10
    $px = 5; $py = 5
    $fx = Get-Random -Minimum 1 -Maximum 11
    $fy = Get-Random -Minimum 1 -Maximum 11
    $gridW = 12; $gridH = 12
    $frameW = $gridW * 2 + 4
    $frameH = $gridH + 4
    
    # Build scene once, update elements in tick
    $scene = New-Scene $frameW $frameH
    Add-SceneFrame $scene 0 0 $frameW $frameH "SNAKE" 'Green'
    Add-SceneText $scene 2 1 "Score: $score / $maxScore" 'Yellow'
    
    $init = {
        # Init done in outer scope
    }
    
    $inputHandler = {
        param($evt, $tick)
        switch ($evt.Key) {
            'W' { if ($py -gt 0) { $py-- } }
            'S' { if ($py -lt ($gridH - 1)) { $py++ } }
            'A' { if ($px -gt 0) { $px-- } }
            'D' { if ($px -lt ($gridW - 1)) { $px-- } }
            'UpArrow' { if ($py -gt 0) { $py-- } }
            'DownArrow' { if ($py -lt ($gridH - 1)) { $py++ } }
            'LeftArrow' { if ($px -gt 0) { $px-- } }
            'RightArrow' { if ($px -lt ($gridW - 1)) { $px-- } }
            'Escape' { return 'QUIT' }
        }
    }
    
    $tick = {
        param($tickCount)
        
        # Check food collision
        if ($px -eq $fx -and $py -eq $fy) {
            $score++
            $fx = Get-Random -Minimum 0 -Maximum $gridW
            $fy = Get-Random -Minimum 0 -Maximum $gridH
            if ($score -ge $maxScore) {
                return 'QUIT'
            }
        }
        
        # Rebuild scene
        $scene = New-Scene $frameW $frameH
        Add-SceneFrame $scene 0 0 $frameW $frameH "SNAKE" 'Green'
        Add-SceneText $scene 2 1 "Score: $score / $maxScore" 'Yellow'
        
        # Draw grid
        for ($y = 0; $y -lt $gridH; $y++) {
            $line = ""
            for ($x = 0; $x -lt $gridW; $x++) {
                if ($x -eq $px -and $y -eq $py) { $line += "O " }
                elseif ($x -eq $fx -and $y -eq $fy) { $line += "X " }
                else { $line += ". " }
            }
            Add-SceneText $scene 2 ($y + 2) $line 'DarkGray'
        }
        
        Show-Scene $scene
    }
    
    $cleanup = {
        if ($score -ge $maxScore) {
            Write-Host "`n  GEWONNEN! Score: $score" -ForegroundColor Green
            Load-State
            $stats = Get-ArcadeStats "Snake"
            if ($score -gt $stats.BestScore) { $stats.BestScore = $score; Set-ArcadeStats "Snake" $stats }
            Unlock-Achievement "Snake Charmer"
        } else {
            Write-Host "`n  Abgebrochen. Score: $score" -ForegroundColor DarkGray
        }
        Wait-Enter
    }
    
    Invoke-GameLoop -Init $init -Tick $tick -InputHandler $inputHandler -Cleanup $cleanup -FPS 8
}

} catch {
    Write-Host "[arcade-snake] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
