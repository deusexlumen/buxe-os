# BUXE_OS v24.2 — PET SYSTEM CORE v2.0
# State, Schema, Meta-Progression

try {

$script:PetXPTable = @(0, 3, 15, 40, 100, 300, 600, 1200, 2500, 5000, 10000)
$script:PetFeatureUnlocks = @{
    0 = @("talk", "companion_create")
    1 = @("gift", "mood")
    2 = @("pet_create", "combat")
    3 = @("train", "work", "gold")
    4 = @("shop", "cooking", "equipment")
    5 = @("pvp")
    6 = @("raid")
    7 = @("breed")
    8 = @("rival")
    9 = @("soul_link")
    10 = @("architect")
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
        }
        Companion = $null
        Pet = $null
        Economy = @{ Gold = 500; Inventory = @() }
        Achievements = @()
        Memories = @()
        Tutorial = @{
            Completed = $false
            Step = 0
            Skipped = $false
        }
    }
}

function Get-PetState {
    Load-State
    if (-not $script:BuxeState.Pet) {
        $script:BuxeState.Pet = (Get-PetDefaults)
        Save-State
    } else {
        # Migration: existing saves before tutorial feature
        if (-not $script:BuxeState.Pet.ContainsKey("Tutorial")) {
            $script:BuxeState.Pet.Tutorial = @{
                Completed = $true
                Step = 0
                Skipped = $false
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

function Unlock-PetFeature($feature) {
    $pet = Get-PetState
    if (-not ($pet.Meta.Unlocked -contains $feature)) {
        $pet.Meta.Unlocked += $feature
        Save-PetState $pet
    }
}

} catch {
    Write-Host "[pet/_init] CRITICAL ERROR: $_" -ForegroundColor Red
}
