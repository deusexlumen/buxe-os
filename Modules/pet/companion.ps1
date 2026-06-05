# BUXE_OS v24.2 — COMPANION CORE v2.0

try {

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
        $cp.Bond = [math]::Min(100, $cp.Bond + $bonus)
        Save-PetState $pet
        Check-EasterEgg "login"
    }
    switch ($action.ToLower()) {
        "talk" {
            $isFirstTalk = ($pet.Meta.Stats.TalkCount -eq 0)
            $pet.Meta.Stats.TalkCount++
            $gain = [math]::Min(100, $cp.Bond + 2); $cp.Bond = $gain; $cp.Talks++
            $line = Get-CompanionLine $cp "talk"
            Show-CompanionDialog $cp $line
            Check-EasterEgg "talk"
            $xpGain = if ($isFirstTalk) { 3 } else { 2 }
            Add-PetXP $xpGain "Talk"
            Check-QuestProgress "talk"
        }
        "gift" {
            $pet.Meta.Stats.GiftCount++
            $cp.Gifts++; $cp.Bond = [math]::Min(100, $cp.Bond + 5)
            $cp.Mood = if ((Get-Random -Maximum 2) -eq 0) { "Excited" } else { "Loving" }
            Show-CompanionDialog $cp (Get-CompanionLine $cp "gift")
            Add-PetXP 5 "Gift"
            Check-QuestProgress "gift"
        }
        "date" {
            if ($cp.Bond -lt 30) { Show-CompanionDialog $cp "Wir sind nicht nah genug..."; Wait-Enter; return }
            $cp.Dates++; $cp.Bond = [math]::Min(100, $cp.Bond + 4); $cp.Mood = "Loving"
            $dateText = @("Ihr schaut euch die digitale Aurora an.","Ihr teilt eine virtuelle Mahlzeit.","Ihr tanzt in Schwerelosigkeit.") | Get-Random
            Write-Host "`n  DATE: $dateText" -ForegroundColor Magenta
            Show-CompanionDialog $cp "*errötet* Das war... schön."
            if ($cp.Dates -eq 1) { Add-PetMemory "Erstes Date mit $($cp.Name)!" "DATE" }
            Add-PetXP 8 "Date"
        }
        "work" {
            if ($cp.LastWork -eq $today) { Show-CompanionDialog $cp "Ich habe heute schon gearbeitet."; Wait-Enter; return }
            Show-PetFrame "JOB MARKET" -Double | Out-Null
            Write-Host "`n  [1] Data Mining    (sicher, 10-20G)" -ForegroundColor White
            Write-Host "  [2] Security Patrol (mittel, 20-35G)" -ForegroundColor White
            Write-Host "  [3] Netrunner Mission (riskant, 0 oder 50-80G)" -ForegroundColor White
            Write-Host "  [Q] Abbrechen" -ForegroundColor DarkGray
            $jc = Read-Choice "Job" '^[123Q]$'
            if ($jc -eq 'Q') { return }
            $cp.LastWork = $today; $cp.WorkCount++; $cp.Mood = "Tired"
            $earn = 0; $bonusText = ""
            if ($jc -eq '1') { $earn = Get-Random -Minimum 10 -Maximum 21 }
            elseif ($jc -eq '2') { $earn = Get-Random -Minimum 20 -Maximum 36 }
            else {
                if ((Get-Random -Maximum 2) -eq 0) { $earn = Get-Random -Minimum 50 -Maximum 81 }
                else { $bonusText = " | Mission fehlgeschlagen..." }
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
            Add-PetXP ($earn / 5) "Work"
        }
        "train" {
            $pet.Meta.Stats.TrainCount++; $cp.Trains++; $cp.Mood = "Excited"
            $cp.Bond = [math]::Min(100, $cp.Bond + 3)
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
        }
        "punish" {
            $pet.Meta.Stats.PunishCount++; $cp.Mood = "Angry"
            $pun = @("*packt dein Kinn* Schau mich an.","Auf die Knie. Entschuldige dich.","*schlägt leicht* Mitleidswürdig." ) | Get-Random
            Write-Host "`n  [$($cp.Name)] $pun" -ForegroundColor Red
            Check-EasterEgg "punish"
            Add-PetXP 2 "Punish"
        }
        "headpat" {
            $cp.Headpats++; $cp.Mood = if ($cp.Bond -ge 50) { "Loving" } else { "Happy" }
            $cp.Bond = [math]::Min(100, $cp.Bond + 1)
            Write-Host "`n  Du streichelst $($cp.Name)." -ForegroundColor Cyan
            Add-PetXP 1 "Headpat"
        }
    }
    Save-PetState $pet
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
        $cp.Bond = [math]::Min(100, $cp.Bond + $bonus)
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
    Wait-Enter
}

} catch {
    Write-Host "[pet/companion] CRITICAL ERROR: $_" -ForegroundColor Red
}
