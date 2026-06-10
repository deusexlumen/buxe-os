# BUXE_OS v24.3 -- TOWER DEFENSE (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice.

try {

function td {
    Load-State
    $stats = Get-StrategyStats "TowerDefense"
    
    Reset-RenderBuffer
    $w = 56; $h = 18
    
    # Pre-game
    $pre = New-Scene $w $h
    Add-SceneFrame $pre 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
    Add-SceneText $pre 4 2 "Verteidige deine Basis gegen 10 Wellen!" 'Cyan'
    Add-SceneText $pre 4 4 "[ENTER] Starten" 'Green'
    Add-SceneText $pre 4 5 "[Q] Quit" 'DarkGray'
    Show-Scene $pre -Force
    
    $act = Read-GameChoice "" "^[Q]$"
    if ($act -eq 'Q') { return }
    
    $entryFee = 100
    $br = Get-Bankroll
    if ($br -lt $entryFee) { Write-Host "`n  Nicht genug Gold! ($entryFee G)" -ForegroundColor Red; Wait-Enter; return }
    Spend-Gold $entryFee "TD Entry"
    
    $baseHP = 100; $gold = 200; $wave = 0; $maxWaves = 10
    $towers = @()
    
    while ($wave -lt $maxWaves -and $baseHP -gt 0) {
        $wave++
        $enemies = $wave * 2 + 3
        $eHP = 10 + $wave * 5
        
        # Build phase
        while ($true) {
            $bs = New-Scene $w $h
            Add-SceneFrame $bs 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
            Add-SceneText $bs 4 2 "Welle $wave/$maxWaves" 'Cyan'
            Add-SceneText $bs 4 3 "Basis HP: $baseHP | Gold: $gold" 'White'
            Add-SceneText $bs 4 4 "Tuerme: $($towers.Count)" 'Green'
            
            $y = 6
            foreach ($t in $towers) {
                Add-SceneText $bs 4 $y "$($t.Type) Tower ($($t.Dmg) DMG)" 'DarkGray'
                $y++
            }
            
            Add-SceneText $bs 4 13 "[1] Laser Tower  (50G, 10 DMG)" 'White'
            Add-SceneText $bs 4 14 "[2] Sniper Tower (100G, 25 DMG)" 'White'
            Add-SceneText $bs 4 15 "[3] Start Welle" 'Yellow'
            Show-Scene $bs -Force
            
            $c = Read-GameChoice "" "^[123]$"
            if ($c -eq '1' -and $gold -ge 50) { $gold -= 50; $towers += @{ Type = "Laser"; Dmg = 10 } }
            elseif ($c -eq '2' -and $gold -ge 100) { $gold -= 100; $towers += @{ Type = "Sniper"; Dmg = 25 } }
            elseif ($c -eq '3') { break }
        }
        
        $totalDmg = 0
        foreach ($t in $towers) { $totalDmg += $t.Dmg }
        
        # Wave start
        $ws = New-Scene $w $h
        Add-SceneFrame $ws 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
        Add-SceneText $ws 4 5 "WELLE $wave STARTET!" 'Magenta'
        Add-SceneText $ws 4 6 "$enemies Gegner mit $eHP HP" 'Red'
        Add-SceneText $ws 4 7 "Deine Tuerme: $totalDmg DMG/Runde" 'Green'
        Show-Scene $ws -Force
        Start-Sleep -Milliseconds 800
        
        # Combat phase
        $roundNum = 0
        while ($enemies -gt 0 -and $baseHP -gt 0) {
            $roundNum++
            $killDmg = $enemies * $eHP
            if ($totalDmg -ge $killDmg) {
                $enemies = 0
                $cs = New-Scene $w $h
                Add-SceneFrame $cs 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
                Add-SceneText $cs 4 5 "Alle Gegner besiegt in $roundNum Runden!" 'Green'
                Show-Scene $cs -Force
                Start-Sleep -Milliseconds 600
            } else {
                $enemies = [math]::Ceiling(($killDmg - $totalDmg) / $eHP)
                $baseHP -= [math]::Max(1, $enemies * 2)
                $cs = New-Scene $w $h
                Add-SceneFrame $cs 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
                Add-SceneText $cs 4 5 "Runde $roundNum" 'Yellow'
                Add-SceneText $cs 4 6 "$enemies Gegner verbleiben" 'Red'
                Add-SceneText $cs 4 7 "Basis: $baseHP HP" 'Cyan'
                Show-Scene $cs -Force
                Start-Sleep -Milliseconds 400
            }
        }
        
        if ($baseHP -gt 0) {
            $reward = $wave * 20 + 10
            $gold += $reward
            $rs = New-Scene $w $h
            Add-SceneFrame $rs 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
            Add-SceneText $rs 4 5 "Welle $wave ueberstanden!" 'Green'
            Add-SceneText $rs 4 6 "+$reward G" 'Yellow'
            Show-Scene $rs -Force
            Start-Sleep -Milliseconds 600
        }
    }
    
    if ($baseHP -gt 0) {
        $fs = New-Scene $w $h
        Add-SceneFrame $fs 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
        Add-SceneText $fs 4 5 "SIEG! Alle $maxWaves Wellen ueberstanden!" 'Green'
        
        $insightMod = Get-StrategyInsightModifier
        $win = [math]::Min(1000, [math]::Floor(($gold + 100) * $insightMod))
        $bonus = $win - ($gold + 100)
        Set-Bankroll $win -TrackCasino
        Add-SceneText $fs 4 7 "+$win G gesammelt!" 'Green'
        if ($bonus -gt 0) { Add-SceneText $fs 4 8 "(+$bonus Strategy Insight)" 'Magenta' }
        Show-Scene $fs -Force
        
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
                Add-SceneText $fs 4 10 "[SKILL UP] Strategy Insight Level $($cp.Skills.StrategyInsight)!" 'Magenta'
                Show-Scene $fs -Force
                Save-CompanionState $cp
            }
        }
    } else {
        $ls = New-Scene $w $h
        Add-SceneFrame $ls 0 0 $w $h "TOWER DEFENSE" 'Cyan' -Double
        Add-SceneText $ls 4 5 "NIEDERLAGE! Welle $wave" 'Red'
        Show-Scene $ls -Force
        $stats.GamesPlayed++; if ($wave -gt $stats.BestWave) { $stats.BestWave = $wave }
        Set-StrategyStats "TowerDefense" $stats
    }
    Wait-Enter
}

} catch {
    Write-Host "[strategy-td] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
