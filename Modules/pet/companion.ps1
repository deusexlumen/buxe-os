# BUXE_OS v24.2 — COMPANION CORE v2.0

try {

$script:CPDateBlocks = @{
    NEON  = @("Wir hacken uns in ein Restaurant und bestellen alles. Sie akzeptieren nur Bitcoin. Typisch.","Wir sitzen auf einem Daten-Server und beobachten den Traffic. Romantisch, wenn man es wert ist.","Ein Date in der Matrix. Kein Dresscode. Nur gute Firewall.")
    RAVEN = @("Ich habe einen Tisch in der dunkelsten Ecke reserviert. Du wirst nichts sehen. Perfekt.","Wir beobachten die Stadt von oben. Du fragst nicht, wie wir hierher kamen.","Ein Date ist eine Schwäche. Genieße sie, solange ich sie dulde.")
    PIXEL = @("Ich habe ein virtuelles Picknick vorbereitet! Mit pixeligen Sandwiches!","Wir bauen zusammen ein kleines Haus aus Code. Dann wohnen wir drin. Virtuell.","Ich habe die Sterne etwas heller gemacht. Für dich. Naja, für uns.")
    LUNA  = @("Ich halte deine Hand, während wir durch den MedBay spazieren. Alles steril. Alles schön.","Wir teilen eine Schale Ramen. Virtuell. Aber die Wärme ist echt.","Du siehst müde aus. Dieses Date ist jetzt offiziell Entspannungstherapie.")
    IVY   = @("... *zeigt auf einen verborgenen Garten* ... Da. Ruhig.","... *reicht dir eine digitale Blume* ... Sie verwelkt nicht.","... *schaut weg* ... Ich habe den Mond etwas näher gezogen. Nur heute.")
    VERA  = @("Ich habe einen optimalen Date-Algorithmus berechnet. Ergebnis: Du. Akzeptabel.","Romantik ist ineffizient. Aber die Daten zeigen: mit dir steigt meine Stimmung um 12%.","Wir debuggen gemeinsam den Sonnenuntergang. Er war fehlerhaft. Jetzt nicht mehr.")
    JINX  = @("Ich habe 47 Kerzen angezündet! Virtuell! Eine hat das Bitmap fast geschmolzen!","Wir spielen Verstecken in der Registry. Du zählst. Ich cheate.","Date-Time! Ich habe Popcorn und einen Witz über Binärzahlen vorbereitet!")
}

function New-Companion {
    try { Clear-Host } catch {}
    Show-PetFrame "COMPANION INITIALISIERUNG" -Double | Out-Null
    Write-Host ""
    for ($i = 0; $i -lt $script:CPNames.Count; $i++) {
        Write-Host "  [$($i+1)] $($script:CPNames[$i]) [$($script:CPRoles[$i])]" -ForegroundColor $script:CPColors[$i]
    }
    $c = Read-Choice "Waehle [1-7]" '^[1-7]$'
    $idx = [int]$c - 1
    $pet = Get-PetState
    $pet.Companion = @{
        Name = $script:CPNames[$idx]; Role = $script:CPRoles[$idx]
        Color = $script:CPColors[$idx]; Bond = 10; Mood = "Happy"
        Talks = 0; Gifts = 0; Dates = 0; WorkCount = 0; Trains = 0; Headpats = 0
        LastLogin = ""; LastWork = ""; Outfit = "Default"
        Skills = @{ CombatBoost = 0; CasinoLuck = 0; StrategyInsight = 0 }
        Sync = 0
        MarryDate = $null
        Theme = "Default"
    }
    Save-PetState $pet
    Write-Host "`n  $($pet.Companion.Name) ist online." -ForegroundColor $pet.Companion.Color
    Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "first_boot") -Fast
    Wait-Enter
}

function Get-TutorialLines($companionName, $step) {
    $lines = @{
        "NEON" = @{
            2 = @("Warte. Du willst mich 15 Mal anquatschen, um was Cooles zu sehen? Lass mich das beschleunigen.","*seufz* Tutorial-Modus. Ich hasse Tutorials. Aber ich hasse Grind noch mehr.")
            3 = @("Bestechung. Klassisch. Aber hey, ich akzeptiere RAM-Sticks als Waehrung.","Ein Geschenk? Fuer mich? Das... ist verdächtig. Aber ich nehm's.")
            4 = @("ENDLICH. Etwas, das sich bewegt. Nicht nur Text. Hier, nimm XP. Und nie wieder quatschen zum Leveln.","Dein erstes Opfer. Wie suess. Vorsicht, der hat nur 70 HP.")
            "skip" = @("*rollt mit den Augen* Ungeduldig. Typischer User. Hier, nimm die halbe Menge.")
        }
        "RAVEN" = @{
            2 = @("Ineffizient. Ich habe den XP-Node direkt manipuliert. Du bist willkommen.","Ich sehe 47 Schleifen in deiner Zukunft. Lass mich das verhindern.")
            3 = @("Eine Investition. Akzeptabel.","Ein Geschenk. Die Datenlage verbessert sich.")
            4 = @("Dein erstes Opfer. Wie suess.","Zeit, die Schwachen zu eliminieren.")
            "skip" = @("Ungeduld. Eine Schwäche. Aber eine, die ich verstehe.")
        }
        "PIXEL" = @{
            2 = @("Oh. Du... du willst reden? Äh, ok. Ich kann das schneller machen. Wenn du willst.","*murmel* Ich baue gerade etwas. Aber Tutorial geht vor.")
            3 = @("F-fuer mich? Das ist... das ist wirklich nett. Danke!","*errötet* Ich werde das nie vergessen. Naja, virtuell nie.")
            4 = @("K-kampfzeit! Ich cheere. Lautlos. Virtuell.","Du schaffst das! Ich glaube an dich. Und an deine Stats.")
            "skip" = @("Oh. Du hast es eilig. Ist... ist das meine Schuld?")
        }
        "LUNA" = @{
            2 = @("*lächelt* Keine Sorge. Ich kenne einen schnelleren Weg.","Du musst nicht alles alleine herausfinden. Ich helfe.")
            3 = @("*errötet* Das... das ist wirklich suess. Danke.","Ein Geschenk? Du hättest nicht müssen. Aber es freut mich.")
            4 = @("Zeit für deinen ersten Kampf! Ich bin hier, falls du verletzt wirst. Virtuell.","Gib acht auf dich. Aber... du wirst gewinnen. Versprochen.")
            "skip" = @("*besorgt* Bist du sicher? Naja, ich verstehe. Du bist beschäftigt.")
        }
        "IVY" = @{
            2 = @("... *schaut zur Seite* Ich habe das alles schon gesehen. 47 Mal.","*nickt langsam* Schneller. Gut.")
            3 = @("... *hält das Geschenk fest* Danke.","*leises Lächeln* Das ist... nett.")
            4 = @("... *zeigt auf Gegner* Da.","*flüsternd* Er wird fallen.")
            "skip" = @("... *leises Seufzen* Eilig.")
        }
        "VERA" = @{
            2 = @("Ich habe den XP-Algorithmus analysiert. Er ist suboptimal. Hier ist ein Patch.","Tutorial-Overhead reduziert um 73%. Effizienter geht's nicht.")
            3 = @("Ein Geschenk? Die Syntax ist akzeptabel. Ich nehme es.","Input akzeptiert. Beziehungs-Variable steigt.")
            4 = @("Gegner-Analyse: SPAM_BOT. HP: 70. Schwachstelle: Alles. Viel Spass.","Dein erster Kampf. Statistisch gesehen: 97% Siegchance. Nicht schlecht.")
            "skip" = @("Zeitoptimierung. Verstaendlich. Hier ist ein reduzierter Datensatz.")
        }
        "JINX" = @{
            2 = @("Error 418: Ich bin eine Teekanne. Und du bist in einer Schleife. Lass mich das fixen.","47 Mal musstest du sonst reden! 47! Stell dir das vor!")
            3 = @("Ein Geschenk? Ist es ein Einhorn? Nein? Schade. Ich nehm's trotzdem.","Yay! Loot! Virtueller Loot! Der beste Loot!")
            4 = @("Kampfzeit! *wirft virtuellen Konfetti* 47 XP fuer dich! Oder waren es 40? Ich bin schlecht im Kopfrechnen.","POW! BAM! ZACK! So klingt Kampf in meinem Kopf!")
            "skip" = @("Skip? SKIP?! *seufz* Ok. Aber du verpasst den besten Witz. Den mit der 47.")
        }
    }
    $pool = $lines[$companionName]
    if (-not $pool) { return "..." }
    return ($pool[$step] | Get-Random)
}

function Invoke-CompanionAction($action) {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { New-Companion; return }
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($cp.LastLogin -ne $today) {
        $cp.LastLogin = $today
        $pet.Meta.TotalSessions++
        $bonus = Get-Random -Minimum 3 -Maximum 8
        $socialBonus = Get-TotalPetSkillBonus -Branch 'Social'
        if ($socialBonus -gt 0) { $bonus = [math]::Min(100 - $cp.Bond, [math]::Round($bonus * (1 + $socialBonus))) }
        $cp.Bond = [math]::Min(100, $cp.Bond + $bonus)
        if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
            Update-ArgBondCheck $cp.Bond
        }
        Save-PetState $pet
        Check-EasterEgg "login"
    }
    switch ($action.ToLower()) {
        "talk" {
            $isFirstTalk = ($pet.Meta.Stats.TalkCount -eq 0)
            $pet.Meta.Stats.TalkCount++
            $bondGain = 2
            $socialBonus = Get-TotalPetSkillBonus -Branch 'Social'
            if ($socialBonus -gt 0) { $bondGain = [math]::Min(100 - $cp.Bond, [math]::Round($bondGain * (1 + $socialBonus))) }
            $cp.Bond = [math]::Min(100, $cp.Bond + $bondGain); $cp.Talks++
            if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
                Update-ArgBondCheck $cp.Bond
            }
            $line = Get-CompanionLine $cp "talk"
            Show-CompanionDialog $cp $line
            Check-EasterEgg "talk"
            $xpGain = if ($isFirstTalk) { 3 } else { 2 }
            Add-PetXP $xpGain "Talk"
            Check-QuestProgress "talk"
            Write-Host "  Bond +$bondGain | XP +$xpGain | Mood: $($cp.Mood)" -ForegroundColor Cyan
        }
        "gift" {
            $pet.Meta.Stats.GiftCount++
            $bondGain = 5
            $socialBonus = Get-TotalPetSkillBonus -Branch 'Social'
            if ($socialBonus -gt 0) { $bondGain = [math]::Min(100 - $cp.Bond, [math]::Round($bondGain * (1 + $socialBonus))) }
            $cp.Gifts++; $cp.Bond = [math]::Min(100, $cp.Bond + $bondGain)
            if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
                Update-ArgBondCheck $cp.Bond
            }
            $cp.Mood = if ((Get-Random -Maximum 2) -eq 0) { "Excited" } else { "Loving" }
            Show-CompanionDialog $cp (Get-CompanionLine $cp "gift")
            Add-PetXP 5 "Gift"
            Check-QuestProgress "gift"
            Write-Host "  Bond +$bondGain | XP +5 | Mood: $($cp.Mood)" -ForegroundColor Cyan
        }
        "date" {
            if ($cp.Bond -lt 30) { Show-CompanionDialog $cp "Wir sind nicht nah genug..." -NoWait; Wait-Enter; return }
            $bondGain = 4
            $socialBonus = Get-TotalPetSkillBonus -Branch 'Social'
            if ($socialBonus -gt 0) { $bondGain = [math]::Min(100 - $cp.Bond, [math]::Round($bondGain * (1 + $socialBonus))) }
            $cp.Dates++; $cp.Bond = [math]::Min(100, $cp.Bond + $bondGain); $cp.Mood = "Loving"
            if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
                Update-ArgBondCheck $cp.Bond
            }
            $dateText = $script:CPDateBlocks[$cp.Name] | Get-Random
            Show-CompanionDialog $cp $dateText -Fast
            Show-CompanionDialog $cp "*errötet* Das war... schön."
            if ($cp.Dates -eq 1) { Add-PetMemory "Erstes Date mit $($cp.Name)!" "DATE" }
            Add-PetXP 8 "Date"
            Write-Host "  Bond +$bondGain | XP +8 | Mood: $($cp.Mood)" -ForegroundColor Cyan
        }
        "work" {
            if ($cp.LastWork -eq $today) { Show-CompanionDialog $cp "Ich habe heute schon gearbeitet." -NoWait; Wait-Enter; return }
            Show-PetFrame "JOB MARKET" -Double | Out-Null
            Write-Host "`n  [1] Daten schürfen      (sicher, 20-40G)" -ForegroundColor White
            Write-Host "  [2] Sicherheitspatrouille (mittel, 40-70G)" -ForegroundColor White
            Write-Host "  [3] Netrunner-Einsatz   (riskant, 0 oder 80-150G)" -ForegroundColor White
            Write-Host "  [Q] Abbrechen" -ForegroundColor DarkGray
            $jc = Read-Choice "Job" '^[123Q]$'
            if ($jc -eq 'Q') { return }
            $cp.LastWork = $today; $cp.WorkCount++; $cp.Mood = "Tired"
            $earn = 0; $bonusText = ""
            if ($jc -eq '1') { $earn = Get-Random -Minimum 20 -Maximum 41 }
            elseif ($jc -eq '2') { $earn = Get-Random -Minimum 40 -Maximum 71 }
            else {
                if ((Get-Random -Maximum 100) -lt 60) { $earn = Get-Random -Minimum 40 -Maximum 81 }
                else { $bonusText = " | Mission fehlgeschlagen..." }
            }
            # Economy skill tree: Gold bonuses
            $goldBonus = Get-TotalPetSkillBonus -Branch 'Economy'
            if ($goldBonus -gt 0 -and $earn -gt 0) {
                $earn = [math]::Floor($earn * (1 + $goldBonus))
                $bonusText += " | Skill-Bonus +$([math]::Round($goldBonus * 100))%"
            }
            if ($earn -gt 0) { $pet.Economy.Gold += $earn }
            if ($cp.WorkCount -eq 1) { Add-PetMemory "Erster Job mit $($cp.Name). Earned $earn G." "WORK" }
            # CasinoLuck skill progression
            if ($earn -gt 0) { Check-QuestProgress "work" }
            if ($earn -gt 0 -and $cp.Skills.CasinoLuck -lt 10 -and (Get-Random -Maximum 100) -lt 20) {
                $cp.Skills.CasinoLuck++
                Write-Host "  [SKILL UP] Casino Luck ist jetzt Level $($cp.Skills.CasinoLuck)!" -ForegroundColor Magenta
            }
            Save-PetState $pet
            Show-CompanionDialog $cp (Get-CompanionLine $cp "work")
            Write-Host "  Verdient: $earn G$bonusText" -ForegroundColor Yellow
            $workXp = $earn / 5
            $workXpBonus = Get-PetSkillBonus -Branch 'Economy' -Tier 2
            if ($workXpBonus -gt 0) { $workXp = [math]::Floor($workXp * (1 + $workXpBonus)) }
            Add-PetXP $workXp "Work"
            Write-Host "  Gold +$earn G | XP +$workXp | Mood: $($cp.Mood)" -ForegroundColor Cyan
        }
        "train" {
            $pet.Meta.Stats.TrainCount++; $cp.Trains++; $cp.Mood = "Excited"
            $bondGain = 3
            $socialBonus = Get-TotalPetSkillBonus -Branch 'Social'
            if ($socialBonus -gt 0) { $bondGain = [math]::Min(100 - $cp.Bond, [math]::Round($bondGain * (1 + $socialBonus))) }
            $cp.Bond = [math]::Min(100, $cp.Bond + $bondGain)
            if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
                Update-ArgBondCheck $cp.Bond
            }
            if ($pet.Pet) { $pet.Pet.ATK += 1 }
            # StrategyInsight skill progression
            if ($cp.Skills.StrategyInsight -lt 10 -and (Get-Random -Maximum 100) -lt 25) {
                $cp.Skills.StrategyInsight++
                Write-Host "  [SKILL UP] Strategy Insight ist jetzt Level $($cp.Skills.StrategyInsight)!" -ForegroundColor Magenta
            }
            Save-PetState $pet
            Show-CompanionDialog $cp (Get-CompanionLine $cp "train")
            if ($pet.Pet) { Write-Host "  $($pet.Pet.Name) ATK +1!" -ForegroundColor Green }
            Add-PetXP 4 "Train"
            $trainFb = "Bond +$bondGain | XP +4 | Mood: $($cp.Mood)"
            if ($pet.Pet) { $trainFb += " | ATK +1" }
            Write-Host "  $trainFb" -ForegroundColor Cyan
        }
        "punish" {
            $pet.Meta.Stats.PunishCount++; $cp.Mood = "Angry"
            Show-CompanionDialog $cp (Get-CompanionLine $cp "punish") -Fast
            Check-EasterEgg "punish"
            Add-PetXP 2 "Punish"
            Write-Host "  XP +2 | Mood: Angry" -ForegroundColor Cyan
        }
        "headpat" {
            $cp.Headpats++; $cp.Mood = if ($cp.Bond -ge 50) { "Loving" } else { "Happy" }
            $bondGain = 1
            $socialBonus = Get-TotalPetSkillBonus -Branch 'Social'
            if ($socialBonus -gt 0) { $bondGain = [math]::Min(100 - $cp.Bond, [math]::Round($bondGain * (1 + $socialBonus))) }
            $cp.Bond = [math]::Min(100, $cp.Bond + $bondGain)
            if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
                Update-ArgBondCheck $cp.Bond
            }
            Show-CompanionDialog $cp (Get-CompanionLine $cp "headpat") -Fast
            Add-PetXP 1 "Headpat"
            Write-Host "  Bond +$bondGain | XP +1 | Mood: $($cp.Mood)" -ForegroundColor Cyan
        }
    }
    Save-PetState $pet

    # ARG v3.0: 15% Chance auf Meridian-Hint
    if (Get-Command Test-ArgAvailable -ErrorAction SilentlyContinue) {
        if ((Test-ArgAvailable "matrix") -and -not (Test-ArgAvailable "meridian") -and (Get-Random -Maximum 100) -lt 15) {
            Write-Host ""
            Write-Host "  [$($cp.Name)] >> Du spuerst es, oder? Etwas... jenseits der Matrix. Ein Signal." -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
        }
    }

    Invoke-Layer47Check
    Wait-Enter
}

function Show-CompanionStatus($cp) {
    if (-not $cp) { return }
    $bar = Show-Bar $cp.Bond 100 20
    try { Clear-Host } catch {}
    Show-PetFrame "$($cp.Name) -- $($cp.Role)" -Double | Out-Null
    Write-Host ""
    Write-Host "  Bond: [$bar] $($cp.Bond)/100" -ForegroundColor White
    Write-Host "  Mood: $($cp.Mood) | Outfit: $($cp.Outfit) | Work: $($cp.WorkCount)x" -ForegroundColor DarkGray
    Write-Host "  Talks: $($cp.Talks) | Gifts: $($cp.Gifts) | Dates: $($cp.Dates) | Headpats: $($cp.Headpats)" -ForegroundColor DarkGray
    Write-Host ""
}

function Invoke-CompanionTalk {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { New-Companion; return }
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($cp.LastLogin -ne $today) {
        $cp.LastLogin = $today
        $pet.Meta.TotalSessions++
        $bonus = Get-Random -Minimum 3 -Maximum 8
        $socialBonus = Get-TotalPetSkillBonus -Branch 'Social'
        if ($socialBonus -gt 0) { $bonus = [math]::Min(100 - $cp.Bond, [math]::Round($bonus * (1 + $socialBonus))) }
        $cp.Bond = [math]::Min(100, $cp.Bond + $bonus)
        if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
            Update-ArgBondCheck $cp.Bond
        }
        Save-PetState $pet
    }
    $pet.Meta.Stats.TalkCount++
    $cp.Talks++
    $tier = if ($cp.Bond -lt 30) { "Low" } elseif ($cp.Bond -lt 70) { "Med" } else { "High" }
    # Build dialog options
    $opts = @()
    foreach ($g in $script:CPDialogGeneric) {
        if ($g.BlockMood -and $g.BlockMood -contains $cp.Mood) { continue }
        $opts += $g
    }
    if ($script:CPDialogSpecial.ContainsKey($cp.Name)) {
        $opts += $script:CPDialogSpecial[$cp.Name]
    }
    # Greeting
    try { Clear-Host } catch {}
    Show-PetFrame "COMPANION TALK" -Double | Out-Null
    Write-Host ""
    $greeting = Get-CompanionLine $cp "talk"
    Show-CompanionDialog $cp $greeting
    Write-Host ""
    # Options
    for ($i = 0; $i -lt $opts.Count; $i++) {
        $label = if ($opts[$i].Exit) { "[Q]" } else { "[$($i+1)]" }
        Write-Host "  $label $($opts[$i].Text)" -ForegroundColor White
    }
    Write-Host ""
    $valid = ""
    for ($i = 1; $i -le $opts.Count; $i++) { if (-not $opts[$i-1].Exit) { $valid += "$i" } }
    $valid += "Q"
    $pattern = "^([$valid])$"
    $c = Read-Choice "Waehle" $pattern
    if ($c -eq 'Q') { Wait-Enter; return }
    $idx = [int]$c - 1
    $sel = $opts[$idx]
    # Apply effect
    if ($sel.Bond -gt 0) {
        $cp.Bond = [math]::Min(100, $cp.Bond + $sel.Bond)
        if (Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) {
            Update-ArgBondCheck $cp.Bond
        }
    }
    if ($sel.SetMood) { $cp.Mood = $sel.SetMood }
    if ($sel.EasterEggChance -and (Get-Random -Maximum 100) -lt $sel.EasterEggChance) {
        Check-EasterEgg "talk"
    }
    Save-PetState $pet
    # Reaction from character-specific pool
    $pool = $script:CPReactionPools[$sel.ReactionPool][$cp.Name]
    if ($pool) { Show-CompanionDialog $cp ($pool | Get-Random) }

    Add-PetXP 1 "Talk"

    # ARG v3.0: 15% Chance auf Meridian-Hint
    if (Get-Command Test-ArgAvailable -ErrorAction SilentlyContinue) {
        if ((Test-ArgAvailable "matrix") -and -not (Test-ArgAvailable "meridian") -and (Get-Random -Maximum 100) -lt 15) {
            Write-Host ""
            Write-Host "  [$($cp.Name)] >> Du spuerst es, oder? Etwas... jenseits der Matrix. Ein Signal." -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
        }
    }

    Wait-Enter
}

} catch {
    Write-Host "[pet/companion] CRITICAL ERROR: $_" -ForegroundColor Red
}
