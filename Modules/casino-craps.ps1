# BUXE_OS v24.3 -- CRAPS (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.
# Erweitert: Come, Don't Come, Odds, Place Bet, Field.

try {

function craps {
    Invoke-CasinoGame -GameName "CRAPS" -PlayRound {
        param($bet, $stats)

        Reset-RenderBuffer
        $w = 52; $h = 18

        $s = New-Scene $w $h
        Add-SceneFrame $s 0 0 $w $h "CRAPS" 'Cyan' -Double
        Add-SceneText $s 4 2 "Bet: $bet G" 'DarkGray'
        Add-SceneText $s 4 4 "[1] Pass Line     -> 7/11 gewinnt, 2/3/12 verliert" 'White'
        Add-SceneText $s 4 5 "[2] Don't Pass    -> 2/3 gewinnt, 7/11 verliert, 12 Push" 'White'
        Add-SceneText $s 4 6 "[3] Come          -> Wie Pass, nach Come-out" 'White'
        Add-SceneText $s 4 7 "[4] Don't Come    -> Wie Don't Pass, nach Come-out" 'White'
        Add-SceneText $s 4 8 "[5] Odds          -> True Odds hinter Pass/Come" 'White'
        Add-SceneText $s 4 9 "[6] Place Bet     -> Auf Zahl setzen (4,5,6,8,9,10)" 'White'
        Add-SceneText $s 4 10 "[7] Field         -> Ein-Wurf (2,3,4,9,10,11,12)" 'White'
        Add-SceneText $s 4 12 "[Q]uit" 'DarkGray'
        Show-Scene $s -Force

        $type = Read-GameChoice "" "^[1234567PDCNOFAQ]$"
        if ($type -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }

        $typeMap = @{ 'P' = '1'; 'D' = '2'; 'C' = '3'; 'N' = '4'; 'O' = '5'; 'A' = '6'; 'F' = '7' }
        if ($typeMap[$type]) { $type = $typeMap[$type] }

        $won = $false; $lost = $false; $push = $false
        $point = 0
        $winAmount = 0
        $dice = @(0,0)
        $sum = 0

        if ($type -in @("1","2","3","4")) {
            $dice = New-DiceRoll 2 6
            $sum = Get-DiceSum $dice

            $rs = New-Scene $w $h
            Add-SceneFrame $rs 0 0 $w $h "CRAPS" 'Cyan' -Double
            Add-SceneFrame $rs 8 3 8 5 "" 'White'
            Add-SceneText $rs 11 5 "$($dice[0])" 'Cyan'
            Add-SceneFrame $rs 20 3 8 5 "" 'White'
            Add-SceneText $rs 23 5 "$($dice[1])" 'Cyan'
            Add-SceneText $rs 32 5 "= $sum" 'Yellow'
            Add-SceneText $rs 4 9 $(switch ($type) { "1" { "Pass Line" } "2" { "Don't Pass" } "3" { "Come" } "4" { "Don't Come" } }) 'DarkGray'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600

            switch ($type) {
                "1" {
                    if ($sum -in @(7,11)) { $won = $true }
                    elseif ($sum -in @(2,3,12)) { $lost = $true }
                    else { $point = $sum }
                }
                "2" {
                    if ($sum -in @(2,3)) { $won = $true }
                    elseif ($sum -eq 12) { $push = $true }
                    elseif ($sum -in @(7,11)) { $lost = $true }
                    else { $point = $sum }
                }
                "3" {
                    if ($sum -in @(7,11)) { $won = $true }
                    elseif ($sum -in @(2,3)) { $lost = $true }
                    elseif ($sum -eq 12) { $push = $true }
                    else { $point = $sum }
                }
                "4" {
                    if ($sum -in @(2,3)) { $won = $true }
                    elseif ($sum -eq 12) { $push = $true }
                    elseif ($sum -in @(7,11)) { $lost = $true }
                    else { $point = $sum }
                }
            }
        }
        elseif ($type -eq "5") {
            $os = New-Scene $w $h
            Add-SceneFrame $os 0 0 $w $h "CRAPS" 'Cyan' -Double
            Add-SceneText $os 4 2 "Odds Bet: $bet G" 'DarkGray'
            Add-SceneText $os 4 4 "Point waehlen (4,5,6,8,9,10):" 'White'
            Show-Scene $os -Force
            try { [Console]::CursorVisible = $true } catch {}
            $inputStr = Read-GameInput "  "
            try { [Console]::CursorVisible = $false } catch {}
            $point = 0
            if (-not [int]::TryParse($inputStr, [ref]$point) -or $point -notin @(4,5,6,8,9,10)) {
                Add-SceneText $os 4 6 "Ungueltige Zahl! Rueckgabe des Einsatzes." 'Red'
                Show-Scene $os -Force
                Start-Sleep -Milliseconds 800
                return @{ Win = 0; Loss = 0; Stats = $stats }
            }
        }
        elseif ($type -eq "6") {
            $os = New-Scene $w $h
            Add-SceneFrame $os 0 0 $w $h "CRAPS" 'Cyan' -Double
            Add-SceneText $os 4 2 "Place Bet: $bet G" 'DarkGray'
            Add-SceneText $os 4 4 "Zahl waehlen (4,5,6,8,9,10):" 'White'
            Show-Scene $os -Force
            try { [Console]::CursorVisible = $true } catch {}
            $inputStr = Read-GameInput "  "
            try { [Console]::CursorVisible = $false } catch {}
            $point = 0
            if (-not [int]::TryParse($inputStr, [ref]$point) -or $point -notin @(4,5,6,8,9,10)) {
                Add-SceneText $os 4 6 "Ungueltige Zahl! Rueckgabe des Einsatzes." 'Red'
                Show-Scene $os -Force
                Start-Sleep -Milliseconds 800
                return @{ Win = 0; Loss = 0; Stats = $stats }
            }
        }
        elseif ($type -eq "7") {
            $dice = New-DiceRoll 2 6
            $sum = Get-DiceSum $dice

            $rs = New-Scene $w $h
            Add-SceneFrame $rs 0 0 $w $h "CRAPS" 'Cyan' -Double
            Add-SceneFrame $rs 8 3 8 5 "" 'White'
            Add-SceneText $rs 11 5 "$($dice[0])" 'Cyan'
            Add-SceneFrame $rs 20 3 8 5 "" 'White'
            Add-SceneText $rs 23 5 "$($dice[1])" 'Cyan'
            Add-SceneText $rs 32 5 "= $sum" 'Yellow'
            Add-SceneText $rs 4 9 "Field Bet" 'DarkGray'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600

            if ($sum -in @(2,12)) {
                $won = $true
                $winAmount = $bet * 2
            }
            elseif ($sum -in @(3,4,9,10,11)) {
                $won = $true
                $winAmount = $bet
            }
            else {
                $lost = $true
            }
        }

        if ($push) {
            $stats.Rolls++
            $ps = New-Scene $w $h
            Add-SceneFrame $ps 0 0 $w $h "CRAPS" 'Cyan' -Double
            Add-SceneFrame $ps 8 3 8 5 "" 'White'
            Add-SceneText $ps 11 5 "$($dice[0])" 'Cyan'
            Add-SceneFrame $ps 20 3 8 5 "" 'White'
            Add-SceneText $ps 23 5 "$($dice[1])" 'Cyan'
            Add-SceneText $ps 32 5 "= $sum" 'Yellow'
            Add-SceneText $ps 4 9 "Push bei 12!" 'Yellow'
            Show-Scene $ps -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = 0; Loss = 0; Stats = $stats }
        }

        # Point phase
        while ($point -gt 0 -and -not $won -and -not $lost) {
            $ps = New-Scene $w $h
            Add-SceneFrame $ps 0 0 $w $h "CRAPS" 'Cyan' -Double
            if ($dice[0] -gt 0) {
                Add-SceneFrame $ps 8 3 8 5 "" 'White'
                Add-SceneText $ps 11 5 "$($dice[0])" 'DarkGray'
                Add-SceneFrame $ps 20 3 8 5 "" 'White'
                Add-SceneText $ps 23 5 "$($dice[1])" 'DarkGray'
                Add-SceneText $ps 32 5 "= $sum" 'DarkGray'
            }
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

            if ($type -in @("2","4")) {
                if ($sum -eq $point) { $lost = $true }
                elseif ($sum -eq 7) { $won = $true }
            } else {
                if ($sum -eq $point) { $won = $true }
                elseif ($sum -eq 7) { $lost = $true }
            }
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
            switch ($type) {
                "1" { $winAmount = $bet }
                "2" { $winAmount = $bet }
                "3" { $winAmount = $bet }
                "4" { $winAmount = $bet }
                "5" {
                    switch ($point) {
                        { $_ -in @(4,10) } { $winAmount = [math]::Floor($bet * 2) }
                        { $_ -in @(5,9) } { $winAmount = [math]::Floor($bet * 3 / 2) }
                        { $_ -in @(6,8) } { $winAmount = [math]::Floor($bet * 6 / 5) }
                    }
                }
                "6" {
                    switch ($point) {
                        { $_ -in @(4,10) } { $winAmount = [math]::Floor($bet * 9 / 5) }
                        { $_ -in @(5,9) } { $winAmount = [math]::Floor($bet * 7 / 5) }
                        { $_ -in @(6,8) } { $winAmount = [math]::Floor($bet * 7 / 6) }
                    }
                }
            }
            $stats.Wins++; $stats.CurrentStreak++
            if ($stats.CurrentStreak -gt $stats.BestStreak) { $stats.BestStreak = $stats.CurrentStreak }
            Add-SceneText $fs 4 9 "GEWONNEN! $winAmount G!" 'Green'
            Show-Scene $fs -Force
            Start-Sleep -Milliseconds 600
            if ($stats.CurrentStreak -ge 3) {
                return @{ Win = $winAmount; Loss = 0; Stats = $stats; Achievement = "Craps Heater" }
            }
            return @{ Win = $winAmount; Loss = 0; Stats = $stats }
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
