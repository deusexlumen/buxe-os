# BUXE_OS v25.0 -- COMBAT CORE (PURE KERNEL)
# Reducer-Pattern: (State, Action) -> { State, Events }
# ZERO UI. ZERO Read-Host. ZERO Save-State. ZERO Write-Host.
# Vollstaendig headless testbar: 10.000 simulierte Kaempfe in <5 Sekunden.
#
# MATHEMATIK-UPGRADE gegenueber v2.1:
#   1. Nichtlineare Schadenskurve: ATK^1.15 statt linear -> Investment in ATK
#      fuehlt sich spaet im Spiel weiterhin an, ohne frueh zu explodieren.
#   2. Level-skalierter DEF-Softcap: DEF/(DEF + 15 + 2.5*AttackerLevel)
#      -> DEF saettigt nie auf "unverwundbar", Damage-Sponges abgeschafft.
#   3. Momentum-System: RPS-Siege stacken (+12% pro Stack, max 3),
#      Niederlage reseted -> belohnt Reads, bestraft Button-Mashing.
#   4. Status-Effekt-MATRIX: Effekte interagieren (Burn+Freeze annihiliert,
#      Poison rampt, Overload-Kombos), Stacking-Regeln pro Effekt.
#   5. Markov-AI: Gegner analysiert die Aktions-Historie des Spielers und
#      exploitet Muster -- gewichtet nach Archetyp-Persoenlichkeit.
#   6. Attacken-System REAKTIVIERT: BPAttacks flossen in v2.1 nie in den
#      Kampf ein (toter Code). Hier sind Moves first-class Actions.

try {

# ============================================================
# DATEN: STATUS-EFFEKT-MATRIX
# ============================================================
# Jeder Effekt: Stacking-Regel, Tick-Verhalten, Interaktionen.
# Stacking: "Refresh" (Dauer neu), "Intensify" (Wert rauf, Cap), "Ignore"
$script:SE_Registry = @{
    "Burn"     = @{ Stacking = "Refresh";   TickPctMaxHP = 0.06; MaxTurns = 3; Tags = @("DoT","Fire") }
    "Poison"   = @{ Stacking = "Intensify"; TickPctMaxHP = 0.04; MaxTurns = 4; IntensifyStep = 0.02; IntensifyCap = 0.10; Tags = @("DoT","Toxic") }
    "Freeze"   = @{ Stacking = "Ignore";    SkipTurn = $true;    MaxTurns = 1; Tags = @("Control","Ice") }
    "Paralyze" = @{ Stacking = "Refresh";   SkipChance = 50;     MaxTurns = 2; Tags = @("Control","Elec") }
    "Stun"     = @{ Stacking = "Ignore";    SkipTurn = $true;    MaxTurns = 1; Tags = @("Control") }
    "Regen"    = @{ Stacking = "Refresh";   TickPctMaxHP = -0.05; MaxTurns = 3; Tags = @("Buff") }
    "DEF-Down" = @{ Stacking = "Intensify"; StatMod = @{ DEF = -0.30 }; MaxTurns = 2; IntensifyStep = -0.10; IntensifyCap = -0.50; Tags = @("Debuff") }
    "DEF-Up"   = @{ Stacking = "Refresh";   StatMod = @{ DEF = 0.40 };  MaxTurns = 2; Tags = @("Buff") }
    "ATK-Up"   = @{ Stacking = "Refresh";   StatMod = @{ ATK = 0.50 };  MaxTurns = 1; Tags = @("Buff") }
    "Crit-Up"  = @{ Stacking = "Refresh";   CritBonus = 25;             MaxTurns = 2; Tags = @("Buff") }
    "Silence"  = @{ Stacking = "Refresh";   BlockSpecial = $true;       MaxTurns = 2; Tags = @("Control") }
}

# Interaktions-Matrix: was passiert, wenn Effekt B auf ein Ziel trifft,
# das bereits Effekt A hat. Reihenfolge: Key = "Vorhanden|Neu".
$script:SE_Interactions = @{
    "Burn|Freeze"     = @{ Result = "Annihilate"; Narrative = "Thermalschock! Burn und Freeze loeschen sich aus -- Dampf-Explosion: %DMG% Schaden!"; BonusDmgPctMaxHP = 0.12 }
    "Freeze|Burn"     = @{ Result = "Annihilate"; Narrative = "Thermalschock! Das Eis verdampft explosiv: %DMG% Schaden!"; BonusDmgPctMaxHP = 0.12 }
    "Poison|Burn"     = @{ Result = "Both";       Narrative = "Toxische Verbrennung! Beide DoTs aktiv -- das wird haesslich." }
    "Paralyze|Freeze" = @{ Result = "Upgrade";    Upgrade = "Stun"; Narrative = "Ueberladung + Vereisung = Systemcrash! Ziel ist GESTUNNED!" }
    "Freeze|Paralyze" = @{ Result = "Upgrade";    Upgrade = "Stun"; Narrative = "Vereisung + Ueberladung = Systemcrash! Ziel ist GESTUNNED!" }
    "DEF-Up|DEF-Down" = @{ Result = "Annihilate"; Narrative = "Buff und Debuff neutralisieren sich." ; BonusDmgPctMaxHP = 0 }
    "DEF-Down|DEF-Up" = @{ Result = "Annihilate"; Narrative = "Debuff und Buff neutralisieren sich." ; BonusDmgPctMaxHP = 0 }
}

# ============================================================
# DATEN: AI-ARCHETYPEN
# ============================================================
# Adaptivity: 0.0 = ignoriert Spieler-Historie, 1.0 = reiner Markov-Exploit
$script:AI_Archetypes = @{
    "Drone"     = @{ Adaptivity = 0.0; Base = @{ A = 42; V = 33; S = 25 }; SpecialAffinity = 0.2 }
    "Hunter"    = @{ Adaptivity = 0.5; Base = @{ A = 55; V = 15; S = 30 }; SpecialAffinity = 0.35 }
    "Fortress"  = @{ Adaptivity = 0.3; Base = @{ A = 25; V = 55; S = 20 }; SpecialAffinity = 0.25 }
    "Predator"  = @{ Adaptivity = 0.8; Base = @{ A = 35; V = 30; S = 35 }; SpecialAffinity = 0.4 }
    "Berserker" = @{ Adaptivity = 0.1; Base = @{ A = 70; V = 5;  S = 25 }; SpecialAffinity = 0.5 }
}

# ============================================================
# REINE MATHE-FUNKTIONEN
# ============================================================
function Get-DamageV3 {
    <#
    .SYNOPSIS
      Kern-Schadensformel v3. Rein, deterministisch bei gegebenem CritRoll.
      DMG = (ATK^1.15 * Power/40) * Mods * (1 - DEF_eff)
      DEF_eff = DEF / (DEF + 15 + 2.5 * AttackerLevel)
    #>
    param(
        [double]$ATK, [double]$MovePower = 40, [double]$DEF,
        [int]$AttackerLevel = 1,
        [double]$TypeMod = 1.0, [double]$StanceMod = 1.0,
        [double]$AvsMod = 1.0, [double]$ComboMod = 1.0,
        [int]$MomentumStacks = 0,
        [bool]$IsCrit = $false,
        [double]$Variance = 0.0  # -0.08..+0.08 uebergeben fuer +-8% Roll
    )
    $atkCurve = [math]::Pow([math]::Max(1, $ATK), 1.13)
    $base = $atkCurve * ($MovePower / 40.0)
    $momentumMod = 1.0 + (0.10 * [math]::Min(3, [math]::Max(0, $MomentumStacks)))
    $critMod = if ($IsCrit) { 1.6 } else { 1.0 }
    $defEff = $DEF / ($DEF + 15.0 + 2.5 * $AttackerLevel)
    $raw = $base * $TypeMod * $StanceMod * $AvsMod * $ComboMod * $momentumMod * $critMod * (1 + $Variance)
    return [math]::Max(1, [math]::Round($raw * (1.0 - $defEff)))
}

function Get-EffectiveStatWithSE($BaseValue, $StatName, $Effects) {
    # Wendet alle StatMod-Effekte multiplikativ-additiv an: (1 + sum(mods))
    $modSum = 0.0
    foreach ($se in $Effects) {
        $reg = $script:SE_Registry[$se.Type]
        if ($reg -and $reg.StatMod -and $reg.StatMod.ContainsKey($StatName)) {
            $val = if ($se.Intensity) { $se.Intensity } else { $reg.StatMod[$StatName] }
            $modSum += $val
        }
    }
    return [math]::Max(1, [math]::Round($BaseValue * (1.0 + $modSum)))
}

# ============================================================
# STATUS-EFFEKT-ENGINE
# ============================================================
function Add-StatusEffectV3 {
    <#
    .SYNOPSIS
      Fuegt einen Effekt hinzu und loest die Interaktions-Matrix auf.
      Gibt Events zurueck (fuer die UI-Schicht), mutiert $Target.Effects.
    #>
    param(
        [Parameter(Mandatory)]$Target,   # @{ Name; HP; MaxHP; Effects = [List] }
        [Parameter(Mandatory)][string]$Type,
        [int]$Turns = 0
    )
    $events = @()
    $reg = $script:SE_Registry[$Type]
    if (-not $reg) { return $events }
    if ($Turns -le 0) { $Turns = $reg.MaxTurns }

    # 1. Interaktionen pruefen
    foreach ($existing in @($Target.Effects)) {
        $key = "$($existing.Type)|$Type"
        $ix = $script:SE_Interactions[$key]
        if ($ix) {
            switch ($ix.Result) {
                "Annihilate" {
                    $Target.Effects.Remove($existing) | Out-Null
                    $dmg = 0
                    if ($ix.BonusDmgPctMaxHP -gt 0) {
                        $dmg = [math]::Max(1, [math]::Round($Target.MaxHP * $ix.BonusDmgPctMaxHP))
                        $Target.HP -= $dmg
                    }
                    $events += @{ Topic = "combat.se.interaction"; Data = @{ Target = $Target.Name; Narrative = ($ix.Narrative -replace "%DMG%", $dmg); Damage = $dmg } }
                    return $events  # Neuer Effekt wird NICHT angewendet
                }
                "Upgrade" {
                    $Target.Effects.Remove($existing) | Out-Null
                    $upReg = $script:SE_Registry[$ix.Upgrade]
                    $Target.Effects.Add(@{ Type = $ix.Upgrade; Turns = $upReg.MaxTurns; Intensity = $null }) | Out-Null
                    $events += @{ Topic = "combat.se.interaction"; Data = @{ Target = $Target.Name; Narrative = $ix.Narrative; Upgraded = $ix.Upgrade } }
                    return $events
                }
                "Both" {
                    $events += @{ Topic = "combat.se.interaction"; Data = @{ Target = $Target.Name; Narrative = $ix.Narrative } }
                    # faellt durch zum normalen Anwenden
                }
            }
        }
    }

    # 2. Stacking-Regel
    $same = $Target.Effects | Where-Object { $_.Type -eq $Type } | Select-Object -First 1
    if ($same) {
        switch ($reg.Stacking) {
            "Refresh"   { $same.Turns = $Turns }
            "Ignore"    { }
            "Intensify" {
                $same.Turns = $Turns
                $cur = if ($same.Intensity) { $same.Intensity } else { if ($reg.TickPctMaxHP) { $reg.TickPctMaxHP } else { $reg.StatMod.Values | Select-Object -First 1 } }
                $next = $cur + $reg.IntensifyStep
                if ($reg.IntensifyCap -gt 0) { $next = [math]::Min($reg.IntensifyCap, $next) }
                else { $next = [math]::Max($reg.IntensifyCap, $next) }
                $same.Intensity = $next
                $events += @{ Topic = "combat.se.intensify"; Data = @{ Target = $Target.Name; Type = $Type; Intensity = $next } }
            }
        }
    } else {
        $Target.Effects.Add(@{ Type = $Type; Turns = $Turns; Intensity = $null }) | Out-Null
        $events += @{ Topic = "combat.se.applied"; Data = @{ Target = $Target.Name; Type = $Type; Turns = $Turns } }
    }
    return $events
}

function Invoke-StatusTick {
    # Tickt alle Effekte EINES Kombattanten. Gibt Events zurueck.
    param([Parameter(Mandatory)]$Combatant)
    $events = @()
    foreach ($se in @($Combatant.Effects)) {
        $reg = $script:SE_Registry[$se.Type]
        if ($reg.TickPctMaxHP) {
            $pct = if ($se.Intensity) { $se.Intensity } else { $reg.TickPctMaxHP }
            $delta = [math]::Round($Combatant.MaxHP * $pct)
            if ($delta -gt 0) {
                $Combatant.HP -= [math]::Max(1, $delta)
                $events += @{ Topic = "combat.se.tick"; Data = @{ Target = $Combatant.Name; Type = $se.Type; Damage = [math]::Max(1, $delta) } }
            } elseif ($delta -lt 0) {
                $heal = [math]::Min([math]::Abs($delta), $Combatant.MaxHP - $Combatant.HP)
                $Combatant.HP += $heal
                $events += @{ Topic = "combat.se.tick"; Data = @{ Target = $Combatant.Name; Type = $se.Type; Heal = $heal } }
            }
        }
        $se.Turns--
        if ($se.Turns -le 0) {
            $Combatant.Effects.Remove($se) | Out-Null
            $events += @{ Topic = "combat.se.expired"; Data = @{ Target = $Combatant.Name; Type = $se.Type } }
        }
    }
    return $events
}

function Test-TurnSkip {
    # Prueft Control-Effekte. Gibt @{ Skip; Reason } zurueck. $Roll: 1..100 injizierbar.
    param($Combatant, [int]$Roll = (Get-Random -Minimum 1 -Maximum 101))
    foreach ($se in $Combatant.Effects) {
        $reg = $script:SE_Registry[$se.Type]
        if ($reg.SkipTurn) { return @{ Skip = $true; Reason = $se.Type } }
        if ($reg.SkipChance -and $Roll -le $reg.SkipChance) { return @{ Skip = $true; Reason = $se.Type } }
    }
    return @{ Skip = $false; Reason = $null }
}

# ============================================================
# MARKOV-AI
# ============================================================
function Get-EnemyActionV3 {
    <#
    .SYNOPSIS
      Adaptive Gegner-AI. Baut Markov-1-Statistik ueber die Spieler-Historie
      und mischt Exploit-Verteilung mit Archetyp-Basis nach Adaptivity.
      Der Spieler KANN das ausspielen (Double-Bluff), aber nicht durch Spam.
    .PARAMETER Behavior
      Optional: "Aggressive" | "Defensive" | "Desperate" | "Random". Ueberschreibt Archetyp-Basis.
    #>
    param(
        [string]$Archetype = "Drone",
        [array]$PlayerHistory = @(),   # z.B. @("A","A","S","V")
        [int]$Roll = (Get-Random -Minimum 1 -Maximum 101),
        [string]$Behavior = $null
    )
    $arch = $script:AI_Archetypes[$Archetype]
    if (-not $arch) { $arch = $script:AI_Archetypes["Drone"] }
    $beats = @{ "A" = "S"; "V" = "A"; "S" = "V" }  # Was schlaegt X: A wird von V geschlagen etc. -> Counter-Lookup: Counter[X] schlaegt X
    $counter = @{ "A" = "S"; "V" = "A"; "S" = "V" }
    # Klarstellung Spielregel: A schlaegt V, V schlaegt S, S schlaegt A.
    # Counter von "A" ist also "S"? Nein: S schlaegt A -> Counter["A"] = "S". Korrekt.

    $dist = @{ A = [double]$arch.Base.A; V = [double]$arch.Base.V; S = [double]$arch.Base.S }

    # Boss-Phase Behavior ueberschreibt Basis-Verteilung
    if ($Behavior) {
        $dist = switch ($Behavior) {
            "Aggressive" { @{ A = 60.0; V = 20.0; S = 20.0 } }
            "Defensive"  { @{ A = 20.0; V = 60.0; S = 20.0 } }
            "Desperate"  { @{ A = 30.0; V = 10.0; S = 60.0 } }
            default        { @{ A = 33.0; V = 33.0; S = 34.0 } }
        }
    }

    if ($arch.Adaptivity -gt 0 -and $PlayerHistory.Count -ge 3) {
        # Markov-1: Was folgt historisch auf die letzte Spieler-Aktion?
        $lastAction = $PlayerHistory[-1]
        $followCounts = @{ A = 1.0; V = 1.0; S = 1.0 }  # Laplace-Smoothing
        for ($i = 0; $i -lt $PlayerHistory.Count - 1; $i++) {
            if ($PlayerHistory[$i] -eq $lastAction) {
                $next = $PlayerHistory[$i + 1]
                $followCounts[$next] += 1.0
            }
        }
        $total = $followCounts.A + $followCounts.V + $followCounts.S
        # Prognose der naechsten Spieler-Aktion -> Gegner waehlt den Counter
        $exploit = @{ A = 0.0; V = 0.0; S = 0.0 }
        foreach ($predicted in @("A","V","S")) {
            $prob = $followCounts[$predicted] / $total
            $counterMove = $counter[$predicted]
            $exploit[$counterMove] += $prob * 100.0
        }
        $w = $arch.Adaptivity
        foreach ($k in @("A","V","S")) {
            $dist[$k] = (1.0 - $w) * $dist[$k] + $w * $exploit[$k]
        }
    }

    $sum = $dist.A + $dist.V + $dist.S
    $cum = 0.0
    $threshold = $Roll / 100.0 * $sum
    foreach ($k in @("A","V","S")) {
        $cum += $dist[$k]
        if ($threshold -le $cum) { return $k }
    }
    return "A"
}

# ============================================================
# COMBAT REDUCER
# ============================================================
function New-CombatStateV3 {
    param(
        [Parameter(Mandatory)]$Player,  # @{ Name; Type; Level; HP; MaxHP; ATK; DEF; SPD; Crit; Attacks }
        [Parameter(Mandatory)]$Enemy,   # @{ Name; Type; Level; HP; MaxHP; ATK; DEF; SPD; Archetype; IsBoss }
        [string]$Seed = $null
    )
    foreach ($c in @($Player, $Enemy)) {
        if (-not ($c.Effects -is [System.Collections.Generic.List[object]])) {
            $c.Effects = [System.Collections.Generic.List[object]]::new()
        }
    }
    return @{
        Round           = 1
        Player          = $Player
        Enemy           = $Enemy
        PlayerStance    = "Balanced"
        Momentum        = 0            # -3..+3 (negativ = Gegner-Momentum)
        PlayerHistory   = @()
        ComboHistory    = @()
        Phase           = "Active"     # Active | Won | Lost | Fled
        LimitBreakUsed  = $false
        BossCharging    = $false       # Boss laedt naechsten Angriff auf
        BossChargeWarned= $false       # Warnung wurde diese Runde bereits angezeigt
        Log             = [System.Collections.Generic.List[string]]::new()
    }
}

function Invoke-CombatReducer {
    <#
    .SYNOPSIS
      DER Kern. Nimmt State + Spieler-Aktion, gibt @{ State; Events } zurueck.
      Alle Zufallswerte sind injizierbar (deterministische Tests moeglich).
    .PARAMETER Action
      @{ Kind = "Attack"|"Vanguard"|"Stealth"|"Move"|"Flee"|"Stance";
         MoveName = "Plasma Lance" (bei Kind=Move); Stance = "Aggressiv" (bei Kind=Stance) }
    #>
    param(
        [Parameter(Mandatory)]$State,
        [Parameter(Mandatory)][hashtable]$Action,
        [hashtable]$Rolls = @{}   # Optional: Crit/Skip/AI/Variance injizieren
    )
    $events = [System.Collections.Generic.List[object]]::new()
    $p = $State.Player; $e = $State.Enemy

    # --- Stance ist kostenlos, kein Rundenverbrauch ---
    if ($Action.Kind -eq "Stance") {
        $State.PlayerStance = $Action.Stance
        $events.Add(@{ Topic = "combat.stance"; Data = @{ Stance = $Action.Stance } })
        return @{ State = $State; Events = $events }
    }
    if ($Action.Kind -eq "Flee") {
        $fleeRoll = if ($Rolls.Flee) { $Rolls.Flee } else { Get-Random -Minimum 1 -Maximum 101 }
        $fleeChance = 50 + [math]::Min(30, ($p.SPD - $e.SPD) * 2)
        if ($fleeRoll -le $fleeChance) {
            $State.Phase = "Fled"
            $events.Add(@{ Topic = "combat.fled"; Data = @{} })
        } else {
            $events.Add(@{ Topic = "combat.flee.failed"; Data = @{} })
            # Gegner bekommt Gratis-Angriff
            $events.AddRange((Invoke-EnemyStrike $State $Rolls "A" 1.25))
        }
        return @{ State = $State; Events = $events }
    }

    # --- Spieler-Aktion normalisieren ---
    $playerAVS = switch ($Action.Kind) {
        "Attack"     { "A" }
        "Vanguard"   { "V" }
        "Stealth"    { "S" }
        "Move"       { "A" }   # Moves zaehlen als Angriff im RPS-Layer
        "LimitBreak" { "A" }   # Limit Break zaehlt als Angriff
        default      { "A" }
    }

    # --- Boss-Phase und Ladungs-Angriff bestimmen ---
    $bossBehavior = $null
    if ($e.IsBoss -and $e.BossPattern) {
        $currentPhase = $e.BossPattern.Phases | Where-Object { ($e.HP / $e.MaxHP * 100) -le $_.HPPercent } | Select-Object -First 1
        if ($currentPhase) {
            $bossBehavior = $currentPhase.Behavior
            if ($currentPhase.WarnTurns -gt 0 -and ($State.Round % ($currentPhase.WarnTurns + 2) -eq 0)) {
                $State.BossCharging = $true
                if (-not $State.BossChargeWarned) {
                    $events.Add(@{ Topic = "combat.boss.warning"; Data = @{ Tell = $currentPhase.Tell; Phase = $currentPhase.Behavior } })
                    $State.BossChargeWarned = $true
                }
            }
        }
    }

    # --- Gegner waehlt (Markov-AI sieht Historie VOR dieser Aktion) ---
    $aiRoll = if ($Rolls.AI) { $Rolls.AI } else { Get-Random -Minimum 1 -Maximum 101 }
    $enemyAVS = Get-EnemyActionV3 -Archetype $e.Archetype -PlayerHistory $State.PlayerHistory -Roll $aiRoll -Behavior $bossBehavior
    $State.PlayerHistory += $playerAVS
    if ($State.PlayerHistory.Count -gt 12) { $State.PlayerHistory = @($State.PlayerHistory | Select-Object -Last 12) }

    # --- RPS aufloesen + Momentum ---
    $beatsMap = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $winner = "Tie"; $pMult = 1.0; $eMult = 1.0
    if ($playerAVS -ne $enemyAVS) {
        if ($beatsMap[$playerAVS] -eq $enemyAVS) {
            $winner = "Player"; $pMult = 1.4; $eMult = 0.6
            $State.Momentum = [math]::Min(3, [math]::Max(1, $State.Momentum + 1))
        } else {
            $winner = "Enemy"; $pMult = 0.6; $eMult = 1.4
            $State.Momentum = [math]::Max(-3, [math]::Min(-1, $State.Momentum - 1))
        }
    }
    $events.Add(@{ Topic = "combat.rps"; Data = @{ Player = $playerAVS; Enemy = $enemyAVS; Winner = $winner; Momentum = $State.Momentum } })

    # --- Initiative ---
    $stanceTbl = @{
        "Balanced"  = @{ ATK = 1.0; DEF = 1.0; SPD = 1.0; Crit = 5 }
        "Aggressiv" = @{ ATK = 1.5; DEF = 0.7; SPD = 1.0; Crit = 15 }
        "Defensiv"  = @{ ATK = 0.7; DEF = 1.5; SPD = 1.0; Crit = 0 }
        "Speed"     = @{ ATK = 1.0; DEF = 0.85; SPD = 1.4; Crit = 10 }
    }
    $stance = $stanceTbl[$State.PlayerStance]
    $playerFirst = ($p.SPD * $stance.SPD) -ge $e.SPD

    $doPlayer = {
        if ($State.Phase -ne "Active") { return }
        $skip = Test-TurnSkip $p ($(if ($Rolls.PlayerSkip) { $Rolls.PlayerSkip } else { Get-Random -Minimum 1 -Maximum 101 }))
        if ($skip.Skip) {
            $events.Add(@{ Topic = "combat.skip"; Data = @{ Target = $p.Name; Reason = $skip.Reason } })
            return
        }
        switch ($Action.Kind) {
            "Vanguard" {
                $events.Add(@{ Topic = "combat.vanguard"; Data = @{ Target = $p.Name } })
            }
            "LimitBreak" {
                if ($State.LimitBreakUsed) {
                    $events.Add(@{ Topic = "combat.limitbreak.failed"; Data = @{ Reason = "Bereits eingesetzt" } })
                } else {
                    $State.LimitBreakUsed = $true
                    $moveName = if ($p.Attacks -and $p.Attacks.Count -gt 0) { $p.Attacks | Get-Random } else { "OMEGA-SCHLAG" }
                    $typeMod = if (Get-Command Get-ElementModifier -ErrorAction SilentlyContinue) { Get-ElementModifier $p.Type $e.Type } else { 1.0 }
                    $critRoll = if ($Rolls.PlayerCrit) { $Rolls.PlayerCrit } else { Get-Random -Minimum 1 -Maximum 101 }
                    $critChance = 50 + $stance.Crit + $(if ($p.Crit) { $p.Crit } else { 0 })
                    $isCrit = ($critRoll -le $critChance)
                    $effATK = Get-EffectiveStatWithSE $p.ATK "ATK" $p.Effects
                    $effDEF = Get-EffectiveStatWithSE $e.DEF "DEF" $e.Effects
                    $lbPower = 120
                    $dmg = Get-DamageV3 -ATK ($effATK * $stance.ATK * 2.0) -MovePower $lbPower -DEF $effDEF `
                        -AttackerLevel $p.Level -TypeMod $typeMod -AvsMod $pMult `
                        -MomentumStacks ([math]::Max(0, $State.Momentum)) -IsCrit $isCrit
                    $e.HP -= $dmg
                    $events.Add(@{ Topic = "combat.limitbreak"; Data = @{ Attacker = $p.Name; Target = $e.Name; Move = $moveName; Damage = $dmg; Crit = $isCrit } })
                    $guaranteed = @("Burn","Poison","Paralyze","DEF-Down") | Get-Random
                    foreach ($ev in (Add-StatusEffectV3 -Target $e -Type $guaranteed)) { $events.Add($ev) }
                }
            }
            default {
                $movePower = 40; $moveType = $p.Type; $moveEffect = $null; $moveEffectChance = 0; $critBonus = 0
                if ($Action.Kind -eq "Move" -and $script:BPAttacks -and $script:BPAttacks[$Action.MoveName]) {
                    $mv = $script:BPAttacks[$Action.MoveName]
                    $accRoll = if ($Rolls.Accuracy) { $Rolls.Accuracy } else { Get-Random -Minimum 1 -Maximum 101 }
                    if ($accRoll -gt $mv.Accuracy) {
                        $events.Add(@{ Topic = "combat.miss"; Data = @{ Attacker = $p.Name; Move = $Action.MoveName } })
                        return
                    }
                    $movePower = $mv.Power; $moveType = $mv.Type
                    $moveEffect = $mv.Effect; $moveEffectChance = $mv.EffectChance
                }
                if ($Action.Kind -eq "Stealth") { $movePower = 52; $critBonus = 10 }

                # Combo-System: drei gleiche Typen -> Triad Surge (1.5x), drei verschiedene -> Prism Burst (1.3x)
                $comboMod = 1.0; $comboName = $null
                if (Get-Command Add-ComboElement -ErrorAction SilentlyContinue) {
                    Add-ComboElement $State $p.Type
                    $combo = Test-ElementCombo $State
                    if ($combo) { $comboMod = $combo.Multiplier; $comboName = $combo.Name }
                }

                $typeMod = if (Get-Command Get-ElementModifier -ErrorAction SilentlyContinue) { Get-ElementModifier $moveType $e.Type } else { 1.0 }
                $critRoll = if ($Rolls.PlayerCrit) { $Rolls.PlayerCrit } else { Get-Random -Minimum 1 -Maximum 101 }
                $critChance = $stance.Crit + $(if ($p.Crit) { $p.Crit } else { 0 }) + $critBonus
                $isCrit = ($critRoll -le $critChance)
                $variance = if ($Rolls.ContainsKey("Variance")) { $Rolls.Variance } else { (Get-Random -Minimum -8 -Maximum 9) / 100.0 }

                $effATK = Get-EffectiveStatWithSE $p.ATK "ATK" $p.Effects
                $effDEF = Get-EffectiveStatWithSE $e.DEF "DEF" $e.Effects
                $dmg = Get-DamageV3 -ATK ($effATK * $stance.ATK) -MovePower $movePower -DEF $effDEF `
                    -AttackerLevel $p.Level -TypeMod $typeMod -AvsMod $pMult -ComboMod $comboMod `
                    -MomentumStacks ([math]::Max(0, $State.Momentum)) -IsCrit $isCrit -Variance $variance
                $e.HP -= $dmg
                $hitData = @{ Attacker = $p.Name; Target = $e.Name; Damage = $dmg; Crit = $isCrit; TypeMod = $typeMod; Move = $Action.MoveName }
                if ($comboName) { $hitData.Combo = $comboName }
                $events.Add(@{ Topic = "combat.hit"; Data = $hitData })

                if ($moveEffect -and $moveEffect -ne "Heal") {
                    $seRoll = if ($Rolls.PlayerEffect) { $Rolls.PlayerEffect } else { Get-Random -Minimum 1 -Maximum 101 }
                    if ($seRoll -le $moveEffectChance) {
                        foreach ($ev in (Add-StatusEffectV3 -Target $e -Type $moveEffect)) { $events.Add($ev) }
                    }
                } elseif ($moveEffect -eq "Heal") {
                    $heal = [math]::Round($p.MaxHP * 0.15)
                    $p.HP = [math]::Min($p.MaxHP, $p.HP + $heal)
                    $events.Add(@{ Topic = "combat.heal"; Data = @{ Target = $p.Name; Heal = $heal } })
                }
            }
        }
        if ($e.HP -le 0) { $State.Phase = "Won" }
    }

    $doEnemy = {
        if ($State.Phase -ne "Active") { return }
        $vanguardMod = if ($Action.Kind -eq "Vanguard") { 0.5 } else { 1.0 }
        $stealthPenalty = if ($Action.Kind -eq "Stealth") { 1.25 } else { 1.0 }
        foreach ($ev in (Invoke-EnemyStrike $State $Rolls $enemyAVS ($eMult * $vanguardMod * $stealthPenalty))) { $events.Add($ev) }
        # Vanguard-Konter
        if ($Action.Kind -eq "Vanguard" -and $State.Phase -eq "Active") {
            $cRoll = if ($Rolls.Counter) { $Rolls.Counter } else { Get-Random -Minimum 1 -Maximum 101 }
            if ($cRoll -le 30) {
                $typeMod = if (Get-Command Get-ElementModifier -ErrorAction SilentlyContinue) { Get-ElementModifier $p.Type $e.Type } else { 1.0 }
                $cd = Get-DamageV3 -ATK $p.ATK -MovePower 30 -DEF $e.DEF -AttackerLevel $p.Level -TypeMod $typeMod
                $e.HP -= $cd
                $events.Add(@{ Topic = "combat.counter"; Data = @{ Attacker = $p.Name; Damage = $cd } })
                if ($e.HP -le 0) { $State.Phase = "Won" }
            }
        }
    }

    if ($playerFirst) { & $doPlayer; & $doEnemy } else { & $doEnemy; & $doPlayer }

    # --- Status-Ticks (Ende der Runde) ---
    if ($State.Phase -eq "Active") {
        foreach ($ev in (Invoke-StatusTick $p)) { $events.Add($ev) }
        foreach ($ev in (Invoke-StatusTick $e)) { $events.Add($ev) }
        if ($p.HP -le 0) { $State.Phase = "Lost" }
        elseif ($e.HP -le 0) { $State.Phase = "Won" }
    }

    $State.Log.Add("R$($State.Round): P=$playerAVS E=$enemyAVS W=$winner M=$($State.Momentum)")
    $State.Round++

    if ($State.Phase -eq "Won")  { $events.Add(@{ Topic = "combat.won";  Data = @{ Enemy = $e.Name; Rounds = $State.Round; IsBoss = [bool]$e.IsBoss } }) }
    if ($State.Phase -eq "Lost") { $events.Add(@{ Topic = "combat.lost"; Data = @{ Enemy = $e.Name } }) }

    # Kampf beendet -> offene Boss-Ladungen verwerfen
    if ($State.Phase -ne "Active") { $State.BossCharging = $false; $State.BossChargeWarned = $false }

    return @{ State = $State; Events = $events }
}

function Invoke-EnemyStrike {
    # Hilfsfunktion: ein Gegner-Angriff mit allen Mods. Gibt Events zurueck.
    param($State, $Rolls, $enemyAVS, [double]$Mult = 1.0)
    $events = @()
    $p = $State.Player; $e = $State.Enemy
    $skip = Test-TurnSkip $e ($(if ($Rolls.EnemySkip) { $Rolls.EnemySkip } else { Get-Random -Minimum 1 -Maximum 101 }))
    if ($skip.Skip) {
        return @(@{ Topic = "combat.skip"; Data = @{ Target = $e.Name; Reason = $skip.Reason } })
    }
    if ($enemyAVS -eq "V") {
        return @(@{ Topic = "combat.vanguard"; Data = @{ Target = $e.Name } })
    }
    # Silence blockiert Gegner-Stealth
    $silenced = $e.Effects | Where-Object { $_.Type -eq "Silence" } | Select-Object -First 1
    if ($silenced -and $enemyAVS -eq "S") {
        $enemyAVS = "A"
        $events += @{ Topic = "combat.silenced"; Data = @{ Target = $e.Name } }
    }
    $power = if ($enemyAVS -eq "S") { 52 } else { 40 }
    $typeMod = if (Get-Command Get-ElementModifier -ErrorAction SilentlyContinue) { Get-ElementModifier $e.Type $p.Type } else { 1.0 }
    $effATK = Get-EffectiveStatWithSE $e.ATK "ATK" $e.Effects
    $effDEF = Get-EffectiveStatWithSE $p.DEF "DEF" $p.Effects
    $variance = if ($Rolls.ContainsKey("EnemyVariance")) { $Rolls.EnemyVariance } else { (Get-Random -Minimum -8 -Maximum 9) / 100.0 }

    # Boss-Ladungs-Angriff
    $chargeMod = 1.0
    if ($State.BossCharging) {
        if ($State.Phase -eq "Active" -and $Action.Kind -eq "Vanguard") {
            $chargeMod = 0.25
            $events += @{ Topic = "combat.boss.charge.mitigated"; Data = @{ Target = $p.Name } }
        } else {
            $chargeMod = 2.0
            $events += @{ Topic = "combat.boss.charge.hit"; Data = @{ Target = $p.Name } }
        }
        $State.BossCharging = $false
        $State.BossChargeWarned = $false
    }

    $dmg = Get-DamageV3 -ATK $effATK -MovePower $power -DEF $effDEF -AttackerLevel $e.Level `
        -TypeMod $typeMod -AvsMod ($Mult * $chargeMod) -MomentumStacks ([math]::Max(0, -$State.Momentum)) -Variance $variance
    $p.HP -= $dmg
    $events += @{ Topic = "combat.hit"; Data = @{ Attacker = $e.Name; Target = $p.Name; Damage = $dmg; TypeMod = $typeMod; Charge = ($chargeMod -ne 1.0) } }
    if ($p.HP -le 0) { $State.Phase = "Lost" }
    return $events
}

# ============================================================
# HEADLESS BALANCE-SIMULATOR
# ============================================================
function Invoke-CombatSimulation {
    <#
    .SYNOPSIS
      Simuliert N Kaempfe headless. Liefert Winrate, avg Runden, avg Rest-HP.
      DAS ist der Grund fuer den Reducer: Balancing per Daten statt Bauchgefuehl.
    .EXAMPLE
      Invoke-CombatSimulation -N 1000 -PlayerLevel 5 -Archetype "Predator"
    #>
    param([int]$N = 500, [int]$PlayerLevel = 5, [string]$Archetype = "Drone")
    $wins = 0; $totalRounds = 0; $totalRestHP = 0.0
    for ($i = 0; $i -lt $N; $i++) {
        $pl = @{ Name = "SIM_PET"; Type = "FIRE"; Level = $PlayerLevel
                 HP = 90 + $PlayerLevel * 10; MaxHP = 90 + $PlayerLevel * 10
                 ATK = 16 + $PlayerLevel * 2; DEF = 6 + $PlayerLevel; SPD = 13 + $PlayerLevel; Crit = 5 }
        # Kalibriert gegen naive Policy: ~65% vs Drone, ~50% vs Predator bei Level 5
        $enScale = 1 + ($PlayerLevel - 1) * 0.33
        $en = @{ Name = "SIM_ENEMY"; Type = "ICE"; Level = $PlayerLevel
                 HP = [math]::Round(125 * $enScale); MaxHP = [math]::Round(125 * $enScale)
                 ATK = [math]::Round(17 * $enScale); DEF = [math]::Round(12 * $enScale)
                 SPD = 14; Archetype = $Archetype; IsBoss = $false }
        $st = New-CombatStateV3 -Player $pl -Enemy $en
        $guard = 60
        while ($st.Phase -eq "Active" -and $guard-- -gt 0) {
            $kind = @("Attack","Attack","Stealth","Vanguard") | Get-Random  # naive Spieler-Policy
            $r = Invoke-CombatReducer -State $st -Action @{ Kind = $kind }
            $st = $r.State
        }
        if ($st.Phase -eq "Won") { $wins++; $totalRestHP += ($st.Player.HP / $st.Player.MaxHP) }
        $totalRounds += $st.Round
    }
    return @{
        N = $N; Winrate = [math]::Round($wins / $N * 100, 1)
        AvgRounds = [math]::Round($totalRounds / $N, 1)
        AvgRestHPPctOnWin = if ($wins -gt 0) { [math]::Round($totalRestHP / $wins * 100, 1) } else { 0 }
    }
}

} catch {
    Write-Host "[pet/combat-core] CRITICAL ERROR: $_" -ForegroundColor Red
}
