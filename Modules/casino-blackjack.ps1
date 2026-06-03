# BUXE_OS v24.0 -- BLACKJACK

try {

function blackjack {
    Invoke-CasinoGame -GameName "BLACKJACK" -PlayRound {
        param($bet, $stats)
        
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
        
        # Check blackjacks
        $pBJ = ($pVal -eq 21); $dBJ = ($dVal -eq 21)
        if ($pBJ -and $dBJ) {
            Write-Host "`n  Beide haben Blackjack! Push." -ForegroundColor Yellow
            $stats.HandsPlayed++
            return @{ Win = 0; Loss = 0; Stats = $stats }
        } elseif ($pBJ) {
            $win = [math]::Floor($bet * 2.5)
            $stats.HandsWon++; $stats.HandsPlayed++
            if ($win -gt $stats.BiggestWin) { $stats.BiggestWin = $win }
            Write-Host "`n  BLACKJACK! Du gewinnst $win G!" -ForegroundColor Green
            return @{ Win = $win; Loss = 0; Stats = $stats; Achievement = "Blackjack Pro" }
        } elseif ($dBJ) {
            $stats.HandsPlayed++
            Write-Host "`n  Dealer hat Blackjack. Du verlierst $bet G." -ForegroundColor Red
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
        
        # Insurance
        $insured = $false
        if ($dealerHand[0].Rank -eq "A") {
            $ins = Read-Host "  Dealer zeigt Ass. Insurance? [Y/N]"
            if ($ins -eq 'Y') {
                $insured = $true
                $insBet = [math]::Floor($bet / 2)
                Set-Bankroll (-$insBet) -TrackCasino
                if ($dBJ) {
                    Write-Host "  Insurance zahlt aus! Break-even." -ForegroundColor Yellow
                    $stats.HandsPlayed++
                    return @{ Win = $insBet; Loss = $insBet; Stats = $stats }
                }
            }
            if ($dBJ) {
                $stats.HandsPlayed++
                Write-Host "`n  Dealer Blackjack! Du verlierst $bet G." -ForegroundColor Red
                return @{ Win = 0; Loss = $bet; Stats = $stats }
            }
        }
        
        # Player turn
        $canSplit = ($playerHand[0].Rank -eq $playerHand[1].Rank)
        $canDouble = $true; $doubled = $false; $split = $false
        $hands = [System.Collections.ArrayList]@($playerHand)
        $totalBet = $bet
        $totalWin = 0
        $handsWon = 0
        
        while ($hands.Count -gt 0) {
            $hand = $hands[0]; $hands.RemoveAt(0)
            $handIdx = if ($split) { " Hand $($hands.Count + 1)" } else { "" }
            
            while ((Get-HandValue $hand) -lt 21) {
                Clear-Screen "BLACKJACK"
                Show-Bankroll
                Write-Host ""
                Write-Host "  DEALER" -ForegroundColor White
                Show-CardHand $dealerHand -HideLast
                Write-Host "  Wert: ?" -ForegroundColor DarkGray
                Write-Host "`n  DU$handIdx" -ForegroundColor Cyan
                Show-CardHand $hand
                $handVal = Get-HandValue $hand
                Write-Host "  Wert: $handVal" -ForegroundColor Cyan
                
                $opts = "[H]it"
                if ($canDouble) { $opts += " [D]ouble" }
                if ($canSplit -and $hands.Count -eq 0) { $opts += " [S]plit" }
                $opts += " [St]and"
                Write-Host "`n  $opts" -ForegroundColor DarkGray
                $act = Read-Host "  Aktion"
                
                if ($act -eq 'D' -and $canDouble) {
                    $doubled = $true; $totalBet += $bet
                    [void]$hand.Add((Draw-Card $deck $deckPos))
                    break
                } elseif ($act -eq 'S' -and $canSplit -and $hands.Count -eq 0) {
                    $split = $true
                    $h1 = [System.Collections.ArrayList]::new(); [void]$h1.Add($hand[0]); [void]$h1.Add((Draw-Card $deck $deckPos))
                    $h2 = [System.Collections.ArrayList]::new(); [void]$h2.Add($hand[1]); [void]$h2.Add((Draw-Card $deck $deckPos))
                    $hands.Insert(0, $h2); $hand = $h1
                    $canSplit = $false; $canDouble = $true
                } elseif ($act -eq 'St') {
                    break
                } else {
                    [void]$hand.Add((Draw-Card $deck $deckPos))
                    $canDouble = $false
                }
            }
            
            $hVal = Get-HandValue $hand
            if ($hVal -gt 21) {
                Write-Host "`n  BUST! $hVal" -ForegroundColor Red
                $totalWin -= $bet
            } else {
                # Dealer turn
                Write-Host "`n  DEALER DREHT AUF" -ForegroundColor White
                Show-CardHand $dealerHand
                Write-Host "  Wert: $(Get-HandValue $dealerHand)" -ForegroundColor White
                while ((Get-HandValue $dealerHand) -lt 17) {
                    [void]$dealerHand.Add((Draw-Card $deck $deckPos))
                    Start-Sleep -Milliseconds 500
                    Write-Host "`n  Dealer zieht..." -ForegroundColor DarkGray
                    Show-CardHand $dealerHand
                    Write-Host "  Wert: $(Get-HandValue $dealerHand)" -ForegroundColor White
                }
                $dFinal = Get-HandValue $dealerHand
                Write-Host ""
                if ($dFinal -gt 21) {
                    $totalWin += $bet; $handsWon++
                    Write-Host "  Dealer busts! Du gewinnst $bet G!" -ForegroundColor Green
                } elseif ($hVal -gt $dFinal) {
                    $totalWin += $bet; $handsWon++
                    Write-Host "  Du gewinnst $bet G!" -ForegroundColor Green
                } elseif ($hVal -lt $dFinal) {
                    $totalWin -= $bet
                    Write-Host "  Du verlierst $bet G." -ForegroundColor Red
                } else {
                    Write-Host "  Push." -ForegroundColor Yellow
                }
            }
        }
        
        $stats.HandsPlayed++
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
