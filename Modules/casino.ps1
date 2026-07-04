# BUXE_OS v24.0 -- CASINO ROUTER

try {

function Show-CasinoStats {
    Load-State
    try { Clear-Host } catch {}
    Show-Frame "CASINO STATS" -Double | Out-Null
    Write-Host ""
    $cs = $script:BuxeState.Casino
    Write-Host "  BLACKJACK" -ForegroundColor Cyan
    Write-Host "    Hands: $($cs.Blackjack.HandsPlayed ?? 0) | Won: $($cs.Blackjack.HandsWon ?? 0) | Biggest: $($cs.Blackjack.BiggestWin ?? 0)G" -ForegroundColor White
    Write-Host ""
    Write-Host "  ROULETTE" -ForegroundColor Cyan
    $hist = if ($cs.Roulette.History -and $cs.Roulette.History.Count -gt 0) { ($cs.Roulette.History | Select-Object -Last 10) -join ', ' } else { "No spins yet" }
    Write-Host "    Spins: $($cs.Roulette.Spins ?? 0) | Biggest: $($cs.Roulette.BiggestWin ?? 0)G" -ForegroundColor White
    Write-Host "    History: $hist" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  CRAPS" -ForegroundColor Cyan
    Write-Host "    Rolls: $($cs.Craps.Rolls ?? 0) | Wins: $($cs.Craps.Wins ?? 0) | Best Streak: $($cs.Craps.BestStreak ?? 0)" -ForegroundColor White
    Write-Host ""
    Write-Host "  HI-LO" -ForegroundColor Cyan
    Write-Host "    Rounds: $($cs.HiLo.Rounds ?? 0) | Best Streak: $($cs.HiLo.BestStreak ?? 0)" -ForegroundColor White
    Write-Host ""
    Write-Host "  BACCARAT" -ForegroundColor Cyan
    Write-Host "    Hands: $($cs.Baccarat.Hands ?? 0) | Banker: $($cs.Baccarat.BankerWins ?? 0) | Player: $($cs.Baccarat.PlayerWins ?? 0) | Ties: $($cs.Baccarat.Ties ?? 0)" -ForegroundColor White
    Write-Host ""
    Write-Host "  SLOTS" -ForegroundColor Cyan
    $profit = ($cs.Slot.TotalWon ?? 0) - ($cs.Slot.TotalSpent ?? 0)
    $profitColor = if ($profit -ge 0) { "Green" } else { "Red" }
    Write-Host "    Spins: $($cs.Slot.Spins ?? 0) | Jackpots: $($cs.Slot.JackpotWins ?? 0) | Won: $($cs.Slot.TotalWon ?? 0)G | Spent: $($cs.Slot.TotalSpent ?? 0)G" -ForegroundColor White
    Write-Host "    Profit: $profit G" -ForegroundColor $profitColor
    Write-Host ""
    Write-Host "  KENO" -ForegroundColor Cyan
    Write-Host "    Played: $($cs.Keno.Played ?? 0) | BestWin: $($cs.Keno.BestWin ?? 0)G | Won: $($cs.Keno.TotalWon ?? 0)G | Spent: $($cs.Keno.TotalSpent ?? 0)G" -ForegroundColor White
    Write-Host ""
    Write-Host "  WHEEL OF FORTUNE" -ForegroundColor Cyan
    Write-Host "    Spins: $($cs.Wheel.Spins ?? 0) | BestWin: $($cs.Wheel.BestWin ?? 0)G | Bankrupts: $($cs.Wheel.Bankrupts ?? 0) | Jackpots: $($cs.Wheel.Jackpots ?? 0)" -ForegroundColor White
    Write-Host ""
    Wait-Enter
}

function casino {
    Load-State
    $pet = if (Get-Command Get-PetState -ErrorAction SilentlyContinue) { Get-PetState } else { $null }
    $cp = if ($pet) { $pet.Companion } else { $null }
    if ($cp -and (Get-Command Get-CompanionLine -ErrorAction SilentlyContinue) -and (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) {
        $greeting = Get-CompanionLine $cp "hub_greeting"
        if ($greeting -and $greeting -ne "Ich bin nur ein Bug in der Matrix. Hallo.") {
            Show-CompanionDialog $cp $greeting -Fast
        }
    }
    while ($true) {
        try { Clear-Host } catch {}
        Show-Bankroll
        Write-Host ""
        $c = Show-MenuEx -Title "CASINO" -Items @(
            @{ Key = '1'; Label = 'Blackjack' },
            @{ Key = '2'; Label = 'Roulette' },
            @{ Key = '3'; Label = 'Craps' },
            @{ Key = '4'; Label = 'Hi-Lo' },
            @{ Key = '5'; Label = 'Baccarat' },
            @{ Key = '6'; Label = 'Slot' },
            @{ Key = '7'; Label = 'Keno' },
            @{ Key = '8'; Label = 'Wheel of Fortune' },
            @{ Key = 'S'; Label = 'Stats' }
        )
        switch ($c) {
            '1' { blackjack }
            '2' { roulette }
            '3' { craps }
            '4' { hilo }
            '5' { baccarat }
            '6' { slot }
            '7' { keno }
            '8' { wheel }
            'S' { Show-CasinoStats }
            'Q' { return }
        }
    }
}

} catch {
    Write-Host "[casino] CRITICAL ERROR: $_" -ForegroundColor Red
}
