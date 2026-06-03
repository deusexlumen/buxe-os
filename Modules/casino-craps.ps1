# BUXE_OS v24.3 -- CRAPS (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function craps {
    Invoke-CasinoGame -GameName "CRAPS" -PlayRound {
        param($bet, $stats)
        
        Reset-RenderBuffer
        $w = 50; $h = 16
        
        # Pass/Don't Pass selection
        $s = New-Scene $w $h
        Add-SceneFrame $s 0 0 $w $h "CRAPS" 'Cyan' -Double
        Add-SceneText $s 4 2 "Bet: $bet G" 'DarkGray'
        Add-SceneText $s 4 4 "[P]ass Line     -> 7/11 gewinnt, 2/3/12 verliert" 'White'
        Add-SceneText $s 4 5 "[D]on't Pass    -> 2/3 gewinnt, 7/11 verliert, 12 Push" 'White'
        Add-SceneText $s 4 7 "[Q]uit" 'DarkGray'
        Show-Scene $s -Force
        
        $type = Read-GameChoice "" "^[PDQ]$"
        if ($type -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
        $pass = ($type -eq 'P')
        
        # First roll
        $dice = New-DiceRoll 2 6
        $sum = Get-DiceSum $dice
        
        $rs = New-Scene $w $h
        Add-SceneFrame $rs 0 0 $w $h "CRAPS" 'Cyan' -Double
        Add-SceneFrame $rs 8 3 8 5 "" 'White'
        Add-SceneText $rs 11 5 "$($dice[0])" 'Cyan'
        Add-SceneFrame $rs 20 3 8 5 "" 'White'
        Add-SceneText $rs 23 5 "$($dice[1])" 'Cyan'
        Add-SceneText $rs 32 5 "= $sum" 'Yellow'
        Add-SceneText $rs 4 9 "$(if ($pass) { 'Pass Line' } else { "Don't Pass" })" 'DarkGray'
        Show-Scene $rs -Force
        Start-Sleep -Milliseconds 600
        
        $won = $false; $lost = $false; $point = 0
        if ($pass) {
            if ($sum -in @(7,11)) { $won = $true }
            elseif ($sum -in @(2,3,12)) { $lost = $true }
            else { $point = $sum }
        } else {
            if ($sum -in @(2,3)) { $won = $true }
            elseif ($sum -eq 12) {
                Add-SceneText $rs 4 11 "Push bei 12!" 'Yellow'
                Show-Scene $rs -Force
                Start-Sleep -Milliseconds 600
                $stats.Rolls++
                return @{ Win = 0; Loss = 0; Stats = $stats }
            }
            elseif ($sum -in @(7,11)) { $lost = $true }
            else { $point = $sum }
        }
        
        # Point phase
        while ($point -gt 0 -and -not $won -and -not $lost) {
            $ps = New-Scene $w $h
            Add-SceneFrame $ps 0 0 $w $h "CRAPS" 'Cyan' -Double
            Add-SceneFrame $ps 8 3 8 5 "" 'White'
            Add-SceneText $ps 11 5 "$($dice[0])" 'DarkGray'
            Add-SceneFrame $ps 20 3 8 5 "" 'White'
            Add-SceneText $ps 23 5 "$($dice[1])" 'DarkGray'
            Add-SceneText $ps 32 5 "= $sum" 'DarkGray'
            Add-SceneText $ps 4 9 "Point: $point" 'Yellow'
            Add-SceneText $ps 4 11 "[R] Roll    [Q] Quit" 'White'
            Show-Scene $ps -Force
            
            $act = Read-GameChoice "" "^[RQ]$"
            if ($act -eq 'Q') { return @{ Win = 0; Loss = $bet; Stats = $stats } }
            
            $dice = New-DiceRoll 2 6
            $sum = Get-DiceSum $dice
            
            $rs = New-Scene $w $h
            Add-SceneFrame $rs 0 0 $w $h "CRAPS" 'Cyan' -Double
            Add-SceneFrame $rs 8 3 8 5 "" 'White'
            Add-SceneText $rs 11 5 "$($dice[0])" 'Cyan'
            Add-SceneFrame $rs 20 3 8 5 "" 'White'
            Add-SceneText $rs 23 5 "$($dice[1])" 'Cyan'
            Add-SceneText $rs 32 5 "= $sum" 'Yellow'
            Add-SceneText $rs 4 9 "Point: $point" 'DarkGray'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600
            
            if ($sum -eq $point) { $won = $true }
            elseif ($sum -eq 7) { $lost = $true }
        }
        
        $stats.Rolls++
        $fs = New-Scene $w $h
        Add-SceneFrame $fs 0 0 $w $h "CRAPS" 'Cyan' -Double
        Add-SceneFrame $fs 8 3 8 5 "" 'White'
        Add-SceneText $fs 11 5 "$($dice[0])" 'Cyan'
        Add-SceneFrame $fs 20 3 8 5 "" 'White'
        Add-SceneText $fs 23 5 "$($dice[1])" 'Cyan'
        Add-SceneText $fs 32 5 "= $sum" 'Yellow'
        
        if ($won) {
            $stats.Wins++; $stats.CurrentStreak++
            if ($stats.CurrentStreak -gt $stats.BestStreak) { $stats.BestStreak = $stats.CurrentStreak }
            Add-SceneText $fs 4 9 "GEWONNEN! $bet G!" 'Green'
            Show-Scene $fs -Force
            Start-Sleep -Milliseconds 600
            if ($stats.CurrentStreak -ge 3) {
                return @{ Win = $bet; Loss = 0; Stats = $stats; Achievement = "Craps Heater" }
            }
            return @{ Win = $bet; Loss = 0; Stats = $stats }
        } else {
            $stats.CurrentStreak = 0
            Add-SceneText $fs 4 9 "Verloren." 'Red'
            Show-Scene $fs -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
    }
}

} catch {
    Write-Host "[casino-craps] CRITICAL ERROR: $_" -ForegroundColor Red
}
