# BUXE_OS v24.12 -- PET COMBAT UI v2.1
# TUI-Kampf-Scene: HP-Bars, Stance, Status, Combo-Historie, Log, Aktionen.

try {

function Show-CombatScene($playerPet, $enemy, $companion, $combatState, $playerStats, $enemyStats, $isBoss) {
    $w = 70; $h = 22
    try {
        $w = [math]::Min(70, $Host.UI.RawUI.WindowSize.Width - 2)
        $h = [math]::Min(22, $Host.UI.RawUI.WindowSize.Height - 2)
    } catch {}
    $scene = New-Scene $w $h

    $title = if ($isBoss) { "BOSS-KAMPF — Runde $($combatState.Round)" } else { "KAMPF — Runde $($combatState.Round)" }
    Add-SceneFrame $scene 0 0 $w $h $title 'Cyan' -Double

    # Enemy line
    $eliteTag = if ($enemy.IsElite) { " [ELITE]" } else { "" }
    Add-SceneText $scene 2 2 "Gegner: $($enemy.Name)$eliteTag" $(if ($enemy.IsElite) { 'Yellow' } else { 'White' })
    Add-SceneBar $scene 2 3 ($w - 4) $enemy.HP $enemyStats.MaxHP $(if ($enemy.HP -lt $enemyStats.MaxHP * 0.25) { 'Red' } elseif ($enemy.HP -lt $enemyStats.MaxHP * 0.5) { 'Yellow' } else { 'Green' }) 'DarkGray'
    Add-SceneText $scene 2 4 "  $($enemy.HP)/$($enemyStats.MaxHP) HP | ATK:$($enemyStats.ATK) DEF:$($enemyStats.DEF) SPD:$($enemyStats.SPD)" 'Gray'

    # Player line
    Add-SceneText $scene 2 6 "$($playerPet.Name) [Lv.$($playerPet.Level)]" 'White'
    Add-SceneBar $scene 2 7 ($w - 4) $playerPet.HP $playerStats.MaxHP $(if ($playerPet.HP -lt $playerStats.MaxHP * 0.25) { 'Red' } elseif ($playerPet.HP -lt $playerStats.MaxHP * 0.5) { 'Yellow' } else { 'Green' }) 'DarkGray'
    Add-SceneText $scene 2 8 "  $($playerPet.HP)/$($playerStats.MaxHP) HP | ATK:$($playerStats.ATK) DEF:$($playerStats.DEF) SPD:$($playerStats.SPD)" 'Gray'

    # Stance
    $stance = Get-StanceModifier $combatState.PlayerStance
    Add-SceneText $scene 2 10 "Stance: [$($stance.Label)] $($combatState.PlayerStance)" 'Cyan'
    Add-SceneText $scene 2 11 "  $(Get-StanceDescription $combatState.PlayerStance)" 'DarkCyan'

    # Combo history
    if ($combatState.ComboHistory.Count -gt 0) {
        $comboText = "Combo: " + ($combatState.ComboHistory -join " -> ")
        Add-SceneText $scene 2 12 $comboText 'Magenta'
    }

    # Status effects
    $y = 13
    if ($combatState.StatusEffects.Count -gt 0) {
        Add-SceneText $scene 2 $y "Status:" 'Yellow'
        $y++
        foreach ($se in $combatState.StatusEffects) {
            $seText = switch ($se.Type) {
                "Burn"     { "[BURN] ($($se.Turns))" }
                "Freeze"   { "[FREEZE] ($($se.Turns))" }
                "Poison"   { "[POISON] ($($se.Turns))" }
                "Paralyze" { "[PARALYZE] ($($se.Turns))" }
                "Stun"     { "[STUN] ($($se.Turns))" }
                "Regen"    { "[REGEN] ($($se.Turns))" }
                "DEF-Down" { "[DEF-DOWN] ($($se.Turns))" }
                "DEF-Up"   { "[DEF-UP] ($($se.Turns))" }
                "ATK-Up"   { "[ATK-UP] ($($se.Turns))" }
                "Crit-Up"  { "[CRIT-UP] ($($se.Turns))" }
                "Silence"  { "[SILENCE] ($($se.Turns))" }
                default    { "[$($se.Type)] ($($se.Turns))" }
            }
            $targetText = if ($se.Target -eq "player") { "$($playerPet.Name)" } else { "$($enemy.Name)" }
            Add-SceneText $scene 4 $y "$targetText $seText" 'DarkYellow'
            $y++
            if ($y -ge $h - 6) { break }
        }
    }

    # Boss warning
    if ($isBoss -and $enemy.BossPattern) {
        $currentPhase = $enemy.BossPattern.Phases | Where-Object { ($enemy.HP / $enemy.MaxHP * 100) -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase -and $currentPhase.Tell -and $currentPhase.WarnTurns -gt 0) {
            Add-SceneText $scene 2 ($h - 6) "! $($currentPhase.Tell)" 'Magenta'
        }
    }

    # Action menu
    Add-SceneText $scene 2 ($h - 5) "[A]ngriff  [V]anguard  [S]tealth  [Q] Flucht" 'White'
    Add-SceneText $scene 2 ($h - 4) "[F1] Aggressiv  [F2] Defensiv  [F3] Speed  [F4] Balanced" 'DarkGray'

    Show-Scene $scene -Force
}

} catch {
    Write-Host "[pet/combat-ui] CRITICAL ERROR: $_" -ForegroundColor Red
}
