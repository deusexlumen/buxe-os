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
            foreach ($key in @($result.Stats.Keys)) {
                $stats[$key] = $result.Stats[$key]
            }
            Set-CasinoStats $StatsKey $stats
        }
        
        # Companion reactions (LucasArts-Style)
        Load-State
        $cp = $script:BuxeState.Companion
        if ($cp -and (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) {
            if ($bank -le 0) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_bust") -Fast
            } elseif ($result.Win -gt 500) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_bigwin") -Fast
            } elseif ($result.Win -gt 0) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_win") -Fast
            } elseif ($result.Loss -gt 0) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_loss") -Fast
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
