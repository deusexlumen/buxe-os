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

# BUXE_OS v25.0 -- REDUCER UI ADAPTER (Phase 2)
# Rendert den Zustand des Combat-Reducers und formatiert Events fuer den Spieler.

function Format-CombatEvent($Event) {
    $d = $Event.Data
    switch ($Event.Topic) {
        "combat.stance"           { return "Stance gewechselt: $($d.Stance)" }
        "combat.rps"              {
            $moves = @{ "A" = "Angriff"; "V" = "Vanguard"; "S" = "Stealth" }
            $txt = "Du: $($moves[$d.Player]) | Gegner: $($moves[$d.Enemy])"
            if ($d.Winner -eq "Player") { return "$txt | Du gewinnst das Tempo!" }
            if ($d.Winner -eq "Enemy")  { return "$txt | Gegner gewinnt das Tempo!" }
            return "$txt | Gleichstand!"
        }
        "combat.hit"              {
            $extra = @()
            if ($d.Crit) { $extra += "KRITISCH" }
            if ($d.TypeMod -gt 1.0) { $extra += "Typ-Vorteil" }
            if ($d.TypeMod -lt 1.0) { $extra += "Typ-Nachteil" }
            if ($d.Charge) { $extra += "LADUNGS-ANGRIFF" }
            if ($d.Combo) { $extra += $d.Combo }
            $extraTxt = if ($extra.Count -gt 0) { " [" + ($extra -join ", ") + "]" } else { "" }
            $moveTxt = if ($d.Move) { " mit $($d.Move)" } else { "" }
            return "$($d.Attacker)$moveTxt trifft $($d.Target) fuer $($d.Damage) HP$extraTxt"
        }
        "combat.miss"             { return "$($d.Attacker) setzt $($d.Move) ein... und verfehlt!" }
        "combat.heal"             { return "$($d.Target) regeneriert $($d.Heal) HP" }
        "combat.counter"          { return "KONTER! $($d.Attacker) schlaegt zurueck fuer $($d.Damage) HP" }
        "combat.vanguard"         { return "$($d.Target) nimmt Vanguard-Stance ein" }
        "combat.skip"             { return "$($d.Target) ueberspringt den Zug ($($d.Reason))" }
        "combat.silenced"         { return "$($d.Target) ist silenced — Stealth blockiert" }
        "combat.fled"             { return "Flucht erfolgreich!" }
        "combat.flee.failed"      { return "Flucht fehlgeschlagen — der Gegner greift an!" }
        "combat.se.applied"       { return "$($d.Target) erhaelt $($d.Type) ($($d.Turns) Runden)" }
        "combat.se.intensify"     { return "$($d.Target)s $($d.Type) intensiviert sich" }
        "combat.se.interaction"   { return $d.Narrative }
        "combat.se.tick"          {
            if ($d.Damage) { return "$($d.Target) erleidet $($d.Type): -$($d.Damage) HP" }
            return "$($d.Target) regeneriert durch $($d.Type): +$($d.Heal) HP"
        }
        "combat.se.expired"       { return "$($d.Target)s $($d.Type) ist abgelaufen" }
        "combat.boss.warning"     { return "! BOSS-WARNUNG: $($d.Tell)" }
        "combat.boss.charge.mitigated" { return "Ladung abgefangen! Schaden massiv reduziert" }
        "combat.boss.charge.hit"  { return "LADUNGS-ANGRIFF trifft!" }
        "combat.limitbreak"       { return "LIMIT BREAK: $($d.Move)! $($d.Damage) HP Schaden" }
        "combat.limitbreak.failed"{ return "Limit Break nicht verfuegbar: $($d.Reason)" }
        default                   { return $null }
    }
}

function Show-CombatV3($State, $Events = @(), $companion = $null, $isBoss = $false, [switch]$Final) {
    $w = 70; $h = 24
    try {
        $w = [math]::Min(70, $Host.UI.RawUI.WindowSize.Width - 2)
        $h = [math]::Min(24, $Host.UI.RawUI.WindowSize.Height - 2)
    } catch {}
    $scene = New-Scene $w $h

    $p = $State.Player; $e = $State.Enemy
    $title = if ($isBoss) { "BOSS-KAMPF — Runde $($State.Round)" } else { "KAMPF — Runde $($State.Round)" }
    if ($Final) { $title = $title -replace "Runde.*", "ERGEBNIS" }
    Add-SceneFrame $scene 0 0 $w $h $title 'Cyan' -Double

    # Enemy line
    $eliteTag = if ($e.IsElite) { " [ELITE]" } else { "" }
    Add-SceneText $scene 2 2 "Gegner: $($e.Name)$eliteTag" $(if ($e.IsElite) { 'Yellow' } else { 'White' })
    Add-SceneBar $scene 2 3 ($w - 4) $e.HP $e.MaxHP $(if ($e.HP -lt $e.MaxHP * 0.25) { 'Red' } elseif ($e.HP -lt $e.MaxHP * 0.5) { 'Yellow' } else { 'Green' }) 'DarkGray'
    Add-SceneText $scene 2 4 "  $($e.HP)/$($e.MaxHP) HP | ATK:$($e.ATK) DEF:$($e.DEF) SPD:$($e.SPD)" 'Gray'

    # Player line
    Add-SceneText $scene 2 6 "$($p.Name) [Lv.$($p.Level)]" 'White'
    Add-SceneBar $scene 2 7 ($w - 4) $p.HP $p.MaxHP $(if ($p.HP -lt $p.MaxHP * 0.25) { 'Red' } elseif ($p.HP -lt $p.MaxHP * 0.5) { 'Yellow' } else { 'Green' }) 'DarkGray'
    Add-SceneText $scene 2 8 "  $($p.HP)/$($p.MaxHP) HP | ATK:$($p.ATK) DEF:$($p.DEF) SPD:$($p.SPD)" 'Gray'

    # Stance + Momentum
    $stance = Get-StanceModifier $State.PlayerStance
    $momText = if ($State.Momentum -gt 0) { " | Momentum: +$($State.Momentum)" } elseif ($State.Momentum -lt 0) { " | Gegner-Momentum: $([math]::Abs($State.Momentum))" } else { "" }
    Add-SceneText $scene 2 10 "Stance: [$($stance.Label)] $($State.PlayerStance)$momText" 'Cyan'
    Add-SceneText $scene 2 11 "  $(Get-StanceDescription $State.PlayerStance)" 'DarkCyan'

    # Combo history
    $y = 12
    if ($State.ComboHistory.Count -gt 0) {
        $comboText = "Combo: " + ($State.ComboHistory -join " -> ")
        Add-SceneText $scene 2 $y $comboText 'Magenta'
        $y++
    }

    # Status effects
    $allEffects = @()
    foreach ($se in $p.Effects) { $allEffects += @{ Target = $p.Name; Type = $se.Type; Turns = $se.Turns; Intensity = $se.Intensity } }
    foreach ($se in $e.Effects) { $allEffects += @{ Target = $e.Name; Type = $se.Type; Turns = $se.Turns; Intensity = $se.Intensity } }
    if ($allEffects.Count -gt 0) {
        Add-SceneText $scene 2 $y "Status:" 'Yellow'
        $y++
        foreach ($se in $allEffects) {
            $intTxt = if ($se.Intensity) { " I:$($se.Intensity)" } else { "" }
            $seText = switch ($se.Type) {
                "Burn"     { "[BURN] ($($se.Turns))$intTxt" }
                "Freeze"   { "[FREEZE] ($($se.Turns))" }
                "Poison"   { "[POISON] ($($se.Turns))$intTxt" }
                "Paralyze" { "[PARALYZE] ($($se.Turns))" }
                "Stun"     { "[STUN] ($($se.Turns))" }
                "Regen"    { "[REGEN] ($($se.Turns))" }
                "DEF-Down" { "[DEF-DOWN] ($($se.Turns))$intTxt" }
                "DEF-Up"   { "[DEF-UP] ($($se.Turns))" }
                "ATK-Up"   { "[ATK-UP] ($($se.Turns))" }
                "Crit-Up"  { "[CRIT-UP] ($($se.Turns))" }
                "Silence"  { "[SILENCE] ($($se.Turns))" }
                default    { "[$($se.Type)] ($($se.Turns))" }
            }
            Add-SceneText $scene 4 $y "$($se.Target) $seText" 'DarkYellow'
            $y++
            if ($y -ge $h - 8) { break }
        }
    }

    # Boss warning
    if ($isBoss -and $e.BossPattern -and $State.BossCharging) {
        $currentPhase = $e.BossPattern.Phases | Where-Object { ($e.HP / $e.MaxHP * 100) -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase -and $currentPhase.Tell) {
            Add-SceneText $scene 2 ($h - 7) "! $($currentPhase.Tell)" 'Magenta'
        }
    }

    # Events log
    $logY = $h - 6
    if ($Events.Count -gt 0) {
        Add-SceneText $scene 2 $logY "---" 'DarkGray'
        $logY++
        $shown = 0
        foreach ($ev in $Events) {
            $line = Format-CombatEvent $ev
            if (-not $line) { continue }
            Add-SceneText $scene 2 $logY "> $line" 'White'
            $logY++; $shown++
            if ($logY -ge $h - 1) { break }
        }
    }

    # Action menu (nur wenn Kampf aktiv)
    if (-not $Final -and $State.Phase -eq "Active") {
        Add-SceneText $scene 2 ($h - 2) "[A]ngriff [V]anguard [S]tealth [M]ove [Q] Flucht" 'White'
        Add-SceneText $scene 2 ($h - 1) "[F1] Aggressiv [F2] Defensiv [F3] Speed [F4] Balanced" 'DarkGray'
    }

    Show-Scene $scene -Force
}

} catch {
    Write-Host "[pet/combat-ui] CRITICAL ERROR: $_" -ForegroundColor Red
}
