# BUXE_OS v24.5 -- KENO

# Waehle Zahlen, ziehe Losnummern, hoffe auf das Beste.
# Der Hausvorteil ist real, aber die Illusion ist kostenlos.

try {

function keno {
    Invoke-CasinoGame -GameName "KENO" -PlayRound {
        param($bet, $stats)

        if (-not $stats.Played) { $stats.Played = 0 }
        if (-not $stats.BestWin) { $stats.BestWin = 0 }
        if (-not $stats.TotalWon) { $stats.TotalWon = 0 }
        if (-not $stats.TotalSpent) { $stats.TotalSpent = 0 }

        $stats.TotalSpent += $bet
        $stats.Played++

        $selected = @()
        $done = $false
        $quit = $false

        while (-not $done -and -not $quit) {
            try { Clear-Host } catch {}
            Show-Frame "KENO" -Double | Out-Null
            Write-Host ""
            Write-Host "  Waehle 1-10 Zahlen (1-80). Zahl eingeben zum Toggle." -ForegroundColor DarkGray
            Write-Host "  [D] Fertig  [Q] Quit  [C] Clear" -ForegroundColor DarkGray
            Write-Host ""

            for ($row = 0; $row -lt 8; $row++) {
                Write-Host "  " -NoNewline
                for ($col = 0; $col -lt 10; $col++) {
                    $num = $row * 10 + $col + 1
                    $ns = $num.ToString().PadLeft(2)
                    if ($selected -contains $num) {
                        Write-Host "*$ns*" -ForegroundColor Yellow -NoNewline
                    } else {
                        Write-Host " $ns " -NoNewline
                    }
                    Write-Host " " -NoNewline
                }
                Write-Host ""
            }

            Write-Host ""
            Write-Host "  Gewaehlt: $($selected.Count)/10" -ForegroundColor Cyan
            if ($selected.Count -gt 0) {
                $selStr = ($selected | Sort-Object | ForEach-Object { $_.ToString() }) -join ', '
                Write-Host "  Zahlen: $selStr" -ForegroundColor White
            }
            Write-Host ""

            $in = Read-GameInput "Zahl (1-80) oder Befehl"
            $in = $in.Trim().ToUpper()

            if ($in -eq 'Q') { $quit = $true; break }
            if ($in -eq 'D') {
                if ($selected.Count -ge 1) { $done = $true }
                else { Write-Host "  Mindestens 1 Zahl waehlen!" -ForegroundColor Red; Start-Sleep -Milliseconds 500 }
                continue
            }
            if ($in -eq 'C') { $selected = @(); continue }

            $num = 0
            if ([int]::TryParse($in, [ref]$num)) {
                if ($num -lt 1 -or $num -gt 80) {
                    Write-Host "  Ungueltig! Nur 1-80 erlaubt." -ForegroundColor Red
                    Start-Sleep -Milliseconds 300
                    continue
                }
                if ($selected -contains $num) {
                    $selected = $selected | Where-Object { $_ -ne $num }
                } elseif ($selected.Count -lt 10) {
                    $selected += $num
                } else {
                    Write-Host "  Maximum 10 Zahlen!" -ForegroundColor Red
                    Start-Sleep -Milliseconds 300
                }
            } else {
                Write-Host "  Ungueltige Eingabe." -ForegroundColor Red
                Start-Sleep -Milliseconds 300
            }
        }

        if ($quit) {
            return @{ Win = 0; Loss = 0; Stats = $stats }
        }

        # Draw 20 numbers
        $pool = 1..80 | Get-Random -Count 80
        $drawn = $pool | Select-Object -First 20
        $matched = @($selected | Where-Object { $drawn -contains $_ })
        $matchCount = $matched.Count

        # Paytable
        $paytable = @{ 0 = 0; 1 = 1; 2 = 1; 3 = 2; 4 = 5; 5 = 10; 6 = 50; 7 = 100; 8 = 500; 9 = 1000; 10 = 10000 }
        $multiplier = $paytable[$matchCount]
        $win = $bet * $multiplier

        # Result display
        try { Clear-Host } catch {}
        Show-Frame "KENO ERGEBNIS" -Double | Out-Null
        Write-Host ""

        for ($row = 0; $row -lt 8; $row++) {
            Write-Host "  " -NoNewline
            for ($col = 0; $col -lt 10; $col++) {
                $num = $row * 10 + $col + 1
                $ns = $num.ToString().PadLeft(2)
                $isSelected = $selected -contains $num
                $isDrawn = $drawn -contains $num

                if ($isSelected -and $isDrawn) {
                    Write-Host "*$ns*" -ForegroundColor Green -NoNewline
                } elseif ($isSelected) {
                    Write-Host "*$ns*" -ForegroundColor DarkGray -NoNewline
                } elseif ($isDrawn) {
                    Write-Host "($ns)" -ForegroundColor Yellow -NoNewline
                } else {
                    Write-Host " $ns " -NoNewline
                }
                Write-Host " " -NoNewline
            }
            Write-Host ""
        }

        Write-Host ""
        $drawnStr = ($drawn | Sort-Object | ForEach-Object { $_.ToString() }) -join ', '
        Write-Host "  Gezogene Zahlen: $drawnStr" -ForegroundColor Yellow
        $matchedStr = ($matched | Sort-Object | ForEach-Object { $_.ToString() }) -join ', '
        Write-Host "  Deine Treffer: $matchedStr" -ForegroundColor Cyan
        Write-Host ""

        if ($matchCount -eq 10) {
            Write-Host "  ALLE 10 TREFFER! Das RNG hat einen schlechten Tag." -ForegroundColor Magenta
        } elseif ($matchCount -ge 7) {
            Write-Host "  $matchCount Treffer! Die Wahrscheinlichkeiten haben sich verbeugt!" -ForegroundColor Magenta
        } elseif ($matchCount -ge 4) {
            Write-Host "  $matchCount Treffer! Nicht schlecht fuer jemanden der auf Zufall tippt." -ForegroundColor Green
        } elseif ($matchCount -ge 1) {
            Write-Host "  $matchCount Treffer. Immerhin kein Game Over." -ForegroundColor Yellow
        } else {
            Write-Host "  0 Treffer. Die Zahlen haben sich gegen dich verschworen." -ForegroundColor Red
        }

        Write-Host "  Gewinn: $win G" -ForegroundColor $(if ($win -gt $bet) { "Green" } elseif ($win -eq $bet) { "Yellow" } else { "Red" })

        if ($win -gt 0) {
            $stats.TotalWon += $win
            if ($win -gt $stats.BestWin) { $stats.BestWin = $win }
        }

        Start-Sleep -Milliseconds 800
        return @{ Win = $win; Loss = if ($win -eq 0) { $bet } else { 0 }; Stats = $stats }
    }
}

} catch {
    Write-Host "[casino-keno] CRITICAL ERROR: $_" -ForegroundColor Red
}
