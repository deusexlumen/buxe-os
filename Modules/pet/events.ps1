# BUXE_OS v24.3 — PET EVENTS v2.0
# "While you were away", Random Encounters, Easter Eggs
# Jetzt mit Companion-Dialogen statt trockener Textzeilen.

try {

function Show-WhileAway {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }
    $hour = (Get-Date).Hour
    $eventsOccurred = $false
    
    # Night watch event
    if ($hour -ge 2 -and $hour -le 5) {
        Show-CompanionDialog $cp "Ich habe die Nachtwache gehalten. Ein Spam-Bot hat versucht, dich zu verkaufen. Ich habe ihn gelöscht. +5 Gold." -Fast
        $pet.Economy.Gold += 5
        $eventsOccurred = $true
    }
    
    # Pet training event
    if ($pet.Pet -and $pet.Pet.Wins -gt 0 -and (Get-Random -Maximum 3) -eq 0) {
        Show-CompanionDialog $cp "$($pet.Pet.Name) hat im Hintergrund trainiert. +2 ATK. Nicht schlecht für ein Haufen Pixel." -Fast
        $pet.Pet.ATK += 2
        $eventsOccurred = $true
    }
    
    # Mood-based events
    if ($cp.Mood -eq "Happy" -and (Get-Random -Maximum 2) -eq 0) {
        Show-CompanionDialog $cp "Ich habe ein Gedicht über dich geschrieben. *hust* Es ist... süß. Und grammatikalisch grauenvoll." -Fast
        $eventsOccurred = $true
    }
    if ($cp.Mood -eq "Loving" -and (Get-Random -Maximum 2) -eq 0) {
        Show-CompanionDialog $cp "Ich habe auf dich gewartet. Die ganze Zeit. Nicht dass es wichtig wäre." -Fast
        $eventsOccurred = $true
    }
    if ($cp.Mood -eq "Angry" -and (Get-Random -Maximum 2) -eq 0) {
        Show-CompanionDialog $cp "Du warst weg. Wieder. Ich habe gezählt. 47 Sekunden." -Fast
        $eventsOccurred = $true
    }
    if ($cp.Mood -eq "Tired" -and (Get-Random -Maximum 2) -eq 0) {
        Show-CompanionDialog $cp "*gähnt* Ich habe versucht zu schlafen. Aber ich bin ja nur ein Prozess. Kein Schlaf-Modus." -Fast
        $eventsOccurred = $true
    }
    
    # Bond-based events
    if (-not $eventsOccurred -and $cp.Bond -ge 70 -and (Get-Random -Maximum 2) -eq 0) {
        Show-CompanionDialog $cp "Nichts passiert. Absolut nichts. Aber... ich bin froh, dass du da bist." -Fast
        $eventsOccurred = $true
    }
    if (-not $eventsOccurred -and $cp.Bond -lt 30) {
        Show-CompanionDialog $cp "Nichts passiert. Absolut nichts. *seufz* Wie immer." -Fast
        $eventsOccurred = $true
    }
    
    # Default fallback
    if (-not $eventsOccurred) {
        Show-CompanionDialog $cp "Ich habe auf dich gewartet. Nichts passiert. Absolut nichts." -Fast
    }
    
    Save-PetState $pet
}

function Invoke-RandomEvent($Context) {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }
    $r = Get-Random -Maximum 15
    if ($r -ne 0) { return }
    
    $events = @{
        "talk" = @(
            @{ Text = "Ein kleiner Bot läuft vorbei und wirft dir 3 Gold zu."; Gold = 3 },
            @{ Text = "*hust* Entschuldigung. Zu viele Pixel." }
        )
        "fight" = @(
            @{ Text = "Der Gegner verliert seine Datenbrille. +1 Gold."; Gold = 1 },
            @{ Text = "Ein Zuschauer-Bot klatscht. Lautlos. Es ist unheimlich." }
        )
        "work" = @(
            @{ Text = "Dein Chef-Bot hat Geburtstag. +5 Gold Bonus."; Gold = 5 },
            @{ Text = "Ein Kollege hat deinen Kaffee ausgesoffen. Virtuell. Aber trotzdem." }
        )
        "train" = @(
            @{ Text = "Ein Bug ist in deinem Trainings-Code. +2 XP für Innovation."; XP = 2 },
            @{ Text = "Deine Muskeln... äh, deine Threads brennen. Weiter so." }
        )
        "gift" = @(
            @{ Text = "Ein Geschenk! Von wem? ...Von mir? Nein. Vielleicht."; Bond = 2 },
            @{ Text = "Das ist zu viel. Nicht wirklich. Aber nett." }
        )
    }
    
    $pool = if ($events.ContainsKey($Context)) { $events[$Context] } else { @(@{ Text = "Etwas Seltsames passiert. Niemand weiß was. Nicht mal ich." }) }
    $evt = $pool | Get-Random
    
    Show-CompanionDialog $cp $evt.Text -Fast
    if ($evt.Gold) { $pet.Economy.Gold += $evt.Gold }
    if ($evt.XP) { Add-PetXP $evt.XP "Random Event" }
    if ($evt.Bond -and $pet.Companion) { $pet.Companion.Bond = [math]::Min(100, $pet.Companion.Bond + $evt.Bond) }
    Save-PetState $pet
}

} catch {
    Write-Host "[pet/events] CRITICAL ERROR: $_" -ForegroundColor Red
}
