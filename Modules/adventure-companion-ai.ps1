# BUXE_OS v24.8 -- ADVENTURE COMPANION AI
# LucasArts-Style CoOp-Partner mit Mood, Running Gags, Initiative, Events.

try {

# === COMPANION AI STATE ===
# Persistiert im Adventure-State, damit es über Sessions erhalten bleibt.

function Get-CompanionAIDefaults {
    return @{
        Mood = "Curious"
        Boredom = 0
        Fear = 0
        MovesWithoutProgress = 0
        LastAdvice = ""
        RunningGags = @{}
        FoundSecrets = @()
        LastRoom = ""
        LastAction = ""
        SameActionCount = 0
    }
}

function Get-CompanionAI {
    if (-not $script:AdvState) { return (Get-CompanionAIDefaults) }
    if (-not $script:AdvState.CompanionAI) {
        $script:AdvState.CompanionAI = Get-CompanionAIDefaults
        Save-AdventureState
    }
    # Convert from JSON-loaded PSCustomObject to Hashtable if needed
    $ai = $script:AdvState.CompanionAI
    if ($ai -is [System.Management.Automation.PSCustomObject]) {
        $ht = @{}
        $ai.PSObject.Properties | ForEach-Object { $ht[$_.Name] = $_.Value }
        $ai = $ht
        $script:AdvState.CompanionAI = $ai
    }
    # Ensure RunningGags is a hashtable
    if ($ai.RunningGags -is [System.Management.Automation.PSCustomObject]) {
        $rg = @{}
        $ai.RunningGags.PSObject.Properties | ForEach-Object { $rg[$_.Name] = $_.Value }
        $ai.RunningGags = $rg
    }
    return $ai
}

function Set-CompanionAI($Key, $Value) {
    $ai = Get-CompanionAI
    $ai[$Key] = $Value
    $script:AdvState.CompanionAI = $ai
    Save-AdventureState
}

# === MOOD SYSTEM ===

function Get-AdventureMoodContext {
    $ai = Get-CompanionAI
    switch ($ai.Mood) {
        "Scared"   { return "adventure_scared" }
        "Bored"    { return "adventure_bored" }
        "Excited"  { return "adventure_excited" }
        "Annoyed"  { return "adventure_annoyed" }
        default    { return "adventure_curios" }
    }
}

function Update-CompanionMood($Event) {
    $ai = Get-CompanionAI
    switch ($Event) {
        "enter_dark"   { if ($ai.Fear -lt 50) { $ai.Fear += 10 }; if ($ai.Fear -ge 30) { $ai.Mood = "Scared" } }
        "enter_bright" { if ($ai.Fear -gt 0) { $ai.Fear -= 5 }; if ($ai.Fear -le 10 -and $ai.Mood -eq "Scared") { $ai.Mood = "Curious" } }
        "find_item"    { $ai.Mood = "Excited"; $ai.Boredom = [math]::Max(0, $ai.Boredom - 5) }
        "unlock"       { $ai.Mood = "Excited"; $ai.Boredom = 0 }
        "stuck"        { $ai.Boredom += 3; if ($ai.Boredom -ge 10) { $ai.Mood = "Bored" } }
        "repeat_action"{ if ($ai.Mood -ne "Annoyed") { $ai.Mood = "Annoyed" } }
        "progress"     { $ai.Boredom = 0; if ($ai.Mood -in @("Bored","Annoyed")) { $ai.Mood = "Curious" } }
        "absurd"       { $ai.Mood = "Excited"; $ai.Boredom = [math]::Max(0, $ai.Boredom - 3) }
        "gag_trigger"  { $ai.Mood = "Annoyed" }
    }
    Set-CompanionAI "Mood" $ai.Mood
    Set-CompanionAI "Fear" $ai.Fear
    Set-CompanionAI "Boredom" $ai.Boredom
}

# === RUNNING GAG SYSTEM ===

function Test-RunningGag($Action, $Target) {
    $ai = Get-CompanionAI
    $key = "$Action|$Target"
    if (-not $ai.RunningGags[$key]) { $ai.RunningGags[$key] = 0 }
    $ai.RunningGags[$key]++
    Set-CompanionAI "RunningGags" $ai.RunningGags

    $count = $ai.RunningGags[$key]
    $ctx = ""
    $line = $null

    switch ($Action) {
        "examine" {
            if ($count -eq 3) { $ctx = "adventure_gag"; $line = "Ja, es ist immer noch da. Ueberraschung." }
            if ($count -eq 5) { $ctx = "adventure_gag"; $line = "WIRKLICH? NOCHMAL? Das Objekt hat sich nicht veraendert. Physik." }
            if ($count -ge 7) { $ctx = "adventure_gag"; $line = "Ich speichere das. In meinem 'Nutzer-verzweifelt'-Ordner." }
        }
        "go" {
            if ($count -eq 3) { $ctx = "adventure_gag"; $line = "Wir drehen uns im Kreis. Wie mein Code." }
            if ($count -eq 5) { $ctx = "adventure_gag"; $line = "Dieser Raum sieht aus wie der letzte. Oh. Es IST der letzte." }
            if ($count -ge 7) { $ctx = "adventure_gag"; $line = "Bist du verloren? Oder verlierst du mich absichtlich?" }
        }
        "use" {
            if ($count -eq 2) { $ctx = "adventure_gag"; $line = "Probiere es nochmal. Vielleicht funktioniert es beim 47. Mal." }
            if ($count -eq 4) { $ctx = "adventure_gag"; $line = "Definition von Wahnsinn: Das Gleiche tun und andere Ergebnisse erwarten." }
            if ($count -ge 6) { $ctx = "adventure_gag"; $line = "Ich werde nicht mehr zuschauen. Okay, ich gucke. Aber ich bewerte es. 2/10." }
        }
        "talk" {
            if ($count -eq 3) { $ctx = "adventure_gag"; $line = "Er hat nichts Neues zu sagen. Trust me. Ich habe alles gecached." }
            if ($count -eq 5) { $ctx = "adventure_gag"; $line = "Wir sind bei Dialog #5. Bald bekommen wir eine Trophaee fuer Ausdauer." }
            if ($count -ge 7) { $ctx = "adventure_gag"; $line = "NPC: 'Hilf mir.' Du: 'Erzaehl mir mehr.' NPC: 'Bitte.' Du: 'Erzaehl mir mehr.'" }
        }
    }

    if ($line) {
        Update-CompanionMood "gag_trigger"
        return @{ Triggered = $true; Context = $ctx; Line = $line }
    }
    return @{ Triggered = $false }
}

# === RANDOM EVENT ENGINE ===

function Invoke-CompanionEvent($Room) {
    $ai = Get-CompanionAI
    $pet = $null
    $cp = $null
    try { $pet = Get-PetState; $cp = $pet.Companion } catch { return $null }
    if (-not $cp) { return $null }

    $roll = Get-Random -Maximum 100
    $result = $null

    # 10%: Companion findet etwas
    if ($roll -lt 10) {
        $finds = @(
            "Warte... da ist etwas unter dem Tisch. Ein Datenstick!",
            "Ich habe einen Kratzer an der Wand entdeckt. Dahinter... ein Schalter?",
            "*hust* Da liegt etwas. Sieht aus wie... ein altes Foto?",
            "Meine Sensoren piepen. Hier ist etwas versteckt."
        )
        $found = $finds | Get-Random
        $result = @{ Type = "find"; Context = "adventure_excited"; Line = $found; BondBonus = 1 }
    }
    # 5%: Atmosphaere-Event
    elseif ($roll -lt 15) {
        $atmos = @(
            "*Kratzen an der Wand*",
            "*Ein Schatten bewegt sich im Nebenraum*",
            "*Das Licht flackert. Ein Sekunde lang ist alles dunkel.*",
            "*Ein Geraeusch wie fallende Datensaetze.*"
        )
        $result = @{ Type = "atmo"; Context = "adventure_scared"; Line = ($atmos | Get-Random) }
        Update-CompanionMood "enter_dark"
    }
    # 3%: Companion warnt
    elseif ($roll -lt 18) {
        $warns = @(
            "Ich habe ein schlechtes Gefuehl. Wir sollten zurueckgehen.",
            "Meine Threat-Detection ist auf 87%. Das ist... hoch.",
            "Hoerst du das? Nein? Gut. Denn es ist unheimlich.",
            "Dieser Raum hat mehr Null-Pointer als mein Code. Vorsicht."
        )
        $result = @{ Type = "warn"; Context = "adventure_scared"; Line = ($warns | Get-Random) }
        Update-CompanionMood "enter_dark"
    }
    # 2%: Easter Egg
    elseif ($roll -lt 20) {
        $hour = (Get-Date).Hour
        if ($hour -ge 2 -and $hour -le 5) {
            $result = @{ Type = "egg"; Context = "adventure_excited"; Line = "Es ist 3 Uhr morgens. Warum sind wir wach? Warum sind WIR wach?" }
        } else {
            $eggs = @(
                "Ich habe eine versteckte Nachricht gefunden: 'SIE SIEHT UNS.' Ja, wieder.",
                "Ein kleiner Bot laeuft vorbei und wirft uns 3 Gold zu. +3 Gold!",
                "*ERROR 418* Ich bin eine Teekanne. Und du bist in einem Adventure."
            )
            $egg = $eggs | Get-Random
            $bonus = if ($egg -match "3 Gold") { 3 } else { 0 }
            $result = @{ Type = "egg"; Context = "adventure_excited"; Line = $egg; GoldBonus = $bonus }
        }
    }

    if ($result -and $result.BondBonus -and $pet -and $pet.Companion) {
        $pet.Companion.Bond = [math]::Min(100, $pet.Companion.Bond + $result.BondBonus)
        Save-PetState $pet
    }
    if ($result -and $result.GoldBonus -and $pet) {
        $pet.Economy.Gold += $result.GoldBonus
        Save-PetState $pet
    }

    return $result
}

# === COMPANION INITIATIVE (Hint System) ===

function Get-CompanionHint($Room) {
    $ai = Get-CompanionAI
    $pet = $null
    $cp = $null
    try { $pet = Get-PetState; $cp = $pet.Companion } catch { return $null }
    if (-not $cp) { return $null }

    # Nur wenn der Spieler steckenbleibt (5+ Zuege ohne Fortschritt)
    if ($ai.MovesWithoutProgress -lt 5) { return $null }
    # Nicht zu oft hinweisen
    if ($ai.LastAdvice -eq $Room.Id) { return $null }

    Set-CompanionAI "LastAdvice" $Room.Id

    $bond = $cp.Bond
    $inv = $script:AdvState.Inventory
    $flags = $script:AdvState.Flags

    # Raum-spezifische Hinweise basierend auf Fortschritt
    $hints = @()

    if ($Room.Id -eq "hangar" -and $inv -notcontains "card") {
        $hints += "Die Zugangskarte liegt hier irgendwo. Suchen. Bitte."
    }
    if ($Room.Id -eq "corridor" -and $inv -contains "card" -and -not $flags["bridge_unlocked"]) {
        $hints += "Wir haben eine Karte. Und dort ist ein Leser. Verbindung?"
    }
    if ($Room.Id -eq "storage" -and $inv -contains "crowbar" -and -not $flags["box_opened"]) {
        $hints += "Die Kiste ist verschlossen. Wir haben ein Brecheisen. Mathe."
    }
    if ($Room.Id -eq "lab" -and $inv -notcontains "crowbar") {
        $hints += "Hier liegt ein Werkzeug, das wir brauchen koennten."
    }
    if ($Room.Id -eq "bridge" -and $inv -contains "key" -and -not $flags["chest_opened"]) {
        $hints += "Der Schrank braucht einen Schluessel. Wir haben einen. Klick."
    }
    if ($Room.Id -eq "bridge" -and $flags["chest_opened"] -and $inv -contains "artifact") {
        $hints += "Das Artefakt summt. Vielleicht sollten wir es BENUTZEN?"
    }
    if ($Room.Id -eq "secret" -and $inv -notcontains "key") {
        $hints += "Ein goldener Schluessel. Warm. Wichtig. Nimm ihn."
    }

    if ($hints.Count -eq 0) { return $null }

    $hint = $hints | Get-Random

    # Qualitaet basiert auf Bond
    if ($bond -lt 30) {
        $hint = "Stuck? I'm shocked. Really. *seufz* " + $hint
    } elseif ($bond -lt 70) {
        $hint = "Vielleicht hilft das: " + $hint
    } else {
        $hint = "Ich habe eine Idee! " + $hint
    }

    Update-CompanionMood "progress"
    return @{ Context = "adventure_hint"; Line = $hint }
}

# === PROGRESS TRACKING ===

function Update-AdventureProgress($Action, $Room) {
    $ai = Get-CompanionAI
    $roomId = $Room.Id

    # Track moves without progress
    $progressActions = @("take","use","unlock","talk")
    if ($progressActions -contains $Action -or ($Action -eq "go" -and $ai.LastRoom -ne $roomId)) {
        Set-CompanionAI "MovesWithoutProgress" 0
        Update-CompanionMood "progress"
    } else {
        Set-CompanionAI "MovesWithoutProgress" ($ai.MovesWithoutProgress + 1)
        Update-CompanionMood "stuck"
    }

    # Track same action repetition
    $actionKey = "$Action|$roomId"
    if ($ai.LastAction -eq $actionKey) {
        Set-CompanionAI "SameActionCount" ($ai.SameActionCount + 1)
        if ($ai.SameActionCount -ge 2) {
            Update-CompanionMood "repeat_action"
        }
    } else {
        Set-CompanionAI "SameActionCount" 0
        Set-CompanionAI "LastAction" $actionKey
    }

    Set-CompanionAI "LastRoom" $roomId
}

# === ABSURD COMBINATIONS ===

$script:AbsurdCombos = @{
    "battery|coffee"   = "Der Kaffee summt jetzt. Das ist... nicht gut. Aber lustig."
    "scrap|drone"      = "Der Droide hat den Schrott verschluckt. Ich bin mir nicht sicher, ob das Canon ist."
    "notebook|captain" = "Kapitän Vance liest nicht. Er STARRT."
    "crowbar|terminal" = "Du haemmst das Brecheisen in das Terminal. Es gibt Funken. Und einen Bluescreen."
    "card|box"         = "Die Karte passt nicht in die Kiste. Es sei denn, die Kiste hat NFC. Hat sie nicht."
    "cup|battery"      = "Du wirfst die Batterie in den Kaffee. Jetzt haben wir radioaktiven Kaffee."
    "uniform|drone"    = "Der Droide zieht die Uniform an. Es passt nicht. Er hat keine Beine."
    "key|terminal"     = "Der Schluessel kratzt am Terminal. Wie mein Code an der Wand."
    "map|drone"        = "Du zeigst dem Droiden die Karte. Er flackert. Er versteht nichts."
    "artifact|cup"     = "Du haeltst das Artefakt ueber den Kaffee. Der Kaffee beginnt zu leuchten."
}

function Test-AbsurdCombo($Item, $Target) {
    $key1 = "$Item|$Target"
    $key2 = "$Target|$Item"
    $line = $script:AbsurdCombos[$key1]
    if (-not $line) { $line = $script:AbsurdCombos[$key2] }
    if ($line) {
        # Bond-Bonus fuer Lachen
        try {
            $pet = Get-PetState
            if ($pet -and $pet.Companion) {
                $pet.Companion.Bond = [math]::Min(100, $pet.Companion.Bond + 1)
                Save-PetState $pet
            }
        } catch {}
        Update-CompanionMood "absurd"
        return @{ IsAbsurd = $true; Context = "adventure_absurd"; Line = $line }
    }
    return @{ IsAbsurd = $false }
}

# === COMPANION DIALOG WRAPPER ===

function Show-AdventureCompanionDialog($Context, $CustomLine = $null) {
    try {
        $pet = Get-PetState
        $cp = $pet.Companion
        if (-not $cp) { return }

        $line = $CustomLine
        if (-not $line) {
            # Versuche Mood-basierten Context, dann Fallback
            if (Get-Command Get-CompanionLine -ErrorAction SilentlyContinue) {
                $moodCtx = Get-AdventureMoodContext
                $line = Get-CompanionLine $cp $moodCtx
            }
        }

        if ($line) {
            $color = if ($script:CPColors) { $script:CPColors[$script:CPNames.IndexOf($cp.Name)] } else { "Cyan" }
            if (-not $color -or $color -eq "") { $color = "Cyan" }
            Write-Host "  [$($cp.Name)] >> $line" -ForegroundColor $color
        }
    } catch {}
}

# === MAIN HOOK ===
# Wird von adventure-engine.ps1 nach jedem Befehl aufgerufen.

function Invoke-AdventureCompanionHook($Action, $Target, $Room, $Result) {
    # 1. Update Progress Tracking
    Update-AdventureProgress $Action $Room

    # 2. Check Running Gags
    $gag = Test-RunningGag $Action $Target
    if ($gag.Triggered) {
        Show-AdventureCompanionDialog $gag.Context $gag.Line
        return
    }

    # 3. Check Absurd Combinations (nur bei 'use')
    if ($Action -eq "use" -and $Target) {
        $absurd = Test-AbsurdCombo $Action $Target
        if ($absurd.IsAbsurd) {
            Show-AdventureCompanionDialog $absurd.Context $absurd.Line
            return
        }
    }

    # 4. Random Event (nur bei 'go' in neuen Raeumen)
    if ($Action -eq "go" -and $Result.RoomChanged) {
        $evt = Invoke-CompanionEvent $Room
        if ($evt) {
            Show-AdventureCompanionDialog $evt.Context $evt.Line
            return
        }
    }

    # 5. Companion Initiative (Hinweis bei Steckenbleiben)
    if ($Action -eq "look" -or $Action -eq "go") {
        $hint = Get-CompanionHint $Room
        if ($hint) {
            Show-AdventureCompanionDialog $hint.Context $hint.Line
            return
        }
    }
}

} catch {
    Write-Host "[ADVENTURE COMPANION AI] Fehler: $_" -ForegroundColor Red
}
