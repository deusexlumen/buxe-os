# BUXE_OS v24.0 -- ROULETTE

try {

function roulette {
    Invoke-CasinoGame -GameName "EUROPEAN ROULETTE" -PlayRound {
        param($bet, $stats)
        $wheel = @(0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26)
        $redNums = @(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36)
        
        Write-Host "`n  Bets: [1] Rot/Schwarz [2] Gerade/Ungerade [3] Zahl [4] Dutzend [5] Street" -ForegroundColor White
        $choice = Read-Host "  W??hle"
        if ($choice -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
        if ($choice -notmatch '^[1-5]$') { Write-Host "  Ung??ltig." -ForegroundColor Red; return @{ Win = 0; Loss = 0; Stats = $stats } }
        
        switch ($choice) {
            "1" { $colorBet = Read-Host "  Rot oder Schwarz?"; $payout = 2 }
            "2" { $eoBet = Read-Host "  Gerade oder Ungerade?"; $payout = 2 }
            "3" { $numBet = [int](Read-Host "  Zahl (0-36)"); $payout = 36 }
            "4" { $dzBet = [int](Read-Host "  Dutzend (1=1-12, 2=13-24, 3=25-36)"); $payout = 3 }
            "5" { $strBet = [int](Read-Host "  Street Startzahl (1,4,7,10,13,16,19,22,25,28,31,34)"); $payout = 12 }
        }
        
        Write-Host "`n  Spinning..." -ForegroundColor Magenta
        for ($s = 0; $s -lt 15; $s++) {
            $temp = $wheel | Get-Random
            Write-Host "  $temp " -NoNewline -ForegroundColor $(if ($temp -eq 0) { "Green" } elseif ($temp -in $redNums) { "Red" } else { "White" })
            Start-Sleep -Milliseconds (50 + ($s * 20))
        }
        $result = $wheel | Get-Random
        Write-Host "`n`n  RESULTAT: $result" -ForegroundColor $(if ($result -eq 0) { "Green" } elseif ($result -in $redNums) { "Red" } else { "White" })
        
        $won = $false
        switch ($choice) {
            "1" { $isRed = $result -in $redNums; if (($colorBet -eq "Rot" -and $isRed) -or ($colorBet -eq "Schwarz" -and -not $isRed -and $result -ne 0)) { $won = $true } }
            "2" { if ($result -ne 0 -and (($eoBet -eq "Gerade" -and $result % 2 -eq 0) -or ($eoBet -eq "Ungerade" -and $result % 2 -eq 1))) { $won = $true } }
            "3" { if ($result -eq $numBet) { $won = $true } }
            "4" { $dz = if ($result -le 12) { 1 } elseif ($result -le 24) { 2 } else { 3 }; if ($dz -eq $dzBet -and $result -ne 0) { $won = $true } }
            "5" { if ($result -ne 0 -and $result -ge $strBet -and $result -lt $strBet + 3) { $won = $true } }
        }
        
        $stats.Spins++
        $stats.History += $result
        if ($stats.History.Count -gt 10) { $stats.History = @($stats.History | Select-Object -Skip 1) }
        
        if ($won) {
            $winAmount = $bet * ($payout - 1)
            if ($winAmount -gt $stats.BiggestWin) { $stats.BiggestWin = $winAmount }
            Write-Host "  GEWONNEN! $winAmount G (${payout}x)" -ForegroundColor Green
            return @{ Win = $winAmount; Loss = 0; Stats = $stats; Achievement = "Roulette Winner" }
        } else {
            Write-Host "  Verloren." -ForegroundColor Red
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
    }
}

} catch {
    Write-Host "[casino-roulette] CRITICAL ERROR: $_" -ForegroundColor Red
}
