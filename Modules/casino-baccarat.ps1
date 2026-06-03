# BUXE_OS v24.3 -- BACCARAT (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function baccarat {
    Invoke-CasinoGame -GameName "BACCARAT" -PlayRound {
        param($bet, $stats)
        $suitSymbol = @{ S = "?"; H = "?"; D = "?"; C = "?" }
        
        Reset-RenderBuffer
        $w = 56; $h = 18
        
        # Side selection
        $sel = New-Scene $w $h
        Add-SceneFrame $sel 0 0 $w $h "BACCARAT" 'Cyan' -Double
        Add-SceneText $sel 4 2 "Bet: $bet G" 'DarkGray'
        Add-SceneText $sel 4 4 "[P]layer  -> 1:1 Auszahlung" 'Cyan'
        Add-SceneText $sel 4 5 "[B]anker  -> 0.95:1 (5% Kommission)" 'Yellow'
        Add-SceneText $sel 4 6 "[T]ie     -> 8:1 Auszahlung" 'Green'
        Add-SceneText $sel 4 8 "[Q]uit" 'DarkGray'
        Show-Scene $sel -Force
        
        $side = Read-GameChoice "" "^[PBTQ]$"
        if ($side -eq 'Q') { return @{ Win = 0; Loss = 0; Stats = $stats } }
        
        $deck = New-CardDeck
        $pHand = @($deck[0], $deck[1])
        $bHand = @($deck[2], $deck[3])
        $pos = 4
        
        $pVal = Get-BaccaratValue $pHand
        $bVal = Get-BaccaratValue $bHand
        
        # Initial deal scene
        $ds = New-Scene $w $h
        Add-SceneFrame $ds 0 0 $w $h "BACCARAT" 'Cyan' -Double
        Add-SceneText $ds 4 2 "Bet: $bet G    Wahl: $(if ($side -eq 'P') { 'Player' } elseif ($side -eq 'B') { 'Banker' } else { 'Tie' })" 'DarkGray'
        
        $px = 4
        foreach ($c in $pHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $ds $px 4 8 5 "" $col
            Add-SceneText $ds ($px + 2) 6 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $px += 10
        }
        Add-SceneText $ds 4 10 "Player: $pVal" 'Cyan'
        
        $bx = 4
        foreach ($c in $bHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $ds $bx 11 8 5 "" $col
            Add-SceneText $ds ($bx + 2) 13 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $bx += 10
        }
        Add-SceneText $ds 4 17 "Banker: $bVal" 'Yellow'
        Show-Scene $ds -Force
        Start-Sleep -Milliseconds 800
        
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
            $ts = New-Scene $w $h
            Add-SceneFrame $ts 0 0 $w $h "BACCARAT" 'Cyan' -Double
            Add-SceneText $ts 4 2 "Nach Ziehung:" 'White'
            
            $px = 4
            foreach ($c in $pHand) {
                $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
                Add-SceneFrame $ts $px 4 8 5 "" $col
                Add-SceneText $ts ($px + 2) 6 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
                $px += 10
            }
            Add-SceneText $ts 4 10 "Player: $pVal" 'Cyan'
            
            $bx = 4
            foreach ($c in $bHand) {
                $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
                Add-SceneFrame $ts $bx 11 8 5 "" $col
                Add-SceneText $ts ($bx + 2) 13 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
                $bx += 10
            }
            Add-SceneText $ts 4 17 "Banker: $bVal" 'Yellow'
            Show-Scene $ts -Force
            Start-Sleep -Milliseconds 800
        }
        
        # Result
        $result = if ($pVal -gt $bVal) { "PLAYER" } elseif ($bVal -gt $pVal) { "BANKER" } else { "TIE" }
        $rColor = if ($result -eq "PLAYER") { 'Cyan' } elseif ($result -eq "BANKER") { 'Yellow' } else { 'Green' }
        
        $rs = New-Scene $w $h
        Add-SceneFrame $rs 0 0 $w $h "BACCARAT" 'Cyan' -Double
        Add-SceneText $rs 4 2 "RESULTAT: $result" $rColor
        
        $px = 4
        foreach ($c in $pHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $rs $px 4 8 5 "" $col
            Add-SceneText $rs ($px + 2) 6 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $px += 10
        }
        Add-SceneText $rs 4 10 "Player: $pVal" 'Cyan'
        
        $bx = 4
        foreach ($c in $bHand) {
            $col = if ($c.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $rs $bx 11 8 5 "" $col
            Add-SceneText $rs ($bx + 2) 13 "$($suitSymbol[$c.Suit])$($c.Rank)" $col
            $bx += 10
        }
        Add-SceneText $rs 4 17 "Banker: $bVal" 'Yellow'
        
        $stats.Hands++
        if ($side -eq 'P' -and $result -eq "PLAYER") {
            $stats.PlayerWins++
            Add-SceneText $rs 4 14 "GEWONNEN! +$bet G" 'Green'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = $bet; Loss = 0; Stats = $stats }
        } elseif ($side -eq 'B' -and $result -eq "BANKER") {
            $stats.BankerWins++
            $win = [math]::Floor($bet * 0.95)
            Add-SceneText $rs 4 14 "GEWONNEN! +$win G (5% Kommission)" 'Green'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = $win; Loss = 0; Stats = $stats }
        } elseif ($side -eq 'T' -and $result -eq "TIE") {
            $stats.Ties++
            Add-SceneText $rs 4 14 "TIE! +$($bet * 8) G" 'Green'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = ($bet * 8); Loss = 0; Stats = $stats; Achievement = "Baccarat Tie" }
        } else {
            Add-SceneText $rs 4 14 "Verloren." 'Red'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
    }
}

} catch {
    Write-Host "[casino-baccarat] CRITICAL ERROR: $_" -ForegroundColor Red
}
