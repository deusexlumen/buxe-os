# BUXE_OS v24.0 -- CASINO ENGINE
# Framework f??r alle Casino-Spiele.

try {

function Invoke-CasinoGame {
    param(
        [Parameter(Mandatory)] [string]$GameName,
        [Parameter(Mandatory)] [scriptblock]$PlayRound,
        [string]$StatsKey = $GameName
    )
    
    Load-State
    $stats = Get-CasinoStats $StatsKey
    if (-not $stats) { $stats = @{} }
    
    while ($true) {
        $br = Confirm-Bust $GameName
        Clear-Screen $GameName
        Show-Bankroll
        Write-Host ""
        Show-Frame "$GameName" -Double | Out-Null
        Write-Host ""
        
        $bet = Read-Bet $br "Einsatz"
        if ($bet -eq 0) { return }
        
        # Execute game logic
        $result = & $PlayRound $bet $stats
        
        # Apply casino luck bonus
        $luckMod = Get-CasinoLuckModifier
        $winAmount = $result.Win
        $bonus = 0
        if ($winAmount -gt 0 -and $luckMod -gt 1.0) {
            $bonus = [math]::Floor($winAmount * ($luckMod - 1.0))
            $winAmount += $bonus
            if ($bonus -gt 0) { $result.Win = $winAmount }
        }
        
        # Skill progression: CasinoLuck increases on wins with luck bonus active
        if ($winAmount -gt 0 -and $luckMod -gt 1.0) {
            $cp.Skills.CasinoLuckWins = if ($cp.Skills.CasinoLuckWins) { $cp.Skills.CasinoLuckWins + 1 } else { 1 }
            if ($cp.Skills.CasinoLuckWins -ge 10 -and $cp.Skills.CasinoLuck -lt 10) {
                $cp.Skills.CasinoLuck++
                $cp.Skills.CasinoLuckWins = 0
                Write-Host "`n  [SKILL UP] Casino Luck ist jetzt Level $($cp.Skills.CasinoLuck)!" -ForegroundColor Magenta
            }
        }
        
        # Update bank
        if ($winAmount -gt 0) {
            Set-Bankroll $winAmount -TrackCasino
            if ($bonus -gt 0) {
                Write-Host "`n  +$winAmount G gewonnen! (+$bonus Casino Luck)" -ForegroundColor Green
            } else {
                Write-Host "`n  +$winAmount G gewonnen!" -ForegroundColor Green
            }
        } elseif ($result.Loss -gt 0) {
            Set-Bankroll (-$result.Loss) -TrackCasino
            Write-Host "`n  -$($result.Loss) G verloren." -ForegroundColor Red
        }
        
        # Update stats
        if ($result.Stats) {
            foreach ($key in $result.Stats.Keys) {
                $stats[$key] = $result.Stats[$key]
            }
            Set-CasinoStats $StatsKey $stats
        }
        
        # Companion reactions
        Load-State
        $cp = $script:BuxeState.Companion
        if ($cp) {
            if ($result.Win -gt 0 -and $result.Win -gt 500 -and $cp.Bond -ge 50) {
                Write-Host "  [$($cp.Name)] >> *fans herself* You are on fire..." -ForegroundColor $cp.Color
            } elseif ($result.Loss -gt 0 -and $cp.Bond -lt 40) {
                Write-Host "  [$($cp.Name)] >> Still chasing losses? Classic." -ForegroundColor $cp.Color
            }
        }
        
        # Achievements
        if ($result.Achievement) { Unlock-Achievement $result.Achievement }
        
        Wait-Enter
    }
}

} catch {
    Write-Host "[casino-engine] CRITICAL ERROR: $_" -ForegroundColor Red
}
