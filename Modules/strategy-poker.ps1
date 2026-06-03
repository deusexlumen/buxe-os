# BUXE_OS v24.3 -- TEXAS HOLD'EM POKER (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function poker {
    Load-State
    $stats = Get-StrategyStats "Poker"
    $suitSymbol = @{ S = "?"; H = "?"; D = "?"; C = "?" }
    
    Reset-RenderBuffer
    $w = 60; $h = 20
    
    while ($true) {
        $br = Confirm-Bust "Poker"
        
        # Buy-in
        $pre = New-Scene $w $h
        Add-SceneFrame $pre 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        Add-SceneText $pre 4 2 "Bankroll: $br G" 'DarkGray'
        Add-SceneText $pre 4 4 "Buy-In festlegen (oder 'Q' fuer Zurueck)" 'White'
        Show-Scene $pre -Force
        
        $bet = Read-Bet $br "Buy-In"
        if ($bet -eq 0) { return }
        Set-Bankroll (-$bet) -TrackCasino
        
        $deck = New-CardDeck
        $deckPos = [ref]0
        $c1 = Draw-Card $deck $deckPos; $c2 = Draw-Card $deck $deckPos
        $playerHand = @($c1, $c2)
        $c3 = Draw-Card $deck $deckPos; $c4 = Draw-Card $deck $deckPos
        $aiHand = @($c3, $c4)
        $community = @()
        for ($ci = 0; $ci -lt 5; $ci++) { $community += Draw-Card $deck $deckPos }
        
        # Show player cards
        $cs = New-Scene $w $h
        Add-SceneFrame $cs 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        Add-SceneText $cs 4 2 "Deine Karten:" 'Cyan'
        $px = 4
        foreach ($c in $playerHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $cs $px 3 7 4 "" $col
            Add-SceneText $cs ($px + 1) 4 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $px += 9
        }
        Show-Scene $cs -Force
        Start-Sleep -Milliseconds 600
        
        # Pre-flop bet
        $pf = New-Scene $w $h
        Add-SceneFrame $pf 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        Add-SceneText $pf 4 2 "Deine Karten:" 'Cyan'
        $px = 4
        foreach ($c in $playerHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $pf $px 3 7 4 "" $col
            Add-SceneText $pf ($px + 1) 4 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $px += 9
        }
        Add-SceneText $pf 4 9 "Pre-Flop:" 'Yellow'
        Add-SceneText $pf 4 10 "[C]all    [F]old" 'White'
        Show-Scene $pf -Force
        
        $pfAct = Read-GameChoice "" "^[CF]$"
        if ($pfAct -eq 'F') { 
            $fs = New-Scene $w $h
            Add-SceneFrame $fs 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
            Add-SceneText $fs 4 5 "Gefoldet." 'DarkGray'
            Show-Scene $fs -Force
            Wait-Enter; continue 
        }
        $pot = $bet * 2
        
        # Flop
        $fb = New-Scene $w $h
        Add-SceneFrame $fb 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        Add-SceneText $fb 4 2 "FLOP:" 'Yellow'
        $cx = 4
        foreach ($c in $community[0..2]) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $fb $cx 3 7 4 "" $col
            Add-SceneText $fb ($cx + 1) 4 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $cx += 9
        }
        Add-SceneText $fb 4 9 "[C]heck   [B]et   [F]old" 'White'
        Show-Scene $fb -Force
        
        $fbAct = Read-GameChoice "" "^[CBF]$"
        if ($fbAct -eq 'F') { 
            $fs = New-Scene $w $h
            Add-SceneFrame $fs 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
            Add-SceneText $fs 4 5 "Gefoldet." 'DarkGray'
            Show-Scene $fs -Force
            Wait-Enter; continue 
        }
        if ($fbAct -eq 'B') { 
            $extra = Read-Bet $br "Bet"
            $pot += $extra * 2 
        }
        
        # Turn
        $tb = New-Scene $w $h
        Add-SceneFrame $tb 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        Add-SceneText $tb 4 2 "TURN:" 'Yellow'
        $cx = 4
        foreach ($c in $community[0..3]) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $tb $cx 3 7 4 "" $col
            Add-SceneText $tb ($cx + 1) 4 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $cx += 9
        }
        Add-SceneText $tb 4 9 "[C]heck   [B]et   [F]old" 'White'
        Show-Scene $tb -Force
        
        $tbAct = Read-GameChoice "" "^[CBF]$"
        if ($tbAct -eq 'F') { 
            $fs = New-Scene $w $h
            Add-SceneFrame $fs 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
            Add-SceneText $fs 4 5 "Gefoldet." 'DarkGray'
            Show-Scene $fs -Force
            Wait-Enter; continue 
        }
        if ($tbAct -eq 'B') { 
            $extra = Read-Bet $br "Bet"
            $pot += $extra * 2 
        }
        
        # River
        $rb = New-Scene $w $h
        Add-SceneFrame $rb 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        Add-SceneText $rb 4 2 "RIVER:" 'Yellow'
        $cx = 4
        foreach ($c in $community) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $rb $cx 3 7 4 "" $col
            Add-SceneText $rb ($cx + 1) 4 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $cx += 9
        }
        Add-SceneText $rb 4 9 "[C]heck   [B]et   [F]old" 'White'
        Show-Scene $rb -Force
        
        $rbAct = Read-GameChoice "" "^[CBF]$"
        if ($rbAct -eq 'F') { 
            $fs = New-Scene $w $h
            Add-SceneFrame $fs 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
            Add-SceneText $fs 4 5 "Gefoldet." 'DarkGray'
            Show-Scene $fs -Force
            Wait-Enter; continue 
        }
        if ($rbAct -eq 'B') { 
            $extra = Read-Bet $br "Bet"
            $pot += $extra * 2 
        }
        
        # Showdown
        $sd = New-Scene $w $h
        Add-SceneFrame $sd 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        Add-SceneText $sd 4 2 "SHOWDOWN" 'Magenta'
        
        Add-SceneText $sd 4 4 "Deine Hand:" 'Cyan'
        $px = 4
        foreach ($c in $playerHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $sd $px 5 7 4 "" $col
            Add-SceneText $sd ($px + 1) 6 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $px += 9
        }
        
        Add-SceneText $sd 4 10 "AI Hand:" 'Red'
        $ax = 4
        foreach ($c in $aiHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $sd $ax 11 7 4 "" $col
            Add-SceneText $sd ($ax + 1) 12 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $ax += 9
        }
        
        Add-SceneText $sd 4 16 "Community:" 'Yellow'
        $cx = 4
        foreach ($c in $community) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $sd $cx 17 7 4 "" $col
            Add-SceneText $sd ($cx + 1) 18 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $cx += 9
        }
        Show-Scene $sd -Force
        Start-Sleep -Milliseconds 800
        
        # Result
        $pHigh = Get-CardValue $playerHand[0].Rank -AcesHigh
        $aHigh = Get-CardValue $aiHand[0].Rank -AcesHigh
        $insightMod = Get-StrategyInsightModifier
        
        $rs = New-Scene $w $h
        Add-SceneFrame $rs 0 0 $w $h "TEXAS HOLD'EM" 'Cyan' -Double
        
        if ($pHigh -gt $aHigh) {
            $winAmount = [math]::Floor($pot * $insightMod)
            $bonus = $winAmount - $pot
            Add-SceneText $rs 4 5 "GEWONNEN! Pot: $winAmount G" 'Green'
            if ($bonus -gt 0) { Add-SceneText $rs 4 6 "(+$bonus Strategy Insight)" 'Magenta' }
            Set-Bankroll $winAmount -TrackCasino
            $stats.HandsWon++; $stats.HandsPlayed++
            if ($winAmount -gt $stats.BiggestPot) { $stats.BiggestPot = $winAmount }
            Unlock-Achievement "Poker Face"
        } elseif ($pHigh -eq $aHigh) {
            $winAmount = [math]::Floor(([math]::Floor($pot / 2)) * $insightMod)
            Add-SceneText $rs 4 5 "Split Pot. $winAmount G" 'Yellow'
            Set-Bankroll $winAmount -TrackCasino
            $stats.HandsPlayed++
        } else {
            Add-SceneText $rs 4 5 "Verloren." 'Red'
            $stats.HandsPlayed++
        }
        Show-Scene $rs -Force
        
        # StrategyInsight skill progression
        $cp = Load-CompanionState
        if ($cp -and $cp.Skills -and $pHigh -ge $aHigh) {
            $cp.Skills.StrategyInsightWins = if ($cp.Skills.StrategyInsightWins) { $cp.Skills.StrategyInsightWins + 1 } else { 1 }
            if ($cp.Skills.StrategyInsightWins -ge 10 -and $cp.Skills.StrategyInsight -lt 10) {
                $cp.Skills.StrategyInsight++
                $cp.Skills.StrategyInsightWins = 0
                Add-SceneText $rs 4 7 "[SKILL UP] Strategy Insight Level $($cp.Skills.StrategyInsight)!" 'Magenta'
                Show-Scene $rs -Force
                Save-CompanionState $cp
            }
        }
        Set-StrategyStats "Poker" $stats
        Wait-Enter
    }
}

} catch {
    Write-Host "[strategy-poker] CRITICAL ERROR: $_" -ForegroundColor Red
}
