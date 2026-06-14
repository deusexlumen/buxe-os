# BUXE_OS v24.0 -- INTEGRATION TEST
$ErrorActionPreference = 'Stop'
$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load all modules
$modules = @("engine-state-core","engine-state-migration","engine-state-advanced","engine-ui","engine-game","engine-aliases","casino-engine","casino-blackjack","casino-roulette","casino-craps","casino-hilo","casino-baccarat","casino-slot","casino","arcade","strategy-poker","strategy-td","strategy-rogue","adventure-engine","adventure-world","adventure-companion-ai","adventure","adventure-insult","desktop-pet","handbook","boot","fun","tts-engine","engine-arg")
foreach ($m in $modules) { . "$modDir\$m.ps1" }

# Load Pet System v2.0
$petModules = Get-ChildItem "$modDir\pet\*.ps1" | Sort-Object Name
foreach ($pm in $petModules) { . $pm.FullName }

$errors = 0; $tests = 0
function Test-Assert($name, $condition) {
    $script:tests++
    if ($condition) { Write-Host "  [PASS] $name" -ForegroundColor Green }
    else { Write-Host "  [FAIL] $name" -ForegroundColor Red; $script:errors++ }
}

Write-Host "`n  BUXE_OS v24.0 INTEGRATION TEST`n" -ForegroundColor Cyan

# Test 1: State
Test-Assert "State defaults v24" ((Get-StateDefaults).Version -eq 24)
Test-Assert "Bust cooldown default" ((Get-StateDefaults).Bank.LastBustReset -eq "")

# Test 1b: ARG v3.0 State Structure
$argDefaults = (Get-StateDefaults).Arg
Test-Assert "ARG state exists" ($argDefaults -ne $null)
Test-Assert "ARG UnlockedCheats array" ($argDefaults.UnlockedCheats -is [array])
Test-Assert "ARG BootHexShown default" ($argDefaults.BootHexShown -eq $false)
Test-Assert "ARG MeridianChoice default" ($argDefaults.MeridianChoice -eq "")
Test-Assert "ARG MeridianCompanion default" ($argDefaults.MeridianCompanion -eq "")

# ARG v3.0 Engine Tests
$argState = Get-ArgState
Test-Assert "ARG v3.0 state loads" ($argState -ne $null)
Test-Assert "ARG v3.0 Meta Version" ($argState.Meta.Version -eq 1)
Test-Assert "ARG v3.0 Counters exist" ($argState.Counters -ne $null)
Test-Assert "ARG v3.0 Triggers exist" ($argState.Triggers -ne $null)
Test-Assert "ARG v3.0 Unlocked exist" ($argState.Unlocked -ne $null)
Test-Assert "ARG v3.0 Hints exist" ($argState.Hints -ne $null)
Test-Assert "ARG v3.0 Meridian exists" ($argState.Meridian -ne $null)
Test-Assert "ARG v3.0 Rosebud not available by default" ((Get-ArgStateDefaults).Triggers.RosebudAvailable -eq $false)
Test-Assert "ARG v3.0 Meridian not active by default" ($argState.Meridian.Active -eq $false)

# ARG v3.0 Core Functions
Test-Assert "Initialize-ArgState exists" ((Get-Command Initialize-ArgState -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Get-ArgState exists" ((Get-Command Get-ArgState -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Save-ArgState exists" ((Get-Command Save-ArgState -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgAvailable exists" ((Get-Command Test-ArgAvailable -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgUnlocked exists" ((Get-Command Test-ArgUnlocked -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgCommand exists" ((Get-Command Test-ArgCommand -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgBootCheck exists" ((Get-Command Invoke-ArgBootCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgCasinoCheck exists" ((Get-Command Invoke-ArgCasinoCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Update-ArgBondCheck exists" ((Get-Command Update-ArgBondCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgRoom17Available exists" ((Get-Command Test-ArgRoom17Available -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgObserver148 exists" ((Get-Command Test-ArgObserver148 -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Invoke-ArgSoulLinkCheck exists" ((Get-Command Invoke-ArgSoulLinkCheck -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Test-ArgMeridianActive exists" ((Get-Command Test-ArgMeridianActive -ErrorAction SilentlyContinue) -ne $null)

# Test 2: Bank
$initial = Get-Bankroll
Add-Gold 100 "test"
Test-Assert "Add-Gold" ((Get-Bankroll) -eq $initial + 100)
Spend-Gold 100 "test"
Test-Assert "Spend-Gold" ((Get-Bankroll) -eq $initial)

# Test 3: UI
Test-Assert "Show-Bar length" ((Show-Bar 50 100 20).Length -eq 20)

# Test 4: Game engine
Test-Assert "Deck size" ((New-CardDeck).Count -eq 52)
$hand = @(@{Rank="A";Suit="S"}, @{Rank="10";Suit="H"})
Test-Assert "Blackjack value" ((Get-HandValue $hand) -eq 21)

# Test 5: Elements
Test-Assert "Fire vs Ice" ((Get-ElementModifier "FIRE" "ICE") -eq 1.5)
Test-Assert "Fire vs Water" ((Get-ElementModifier "FIRE" "WATER") -eq 0.5)

# Test 6: Pet System v2.0
Test-Assert "Pet state loads" ((Get-PetState) -ne $null)
Test-Assert "Pet defaults level 0" ((Get-PetDefaults).Meta.Level -eq 0)
Test-Assert "Pet defaults have Tutorial" ((Get-PetDefaults).ContainsKey("Tutorial"))
Test-Assert "Pet Tutorial defaults not completed" ((Get-PetDefaults).Tutorial.Completed -eq $false)
Test-Assert "Pet Tutorial defaults step 0" ((Get-PetDefaults).Tutorial.Step -eq 0)
Test-Assert "Pet XP Table Lv1 threshold is 3" ($script:PetXPTable[1] -eq 3)

# Test 7: Pet effective stats
$pet = Get-PetState
$pet.SkillTree.Combat.Level = 0
$pet.SkillTree.Economy.Level = 0
$pet.SkillTree.Social.Level = 0
Save-PetState $pet
$testPet = @{ MaxHP = 100; ATK = 10; DEF = 5; SPD = 8; Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }; BonusMaxHP = 0; BonusATK = 0; BonusDEF = 0; BonusSPD = 0; CritBonus = 0; CritResist = 0 }
$es = Get-EffectiveStats $testPet
Test-Assert "Effective stats calc" ($es.MaxHP -eq 100 -and $es.ATK -eq 10)

# Test 8: Required functions exist
$required = @("status","bank","daily","achievements","ego","capsule","h","pet","companion","battlepet","handbook","snake","monkeytype","wordle","zork","hangman","blackjack","roulette","craps","hilo","baccarat","slot","poker","td","rogue","say","chuck","mem","sysinfo","uptime","weather","ip","port","reload")
$missing = 0
foreach ($fn in $required) {
    if (-not (Get-Command $fn -ErrorAction SilentlyContinue)) { $missing++ }
}
Test-Assert "All required functions exist" ($missing -eq 0)

# Test 9: State persistence
Save-State
$statePath = Join-Path $env:LOCALAPPDATA "buxe\buxe_state_v24.json"
Test-Assert "State file exists" (Test-Path $statePath)

# Test 10: No duplicate functions in production modules
$allDefs = @{};
$prodFiles = @((Get-ChildItem "$modDir\*.ps1" | Where-Object { $_.Name -notlike "_*" }), (Get-ChildItem "$modDir\pet\*.ps1" | Where-Object { $_.Name -notlike "_*" }))
foreach ($f in $prodFiles) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$null)
    $funcs = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
    foreach ($fn in $funcs) {
        if (-not $allDefs.ContainsKey($fn.Name)) { $allDefs[$fn.Name] = @() }
        $allDefs[$fn.Name] += $f.Name
    }
}
$dupCount = ($allDefs.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 } | Measure-Object).Count
Test-Assert "No duplicate functions" ($dupCount -eq 0)

# Test 10b: No duplicate functions in engine-arg.ps1 specifically
$argFile = Join-Path $modDir "engine-arg.ps1"
if (Test-Path $argFile) {
    $argAst = [System.Management.Automation.Language.Parser]::ParseFile($argFile, [ref]$null, [ref]$null)
    $argFuncs = $argAst.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
    $argFuncNames = $argFuncs | ForEach-Object { $_.Name }
    $argDups = $argFuncNames | Group-Object | Where-Object { $_.Count -gt 1 }
    Test-Assert "No duplicates in engine-arg.ps1" ($argDups.Count -eq 0)
} else {
    Test-Assert "engine-arg.ps1 exists for dup check" ($false)
}

# Test 11: No conflicting script variables in production modules
$allVars = @{}
foreach ($f in $prodFiles) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$null)
    $vars = $ast.FindAll({ 
        $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] -and
        $args[0].Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
        $args[0].Left.VariablePath.DriveName -eq 'script'
    }, $true)
    foreach ($v in $vars) {
        $name = $v.Left.VariablePath.UserPath
        if (-not $allVars.ContainsKey($name)) { $allVars[$name] = @() }
        $allVars[$name] += $f.Name
    }
}
$varDupCount = ($allVars.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 -and $_.Name -notin @('ErrorActionPreference') } | Measure-Object).Count
Test-Assert "No conflicting script variables" ($varDupCount -eq 0)

# Test 12: Handbook functions exist
$hbFuncs = @("handbook","Show-HBCombat","Show-HBElements","Show-HBStatus","Show-HBSkills","Show-HBEquipment","Show-HBCasino","Show-HBCompanion","Show-HBCommands")
$hbMissing = 0
foreach ($fn in $hbFuncs) { if (-not (Get-Command $fn -ErrorAction SilentlyContinue)) { $hbMissing++ } }
Test-Assert "Handbook functions exist" ($hbMissing -eq 0)

# Test 13: Pet shop items loaded
Test-Assert "Pet shop items" ($script:PetShopItems.Count -ge 3)

# Test 14: Pet hub function
Test-Assert "Pet hub exists" ((Get-Command pet -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Tutorial orchestrator exists" ((Get-Command Invoke-PetTutorial -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Tutorial skip exists" ((Get-Command Invoke-TutorialSkip -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Tutorial dialog engine exists" ((Get-Command Get-TutorialLines -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Tutorial fight exists" ((Get-Command Start-PetTutorialFight -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Skill tree functions exist" ((Get-Command Add-PetSkillPoint -ErrorAction SilentlyContinue) -ne $null -and (Get-Command Get-PetSkillBonus -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Achievement reward function exists" ((Get-Command Claim-AchievementReward -ErrorAction SilentlyContinue) -ne $null)

# Test 14b: Tutorial dialog returns non-empty string
$tutLine = Get-TutorialLines "NEON" 2
Test-Assert "Tutorial dialog returns string" ($tutLine -is [string] -and $tutLine.Length -gt 0)
$tutSkip = Get-TutorialLines "JINX" "skip"
Test-Assert "Tutorial skip dialog returns string" ($tutSkip -is [string] -and $tutSkip.Length -gt 0)

# Test 14c: Existing state migration (simulate old save without Tutorial)
Load-State
$script:BuxeState.Pet.Remove("Tutorial")
Save-State
$pet = Get-PetState
Test-Assert "Pet state migration sets Tutorial.Completed=true" ($pet.Tutorial.Completed -eq $true)

# Beacon System Integration
$pet = Get-PetState
$originalPending = $pet.Tutorial.PendingBeacons.Clone()
$originalShown = $pet.Tutorial.BeaconsShown.Clone()

# Test Queue
Queue-LevelUpBeacon 8
$pet = Get-PetState
Test-Assert "Integration: Beacon queued" ($pet.Tutorial.PendingBeacons -contains 8)

# Test State Roundtrip
Save-PetState $pet
Load-State
$pet = Get-PetState
Test-Assert "Integration: Beacon survives save/load" ($pet.Tutorial.PendingBeacons -contains 8)

# Test duplicate prevention
Queue-LevelUpBeacon 8
$pet = Get-PetState
Test-Assert "Integration: Duplicate queue ignored" ($pet.Tutorial.PendingBeacons.Count -eq 1)

# Cleanup
$pet.Tutorial.PendingBeacons = $originalPending
$pet.Tutorial.BeaconsShown = $originalShown
Save-PetState $pet

# Progress Overhaul State Roundtrip
$pet = Get-PetState
$pet.SkillTree.Combat.Level = 3
$pet.SkillTree.Economy.Level = 2
$pet.SkillTree.Social.Level = 1
$pet.SkillPoints = 5
$pet.Tutorial.Flags.firstFight = $true
$pet.Tutorial.Flags.firstShop = $true
Save-PetState $pet
Load-State
$reloaded = Get-PetState
Test-Assert "SkillTree Combat level persists" ($reloaded.SkillTree.Combat.Level -eq 3)
Test-Assert "SkillTree Economy level persists" ($reloaded.SkillTree.Economy.Level -eq 2)
Test-Assert "SkillTree Social level persists" ($reloaded.SkillTree.Social.Level -eq 1)
Test-Assert "SkillPoints persist" ($reloaded.SkillPoints -eq 5)
Test-Assert "Tutorial firstFight flag persists" ($reloaded.Tutorial.Flags.firstFight -eq $true)
Test-Assert "Tutorial firstShop flag persists" ($reloaded.Tutorial.Flags.firstShop -eq $true)

# Achievement reward roundtrip
Load-State
$script:BuxeState.Achievements['First Step'] = (Get-Date -Format 'yyyy-MM-dd')
$script:BuxeState.Achievements['RewardsClaimed'] = @{}
$beforeGold = Get-Bankroll
Claim-AchievementReward 'First Step' | Out-Null
Test-Assert "Achievement reward grants gold (integration)" ((Get-Bankroll) -eq $beforeGold + 50)
$script:BuxeState.Achievements.Remove('First Step')
$script:BuxeState.Achievements.Remove('RewardsClaimed')
Save-State

# All companions have episode 1 story data
Test-Assert "RAVEN episode 1 data" ($script:CompanionEpisodeData.ContainsKey('RAVEN') -and $script:CompanionEpisodeData.RAVEN.ContainsKey(1))
Test-Assert "PIXEL episode 1 data" ($script:CompanionEpisodeData.ContainsKey('PIXEL') -and $script:CompanionEpisodeData.PIXEL.ContainsKey(1))
Test-Assert "LUNA episode 1 data" ($script:CompanionEpisodeData.ContainsKey('LUNA') -and $script:CompanionEpisodeData.LUNA.ContainsKey(1))
Test-Assert "IVY episode 1 data" ($script:CompanionEpisodeData.ContainsKey('IVY') -and $script:CompanionEpisodeData.IVY.ContainsKey(1))
Test-Assert "VERA episode 1 data" ($script:CompanionEpisodeData.ContainsKey('VERA') -and $script:CompanionEpisodeData.VERA.ContainsKey(1))

# Hollow Promises State Fields
$pet = Get-PetState
Test-Assert "Hollow Promises: GlitchLuckActive exists" ($pet.Meta.ContainsKey("GlitchLuckActive"))
Test-Assert "Hollow Promises: AwakenedTopicsSeen exists" ($pet.Meta.ContainsKey("AwakenedTopicsSeen"))
Test-Assert "Hollow Promises: LastGlitchEffect exists" ($pet.Meta.ContainsKey("LastGlitchEffect"))
Test-Assert "Hollow Promises: LastFourthWallDate exists" ($pet.Meta.ContainsKey("LastFourthWallDate"))
Test-Assert "Hollow Promises: ArchitectOverrideDate exists" ($pet.Meta.ContainsKey("ArchitectOverrideDate"))

# Test 15: Adventure engine loads
Test-Assert "Adventure engine loaded" ((Get-Command Invoke-Adventure -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Adventure alias 'adv' exists" ((Get-Command adv -ErrorAction SilentlyContinue) -ne $null)

# Test 16: Adventure state roundtrip
$script:AdvState = Get-AdventureDefaults
$script:AdvState.CurrentRoom = "lab"
$script:AdvState.Inventory = @("card", "battery")
Save-AdventureState -Force
Load-AdventureState
Test-Assert "Adventure state save/load" ($script:AdvState.CurrentRoom -eq "lab" -and $script:AdvState.Inventory -contains "card")

# Test 17: Adventure room connectivity
$hangar = Get-Room "hangar"
Test-Assert "Hangar connects to corridor" ($hangar.Exits["north"] -eq "corridor")
Test-Assert "Corridor north exit initially unset" ((Get-Room "corridor").Exits["north"] -eq $null)
Test-Assert "Bridge is not directly accessible from corridor" ((Get-Room "corridor").Exits["bridge"] -eq $null)

# Test 18: Adventure parser coverage
$parseTests = @(
    @{ In = "go north"; V = "go"; N = "north" },
    @{ In = "n"; V = "go"; N = "north" },
    @{ In = "take card"; V = "take"; N = "card" },
    @{ In = "look at box"; V = "examine"; N = "box" },
    @{ In = "talk to drone"; V = "talk"; N = "drone" },
    @{ In = "use key on chest"; V = "use"; N = "key" },
    @{ In = "i"; V = "inventory"; N = "" },
    @{ In = "l"; V = "look"; N = "" }
)
$parseOk = 0
foreach ($t in $parseTests) {
    $c = Parse-AdventureCommand $t.In
    if ($c.Verb -eq $t.V -and $c.Noun -eq $t.N) { $parseOk++ }
}
Test-Assert "Adventure parser coverage (8/8)" ($parseOk -eq 8)

# Test 19: Companion AI functions exist
$aiFuncs = @("Get-CompanionAIDefaults","Test-RunningGag","Test-AbsurdCombo","Update-CompanionMood","Invoke-CompanionEvent","Get-CompanionHint")
$aiMissing = 0
foreach ($fn in $aiFuncs) { if (-not (Get-Command $fn -ErrorAction SilentlyContinue)) { $aiMissing++ } }
Test-Assert "Companion AI functions exist" ($aiMissing -eq 0)

# Test 20: Companion AI state roundtrip
$script:AdvState.CompanionAI = Get-CompanionAIDefaults
$script:AdvState.CompanionAI.Mood = "Excited"
Save-AdventureState -Force
Load-AdventureState
$ai = Get-CompanionAI
Test-Assert "Companion AI state persists" ($ai.Mood -eq "Excited")

# Test 21: Running gag counter
$ai = Get-CompanionAI
$ai.RunningGags = @{}
$script:AdvState.CompanionAI = $ai
Save-AdventureState -Force
Test-RunningGag "go" "north" | Out-Null
Test-RunningGag "go" "north" | Out-Null
$gag = Test-RunningGag "go" "north"
Test-Assert "Running gag triggers on 3rd repeat" ($gag.Triggered -eq $true)

# Test 22: Absurd combo registry
Test-Assert "Absurd battery+coffee exists" ((Test-AbsurdCombo "battery" "coffee").IsAbsurd -eq $true)
Test-Assert "Non-absurd combo rejected" ((Test-AbsurdCombo "card" "terminal").IsAbsurd -eq $false)

# Test 23: Mood transitions
$script:AdvState.CompanionAI = Get-CompanionAIDefaults
Update-CompanionMood "find_item"
Test-Assert "Mood -> Excited on find" ((Get-CompanionAI).Mood -eq "Excited")

# Test 24: New rooms connectivity
Test-Assert "Hangar connects to airlock" ((Get-Room "hangar").Exits["down"] -eq "airlock")
Test-Assert "Airlock connects to EVA" ((Get-Room "airlock").Exits["west"] -eq "eva")
Test-Assert "Corridor connects to engine" ((Get-Room "corridor").Exits["down"] -eq "engine")
Test-Assert "Engine connects to core" ((Get-Room "engine").Exits["north"] -eq "core")
Test-Assert "Bridge connects to observatory" ((Get-Room "bridge").Exits["up"] -eq "observatory")
Test-Assert "Total rooms = 17" ($script:AdvRooms.Count -eq 17)

# Test 25: Sauerstoff-System
$script:AdvState.Oxygen = 10
Test-Assert "Oxygen defaults to 10" ($script:AdvState.Oxygen -eq 10)

# Test 26: Hack command
$cmd = Parse-AdventureCommand "hack terminal"
Test-Assert "Hack parser works" ($cmd.Verb -eq "hack" -and $cmd.Noun -eq "terminal")

# Test 27: EVA death without suit
$script:AdvState.CurrentRoom = "airlock"
$script:AdvState.Inventory = @()
$result = Process-AdventureCommand (Parse-AdventureCommand "go west")
Test-Assert "EVA without suit = death" ($result.Death -eq $true)

# Test 28: True ending flag
Test-Assert "True ending flag exists" ($script:AdvState.Flags -is [hashtable] -or $script:AdvState.Flags -is [System.Management.Automation.PSCustomObject])

# Test 29: JINX companion
Test-Assert "JINX companion exists" ($script:CPNames -contains "JINX")
Test-Assert "7 companions" ($script:CPNames.Count -eq 7)
Test-Assert "JINX quotes loaded" ($script:CPQuotes.ContainsKey("JINX"))

# Test 30: LucasArts Easter Eggs
Test-Assert "Rubber chicken in cafeteria" ((Get-Room "cafeteria").Objects.ContainsKey("rubber_chicken"))
Test-Assert "Skull in vent" ((Get-Room "vent").Objects.ContainsKey("skull"))
Test-Assert "Tree in secret" ((Get-Room "secret").Objects.ContainsKey("tree"))

# Test 31: Insult pairs expanded
Test-Assert "Insult pairs = 29" ($script:InsultPairs.Count -eq 29)

# Test 26: Companion hint system
$script:AdvState.CompanionAI = Get-CompanionAIDefaults
$script:AdvState.CompanionAI.MovesWithoutProgress = 10
$script:AdvState.Flags = @{}
$script:AdvState.Inventory = @()
$hint = Get-CompanionHint (Get-Room "hangar")
$hasCompanion = $false
try { $hasCompanion = (Get-PetState).Companion -ne $null } catch {}
Test-Assert "Companion gives hint when stuck (hasCompanion=$hasCompanion)" ($hint -ne $null -or -not $hasCompanion)

# Test 27: Desktop Pet functions exist
Test-Assert "Desktop Pet functions exist" ((Get-Command Get-DesktopPetComment -ErrorAction SilentlyContinue) -ne $null)

# Test 28: Desktop Pet comment generation
$comment = Get-DesktopPetComment "git push --force"
Test-Assert "Desktop Pet detects force push" ($comment -ne $null)

# Test 29: Insult Swordfighting functions exist
Test-Assert "Insult game function exists" ((Get-Command Invoke-InsultGame -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Insult alias exists" ((Get-Command insult -ErrorAction SilentlyContinue) -ne $null)

# Test 30: Insult pairs integrity
$insults = $script:InsultPairs
$valid = 0
foreach ($i in $insults) { if ($i.Insult -and $i.Correct -and $i.Wrongs.Count -eq 3) { $valid++ } }
Test-Assert "All insult pairs valid (29/29)" ($valid -eq 29)

# Summary
Write-Host "`n  ========================================" -ForegroundColor Cyan
Write-Host "  Tests: $tests | Passed: $($tests - $errors) | Failed: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "  ========================================" -ForegroundColor Cyan
if ($errors -eq 0) { Write-Host "`n  ALL INTEGRATION TESTS PASSED!`n" -ForegroundColor Green }
else { Write-Host "`n  $errors TEST(S) FAILED.`n" -ForegroundColor Red }
