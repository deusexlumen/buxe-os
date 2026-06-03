# BUXE_OS v24.3 -- WORDLE (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-Host (Text-Input).

try {

function wordle {
    $words = @("POWER","SHELL","LINUX","CODER","AGENT","TERMINAL","SCRIPT","MODULE","KERNEL","DOCKER","KUBERNETES")
    $target = ($words | Get-Random).ToUpper()
    $attempts = 0; $maxAttempts = 6
    $history = @()
    
    Reset-RenderBuffer
    $w = 50; $h = 16 + $maxAttempts
    
    while ($attempts -lt $maxAttempts) {
        $s = New-Scene $w $h
        Add-SceneFrame $s 0 0 $w $h "WORDLE" 'Cyan' -Double
        Add-SceneText $s 4 2 "Errate das Wort in $maxAttempts Versuchen!" 'White'
        Add-SceneText $s 4 3 "Laenge: $($target.Length) Buchstaben" 'DarkGray'
        
        # Show previous guesses
        $y = 5
        foreach ($entry in $history) {
            Add-SceneText $s 4 $y $entry.Text $entry.Color
            $y++
        }
        
        Add-SceneText $s 4 ($y + 1) "Versuch $($attempts+1)/${maxAttempts}:" 'White'
        Show-Scene $s -Force
        
        [Console]::CursorVisible = $true
        $guess = (Read-Host "  ").ToUpper()
        [Console]::CursorVisible = $false
        
        if ($guess -eq 'Q') { return }
        if ($guess.Length -ne $target.Length) {
            $history += @{ Text = "Ungueltig! ($($target.Length) Buchstaben)"; Color = 'Red' }
            continue
        }
        
        $attempts++
        $resultText = ""
        $resultColor = "White"
        
        for ($i = 0; $i -lt $target.Length; $i++) {
            if ($i -lt $guess.Length -and $guess[$i] -eq $target[$i]) {
                $resultText += $guess[$i]
            } elseif ($target.Contains($guess[$i])) {
                $resultText += $guess[$i]
            } else {
                $resultText += $guess[$i]
            }
        }
        
        # Build colored result for history display (store as simple string since we can't do per-char colors easily in SceneText)
        # Instead, we'll show the guess and a separate indicator line
        $indicator = ""
        for ($i = 0; $i -lt $target.Length; $i++) {
            if ($i -lt $guess.Length -and $guess[$i] -eq $target[$i]) {
                $indicator += "+"  # Correct position
            } elseif ($target.Contains($guess[$i])) {
                $indicator += "~"  # Wrong position
            } else {
                $indicator += "-"  # Not in word
            }
        }
        
        $history += @{ Text = "$guess  $indicator"; Color = 'White' }
        
        if ($guess -eq $target) {
            $rs = New-Scene $w $h
            Add-SceneFrame $rs 0 0 $w $h "WORDLE" 'Cyan' -Double
            Add-SceneText $rs 4 2 "RICHTIG!" 'Green'
            Add-SceneText $rs 4 3 "'$target' in $attempts Versuchen!" 'Green'
            $y = 5
            foreach ($entry in $history) {
                Add-SceneText $rs 4 $y $entry.Text $entry.Color
                $y++
            }
            Show-Scene $rs -Force
            
            Load-State
            $stats = Get-ArcadeStats "Wordle"
            $stats.Played++; $stats.Streak++
            if ($stats.Streak -gt $stats.BestStreak) { $stats.BestStreak = $stats.Streak }
            Set-ArcadeStats "Wordle" $stats
            if ($attempts -le 3) { Unlock-Achievement "Wordle Master" }
            Wait-Enter; return
        }
    }
    
    # Game over
    $gs = New-Scene $w $h
    Add-SceneFrame $gs 0 0 $w $h "WORDLE" 'Cyan' -Double
    Add-SceneText $gs 4 2 "Game Over!" 'Red'
    Add-SceneText $gs 4 3 "Das Wort war: $target" 'Yellow'
    $y = 5
    foreach ($entry in $history) {
        Add-SceneText $gs 4 $y $entry.Text $entry.Color
        $y++
    }
    Show-Scene $gs -Force
    
    Load-State
    $stats = Get-ArcadeStats "Wordle"
    $stats.Played++; $stats.Streak = 0
    Set-ArcadeStats "Wordle" $stats
    Wait-Enter
}

} catch {
    Write-Host "[arcade-wordle] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
