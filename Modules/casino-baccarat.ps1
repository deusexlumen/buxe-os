# BUXE_OS v24.0 -- BACCARAT

try {

function baccarat {
    Invoke-CasinoGame -GameName "BACCARAT" -PlayRound {
        param($bet, $stats)
        $side = Read-Host "  Auf [P]layer (1:1) [B]anker (0.95:1) [T]ie (8:1)"
        $deck = New-CardDeck
        $pHand = @($deck[0], $deck[1])
        $bHand = @($deck[2], $deck[3])
        $pos = 4
        
        $pVal = Get-BaccaratValue $pHand
        $bVal = Get-BaccaratValue $bHand
        Write-Host "`n  Player: $(($pHand | ForEach-Object { "[$($_.Suit)$($_.Rank)]" }) -join ' ') = $pVal" -ForegroundColor Cyan
        Write-Host "  Banker: $(($bHand | ForEach-Object { "[$($_.Suit)$($_.Rank)]" }) -join ' ') = $bVal" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 600
        
        # Third card rules
        $pDraw = $false; $bDraw = $false; $pThird = $null
        if ($pVal -le 5) { $pDraw = $true; $pThird = $deck[$pos]; $pHand += $pThird; $pos++; $pVal = Get-BaccaratValue $pHand }
        if ($bVal -le 2) { $bDraw = $true }
        elseif ($bVal -eq 3) { if (-not $pDraw) { $bDraw = $true } elseif ($pThird.Rank -ne "8") { $bDraw = $true } }
        elseif ($bVal -eq 4) { if (-not $pDraw) { $bDraw = $true } elseif ($pThird.Rank -in @("2","3","4","5","6","7")) { $bDraw = $true } }
        elseif ($bVal -eq 5) { if (-not $pDraw) { $bDraw = $true } elseif ($pThird.Rank -in @("4","5","6","7")) { $bDraw = $true } }
        elseif ($bVal -eq 6) { if (-not $pDraw) { $bDraw = $false } elseif ($pThird.Rank -in @("6","7")) { $bDraw = $true } }
        if ($bDraw) { $bHand += $deck[$pos]; $bVal = Get-BaccaratValue $bHand }
        
        if ($pDraw -or $bDraw) {
            Write-Host "`n  Nach Ziehung:" -ForegroundColor White
            if ($pDraw) { Write-Host "  Player: $(($pHand | ForEach-Object { "[$($_.Suit)$($_.Rank)]" }) -join ' ') = $pVal" -ForegroundColor Cyan }
            if ($bDraw) { Write-Host "  Banker: $(($bHand | ForEach-Object { "[$($_.Suit)$($_.Rank)]" }) -join ' ') = $bVal" -ForegroundColor Yellow }
        }
        
        $result = if ($pVal -gt $bVal) { "PLAYER" } elseif ($bVal -gt $pVal) { "BANKER" } else { "TIE" }
        Write-Host "`n  RESULTAT: $result" -ForegroundColor $(if ($result -eq "PLAYER") { "Cyan" } elseif ($result -eq "BANKER") { "Yellow" } else { "Green" })
        
        $stats.Hands++
        $won = $false
        if ($side -eq 'P' -and $result -eq "PLAYER") { $stats.PlayerWins++; $won = $true; return @{ Win = $bet; Loss = 0; Stats = $stats } }
        elseif ($side -eq 'B' -and $result -eq "BANKER") { $stats.BankerWins++; $won = $true; $win = [math]::Floor($bet * 0.95); Write-Host "  5% Kommission abgezogen." -ForegroundColor DarkGray; return @{ Win = $win; Loss = 0; Stats = $stats } }
        elseif ($side -eq 'T' -and $result -eq "TIE") { $stats.Ties++; $won = $true; return @{ Win = ($bet * 8); Loss = 0; Stats = $stats; Achievement = "Baccarat Tie" } }
        else { return @{ Win = 0; Loss = $bet; Stats = $stats } }
    }
}

} catch {
    Write-Host "[casino-baccarat] CRITICAL ERROR: $_" -ForegroundColor Red
}
