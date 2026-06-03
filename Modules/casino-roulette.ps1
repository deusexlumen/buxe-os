# BUXE_OS v24.3 -- ROULETTE (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function roulette {
    Invoke-CasinoGame -GameName "EUROPEAN ROULETTE" -PlayRound {
        param($bet, $stats)
        $wheel = @(0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26)
        $redNums = @(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36)
        
        Reset-RenderBuffer
        $w = 56; $h = 16
        
        # Bet type selection
        $sel = New-Scene $w $h
        Add-SceneFrame $sel 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
        Add-SceneText $sel 4 2 "Bet: $bet G" 'DarkGray'
        Add-SceneText $sel 4 4 "[1] Rot/Schwarz     (2x)" 'White'
        Add-SceneText $sel 4 5 "[2] Gerade/Ungerade (2x)" 'White'
        Add-SceneText $sel 4 6 "[3] Zahl            (36x)" 'White'
        Add-SceneText $sel 4 7 "[4] Dutzend         (3x)" 'White'
        Add-SceneText $sel 4 8 "[5] Street          (12x)" 'White'
        Add-SceneText $sel 4 10 "[Q] Quit" 'DarkGray'
        Show-Scene $sel -Force
        
        $choice = Read-GameChoice "" "^[12345Q]$"
        if ($choice -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
        
        $payout = 2
        $won = $false
        
        # Sub-menu for bet specifics
        switch ($choice) {
            "1" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Farbe waehlen:" 'White'
                Add-SceneText $sub 4 4 "[R]ot" 'Red'
                Add-SceneText $sub 4 5 "[S]chwarz" 'White'
                Add-SceneText $sub 4 7 "[Q] Zurueck" 'DarkGray'
                Show-Scene $sub -Force
                $cb = Read-GameChoice "" "^[RSQ]$"
                if ($cb -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                $colorBet = if ($cb -eq 'R') { "Rot" } else { "Schwarz" }
                $payout = 2
            }
            "2" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Gerade/Ungerade:" 'White'
                Add-SceneText $sub 4 4 "[G]erade" 'Cyan'
                Add-SceneText $sub 4 5 "[U]ngerade" 'Yellow'
                Add-SceneText $sub 4 7 "[Q] Zurueck" 'DarkGray'
                Show-Scene $sub -Force
                $eb = Read-GameChoice "" "^[GUQ]$"
                if ($eb -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                $eoBet = if ($eb -eq 'G') { "Gerade" } else { "Ungerade" }
                $payout = 2
            }
            "3" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Zahl (0-36):" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $numBet = [int](Read-Host "  ")
                try { [Console]::CursorVisible = $false } catch {}
                $payout = 36
            }
            "4" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Dutzend:" 'White'
                Add-SceneText $sub 4 4 "[1] 1-12" 'White'
                Add-SceneText $sub 4 5 "[2] 13-24" 'White'
                Add-SceneText $sub 4 6 "[3] 25-36" 'White'
                Add-SceneText $sub 4 8 "[Q] Zurueck" 'DarkGray'
                Show-Scene $sub -Force
                $db = Read-GameChoice "" "^[123Q]$"
                if ($db -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                $dzBet = [int]$db
                $payout = 3
            }
            "5" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Street Startzahl (1,4,7,10,13,16,19,22,25,28,31,34):" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $strBet = [int](Read-Host "  ")
                try { [Console]::CursorVisible = $false } catch {}
                $payout = 12
            }
        }
        
        # Spin animation
        for ($s = 0; $s -lt 15; $s++) {
            $temp = $wheel | Get-Random
            $tCol = if ($temp -eq 0) { 'Green' } elseif ($temp -in $redNums) { 'Red' } else { 'White' }
            $spin = New-Scene $w $h
            Add-SceneFrame $spin 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
            Add-SceneText $spin 4 2 "Spinning..." 'Magenta'
            Add-SceneFrame $spin 22 5 10 5 "" $tCol
            Add-SceneText $spin 26 7 "$temp" $tCol
            Show-Scene $spin -Force
            Start-Sleep -Milliseconds (50 + ($s * 20))
        }
        
        $result = $wheel | Get-Random
        $rCol = if ($result -eq 0) { 'Green' } elseif ($result -in $redNums) { 'Red' } else { 'White' }
        
        # Result evaluation
        switch ($choice) {
            "1" { $isRed = $result -in $redNums; if (($colorBet -eq "Rot" -and $isRed) -or ($colorBet -eq "Schwarz" -and -not $isRed -and $result -ne 0)) { $won = $true } }
            "2" { if ($result -ne 0 -and (($eoBet -eq "Gerade" -and $result % 2 -eq 0) -or ($eoBet -eq "Ungerade" -and $result % 2 -eq 1))) { $won = $true } }
            "3" { if ($result -eq $numBet) { $won = $true } }
            "4" { $dz = if ($result -le 12) { 1 } elseif ($result -le 24) { 2 } else { 3 }; if ($dz -eq $dzBet -and $result -ne 0) { $won = $true } }
            "5" { if ($result -ne 0 -and $result -ge $strBet -and $result -lt $strBet + 3) { $won = $true } }
        }
        
        $stats.Spins++
        $stats.History += $result
        if ($stats.History.Count -gt 10) { $stats.History = @($stats.History | Select-Object -Skip 1) }
        
        # Final result scene
        $fs = New-Scene $w $h
        Add-SceneFrame $fs 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
        Add-SceneFrame $fs 22 5 10 5 "" $rCol
        Add-SceneText $fs 26 7 "$result" $rCol
        
        if ($won) {
            $winAmount = $bet * ($payout - 1)
            if ($winAmount -gt $stats.BiggestWin) { $stats.BiggestWin = $winAmount }
            Add-SceneText $fs 4 11 "GEWONNEN! $winAmount G (${payout}x)" 'Green'
            Show-Scene $fs -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = $winAmount; Loss = 0; Stats = $stats; Achievement = "Roulette Winner" }
        } else {
            Add-SceneText $fs 4 11 "Verloren." 'Red'
            Show-Scene $fs -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
    }
}

} catch {
    Write-Host "[casino-roulette] CRITICAL ERROR: $_" -ForegroundColor Red
}
