# BUXE_OS v24.3 -- BLACKJACK (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function blackjack {
    Invoke-CasinoGame -GameName "BLACKJACK" -PlayRound {
        param($bet, $stats)
        $suitSymbol = @{ S = "♠"; H = "♥"; D = "♦"; C = "♣" }
        $deck = New-CardDeck
        $deckPos = [ref]0
        $playerHand = [System.Collections.ArrayList]::new()
        $dealerHand = [System.Collections.ArrayList]::new()
        [void]$playerHand.Add((Draw-Card $deck $deckPos))
        [void]$playerHand.Add((Draw-Card $deck $deckPos))
        [void]$dealerHand.Add((Draw-Card $deck $deckPos))
        [void]$dealerHand.Add((Draw-Card $deck $deckPos))
        
        $pVal = Get-HandValue $playerHand
        $dVal = Get-HandValue $dealerHand
        
        Reset-RenderBuffer
        $w = 60; $h = 20
        
        # Check blackjacks
        $pBJ = ($pVal -eq 21); $dBJ = ($dVal -eq 21)
        if ($pBJ -and $dBJ) {
            $s = New-Scene $w $h
            Add-SceneFrame $s 0 0 $w $h "BLACKJACK" 'Cyan' -Double
            Add-SceneText $s 4 5 "Beide haben Blackjack! Push." 'Yellow'
            Show-Scene $s -Force
            Start-Sleep -Milliseconds 600
            $stats.HandsPlayed++
            return @{ Win = 0; Loss = 0; Stats = $stats }
        } elseif ($pBJ) {
            $win = [math]::Floor($bet * 1.5)
            $stats.HandsWon++; $stats.HandsPlayed++
            if ($win -gt $stats.BiggestWin) { $stats.BiggestWin = $win }
            $s = New-Scene $w $h
            Add-SceneFrame $s 0 0 $w $h "BLACKJACK" 'Cyan' -Double
            Add-SceneText $s 4 5 "BLACKJACK! Du gewinnst $win G!" 'Green'
            Show-Scene $s -Force
            Start-Sleep -Milliseconds 600
            Unlock-Achievement "Blackjack Pro"
            return @{ Win = $win; Loss = 0; Stats = $stats }
        } elseif ($dBJ) {
            $stats.HandsPlayed++
            $s = New-Scene $w $h
            Add-SceneFrame $s 0 0 $w $h "BLACKJACK" 'Cyan' -Double
            Add-SceneText $s 4 5 "Dealer hat Blackjack. Du verlierst $bet G." 'Red'
            Show-Scene $s -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
        
        # Insurance
        $insured = $false
        if ($dealerHand[0].Rank -eq "A") {
            $ins = New-Scene $w $h
            Add-SceneFrame $ins 0 0 $w $h "BLACKJACK" 'Cyan' -Double
            Add-SceneText $ins 4 5 "Dealer zeigt Ass. Insurance?" 'Yellow'
            Add-SceneText $ins 4 7 "[Y]es    [N]o" 'White'
            Show-Scene $ins -Force
            $insAct = Read-GameChoice "" "^[YN]$"
            if ($insAct -eq 'Y') {
                $insured = $true
                $insBet = [math]::Floor($bet / 2)
                if ($dBJ) {
                    $s = New-Scene $w $h
                    Add-SceneFrame $s 0 0 $w $h "BLACKJACK" 'Cyan' -Double
                    Add-SceneText $s 4 5 "Insurance zahlt aus! Break-even." 'Yellow'
                    Show-Scene $s -Force
                    Start-Sleep -Milliseconds 600
                    $stats.HandsPlayed++
                    return @{ Win = $insBet * 2; Loss = $bet + $insBet; Stats = $stats }
                }
            }
            if ($dBJ) {
                $stats.HandsPlayed++
                $s = New-Scene $w $h
                Add-SceneFrame $s 0 0 $w $h "BLACKJACK" 'Cyan' -Double
                Add-SceneText $s 4 5 "Dealer Blackjack! Du verlierst $bet G." 'Red'
                Show-Scene $s -Force
                Start-Sleep -Milliseconds 600
                return @{ Win = 0; Loss = $bet; Stats = $stats }
            }
        }
        
        # Player turn
        $canSplit = ($playerHand[0].Rank -eq $playerHand[1].Rank)
        $canDouble = $true; $doubled = $false; $split = $false
        $hands = [System.Collections.Generic.List[object]]::new()
        $hands.Add($playerHand)
        $totalBet = $bet
        $totalWin = 0
        $handsWon = 0
        $handsPlayedCount = 0
        
        while ($hands.Count -gt 0) {
            $hand = $hands[0]; $hands.RemoveAt(0)
            $handIdx = if ($split) { " Hand $($hands.Count + 1)" } else { "" }
            
            while ((Get-HandValue $hand) -lt 21) {
                $s = New-Scene $w $h
                Add-SceneFrame $s 0 0 $w $h "BLACKJACK" 'Cyan' -Double
                Add-SceneText $s 4 1 "Bet: $totalBet G" 'DarkGray'
                
                # Dealer cards (hidden)
                Add-SceneText $s 4 3 "DEALER" 'White'
                $dx = 4
                for ($i = 0; $i -lt $dealerHand.Count; $i++) {
                    if ($i -eq $dealerHand.Count - 1) {
                        Add-SceneFrame $s $dx 4 7 4 "" 'White'
                        Add-SceneText $s ($dx + 2) 5 "?" 'White'
                    } else {
                        $col = if ($dealerHand[$i].Suit -in @("H","D")) { 'Red' } else { 'White' }
                        Add-SceneFrame $s $dx 4 7 4 "" $col
                        Add-SceneText $s ($dx + 1) 5 "$($suitSymbol[$dealerHand[$i].Suit])$($dealerHand[$i].Rank)" $col
                    }
                    $dx += 9
                }
                Add-SceneText $s 4 9 "Wert: ?" 'DarkGray'
                
                # Player cards
                Add-SceneText $s 4 11 "DU$handIdx" 'Cyan'
                $px = 4
                foreach ($c in $hand) {
                    $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
                    Add-SceneFrame $s $px 12 7 4 "" $col
                    Add-SceneText $s ($px + 1) 13 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
                    $px += 9
                }
                $handVal = Get-HandValue $hand
                Add-SceneText $s 4 17 "Wert: $handVal" 'Cyan'
                
                # Options
                $opts = "[H]it"
                if ($canDouble) { $opts += "  [D]ouble" }
                if ($canSplit -and $hands.Count -eq 0) { $opts += "  [P]plit" }
                $opts += "  [S]tand  [Q]uit"
                Add-SceneText $s 4 18 $opts 'DarkGray'
                Show-Scene $s -Force
                
                $act = Read-GameChoice "" "^[HDPSQ]$"
                if ($act -eq 'Q') {
                    return @{ Win = if ($totalWin -gt 0) { $totalWin } else { 0 }; Loss = $totalBet; Stats = $stats }
                }
                
                if ($act -eq 'D' -and $canDouble) {
                    $doubled = $true; $totalBet += $bet
                    [void]$hand.Add((Draw-Card $deck $deckPos))
                    break
                } elseif ($act -eq 'P' -and $canSplit -and $hands.Count -eq 0) {
                    $split = $true
                    $h1 = [System.Collections.ArrayList]::new(); [void]$h1.Add($hand[0]); [void]$h1.Add((Draw-Card $deck $deckPos))
                    $h2 = [System.Collections.ArrayList]::new(); [void]$h2.Add($hand[1]); [void]$h2.Add((Draw-Card $deck $deckPos))
                    $hands.Insert(0, $h2); $hand = $h1
                    $canSplit = $false; $canDouble = $true
                } elseif ($act -eq 'S') {
                    break
                } else {
                    [void]$hand.Add((Draw-Card $deck $deckPos))
                    $canDouble = $false
                }
            }
            
            $hVal = Get-HandValue $hand
            if ($hVal -gt 21) {
                $s = New-Scene $w $h
                Add-SceneFrame $s 0 0 $w $h "BLACKJACK" 'Cyan' -Double
                Add-SceneText $s 4 5 "BUST! $hVal" 'Red'
                Add-SceneText $s 4 7 "Hand verloren." 'DarkGray'
                Show-Scene $s -Force
                Start-Sleep -Milliseconds 500
                $totalWin -= $bet
            } else {
                # Dealer turn
                $ds = New-Scene $w $h
                Add-SceneFrame $ds 0 0 $w $h "BLACKJACK" 'Cyan' -Double
                Add-SceneText $ds 4 3 "DEALER DREHT AUF" 'White'
                $dx = 4
                foreach ($c in $dealerHand) {
                    $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
                    Add-SceneFrame $ds $dx 4 7 4 "" $col
                    Add-SceneText $ds ($dx + 1) 5 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
                    $dx += 9
                }
                Add-SceneText $ds 4 9 "Wert: $(Get-HandValue $dealerHand)" 'White'
                Show-Scene $ds -Force
                Start-Sleep -Milliseconds 600
                
                while ((Get-HandValue $dealerHand) -lt 17) {
                    [void]$dealerHand.Add((Draw-Card $deck $deckPos))
                    Start-Sleep -Milliseconds 500
                    $ds = New-Scene $w $h
                    Add-SceneFrame $ds 0 0 $w $h "BLACKJACK" 'Cyan' -Double
                    Add-SceneText $ds 4 3 "Dealer zieht..." 'DarkGray'
                    $dx = 4
                    foreach ($c in $dealerHand) {
                        $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
                        Add-SceneFrame $ds $dx 4 7 4 "" $col
                        Add-SceneText $ds ($dx + 1) 5 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
                        $dx += 9
                    }
                    Add-SceneText $ds 4 9 "Wert: $(Get-HandValue $dealerHand)" 'White'
                    Show-Scene $ds -Force
                    Start-Sleep -Milliseconds 500
                }
                
                $dFinal = Get-HandValue $dealerHand
                $fs = New-Scene $w $h
                Add-SceneFrame $fs 0 0 $w $h "BLACKJACK" 'Cyan' -Double
                
                if ($dFinal -gt 21) {
                    $totalWin += $bet; $handsWon++
                    Add-SceneText $fs 4 5 "Dealer busts! Du gewinnst $bet G!" 'Green'
                } elseif ($hVal -gt $dFinal) {
                    $totalWin += $bet; $handsWon++
                    Add-SceneText $fs 4 5 "Du gewinnst $bet G!" 'Green'
                } elseif ($hVal -lt $dFinal) {
                    $totalWin -= $bet
                    Add-SceneText $fs 4 5 "Du verlierst $bet G." 'Red'
                } else {
                    Add-SceneText $fs 4 5 "Push." 'Yellow'
                }
                Show-Scene $fs -Force
                Start-Sleep -Milliseconds 600
            }
            $handsPlayedCount++
        }
        
        $stats.HandsPlayed += $handsPlayedCount
        if ($handsWon -gt 0) { $stats.HandsWon++ }
        if ($totalWin -gt $stats.BiggestWin) { $stats.BiggestWin = $totalWin }
        
        return @{ 
            Win = if ($totalWin -gt 0) { $totalWin } else { 0 }
            Loss = if ($totalWin -lt 0) { [math]::Abs($totalWin) } else { 0 }
            Stats = $stats 
        }
    }
}

} catch {
    Write-Host "[casino-blackjack] CRITICAL ERROR: $_" -ForegroundColor Red
}
