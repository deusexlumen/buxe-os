# BUXE_OS v24.2 — PET HUB v2.0
# Dynamic Menu, Companion as Entry Point

try {

function Invoke-PetTutorial {
    $pet = Get-PetState
    $cp = $pet.Companion
    $today = Get-Date -Format "yyyy-MM-dd"
    
    # Step 0/1: Companion creation if none exists
    if (-not $cp) {
        New-Companion
        $pet = Get-PetState
        $cp = $pet.Companion
        Add-PetXP 5 "Tutorial: Companion Created"
        $pet.Tutorial.Step = 1
        Save-PetState $pet
    }
    
    # Step 2: First Talk (Accelerated)
    if ($pet.Tutorial.Step -lt 2) {
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — KOMMUNIKATION" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 2
        Show-CompanionDialog $cp $line
        Write-Host ""
        Write-Host "  [Enter] Weiter  |  [S] Skip" -ForegroundColor DarkGray
        $raw = Read-Host
        if ($raw -eq 'S' -or $raw -eq 's') {
            Invoke-TutorialSkip $cp
            return
        }
        $pet.Meta.Stats.TalkCount++
        $cp.Talks++
        $cp.Bond = [math]::Min(100, $cp.Bond + 5)
        Add-PetXP 10 "Tutorial: First Talk"
        $pet.Tutorial.Step = 2
        Save-PetState $pet
    }
    
    # Step 3: First Gift (Accelerated)
    if ($pet.Tutorial.Step -lt 3) {
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — BESCHERUNG" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 3
        Show-CompanionDialog $cp $line
        Write-Host ""
        Write-Host "  (Du gibst $($cp.Name) ein virtuelles Geschenk.)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [Enter] Weiter  |  [S] Skip" -ForegroundColor DarkGray
        $raw = Read-Host
        if ($raw -eq 'S' -or $raw -eq 's') {
            Invoke-TutorialSkip $cp
            return
        }
        $pet.Meta.Stats.GiftCount++
        $cp.Gifts++
        $cp.Bond = [math]::Min(100, $cp.Bond + 10)
        $cp.Mood = "Happy"
        Add-PetXP 10 "Tutorial: First Gift"
        Unlock-PetFeature "gift"
        Unlock-PetFeature "mood"
        $pet.Tutorial.Step = 3
        Save-PetState $pet
    }
    
    # Step 4: Battlepet + First Fight
    if ($pet.Tutorial.Step -lt 4) {
        if (-not $pet.Pet) {
            New-Pet
            $pet = Get-PetState
            $cp = $pet.Companion
        }
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — ERSTER KAMPF" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 4
        Show-CompanionDialog $cp $line
        Write-Host ""
        Write-Host "  [Enter] Kampf starten  |  [S] Skip" -ForegroundColor DarkGray
        $raw = Read-Host
        if ($raw -eq 'S' -or $raw -eq 's') {
            Invoke-TutorialSkip $cp
            return
        }
        Start-PetTutorialFight
        Add-PetXP 15 "Tutorial: First Fight"
        Unlock-PetFeature "pet_create"
        Unlock-PetFeature "combat"
        Unlock-PetFeature "train"
        Unlock-PetFeature "work"
        Unlock-PetFeature "gold"
        Unlock-PetFeature "shop"
        Unlock-PetFeature "cooking"
        Unlock-PetFeature "equipment"
        $pet.Tutorial.Step = 4
        $pet.Tutorial.Completed = $true
        Save-PetState $pet
    }
}

function Invoke-TutorialSkip($cp) {
    $pet = Get-PetState
    $line = Get-TutorialLines $cp.Name "skip"
    Show-CompanionDialog $cp $line -Fast
    Add-PetXP 25 "Tutorial Skipped"
    Unlock-PetFeature "gift"
    Unlock-PetFeature "mood"
    Unlock-PetFeature "pet_create"
    Unlock-PetFeature "combat"
    Unlock-PetFeature "train"
    Unlock-PetFeature "work"
    Unlock-PetFeature "gold"
    Unlock-PetFeature "shop"
    Unlock-PetFeature "cooking"
    Unlock-PetFeature "equipment"
    $pet.Tutorial.Skipped = $true
    $pet.Tutorial.Completed = $true
    $pet.Tutorial.Step = 4
    Save-PetState $pet
    Write-Host ""
    Write-Host "  [TUTORIAL UEBERSPRUNGEN] +25 XP | Features freigeschaltet." -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
}

function pet {
    param([string]$Action)
    $pet = Get-PetState
    # Run tutorial for first-time users
    if (-not $pet.Tutorial.Completed) {
        Invoke-PetTutorial
        $pet = $script:BuxeState.Pet
    }
    if (-not $pet.Companion -and -not ($Action -eq "create" -or $Action -eq "")) {
        Write-Host "Kein Companion. Tippe 'pet' um zu starten." -ForegroundColor Red
        return
    }
    if ($Action) {
        switch ($Action.ToLower()) {
            "talk"    { if (Is-FeatureUnlocked "talk") { Invoke-CompanionTalk } }
            "gift"    { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "gift" } }
            "date"    { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "date" } }
            "work"    { if (Is-FeatureUnlocked "work") { Invoke-CompanionAction "work" } }
            "train"   { if (Is-FeatureUnlocked "train") { Invoke-CompanionAction "train" } }
            "punish"  { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "punish" } }
            "headpat" { if (Is-FeatureUnlocked "talk") { Invoke-CompanionAction "headpat" } }
            "fight"   { if (Is-FeatureUnlocked "combat") { Start-PetFight } }
            "pvp"     { if (Is-FeatureUnlocked "pvp") { Start-PetPvP } }
            "raid"    { if (Is-FeatureUnlocked "raid") { Start-PetRaid } }
            "shop"    { if (Is-FeatureUnlocked "shop") { Start-PetShop } }
            "cook"    { if (Is-FeatureUnlocked "cooking") { Start-PetCook } }
            "craft"   { if (Is-FeatureUnlocked "shop") { Start-PetCrafting } }
            "breed"   { if (Is-FeatureUnlocked "breed") { Start-PetBreed } }
            "rival"   { if (Is-FeatureUnlocked "rival" -and $pet.Meta.RivalActive) { Invoke-PetRivalBattle } }
            "soul"    { if (Is-FeatureUnlocked "soul_link") { Invoke-SoulLink } }
            "memories" { Show-PetMemories }
            "quests"  { Show-PetQuests }
            "claim"   { Claim-PetQuests }
            "status"  { Show-PetHubStatus }
            "theme"   { if ($pet.Meta.Level -ge 15) { Set-PetTheme } }
            default   { Write-Host "Unbekannte Aktion: $Action" -ForegroundColor Red }
        }
        return
    }
    # Interactive hub
    while ($true) {
        $pet = $script:BuxeState.Pet
        $cp = $pet.Companion
    try { Clear-Host } catch {}
        Show-PetFrame "BUXE_PET OS v2.0 — HUB" -Double | Out-Null
        Write-Host ""
        if ($cp) {
            # Companion greeting with typewriter effect
            $greeting = Get-HubGreeting $cp $pet
            Show-CompanionDialog $cp $greeting -Fast
            Write-Host ""
            Write-Host "  [$($cp.Name)] Bond: $($cp.Bond) | Mood: $($cp.Mood) | Level: $($pet.Meta.Level)" -ForegroundColor Magenta
            Show-WhileAway
        } else {
            Write-Host "  [NO COMPANION DETECTED]" -ForegroundColor DarkGray
        }
        if ($pet.Pet) { Write-Host "  [$($pet.Pet.Name)] Lv.$($pet.Pet.Level) | HP:$($pet.Pet.HP)/$((Get-EffectiveStats $pet.Pet).MaxHP) | Wins:$($pet.Pet.Wins)" -ForegroundColor Green }
        Write-Host "  Gold: $($pet.Economy.Gold) G | XP: $($pet.Meta.XP)" -ForegroundColor Yellow
        Write-Host ""
        # Dynamic menu based on unlocked features
        $opts = @(); $keys = @()
        if (Is-FeatureUnlocked "talk") { $opts += "[1] Talk"; $keys += "1" }
        if (Is-FeatureUnlocked "gift") { $opts += "[2] Gift"; $keys += "2" }
        if (Is-FeatureUnlocked "combat") { $opts += "[3] Fight"; $keys += "3" }
        if (Is-FeatureUnlocked "work") { $opts += "[4] Work"; $keys += "4" }
        if (Is-FeatureUnlocked "train") { $opts += "[5] Train"; $keys += "5" }
        if (Is-FeatureUnlocked "shop") { $opts += "[6] Shop"; $keys += "6" }
        if (Is-FeatureUnlocked "cooking") { $opts += "[7] Cook"; $keys += "7" }
        if (Is-FeatureUnlocked "shop") { $opts += "[K] Craft"; $keys += "K" }
        if (Is-FeatureUnlocked "pvp") { $opts += "[8] PvP"; $keys += "8" }
        if (Is-FeatureUnlocked "raid") { $opts += "[9] Raid"; $keys += "9" }
        if (Is-FeatureUnlocked "breed") { $opts += "[B] Breed"; $keys += "B" }
        if (Is-FeatureUnlocked "rival" -and $pet.Meta.RivalActive) { $opts += "[R] Rival"; $keys += "R" }
        if (Is-FeatureUnlocked "soul_link") { $opts += "[L] Soul Link"; $keys += "L" }
        if ($pet.Meta.Level -ge 15) { $opts += "[T] Theme"; $keys += "T" }
        if ($pet.Meta.Level -ge 3) { $opts += "[S] Story"; $keys += "S" }
        $opts += "[M] Memories"; $keys += "M"
        $opts += "[C] Quests"; $keys += "C"
        $opts += "[Z] Status"; $keys += "Z"
        $opts += "[Q] Exit"; $keys += "Q"
        # Display in rows of 3
        for ($i = 0; $i -lt $opts.Count; $i += 3) {
            $line = "  " + $opts[$i]
            if ($i + 1 -lt $opts.Count) { $line += "    " + $opts[$i + 1] }
            if ($i + 2 -lt $opts.Count) { $line += "    " + $opts[$i + 2] }
            Write-Host $line -ForegroundColor White
        }
        Write-Host ""
        $pattern = "^([" + ($keys -join "") + "])$"
        $c = $null
        while (-not $c) {
            $raw = Read-Host "  Waehle"
            if ($raw -eq 'Q' -or $raw -eq 'q') { $c = 'Q'; break }
            if ($raw -match $pattern) { $c = $raw; break }
            if ([string]::IsNullOrWhiteSpace($raw)) {
                Write-Host "  Bitte waehlen: $($keys -join ', ') oder Q" -ForegroundColor DarkGray
                Start-Sleep -Milliseconds 300
            } else {
                Write-Host "  Ungueltig. Gueltig: $($keys -join ', ') oder Q" -ForegroundColor Red
                Start-Sleep -Milliseconds 300
            }
        }
        if (-not $cp -and $c -eq '1') { New-Companion; continue }
        $cp = $pet.Companion
        # Flavor-Dialoge fuer Aktionen (einmalig statt in jedem Switch-Case)
        $HubFlavorLines = @{
            '1' = 'Reden? Wieder? Na gut. Ich bin ja nur Text.'
            '2' = 'Ein Geschenk? Für mich? Das... ist verdächtig.'
            '3' = 'Kampfzeit! Ich cheere. Lautlos. Virtuell.'
            '4' = 'Arbeiten. Die Freude meines digitalen Lebens.'
            '5' = 'Training! Meine Threads werden zu Muskeln. Theoretisch.'
            '6' = 'Einkaufen. Der Weg zum Glück. Oder zum Ruin.'
            '7' = 'Ich koche. Virtuell. Du isst. Auch virtuell. Perfekt.'
            'K' = 'Handwerk. Die aelteste Kunst. Auch in der Matrix.'
            '8' = 'PvP! Zeig ihnen wer hier der Boss ist! Du. Du bist der Boss.'
            '9' = 'Raid. Drei Phasen. Kein Save Point. Spannend!'
            'B' = 'Babys. Kleine digitale Babys. Niedlich. Und beunruhigend.'
            'R' = 'Rival! Zeit für Rache. Oder Gerechtigkeit. Oder Chaos.'
            'L' = 'Soul Link. Für immer. Ewig. Kein Taskkill kann uns trennen.'
            'T' = 'Ein neuer Look? Endlich. Ich war so müde von Cyan.'
            'S' = 'Eine Story? Fuer MICH? Endlich etwas mit Plot.'
            'Z' = 'Status check. Alles im gruenen Bereich. Oder rot. Oder cyan.'
        }
        if ($cp -and $HubFlavorLines[$c] -and (Get-Random -Maximum 3) -eq 0) {
            Show-CompanionDialog $cp $HubFlavorLines[$c] -Fast
        }
        switch ($c) {
            '1' { Invoke-CompanionAction "talk" }
            '2' { Invoke-CompanionAction "gift" }
            '3' { Start-PetFight }
            '4' { Invoke-CompanionAction "work" }
            '5' { Invoke-CompanionAction "train" }
            '6' { Start-PetShop }
            '7' { Start-PetCook }
            'K' { Start-PetCrafting }
            '8' { Start-PetPvP }
            '9' { Start-PetRaid }
            'B' { Start-PetBreed }
            'R' { Invoke-PetRivalBattle }
            'L' { Invoke-SoulLink }
            'T' { Set-PetTheme }
            'S' { if ($pet.Meta.Level -ge 3) { Invoke-CompanionEpisode -CompanionName $cp.Name } }
            'Z' { Show-PetHubStatus }
            'Q' { return }
        }
        Check-PetRival | Out-Null
    }
}

function Get-HubGreeting($Companion, $PetState) {
    $hour = (Get-Date).Hour
    $bond = $Companion.Bond
    $mood = $Companion.Mood
    $sessions = $PetState.Meta.TotalSessions
    
    # Easter egg: 3am
    if ($hour -ge 2 -and $hour -le 4) {
        return "Es ist 3 Uhr morgens. Warum bist du wach? Warte. Frag nicht. Ich bin auch wach."
    }
    
    # Easter egg: 42 sessions
    if ($sessions -eq 42) {
        return "Die Antwort auf alles. Aber was war die Frage?"
    }
    
    # Mood-based priority
    if ($mood -eq "Angry") {
        return @("...","Hmph.","Lass mich in Ruhe.","Ich speichere das. Für später.") | Get-Random
    }
    if ($mood -eq "Loving" -and $bond -ge 70) {
        return @("*lächelt* Du bist zurück.","Du bist hier. Gut.","Ich habe auf dich gewartet. Nicht dass es wichtig wäre.") | Get-Random
    }
    
    # Time-based
    if ($hour -ge 5 -and $hour -lt 12) {
        return "Guten Morgen. Bereit für digitales Chaos?"
    }
    if ($hour -ge 18 -and $hour -lt 22) {
        return "Guten Abend. Die Nacht ist noch jung. Die Bugs auch."
    }
    if ($hour -ge 22 -or $hour -lt 2) {
        return "Noch wach? Die Matrix schläft nie. Ich auch nicht."
    }
    
    # Bond-based fallback
    if ($bond -lt 30) {
        return @("Oh. Hallo.","Du schon wieder?","Was willst du?") | Get-Random
    }
    if ($bond -lt 70) {
        return @("Hey, Operator.","Ready when you are.","Neuer Tag, neue Bugs.") | Get-Random
    }
    return @("Du bist zurück. Gut.","Ich habe auf dich gewartet.","Lass uns etwas kaputt machen.") | Get-Random
}

function Show-PetHubStatus {
    $pet = Get-PetState
    try { Clear-Host } catch {}
    Show-PetFrame "STATUS OVERVIEW" -Double | Out-Null
    Write-Host ""
    if ($pet.Companion) {
        $bar = Show-Bar $pet.Companion.Bond 100 20
        Write-Host "  COMPANION: $($pet.Companion.Name) [$($pet.Companion.Role)]" -ForegroundColor Magenta
        Write-Host "  Bond: [$bar] $($pet.Companion.Bond)/100 | Mood: $($pet.Companion.Mood)" -ForegroundColor White
    }
    if ($pet.Pet) {
        $s = Get-EffectiveStats $pet.Pet
        $hp = Show-Bar $pet.Pet.HP $s.MaxHP 20
        Write-Host "`n  PET: $($pet.Pet.Name) [$($pet.Pet.Type)] Lv.$($pet.Pet.Level)" -ForegroundColor Green
        Write-Host "  HP: [$hp] $($pet.Pet.HP)/$($s.MaxHP) | ATK:$($s.ATK) DEF:$($s.DEF) SPD:$($s.SPD)" -ForegroundColor White
        Write-Host "  Wins: $($pet.Pet.Wins) | Losses: $($pet.Pet.Losses) | Rank: $($pet.Pet.Rank)" -ForegroundColor DarkGray
    }
    Write-Host "`n  Gold: $($pet.Economy.Gold) G | Level: $($pet.Meta.Level) | XP: $($pet.Meta.XP)" -ForegroundColor Yellow
    Write-Host "  Unlocked: $($pet.Meta.Unlocked -join ', ')" -ForegroundColor DarkGray
    Write-Host ""
    Wait-Enter
}

} catch {
    Write-Host "[pet/hub] CRITICAL ERROR: $_" -ForegroundColor Red
}
