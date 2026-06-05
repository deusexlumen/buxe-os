# BUXE_OS v24.3 -- ROULETTE (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.
# Erweitert: Column, Corner, Six-Line.

try {

function roulette {
    Invoke-CasinoGame -GameName "EUROPEAN ROULETTE" -PlayRound {
        param($bet, $stats)
        $wheel = @(0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26)
        $redNums = @(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36)
        $col1 = @(1,4,7,10,13,16,19,22,25,28,31,34)
        $col2 = @(2,5,8,11,14,17,20,23,26,29,32,35)
        $col3 = @(3,6,9,12,15,18,21,24,27,30,33,36)

        Reset-RenderBuffer
        $w = 60; $h = 18

        $sel = New-Scene $w $h
        Add-SceneFrame $sel 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
        Add-SceneText $sel 4 2 "Bet: $bet G" 'DarkGray'
        Add-SceneText $sel 4 4 "[1] Straight        (36x)" 'White'
        Add-SceneText $sel 4 5 "[2] Split           (18x)" 'White'
        Add-SceneText $sel 4 6 "[3] Rot/Schwarz     (2x)" 'White'
        Add-SceneText $sel 4 7 "[4] Dutzend         (3x)" 'White'
        Add-SceneText $sel 4 8 "[5] Gerade/Ungerade (2x)" 'White'
        Add-SceneText $sel 4 9 "[6] Column          (3x)" 'White'
        Add-SceneText $sel 4 10 "[7] Corner          (9x)" 'White'
        Add-SceneText $sel 4 11 "[8] Six-Line        (6x)" 'White'
        Add-SceneText $sel 4 13 "[Q] Quit" 'DarkGray'
        Show-Scene $sel -Force

        $choice = Read-GameChoice "" "^[12345678Q]$"
        if ($choice -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }

        $payout = 2
        $won = $false
        $numBet = 0
        $numBet2 = 0
        $strBet = 0
        $dzBet = 0
        $colorBet = ""
        $eoBet = ""
        $cornerNums = @()
        $sixLineNums = @()

        switch ($choice) {
            "1" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Zahl (0-36):" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $inputStr = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($inputStr -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                try { $numBet = [int]$inputStr } catch { $numBet = -1 }
                $payout = 36
            }
            "2" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Erste Zahl (0-36):" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $inputStr = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($inputStr -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                try { $numBet = [int]$inputStr } catch { $numBet = -1 }
                $sub2 = New-Scene $w $h
                Add-SceneFrame $sub2 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub2 4 2 "Zweite Zahl (0-36):" 'White'
                Show-Scene $sub2 -Force
                try { [Console]::CursorVisible = $true } catch {}
                $inputStr2 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($inputStr2 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                try { $numBet2 = [int]$inputStr2 } catch { $numBet2 = -1 }
                $diff = [math]::Abs($numBet - $numBet2)
                $validSplit = ($numBet -ge 0 -and $numBet -le 36 -and $numBet2 -ge 0 -and $numBet2 -le 36 -and $numBet -ne $numBet2 -and ($diff -eq 1 -or $diff -eq 3))
                if (-not $validSplit) {
                    Add-SceneText $sub2 4 4 "Ungueltiger Split! Rueckgabe." 'Red'
                    Show-Scene $sub2 -Force
                    Start-Sleep -Milliseconds 800
                    return @{ Win = 0; Loss = 0; Stats = $stats }
                }
                $payout = 18
            }
            "3" {
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
            "6" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Column:" 'White'
                Add-SceneText $sub 4 4 "[1] 1,4,7,10,13,16,19,22,25,28,31,34" 'White'
                Add-SceneText $sub 4 5 "[2] 2,5,8,11,14,17,20,23,26,29,32,35" 'White'
                Add-SceneText $sub 4 6 "[3] 3,6,9,12,15,18,21,24,27,30,33,36" 'White'
                Add-SceneText $sub 4 8 "[Q] Zurueck" 'DarkGray'
                Show-Scene $sub -Force
                $cb = Read-GameChoice "" "^[123Q]$"
                if ($cb -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                $colBet = [int]$cb
                $payout = 3
            }
            "7" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Corner: 4 Zahlen als Quadrat eingeben:" 'White'
                Add-SceneText $sub 4 4 "Zahl 1:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $c1 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($c1 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 5 "Zahl 2:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $c2 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($c2 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 6 "Zahl 3:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $c3 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($c3 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 7 "Zahl 4:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $c4 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($c4 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                try {
                    $cornerNums = @([int]$c1, [int]$c2, [int]$c3, [int]$c4)
                } catch {
                    $cornerNums = @()
                }
                $sorted = @($cornerNums | Sort-Object)
                $n = $sorted[0]
                $validCorner = ($sorted.Count -eq 4 -and $sorted[1] -eq $n+1 -and $sorted[2] -eq $n+3 -and $sorted[3] -eq $n+4 -and ($n % 3) -ne 0 -and $n -le 32 -and $sorted | Where-Object { $_ -lt 1 -or $_ -gt 36 } | Measure-Object).Count -eq 0
                if (-not $validCorner) {
                    Add-SceneText $sub 4 9 "Ungueltiges Corner! Rueckgabe." 'Red'
                    Show-Scene $sub -Force
                    Start-Sleep -Milliseconds 800
                    return @{ Win = 0; Loss = 0; Stats = $stats }
                }
                $payout = 9
            }
            "8" {
                $sub = New-Scene $w $h
                Add-SceneFrame $sub 0 0 $w $h "EUROPEAN ROULETTE" 'Cyan' -Double
                Add-SceneText $sub 4 2 "Six-Line: 6 Zahlen (2 benachbarte Reihen):" 'White'
                Add-SceneText $sub 4 4 "Zahl 1:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $n1 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($n1 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 5 "Zahl 2:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $n2 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($n2 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 6 "Zahl 3:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $n3 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($n3 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 7 "Zahl 4:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $n4 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($n4 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 8 "Zahl 5:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $n5 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($n5 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                Add-SceneText $sub 4 9 "Zahl 6:" 'White'
                Show-Scene $sub -Force
                try { [Console]::CursorVisible = $true } catch {}
                $n6 = Read-GameInput "  "
                try { [Console]::CursorVisible = $false } catch {}
                if ($n6 -match '^[Qq]$') { return @{ Win = 0; Loss = 0; Stats = $stats } }
                try {
                    $sixLineNums = @([int]$n1, [int]$n2, [int]$n3, [int]$n4, [int]$n5, [int]$n6)
                } catch {
                    $sixLineNums = @()
                }
                $sorted = @($sixLineNums | Sort-Object)
                $n = $sorted[0]
                $validSix = ($sorted.Count -eq 6 -and $sorted[1] -eq $n+1 -and $sorted[2] -eq $n+2 -and $sorted[3] -eq $n+3 -and $sorted[4] -eq $n+4 -and $sorted[5] -eq $n+5 -and ($n % 3) -eq 1 -and $n -ge 1 -and ($sorted | Where-Object { $_ -lt 1 -or $_ -gt 36 } | Measure-Object).Count -eq 0)
                if (-not $validSix) {
                    Add-SceneText $sub 4 11 "Ungueltige Six-Line! Rueckgabe." 'Red'
                    Show-Scene $sub -Force
                    Start-Sleep -Milliseconds 800
                    return @{ Win = 0; Loss = 0; Stats = $stats }
                }
                $payout = 6
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

        switch ($choice) {
            "1" { if ($result -eq $numBet) { $won = $true } }
            "2" { if ($result -eq $numBet -or $result -eq $numBet2) { $won = $true } }
            "3" { $isRed = $result -in $redNums; if (($colorBet -eq "Rot" -and $isRed) -or ($colorBet -eq "Schwarz" -and -not $isRed -and $result -ne 0)) { $won = $true } }
            "4" { $dz = if ($result -le 12) { 1 } elseif ($result -le 24) { 2 } else { 3 }; if ($dz -eq $dzBet -and $result -ne 0) { $won = $true } }
            "5" { if ($result -ne 0 -and (($eoBet -eq "Gerade" -and $result % 2 -eq 0) -or ($eoBet -eq "Ungerade" -and $result % 2 -eq 1))) { $won = $true } }
            "6" {
                $inCol = switch ($colBet) {
                    1 { $result -in $col1 }
                    2 { $result -in $col2 }
                    3 { $result -in $col3 }
                }
                if ($inCol -and $result -ne 0) { $won = $true }
            }
            "7" { if ($result -in $cornerNums -and $result -ne 0) { $won = $true } }
            "8" { if ($result -in $sixLineNums -and $result -ne 0) { $won = $true } }
        }

        $stats.Spins++
        $stats.History += $result
        if ($stats.History.Count -gt 10) { $stats.History = @($stats.History | Select-Object -Skip 1) }

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
