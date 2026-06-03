# BUXE_OS v24.2 — PET EVENTS v2.0
# "While you were away", Random Encounters, Easter Eggs

try {

function Show-WhileAway {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }
    $hour = (Get-Date).Hour
    $events = @()
    if ($hour -ge 2 -and $hour -le 5) { $events += "$($cp.Name) hat die Nachtwache gehalten und einen Spam-Bot vertrieben. +5 Gold."; $pet.Economy.Gold += 5 }
    if ($pet.Pet -and $pet.Pet.Wins -gt 0 -and (Get-Random -Maximum 3) -eq 0) { $events += "$($pet.Pet.Name) hat im Hintergrund trainiert. +2 ATK."; $pet.Pet.ATK += 2 }
    if ($cp.Mood -eq "Happy" -and (Get-Random -Maximum 2) -eq 0) { $events += "$($cp.Name) hat ein virtuelles Gedicht über dich geschrieben. Es ist... süß. Und grammatikalisch grauenvoll." }
    if ($events.Count -eq 0) { $events += "$($cp.Name) hat auf dich gewartet. Nichts passiert. Absolut nichts. *seufz*" }
    Save-PetState $pet
    foreach ($e in $events) { Write-Host "  [EVENT] $e" -ForegroundColor DarkGray; Start-Sleep -Milliseconds 300 }
}

function Invoke-RandomEvent($Context) {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }
    $r = Get-Random -Maximum 20
    if ($r -ne 0) { return }
    $events = @{
        "talk" = @("Ein kleiner Bot läuft vorbei und wirft dir 3 Gold zu.","$($cp.Name) hustet. *hust* Entschuldigung. Zu viele Pixel.")
        "fight" = @("Der Gegner verliert seine Datenbrille. +1 Gold.","Ein Zuschauer-Bot klatscht. Lautlos. Es ist unheimlich.")
        "work" = @("Dein Chef-Bot hat Geburtstag. +5 Gold Bonus.","Ein Kollege hat deinen Kaffee ausgesoffen. Virtuell. Aber trotzdem.")
    }
    $pool = if ($events.ContainsKey($Context)) { $events[$Context] } else { @("Etwas Seltsames passiert. Niemand weiß was. Nicht mal ich.") }
    $msg = $pool | Get-Random
    Write-Host "`n  [RANDOM] $msg" -ForegroundColor Cyan
    if ($msg -like "*Gold*") { $pet.Economy.Gold += 3 }
    Save-PetState $pet
}

} catch {
    Write-Host "[pet/events] CRITICAL ERROR: $_" -ForegroundColor Red
}
