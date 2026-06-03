# BUXE_OS v24.0 -- HI-LO

try {

function hilo {
    Invoke-CasinoGame -GameName "HIGHER OR LOWER" -PlayRound {
        param($bet, $stats)
        $deck = New-CardDeck
        $deckPos = [ref]1
        $card = $deck[0]
        $multiplier = 1.0
        $streak = 0
        
        while ($true) {
            $col = if ($card.Suit -in @("H","D")) { "Red" } else { "White" }
            $suitSymbol = @{ S = "?"; H = "?"; D = "?"; C = "?" }
            Write-Host "`n  Aktuell: [$($suitSymbol[$card.Suit])$($card.Rank)]   Multiplikator: ${multiplier}x   Streak: $streak" -ForegroundColor Green
            $act = Read-Host "  [H]oeher [L]iefer [C]ash out"
            if ($act -eq 'C') {
                $win = [math]::Floor($bet * ($multiplier - 1))
                if ($win -gt 0) { Write-Host "`n  CASHED OUT! +$win G" -ForegroundColor Green }
                else { Write-Host "`n  Break-even." -ForegroundColor Yellow }
                $stats.Rounds++; if ($streak -gt $stats.BestStreak) { $stats.BestStreak = $streak }
                return @{ Win = $win; Loss = 0; Stats = $stats }
            }
            if ($deckPos.Value -ge $deck.Count) { $deck = New-CardDeck; $deckPos.Value = 0 }
            $next = Draw-Card $deck $deckPos
            $isHigher = (Get-CardValue $next.Rank) -gt (Get-CardValue $card.Rank)
            $isLower = (Get-CardValue $next.Rank) -lt (Get-CardValue $card.Rank)
            $correct = ($act -eq 'H' -and $isHigher) -or ($act -eq 'L' -and $isLower)
            Write-Host "`n  Naechste: [$($suitSymbol[$next.Suit])$($next.Rank)]" -ForegroundColor $(if ($next.Suit -in @("H","D")) { "Red" } else { "White" })
            if ((Get-CardValue $next.Rank) -eq (Get-CardValue $card.Rank)) {
                Write-Host "  Gleicher Wert! Keine Aenderung." -ForegroundColor Yellow
            } elseif ($correct) {
                $multiplier += 0.5; $streak++
                Write-Host "  RICHTIG! Multiplikator: ${multiplier}x" -ForegroundColor Green
                if ($streak -ge 5) { return @{ Win = [math]::Floor($bet * ($multiplier - 1)); Loss = 0; Stats = $stats; Achievement = "HiLo Legend" } }
            } else {
                $stats.Rounds++; if ($streak -gt $stats.BestStreak) { $stats.BestStreak = $streak }
                Write-Host "  FALSCH! Du verlierst $bet G." -ForegroundColor Red
                return @{ Win = 0; Loss = $bet; Stats = $stats }
            }
            $card = $next
        }
    }
}

} catch {
    Write-Host "[casino-hilo] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
