# BUXE_OS v24.3 -- HI-LO (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function hilo {
    Invoke-CasinoGame -GameName "HIGHER OR LOWER" -PlayRound {
        param($bet, $stats)
        $deck = New-CardDeck
        $deckPos = [ref]1
        $card = $deck[0]
        $multiplier = 1.0
        $streak = 0
        $suitSymbol = @{ S = "♠"; H = "♥"; D = "♦"; C = "♣" }
        
        Reset-RenderBuffer
        
        while ($true) {
            $w = 50; $h = 16
            $s = New-Scene $w $h
            Add-SceneFrame $s 0 0 $w $h "HIGHER OR LOWER" 'Cyan' -Double
            
            # Card display
            $col = if ($card.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $s 4 3 12 5 "CARD" $col
            Add-SceneText $s 8 5 "$($suitSymbol[$card.Suit])$($card.Rank)" $col
            
            # Stats
            Add-SceneText $s 22 4 "Multiplier: ${multiplier}x" 'Green'
            Add-SceneText $s 22 5 "Streak: $streak" 'Yellow'
            Add-SceneText $s 22 6 "Bet: $bet G" 'DarkGray'
            
            # Controls
            Add-SceneText $s 4 10 "[H] Higher   [L] Lower   [C] Cash Out" 'White'
            Add-SceneText $s 4 11 "[Q] Quit" 'DarkGray'
            Add-SceneText $s 4 12 "Tipp: Farbe zaehlt nicht." 'DarkGray'
            
            Show-Scene $s -Force
            
            # Input
            $act = Read-GameChoice "" "^[HLCQ]$"
            if ($act -eq 'Q') {
                return @{ Win = 0; Loss = 0; Stats = $stats }
            }
            if ($act -eq 'C') {
                $win = [math]::Floor($bet * ($multiplier - 1))
                $stats.Rounds++; if ($streak -gt $stats.BestStreak) { $stats.BestStreak = $streak }
                
                # Show result scene
                $rs = New-Scene $w $h
                Add-SceneFrame $rs 0 0 $w $h "HIGHER OR LOWER" 'Cyan' -Double
                Add-SceneText $rs 4 5 "CASHED OUT!" 'Green'
                if ($win -gt 0) { Add-SceneText $rs 4 6 "+$win G" 'Green' }
                else { Add-SceneText $rs 4 6 "Break-even." 'Yellow' }
                Show-Scene $rs -Force
                Start-Sleep -Milliseconds 800
                
                return @{ Win = $win; Loss = 0; Stats = $stats }
            }
            
            # Draw next card
            if ($deckPos.Value -ge $deck.Count) { $deck = New-CardDeck; $deckPos.Value = 0 }
            $next = Draw-Card $deck $deckPos
            
            $isHigher = (Get-CardValue $next.Rank) -gt (Get-CardValue $card.Rank)
            $isLower = (Get-CardValue $next.Rank) -lt (Get-CardValue $card.Rank)
            $correct = ($act -eq 'H' -and $isHigher) -or ($act -eq 'L' -and $isLower)
            
            # Reveal scene
            $rs = New-Scene $w $h
            Add-SceneFrame $rs 0 0 $w $h "HIGHER OR LOWER" 'Cyan' -Double
            
            # Old card
            $ocol = if ($card.Suit -in @("H","D")) { 'DarkGray' } else { 'DarkGray' }
            Add-SceneFrame $rs 4 3 12 5 "OLD" 'DarkGray'
            Add-SceneText $rs 8 5 "$($suitSymbol[$card.Suit])$($card.Rank)" 'DarkGray'
            Add-SceneText $rs 17 5 "=>" 'DarkGray'
            
            # New card
            $ncol = if ($next.Suit -in @("H","D")) { 'Red' } else { 'White' }
            Add-SceneFrame $rs 22 3 12 5 "NEW" $ncol
            Add-SceneText $rs 26 5 "$($suitSymbol[$next.Suit])$($next.Rank)" $ncol
            
            Add-SceneText $rs 4 10 "Multiplier: ${multiplier}x" 'Green'
            Add-SceneText $rs 4 11 "Streak: $streak" 'Yellow'
            
            if ((Get-CardValue $next.Rank) -eq (Get-CardValue $card.Rank)) {
                Add-SceneText $rs 4 13 "GLEICHER WERT! Keine Aenderung." 'Yellow'
                Show-Scene $rs -Force
                Start-Sleep -Milliseconds 600
                # Card doesn't advance
            } elseif ($correct) {
                $multiplier += 0.5; $streak++
                Add-SceneText $rs 4 13 "RICHTIG! Multiplikator: ${multiplier}x" 'Green'
                Show-Scene $rs -Force
                Start-Sleep -Milliseconds 600
                
                if ($streak -ge 5) {
                    $win = [math]::Floor($bet * ($multiplier - 1))
                    Add-SceneText $rs 4 14 "LEGEND! +$win G" 'Magenta'
                    Show-Scene $rs -Force
                    Start-Sleep -Milliseconds 800
                    $stats.Rounds++; if ($streak -gt $stats.BestStreak) { $stats.BestStreak = $streak }
                    return @{ Win = $win; Loss = 0; Stats = $stats; Achievement = "HiLo Legend" }
                }
                $card = $next
            } else {
                Add-SceneText $rs 4 13 "FALSCH! Du verlierst $bet G." 'Red'
                Show-Scene $rs -Force
                Start-Sleep -Milliseconds 800
                $stats.Rounds++; if ($streak -gt $stats.BestStreak) { $stats.BestStreak = $streak }
                return @{ Win = 0; Loss = $bet; Stats = $stats }
            }
        }
    }
}

} catch {
    Write-Host "[casino-hilo] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
