# BUXE_OS v24.2 — PET SYSTEM CORE v2.0
# State, Schema, Meta-Progression

try {

$script:PetXPTable = @(0, 3, 15, 40, 100, 300, 600, 1200, 2500, 5000, 10000, 15000, 22000, 32000, 47000, 70000)
$script:PetFeatureUnlocks = @{
    0 = @("talk", "companion_create")
    1 = @("gift", "mood")
    2 = @("pet_create", "combat", "companion_games")
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
        }
        Companion = $null
        Pet = $null
        CompanionStories = @{
            NEON  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
            RAVEN = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            PIXEL = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            LUNA  = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            IVY   = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
            VERA  = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
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
        Tutorial = @{
            Completed     = $false
            Step          = 0
            Skipped       = $false
            PendingBeacons = @()
            BeaconsShown  = @()
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
        # Lazy migration: Equipment Durability (Balance Patch)
        if ($script:BuxeState.Pet.Pet) {
            $p = $script:BuxeState.Pet.Pet
            foreach ($durKey in @("Dur_chip","Dur_armor","Dur_accessory")) {
                if (-not $p.$durKey) { $p.$durKey = 10 }
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

} catch {
    Write-Host "[pet/_init] CRITICAL ERROR: $_" -ForegroundColor Red
}
