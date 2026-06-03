# BUXE_OS v24.3 -- MINESWEEPER (TUI)
# 10x10 Grid, 10 Minen. WASD + E/F/Q.

try {

function minesweeper {
    # Init grid
    $grid = @(); $counts = @()
    for ($y = 0; $y -lt 10; $y++) {
        $r = @(); $c = @()
        for ($x = 0; $x -lt 10; $x++) { $r += @{ Mine = $false; Revealed = $false; Flagged = $false }; $c += 0 }
        $grid += ,$r; $counts += ,$c
    }
    # Place mines
    $m = 0; while ($m -lt 10) {
        $x = Get-Random -Maximum 10; $y = Get-Random -Maximum 10
        if (-not $grid[$y][$x].Mine) { $grid[$y][$x].Mine = $true; $m++ }
    }
    # Precompute counts
    for ($y = 0; $y -lt 10; $y++) {
        for ($x = 0; $x -lt 10; $x++) {
            if ($grid[$y][$x].Mine) { continue }
            $cnt = 0
            for ($dy = -1; $dy -le 1; $dy++) {
                for ($dx = -1; $dx -le 1; $dx++) {
                    $nx = $x + $dx; $ny = $y + $dy
                    if ($nx -ge 0 -and $nx -lt 10 -and $ny -ge 0 -and $ny -lt 10 -and $grid[$ny][$nx].Mine) { $cnt++ }
                }
            }
            $counts[$y][$x] = $cnt
        }
    }
    
    $cx = 0; $cy = 0; $flags = 0; $state = "PLAY"
    $start = Get-Date
    Reset-RenderBuffer
    
    # Flood-fill helper
    function Flood-Reveal($fx, $fy) {
        $q = @(@($fx, $fy))
        $i = 0
        while ($i -lt $q.Count) {
            $x = $q[$i][0]; $y = $q[$i][1]; $i++
            if ($x -lt 0 -or $x -ge 10 -or $y -lt 0 -or $y -ge 10) { continue }
            $c = $grid[$y][$x]
            if ($c.Revealed -or $c.Flagged) { continue }
            $c.Revealed = $true
            if ($counts[$y][$x] -eq 0) {
                for ($dy = -1; $dy -le 1; $dy++) {
                    for ($dx = -1; $dx -le 1; $dx++) {
                        $q += ,@(($x + $dx), ($y + $dy))
                    }
                }
            }
        }
    }
    
    while ($state -eq "PLAY") {
        $s = New-Scene 46 18
        Add-SceneFrame $s 0 0 46 18 "MINESWEEPER" 'Cyan' -Double
        $elapsed = [math]::Floor(((Get-Date) - $start).TotalSeconds)
        Add-SceneText $s 4 2 "Cursor: ($cx,$cy)  Flags: $flags/10  Time: ${elapsed}s" 'Yellow'
        Add-SceneText $s 4 3 "  0 1 2 3 4 5 6 7 8 9" 'DarkGray'
        
        for ($y = 0; $y -lt 10; $y++) {
            $prefix = if ($y -eq $cy) { ">" } else { " " }
            $line = "$prefix "
            for ($x = 0; $x -lt 10; $x++) {
                $c = $grid[$y][$x]
                $ch = if ($c.Flagged) { "F" } elseif (-not $c.Revealed) { "#" } elseif ($c.Mine) { "*" } elseif ($counts[$y][$x] -eq 0) { "." } else { $counts[$y][$x].ToString() }
                $line += "$ch "
            }
            Add-SceneText $s 4 (4 + $y) $line 'White'
        }
        
        Add-SceneText $s 4 15 "[WASD] Move  [E] Reveal  [F] Flag  [Q] Quit" 'DarkGray'
        Show-Scene $s -Force
        
        $act = Read-GameChoice "" "^[WASDEFQ]$"
        switch ($act) {
            'W' { if ($cy -gt 0) { $cy-- } }
            'A' { if ($cx -gt 0) { $cx-- } }
            'S' { if ($cy -lt 9) { $cy++ } }
            'D' { if ($cx -lt 9) { $cx++ } }
            'E' {
                $c = $grid[$cy][$cx]
                if (-not $c.Revealed -and -not $c.Flagged) {
                    if ($c.Mine) { $state = "LOSE" }
                    else { Flood-Reveal $cx $cy }
                }
            }
            'F' {
                $c = $grid[$cy][$cx]
                if (-not $c.Revealed) {
                    $c.Flagged = -not $c.Flagged
                    $flags = if ($c.Flagged) { $flags + 1 } else { $flags - 1 }
                }
            }
            'Q' { return }
        }
        
        # Check win
        $rev = 0
        for ($y = 0; $y -lt 10; $y++) { for ($x = 0; $x -lt 10; $x++) { if ($grid[$y][$x].Revealed) { $rev++ } } }
        if ($rev -eq 90) { $state = "WIN" }
    }
    
    # Result screen
    $rs = New-Scene 46 18
    Add-SceneFrame $rs 0 0 46 18 "MINESWEEPER" 'Cyan' -Double
    if ($state -eq "WIN") {
        Add-SceneText $rs 4 5 "GEWONNEN! Alle Minen entschaerft." 'Green'
        Add-SceneText $rs 4 6 "Zeit: $elapsed Sekunden" 'Yellow'
        Load-State; $stats = Get-ArcadeStats "Minesweeper"; $stats.Won++; Set-ArcadeStats "Minesweeper" $stats
        if ($elapsed -lt 60) { Unlock-Achievement "Minesweeper Speedrun" }
    } else {
        Add-SceneText $rs 4 5 "BOOM! Mine getroffen." 'Red'
        Load-State; $stats = Get-ArcadeStats "Minesweeper"; $stats.Lost++; Set-ArcadeStats "Minesweeper" $stats
    }
    Show-Scene $rs -Force
    Start-Sleep -Milliseconds 1500
}

} catch {
    Write-Host "[arcade-minesweeper] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
