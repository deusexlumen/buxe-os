# BUXE_OS v24.0 -- CRAPS

try {

function craps {
    Invoke-CasinoGame -GameName "CRAPS" -PlayRound {
        param($bet, $stats)
        $type = Read-Host "  [P]ass Line (7/11 gewinnt, 2/3/12 verliert) oder [D]on't Pass (2/3 gewinnt, 7/11 verliert, 12 Push)"
        $pass = ($type -eq 'P' -or $type -eq 'p')
        
        $dice = New-DiceRoll 2 6
        $sum = Get-DiceSum $dice
        Write-Host "`n  W??rfel: [$($dice[0])] [$($dice[1])] = $sum" -ForegroundColor Cyan
        Start-Sleep -Milliseconds 500
        
        $won = $false; $lost = $false; $point = 0
        if ($pass) {
            if ($sum -in @(7,11)) { $won = $true }
            elseif ($sum -in @(2,3,12)) { $lost = $true }
            else { $point = $sum; Write-Host "  Point etabliert: $point" -ForegroundColor Yellow }
        } else {
            if ($sum -in @(2,3)) { $won = $true }
            elseif ($sum -eq 12) { Write-Host "  Push bei 12!" -ForegroundColor Yellow; $stats.Rolls++; return @{ Win = 0; Loss = 0; Stats = $stats } }
            elseif ($sum -in @(7,11)) { $lost = $true }
            else { $point = $sum; Write-Host "  Point etabliert: $point" -ForegroundColor Yellow }
        }
        
        while ($point -gt 0 -and -not $won -and -not $lost) {
            Read-Host "  [Enter] zum W??rfeln"
            $dice = New-DiceRoll 2 6
            $sum = Get-DiceSum $dice
            Write-Host "  [$($dice[0])] [$($dice[1])] = $sum" -ForegroundColor Cyan
            if ($sum -eq $point) { $won = $true }
            elseif ($sum -eq 7) { $lost = $true }
        }
        
        $stats.Rolls++
        if ($won) {
            $stats.Wins++; $stats.CurrentStreak++
            if ($stats.CurrentStreak -gt $stats.BestStreak) { $stats.BestStreak = $stats.CurrentStreak }
            Write-Host "  GEWONNEN! $bet G!" -ForegroundColor Green
            if ($stats.CurrentStreak -ge 3) { return @{ Win = $bet; Loss = 0; Stats = $stats; Achievement = "Craps Heater" } }
            return @{ Win = $bet; Loss = 0; Stats = $stats }
        } else {
            $stats.CurrentStreak = 0
            Write-Host "  Verloren." -ForegroundColor Red
            return @{ Win = 0; Loss = $bet; Stats = $stats }
        }
    }
}

} catch {
    Write-Host "[casino-craps] CRITICAL ERROR: $_" -ForegroundColor Red
}
