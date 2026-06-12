# BUXE_OS v24.5 -- WHEEL OF FORTUNE

# Ein Rad, viele Segmente, eine einzige Wahrheit: Der Hausvorteil dreht sich immer zuerst.

try {

function wheel {
    Invoke-CasinoGame -GameName "WHEEL OF FORTUNE" -PlayRound {
        param($bet, $stats)

        if (-not $stats.Spins) { $stats.Spins = 0 }
        if (-not $stats.BestWin) { $stats.BestWin = 0 }
        if (-not $stats.Bankrupts) { $stats.Bankrupts = 0 }
        if (-not $stats.Jackpots) { $stats.Jackpots = 0 }

        # Balanciert auf ~97% RTP: mehr Push-/Kleingewinne, grosse Treffer entfernt.
        $segments = @(
            "1x","1x","1x","1x","1x","1x","1x","1x","1x",
            "2x","2x","2x","2x","2x","2x","2x",
            "3x",
            "5x",
            "BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT",
            "BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT","BANKRUPT"
        )

        $segmentColors = @{
            "1x" = "DarkGray"; "2x" = "White"; "3x" = "Cyan"; "5x" = "Yellow"
            "BANKRUPT" = "Red"
        }

        $stats.Spins++

        # Intro screen
        try { Clear-Host } catch {}
        Show-Frame "WHEEL OF FORTUNE" -Double | Out-Null
        Write-Host ""
        Write-Host "    +--------------+" -ForegroundColor Cyan
        Write-Host "    |  WHEEL OF  |" -ForegroundColor Cyan
        Write-Host "    |   FORTUNE  |" -ForegroundColor Cyan
        Write-Host "    +--------------+" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Segmente:" -ForegroundColor White
        Write-Host "  1x(9) | 2x(7) | 3x(1) | 5x(1) | BANKRUPT(14)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Bet: $bet G" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  [ENTER] Drehen   [Q] Quit" -ForegroundColor DarkGray

        $act = Read-GameChoice "" "^[`rQ]$"
        if ($act -eq 'Q') {
            return @{ Win = 0; Loss = 0; Stats = $stats }
        }

        # Spin animation
        $resultIdx = Get-Random -Maximum $segments.Count
        $totalFrames = 25 + $resultIdx

        for ($i = 0; $i -le $totalFrames; $i++) {
            $idx = $i % $segments.Count
            $seg = $segments[$idx]
            $color = $segmentColors[$seg]

            try { Clear-Host } catch {}
            Show-Frame "WHEEL OF FORTUNE" -Double | Out-Null
            Write-Host ""
            Write-Host "    +--------------+" -ForegroundColor Cyan
            Write-Host "    |  WHEEL OF  |" -ForegroundColor Cyan
            Write-Host "    |   FORTUNE  |" -ForegroundColor Cyan
            Write-Host "    +--------------+" -ForegroundColor Cyan
            Write-Host ""

            if ($i -lt $totalFrames) {
                Write-Host "    [ SPINNING... $seg ]" -ForegroundColor $color
            } else {
                Write-Host "    [ >>> $seg <<< ]" -ForegroundColor $color -BackgroundColor DarkGray
            }

            Write-Host ""
            Write-Host "  Bet: $bet G" -ForegroundColor DarkGray

            $delay = 60 + ($i * 25)
            if ($delay -gt 350) { $delay = 350 }
            Start-Sleep -Milliseconds $delay
        }

        # Calculate result
        $result = $segments[$resultIdx]
        $win = 0
        $loss = 0
        $achievement = $null

        Write-Host ""
        switch ($result) {
            "BANKRUPT" {
                $loss = $bet
                $stats.Bankrupts++
                Write-Host "  Result: BANKRUPT!" -ForegroundColor Red
                Write-Host "  Das Rad hat gesprochen. Dein Einsatz ist Geschichte." -ForegroundColor Red
            }
            "1x" {
                Write-Host "  Result: $result!" -ForegroundColor DarkGray
                Write-Host "  Push. Einsatz zurueck." -ForegroundColor DarkGray
            }
            default {
                $multiplier = [int]($result -replace "x", "")
                $win = $bet * ($multiplier - 1)
                if ($win -gt $stats.BestWin) { $stats.BestWin = $win }
                Write-Host "  Result: $result!" -ForegroundColor Green
                Write-Host "  Gewinn: $win G" -ForegroundColor Green
            }
        }

        Start-Sleep -Milliseconds 600
        return @{ Win = $win; Loss = $loss; Stats = $stats; Achievement = $achievement }
    }
}

} catch {
    Write-Host "[casino-wheel] CRITICAL ERROR: $_" -ForegroundColor Red
}
