# BUXE_OS v24.0 -- INTEGRATION TEST
$ErrorActionPreference = 'Stop'
$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load all modules
$modules = @("engine-state-core","engine-state-migration","engine-state-advanced","engine-ui","engine-game","engine-aliases","casino-engine","casino-blackjack","casino-roulette","casino-craps","casino-hilo","casino-baccarat","casino-slot","casino","arcade","strategy-poker","strategy-td","strategy-rogue","adventure-engine","adventure-world","adventure-companion-ai","adventure","handbook","boot","fun","ralph-loop")
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

# Test 7: Pet effective stats
$testPet = @{ MaxHP = 100; ATK = 10; DEF = 5; SPD = 8; Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }; BonusMaxHP = 0; BonusATK = 0; BonusDEF = 0; BonusSPD = 0; CritBonus = 0; CritResist = 0 }
$es = Get-EffectiveStats $testPet
Test-Assert "Effective stats calc" ($es.MaxHP -eq 100 -and $es.ATK -eq 10)

# Test 8: Required functions exist
$required = @("status","bank","daily","achievements","ego","capsule","h","pet","companion","battlepet","handbook","snake","monkeytype","wordle","zork","hangman","blackjack","roulette","craps","hilo","baccarat","slot","poker","td","rogue","say","chuck","kimir","mem","sysinfo","uptime","weather","ip","port","reload")
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

# Test 15: Adventure engine loads
Test-Assert "Adventure engine loaded" ((Get-Command Invoke-Adventure -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Adventure alias 'adv' exists" ((Get-Command adv -ErrorAction SilentlyContinue) -ne $null)

# Test 16: Adventure state roundtrip
$script:AdvState = Get-AdventureDefaults
$script:AdvState.CurrentRoom = "lab"
$script:AdvState.Inventory = @("card", "battery")
Save-AdventureState
Load-AdventureState
Test-Assert "Adventure state save/load" ($script:AdvState.CurrentRoom -eq "lab" -and $script:AdvState.Inventory -contains "card")

# Test 17: Adventure room connectivity
$hangar = Get-Room "hangar"
Test-Assert "Hangar connects to corridor" ($hangar.Exits["north"] -eq "corridor")
Test-Assert "Corridor has bridge exit (locked by default)" ((Get-Room "corridor").Exits["north"] -eq $null)

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
Save-AdventureState
Load-AdventureState
Test-Assert "Companion AI state persists" ($script:AdvState.CompanionAI.Mood -eq "Excited")

# Test 21: Running gag counter
$script:AdvState.CompanionAI.RunningGags = @{}
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

# Test 24: Companion hint system
$script:AdvState.CompanionAI = Get-CompanionAIDefaults
$script:AdvState.CompanionAI.MovesWithoutProgress = 10
$script:AdvState.Flags = @{}
$script:AdvState.Inventory = @()
$hint = Get-CompanionHint (Get-Room "hangar")
$hasCompanion = $false
try { $hasCompanion = (Get-PetState).Companion -ne $null } catch {}
Test-Assert "Companion gives hint when stuck (hasCompanion=$hasCompanion)" ($hint -ne $null -or -not $hasCompanion)

# Summary
Write-Host "`n  ========================================" -ForegroundColor Cyan
Write-Host "  Tests: $tests | Passed: $($tests - $errors) | Failed: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "  ========================================" -ForegroundColor Cyan
if ($errors -eq 0) { Write-Host "`n  ALL INTEGRATION TESTS PASSED!`n" -ForegroundColor Green }
else { Write-Host "`n  $errors TEST(S) FAILED.`n" -ForegroundColor Red }
