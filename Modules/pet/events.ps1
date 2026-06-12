# BUXE_OS v24.3 — PET EVENTS v2.0
# "While you were away", Random Encounters, Easter Eggs
# Jetzt mit Companion-Dialogen statt trockener Textzeilen.

try {

function Show-WhileAway {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }

    # Cooldown: While-Away nur einmal pro Stunde oder pro Sitzung
    $now = Get-Date
    if ($pet.Meta.LastWhileAway) {
        $last = [datetime]$pet.Meta.LastWhileAway
        if (($now - $last).TotalHours -lt 1) { return }
    }

    $hour = (Get-Date).Hour
    $eventsOccurred = $false

    # Night watch event
    if ($hour -ge 2 -and $hour -le 5) {
        Show-CompanionDialog $cp "Ich habe die Nachtwache gehalten. Ein Spam-Bot hat versucht, dich zu verkaufen. Ich habe ihn gelöscht. +15 Gold." -Fast
        $pet.Economy.Gold += 15
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

    $pet.Meta.LastWhileAway = $now.ToString("yyyy-MM-dd HH:mm")
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
            @{ Text = "Ein kleiner Bot läuft vorbei und wirft dir 10 Gold zu."; Gold = 10 },
            @{ Text = "*hust* Entschuldigung. Zu viele Pixel." }
        )
        "fight" = @(
            @{ Text = "Der Gegner verliert seine Datenbrille. +5 Gold."; Gold = 5 },
            @{ Text = "Ein Zuschauer-Bot klatscht. Lautlos. Es ist unheimlich." }
        )
        "work" = @(
            @{ Text = "Dein Chef-Bot hat Geburtstag. +15 Gold Bonus."; Gold = 15 },
            @{ Text = "Ein Kollege hat deinen Kaffee ausgesoffen. Virtuell. Aber trotzdem." }
        )
        "train" = @(
            @{ Text = "Ein Bug ist in deinem Trainings-Code. +3 XP für Innovation."; XP = 3 },
            @{ Text = "Deine Muskeln... äh, deine Threads brennen. Weiter so." }
        )
        "gift" = @(
            @{ Text = "Ein Geschenk! Von wem? ...Von mir? Nein. Vielleicht."; Bond = 3 },
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

function Add-PetMemory($Text, $Icon = "*") {
    $pet = Get-PetState
    $mem = @{
        Text = $Text
        Icon = $Icon
        Date = (Get-Date -Format "yyyy-MM-dd HH:mm")
    }
    $pet.Memories = @($mem) + $pet.Memories | Select-Object -First 20
    Save-PetState $pet
}

function Show-PetMemories {
    $pet = Get-PetState
    try { Clear-Host } catch {}
    Show-PetFrame "MEMORIES" -Double | Out-Null
    Write-Host ""
    if ($pet.Memories.Count -eq 0) {
        Write-Host "  Noch keine Memories. Zeit mit deinem Companion verbringen!" -ForegroundColor DarkGray
    } else {
        foreach ($m in $pet.Memories | Select-Object -First 10) {
            Write-Host "  $($m.Icon) $($m.Text)" -ForegroundColor White
            Write-Host "     $($m.Date)" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    Wait-Enter
}

# === QUEST SYSTEM ===
$script:PetQuestPool = @(
    @{ Type = "talk"; Text = "Sprich 3x mit deinem Companion."; Target = 3; RewardGold = 25; RewardBond = 5 }
    @{ Type = "fight"; Text = "Gewinne 1 Kampf."; Target = 1; RewardGold = 40; RewardBond = 8 }
    @{ Type = "work"; Text = "Arbeite 1x und verdiene Gold."; Target = 1; RewardGold = 30; RewardBond = 5 }
    @{ Type = "gift"; Text = "Gib deinem Companion 1 Geschenk."; Target = 1; RewardGold = 30; RewardBond = 6 }
    @{ Type = "casino"; Text = "Spiele 1 Casino-Spiel."; Target = 1; RewardGold = 25; RewardBond = 4 }
    @{ Type = "train"; Text = "Trainiere 1x."; Target = 1; RewardGold = 25; RewardBond = 5 }
    @{ Type = "pvp"; Text = "Gewinne 1 PvP-Kampf."; Target = 1; RewardGold = 50; RewardBond = 10 }
    @{ Type = "raid"; Text = "Erreiche Raid Phase 2."; Target = 1; RewardGold = 60; RewardBond = 12 }
    @{ Type = "cook"; Text = "Koche 1 Gericht fuer dein Pet."; Target = 1; RewardGold = 20; RewardBond = 4 }
    @{ Type = "shop"; Text = "Kaufe 1 Item im Shop."; Target = 1; RewardGold = 15; RewardBond = 3 }
)

function Get-DailyQuests {
    $pet = Get-PetState
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($pet.Meta.QuestDate -eq $today -and $pet.Quests -and $pet.Quests.Count -gt 0) { return $pet.Quests }
    $pool = $script:PetQuestPool | Sort-Object { Get-Random } | Select-Object -First 3
    $pet.Quests = @()
    foreach ($q in $pool) {
        $pet.Quests += @{ Type = $q.Type; Text = $q.Text; Target = $q.Target; Progress = 0; Completed = $false; Claimed = $false; RewardGold = $q.RewardGold; RewardBond = $q.RewardBond }
    }
    $pet.Meta.QuestDate = $today
    Save-PetState $pet
    return $pet.Quests
}

function Check-QuestProgress($Type, $Amount = 1) {
    $pet = Get-PetState
    if (-not $pet.Quests) { return }
    foreach ($q in $pet.Quests) {
        if ($q.Type -eq $Type -and -not $q.Completed) {
            $q.Progress += $Amount
            if ($q.Progress -ge $q.Target) { $q.Completed = $true }
        }
    }
    Save-PetState $pet
}

function Show-PetQuests {
    $pet = Get-PetState
    $quests = Get-DailyQuests
    try { Clear-Host } catch {}
    Show-PetFrame "DAILY QUESTS" -Double | Out-Null
    Write-Host ""
    if ($quests.Count -eq 0) { Write-Host "  Keine Quests verfuegbar." -ForegroundColor DarkGray }
    for ($i = 0; $i -lt $quests.Count; $i++) {
        $q = $quests[$i]
        $status = if ($q.Claimed) { "[CLAIMED]" } elseif ($q.Completed) { "[READY]" } else { "[$($q.Progress)/$($q.Target)]" }
        $color = if ($q.Claimed) { "DarkGray" } elseif ($q.Completed) { "Green" } else { "Yellow" }
        Write-Host "  $($i+1). $($q.Text) $status | Belohnung: $($q.RewardGold)G + $($q.RewardBond) Bond" -ForegroundColor $color
    }
    Write-Host ""
    Wait-Enter
}

function Claim-PetQuests {
    $pet = Get-PetState
    $quests = Get-DailyQuests
    $claimed = 0; $totalGold = 0; $totalBond = 0
    foreach ($q in $quests) {
        if ($q.Completed -and -not $q.Claimed) {
            $q.Claimed = $true
            $totalGold += $q.RewardGold
            $totalBond += $q.RewardBond
            $claimed++
        }
    }
    if ($claimed -gt 0) {
        $pet.Economy.Gold += $totalGold
        if ($pet.Companion) { $pet.Companion.Bond = [math]::Min(100, $pet.Companion.Bond + $totalBond) }
        Save-PetState $pet
        Write-Host "`n  $claimed Quest(s) abgeschlossen! +$totalGold G | +$totalBond Bond" -ForegroundColor Green
    } else {
        Write-Host "`n  Keine abgeschlossenen Quests zum Abholen." -ForegroundColor DarkGray
    }
    Wait-Enter
}

} catch {
    Write-Host "[pet/events] CRITICAL ERROR: $_" -ForegroundColor Red
}
