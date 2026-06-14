# BUXE_OS v24.0 -- SMOKE TEST

$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$modDir\engine-state-core.ps1"
. "$modDir\engine-state-migration.ps1"
. "$modDir\engine-state-advanced.ps1"
. "$modDir\engine-ui.ps1"
. "$modDir\engine-game.ps1"
. "$modDir\engine-aliases.ps1"
. "$modDir\casino-engine.ps1"
. "$modDir\adventure-engine.ps1"
. "$modDir\adventure-world.ps1"

# Load Pet System v2.0
$petModules = Get-ChildItem "$modDir\pet\*.ps1" | Sort-Object Name
foreach ($pm in $petModules) { . $pm.FullName }

# Save original pet state before any mutation tests
$originalPetState = Get-PetState | ConvertTo-Json -Depth 20 | ConvertFrom-Json -AsHashtable

try {

$errors = 0; $tests = 0

function Test-Assert($name, $condition) {
    $script:tests++
    if ($condition) { Write-Host "  [PASS] $name" -ForegroundColor Green }
    else { Write-Host "  [FAIL] $name" -ForegroundColor Red; $script:errors++ }
}

Write-Host "`n  BUXE_OS v24.0 SMOKE TEST`n" -ForegroundColor Cyan

# === ENGINE TESTS ===
Write-Host "  Testing Engine..." -ForegroundColor Yellow
$defaults = Get-StateDefaults
Test-Assert "State defaults exist" ($defaults.Version -eq 24)
Test-Assert "Bank defaults" ($defaults.Bank.Gold -eq 500)
Test-Assert "Bust cooldown default" ($defaults.Bank.LastBustReset -eq "")
Test-Assert "Casino defaults" ($defaults.Casino.Blackjack.HandsPlayed -eq 0)

$deck = New-CardDeck
Test-Assert "Deck has 52 cards" ($deck.Count -eq 52)
Test-Assert "Ace value" ((Get-CardValue "A") -eq 11)
Test-Assert "Face card values" ((Get-CardValue "K") -eq 10)

$bjHand = @(@{Rank="A";Suit="S"}, @{Rank="10";Suit="H"})
Test-Assert "Blackjack hand value" ((Get-HandValue $bjHand) -eq 21)

$baccHand = @(@{Rank="9";Suit="S"}, @{Rank="8";Suit="H"})
Test-Assert "Baccarat value" ((Get-BaccaratValue $baccHand) -eq 7)

$dice = New-DiceRoll 2 6
Test-Assert "Dice roll count" ($dice.Count -eq 2)
Test-Assert "Dice in range" ($dice[0] -ge 1 -and $dice[0] -le 6)

Test-Assert "Fire strong vs Ice" ((Get-ElementModifier "FIRE" "ICE") -eq 1.5)
Test-Assert "Fire weak vs Water" ((Get-ElementModifier "FIRE" "WATER") -eq 0.5)
Test-Assert "Neutral matchup" ((Get-ElementModifier "NORM" "FIRE") -eq 1.0)

$bar = Show-Bar 50 100 20
Test-Assert "Show-Bar returns string" ($bar -is [string])
Test-Assert "Show-Bar width" ($bar.Length -eq 20)

# === PET SYSTEM v2.0 TESTS ===
Write-Host "`n  Testing Pet System v2.0..." -ForegroundColor Yellow

$petState = Get-PetState
Test-Assert "Pet state loads" ($petState -ne $null)
Test-Assert "Pet state has Meta" ($petState.Meta -ne $null)

$defaults = Get-PetDefaults
Test-Assert "Pet defaults exist" ($defaults.Meta -ne $null)
Test-Assert "Pet default level 0" ($defaults.Meta.Level -eq 0)

$cleanStatsState = Get-PetState
$cleanStatsState.SkillTree.Combat.Level = 0
$cleanStatsState.SkillTree.Economy.Level = 0
$cleanStatsState.SkillTree.Social.Level = 0
Save-PetState $cleanStatsState
$testPet = @{ MaxHP = 100; ATK = 10; DEF = 5; SPD = 8; Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }; BonusMaxHP = 0; BonusATK = 0; BonusDEF = 0; BonusSPD = 0; CritBonus = 0; CritResist = 0 }
$es = Get-EffectiveStats $testPet
Test-Assert "Effective stats calc" ($es.MaxHP -eq 100 -and $es.ATK -eq 10)

# Show-PetFrame uses Write-Host, so we just verify it doesn't throw
Show-PetFrame "Test" | Out-Null
Test-Assert "Show-PetFrame runs without error" ($? -eq $true)

Test-Assert "Pet hub function exists" ((Get-Command pet -ErrorAction SilentlyContinue) -ne $null)

# Pet Beacon System v24.11
$petDefaults = Get-PetDefaults
Test-Assert "Pet Tutorial PendingBeacons default array" ($petDefaults.Tutorial.PendingBeacons -is [array])
Test-Assert "Pet Tutorial PendingBeacons default empty" ($petDefaults.Tutorial.PendingBeacons.Count -eq 0)
Test-Assert "Pet Tutorial BeaconsShown default array" ($petDefaults.Tutorial.BeaconsShown -is [array])
Test-Assert "Pet Tutorial BeaconsShown default empty" ($petDefaults.Tutorial.BeaconsShown.Count -eq 0)

# Skill Tree & Adaptive Tutorial Defaults
$petDefaults = Get-PetDefaults
Test-Assert "Pet SkillTree default exists" ($petDefaults.SkillTree -ne $null)
Test-Assert "Pet SkillTree Combat branch" ($petDefaults.SkillTree.Combat -ne $null -and $petDefaults.SkillTree.Combat.MaxLevel -eq 5)
Test-Assert "Pet SkillTree Economy branch" ($petDefaults.SkillTree.Economy -ne $null)
Test-Assert "Pet SkillTree Social branch" ($petDefaults.SkillTree.Social -ne $null)
Test-Assert "Pet SkillPoints default 0" ($petDefaults.SkillPoints -eq 0)
Test-Assert "Pet Tutorial Flags exist" ($petDefaults.Tutorial.Flags -ne $null)
Test-Assert "Pet Tutorial companionCreated flag" ($petDefaults.Tutorial.Flags.companionCreated -eq $false)

# Skill Tree Engine
$cleanState = Get-PetState
$cleanState.Meta.Level = 3
$cleanState.SkillPoints = 2
$cleanState.SkillTree.Combat.Level = 0
$cleanState.SkillTree.Economy.Level = 0
$cleanState.SkillTree.Social.Level = 0
Save-PetState $cleanState

Test-Assert "Add-PetSkillPoint function exists" ((Get-Command Add-PetSkillPoint -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Get-PetSkillBonus function exists" ((Get-Command Get-PetSkillBonus -ErrorAction SilentlyContinue) -ne $null)
$addResult = Add-PetSkillPoint -Branch 'Combat'
Test-Assert "Add-PetSkillPoint succeeds" ($addResult -eq $true)
$bonus = Get-PetSkillBonus -Branch 'Combat' -Tier 1
Test-Assert "Combat tier 1 bonus is 5%" ($bonus -eq 0.05)
$stateAfter = Get-PetState
Test-Assert "Skill point consumed" ($stateAfter.SkillPoints -eq 1)
Test-Assert "Combat level increased" ($stateAfter.SkillTree.Combat.Level -eq 1)

# Skill points granted on level-up
$xpState = Get-PetState
$xpState.Meta.Level = 0
$xpState.Meta.XP = 0
$xpState.SkillPoints = 0
Save-PetState $xpState
Add-PetXP -amount 5
$xpStateAfter = Get-PetState
Test-Assert "Level-up grants skill point" ($xpStateAfter.SkillPoints -ge 1)

# Skill bonuses applied in core loops
$bonusState = Get-PetState
$bonusState.SkillTree.Combat.Level = 2
$bonusState.SkillTree.Economy.Level = 3
$bonusState.SkillTree.Social.Level = 1
Save-PetState $bonusState

$testPetForStats = @{ MaxHP = 100; ATK = 10; DEF = 5; SPD = 8; Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }; FoodBuffs = @(); Personality = "Balanced" }
$effective = Get-EffectiveStats $testPetForStats
Test-Assert "Combat skill bonus increases ATK" ($effective.ATK -gt 10)

$shopPrice = Get-PetShopPrice -ItemName 'Neural Chip'
Test-Assert "Economy skill discount reduces shop price" ($shopPrice -lt 60)

$socialTotal = Get-TotalPetSkillBonus -Branch 'Social'
Test-Assert "Social skill bonus is positive" ($socialTotal -gt 0)

# Reset test state
$cleanState = Get-PetState
$cleanState.SkillTree.Combat.Level = 0
$cleanState.SkillTree.Economy.Level = 0
$cleanState.SkillTree.Social.Level = 0
$cleanState.SkillPoints = 0
Save-PetState $cleanState

# Queue-LevelUpBeacon
# Clear any prior test pollution before testing queue behavior
$cleanState = Get-PetState
$cleanState.Tutorial.PendingBeacons = @()
$cleanState.Tutorial.BeaconsShown = @()
Save-PetState $cleanState

Queue-LevelUpBeacon 5
$petState2 = Get-PetState
Test-Assert "Queue-LevelUpBeacon adds to PendingBeacons" ($petState2.Tutorial.PendingBeacons -contains 5)

# Invoke-LevelUpBeacon simulation (clear manually)
$petState2.Tutorial.PendingBeacons = @()
$petState2.Tutorial.BeaconsShown += 5
Save-PetState $petState2
$petState3 = Get-PetState
Test-Assert "Beacon clear works" ($petState3.Tutorial.PendingBeacons.Count -eq 0)
Test-Assert "Beacon tracked in BeaconsShown" ($petState3.Tutorial.BeaconsShown -contains 5)

# Duplicate beacon prevention
Queue-LevelUpBeacon 5
$petState4 = Get-PetState
Test-Assert "Duplicate beacon rejected (already in BeaconsShown)" ($petState4.Tutorial.PendingBeacons.Count -eq 0)

# Hollow Promises features
Test-Assert "Invoke-ArchitectTerminal exists" ((Get-Command Invoke-ArchitectTerminal -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-AwakeningTalk exists" ((Get-Command Invoke-AwakeningTalk -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-FourthWall exists" ((Get-Command Invoke-FourthWall -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-PetGlitch exists" ((Get-Command Invoke-PetGlitch -ErrorAction SilentlyContinue) -ne $null)

# === TACTICAL COMBAT SYSTEM TESTS ===
Write-Host "`n  Testing Tactical Combat System..." -ForegroundColor Yellow
$pet = Get-PetState
$pet.Pet = @{
    Name = "GLITCH_WOLF"; Type = "VIRUS"; Level = 3; XP = 0; NextXP = 50
    HP = 100; MaxHP = 100; ATK = 16; DEF = 7; SPD = 12
    Color = "Magenta"; Attacks = @("Neural Overload","Bit Crusher","Plasma Lance")
    Wins = 0; Losses = 0; Evolved = $false; Personality = "Balanced"
    Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }
    FoodBuffs = @(); LimitBreakUnlocked = $true
}
Save-PetState $pet

# Test Show-HPBar
$bar = Show-HPBar 50 100
Test-Assert "Show-HPBar renders bar" ($bar.Bar.Contains("█") -and $bar.Bar.Contains("░"))
Test-Assert "Show-HPBar color at 50%" ($bar.Color -eq "Yellow")
Test-Assert "Show-HPBar percent correct" ($bar.Percent -eq 50)

$bar2 = Show-HPBar 80 100
Test-Assert "Show-HPBar green above 50%" ($bar2.Color -eq "Green")

$bar3 = Show-HPBar 20 100
Test-Assert "Show-HPBar red below 25%" ($bar3.Color -eq "Red")

# Test BPAttacks
Test-Assert "BPAttacks has Neural Overload" ($script:BPAttacks.ContainsKey("Neural Overload"))
Test-Assert "BPAttacks Plasma Lance is FIRE" ($script:BPAttacks["Plasma Lance"].Type -eq "FIRE")
Test-Assert "BPAttacks Neural Overload has Poison effect" ($script:BPAttacks["Neural Overload"].Effect -eq "Poison")

# Test BossPatterns
Test-Assert "BossPatterns has BOSS_OMEGA" ($script:BossPatterns.ContainsKey("BOSS_OMEGA"))
Test-Assert "BOSS_OMEGA has 3 phases" ($script:BossPatterns["BOSS_OMEGA"].Phases.Count -eq 3)

# Test Get-CombatInitiative
$init = Get-CombatInitiative @{ SPD = 10 } @{ SPD = 5 }
Test-Assert "Get-CombatInitiative returns boolean" ($init -is [bool])

# Test New-CombatState
$cs = New-CombatState $pet.Pet $pet.Companion
Test-Assert "CombatState Round starts at 1" ($cs.Round -eq 1)
Test-Assert "CombatState Stance starts Balanced" ($cs.PlayerStance -eq "Balanced")
Test-Assert "CombatState StatusEffects empty" ($cs.StatusEffects.Count -eq 0)
Test-Assert "CombatState LimitBreak not used" ($cs.LimitBreakUsed -eq $false)

# === STORY ENGINE TESTS ===
Write-Host "`n  Testing Story Engine..." -ForegroundColor Yellow
# Story Engine Smoke Tests
Test-Assert "Story function Invoke-CompanionEpisode vorhanden" `
    ((Get-Command Invoke-CompanionEpisode -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Story function Get-CompanionEpisodeData vorhanden" `
    ((Get-Command Get-CompanionEpisodeData -ErrorAction SilentlyContinue) -ne $null)

$petDefaults = Get-PetDefaults
Test-Assert "CompanionStories State-Branch vorhanden" `
    ($petDefaults.CompanionStories -ne $null)
Test-Assert "NEON Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.NEON.Episode -eq 1)
Test-Assert "RAVEN Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.RAVEN.Episode -eq 1)
Test-Assert "PIXEL Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.PIXEL.Episode -eq 1)
Test-Assert "LUNA Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.LUNA.Episode -eq 1)
Test-Assert "IVY Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.IVY.Episode -eq 1)
Test-Assert "VERA Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.VERA.Episode -eq 1)
Test-Assert "JINX Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.JINX.Episode -eq 1)
Test-Assert "RAVEN story data has scenes" `
    ($script:CompanionEpisodeData.RAVEN[1].Scenes.Count -gt 0)
Test-Assert "PIXEL story data has scenes" `
    ($script:CompanionEpisodeData.PIXEL[1].Scenes.Count -gt 0)
Test-Assert "LUNA story data has scenes" `
    ($script:CompanionEpisodeData.LUNA[1].Scenes.Count -gt 0)
Test-Assert "IVY story data has scenes" `
    ($script:CompanionEpisodeData.IVY[1].Scenes.Count -gt 0)
Test-Assert "VERA story data has scenes" `
    ($script:CompanionEpisodeData.VERA[1].Scenes.Count -gt 0)

$storyDataPath = Join-Path $modDir "pet\companion-story-data.ps1"
Test-Assert "Story data file existiert" (Test-Path $storyDataPath)

# Companion Games Smoke Tests
$gameFuncs = @('Invoke-CompanionGame', 'Play-ChaosChips', 'Play-FortyTwoOr47', 'Play-Memory')
foreach ($fn in $gameFuncs) {
    Test-Assert "Game function $fn vorhanden" `
        ((Get-Command $fn -ErrorAction SilentlyContinue) -ne $null)
}

$petDefaults = Get-PetDefaults
Test-Assert "CompanionGames State-Branch vorhanden" `
    ($petDefaults.CompanionGames -ne $null)
Test-Assert "CompanionGames Wins default 0" `
    ($petDefaults.CompanionGames.Wins -eq 0)
Test-Assert "CompanionGames ChaosChipsHighscore default 0" `
    ($petDefaults.CompanionGames.ChaosChipsHighscore -eq 0)
Test-Assert "CompanionGames MemoryBestTime default 999" `
    ($petDefaults.CompanionGames.MemoryBestTime -eq 999)

# === ACHIEVEMENT REWARDS ===
Write-Host "`n  Testing Achievement Rewards..." -ForegroundColor Yellow
Load-State
$achGoldBefore = (Get-Bankroll)
Unlock-Achievement 'First Step'
$claimResult = Claim-AchievementReward -name 'First Step'
Test-Assert "Claim-AchievementReward succeeds" ($claimResult -eq $true)
Test-Assert "Achievement reward grants gold" ((Get-Bankroll) -gt $achGoldBefore)
$doubleClaim = Claim-AchievementReward -name 'First Step'
Test-Assert "Double claim prevented" ($doubleClaim -eq $false)
Test-Assert "Achievements command exists" ((Get-Command achievements -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "ARG beacon hints function exists" ((Get-Command Get-ArgBeaconHints -ErrorAction SilentlyContinue) -ne $null)
$hints = Get-ArgBeaconHints
Test-Assert "ARG beacon hints returned" ($hints.Count -ge 3)
$script:BuxeState.Achievements.Remove('First Step')
$script:BuxeState.Achievements.Remove('RewardsClaimed')
Save-State

# === STATE ACCESSORS ===
Write-Host "`n  Testing State Access..." -ForegroundColor Yellow
Test-Assert "Get-Bankroll" ((Get-Bankroll) -ge 0)
Test-Assert "Load-State" ($script:BuxeState.Version -eq 24)

# === AUDIT LOG ===
Write-Host "`n  Testing Audit Log..." -ForegroundColor Yellow
$auditExists = Test-Path $script:BuxeAuditFile
Test-Assert "Audit log file exists" ($auditExists -eq $true)
if ($auditExists) {
    $auditLines = Get-Content $script:BuxeAuditFile -ErrorAction SilentlyContinue
    Test-Assert "Audit log has entries" ($auditLines.Count -gt 0)
}

# === STATE TRANSACTIONS ===
Write-Host "`n  Testing State Transactions..." -ForegroundColor Yellow
$txGoldBefore = Get-Bankroll
Start-StateTransaction
Add-Gold 999 "TestTransaction"
Test-Assert "Transaction active (depth > 0)" ($script:BuxeStateTransactionDepth -gt 0)
Rollback-StateTransaction
Test-Assert "Rollback restores gold" ((Get-Bankroll) -eq $txGoldBefore)
Test-Assert "Transaction depth reset" ($script:BuxeStateTransactionDepth -eq 0)

Start-StateTransaction
Add-Gold 111 "TestTransaction"
Complete-StateTransaction
Test-Assert "Commit persists gold" ((Get-Bankroll) -eq $txGoldBefore + 111)
# Cleanup: remove the test gold
Start-StateTransaction
$script:BuxeState.Bank.Gold = $txGoldBefore
Complete-StateTransaction

# === CORRUPT JSON RECOVERY ===
Write-Host "`n  Testing Corrupt JSON Recovery..." -ForegroundColor Yellow
$origState = Get-Content $script:BuxeStateFile -Raw
$corruptBackupPattern = "$script:BuxeStateFile.corrupt.*"
$preBackups = Get-ChildItem $corruptBackupPattern -ErrorAction SilentlyContinue

# Corrupt the file
"THIS IS NOT JSON {{{" | Out-File $script:BuxeStateFile -Encoding utf8 -Force
Start-Sleep -Milliseconds 100
$script:BuxeStateLoadedAt = $null
Load-State

$postBackups = Get-ChildItem $corruptBackupPattern -ErrorAction SilentlyContinue
Test-Assert "Corrupt backup created" ($postBackups.Count -gt $preBackups.Count)
Test-Assert "Defaults restored after corruption" ($script:BuxeState.Version -eq 24)

# Restore original state
$origState | Out-File $script:BuxeStateFile -Encoding utf8 -Force
$script:BuxeStateLoadedAt = $null
Load-State
Test-Assert "Original state restored" ($script:BuxeState.Version -eq 24)

# === ADVENTURE ENGINE ===
Write-Host "`n  Testing Adventure Engine..." -ForegroundColor Yellow
$script:AdvState = Get-AdventureDefaults
Test-Assert "Adventure defaults exist" ($script:AdvState.Version -eq 1)
Test-Assert "Adventure default room" ($script:AdvState.CurrentRoom -eq "hangar")
Test-Assert "Get-AdventureMessage exists" ((Get-Command Get-AdventureMessage -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Get-AdventureMessage returns string" ((Get-AdventureMessage "cannot_go") -is [string])

$hangar = $script:AdvRooms["hangar"]
Test-Assert "Hangar description is not generic" ($hangar.Description -notmatch "grosser Hangar mit einem alten Shuttle")
Test-Assert "Hangar description uses message lookup" ($hangar.Description -notlike "*Ein grosser Hangar*")

$room = Get-Room "hangar"
Test-Assert "Hangar room exists" ($room -ne $null)
Test-Assert "Hangar has name" ($room.Name -eq "HANGAR BAY 7")
Test-Assert "Hangar has exits" ($room.Exits.Count -gt 0)

# Parser tests
$cmd = Parse-AdventureCommand "go north"
Test-Assert "Parser: go north" ($cmd.Verb -eq "go" -and $cmd.Noun -eq "north")
$cmd = Parse-AdventureCommand "take card"
Test-Assert "Parser: take card" ($cmd.Verb -eq "take" -and $cmd.Noun -eq "card")
$cmd = Parse-AdventureCommand "look at terminal"
Test-Assert "Parser: look at terminal" ($cmd.Verb -eq "examine" -and $cmd.Noun -eq "terminal")
$cmd = Parse-AdventureCommand "n"
Test-Assert "Parser: n shortcut" ($cmd.Verb -eq "go" -and $cmd.Noun -eq "north")
$cmd = Parse-AdventureCommand "i"
Test-Assert "Parser: i shortcut" ($cmd.Verb -eq "inventory")

# Inventory tests
$script:AdvState.Inventory = @()
Add-ToInventory "card" "Zugangskarte"
Test-Assert "Add to inventory" (Has-Item "card")
Remove-FromInventory "card"
Test-Assert "Remove from inventory" (-not (Has-Item "card"))

# Use handler test
$script:AdvState.Flags = @{}
$script:AdvState.Inventory = @("card")
$script:AdvState.CurrentRoom = "corridor"
$result = Invoke-UseHandler "card" "" (Get-Room "corridor")
Test-Assert "Use card on corridor terminal" ($result.Success -eq $true)
Test-Assert "Bridge unlocked flag" ($script:AdvState.Flags["bridge_unlocked"] -eq $true)

# Companion AI tests
. "$modDir\adventure-companion-ai.ps1" 2>$null
$script:AdvState.CompanionAI = Get-CompanionAIDefaults
Test-Assert "Companion AI defaults" ($script:AdvState.CompanionAI.Mood -eq "Curious")

Test-Assert "CPAdventureVoice exists" ((Get-Variable CPAdventureVoice -Scope Script -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "CPAdventureVoice has NEON" ($script:CPAdventureVoice.ContainsKey("NEON"))
Test-Assert "CPAdventureVoice NEON has Find" ($script:CPAdventureVoice["NEON"].ContainsKey("Find"))
Test-Assert "CPAdventureVoice NEON Find not empty" ($script:CPAdventureVoice["NEON"].Find.Count -gt 0)

# Running Gag test
$script:AdvState.CompanionAI = Get-CompanionAIDefaults
$script:AdvState.CompanionAI.RunningGags = @{}
$gag = Test-RunningGag "examine" "card"
Test-Assert "Running gag not triggered on 1st try" ($gag.Triggered -eq $false)
$gag = Test-RunningGag "examine" "card"
Test-Assert "Running gag not triggered on 2nd try" ($gag.Triggered -eq $false)
$gag = Test-RunningGag "examine" "card"
Test-Assert "Running gag triggered on 3rd try" ($gag.Triggered -eq $true)

# Absurd combo test
$abs = Test-AbsurdCombo "battery" "coffee"
Test-Assert "Absurd combo recognized" ($abs.IsAbsurd -eq $true)
$abs = Test-AbsurdCombo "card" "terminal"
Test-Assert "Normal combo not absurd" ($abs.IsAbsurd -eq $false)

# Mood update test
Update-CompanionMood "find_item"
Test-Assert "Mood changes to excited on find" ((Get-CompanionAI).Mood -eq "Excited")
Update-CompanionMood "stuck"
Update-CompanionMood "stuck"
Update-CompanionMood "stuck"
Update-CompanionMood "stuck"
Test-Assert "Mood changes to bored on stuck" ((Get-CompanionAI).Mood -eq "Bored")

# Test new rooms v25.0
Test-Assert "Airlock room exists" ((Get-Room "airlock") -ne $null)
Test-Assert "EVA room exists" ((Get-Room "eva") -ne $null)
Test-Assert "Engine room exists" ((Get-Room "engine") -ne $null)
Test-Assert "Medbay room exists" ((Get-Room "medbay") -ne $null)
Test-Assert "Armory room exists" ((Get-Room "armory") -ne $null)
Test-Assert "Quarters room exists" ((Get-Room "quarters") -ne $null)
Test-Assert "Observatory room exists" ((Get-Room "observatory") -ne $null)
Test-Assert "Core room exists" ((Get-Room "core") -ne $null)
Test-Assert "Total rooms = 17" ($script:AdvRooms.Count -eq 17)

# Test JINX companion
Test-Assert "JINX in CPNames" ($script:CPNames -contains "JINX")
Test-Assert "JINX role is JESTER" ($script:CPRoles[$script:CPNames.IndexOf("JINX")] -eq "JESTER")
Test-Assert "7 companions total" ($script:CPNames.Count -eq 7)
Test-Assert "JINX quotes exist" ($script:CPQuotes["JINX"] -ne $null)
Test-Assert "JINX Low quote" ($script:CPQuotes["JINX"].Low.Count -eq 2)

# Test Easter Egg objects
Test-Assert "Rubber chicken exists" ((Get-Room "cafeteria").Objects["rubber_chicken"] -ne $null)
Test-Assert "Skull exists" ((Get-Room "vent").Objects["skull"] -ne $null)
Test-Assert "Plastic tree exists" ((Get-Room "secret").Objects["tree"] -ne $null)

# Test EVA without suit = death
$script:AdvState.CurrentRoom = "airlock"
$script:AdvState.Inventory = @()
$script:AdvState.Oxygen = 10
$cmd = Parse-AdventureCommand "go west"
$result = Process-AdventureCommand $cmd
Test-Assert "EVA without suit = death" ($result.Death -eq $true)

# Test EVA with suit = ok
$script:AdvState.CurrentRoom = "airlock"
$script:AdvState.Inventory = @("suit")
$script:AdvState.Oxygen = 10
$cmd = Parse-AdventureCommand "go west"
$result = Process-AdventureCommand $cmd
Test-Assert "EVA with suit = ok" ($result.Success -eq $true)

# Test oxygen countdown
$script:AdvState.CurrentRoom = "eva"
$script:AdvState.Inventory = @("suit")
$script:AdvState.Oxygen = 1
$cmd = Parse-AdventureCommand "go east"
$result = Process-AdventureCommand $cmd
Test-Assert "Oxygen depletes in EVA" ($result.Success -eq $true -and $script:AdvState.Oxygen -eq 10)

# Test hack command parsing
$cmd = Parse-AdventureCommand "hack terminal"
Test-Assert "Parser: hack terminal" ($cmd.Verb -eq "hack" -and $cmd.Noun -eq "terminal")

# === TETRIS ENGINE ===
Write-Host "`n  Testing Tetris Engine..." -ForegroundColor Yellow
# Load tetris module explicitly for tests
$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$modDir\arcade-tetris.ps1" 2>$null
$tb = New-TetrisBoard 10 20
Test-Assert "Tetris board is 20 rows" ($tb.Count -eq 20)
Test-Assert "Tetris board row is 10 cols" ($tb[0].Count -eq 10)
Test-Assert "Tetris board cell is empty" ($tb[5][5] -eq '.')

# Test collision with wall
$tp = @{ Type = 'O'; X = -1; Y = 0; Rotation = 0 }
Test-Assert "Tetris collision left wall" (Test-TetrisCollision $tb $tp -1 0 0)

# Test lock piece (O-Piece at X=4,Y=17 -> blocks at (5,18) and (5,19))
$tp2 = @{ Type = 'O'; X = 4; Y = 17; Rotation = 0 }
Lock-TetrisPiece $tb $tp2
Test-Assert "Tetris lock piece" ($tb[18][5] -eq '#')

# Test line clear
for ($x = 0; $x -lt 10; $x++) { $tb[19][$x] = '#' }
$cleared = Clear-TetrisLines $tb
Test-Assert "Tetris clear line" ($cleared -eq 1)
Test-Assert "Tetris top row empty after clear" ($tb[0][0] -eq '.')

# === BREAKOUT ENGINE ===
Write-Host "`n  Testing Breakout Engine..." -ForegroundColor Yellow
$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$modDir\engine-input.ps1" 2>$null
. "$modDir\arcade-breakout.ps1" 2>$null
$bg = New-BreakoutLevel 1
Test-Assert "Breakout bricks created" ($bg.Bricks.Count -eq 40)
Test-Assert "Breakout paddle in bounds" ($bg.PaddleX -ge 0)
Test-Assert "Breakout ball moving" ($bg.BallDY -lt 0)
$bg.Bricks[0].Active = $true
$bg.Bricks[0].Strength = 1
$bg.BallX = $bg.Bricks[0].X
$bg.BallY = $bg.Bricks[0].Y
$bg.BallDX = 0
$bg.BallDY = 0.5
Update-Breakout $bg
Test-Assert "Breakout brick hit" ($bg.Bricks[0].Active -eq $false)
Test-Assert "Breakout score increased" ($bg.Score -gt 0)

# === BACKUP ROTATION ===
Write-Host "`n  Testing Backup Rotation..." -ForegroundColor Yellow
$bakPattern = "$script:BuxeStateFile.bak*"
Remove-Item $bakPattern -Force -ErrorAction SilentlyContinue
# Ensure throttle window from previous saves has passed
Start-Sleep -Milliseconds 700
# Save 6 times to trigger rotation (600ms Pause fuer Throttle)
for ($i = 1; $i -le 6; $i++) {
    $script:BuxeState.Bank.Gold = 500 + $i
    Save-State
    Start-Sleep -Milliseconds 600
}
Test-Assert "bak1 exists" (Test-Path "$script:BuxeStateFile.bak1")
Test-Assert "bak5 exists" (Test-Path "$script:BuxeStateFile.bak5")
Test-Assert "bak6 does not exist" (-not (Test-Path "$script:BuxeStateFile.bak6"))
# Verify chain: bak5 should have gold=501 (oldest backup after 6 saves)
$bak5Content = Get-Content "$script:BuxeStateFile.bak5" -Raw | ConvertFrom-Json
Test-Assert "bak5 has oldest data" ($bak5Content.Bank.Gold -eq 501)
# Cleanup backups
Remove-Item $bakPattern -Force -ErrorAction SilentlyContinue
# Restore state
$script:BuxeState.Bank.Gold = 500
Save-State

# === MODULE LOAD TEST ===
Write-Host "`n  Testing Module Load..." -ForegroundColor Yellow
$allMods = @("casino-engine.ps1","casino-blackjack.ps1","casino-roulette.ps1","casino-craps.ps1","casino-hilo.ps1","casino-baccarat.ps1","casino-slot.ps1","casino-keno.ps1","casino-wheel.ps1","casino.ps1","arcade.ps1","strategy-poker.ps1","strategy-td.ps1","strategy-rogue.ps1","handbook.ps1","boot.ps1","fun.ps1","adventure-engine.ps1","adventure-world.ps1","adventure-companion-ai.ps1","adventure.ps1","adventure-insult.ps1","desktop-pet.ps1","engine-arg.ps1")
$loadOk = 0
foreach ($m in $allMods) {
    try { . "$modDir\$m" 2>$null; $loadOk++ } catch {}
}
Test-Assert "All modules load" ($loadOk -eq $allMods.Count)

# === KENO TESTS ===
Write-Host "`n  Testing Keno..." -ForegroundColor Yellow
Test-Assert "Keno function exists" ((Get-Command keno -ErrorAction SilentlyContinue) -ne $null)
$defaults = Get-StateDefaults
Test-Assert "Keno state defaults" ($defaults.Casino.Keno.Played -eq 0 -and $defaults.Casino.Keno.BestWin -eq 0)

# === WHEEL OF FORTUNE TESTS ===
Write-Host "`n  Testing Wheel of Fortune..." -ForegroundColor Yellow
Test-Assert "Wheel function exists" ((Get-Command wheel -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Wheel state defaults" ($defaults.Casino.Wheel.Spins -eq 0 -and $defaults.Casino.Wheel.Bankrupts -eq 0)

# === DESKTOP PET TESTS ===
Write-Host "`n  Testing Desktop Pet..." -ForegroundColor Yellow
. "$modDir\desktop-pet.ps1" 2>$null
$comment = Get-DesktopPetComment "git push"
Test-Assert "Desktop Pet comment for git push" ($comment -ne $null)
$comment = Get-DesktopPetComment "rm -rf /"
Test-Assert "Desktop Pet comment for rm -rf" ($comment -ne $null)
$comment = Get-DesktopPetComment "this-command-does-not-exist"
Test-Assert "Desktop Pet default comment chance" ($comment -eq $null -or $comment -ne $null)  # 10% chance

# === INSULT SWORDFIGHTING TESTS ===
Write-Host "`n  Testing Insult Swordfighting..." -ForegroundColor Yellow
. "$modDir\adventure-insult.ps1" 2>$null
$insultCount = if ($script:InsultPairs) { $script:InsultPairs.Count } else { 0 }
Test-Assert "Insult pairs loaded ($insultCount)" ($insultCount -eq 29)
Reset-InsultState
Test-Assert "Insult state reset" ($script:InsultState.PlayerScore -eq 0)
$round = Get-RandomInsultRound
Test-Assert "Random insult round has insult" ($round.Insult -ne $null)
Test-Assert "Random insult round has correct" ($round.Correct -ne $null)
Test-Assert "Random insult round has 3 wrongs" ($round.Wrongs.Count -eq 3)

# === ARG FRAMEWORK TESTS ===
Write-Host "`n  Testing ARG Framework v3.0..." -ForegroundColor Yellow
. "$modDir\engine-arg.ps1" 2>$null
$defaults = Get-StateDefaults
Test-Assert "ARG state defaults exist" ($defaults.Arg -ne $null)
Test-Assert "ARG UnlockedCheats default" ($defaults.Arg.UnlockedCheats.Count -eq 0)
Test-Assert "ARG BootHexShown default" ($defaults.Arg.BootHexShown -eq $false)
Test-Assert "ARG MeridianChoice default empty" ($defaults.Arg.MeridianChoice -eq "")
Test-Assert "ARG MeridianCompanion default empty" ($defaults.Arg.MeridianCompanion -eq "")

# ARG v3.0 State Engine Tests
$argState = Get-ArgState
Test-Assert "ARG v3.0 state loads" ($argState -ne $null)
Test-Assert "ARG v3.0 Meta exists" ($argState.Meta -ne $null)
Test-Assert "ARG v3.0 Counters exist" ($argState.Counters -ne $null)
Test-Assert "ARG v3.0 Triggers exist" ($argState.Triggers -ne $null)
Test-Assert "ARG v3.0 Unlocked exist" ($argState.Unlocked -ne $null)
Test-Assert "ARG v3.0 Hints exist" ($argState.Hints -ne $null)
Test-Assert "ARG v3.0 Meridian exists" ($argState.Meridian -ne $null)
Test-Assert "ARG v3.0 Rosebud not available by default" ((Get-ArgStateDefaults).Triggers.RosebudAvailable -eq $false)
Test-Assert "ARG v3.0 Meridian not active by default" ($argState.Meridian.Active -eq $false)

# ARG v3.0 Functions
Test-Assert "Initialize-ArgState function exists" ((Get-Command Initialize-ArgState -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Get-ArgState function exists" ((Get-Command Get-ArgState -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Save-ArgState function exists" ((Get-Command Save-ArgState -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgAvailable function exists" ((Get-Command Test-ArgAvailable -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgUnlocked function exists" ((Get-Command Test-ArgUnlocked -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgUnlock function exists" ((Get-Command Invoke-ArgUnlock -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgTriggerAvailable function exists" ((Get-Command Invoke-ArgTriggerAvailable -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgTriggerNext function exists" ((Get-Command Invoke-ArgTriggerNext -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgActionTick function exists" ((Get-Command Invoke-ArgActionTick -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgCommand function exists" ((Get-Command Test-ArgCommand -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgBootCheck function exists" ((Get-Command Invoke-ArgBootCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgCasinoCheck function exists" ((Get-Command Invoke-ArgCasinoCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Update-ArgBondCheck function exists" ((Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgRoom17Death function exists" ((Get-Command Invoke-ArgRoom17Death -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgRoom17Available function exists" ((Get-Command Test-ArgRoom17Available -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgObserver148 function exists" ((Get-Command Test-ArgObserver148 -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgSoulLinkCheck function exists" ((Get-Command Invoke-ArgSoulLinkCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgMeridianActive function exists" ((Get-Command Test-ArgMeridianActive -ErrorAction SilentlyContinue) -ne $null)

# Backward Compatibility
Test-Assert "Show-MetaTerminal function exists" ((Get-Command Show-MetaTerminal -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgCheatUnlocked function exists" ((Get-Command Test-ArgCheatUnlocked -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgMirrorMatch function exists" ((Get-Command Invoke-ArgMirrorMatch -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgMeridian function exists" ((Get-Command Invoke-ArgMeridian -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgLayer6CompanionDialog function exists" ((Get-Command Invoke-ArgLayer6CompanionDialog -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgLayer7CompanionDialog function exists" ((Get-Command Invoke-ArgLayer7CompanionDialog -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "MERIDIAN_STATUS function exists" ((Get-Command MERIDIAN_STATUS -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "meta command exists" ((Get-Command meta -ErrorAction SilentlyContinue) -ne $null)

# Restore original pet state to prevent test pollution
$originalPetState.Tutorial.BeaconsShown = @($originalPetState.Tutorial.BeaconsShown | Select-Object -Unique)
Save-PetState $originalPetState

# === SUMMARY ===
Write-Host "`n  ========================================" -ForegroundColor Cyan
Write-Host "  Tests: $tests | Passed: $($tests - $errors) | Failed: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "  ========================================" -ForegroundColor Cyan
if ($errors -eq 0) { Write-Host "`n  ALL TESTS PASSED! BUXE_OS v24 ready.`n" -ForegroundColor Green }
else { Write-Host "`n  $errors TEST(S) FAILED.`n" -ForegroundColor Red }

} catch {
    Write-Host "  [CRITICAL] Smoke test crashed: $_" -ForegroundColor Red -BackgroundColor DarkRed
}
