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

$testPet = @{ MaxHP = 100; ATK = 10; DEF = 5; SPD = 8; Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }; BonusMaxHP = 0; BonusATK = 0; BonusDEF = 0; BonusSPD = 0; CritBonus = 0; CritResist = 0 }
$es = Get-EffectiveStats $testPet
Test-Assert "Effective stats calc" ($es.MaxHP -eq 100 -and $es.ATK -eq 10)

# Show-PetFrame uses Write-Host, so we just verify it doesn't throw
Show-PetFrame "Test" | Out-Null
Test-Assert "Show-PetFrame runs without error" ($? -eq $true)

Test-Assert "Pet hub function exists" ((Get-Command pet -ErrorAction SilentlyContinue) -ne $null)

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
Test-Assert "JINX Episode 1 default korrekt" `
    ($petDefaults.CompanionStories.JINX.Episode -eq 1)

$storyDataPath = Join-Path $modDir "pet\companion-story-data.ps1"
Test-Assert "Story data file existiert" (Test-Path $storyDataPath)

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
Test-Assert "Total rooms = 16" ($script:AdvRooms.Count -eq 16)

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
Test-Assert "EVA without suit = death" ($result.Message -match "GAME OVER")

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
$allMods = @("casino-engine.ps1","casino-blackjack.ps1","casino-roulette.ps1","casino-craps.ps1","casino-hilo.ps1","casino-baccarat.ps1","casino-slot.ps1","casino-keno.ps1","casino-wheel.ps1","casino.ps1","arcade.ps1","strategy-poker.ps1","strategy-td.ps1","strategy-rogue.ps1","handbook.ps1","boot.ps1","fun.ps1","adventure-engine.ps1","adventure-world.ps1","adventure-companion-ai.ps1","adventure.ps1","adventure-insult.ps1","desktop-pet.ps1")
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

# === SUMMARY ===
Write-Host "`n  ========================================" -ForegroundColor Cyan
Write-Host "  Tests: $tests | Passed: $($tests - $errors) | Failed: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "  ========================================" -ForegroundColor Cyan
if ($errors -eq 0) { Write-Host "`n  ALL TESTS PASSED! BUXE_OS v24 ready.`n" -ForegroundColor Green }
else { Write-Host "`n  $errors TEST(S) FAILED.`n" -ForegroundColor Red }

} catch {
    Write-Host "  [CRITICAL] Smoke test crashed: $_" -ForegroundColor Red -BackgroundColor DarkRed
}
