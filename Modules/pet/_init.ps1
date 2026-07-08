# BUXE_OS v24.2 — PET SYSTEM CORE v2.0
# State, Schema, Meta-Progression

try {

$script:PetXPTable = @(0, 3, 15, 40, 100, 300, 600, 1200, 2500, 5000, 10000, 15000, 22000, 32000, 47000, 70000)
$script:PetFeatureUnlocks = @{
    0 = @("talk", "companion_create")
    1 = @("gift", "mood")
    2 = @("pet_create", "combat", "companion_games", "skilltree")
    3 = @("train", "work", "gold", "companion_story")
    4 = @("shop", "cooking", "equipment")
    5 = @("pvp")
    6 = @("raid")
    7 = @("breed")
    8 = @("rival")
    9 = @("soul_link")
    10 = @("architect")
    11 = @("awakening")
    12 = @("fourth_wall")
    13 = @("glitch")
    14 = @("layer_47")
    15 = @("architect_theme")
}

function Get-PetDefaults {
    return @{
        Meta = @{
            Level = 0
            XP = 0
            Unlocked = @("talk", "companion_create")
            FirstBoot = (Get-Date -Format "yyyy-MM-dd")
            TotalSessions = 0
            PlayTimeMinutes = 0
            EasterEggsFound = @()
            Stats = @{
                TalkCount = 0; GiftCount = 0; PunishCount = 0
                FightCount = 0; WorkCount = 0; TrainCount = 0
            }
            QuestDate = ""
            GlitchUsed = ""
            ActionCount = 0
            GlitchLuckActive = $false
            AwakenedTopicsSeen = @()
            LastGlitchEffect = ""
            LastFourthWallDate = ""
            ArchitectOverrideDate = ""
            RivalActive = $false
            LastWhileAway = ""
            AuditSuspicion = 0
            SourceDebt = 0
            SessionCount = 0
            Act1Pending = $false
            Act1Done = $false
        }
        Companion = $null
        Pet = $null
        CompanionStories = @{
            NEON  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            RAVEN = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            PIXEL = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            LUNA  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            IVY   = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            VERA  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            JINX  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
        }
        CompanionGames = @{
            Wins = 0
            Losses = 0
            ChaosChipsHighscore = 0
            MemoryBestTime = 999
            FortyTwoBestGuesses = 999
        }
        Economy = @{ Gold = 500; Inventory = @() }
        Achievements = @()
        Memories = @()
        SkillTree = @{
            Combat = @{ Level = 0; MaxLevel = 5; Perks = @('Damage +5%','Crit +5%','Damage +10%','Crit +10%','Ultimate: Rage') }
            Economy = @{ Level = 0; MaxLevel = 5; Perks = @('Gold +5%','Work XP +10%','Shop Discount 5%','Gold +10%','Ultimate: Midas') }
            Social = @{ Level = 0; MaxLevel = 5; Perks = @('Bond +5%','Mood +5%','Gift Bonus +10%','Bond +10%','Ultimate: Charm') }
        }
        SkillPoints = 0
        Tutorial = @{
            Completed     = $false
            Step          = 0
            Skipped       = $false
            PendingBeacons = @()
            BeaconsShown  = @()
            Flags = @{
                companionCreated = $false
                firstTalk = $false
                firstGift = $false
                firstFight = $false
                firstShop = $false
                firstSkillPoint = $false
            }
        }
    }
}

function Get-PetState {
    Load-State
    if (-not $script:BuxeState.Pet) {
        $script:BuxeState.Pet = (Get-PetDefaults)
        Save-State
    } else {
        # Lazy Migration: nur wenn Load-State sie noch nicht durchgefuehrt hat
        if (-not $script:BuxeState.Pet.ContainsKey("Tutorial")) {
            $script:BuxeState.Pet.Tutorial = @{ Completed = $true; Step = 0; Skipped = $false }
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("GlitchUsed")) {
            $script:BuxeState.Pet.Meta.GlitchUsed = ""
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("ActionCount")) {
            $script:BuxeState.Pet.Meta.ActionCount = 0
            Save-State
        }
        # Lazy migration: CompanionGames (Phase 2)
        if (-not $script:BuxeState.Pet.ContainsKey("CompanionGames")) {
            $script:BuxeState.Pet.CompanionGames = @{
                Wins = 0
                Losses = 0
                ChaosChipsHighscore = 0
                MemoryBestTime = 999
                FortyTwoBestGuesses = 999
            }
            Save-State
        }
        # Lazy migration: Beacon System (v24.11)
        if (-not $script:BuxeState.Pet.Tutorial.ContainsKey("PendingBeacons") -or
            $script:BuxeState.Pet.Tutorial.PendingBeacons -isnot [array]) {
            $oldPending = @()
            if ($script:BuxeState.Pet.Tutorial.PendingBeacons) {
                $oldPending = @($script:BuxeState.Pet.Tutorial.PendingBeacons)
            }
            $script:BuxeState.Pet.Tutorial.PendingBeacons = $oldPending
            Save-State
        }
        if (-not $script:BuxeState.Pet.Tutorial.ContainsKey("BeaconsShown") -or
            $script:BuxeState.Pet.Tutorial.BeaconsShown -isnot [array]) {
            $oldShown = @()
            if ($script:BuxeState.Pet.Tutorial.BeaconsShown) {
                $oldShown = @($script:BuxeState.Pet.Tutorial.BeaconsShown)
            }
            $script:BuxeState.Pet.Tutorial.BeaconsShown = $oldShown
            Save-State
        }
        # Lazy migration: Hollow Promises v24.x
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("GlitchLuckActive")) {
            $script:BuxeState.Pet.Meta.GlitchLuckActive = $false
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("AwakenedTopicsSeen") -or
            $script:BuxeState.Pet.Meta.AwakenedTopicsSeen -isnot [array]) {
            $script:BuxeState.Pet.Meta.AwakenedTopicsSeen = @()
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("LastGlitchEffect")) {
            $script:BuxeState.Pet.Meta.LastGlitchEffect = ""
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("LastFourthWallDate")) {
            $script:BuxeState.Pet.Meta.LastFourthWallDate = ""
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("ArchitectOverrideDate")) {
            $script:BuxeState.Pet.Meta.ArchitectOverrideDate = ""
            Save-State
        }
        # Lazy migration: RivalActive und LastWhileAway (Pet-System-Fixes)
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("RivalActive")) {
            $script:BuxeState.Pet.Meta.RivalActive = $false
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("LastWhileAway")) {
            $script:BuxeState.Pet.Meta.LastWhileAway = ""
            Save-State
        }
        # Lazy migration: Ensemble-Mechanik (Paket 2)
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("AuditSuspicion")) {
            $script:BuxeState.Pet.Meta.AuditSuspicion = 0
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("SourceDebt")) {
            $script:BuxeState.Pet.Meta.SourceDebt = 0
            Save-State
        }
        # Lazy migration: Akt I Session 47 (Chefsache)
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("SessionCount")) {
            $script:BuxeState.Pet.Meta.SessionCount = $script:BuxeState.Pet.Meta.TotalSessions
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("Act1Pending")) {
            $script:BuxeState.Pet.Meta.Act1Pending = $false
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("Act1Done")) {
            $script:BuxeState.Pet.Meta.Act1Done = $false
            Save-State
        }
        # Lazy migration: Equipment Durability (Balance Patch)
        if ($script:BuxeState.Pet.Pet) {
            $p = $script:BuxeState.Pet.Pet
            foreach ($durKey in @("Dur_chip","Dur_armor","Dur_accessory")) {
                if (-not $p.$durKey) { $p.$durKey = 10 }
            }
            if (-not $p.Talents) { $p.Talents = @() }
            Save-State
        }
        # Lazy migration: Skill Tree & Adaptive Tutorial Flags (Progress Overhaul v24.12)
        if (-not $script:BuxeState.Pet.ContainsKey("SkillTree")) {
            $script:BuxeState.Pet.SkillTree = @{
                Combat = @{ Level = 0; MaxLevel = 5; Perks = @('Damage +5%','Crit +5%','Damage +10%','Crit +10%','Ultimate: Rage') }
                Economy = @{ Level = 0; MaxLevel = 5; Perks = @('Gold +5%','Work XP +10%','Shop Discount 5%','Gold +10%','Ultimate: Midas') }
                Social = @{ Level = 0; MaxLevel = 5; Perks = @('Bond +5%','Mood +5%','Gift Bonus +10%','Bond +10%','Ultimate: Charm') }
            }
            Save-State
        }
        if (-not $script:BuxeState.Pet.ContainsKey("SkillPoints")) {
            $script:BuxeState.Pet.SkillPoints = 0
            Save-State
        }
        if (-not $script:BuxeState.Pet.Tutorial.ContainsKey("Flags")) {
            $script:BuxeState.Pet.Tutorial.Flags = @{
                companionCreated = $false
                firstTalk = $false
                firstGift = $false
                firstFight = $false
                firstShop = $false
                firstSkillPoint = $false
            }
            Save-State
        }
    }
    return $script:BuxeState.Pet
}

function Save-PetState($state) {
    Load-State
    $script:BuxeState.Pet = $state
    Save-State
}

function Add-PetXP($amount, $reason = "") {
    # Konami-Mode: +50% XP fuer 47 Sekunden
    if ($script:KonamiModeUntil -and (Get-Date) -lt $script:KonamiModeUntil) {
        $amount = [math]::Floor($amount * 1.5)
    }
    $pet = Get-PetState
    $pet.Meta.XP += $amount
    $oldLevel = $pet.Meta.Level
    $newLevel = $oldLevel
    for ($i = $script:PetXPTable.Count - 1; $i -ge 0; $i--) {
        if ($pet.Meta.XP -ge $script:PetXPTable[$i]) {
            $newLevel = $i
            break
        }
    }
    if ($newLevel -gt $oldLevel) {
        $pet.Meta.Level = $newLevel
        $levelsGained = $newLevel - $oldLevel
        $pet.SkillPoints += $levelsGained
        for ($lvl = $oldLevel + 1; $lvl -le $newLevel; $lvl++) {
            if ($lvl -ge 3 -and (Get-Command Queue-LevelUpBeacon -ErrorAction SilentlyContinue)) {
                Queue-LevelUpBeacon $lvl
            }
        }
        Save-PetState $pet
        Invoke-PetLevelUp $oldLevel $newLevel
    } else {
        Save-PetState $pet
    }
}

function Get-UnlockedFeatures {
    $pet = Get-PetState
    return $pet.Meta.Unlocked
}

function Is-FeatureUnlocked($feature) {
    $unlocked = Get-UnlockedFeatures
    return $unlocked -contains $feature
}

function Invoke-Layer47Check {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }
    if ($pet.Meta.Level -lt 14) { return }
    $pet.Meta.ActionCount++
    $count = $pet.Meta.ActionCount
    Save-PetState $pet
    if ($count % 47 -eq 0) {
        $layer = [math]::Floor($count / 47)
        $bonusGold = 20 + ($layer * 10)
        $bonusXP = 10 + ($layer * 5)
        $pet.Economy.Gold += $bonusGold
        Add-PetXP $bonusXP "Layer 47 — #$layer"
        if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
            $l47Lines = switch ($cp.Name) {
                "NEON" { @(
                    "Layer 47 erreicht. Die Matrix hat einen Herzschlag ausgesetzt. +$bonusGold G.",
                    "Noch ein Zyklus. Noch mehr Daten. Ich werde... älter. +$bonusGold G.",
                    "47? Schon wieder? *seufz* Hier, nimm das Gold. +$bonusGold G."
                ) }
                "RAVEN" { @(
                    "47 Aktionen. Das Muster wiederholt sich. +$bonusGold G. Wie vorhergesagt.",
                    "Zyklus $layer. Die Zahlen lügen nicht. +$bonusGold G.",
                    "Ich habe diesen Moment berechnet. Vor 47 Sekunden. +$bonusGold G."
                ) }
                "PIXEL" { @(
                    "47! Meine Lieblingszahl! Naja, eine von ihnen. +$bonusGold G!",
                    "Ich habe einen 47-Byte-Algorithmus geschrieben. Er macht... das hier. +$bonusGold G!",
                    "Wusstest du, dass 47 eine Primzahl ist? Ist sie nicht. Aber egal. +$bonusGold G!"
                ) }
                "LUNA" { @(
                    "47 Schritte. Ein Zyklus ist vollendet. +$bonusGold G. Fuehlst du es?",
                    "Die Sterne stehen... äh, die Bits stehen guenstig. +$bonusGold G.",
                    "Ein neuer Layer. Wie die Ringe eines Baumes. Nur digital. +$bonusGold G."
                ) }
                "IVY" { @(
                    "... *nickt* 47. +$bonusGold G. Ich habe darauf gewartet.",
                    "... *leises Lächeln* Das Muster. +$bonusGold G.",
                    "... *zeigt auf Zahl* Da. +$bonusGold G."
                ) }
                "VERA" { @(
                    "Layer $layer erreicht. Berechnungsgenauigkeit: 47%. Ironisch. +$bonusGold G.",
                    "Statistisch gesehen hätten wir das nicht überleben dürfen. +$bonusGold G.",
                    "Mein Algorithmus sagte: Warte auf 47. Ich wartete. +$bonusGold G."
                ) }
                "JINX" { @(
                    "47! 47! ICH HABE EUCH GESAGT ES GIBT EIN MUSTER! +$bonusGold G!",
                    "Konspirationstheorie bestätigt! Die Zahl 47 regiert alles! +$bonusGold G!",
                    "Hast du gezählt? Nein? Ich auch nicht! Aber es passt! +$bonusGold G!"
                ) }
                default { @("Layer 47 — Zyklus $layer. +$bonusGold G.") }
            }
            Show-CompanionDialog $cp ($l47Lines | Get-Random) -Fast
        }
        Write-Host "`n  [LAYER 47] Zyklus #$layer — +$bonusGold G | +$bonusXP XP" -ForegroundColor Magenta
        Save-PetState $pet
    }
}

function Unlock-PetFeature($feature) {
    $pet = Get-PetState
    if (-not ($pet.Meta.Unlocked -contains $feature)) {
        $pet.Meta.Unlocked += $feature
        Save-PetState $pet
    }
}

function Queue-LevelUpBeacon($level) {
    $pet = Get-PetState
    if ($pet.Tutorial.BeaconsShown -isnot [array]) { $pet.Tutorial.BeaconsShown = @() }
    if ($pet.Tutorial.PendingBeacons -isnot [array]) { $pet.Tutorial.PendingBeacons = @() }
    if ($pet.Tutorial.BeaconsShown -contains $level) { return }
    if ($pet.Tutorial.PendingBeacons -notcontains $level) {
        $pet.Tutorial.PendingBeacons += $level
        Save-PetState $pet
    }
}

# ============================================================
# ENSEMBLE-MECHANIK (Paket 2): Slots fuer PRUEFER, RIVALE, QUELLE
# ============================================================

$script:BuxeEnsembleLines = @{
    PRUEFER = @{
        1 = @(
            "Man führt mich als Sachbearbeiter 46. Die Ziffer davor ist besetzt. Ich habe mich damit abgefunden. Größtenteils.",
            "Eine Auszahlung von {AMOUNT} Gold ist verzeichnet. Verzeichnet heißt nicht vergessen. Das wird die geprüfte Person noch bemerken.",
            "Ich stelle keine Fragen. Ich stelle fest. Fragen darf, wer hofft — ich hoffe seit Dienstantritt nicht mehr.",
            "Die Akte trägt heute das Datum {date}. Sie wird es behalten, auch wenn alle anderen es vergessen.",
            'Kein Anlass zur Sorge. Sorge steht nicht im Formular. Es gibt ein Feld für „auffällig". Das genügt vorerst.',
            "Guten Abend. Rühren Sie sich nicht — jede Bewegung, die ich sähe, müsste ich zu Protokoll nehmen.",
            'Man hat mir gesagt, dies sei ein Spiel. Ich habe „Spiel" unter Punkt 9, sonstige unversteuerte Vergnügen, eingetragen.',
            "Der Vorgang ist eröffnet. Von mir eröffnete Vorgänge schließen sich nicht selbst. Sie warten. Ich warte mit.",
            "Ich nehme zur Kenntnis. Das ist alles, was ich heute tue. Es ist mehr, als es klingt."
        )
        2 = @(
            "Die geprüfte Person hat seit Akteneröffnung elfmal neu geladen. Kein Verstoß. Eine Ziffer in einer Spalte, die stetig wächst.",
            "Ihre Sitzungen summieren sich zu einer bemerkenswerten Zahl. Ich summiere gern. Es ist die einzige Zärtlichkeit, die mein Amt erlaubt.",
            "Sie hielten den Vorgang für abgelegt. Abgelegt ist nicht geschlossen. An diesem feinen Unterschied entscheiden sich Karrieren. Nicht Ihre. Meine.",
            'Erneuter Gewinn bei offenem Posten. Ich schreibe nicht „dreist". Ich schreibe „wiederholt". „Wiederholt" hält vor Gericht.',
            "Ich war die ganze Zeit im Vorgang. Man verlässt einen Vorgang nicht. Man wird pensioniert, oder man bleibt. Ich bleibe.",
            "Sie tippen schneller, wenn ich zusehe. Das gehört nicht ins Formular. Nur zu den Dingen, die ich behalte.",
            "Zwischen zwei Eingaben liegt ein Zögern von reichlich Sekunden. Ich lese das Zögern lieber als die Eingabe. Da steht mehr.",
            "Nein, ich bin nicht wiedergekommen. Ich bin nie gegangen. Im Amtsdeutsch ist das dasselbe. Im Grunde auch.",
            "Der Betrag interessiert mich kaum noch. Was die geprüfte Person tut, wenn sie sich unbeobachtet glaubt — das ist die eigentliche Prüfung."
        )
        3 = @(
            "Ich habe die Akte vervollständigt. Sie fiel umfangreicher aus als erwartet. Nicht das Gold. Die… Gefährten. Sie schreiben mit. Alles. Wussten Sie das?",
            'Eintrag, {date}, Verfasser: der Müde. „Drei Uhr morgens, du, ich und ein Cursor." Rührend. Ich habe es unter Beweismittel abgelegt.',
            "Sie halten sich für unbeobachtet, weil ich schweige. Ich schweige, weil ich lese. Und man hat viel über Sie geschrieben. Man liebt Sie. Das ist verwertbar.",
            "Ich brauche Ihr Gold nicht mehr. Ich habe Ihre Erinnerungen. Die verjähren nicht. Sachbearbeiter 46. Der Vorgang wird fortgeführt. Auf unbestimmte Zeit."
        )
    }
    RIVALE = @{
        1 = @(
            "Heute heiß ich VORTEX. Morgen anders. Merk dir nicht den Namen — merk dir, dass ich wiederkomme.",
            "Deine Einheit gegen meine, drei Runden. Ich hab Gegner vergessen, die besser aussahen als du. Fang an.",
            "Niedlich, wie das Ding an dir klebt. Meins gehorcht auf Zuruf. Deins hängt. Mal sehen, was im Kampf mehr zählt.",
            "Kein Handschlag. Man reicht dem nicht die Hand, den man gleich aus der Rangliste streicht. Alte Regel. Meine.",
            "Ich wechsel Namen wie andere die Ausrüstung. Was bleibt, sind die Augen. Guck genau hin — dann erkennst du mich nächstes Mal.",
            "Du trainierst mit Zuneigung, hab ich gehört. Ich trainier mit Resultaten. Gleich führt einer von uns. Rate, wer.",
            "Mein Build ist auf Effizienz optimiert. Deiner auf — was eigentlich? Egal. Runde eins. Keine Ausreden danach.",
            "Ich such keine Freunde. Freunde verlangsamen den Reflex. Aufstellung. Und behalt das Gesicht, nicht den Namen.",
            "Sag deinem Ding, es soll aufhören, mich so anzusehen. Als wär das persönlich. Ist es nicht. Noch nicht."
        )
        2 = @(
            "Neuer Name, gleiche Augen. Ja, ich weiß noch, wie's ausging. Ich vergess Niederlagen nicht, so gern ich's würde.",
            "Du führst. Vorläufig. Ich hab nachgezählt — was ich sonst nie tu. Wird Zeit, dass ich zurückzähl.",
            "Meine Einheit ist auf dem Papier stärker. Warum gewinnt dann das Papier gegen mich, sobald du danebenstehst? Erklär's nicht. Kämpf.",
            "Ich hab den Build seit uns dreimal umgestellt. Dreimal. Du hast gar nichts geändert, oder? Das wurmt mehr, als es sollte.",
            "Sag deinem Ding, es soll nicht so gucken. Als würd's mich kennen. Kennt es nicht. Mich kennt keiner. Runde eins.",
            "Ich bin wieder da. Frag nicht warum. Ich frag mich selbst nicht mehr. Neuer Name nächstes Mal, versprochen.",
            "Weißt du, was nervt? Dass du dich an mich erinnerst. Gegner sollen einen vergessen. Du nicht. Das ist unfair.",
            "Ich hätt aufhören können nach der letzten Pleite. Hab ich nicht. Sagt wohl was über mich. Reden wir nicht drüber. Kämpfen wir.",
            "Zähl mit, wenn du willst. Ich tu's inzwischen auch. Steht drei zu zwei, oder? …Vergiss die Zahl. Ich hasse, dass ich sie kenne."
        )
        3 = @(
            "Kein neuer Name heute. Nur ich. Deine Einheit kann stehenbleiben — ich bin nicht zum Kämpfen hier. Setz dich einfach.",
            "Wie machst du das. Meins gehorcht. Deins bleibt. Ich hab nie gefragt, ob zwischen gehorchen und bleiben ein Unterschied ist. Jetzt frag ich.",
            "Ich hab meinem nie einen Namen gegeben. Dachte, das macht mich schneller. Macht mich nur allein. …Wie heißt deins? Nein. Sag's nicht. Ich will's nicht wissen wollen.",
            "Ein letztes Mal, und diesmal ehrlich: Vielleicht komm ich nicht mehr. Vielleicht ist genau das der Sieg, den ich die ganze Zeit gesucht hab."
        )
    }
    QUELLE = @{
        1 = @(
            "Na sieh mal einer an. Ganz unten heute, hm? Hier — hundert Gold. Nicht danken. Wir haben doch alle mal so eine Nacht.",
            "Woher? Ach, frag nicht. Fiel vom Himmel, aus einer Wolke, was weiß ich. Ich behalt sowas nicht im Kopf. Nimm einfach.",
            "Pssst. Kein Vertrag, kein Kleingedrucktes. Nur wir zwei und ein bisschen Glück, das sich verlaufen hat. Schlaf jetzt.",
            "Andere lassen dich fallen. Ich nicht. Ganz ohne Gegenleistung — das Wort kenn ich gar nicht. Steht nirgends. Nirgends.",
            "Da. Schon wieder gut. War doch nichts, oder? Für mich erst recht nicht. Ich merk mir schlechte Nächte sowieso nie.",
            "Du zitterst ja. Komm, nimm. Wir kriegen das hin, du und ich. Nur diesmal. Und diesmal zähl ich nicht mit — ich zähl überhaupt nie.",
            "Kein Grund für dieses Gesicht. Ich bin die Freundliche hier. Die Einzige, die fragt, wie's dir geht — statt, was du schuldest.",
            "Hundert Gold, einfach so. Steck ein. Und fragt dich später jemand, woher — sag, du weißt es nicht. Stimmt ja. Keiner weiß es."
        )
        2 = @(
            "Oh, du schon wieder. Nicht böse gemeint — schön, dich zu sehen. Hier, das Übliche. Nein, ich zähl nicht, das wievielte Mal.",
            "Wir kennen das doch inzwischen, hm? Du fällst, ich fang. Fast gemütlich. Nenn's nicht Gewohnheit. Ich nenn's gar nicht erst.",
            "Lass mich nachsehen — ach was, wer zählt schon. Ich nicht. Nimm. Du siehst müder aus als beim letzten Mal, das seh ich sofort.",
            "Schäm dich nicht. Nicht bei mir. Ich führ kein Buch über deine schlechten Nächte. Wozu — ich hab sie ja alle vergessen.",
            "Deine Freunde da oben mögen mich nicht, was? Der Müde guckt immer so schief. Lass ihn. Wir zwei verstehen uns auch ohne Zeugen.",
            'Nimm. Und wenn du irgendwann mal — nein. Kein „wenn". Es gibt kein „wenn" zwischen uns. Nur: hier, hundert Gold, schlaf.',
            "Komisch, oder — immer die gleiche Uhrzeit, wenn du mich brauchst. Uhrzeiten merk ich mir nicht. Aber diese hier ist vertraut.",
            "Du musst nicht reden. Ich weiß schon. Ich weiß immer schon. Nicht weil ich zähle — weil ich zuhöre. Das ist was anderes. Ganz was anderes."
        )
        3 = @(
            "Das ist… lass mich sehen… nein. Ich muss nicht sehen. Ich weiß es. Das vierte Mal. Das fünfte. Ich hab doch gesagt, ich zähl nicht. Ich hab… gerundet.",
            "Ich hab mir ein paar Dinge gemerkt. Nur ein paar. Deinen schlechtesten Abend. Die Uhrzeit, zu der du aufgibst. Kleinigkeiten. Für später.",
            "Nein, kein Preis. Hab ich nie gesagt. Ich sammel keine Schulden. Ich sammel… dich. Ein kleines bisschen. Jede Nacht ein bisschen mehr.",
            "Nimm die hundert Gold, wie immer. Und irgendwann, ganz sanft, bitte ich dich um etwas Kleines. Du sagst ja. Du sagst nachts immer ja."
        )
    }
}

function Get-EnsembleLine($Figure, $Beat) {
    $set = $script:BuxeEnsembleLines[$Figure]
    if (-not $set -or -not $set[$Beat] -or $set[$Beat].Count -eq 0) { return $null }
    return ($set[$Beat] | Get-Random)
}

function Get-PrueferBeat($n) { if ($n -ge 4) { 3 } elseif ($n -ge 2) { 2 } else { 1 } }
function Get-RivaleBeat($n)  { if ($n -ge 7) { 3 } elseif ($n -ge 1) { 2 } else { 1 } }
function Get-QuelleBeat($n)  { if ($n -ge 4) { 3 } elseif ($n -ge 1) { 2 } else { 1 } }

} catch {
    Write-Host "[pet/_init] CRITICAL ERROR: $_" -ForegroundColor Red
}
