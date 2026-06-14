# BUXE_OS v24.3 -- SLOTS (TUI)
# Migriert auf TUI-Framework: Show-Scene + animierte Reels.
# Erweitert: Wild, Scatter/Free Spins, Bonus-Game, Progressive Jackpot.

try {

$script:SlotJackpotBase = 500
$script:SlotSymbolPools = @{}

function Get-SlotSymbolWeighted($luckLevel) {
    $symbols = @("7","BAR","CHERRY","LEMON","DIAMOND","BELL","HORSESHOE","W","S","B")
    if ($luckLevel -le 0) { return $symbols | Get-Random }
    $weights = @{
        "7" = 2; "BAR" = 3; "DIAMOND" = 4; "BELL" = 5
        "HORSESHOE" = 6; "CHERRY" = 8; "LEMON" = 10
        "W" = 5; "S" = 8; "B" = 6
    }
    # Static pool cache per luck level to reduce memory pressure
    $pool = $script:SlotSymbolPools[$luckLevel]
    if (-not $pool) {
        $pool = @()
        foreach ($sym in $symbols) {
            $w = $weights[$sym] - $luckLevel
            if ($w -lt 1) { $w = 1 }
            for ($i = 0; $i -lt $w; $i++) { $pool += $sym }
        }
        $script:SlotSymbolPools[$luckLevel] = $pool
    }
    return $pool | Get-Random
}

function Invoke-FisherYatesShuffle($Array) {
    $rng = [System.Random]::new()
    for ($i = $Array.Count - 1; $i -gt 0; $i--) {
        $j = $rng.Next($i + 1)
        $tmp = $Array[$i]
        $Array[$i] = $Array[$j]
        $Array[$j] = $tmp
    }
    return $Array
}

function Get-SlotLineWin($reels, $bet, $payouts) {
    $s1 = $reels[0]; $s2 = $reels[1]; $s3 = $reels[2]
    $scatterCount = ($reels | Where-Object { $_ -eq "S" }).Count
    $bonusCount = ($reels | Where-Object { $_ -eq "B" }).Count
    $wildCount = ($reels | Where-Object { $_ -eq "W" }).Count

    $lineReels = @()
    foreach ($r in $reels) {
        if ($r -eq "S" -or $r -eq "B") { $lineReels += $null }
        else { $lineReels += $r }
    }

    $win = 0
    $matchType = ""
    $nonNullLine = $lineReels | Where-Object { $_ -ne $null }

    if ($nonNullLine.Count -eq 3) {
        $hasWild = ($nonNullLine | Where-Object { $_ -eq "W" }).Count
        $uniqueBase = @($nonNullLine | Where-Object { $_ -ne "W" } | Select-Object -Unique)

        if ($hasWild -eq 3) {
            $win = $bet * $payouts["7"]
            $matchType = "DREI WILD!"
        } elseif ($hasWild -eq 2) {
            $sym = $uniqueBase[0]
            $win = $bet * $payouts[$sym]
            $matchType = "DREI $sym!"
        } elseif ($hasWild -eq 1) {
            if ($uniqueBase.Count -eq 1) {
                $sym = $uniqueBase[0]
                $win = $bet * $payouts[$sym]
                $matchType = "DREI $sym!"
            } else {
                $bestSym = $uniqueBase | Sort-Object { $payouts[$_] } -Descending | Select-Object -First 1
                $multiplier = [math]::Max(2, [math]::Floor($payouts[$bestSym] / 3))
                $win = $bet * $multiplier
                $matchType = "MATCH! Zwei $bestSym!"
            }
        } else {
            if ($s1 -eq $s2 -and $s2 -eq $s3) {
                $win = $bet * $payouts[$s1]
                $matchType = "DREI $s1!"
            } elseif ($s1 -eq $s2 -or $s2 -eq $s3 -or $s1 -eq $s3) {
                $match = if ($s1 -eq $s2) { $s1 } elseif ($s2 -eq $s3) { $s2 } else { $s1 }
                $multiplier = [math]::Max(2, [math]::Floor($payouts[$match] / 3))
                $win = $bet * $multiplier
                $matchType = "MATCH! Zwei $match!"
            }
        }
    } elseif ($nonNullLine.Count -eq 2) {
        if ($nonNullLine[0] -eq $nonNullLine[1]) {
            $sym = $nonNullLine[0]
            if ($sym -eq "W") {
                $multiplier = [math]::Max(2, [math]::Floor($payouts["7"] / 3))
                $matchType = "MATCH! Zwei 7!"
            } else {
                $multiplier = [math]::Max(2, [math]::Floor($payouts[$sym] / 3))
                $matchType = "MATCH! Zwei $sym!"
            }
            $win = $bet * $multiplier
        } elseif ($nonNullLine -contains "W") {
            $sym = ($nonNullLine | Where-Object { $_ -ne "W" })[0]
            $multiplier = [math]::Max(2, [math]::Floor($payouts[$sym] / 3))
            $win = $bet * $multiplier
            $matchType = "MATCH! Zwei $sym!"
        }
    }

    return @{ Win = $win; MatchType = $matchType; ScatterCount = $scatterCount; BonusCount = $bonusCount }
}

function slot {
    Invoke-CasinoGame -GameName "SLOT MACHINE" -PlayRound {
        param($bet, $stats)
        $symbols = @("7","BAR","CHERRY","LEMON","DIAMOND","BELL","HORSESHOE","W","S","B")
        $colors = @{ "7" = "Red"; "BAR" = "White"; "CHERRY" = "DarkRed"; "LEMON" = "Yellow"; "DIAMOND" = "Cyan"; "BELL" = "DarkYellow"; "HORSESHOE" = "Green"; "W" = "Magenta"; "S" = "Yellow"; "B" = "Green"; "OBSERVER" = "Magenta" }
        $payouts = @{ "7" = 50; "BAR" = 20; "DIAMOND" = 15; "BELL" = 10; "HORSESHOE" = 8; "CHERRY" = 5; "LEMON" = 3; "W" = 50 }

        if (-not $stats.ProgressiveJackpot) { $stats.ProgressiveJackpot = $script:SlotJackpotBase }
        if (-not $stats.JackpotWins) { $stats.JackpotWins = 0 }
        if (-not $stats.Spins) { $stats.Spins = 0 }
        if (-not $stats.TotalWon) { $stats.TotalWon = 0 }
        if (-not $stats.TotalSpent) { $stats.TotalSpent = 0 }

        $stats.TotalSpent += $bet
        $stats.Spins++
        $stats.ProgressiveJackpot += [math]::Floor($bet * 0.01)

        $cp = Load-CompanionState
        $luckLvl = if ($cp -and $cp.Skills) { $cp.Skills.CasinoLuck } else { 0 }
        if (-not $luckLvl) { $luckLvl = 0 }

        $totalWin = 0
        $jackpotWon = $false
        $achievement = $null
        $freeSpinsRemaining = 0
        $hadFreeSpins = $false

        $w = 56; $h = 16

        # Pre-spin scene
        $pre = New-Scene $w $h
        Add-SceneFrame $pre 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
        Add-SceneText $pre 4 2 "Bet: $bet G    Jackpot: $($stats.ProgressiveJackpot) G" 'DarkGray'
        Add-SceneFrame $pre 6 4 12 5 "" 'White'
        Add-SceneFrame $pre 22 4 12 5 "" 'White'
        Add-SceneFrame $pre 38 4 12 5 "" 'White'
        Add-SceneText $pre 4 10 "[SPACE] Spin    [Q] Quit" 'White'
        Show-Scene $pre -Force

        $act = Read-GameChoice "" "^[ SQ]$"
        if ($act -eq 'Q') {
            return @{ Win = 0; Loss = 0; Stats = $stats }
        }

        # Spin animation
        for ($i = 0; $i -lt 15; $i++) {
            $r1 = $symbols | Get-Random
            $r2 = $symbols | Get-Random
            $r3 = $symbols | Get-Random
            $spin = New-Scene $w $h
            Add-SceneFrame $spin 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
            Add-SceneText $spin 4 2 "Bet: $bet G    Jackpot: $($stats.ProgressiveJackpot) G    Spinning..." 'DarkGray'
            Add-SceneFrame $spin 6 4 12 5 "" 'White'
            Add-SceneText $spin 10 6 $r1 $colors[$r1]
            Add-SceneFrame $spin 22 4 12 5 "" 'White'
            Add-SceneText $spin 26 6 $r2 $colors[$r2]
            Add-SceneFrame $spin 38 4 12 5 "" 'White'
            Add-SceneText $spin 42 6 $r3 $colors[$r3]
            Show-Scene $spin -Force
            Start-Sleep -Milliseconds (80 + ($i * 40))
        }

        $s1 = Get-SlotSymbolWeighted $luckLvl
        $s2 = Get-SlotSymbolWeighted $luckLvl
        $s3 = Get-SlotSymbolWeighted $luckLvl
        $reels = @($s1, $s2, $s3)

        # ARG v3.0: OBSERVER Symbol alle 7 Spins
        if ($stats.Spins % 7 -eq 0) {
            $reels[(Get-Random -Maximum 3)] = "OBSERVER"
        }

        # Progressive jackpot check (main spin only)
        $jackpotAmount = 0
        if ((Get-Random -Maximum 10000) -eq 0) {
            $jackpotWon = $true
            $jackpotAmount = $stats.ProgressiveJackpot
            $totalWin += $jackpotAmount
            $stats.JackpotWins++
            $achievement = "Progressive Jackpot"
            $stats.TotalWon += $jackpotAmount
            $stats.ProgressiveJackpot = $script:SlotJackpotBase
        }

        $eval = Get-SlotLineWin $reels $bet $payouts
        if ($eval.Win -gt 0) {
            $totalWin += $eval.Win
            $stats.TotalWon += $eval.Win
        }

        if ($eval.ScatterCount -ge 3) {
            $hadFreeSpins = $true
            if ($eval.ScatterCount -eq 3) { $freeSpinsRemaining = 5 }
            elseif ($eval.ScatterCount -eq 4) { $freeSpinsRemaining = 8 }
            else { $freeSpinsRemaining = 12 }
        }

        # Bonus game
        $bonusWin = 0
        if ($eval.BonusCount -ge 3) {
            $bonusScene = New-Scene $w $h
            Add-SceneFrame $bonusScene 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
            Add-SceneText $bonusScene 4 2 "BONUS RUNDE!" 'Green'
            Add-SceneText $bonusScene 4 4 "Waehle eine Truhe:" 'White'
            Add-SceneText $bonusScene 6 6 "[1] Truhe 1" 'Yellow'
            Add-SceneText $bonusScene 6 7 "[2] Truhe 2" 'Yellow'
            Add-SceneText $bonusScene 6 8 "[3] Truhe 3" 'Yellow'
            Show-Scene $bonusScene -Force
            $pick = Read-GameChoice "" "^[123]$"

            $rewards = Invoke-FisherYatesShuffle -Array @(10, 50, $stats.ProgressiveJackpot)
            $bonusWin = $rewards[[int]$pick - 1]
            if ($bonusWin -eq $stats.ProgressiveJackpot -and $stats.ProgressiveJackpot -gt $script:SlotJackpotBase) {
                $stats.JackpotWins++
                $achievement = "Progressive Jackpot"
                $stats.ProgressiveJackpot = $script:SlotJackpotBase
            }

            $bonusResult = New-Scene $w $h
            Add-SceneFrame $bonusResult 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
            Add-SceneText $bonusResult 4 2 "BONUS RUNDE!" 'Green'
            Add-SceneText $bonusResult 4 4 "Du oeffnest Truhe $pick..." 'White'
            Add-SceneText $bonusResult 4 6 "Gewinn: $bonusWin G!" $(if ($bonusWin -ge 50) { 'Magenta' } else { 'Yellow' })
            Show-Scene $bonusResult -Force
            Start-Sleep -Milliseconds 800

            $totalWin += $bonusWin
            $stats.TotalWon += $bonusWin
        }

        # Final result scene
        $final = New-Scene $w $h
        Add-SceneFrame $final 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
        Add-SceneText $final 4 2 "Bet: $bet G    Jackpot: $($stats.ProgressiveJackpot) G" 'DarkGray'
        Add-SceneFrame $final 6 4 12 5 "" 'White'
        Add-SceneText $final 10 6 $s1 $colors[$s1]
        Add-SceneFrame $final 22 4 12 5 "" 'White'
        Add-SceneText $final 26 6 $s2 $colors[$s2]
        Add-SceneFrame $final 38 4 12 5 "" 'White'
        Add-SceneText $final 42 6 $s3 $colors[$s3]

        $lineY = 10
        if ($jackpotWon) {
            Add-SceneText $final 4 $lineY "PROGRESSIVE JACKPOT!!! $jackpotAmount G!" 'Magenta'
            $lineY++
        }
        if ($eval.Win -gt 0 -and $eval.MatchType) {
            Add-SceneText $final 4 $lineY $eval.MatchType 'Green'
            $lineY++
            Add-SceneText $final 4 $lineY "+$($eval.Win) G" 'Green'
            $lineY++
        } elseif (-not $jackpotWon -and $bonusWin -eq 0) {
            Add-SceneText $final 4 $lineY "Nichts." 'DarkGray'
            $lineY++
        }
        if ($bonusWin -gt 0) {
            Add-SceneText $final 4 $lineY "Bonus: +$bonusWin G" 'Yellow'
            $lineY++
        }
        if ($freeSpinsRemaining -gt 0) {
            Add-SceneText $final 4 $lineY "$freeSpinsRemaining FREE SPINS!" 'Cyan'
        }
        Show-Scene $final -Force
        Start-Sleep -Milliseconds 600

        # === FREE SPINS ===
        while ($freeSpinsRemaining -gt 0) {
            $fsBet = $bet

            for ($i = 0; $i -lt 10; $i++) {
                $r1 = $symbols | Get-Random
                $r2 = $symbols | Get-Random
                $r3 = $symbols | Get-Random
                $fsAnim = New-Scene $w $h
                Add-SceneFrame $fsAnim 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
                Add-SceneText $fsAnim 4 2 "FREE SPINS: $freeSpinsRemaining    Jackpot: $($stats.ProgressiveJackpot) G" 'Cyan'
                Add-SceneFrame $fsAnim 6 4 12 5 "" 'White'
                Add-SceneText $fsAnim 10 6 $r1 $colors[$r1]
                Add-SceneFrame $fsAnim 22 4 12 5 "" 'White'
                Add-SceneText $fsAnim 26 6 $r2 $colors[$r2]
                Add-SceneFrame $fsAnim 38 4 12 5 "" 'White'
                Add-SceneText $fsAnim 42 6 $r3 $colors[$r3]
                Show-Scene $fsAnim -Force
                Start-Sleep -Milliseconds (60 + ($i * 30))
            }

            $fs1 = Get-SlotSymbolWeighted $luckLvl
            $fs2 = Get-SlotSymbolWeighted $luckLvl
            $fs3 = Get-SlotSymbolWeighted $luckLvl
            $fsReels = @($fs1, $fs2, $fs3)
            $stats.Spins++

            # No progressive jackpot check on free spins (KB-CS1 fix)
            $fsEval = Get-SlotLineWin $fsReels $fsBet $payouts
            if ($fsEval.Win -gt 0) {
                $totalWin += $fsEval.Win
                $stats.TotalWon += $fsEval.Win
            }

            if ($fsEval.ScatterCount -ge 3) {
                $hadFreeSpins = $true
                $newFs = if ($fsEval.ScatterCount -eq 3) { 5 } elseif ($fsEval.ScatterCount -eq 4) { 8 } else { 12 }
                $freeSpinsRemaining += $newFs
            }

            $fsBonusWin = 0
            if ($fsEval.BonusCount -ge 3) {
                $bonusScene = New-Scene $w $h
                Add-SceneFrame $bonusScene 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
                Add-SceneText $bonusScene 4 2 "BONUS RUNDE (FREE SPIN)!" 'Green'
                Add-SceneText $bonusScene 4 4 "Waehle eine Truhe:" 'White'
                Add-SceneText $bonusScene 6 6 "[1] Truhe 1" 'Yellow'
                Add-SceneText $bonusScene 6 7 "[2] Truhe 2" 'Yellow'
                Add-SceneText $bonusScene 6 8 "[3] Truhe 3" 'Yellow'
                Show-Scene $bonusScene -Force
                $pick = Read-GameChoice "" "^[123]$"

                $rewards = Invoke-FisherYatesShuffle -Array @(10, 50, $stats.ProgressiveJackpot)
                $fsBonusWin = $rewards[[int]$pick - 1]
                if ($fsBonusWin -eq $stats.ProgressiveJackpot -and $stats.ProgressiveJackpot -gt $script:SlotJackpotBase) {
                    $stats.JackpotWins++
                    $achievement = "Progressive Jackpot"
                    $stats.ProgressiveJackpot = $script:SlotJackpotBase
                }

                $bonusResult = New-Scene $w $h
                Add-SceneFrame $bonusResult 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
                Add-SceneText $bonusResult 4 2 "BONUS RUNDE!" 'Green'
                Add-SceneText $bonusResult 4 4 "Du oeffnest Truhe $pick..." 'White'
                Add-SceneText $bonusResult 4 6 "Gewinn: $fsBonusWin G!" $(if ($fsBonusWin -ge 50) { 'Magenta' } else { 'Yellow' })
                Show-Scene $bonusResult -Force
                Start-Sleep -Milliseconds 800

                $totalWin += $fsBonusWin
                $stats.TotalWon += $fsBonusWin
            }

            $fsFinal = New-Scene $w $h
            Add-SceneFrame $fsFinal 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
            Add-SceneText $fsFinal 4 2 "FREE SPINS: $freeSpinsRemaining    Jackpot: $($stats.ProgressiveJackpot) G" 'Cyan'
            Add-SceneFrame $fsFinal 6 4 12 5 "" 'White'
            Add-SceneText $fsFinal 10 6 $fs1 $colors[$fs1]
            Add-SceneFrame $fsFinal 22 4 12 5 "" 'White'
            Add-SceneText $fsFinal 26 6 $fs2 $colors[$fs2]
            Add-SceneFrame $fsFinal 38 4 12 5 "" 'White'
            Add-SceneText $fsFinal 42 6 $fs3 $colors[$fs3]

            $fsLineY = 10
            if ($fsEval.Win -gt 0 -and $fsEval.MatchType) {
                Add-SceneText $fsFinal 4 $fsLineY $fsEval.MatchType 'Green'
                $fsLineY++
                Add-SceneText $fsFinal 4 $fsLineY "+$($fsEval.Win) G" 'Green'
                $fsLineY++
            } else {
                Add-SceneText $fsFinal 4 $fsLineY "Nichts." 'DarkGray'
                $fsLineY++
            }
            if ($fsBonusWin -gt 0) {
                Add-SceneText $fsFinal 4 $fsLineY "Bonus: +$fsBonusWin G" 'Yellow'
            }
            Show-Scene $fsFinal -Force
            Start-Sleep -Milliseconds 500

            $freeSpinsRemaining--
        }

        if ($totalWin -gt 0) {
            $summary = New-Scene $w $h
            Add-SceneFrame $summary 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
            Add-SceneText $summary 4 2 "Gesamtgewinn: $totalWin G" 'Green'
            Add-SceneText $summary 4 4 "Spins: $($stats.Spins) | Jackpot: $($stats.ProgressiveJackpot) G" 'DarkGray'
            Show-Scene $summary -Force
            Start-Sleep -Milliseconds 600
        }

        Save-State
        if ($jackpotWon -and $achievement) {
            Unlock-Achievement $achievement
            return @{ Win = $totalWin; Loss = 0; Stats = $stats }
        }
        return @{ Win = $totalWin; Loss = if ($totalWin -eq 0 -and -not $hadFreeSpins) { $bet } else { 0 }; Stats = $stats }
    }
}

} catch {
    Write-Host "[casino-slot] CRITICAL ERROR: $_" -ForegroundColor Red
}
