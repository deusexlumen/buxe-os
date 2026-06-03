# BUXE_OS v24.0 -- TOWER DEFENSE (vereinfacht)

try {

function td {
    Load-State
    $stats = Get-StrategyStats "TowerDefense"
    
    Clear-Screen "TOWER DEFENSE"
    Show-Bankroll
    Write-Host "`n  Verteidige deine Basis gegen 10 Wellen!" -ForegroundColor Cyan
    Write-Host "  [Enter] zum Starten..." -ForegroundColor DarkGray
    Read-Host
    
    $baseHP = 100; $gold = 200; $wave = 0; $maxWaves = 10
    $towers = @()
    
    while ($wave -lt $maxWaves -and $baseHP -gt 0) {
        $wave++
        $enemies = $wave * 2 + 3
        $eHP = 10 + $wave * 5
        
        while ($true) {
            Clear-Screen "TOWER DEFENSE"
            Write-Host "  Welle $wave/$maxWaves | Basis HP: $baseHP | Gold: $gold" -ForegroundColor Cyan
            Write-Host "  Tuerme: $($towers.Count)" -ForegroundColor Green
            Write-Host "`n  [1] Laser Tower (50G, 10 DMG)" -ForegroundColor White
            Write-Host "  [2] Sniper Tower (100G, 25 DMG)" -ForegroundColor White
            Write-Host "  [3] Start Welle" -ForegroundColor Yellow
            $c = Read-Host "  Waehle"
            if ($c -eq '1' -and $gold -ge 50) { $gold -= 50; $towers += @{ Type = "Laser"; Dmg = 10 } }
            elseif ($c -eq '2' -and $gold -ge 100) { $gold -= 100; $towers += @{ Type = "Sniper"; Dmg = 25 } }
            elseif ($c -eq '3') { break }
        }
        
        $totalDmg = 0
        foreach ($t in $towers) { $totalDmg += $t.Dmg }
        
        Write-Host "`n  WELLE $wave STARTET!" -ForegroundColor Magenta
        Write-Host "  $enemies Gegner mit $eHP HP" -ForegroundColor Red
        Write-Host "  Deine Tuerme machen $totalDmg DMG/Runde" -ForegroundColor Green
        Start-Sleep -Milliseconds 800
        
        $roundNum = 0
        while ($enemies -gt 0 -and $baseHP -gt 0) {
            $roundNum++
            $killDmg = $enemies * $eHP
            if ($totalDmg -ge $killDmg) {
                $enemies = 0
                Write-Host "  Alle Gegner besiegt in $roundNum Runden!" -ForegroundColor Green
            } else {
                $enemies = [math]::Ceiling(($killDmg - $totalDmg) / $eHP)
                $baseHP -= [math]::Max(1, $enemies * 2)
                Write-Host "  Runde $roundNum`: $enemies Gegner verbleiben | Basis: $baseHP HP" -ForegroundColor Yellow
            }
            Start-Sleep -Milliseconds 400
        }
        
        if ($baseHP -gt 0) {
            $reward = $wave * 20 + 10
            $gold += $reward
            Write-Host "`n  Welle $wave ueberstanden! +$reward G" -ForegroundColor Green
        }
    }
    
    if ($baseHP -gt 0) {
        Write-Host "`n  SIEG! Alle $maxWaves Wellen ueberstanden!" -ForegroundColor Green
        $insightMod = Get-StrategyInsightModifier
        $win = [math]::Floor(($gold + 100) * $insightMod)
        $bonus = $win - ($gold + 100)
        Set-Bankroll $win -TrackCasino
        if ($bonus -gt 0) { Write-Host "  (+$bonus Strategy Insight)" -ForegroundColor Magenta }
        $stats.GamesPlayed++; if ($wave -gt $stats.BestWave) { $stats.BestWave = $wave }
        Set-StrategyStats "TowerDefense" $stats
        Unlock-Achievement "Tower Defender"
        # StrategyInsight skill progression
        $cp = Load-CompanionState
        if ($cp -and $cp.Skills -and $cp.Skills.StrategyInsight -lt 10) {
            $cp.Skills.StrategyInsightWins = if ($cp.Skills.StrategyInsightWins) { $cp.Skills.StrategyInsightWins + 1 } else { 1 }
            if ($cp.Skills.StrategyInsightWins -ge 8) {
                $cp.Skills.StrategyInsight++
                $cp.Skills.StrategyInsightWins = 0
                Write-Host "  [SKILL UP] Strategy Insight ist jetzt Level $($cp.Skills.StrategyInsight)!" -ForegroundColor Magenta
                Save-CompanionState $cp
            }
        }
    } else {
        Write-Host "`n  NIEDERLAGE! Welle $wave" -ForegroundColor Red
        $stats.GamesPlayed++; if ($wave -gt $stats.BestWave) { $stats.BestWave = $wave }
        Set-StrategyStats "TowerDefense" $stats
    }
    Wait-Enter
}

} catch {
    Write-Host "[strategy-td] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
