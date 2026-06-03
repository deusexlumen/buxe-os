# BUXE_OS v24.3 -- SLOTS (TUI)
# Migriert auf TUI-Framework: Show-Scene + animierte Reels.

try {

function Get-SlotSymbolWeighted($luckLevel) {
    $symbols = @("7","BAR","CHERRY","LEMON","DIAMOND","BELL","HORSESHOE")
    if ($luckLevel -le 0) { return $symbols | Get-Random }
    $weights = @{
        "7" = 2; "BAR" = 3; "DIAMOND" = 4; "BELL" = 5
        "HORSESHOE" = 6; "CHERRY" = 8; "LEMON" = 10
    }
    $pool = @()
    foreach ($sym in $symbols) {
        $w = $weights[$sym] - $luckLevel
        if ($w -lt 1) { $w = 1 }
        for ($i = 0; $i -lt $w; $i++) { $pool += $sym }
    }
    return $pool | Get-Random
}

function slot {
    Invoke-CasinoGame -GameName "SLOT MACHINE" -PlayRound {
        param($bet, $stats)
        $symbols = @("7","BAR","CHERRY","LEMON","DIAMOND","BELL","HORSESHOE")
        $colors = @{ "7" = "Red"; "BAR" = "White"; "CHERRY" = "DarkRed"; "LEMON" = "Yellow"; "DIAMOND" = "Cyan"; "BELL" = "DarkYellow"; "HORSESHOE" = "Green" }
        $payouts = @{ "7" = 50; "BAR" = 20; "DIAMOND" = 15; "BELL" = 10; "HORSESHOE" = 8; "CHERRY" = 5; "LEMON" = 3 }
        
        Set-Bankroll (-$bet) -TrackCasino
        $stats.TotalSpent += $bet; $stats.Spins++
        
        $cp = Load-CompanionState
        $luckLvl = if ($cp -and $cp.Skills) { $cp.Skills.CasinoLuck } else { 0 }
        if (-not $luckLvl) { $luckLvl = 0 }
        
        $s1 = Get-SlotSymbolWeighted $luckLvl
        $s2 = Get-SlotSymbolWeighted $luckLvl
        $s3 = Get-SlotSymbolWeighted $luckLvl
        
        Reset-RenderBuffer
        $w = 56; $h = 14
        
        # Pre-spin scene
        $pre = New-Scene $w $h
        Add-SceneFrame $pre 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
        Add-SceneText $pre 4 2 "Bet: $bet G" 'DarkGray'
        Add-SceneFrame $pre 6 4 12 5 "" 'White'
        Add-SceneFrame $pre 22 4 12 5 "" 'White'
        Add-SceneFrame $pre 38 4 12 5 "" 'White'
        Add-SceneText $pre 4 10 "[SPACE] Spin    [Q] Quit" 'White'
        Show-Scene $pre -Force
        
        $act = Read-GameChoice "" "^[ SQ]$"
        if ($act -eq 'Q') {
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
        
        # Spin animation
        for ($i = 0; $i -lt 15; $i++) {
            $r1 = $symbols | Get-Random
            $r2 = $symbols | Get-Random
            $r3 = $symbols | Get-Random
            
            $spin = New-Scene $w $h
            Add-SceneFrame $spin 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
            Add-SceneText $spin 4 2 "Bet: $bet G    Spinning..." 'DarkGray'
            
            Add-SceneFrame $spin 6 4 12 5 "" 'White'
            Add-SceneText $spin 10 6 $r1 $colors[$r1]
            
            Add-SceneFrame $spin 22 4 12 5 "" 'White'
            Add-SceneText $spin 26 6 $r2 $colors[$r2]
            
            Add-SceneFrame $spin 38 4 12 5 "" 'White'
            Add-SceneText $spin 42 6 $r3 $colors[$r3]
            
            Show-Scene $spin -Force
            Start-Sleep -Milliseconds (80 + ($i * 40))
        }
        
        # Final result scene
        $final = New-Scene $w $h
        Add-SceneFrame $final 0 0 $w $h "SLOT MACHINE" 'Cyan' -Double
        Add-SceneText $final 4 2 "Bet: $bet G" 'DarkGray'
        
        Add-SceneFrame $final 6 4 12 5 "" 'White'
        Add-SceneText $final 10 6 $s1 $colors[$s1]
        
        Add-SceneFrame $final 22 4 12 5 "" 'White'
        Add-SceneText $final 26 6 $s2 $colors[$s2]
        
        Add-SceneFrame $final 38 4 12 5 "" 'White'
        Add-SceneText $final 42 6 $s3 $colors[$s3]
        
        $win = 0
        if ($s1 -eq $s2 -and $s2 -eq $s3) {
            $multiplier = $payouts[$s1]; $win = $bet * $multiplier
            Add-SceneText $final 4 10 "JACKPOT!!! DREI $s1 !!! ${multiplier}x!" 'Magenta'
            $stats.JackpotWins++
            Show-Scene $final -Force
            Start-Sleep -Milliseconds 800
            return @{ Win = $win; Loss = 0; Stats = $stats; Achievement = "Jackpot" }
        } elseif ($s1 -eq $s2 -or $s2 -eq $s3 -or $s1 -eq $s3) {
            $match = if ($s1 -eq $s2) { $s1 } elseif ($s2 -eq $s3) { $s2 } else { $s1 }
            $multiplier = [math]::Max(2, [math]::Floor($payouts[$match] / 3))
            $win = $bet * $multiplier
            Add-SceneText $final 4 10 "MATCH! Zwei $match! ${multiplier}x = $win G" 'Green'
        } else {
            Add-SceneText $final 4 10 "Nichts." 'DarkGray'
        }
        
        Show-Scene $final -Force
        Start-Sleep -Milliseconds 600
        
        if ($win -gt 0) { $stats.TotalWon += $win }
        return @{ Win = $win; Loss = if ($win -eq 0) { $bet } else { 0 }; Stats = $stats }
    }
}

} catch {
    Write-Host "[casino-slot] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
