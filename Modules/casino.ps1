# BUXE_OS v24.0 -- CASINO ROUTER

try {

function Show-CasinoStats {
    Load-State
    Clear-Host
    Show-Frame "CASINO STATS" -Double | Out-Null
    Write-Host ""
    $cs = $script:BuxeState.Casino
    Write-Host "  BLACKJACK" -ForegroundColor Cyan
    Write-Host "    Hands: $($cs.Blackjack.HandsPlayed) | Won: $($cs.Blackjack.HandsWon) | Biggest: $($cs.Blackjack.BiggestWin)G" -ForegroundColor White
    Write-Host ""
    Write-Host "  ROULETTE" -ForegroundColor Cyan
    $hist = if ($cs.Roulette.History) { ($cs.Roulette.History | Select-Object -Last 10) -join ', ' } else { "No spins yet" }
    Write-Host "    Spins: $($cs.Roulette.Spins) | Biggest: $($cs.Roulette.BiggestWin)G" -ForegroundColor White
    Write-Host "    History: $hist" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  CRAPS" -ForegroundColor Cyan
    Write-Host "    Rolls: $($cs.Craps.Rolls) | Wins: $($cs.Craps.Wins) | Best Streak: $($cs.Craps.BestStreak)" -ForegroundColor White
    Write-Host ""
    Write-Host "  HI-LO" -ForegroundColor Cyan
    Write-Host "    Rounds: $($cs.HiLo.Rounds) | Best Streak: $($cs.HiLo.BestStreak)" -ForegroundColor White
    Write-Host ""
    Write-Host "  BACCARAT" -ForegroundColor Cyan
    Write-Host "    Hands: $($cs.Baccarat.Hands) | Banker: $($cs.Baccarat.BankerWins) | Player: $($cs.Baccarat.PlayerWins) | Ties: $($cs.Baccarat.Ties)" -ForegroundColor White
    Write-Host ""
    Write-Host "  SLOTS" -ForegroundColor Cyan
    $profit = $cs.Slot.TotalWon - $cs.Slot.TotalSpent
    $profitColor = if ($profit -ge 0) { "Green" } else { "Red" }
    Write-Host "    Spins: $($cs.Slot.Spins) | Jackpots: $($cs.Slot.JackpotWins) | Won: $($cs.Slot.TotalWon)G | Spent: $($cs.Slot.TotalSpent)G" -ForegroundColor White
    Write-Host "    Profit: $profit G" -ForegroundColor $profitColor
    Write-Host ""
    Wait-Enter
}

function casino {
    while ($true) {
        Clear-Screen "CASINO"
        Show-Bankroll
        Write-Host ""
        Show-Menu "Casino" @(
            "Blackjack",
            "Roulette",
            "Craps",
            "Hi-Lo",
            "Baccarat",
            "Slot"
        ) | Out-Null
        Write-Host "  [S] Stats | [Q] Zurueck" -ForegroundColor DarkGray
        
        $c = Read-Choice "Waehle" '^[1-6SQ]$'
        switch ($c) {
            '1' { blackjack }
            '2' { roulette }
            '3' { craps }
            '4' { hilo }
            '5' { baccarat }
            '6' { slot }
            'S' { Show-CasinoStats }
            'Q' { return }
        }
    }
}

} catch {
    Write-Host "[casino] CRITICAL ERROR: $_" -ForegroundColor Red
}
