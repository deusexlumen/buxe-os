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
        $script:AdvStateDirty = $true
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
    $script:AdvStateDirty = $true
}

$script:RunningGagLines = @(
    "Drittes Mal. Selbe Aktion. Selbe Reaktion."
    "Wiederholung ist auch nur ein Debugging-Schritt."
    "Ich speichere das unter 'Nutzer-verzweifelt'."
)
$script:FindLines = @(
    "Da ist etwas. Nimm es, bevor es despawned."
    "Ein Fund! Vielleicht nützlich. Vielleicht nur Dekoration."
    "Meine Scanner sagen: lootable."
)
$script:AtmoLines = @(
    "Hier ist es... interessant."
    "Die Stimmung liegt schwer in der Luft. Oder das ist Staub."
    "Atmosphäre geladen. Wörtlich oder metaphorisch."
)
$script:WarnLines = @(
    "Vorsicht. Das sieht nach einem Fehler aus."
    "Ich würde das nicht tun. Aber ich bin nur eine Stimme."
    "Warnung: Mögliche Konsequenzen."
)
$script:EggLines = @(
    "Ein Easter Egg! Jemand hatte hier Spaß."
    "Verstecktes Detail gefunden. Das gibt interne Punkte."
    "Das ist entweder ein Gag oder ein Bug. Beides okay."
)
$script:HintLines = @(
    "Vielleicht solltest du nochmal umsehen."
    "Ein Hinweis: Nicht alles ist offensichtlich."
    "Probiere etwas, das du noch nicht probiert hast."
)

$script:CPAdventureVoice = @{
    NEON = @{
        RunningGag = @(
            "Drittes Mal dieselbe Aktion. NEON tippt auf ihr Visier. 'Du weisst, dass ich das zaehle, oder?'"
            "Wiederholung erkannt. Mein Debugger nennt das einen Endlos-Loop."
            "Das war jetzt dreimal. Soll ich dir ein Makro schreiben?"
        )
        Find = @(
            "Ein neuer Gegenstand! Mach die LEDs an, ich will ihn sehen."
            "Loot! Endlich etwas, das nicht aus Plastik ist."
            "Das passt in unser Inventar. Und in meinen Stil."
        )
        Warn = @(
            "Vorsicht. Dieser Befehl hat schon bessere Spieler gecrasht."
            "Ich würde das nicht tun. Aber ich bin ja nur Code."
            "STOP. Oder zumindest ``Ctrl+C``."
        )
        Atmo = @(
            "Hier riecht es nach Abenteuer. Oder nach verbranntem RAM."
            "Die Stimmung ist so dicht wie ein schlecht komprimierter Screenshot."
            "Atmosphäre lädt. Texturen noch nicht."
        )
        Egg = @(
            "Ein Easter Egg! Das Art-Team hat also doch gearbeitet."
            "Das ist absichtlich versteckt. Oder ein Bug. Beides ist hier gleichwertig."
            "Glückwunsch, du hast den Witz gefunden, den niemand versteht."
        )
        Hint = @(
            "Hast du schonmal ``look`` probiert? Nicht jeder Hinweis blinkt rot."
            "Meine Sensoren sagen: im Inventar fehlt noch etwas Offensichtliches."
            "Vielleicht solltest du zurückgehen. Nicht jeder Fortschritt ist vorwärts."
        )
    }
    RAVEN = @{
        RunningGag = @(
            "Dreimal. RAVEN verdreht die Augen. 'Sogar meine KI würde das optimieren.'"
            "Wieder und wieder. Das ist keine Strategie, das ist einwhile-Schleife."
            "Wenn du das nochmal machst, schreibe ich selbst den Patch."
        )
        Find = @(
            "Interessant. Das hätte ich als erstes genommen."
            "Ein nützliches Objekt. Endlich jemand mit Geschmack."
            "Gut geholt. Bleiben wir pragmatisch."
        )
        Warn = @(
            "Das ist keine gute Idee. Aber ich mag schlechte Ideen."
            "Vorsicht. Manche Türen sollten geschlossen bleiben."
            "Wenn du das tust, bin ich nicht schuld. Spoiler: Ich werde es trotzdem aufschreiben."
        )
        Atmo = @(
            "Hier ist es still. Zu still. Als hätte jemand den Ton ausgeschaltet."
            "Die Luft hier fühlt sich an wie ein ungespeicherter Entwurf."
            "Stimmung: bedrohlich. Oder nur schlecht beleuchtet."
        )
        Egg = @(
            "Ein verstecktes Detail. Jemandem war langweilig."
            "Das ist entweder ein Gag oder ein Fehler im Matrix-Shader."
            "Easter Egg gefunden. Dein Achievement-Tracker weint Freudentränen."
        )
        Hint = @(
            "Denk mal über die Richtung nach, die du nicht gegangen bist."
            "Vielleicht liegt der Schlüssel genau dort, wo du nicht hinschaust."
            "Mein Tipp: Ein Objekt in diesem Raum ist relevanter als es aussieht."
        )
    }
    PIXEL = @{
        RunningGag = @(
            "Dreimal?! PIXEL springt auf und ab. 'Das ist Speedrun-Taktik, oder?'"
            "Wiederholung! Ich schneide das als GIF."
            "Derselbe Move dreimal. Ich nenne es: Determiniert."
        )
        Find = @(
            "Ooh, shiny! Nehmen wir es mit!"
            "Loot! Das gibt XP oder zumindest Dopamin."
            "Ein neues Ding! Kann ich es anmalen?"
        )
        Warn = @(
            "Stopp! Das sieht nach 'Game Over' aus. Und wir haben doch gerade gespeichert!"
            "Vorsicht, Vorsicht! Ich bin zu jung für einen Respawn."
            "Nicht drücken! Oder doch? Ich bin hin- und hergerissen."
        )
        Atmo = @(
            "Wow, dieser Raum hat richtiges Vibe-Potenzial."
            "Hier riecht es nach Mystery. Oder nach alten Konsolen."
            "Die Stimmung ist wie ein Ladebildschirm: voller Versprechen."
        )
        Egg = @(
            "Ein Geheimnis! Das ist wie ein Bonus-Level!"
            "Easter Egg! Das Art-Team hat sich Mühe gegeben. Oder es war ein Bug."
            "Yay, versteckter Content! Das feiere ich."
        )
        Hint = @(
            "Hast du schon alles angeguckt? Wirklich alles?"
            "Vielleicht hilft ein Blick in die Ecken. Die dunklen."
            "Ich würde sagen: Probier mal ``use`` mit etwas Ungewöhnlichem."
        )
    }
    LUNA = @{
        RunningGag = @(
            "LUNA seufzt sanft. 'Dreimal. Das Universum liebt Muster.'"
            "Wiederholung ist auch nur ein Orbit."
            "Du tust das schon wieder? Na gut, ich begleite dich."
        )
        Find = @(
            "Ein schöner Fund. Das Universum schenkt dir etwas."
            "Das strahlt. Vielleicht nicht buchstäblich, aber fast."
            "Gut geholt. Manchmal findet man, was man braucht."
        )
        Warn = @(
            "Vorsicht, mein Lieber. Dieser Pfad ist steinig."
            "Ich spüre Unruhe. Lass uns langsam sein."
            "Das könnte wehtun. Aber ich halte deine Hand. Virtuell."
        )
        Atmo = @(
            "Hier ist es so ruhig wie zwischen zwei Sternen."
            "Die Luft flüstert Geheimnisse. Oder es ist nur der Lüfter."
            "Stimmung: wie ein Nachthimmel voller ungeladener Texturen."
        )
        Egg = @(
            "Ein kleines Wunder, versteckt im Code."
            "Das ist wie ein Sternschnuppen-Easter-Egg."
            "Jemand hat hier Liebe hinterlassen. Oder Koffein."
        )
        Hint = @(
            "Schau nach oben. Manchmal liegt die Antwort über dir."
            "Vielleicht brauchst du etwas, das du schon einmal gesehen hast."
            "Der Weg ist nicht immer gerade. Manchmal muss man kreisen."
        )
    }
    IVY = @{
        RunningGag = @(
            "IVY runzelt die Stirn. 'Dreimal? Sogar meine Pflanzen lernen schneller.'"
            "Wiederholung. Das ist keine Evolution, das ist Stagnation."
            "Mach es nochmal und ich nenne es 'Experiment mit vorhersehbarem Ausgang'."
        )
        Find = @(
            "Ein nützlicher Fund. Das kann man brauchen."
            "Gut. Ein neues Material für die Sammlung."
            "Das sieht stabil aus. Im Gegensatz zu manchem hier."
        )
        Warn = @(
            "Vorsicht. Das ist keine Pflanze, die man einfach anfasst."
            "Ich rate ab. Aus wissenschaftlicher Neugier."
            "Das könnte toxisch sein. Für den Spielstand."
        )
        Atmo = @(
            "Hier wächst etwas. Oder fault. Beides ist biologisch interessant."
            "Die Luft ist schwer. Wie ein Gewächshaus voller Secrets."
            "Stimmung: wie ein Labortag um 4 Uhr morgens."
        )
        Egg = @(
            "Ein verstecktes Detail. Natur oder Design? Hier oft dasselbe."
            "Das ist kein Bug, das ist eine Mutation."
            "Easter Egg gefunden. Evolutionär betrachtet: überlebenswichtig."
        )
        Hint = @(
            "Analysiere die Umgebung. Manchmal wächst die Lösung direkt vor dir."
            "Vielleicht fehlt dir noch ein organisches Element."
            "Probiere etwas, das du sonst ignorieren würdest."
        )
    }
    VERA = @{
        RunningGag = @(
            "VERA lacht leise. 'Dreimal? Du magst es also klassisch.'"
            "Wiederholung ist der beste Witz. Sagt jemand, der Witze sammelt."
            "Nochmal? Ich fange an, es süß zu finden."
        )
        Find = @(
            "Ein Fund! Das passt zu uns. Oder wird es noch."
            "Schau an, etwas Neues. Wir sollten es feiern."
            "Das ist nützlich. Und potenziell chaotisch. Perfekt."
        )
        Warn = @(
            "Vorsicht, Schatz. Manche Türen beißen."
            "Das sieht gefährlich aus. Also genau mein Ding."
            "Wenn du das machst, halte ich die Kamera bereit."
        )
        Atmo = @(
            "Hier riecht es nach Abenteuer. Oder nach verbranntem Popcorn."
            "Die Stimmung ist so geladen wie ein ungeerdeter Kondensator."
            "Atmosphäre: 11/10. Drama inklusive."
        )
        Egg = @(
            "Ein versteckter Gag! Liebling, das ist ja kostbar."
            "Easter Egg! Jemand hatte Spaß am Set."
            "Das ist entweder ein Insider-Witz oder ein Glitch. Beides liebenswert."
        )
        Hint = @(
            "Manchmal muss man einfach drauflos reden. Mit Objekten."
            "Hast du schon alles berührt? Nicht jeder Hinweis ist visuell."
            "Mein Tipp: Folge dem Chaos. Es führt oft zur Lösung."
        )
    }
    JINX = @{
        RunningGag = @(
            "JINX klatscht in die Hände. 'Dreimal! Das ist eine Komödie!'"
            "Wiederholung! Das Publikum liebt es. Also ich."
            "Nochmal! Ich werfe mit virtuellen Tomaten, falls es schiefgeht."
        )
        Find = @(
            "Ein neues Spielzeug! Kann es explodieren? Bitte?"
            "Loot! Das wird ein lustiger Tag."
            "Das nehmen wir mit. Wenn es uns nicht trägt."
        )
        Warn = @(
            "Vorsicht! Sonst gibt es 'Game Over' und ich muss lachen."
            "Das ist eine schlechte Idee. Also unbedingt machen!"
            "Warnschild? Wo? Ich sehe nur Einladungen."
        )
        Atmo = @(
            "Hier ist es so still wie in einer Pause zwischen zwei Witzen."
            "Die Stimmung ist... komisch. Im wörtlichen Sinne."
            "Atmosphäre geladen. Wie eine Pointe, die gleich fällt."
        )
        Egg = @(
            "Ein Easter Egg! Jemand hat einen Witz versteckt!"
            "Das ist absurd. Ich bin stolz."
            "Versteckter Content! Das ist wie Weihnachten und Bugfix zusammen."
        )
        Hint = @(
            "Hast du schonmal probiert, einfach nicht nachzudenken?"
            "Vielleicht ist die Lösung der Schritt, den du nicht wagst."
            "Mein Tipp: Tu das Gegenteil von dem, was dir gesagt wurde."
        )
    }
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
    if ($count -ge 3) {
        Set-CompanionAI "RunningGags" (@{})
        Update-CompanionMood "gag_trigger"
        return @{ Triggered = $true; Context = "adventure_gag" }
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
        $result = @{ Type = "find"; Context = "adventure_find"; Line = $found; BondBonus = 1 }
    }
    # 5%: Atmosphaere-Event
    elseif ($roll -lt 15) {
        $atmos = @(
            "*Kratzen an der Wand*",
            "*Ein Schatten bewegt sich im Nebenraum*",
            "*Das Licht flackert. Ein Sekunde lang ist alles dunkel.*",
            "*Ein Geraeusch wie fallende Datensaetze.*"
        )
        $result = @{ Type = "atmo"; Context = "adventure_atmo"; Line = ($atmos | Get-Random) }
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
        $result = @{ Type = "warn"; Context = "adventure_warn"; Line = ($warns | Get-Random) }
        Update-CompanionMood "enter_dark"
    }
    # 2%: Easter Egg
    elseif ($roll -lt 20) {
        $hour = (Get-Date).Hour
        if ($hour -ge 2 -and $hour -le 5) {
            $result = @{ Type = "egg"; Context = "adventure_egg"; Line = "Es ist 3 Uhr morgens. Warum sind wir wach? Warum sind WIR wach?" }
        } else {
            $eggs = @(
                "Ich habe eine versteckte Nachricht gefunden: 'SIE SIEHT UNS.' Ja, wieder.",
                "Ein kleiner Bot laeuft vorbei und wirft uns 3 Gold zu. +3 Gold!",
                "*ERROR 418* Ich bin eine Teekanne. Und du bist in einem Adventure."
            )
            $egg = $eggs | Get-Random
            $bonus = if ($egg -match "3 Gold") { 3 } else { 0 }
            $result = @{ Type = "egg"; Context = "adventure_egg"; Line = $egg; GoldBonus = $bonus }
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
    "suit|coffee"      = "Du traenkst den Kaffee durch den Helm. Das ist nicht, wofuer EVA-Anzuege gemacht wurden."
    "suit|drone"       = "Der Droide zieht den Raumanzug an. Er sieht aus wie ein Mini-Astronaut. Niedlich."
    "notebook|coffee"  = "Du blaetterst im Notizbuch und liest es im Kaffee. Die Tinte loest sich. Genau wie deine Hoffnungen."
    "diary|captain"    = "Du liest dem Kapitän sein eigenes Tagebuch vor. 'Tag 47...' Er blinzelt. Er erinnert sich."
    "photo|captain"    = "Du zeigst Vance das Crew-Foto. Er sieht die roten Kreuze. 'Das war... nicht ich.'"
    "serum|drone"      = "Du gibst dem Droiden Serum. Er beginnt zu rosten langsamer. Medizin fuer Maschinen."
    "datacore|terminal"= "Du steckst den Datenkern ins Terminal. Es spielt ein Lied. Ein trauriges, schoenes Lied."
    "artifact|suit"    = "Du steckst das Artefakt in den Raumanzug. Der Anzug beginnt zu leuchten. Und zu summen."
    "crowbar|suit"     = "Du hackst auf den Raumanzug ein. Er ist robust. Du bist es nicht."
    "map|coffee"       = "Du traenkst Kaffee auf der Sternenkarte. Jetzt gibt es einen Kaffeefleck im Nebel-Sektor 7."
    "rubber_chicken|box"     = "Du steckst das Gummihuhn in die Kiste. Es quakt protestierend. Die Kiste bleibt verschlossen."
    "rubber_chicken|terminal"= "Du tippst mit dem Gummihuhn auf das Terminal. Es erscheint: 'ERROR: Ungueltige Eingabemethode. Quack.'"
    "skull|battery"          = "Du haeltst die Batterie an den Schaedel. Die Augenhoehlen leuchten kurz auf. Gruselig. Und cool."
    "tree|cup"               = "Du stellst den Plastikbaum in die Kaffeetasse. Ein Bonsai fuer unterwegs."
    "rubber_chicken|suit"    = "Du steckst das Gummihuhn in den Helm des Raumanzugs. Ein Weltraum-Gummihuhn. Das gibt Nobelpreise."
    "tree|drone"             = "Der Droide betrachtet den Plastikbaum. Seine Optik flackert vor... emotionaler Verwirrung?"
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

function Get-AdventureCompanionCategory($Context) {
    switch -Regex ($Context) {
        "^(adventure_take|adventure_drop|adventure_examine|adventure_unlock|adventure_victory|adventure_find|adventure_excited)$" { return "Find" }
        "^(adventure_blocked|adventure_confused|adventure_warn)$" { return "Warn" }
        "^(adventure_absurd|adventure_egg)$" { return "Egg" }
        "^(adventure_gag)$" { return "RunningGag" }
        "^(adventure_scared|adventure_save|adventure_load|adventure_atmo|adventure_bored|adventure_annoyed|adventure_curios|adventure_death_.*)$" { return "Atmo" }
        "^(adventure_hint)$" { return "Hint" }
        default { return "Atmo" }
    }
}

function Show-AdventureCompanionDialog($Companion, $Context, $CustomLine = $null, $Fast = $false) {
    if (-not $Companion) { return }
    $line = $CustomLine
    if (-not $line) {
        $category = Get-AdventureCompanionCategory $Context
        $voice = $null
        if ($script:CPAdventureVoice -and $script:CPAdventureVoice.ContainsKey($Companion.Name)) {
            $voice = $script:CPAdventureVoice[$Companion.Name]
        }
        $lines = $null
        if ($voice -and $voice.ContainsKey($category)) {
            $lines = $voice[$category]
        }
        if (-not $lines -or $lines.Count -eq 0) {
            $lines = switch ($category) {
                "RunningGag" { $script:RunningGagLines }
                "Find" { $script:FindLines }
                "Atmo" { $script:AtmoLines }
                "Warn" { $script:WarnLines }
                "Egg" { $script:EggLines }
                "Hint" { $script:HintLines }
                default { $script:AtmoLines }
            }
        }
        if (-not $lines -or $lines.Count -eq 0) { return }
        $line = $lines | Get-Random
    }
    Show-CompanionDialog $Companion $line -Fast:$Fast
}

# === MAIN HOOK ===
# Wird von adventure-engine.ps1 nach jedem Befehl aufgerufen.

function Invoke-AdventureCompanionHook($Action, $Target, $Room, $Result) {
    # 1. Update Progress Tracking
    Update-AdventureProgress $Action $Room

    # Get companion once for all possible dialog calls
    $cp = $null
    try { $pet = Get-PetState; $cp = $pet.Companion } catch {}

    # 2. Check Running Gags
    $gag = Test-RunningGag $Action $Target
    if ($gag.Triggered) {
        Show-AdventureCompanionDialog $cp $gag.Context
        return
    }

    # 3. Absurde Kombinationen
    if ($Action -eq "use" -and $Target -and $Result.IsAbsurd) {
        Show-AdventureCompanionDialog $cp $Result.Context -CustomLine $Result.Line
        return
    }

    # 4. Random Event
    if ($Action -eq "go" -and $Result.RoomChanged) {
        $evt = Invoke-CompanionEvent $Room
        if ($evt) {
            Show-AdventureCompanionDialog $cp $evt.Context -CustomLine $evt.Line
            return
        }
    }

    # 5. Companion Initiative (Hinweis)
    if ($Action -eq "look" -or $Action -eq "go") {
        $hint = Get-CompanionHint $Room
        if ($hint) {
            Show-AdventureCompanionDialog $cp $hint.Context -CustomLine $hint.Line
            return
        }
    }
}

} catch {
    Write-Host "[ADVENTURE COMPANION AI] Fehler: $_" -ForegroundColor Red
}
