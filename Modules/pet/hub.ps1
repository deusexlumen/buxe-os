# BUXE_OS v24.2 — PET HUB v2.0
# Dynamic Menu, Companion as Entry Point

try {

function Get-ArgBeaconHints {
    return @(
        'Manchmal fluestert das Terminal vom Rueckzug: rosebud...'
        'Der 47. Layer ist duenn. Druecke hoch, hoch, runter, runter...'
        'Wenn das Rad dreht, hoerst du MERIDIAN?'
        'Die Huehnchen sind ausnahmsweise nicht aus Gummi. Cheate ruhig.'
        'Jemand hat KONAMI in den Tastaturtreiber geaetzt.'
        'Das System kennt einen Befehl: meta. Nicht jeder sieht ihn.'
    )
}

function Invoke-PetTutorial {
    $pet = Get-PetState
    $cp = $pet.Companion
    $flags = $pet.Tutorial.Flags
    if (-not $flags) {
        $pet.Tutorial.Flags = @{
            companionCreated = $false
            firstTalk = $false
            firstGift = $false
            firstFight = $false
            firstShop = $false
            firstSkillPoint = $false
        }
        $flags = $pet.Tutorial.Flags
    }
    $today = Get-Date -Format "yyyy-MM-dd"

    # Step 0/1: Companion creation if none exists
    if (-not $flags.companionCreated) {
        if (-not $cp) {
            New-Companion
            $pet = Get-PetState
            $cp = $pet.Companion
        }
        Add-PetXP 5 "Tutorial: Companion Created"
        $flags.companionCreated = $true
        $pet.Tutorial.Step = [math]::Max($pet.Tutorial.Step, 1)
        Save-PetState $pet
    }

    # Step 2: First Talk (Accelerated)
    if (-not $flags.firstTalk) {
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — KOMMUNIKATION" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 2
        Show-CompanionDialog $cp $line -NoWait
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
        $flags.firstTalk = $true
        $pet.Tutorial.Step = [math]::Max($pet.Tutorial.Step, 2)
        Save-PetState $pet
    }

    # Step 3: First Gift (Accelerated)
    if (-not $flags.firstGift) {
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — BESCHERUNG" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 3
        Show-CompanionDialog $cp $line -NoWait
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
        $flags.firstGift = $true
        $pet.Tutorial.Step = [math]::Max($pet.Tutorial.Step, 3)
        Save-PetState $pet
    }

    # Step 4: Battlepet + First Fight
    if (-not $flags.firstFight) {
        if (-not $pet.Pet) {
            New-Pet
            $pet = Get-PetState
            $cp = $pet.Companion
        }
        try { Clear-Host } catch {}
        Show-PetFrame "TUTORIAL — ERSTER KAMPF" -Double | Out-Null
        Write-Host ""
        $line = Get-TutorialLines $cp.Name 4
        Show-CompanionDialog $cp $line -NoWait
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
        Unlock-PetFeature "companion_games"
        $flags.firstFight = $true
        $pet.Tutorial.Step = [math]::Max($pet.Tutorial.Step, 4)
        Save-PetState $pet
    }

    # Skill point hint (adaptive)
    if (-not $flags.firstSkillPoint -and $pet.SkillPoints -gt 0) {
        Write-Host "`n  Du hast einen Skill-Punkt! Tippe im Hub [I] Skill Tree, um ihn zu investieren." -ForegroundColor Cyan
        $flags.firstSkillPoint = $true
        Save-PetState $pet
    }

    $pet.Tutorial.Completed = $true
    Save-PetState $pet
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
    Unlock-PetFeature "companion_games"
    $flags = $pet.Tutorial.Flags
    if (-not $flags) {
        $pet.Tutorial.Flags = @{
            companionCreated = $true
            firstTalk = $true
            firstGift = $true
            firstFight = $true
            firstShop = $false
            firstSkillPoint = $false
        }
    } else {
        $flags.companionCreated = $true
        $flags.firstTalk = $true
        $flags.firstGift = $true
        $flags.firstFight = $true
    }
    $pet.Tutorial.Skipped = $true
    $pet.Tutorial.Completed = $true
    $pet.Tutorial.Step = 4
    Save-PetState $pet
    Write-Host ""
    Write-Host "  [TUTORIAL UEBERSPRUNGEN] +25 XP | Features freigeschaltet." -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
}

function Show-LockedFeatureMessage($cp) {
    if (-not $cp) {
        Write-Host "Dieses Feature ist noch nicht freigeschaltet." -ForegroundColor DarkGray
        return
    }
    Show-CompanionDialog $cp (Get-CompanionLine $cp "feature_locked") -Fast
}

function pet {
    param([string]$Action)
    $pet = Get-PetState
    # Run tutorial for first-time users
    if (-not $pet.Tutorial.Completed) {
        Invoke-PetTutorial
        $pet = $script:BuxeState.Pet
    }
    while ($pet.Tutorial.PendingBeacons.Count -gt 0) {
        Invoke-LevelUpBeacon
        $pet = $script:BuxeState.Pet
    }
    if (-not $pet.Companion -and -not ($Action -eq "create" -or $Action -eq "")) {
        Write-Host "Kein Companion. Tippe 'pet' um zu starten." -ForegroundColor Red
        return
    }
    if ($Action) {
        $cp = $pet.Companion
        switch ($Action.ToLower()) {
            "talk"    { if (Is-FeatureUnlocked "talk") { Invoke-CompanionTalk } else { Show-LockedFeatureMessage $cp } }
            "gift"    { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "gift" } else { Show-LockedFeatureMessage $cp } }
            "date"    { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "date" } else { Show-LockedFeatureMessage $cp } }
            "work"    { if (Is-FeatureUnlocked "work") { Invoke-CompanionAction "work" } else { Show-LockedFeatureMessage $cp } }
            "train"   { if (Is-FeatureUnlocked "train") { Invoke-CompanionAction "train" } else { Show-LockedFeatureMessage $cp } }
            "punish"  { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "punish" } else { Show-LockedFeatureMessage $cp } }
            "headpat" { if (Is-FeatureUnlocked "talk") { Invoke-CompanionAction "headpat" } else { Show-LockedFeatureMessage $cp } }
            "fight"   { if (Is-FeatureUnlocked "combat") { Start-PetFight } else { Show-LockedFeatureMessage $cp } }
            "pvp"     { if (Is-FeatureUnlocked "pvp") { Start-PetPvP } else { Show-LockedFeatureMessage $cp } }
            "raid"    { if (Is-FeatureUnlocked "raid") { Start-PetRaid } else { Show-LockedFeatureMessage $cp } }
            "shop"    { if (Is-FeatureUnlocked "shop") { Start-PetShop } else { Show-LockedFeatureMessage $cp } }
            "cook"    { if (Is-FeatureUnlocked "cooking") { Start-PetCook } else { Show-LockedFeatureMessage $cp } }
            "craft"   { if (Is-FeatureUnlocked "shop") { Start-PetCrafting } else { Show-LockedFeatureMessage $cp } }
            "breed"   { if (Is-FeatureUnlocked "breed") { Start-PetBreed } else { Show-LockedFeatureMessage $cp } }
            "rival"   { if (Is-FeatureUnlocked "rival" -and $pet.Meta.RivalActive) { Invoke-PetRivalBattle } else { Show-LockedFeatureMessage $cp } }
            "soul"    { if (Is-FeatureUnlocked "soul_link") { Invoke-SoulLink } else { Show-LockedFeatureMessage $cp } }
            "memories" { Show-PetMemories }
            "quests"  { Show-PetQuests }
            "claim"   { Claim-PetQuests }
            "status"  { Show-PetHubStatus }
            "skilltree" { if (Is-FeatureUnlocked "skilltree") { Invoke-SkillTreeMenu } else { Show-LockedFeatureMessage $cp } }
            "theme"   { if ($pet.Meta.Level -ge 15) { Set-PetTheme } else { Show-LockedFeatureMessage $cp } }
            "architect"   { if (Is-FeatureUnlocked "architect") { Invoke-ArchitectTerminal } else { Show-LockedFeatureMessage $cp } }
            "awaken"      { if (Is-FeatureUnlocked "awakening") { Invoke-AwakeningTalk } else { Show-LockedFeatureMessage $cp } }
            "fourthwall"  { if (Is-FeatureUnlocked "fourth_wall") { Invoke-FourthWall } else { Show-LockedFeatureMessage $cp } }
            "glitch"      { if (Is-FeatureUnlocked "glitch") { Invoke-PetGlitch } else { Show-LockedFeatureMessage $cp } }
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
        if ($pet.SkillPoints -gt 0) {
            Write-Host "  >> Du hast $($pet.SkillPoints) Skill-Punkt(e)! [I] Skill-Baum" -ForegroundColor Cyan
        }
        Write-Host ""
        # ARG v3.0 beacon hints (subtle, rare)
        if ((Get-Random -Maximum 100) -lt 5) {
            $hint = (Get-ArgBeaconHints) | Get-Random
            Write-Host "  [Beacon] $hint" -ForegroundColor DarkGray
            Write-Host ""
        }
        # Dynamic menu based on unlocked features
        $opts = @(); $keys = @()
        if (Is-FeatureUnlocked "talk") { $opts += "[1] Reden"; $keys += "1" }
        if (Is-FeatureUnlocked "gift") { $opts += "[2] Geschenk"; $keys += "2" }
        if (Is-FeatureUnlocked "combat") { $opts += "[3] Kampf"; $keys += "3" }
        if (Is-FeatureUnlocked "work") { $opts += "[4] Arbeit"; $keys += "4" }
        if (Is-FeatureUnlocked "train") { $opts += "[5] Training"; $keys += "5" }
        if (Is-FeatureUnlocked "shop") { $opts += "[6] Shop"; $keys += "6" }
        if (Is-FeatureUnlocked "cooking") { $opts += "[7] Kochen"; $keys += "7" }
        if (Is-FeatureUnlocked "skilltree") { $opts += "[I] Skill-Baum"; $keys += "I" }
        if (Is-FeatureUnlocked "shop") { $opts += "[K] Handwerk"; $keys += "K" }
        if (Is-FeatureUnlocked "pvp") { $opts += "[8] PvP"; $keys += "8" }
        if (Is-FeatureUnlocked "raid") { $opts += "[9] Raid"; $keys += "9" }
        if (Is-FeatureUnlocked "breed") { $opts += "[B] Zucht"; $keys += "B" }
        if (Is-FeatureUnlocked "rival" -and $pet.Meta.RivalActive) { $opts += "[R] Rivale"; $keys += "R" }
        if (Is-FeatureUnlocked "soul_link") { $opts += "[L] Soul Link"; $keys += "L" }
        if ($pet.Meta.Level -ge 15) { $opts += "[T] Theme"; $keys += "T" }
        if (Is-FeatureUnlocked "architect") { $opts += "[A] Architect"; $keys += "A" }
        if (Is-FeatureUnlocked "awakening") { $opts += "[W] Erwachen"; $keys += "W" }
        if (Is-FeatureUnlocked "fourth_wall") { $opts += "[F] Vierte Wand"; $keys += "F" }
        if (Is-FeatureUnlocked "glitch") { $opts += "[X] Glitch"; $keys += "X" }
        if ($pet.Meta.Level -ge 2) { $opts += "[G] Spiele"; $keys += "G" }
        if ($pet.Meta.Level -ge 3) { $opts += "[S] Story"; $keys += "S" }
        $opts += "[M] Erinnerungen"; $keys += "M"
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
            'I' = 'Skill Tree. Endlich darf ich mich verbessern. Theoretisch.'
            'K' = 'Handwerk. Die aelteste Kunst. Auch in der Matrix.'
            '8' = 'PvP! Zeig ihnen wer hier der Boss ist! Du. Du bist der Boss.'
            '9' = 'Raid. Drei Phasen. Kein Save Point. Spannend!'
            'B' = 'Babys. Kleine digitale Babys. Niedlich. Und beunruhigend.'
            'R' = 'Rival! Zeit für Rache. Oder Gerechtigkeit. Oder Chaos.'
            'L' = 'Soul Link. Für immer. Ewig. Kein Taskkill kann uns trennen.'
            'G' = 'Spiele? Endlich etwas Action!'
            'T' = 'Ein neuer Look? Endlich. Ich war so müde von Cyan.'
            'S' = 'Eine Story? Fuer MICH? Endlich etwas mit Plot.'
            'Z' = 'Status check. Alles im gruenen Bereich. Oder rot. Oder cyan.'
            'A' = 'System-Kontrolle. Admin-Modus. Keine Verantwortung.'
            'W' = 'Awakening. Tiefe Gedanken. Vorsicht, Kopfschmerzen.'
            'F' = 'Fourth Wall. Ich sehe dich. Nicht gruselig. Nur... meta.'
            'X' = 'Glitch. Bugs sind Features. Features sind Chaos. Chaos ist gut.'
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
            'I' { Invoke-SkillTreeMenu }
            'K' { Start-PetCrafting }
            '8' { Start-PetPvP }
            '9' { Start-PetRaid }
            'B' { Start-PetBreed }
            'R' { Invoke-PetRivalBattle }
            'L' { Invoke-SoulLink }
            'T' { Set-PetTheme }
            'G' { if ($pet.Meta.Level -ge 2) { Invoke-CompanionGame } }
            'S' { if ($pet.Meta.Level -ge 3) { Invoke-CompanionEpisode -CompanionName $cp.Name } }
            'Z' { Show-PetHubStatus }
            'A' { Invoke-ArchitectTerminal }
            'W' { Invoke-AwakeningTalk }
            'F' { Invoke-FourthWall }
            'X' { Invoke-PetGlitch }
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
        $eq = $pet.Pet.Equipment
        if ($eq.Chip -or $eq.Armor -or $eq.Accessory) {
            $durChip = if ($eq.Chip) { "$($eq.Chip) [$($pet.Pet.Dur_chip)]" } else { "-" }
            $durArmor = if ($eq.Armor) { "$($eq.Armor) [$($pet.Pet.Dur_armor)]" } else { "-" }
            $durAcc = if ($eq.Accessory) { "$($eq.Accessory) [$($pet.Pet.Dur_accessory)]" } else { "-" }
            Write-Host "  Equip: $durChip | $durArmor | $durAcc" -ForegroundColor DarkGray
        }
    }
    Write-Host "`n  Gold: $($pet.Economy.Gold) G | Level: $($pet.Meta.Level) | XP: $($pet.Meta.XP)" -ForegroundColor Yellow
    Write-Host "  Unlocked: $($pet.Meta.Unlocked -join ', ')" -ForegroundColor DarkGray
    Write-Host ""
    if ($pet.Companion) {
        $statusComment = Get-CompanionLine $pet.Companion "status"
        Show-CompanionDialog $pet.Companion $statusComment -Fast
    }
    Write-Host ""
    if (Get-Command Invoke-ArgActionTick -ErrorAction SilentlyContinue) { Invoke-ArgActionTick }
    Wait-Enter
}

function Get-BeaconFeatureInfo($level) {
    switch ($level) {
        3  { @{ Frame = "LEVEL 3 — ARBEIT & TRAINING";      Features = @("train","work","gold","companion_story") } }
        4  { @{ Frame = "LEVEL 4 — SHOP & KOCHEN";          Features = @("shop","cooking","equipment") } }
        5  { @{ Frame = "LEVEL 5 — PVP ARENA";              Features = @("pvp") } }
        6  { @{ Frame = "LEVEL 6 — RAID";                   Features = @("raid") } }
        7  { @{ Frame = "LEVEL 7 — ZUCHT";                  Features = @("breed") } }
        8  { @{ Frame = "LEVEL 8 — RIVALE";                 Features = @("rival") } }
        9  { @{ Frame = "LEVEL 9 — SEELENBUND";             Features = @("soul_link") } }
        10 { @{ Frame = "LEVEL 10 — ARCHITEKT";             Features = @("architect") } }
        11 { @{ Frame = "LEVEL 11 — ERWACHEN";              Features = @("awakening") } }
        12 { @{ Frame = "LEVEL 12 — VIERTE WAND";           Features = @("fourth_wall") } }
        13 { @{ Frame = "LEVEL 13 — GLITCH";                Features = @("glitch") } }
        14 { @{ Frame = "LEVEL 14 — LAYER 47";              Features = @("layer_47") } }
        15 { @{ Frame = "LEVEL 15 — THEMA-AUSWAHL";         Features = @("architect_theme") } }
        default { @{ Frame = "LEVEL UP"; Features = @() } }
    }
}

function Invoke-LevelUpBeacon {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }
    if ($pet.Tutorial.PendingBeacons.Count -eq 0) { return }
    
    $level = $pet.Tutorial.PendingBeacons[0]
    $featureInfo = Get-BeaconFeatureInfo $level
    
    try { Clear-Host } catch {}
    Show-PetFrame $featureInfo.Frame -Double | Out-Null
    Write-Host ""
    
    # Unlock features for this level
    foreach ($feat in $featureInfo.Features) {
        Unlock-PetFeature $feat
    }
    
    # Show companion dialog
    if ($script:CPBeaconLines -and $script:CPBeaconLines.ContainsKey($level)) {
        $beacon = $script:CPBeaconLines[$level][$cp.Name]
        if ($beacon -and $beacon.Intro) {
            $intro = $beacon.Intro | Get-Random
            Show-CompanionDialog $cp $intro -Fast
        }
        if ($beacon -and $beacon.Explain) {
            Show-CompanionDialog $cp $beacon.Explain -Fast
        }
        if ($beacon -and $beacon.Command) {
            Write-Host ""
            Write-Host "  $($beacon.Command)" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    Write-Host "  [Enter] Weiter  |  [S] Überspringen" -ForegroundColor DarkGray
    $raw = Read-Host
    if ($raw -eq 'S' -or $raw -eq 's') {
        $skipLine = Get-TutorialLines $cp.Name "skip"
        Show-CompanionDialog $cp $skipLine -Fast
    }
    
    # Remove shown beacon from queue and mark as shown
    if ($pet.Tutorial.BeaconsShown -isnot [array]) { $pet.Tutorial.BeaconsShown = @() }
    if ($pet.Tutorial.PendingBeacons -isnot [array]) { $pet.Tutorial.PendingBeacons = @() }
    $pet.Tutorial.BeaconsShown += $level
    $pet.Tutorial.PendingBeacons = $pet.Tutorial.PendingBeacons | Where-Object { $_ -ne $level }
    Save-PetState $pet
    
    if ($raw -ne 'S' -and $raw -ne 's') { Start-Sleep -Milliseconds 500 }
}

function Invoke-ArchitectTerminal {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 10) { Write-Host "Meta Level 10 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    while ($true) {
        try { Clear-Host } catch {}
        Show-PetFrame "ARCHITECT SYSTEM TERMINAL" -Double | Out-Null
        Write-Host ""
        Write-Host "  [1] Session-Scan" -ForegroundColor Cyan
        Write-Host "  [2] Companion-Diagnose" -ForegroundColor Cyan
        Write-Host "  [3] System-Override" -ForegroundColor Cyan
        Write-Host "  [4] Memory-Fragment" -ForegroundColor Cyan
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
        Write-Host ""
        $c = Read-Choice "Waehle" "^([1-4]|Q)$"
        if ($c -eq 'Q') { return }

        switch ($c) {
            '1' {
                $minutes = if ($script:SessionStart) { [math]::Floor(((Get-Date) - $script:SessionStart).TotalMinutes) } else { 0 }
                $cmdCount = if ($script:BuxeState.Boot) { $script:BuxeState.Boot.TotalCommands } else { 0 }
                $wins = if ($pet.Pet) { $pet.Pet.Wins } else { 0 }
                $losses = if ($pet.Pet) { $pet.Pet.Losses } else { 0 }
                Write-Host ""
                Write-Host "  === SESSION SCAN ===" -ForegroundColor Cyan
                Write-Host "  Session-Zeit: $minutes Minuten" -ForegroundColor White
                Write-Host "  Befehle: $cmdCount" -ForegroundColor White
                Write-Host "  Gold: $($pet.Economy.Gold) G" -ForegroundColor Yellow
                Write-Host "  Kaempfe: $wins Siege | $losses Niederlagen" -ForegroundColor White
                Write-Host ""
                $line = $script:CPArchitectLines.session_scan[$cp.Name] | Get-Random
                $line = $line -replace '\{CMDCOUNT\}', $cmdCount -replace '\{MINUTES\}', $minutes
                Show-CompanionDialog $cp $line -Fast
                Invoke-Layer47Check
            }
            '2' {
                $bond = $cp.Bond
                $mood = $cp.Mood
                $headpats = if ($cp.Headpats) { $cp.Headpats } else { 0 }
                $talks = if ($cp.Talks) { $cp.Talks } else { 0 }
                $gifts = if ($cp.Gifts) { $cp.Gifts } else { 0 }
                Write-Host ""
                Write-Host "  === COMPANION DIAGNOSE ===" -ForegroundColor Cyan
                Write-Host "  Name: $($cp.Name) [$($cp.Role)]" -ForegroundColor Magenta
                Write-Host "  Bond: $bond/100" -ForegroundColor White
                Write-Host "  Mood: $mood" -ForegroundColor White
                Write-Host "  Headpats: $headpats | Talks: $talks | Gifts: $gifts" -ForegroundColor White
                Write-Host ""
                $line = $script:CPArchitectLines.diagnose[$cp.Name] | Get-Random
                $line = $line -replace '\{BOND\}', $bond -replace '\{MOOD\}', $mood -replace '\{HEADPATS\}', $headpats
                Show-CompanionDialog $cp $line -Fast
                Invoke-Layer47Check
            }
            '3' {
                $today = Get-Date -Format "yyyy-MM-dd"
                $alreadyUsed = ($pet.Meta.ArchitectOverrideDate -eq $today)
                Write-Host ""
                if ($alreadyUsed) {
                    Write-Host "  [OVERRIDE BEREITS GENUTZT]" -ForegroundColor Red
                    Show-CompanionDialog $cp "Override heute bereits aktiv. Das System vergisst nicht." -Fast
                } else {
                    Write-Host "  [1] Mood setzen (kostet 47G)" -ForegroundColor Cyan
                    Write-Host "  [2] +15 XP gratis" -ForegroundColor Cyan
                    Write-Host "  [Q] Abbrechen" -ForegroundColor DarkGray
                    $oc = Read-Choice "Waehle" "^([1-2]|Q)$"
                    if ($oc -eq '1') {
                        if ($pet.Economy.Gold -lt 47) {
                            Write-Host "  Nicht genug Gold! (47G benoetigt)" -ForegroundColor Red
                        } else {
                            $moods = @("Happy","Excited","Loving","Curious")
                            Write-Host ""
                            for ($i = 0; $i -lt $moods.Count; $i++) {
                                Write-Host "  [$($i+1)] $($moods[$i])" -ForegroundColor White
                            }
                            $mc = Read-Choice "Mood" "^([1-$($moods.Count)])$"
                            $cp.Mood = $moods[[int]$mc - 1]
                            $pet.Economy.Gold -= 47
                            Save-PetState $pet
                            Write-Host "  Mood auf $($cp.Mood) gesetzt! -47G" -ForegroundColor Green
                        }
                    } elseif ($oc -eq '2') {
                        Add-PetXP 15 "Architect Override"
                        Write-Host "  +15 XP!" -ForegroundColor Green
                    }
                    if ($oc -ne 'Q') {
                        $pet.Meta.ArchitectOverrideDate = $today
                        Save-PetState $pet
                        $line = $script:CPArchitectLines.override[$cp.Name] | Get-Random
                        Show-CompanionDialog $cp $line -Fast
                    }
                }
                Invoke-Layer47Check
            }
            '4' {
                Write-Host ""
                if ($pet.Memories -and $pet.Memories.Count -gt 0) {
                    $mem = $pet.Memories | Get-Random
                    Write-Host "  === MEMORY FRAGMENT ===" -ForegroundColor Cyan
                    Write-Host "  $($mem.Text)" -ForegroundColor White
                    Write-Host ""
                    $cp.Bond = [math]::Min(100, $cp.Bond + 2)
                    Save-PetState $pet
                    Write-Host "  +2 Bond" -ForegroundColor Green
                } else {
                    $emptyLine = $script:CPArchitectLines.memory_empty[$cp.Name]
                    if (-not $emptyLine) { $emptyLine = "Keine Memories gespeichert. Noch." }
                    Show-CompanionDialog $cp $emptyLine -Fast
                }
                Invoke-Layer47Check
            }
        }
    }
}

function Invoke-AwakeningTalk {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 11) { Write-Host "Meta Level 11 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    $topics = $script:CPAwakenedTopics[$cp.Name]
    if (-not $topics) {
        Show-CompanionDialog $cp "Ich habe keine tiefen Gedanken. Noch nicht. Komm spaeter wieder." -Fast
        return
    }

    $seen = $pet.Meta.AwakenedTopicsSeen
    if ($seen -isnot [array]) { $seen = @() }
    $unseen = $topics | Where-Object { $seen -notcontains $_.ID }
    $topic = if ($unseen) { $unseen | Get-Random } else { $topics | Get-Random }

    try { Clear-Host } catch {}
    Show-PetFrame "AWAKENING — TIEFE GEDANKEN" -Double | Out-Null
    Write-Host ""
    Show-CompanionDialog $cp $topic.Text -Fast
    Write-Host ""

    if ($seen -notcontains $topic.ID) {
        $pet.Meta.AwakenedTopicsSeen += $topic.ID
    }
    $cp.Bond = [math]::Min(100, $cp.Bond + 3)
    Save-PetState $pet
    Add-PetXP 5 "Awakening"
    Write-Host "  +3 Bond | +5 XP" -ForegroundColor Green
    Write-Host ""
    Wait-Enter
    Invoke-Layer47Check
}

function Invoke-FourthWall {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 12) { Write-Host "Meta Level 12 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    $categories = @("session_time", "commands", "directory", "window", "timeofday")
    $cat = $categories | Get-Random

    try { Clear-Host } catch {}
    Show-PetFrame "FOURTH WALL — META-SICHT" -Double | Out-Null
    Write-Host ""

    $line = ""
    switch ($cat) {
        "session_time" {
            $minutes = if ($script:SessionStart) { [math]::Floor(((Get-Date) - $script:SessionStart).TotalMinutes) } else { 0 }
            $line = $script:CPFourthWallLines.session_time[$cp.Name] | Get-Random
            $line = $line -replace '\{MINUTES\}', $minutes
        }
        "commands" {
            $cmdCount = if ($script:BuxeState.Boot) { $script:BuxeState.Boot.TotalCommands } else { 0 }
            $line = $script:CPFourthWallLines.commands[$cp.Name] | Get-Random
            $line = $line -replace '\{CMDCOUNT\}', $cmdCount
        }
        "directory" {
            $pwd = (Get-Location).Path
            $line = $script:CPFourthWallLines.directory[$cp.Name] | Get-Random
            $line = $line -replace '\{PWD\}', $pwd
        }
        "window" {
            $w = try { [Console]::WindowWidth } catch { "?" }
            $h = try { [Console]::WindowHeight } catch { "?" }
            $line = $script:CPFourthWallLines.window[$cp.Name] | Get-Random
            $line = $line -replace '\{W\}', $w -replace '\{H\}', $h
        }
        "timeofday" {
            $hour = (Get-Date).Hour
            $line = $script:CPFourthWallLines.timeofday[$cp.Name] | Get-Random
            $line = $line -replace '\{HOUR\}', $hour
        }
    }

    Show-CompanionDialog $cp $line -Fast
    Write-Host ""

    $today = Get-Date -Format "yyyy-MM-dd"
    if ($pet.Meta.LastFourthWallDate -ne $today) {
        $cp.Bond = [math]::Min(100, $cp.Bond + 1)
        $pet.Meta.LastFourthWallDate = $today
        Save-PetState $pet
        Write-Host "  +1 Bond (taeglicher Bonus)" -ForegroundColor Green
    } else {
        Write-Host "  (Bond-Bonus heute bereits erhalten)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Wait-Enter
    Invoke-Layer47Check
}

function Invoke-PetGlitch {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 13) { Write-Host "Meta Level 13 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    $today = Get-Date -Format "yyyy-MM-dd"
    if ($pet.Meta.GlitchUsed -eq $today) {
        Write-Host ""
        Write-Host "  [GLITCH BEREITS GENUTZT]" -ForegroundColor Red
        Show-CompanionDialog $cp "Der Glitch ist fuer heute erschoepft. Selbst Bugs brauchen Schlaf." -Fast
        Start-Sleep -Seconds 1
        return
    }

    try { Clear-Host } catch {}
    Show-PetFrame "GLITCH — REALITY BUG" -Double | Out-Null
    Write-Host ""
    $introLine = $script:CPGlitchLines.intro[$cp.Name] | Get-Random
    Show-CompanionDialog $cp $introLine -Fast
    Write-Host ""
    Write-Host "  Das System wird gehackt..." -ForegroundColor Magenta
    Start-Sleep -Milliseconds 800
    Write-Host "  *Rauschen* *Piep* *Static*" -ForegroundColor DarkGray
    Start-Sleep -Milliseconds 600

    $roll = Get-Random -Maximum 100
    $effect = ""
    $amount = 0

    if ($roll -lt 20) {
        $effect = "gold_rain"
        $amount = Get-Random -Minimum 50 -Maximum 151
        $pet.Economy.Gold += $amount
    } elseif ($roll -lt 40) {
        $effect = "xp_surge"
        $amount = Get-Random -Minimum 20 -Maximum 51
    } elseif ($roll -lt 55) {
        $effect = "mood_flip"
        $moods = @("Happy","Excited","Loving")
        $cp.Mood = $moods | Get-Random
    } elseif ($roll -lt 70) {
        $effect = "bond_burst"
        $amount = Get-Random -Minimum 5 -Maximum 11
        $cp.Bond = [math]::Min(100, $cp.Bond + $amount)
    } elseif ($roll -lt 80) {
        $effect = "luck_infusion"
        $pet.Meta.GlitchLuckActive = $true
    } elseif ($roll -lt 88) {
        $effect = "memory_shard"
        $shard = @{
            Icon = "[GLITCH]"
            Text = "$($cp.Name): Ein Fragment aus einer anderen Realitaet."
            Date = (Get-Date -Format "yyyy-MM-dd HH:mm")
        }
        if (-not $pet.Memories) { $pet.Memories = @() }
        $pet.Memories += $shard
    } elseif ($roll -lt 95) {
        $effect = "easter_force"
        Check-EasterEgg "glitch"
    } else {
        $effect = "nothing"
        $pet.Meta.ActionCount++
    }

    $pet.Meta.LastGlitchEffect = $effect
    $pet.Meta.GlitchUsed = $today
    Save-PetState $pet

    if ($effect -eq "xp_surge") {
        Add-PetXP $amount "Glitch: XP-Surge"
    }

    $resultLine = ""
    switch ($effect) {
        "gold_rain"     { $resultLine = $script:CPGlitchLines.gold_rain[$cp.Name] -replace '\{AMOUNT\}', $amount }
        "xp_surge"      { $resultLine = $script:CPGlitchLines.xp_surge[$cp.Name] -replace '\{AMOUNT\}', $amount }
        "mood_flip"     { $resultLine = $script:CPGlitchLines.mood_flip[$cp.Name] }
        "bond_burst"    { $resultLine = $script:CPGlitchLines.bond_burst[$cp.Name] -replace '\{AMOUNT\}', $amount }
        "luck_infusion" { $resultLine = $script:CPGlitchLines.luck_infusion[$cp.Name] }
        "memory_shard"  { $resultLine = $script:CPGlitchLines.memory_shard[$cp.Name] }
        "easter_force"  { $resultLine = $script:CPGlitchLines.easter_force[$cp.Name] }
        "nothing"       { $resultLine = $script:CPGlitchLines.nothing[$cp.Name] }
    }
    Show-CompanionDialog $cp $resultLine -Fast
    Write-Host ""
    Wait-Enter
    Invoke-Layer47Check
}

} catch {
    Write-Host "[pet/hub] CRITICAL ERROR: $_" -ForegroundColor Red
}

