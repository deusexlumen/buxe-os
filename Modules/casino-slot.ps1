# BUXE_OS v24.0 -- SLOTS

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
        Show-SlotSpin $symbols $colors @($s1,$s2,$s3) 10
        
        $win = 0
        if ($s1 -eq $s2 -and $s2 -eq $s3) {
            $multiplier = $payouts[$s1]; $win = $bet * $multiplier
            Write-Host "  JACKPOT!!! DREI $s1 !!! ${multiplier}x!" -ForegroundColor Magenta -BackgroundColor Yellow
            $stats.JackpotWins++
            return @{ Win = $win; Loss = 0; Stats = $stats; Achievement = "Jackpot" }
        } elseif ($s1 -eq $s2 -or $s2 -eq $s3 -or $s1 -eq $s3) {
            $match = if ($s1 -eq $s2) { $s1 } elseif ($s2 -eq $s3) { $s2 } else { $s1 }
            $multiplier = [math]::Max(2, [math]::Floor($payouts[$match] / 3))
            $win = $bet * $multiplier
            Write-Host "  MATCH! Zwei $match! ${multiplier}x = $win G" -ForegroundColor Green
        } else {
            Write-Host "  Nichts." -ForegroundColor DarkGray
        }
        
        if ($win -gt 0) { $stats.TotalWon += $win }
        return @{ Win = $win; Loss = if ($win -eq 0) { $bet } else { 0 }; Stats = $stats }
    }
}

} catch {
    Write-Host "[casino-slot] CRITICAL ERROR: $_" -ForegroundColor Red
}
