# BUXE_OS v24.0 -- TEXAS HOLD'EM POKER (vereinfacht)

try {

function poker {
    Load-State
    $stats = Get-StrategyStats "Poker"
    
    while ($true) {
        $br = Confirm-Bust "Poker"
        Clear-Screen "TEXAS HOLD'EM"
        Show-Bankroll
        Write-Host ""
        
        $bet = Read-Bet $br "Buy-In"
        if ($bet -eq 0) { return }
        Set-Bankroll (-$bet) -TrackCasino
        
        $deck = New-CardDeck
        $deckPos = [ref]0
        $playerHand = @(Draw-Card $deck $deckPos, Draw-Card $deck $deckPos)
        $aiHand = @(Draw-Card $deck $deckPos, Draw-Card $deck $deckPos)
        $community = @(Draw-Card $deck $deckPos, Draw-Card $deck $deckPos, Draw-Card $deck $deckPos, Draw-Card $deck $deckPos, Draw-Card $deck $deckPos)
        
        Write-Host "  Deine Karten:" -ForegroundColor Cyan
        Show-CardHand $playerHand
        Write-Host ""
        
        # Pre-flop bet
        $pf = Read-Host "  Pre-Flop: [C]all [F]old"
        if ($pf -eq 'F') { Write-Host "  Gefoldet." -ForegroundColor DarkGray; Wait-Enter; continue }
        $pot = $bet * 2
        
        # Flop
        Write-Host "`n  FLOP:" -ForegroundColor Yellow
        Show-CardHand $community[0..2]
        $fb = Read-Host "  [C]heck [B]et [F]old"
        if ($fb -eq 'F') { Write-Host "  Gefoldet." -ForegroundColor DarkGray; Wait-Enter; continue }
        if ($fb -eq 'B') { $extra = Read-Bet $br "Bet"; $pot += $extra * 2 }
        
        # Turn
        Write-Host "`n  TURN:" -ForegroundColor Yellow
        Show-CardHand $community[0..3]
        $tb = Read-Host "  [C]heck [B]et [F]old"
        if ($tb -eq 'F') { Write-Host "  Gefoldet." -ForegroundColor DarkGray; Wait-Enter; continue }
        if ($tb -eq 'B') { $extra = Read-Bet $br "Bet"; $pot += $extra * 2 }
        
        # River
        Write-Host "`n  RIVER:" -ForegroundColor Yellow
        Show-CardHand $community
        $rb = Read-Host "  [C]heck [B]et [F]old"
        if ($rb -eq 'F') { Write-Host "  Gefoldet." -ForegroundColor DarkGray; Wait-Enter; continue }
        if ($rb -eq 'B') { $extra = Read-Bet $br "Bet"; $pot += $extra * 2 }
        
        # Showdown
        Write-Host "`n  SHOWDOWN" -ForegroundColor Magenta
        Write-Host "  Deine Hand:" -ForegroundColor Cyan
        Show-CardHand $playerHand
        Write-Host "`n  AI Hand:" -ForegroundColor Red
        Show-CardHand $aiHand
        Write-Host "`n  Community:" -ForegroundColor Yellow
        Show-CardHand $community
        
        # Simplified: higher card wins
        $pHigh = Get-CardValue $playerHand[0].Rank -AcesHigh
        $aHigh = Get-CardValue $aiHand[0].Rank -AcesHigh
        $insightMod = Get-StrategyInsightModifier
        if ($pHigh -gt $aHigh) {
            $winAmount = [math]::Floor($pot * $insightMod)
            $bonus = $winAmount - $pot
            Write-Host "`n  GEWONNEN! Pot: $winAmount G" -ForegroundColor Green
            if ($bonus -gt 0) { Write-Host "  (+$bonus Strategy Insight)" -ForegroundColor Magenta }
            Set-Bankroll $winAmount -TrackCasino
            $stats.HandsWon++; $stats.HandsPlayed++
            if ($winAmount -gt $stats.BiggestPot) { $stats.BiggestPot = $winAmount }
            Unlock-Achievement "Poker Face"
        } elseif ($pHigh -eq $aHigh) {
            $winAmount = [math]::Floor(([math]::Floor($pot / 2)) * $insightMod)
            Write-Host "`n  Split Pot. $winAmount G" -ForegroundColor Yellow
            Set-Bankroll $winAmount -TrackCasino
            $stats.HandsPlayed++
        } else {
            Write-Host "`n  Verloren." -ForegroundColor Red
            $stats.HandsPlayed++
        }
        # StrategyInsight skill progression
        $cp = Load-CompanionState
        if ($cp -and $cp.Skills -and $pHigh -ge $aHigh) {
            $cp.Skills.StrategyInsightWins = if ($cp.Skills.StrategyInsightWins) { $cp.Skills.StrategyInsightWins + 1 } else { 1 }
            if ($cp.Skills.StrategyInsightWins -ge 10 -and $cp.Skills.StrategyInsight -lt 10) {
                $cp.Skills.StrategyInsight++
                $cp.Skills.StrategyInsightWins = 0
                Write-Host "  [SKILL UP] Strategy Insight ist jetzt Level $($cp.Skills.StrategyInsight)!" -ForegroundColor Magenta
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
