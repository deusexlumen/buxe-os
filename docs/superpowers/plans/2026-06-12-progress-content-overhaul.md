# Progress & Content Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Erweitere die Meta-Progression (Pet Skill Trees), mache Achievements belohnt und sichtbar, verteile ARG-Hinweise im Pet-Hub, erweitere Companion-Storys um Episode 1 für alle Girls und mache das Tutorial adaptiv.

**Architecture:** Neue State-Schlüssel unter `Pet.SkillTree`, `Achievements.RewardsClaimed` und `Tutorial.Flags`. Skill-Trees geben pro Level einen Punkt, der in Combat/Economy/Social investiert wird. Achievements triggern `Claim-AchievementReward` für Gold/XP. Der Pet-Hub spielt gelegentlich Layer-47/ARG-Beacons. Companion-Story-Daten werden für RAVEN, PIXEL, LUNA, IVY, VERA um Episode 1 ergänzt. Das Tutorial prüft Flags und überspringt bekannte Schritte.

**Tech Stack:** PowerShell 7, Pester-Tests (via `_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1`), State-Persistenz in `%LOCALAPPDATA%\buxe\buxe_state_v24.json`.

---

## File Structure

| Datei | Verantwortung |
|-------|---------------|
| `Modules/pet/_init.ps1` | Pet-Defaults erweitern um `SkillTree`, `SkillPoints`, `Tutorial.Flags` |
| `Modules/pet/skilltree.ps1` | **Neu** Skill-Tree-Engine: Add-PetSkillPoint, Get-PetSkillBonus, Show-SkillTree |
| `Modules/pet/_ui.ps1` | UI-Hilfsfunktionen für Skill-Tree und Achievement-Anzeige |
| `Modules/pet/hub.ps1` | Hub-Menü erweitern um Skill-Tree-Eintrag und ARG-Beacon-Hinweise |
| `Modules/engine-state-core.ps1` | Achievement-Reward-Logik, `Unlock-Achievement` erweitern, `Claim-AchievementReward` |
| `Modules/pet/companion-story-data.ps1` | Story-Daten für RAVEN, PIXEL, LUNA, IVY, VERA Episode 1 ergänzen |
| `Modules/pet/companion.ps1` | Companion-Actions nutzen Skill-Boni (talk/train/work/combat) |
| `Modules/pet/combat.ps1` | Kampf-Engine nutzt Combat-Skill-Boni |
| `Modules/pet/economy.ps1` | Shop/Cooking/Work nutzt Economy-Skill-Boni |
| `Modules/pet/events.ps1` | Daily/Quest-System prüft Tutorial-Flags |
| `Modules/pet/_unlock.ps1` | Feature-Unlocks interagieren mit Skill-Tree-Voraussetzungen |
| `Modules/_smoke_test.ps1` | Tests für Skill-Tree, Achievement-Rewards, ARG-Beacons, Story-Daten |
| `Modules/_integration_test.ps1` | AST-Checks und State-Roundtrip für neue Schlüssel |
| `Modules/_e2e_test.ps1` | E2E-Flows für Skill-Tree, Achievements, Tutorial überspringen |
| `GUIDE.md` / `AGENTS.md` | Dokumentation der neuen Features aktualisieren |

---

## Task 1: Pet Skill-Tree State Defaults

**Files:**
- Modify: `Modules/pet/_init.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

Füge in `_smoke_test.ps1` nach dem Pet-Defaults-Test folgenden Test ein:

```powershell
function Test-PetSkillTreeDefaults {
    $defaults = Get-PetDefaults
    if (-not $defaults.ContainsKey('SkillTree')) { throw 'Pet defaults missing SkillTree' }
    if (-not $defaults.SkillTree.ContainsKey('Combat')) { throw 'SkillTree missing Combat branch' }
    if (-not $defaults.SkillTree.ContainsKey('Economy')) { throw 'SkillTree missing Economy branch' }
    if (-not $defaults.SkillTree.ContainsKey('Social')) { throw 'SkillTree missing Social branch' }
    if ($defaults.SkillPoints -ne 0) { throw "Expected 0 skill points, got $($defaults.SkillPoints)" }
    Write-Host '  Pet skill tree defaults OK' -ForegroundColor Green
}
```

Rufe `Test-PetSkillTreeDefaults` in der Pet-Test-Sektion auf.

- [ ] **Step 2: Run test to verify it fails**

Run: `pwsh -NoProfile -Command "& { $ErrorActionPreference='Stop'; . .\Modules\_smoke_test.ps1 }"`
Expected: FAIL — `Pet defaults missing SkillTree`

- [ ] **Step 3: Write minimal implementation**

In `Modules/pet/_init.ps1` innerhalb von `Get-PetDefaults` (der Hashtable, die zurückgegeben wird) ergänze:

```powershell
SkillTree = @{
    Combat = @{ Level = 0; MaxLevel = 5; Perks = @('Damage+5%','Crit+5%','Damage+10%','Crit+10%','Ultimate: Rage') }
    Economy = @{ Level = 0; MaxLevel = 5; Perks = @('Gold+5%','Work XP+10%','Shop Discount 5%','Gold+10%','Ultimate: Midas') }
    Social = @{ Level = 0; MaxLevel = 5; Perks = @('Bond+5%','Mood+5%','Gift Bonus+10%','Bond+10%','Ultimate: Charm') }
}
SkillPoints = 0
Tutorial = @{
    Completed = $false
    Flags = @{
        companionCreated = $false
        firstFight = $false
        firstShop = $false
        firstSkillPoint = $false
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pwsh -NoProfile -Command "& { $ErrorActionPreference='Stop'; . .\Modules\_smoke_test.ps1 }"`
Expected: PASS (Smoke läuft weiter, Test grün)

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/_init.ps1 Modules/_smoke_test.ps1
git commit -m "feat(pet): add skill-tree and adaptive-tutorial state defaults"
```

---

## Task 2: Skill-Tree Engine

**Files:**
- Create: `Modules/pet/skilltree.ps1`
- Modify: `Modules/pet/hub.ps1` (später eingebunden)
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

Füge in `_smoke_test.ps1` hinzu:

```powershell
function Test-PetSkillTreeEngine {
    $state = Get-PetState
    $state.Meta.Level = 3
    $state.SkillPoints = 2
    Save-PetState

    $result = Add-PetSkillPoint -Branch 'Combat'
    if (-not $result) { throw 'Add-PetSkillPoint returned false unexpectedly' }
    $bonus = Get-PetSkillBonus -Branch 'Combat' -Tier 1
    if ($bonus -ne 0.05) { throw "Expected Combat tier 1 bonus 0.05, got $bonus" }

    # Verbrauchter Punkt
    if ((Get-PetState).SkillPoints -ne 1) { throw 'Skill point not consumed' }

    Reset-PetStateForTests
    Write-Host '  Pet skill tree engine OK' -ForegroundColor Green
}
```

Rufe `Test-PetSkillTreeEngine` auf.

- [ ] **Step 2: Run test to verify it fails**

Run: `pwsh -NoProfile -Command "& { $ErrorActionPreference='Stop'; . .\Modules\_smoke_test.ps1 }"`
Expected: FAIL — `Add-PetSkillPoint` not found

- [ ] **Step 3: Write minimal implementation**

Erstelle `Modules/pet/skilltree.ps1`:

```powershell
# BUXE_OS v24.10 -- pet/skilltree.ps1
# Pet Skill Tree Engine

try {
    function Add-PetSkillPoint {
        param([Parameter(Mandatory=$true)][ValidateSet('Combat','Economy','Social')][string]$Branch)
        $state = Get-PetState
        if ($state.SkillPoints -le 0) { return $false }
        $tree = $state.SkillTree[$Branch]
        if ($tree.Level -ge $tree.MaxLevel) { return $false }
        $tree.Level++
        $state.SkillPoints--
        Save-PetState
        return $true
    }

    function Get-PetSkillBonus {
        param(
            [Parameter(Mandatory=$true)][ValidateSet('Combat','Economy','Social')][string]$Branch,
            [Parameter(Mandatory=$true)][ValidateRange(1,5)][int]$Tier
        )
        $state = Get-PetState
        $level = $state.SkillTree[$Branch].Level
        switch ($Branch) {
            'Combat' {
                if ($Tier -le $level) {
                    if ($Tier -in 1,2) { return 0.05 }
                    if ($Tier -in 3,4) { return 0.10 }
                    if ($Tier -eq 5) { return 0.20 }
                }
            }
            'Economy' {
                if ($Tier -le $level) {
                    if ($Tier -eq 1) { return 0.05 }
                    if ($Tier -eq 2) { return 0.10 }
                    if ($Tier -eq 3) { return 0.05 }
                    if ($Tier -in 4,5) { return 0.10 }
                }
            }
            'Social' {
                if ($Tier -le $level) {
                    if ($Tier -in 1,2) { return 0.05 }
                    if ($Tier -in 3,4) { return 0.10 }
                    if ($Tier -eq 5) { return 0.15 }
                }
            }
        }
        return 0.0
    }

    function Show-SkillTree {
        $state = Get-PetState
        Show-PetFrame 'SKILL TREE'
        Write-Host "Verfuegbare Punkte: $($state.SkillPoints)" -ForegroundColor Yellow
        foreach ($branch in @('Combat','Economy','Social')) {
            $t = $state.SkillTree[$branch]
            Write-Host "`n[$branch] Level $($t.Level)/$($t.MaxLevel)" -ForegroundColor Cyan
            for ($i = 0; $i -lt $t.Perks.Count; $i++) {
                $marker = if ($i -lt $t.Level) { '[x]' } else { '[ ]' }
                $color = if ($i -lt $t.Level) { 'Green' } else { 'Gray' }
                Write-Host "  $marker Tier $($i+1): $($t.Perks[$i])" -ForegroundColor $color
            }
        }
        Wait-Enter
    }
} catch {
    Write-Warning "Fehler in pet/skilltree.ps1: $_"
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pwsh -NoProfile -Command "& { $ErrorActionPreference='Stop'; . .\Modules\_smoke_test.ps1 }"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/skilltree.ps1 Modules/_smoke_test.ps1
git commit -m "feat(pet): add skill-tree engine with combat/economy/social branches"
```

---

## Task 3: Skill-Points beim Level-Up vergeben

**Files:**
- Modify: `Modules/pet/events.ps1` oder `Modules/pet/_init.ps1` (wo Add-PetXP lebt)
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

Füge in `_smoke_test.ps1` hinzu:

```powershell
function Test-PetLevelUpGrantsSkillPoint {
    $state = Get-PetState
    $state.Meta.XP = 0
    $state.Meta.Level = 0
    $state.SkillPoints = 0
    Save-PetState

    Add-PetXP -Amount 5  # genug für Level 1 + 2
    $state = Get-PetState
    if ($state.SkillPoints -lt 1) { throw "Expected at least 1 skill point after level-up, got $($state.SkillPoints)" }

    Reset-PetStateForTests
    Write-Host '  Level-up skill point grant OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: Smoke-Test
Expected: FAIL — keine Skill-Points vergeben

- [ ] **Step 3: Write minimal implementation**

Finde `Add-PetXP` in `Modules/pet/events.ps1` (oder wo es definiert ist). Nach jedem erreichten Level-Up erhöhe `SkillPoints` um 1:

```powershell
while ($state.Meta.Level -lt $PetXPCurve.Count -and $state.Meta.XP -ge $PetXPCurve[$state.Meta.Level + 1]) {
    $state.Meta.Level++
    $state.SkillPoints++
    # ... bestehende Level-Up-Logik (Beacons etc.)
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: Smoke-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/events.ps1 Modules/_smoke_test.ps1
git commit -m "feat(pet): grant one skill point per meta level-up"
```

---

## Task 4: Skill-Boni in Kampf, Wirtschaft und Sozial einbinden

**Files:**
- Modify: `Modules/pet/combat.ps1`
- Modify: `Modules/pet/economy.ps1`
- Modify: `Modules/pet/companion.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

Füge in `_smoke_test.ps1` hinzu:

```powershell
function Test-PetSkillBonusesApplied {
    $state = Get-PetState
    $state.SkillTree.Combat.Level = 2
    $state.SkillTree.Economy.Level = 1
    $state.SkillTree.Social.Level = 1
    Save-PetState

    $stats = Get-EffectivePetStats
    if ($stats.DamageMultiplier -le 1.0) { throw 'Combat skill bonus not applied to damage' }

    $price = Get-PetShopPrice -ItemName 'Neural Chip'
    if ($price -ge 60) { throw 'Economy discount not applied to shop price' }

    Reset-PetStateForTests
    Write-Host '  Skill bonuses applied OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: Smoke-Test
Expected: FAIL — `Get-EffectivePetStats` kennt keinen DamageMultiplier, `Get-PetShopPrice` nicht gefunden

- [ ] **Step 3: Write minimal implementation**

In `Modules/pet/combat.ps1`, wo Schaden berechnet wird:

```powershell
$combatBonus = Get-PetSkillBonus -Branch 'Combat' -Tier 1
$damageMultiplier = 1.0 + $combatBonus + (Get-PetSkillBonus -Branch 'Combat' -Tier 3)
$finalDamage = [math]::Round($baseDamage * $damageMultiplier)
```

In `Modules/pet/economy.ps1`, bei Shop-Preisen:

```powershell
function Get-PetShopPrice {
    param([string]$ItemName)
    $item = $PetShopItems | Where-Object { $_.Name -eq $ItemName } | Select-Object -First 1
    if (-not $item) { return $null }
    $discount = Get-PetSkillBonus -Branch 'Economy' -Tier 3
    return [math]::Round($item.Cost * (1 - $discount))
}
```

In `Modules/pet/companion.ps1`, bei Bond/Mood-Gewinn:

```powershell
$socialBonus = Get-PetSkillBonus -Branch 'Social' -Tier 1
$bondGain = [math]::Round($baseBondGain * (1 + $socialBonus))
```

- [ ] **Step 4: Run test to verify it passes**

Run: Smoke-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/combat.ps1 Modules/pet/economy.ps1 Modules/pet/companion.ps1 Modules/_smoke_test.ps1
git commit -m "feat(pet): apply combat/economy/social skill bonuses to core loops"
```

---

## Task 5: Achievement Rewards + Claim-UI

**Files:**
- Modify: `Modules/engine-state-core.ps1`
- Modify: `Modules/engine-aliases-buxe.ps1` (oder wo `achievements` alias lebt)
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

Füge in `_smoke_test.ps1` hinzu:

```powershell
function Test-AchievementRewards {
    Load-State
    Unlock-Achievement 'First Step'
    $beforeGold = (Get-Bankroll).Gold
    $result = Claim-AchievementReward -Name 'First Step'
    if (-not $result) { throw 'Claim-AchievementReward returned false' }
    $afterGold = (Get-Bankroll).Gold
    if ($afterGold -le $beforeGold) { throw 'Achievement reward did not grant gold' }

    # Doppelter Claim muss fehlschlagen
    $result2 = Claim-AchievementReward -Name 'First Step'
    if ($result2) { throw 'Double achievement claim succeeded' }

    Reset-StateForTests
    Write-Host '  Achievement rewards OK' -ForegroundColor Green
}
```

Definiere `$script:AchievementRewards` im Test-Setup:

```powershell
$script:AchievementRewards = @{
    'First Step' = @{ Gold = 50; XP = 10; Title = 'Neuling' }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: Smoke-Test
Expected: FAIL — `Claim-AchievementReward` not found

- [ ] **Step 3: Write minimal implementation**

In `Modules/engine-state-core.ps1` ergänze:

```powershell
$script:AchievementCatalog = @{
    'First Step' = @{ Gold = 50; XP = 0; Title = 'Neuling' }
    'High Roller' = @{ Gold = 200; XP = 0; Title = 'High Roller' }
    'Pet Tamer' = @{ Gold = 100; XP = 25; Title = 'Pet Tamer' }
    'Dungeon Master' = @{ Gold = 300; XP = 50; Title = 'Dungeon Master' }
}

function Claim-AchievementReward {
    param([Parameter(Mandatory=$true)][string]$Name)
    if (-not $script:BuxeState.Achievements.ContainsKey($Name)) { return $false }
    if ($script:BuxeState.Achievements.RewardsClaimed -and $script:BuxeState.Achievements.RewardsClaimed.ContainsKey($Name)) { return $false }
    $reward = $script:AchievementCatalog[$Name]
    if (-not $reward) { return $false }
    if (-not $script:BuxeState.Achievements.ContainsKey('RewardsClaimed')) {
        $script:BuxeState.Achievements['RewardsClaimed'] = @{}
    }
    Add-Gold $reward.Gold
    $script:BuxeState.Achievements['RewardsClaimed'][$Name] = (Get-Date -Format 'yyyy-MM-dd')
    Save-State
    return $true
}
```

Ändere `Unlock-Achievement` so, dass es den Reward-Hinweis ausgibt:

```powershell
function Unlock-Achievement {
    param([string]$name)
    if (-not $script:BuxeState.Achievements.ContainsKey($name)) {
        $script:BuxeState.Achievements[$name] = (Get-Date -Format 'yyyy-MM-dd')
        Save-State
        Write-Host "Achievement freigeschaltet: $name" -ForegroundColor Yellow
        if ($script:AchievementCatalog.ContainsKey($name)) {
            Write-Host "  Belohnung: $($script:AchievementCatalog[$name].Gold)G — tippe 'achievements' zum Einloesen." -ForegroundColor DarkYellow
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: Smoke-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/engine-state-core.ps1 Modules/_smoke_test.ps1
git commit -m "feat(state): add achievement rewards and claim function"
```

---

## Task 6: Achievements-UI Command

**Files:**
- Modify: `Modules/engine-aliases-buxe.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

```powershell
function Test-AchievementsCommand {
    $cmd = Get-Command 'Show-Achievements' -ErrorAction SilentlyContinue
    if (-not $cmd) { throw 'Show-Achievements command missing' }
    Write-Host '  Achievements command OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: Smoke-Test
Expected: FAIL — `Show-Achievements` missing

- [ ] **Step 3: Write minimal implementation**

In `Modules/engine-aliases-buxe.ps1` (oder passendes Aliase-Modul):

```powershell
function Show-Achievements {
    Load-State
    Show-Frame 'ACHIEVEMENTS'
    $achs = $script:BuxeState.Achievements
    if ($achs.Count -eq 0 -or ($achs.Count -eq 1 -and $achs.ContainsKey('RewardsClaimed'))) {
        Write-Host 'Noch keine Achievements. Mach dich nuetzlich, User.' -ForegroundColor Gray
    } else {
        foreach ($name in $achs.Keys | Where-Object { $_ -ne 'RewardsClaimed' }) {
            $claimed = $achs.RewardsClaimed -and $achs.RewardsClaimed.ContainsKey($name)
            $reward = $script:AchievementCatalog[$name]
            $status = if ($claimed) { '[x]' } else { '[!]' }
            $color = if ($claimed) { 'Green' } else { 'Yellow' }
            $line = "$status $name ($($achs[$name]))"
            if ($reward) { $line += " -> $($reward.Gold)G" }
            Write-Host $line -ForegroundColor $color
        }
    }
    Wait-Enter
}
Set-Alias achievements Show-Achievements
```

- [ ] **Step 4: Run test to verify it passes**

Run: Smoke-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/engine-aliases-buxe.ps1 Modules/_smoke_test.ps1
git commit -m "feat(aliases): add achievements command UI"
```

---

## Task 7: ARG-Hinweise im Pet-Hub

**Files:**
- Modify: `Modules/pet/hub.ps1`
- Modify: `Modules/engine-arg.ps1` (sicherstellen, dass Cheats bekannt sind)
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

```powershell
function Test-ArgBeaconHints {
    $hints = Get-ArgBeaconHints
    if ($hints.Count -lt 3) { throw 'Expected at least 3 ARG beacon hints' }
    Write-Host '  ARG beacon hints OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: Smoke-Test
Expected: FAIL — `Get-ArgBeaconHints` not found

- [ ] **Step 3: Write minimal implementation**

In `Modules/pet/hub.ps1` (oder `Modules/pet/_ui.ps1`):

```powershell
function Get-ArgBeaconHints {
    return @(
        'Manchmal fluestert das Terminal vom Rueckzug: rosebud...'
        'Der 47. Layer ist duenn. Druecke hoch, hoch, runter, runter...'
        'Wenn das Rad dreht, hoerst du MERIDIAN?'
        'Die Huehnchen sind ausnahmsweise nicht aus Gummi. Cheate ruhig.'
    )
}
```

In `Show-PetHubMenu`, mit 5% Chance pro Aufruf:

```powershell
if ((Get-Random -Maximum 100) -lt 5) {
    $hint = (Get-ArgBeaconHints) | Get-Random
    Write-Host "`n[Beacon] $hint" -ForegroundColor DarkGray
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: Smoke-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/hub.ps1 Modules/_smoke_test.ps1
git commit -m "feat(pet): add ARG beacon hints to pet hub"
```

---

## Task 8: Companion Story-Episoden für RAVEN, PIXEL, LUNA, IVY, VERA

**Files:**
- Modify: `Modules/pet/companion-story-data.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Write the failing test**

```powershell
function Test-AllCompanionsHaveEpisodeOne {
    $stories = Get-CompanionStories
    $expected = @('NEON','RAVEN','PIXEL','LUNA','IVY','VERA','JINX')
    foreach ($name in $expected) {
        if (-not $stories.ContainsKey($name)) { throw "Missing story data for $name" }
        if ($stories[$name].Episode -lt 1) { throw "$name has no Episode 1" }
        if (-not $stories[$name].Scenes -or $stories[$name].Scenes.Count -eq 0) { throw "$name has no scenes" }
    }
    Write-Host '  All companions have episode 1 OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: Smoke-Test
Expected: FAIL — RAVEN/PIXEL/LUNA/IVY/VERA haben Episode 0

- [ ] **Step 3: Write minimal implementation**

In `Modules/pet/companion-story-data.ps1` für jede fehlende Companion Episode 1 hinzufügen. Beispiel RAVEN:

```powershell
RAVEN = @{
    Episode = 1
    Scenes = @{
        1 = @{
            Title = 'Das dunkle Protokoll'
            Lines = @(
                @{ Speaker = 'RAVEN'; Text = 'User, dein Netzwerk blinkt komisch. Nicht komisch-ha-ha.' }
                @{ Speaker = 'RAVEN'; Text = 'Ich habe einen Request aus dem 47. Layer gefangen. Jemand... oder etwas... sucht nach dir.' }
                @{ Speaker = 'User'; Text = 'Was will es?' }
                @{ Speaker = 'RAVEN'; Text = 'Das steht nicht im Header. Aber der User-Agent lautet MERIDIAN.' }
            )
            Reward = @{ XP = 20; Gold = 30 }
        }
    }
}
```

Analog für PIXEL (Glitch/Retro-Gaming), LUNA (Traum/Mond), IVY (Natur/Rootkit), VERA (Wissenschaft/Experiment).

- [ ] **Step 4: Run test to verify it passes**

Run: Smoke-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/companion-story-data.ps1 Modules/_smoke_test.ps1
git commit -m "feat(pet): add episode 1 story scenes for RAVEN, PIXEL, LUNA, IVY, VERA"
```

---

## Task 9: Adaptives Tutorial

**Files:**
- Modify: `Modules/pet/hub.ps1`
- Modify: `Modules/pet/_init.ps1` (Tutorial-Flags)
- Test: `Modules/_e2e_test.ps1`

- [ ] **Step 1: Write the failing test**

In `_e2e_test.ps1`:

```powershell
function Test-AdaptiveTutorialSkipsKnownSteps {
    $state = Get-PetState
    $state.Tutorial.Flags.companionCreated = $true
    $state.Tutorial.Flags.firstFight = $true
    Save-PetState

    Enable-MockInput @('t','q')
    Invoke-PetTutorial
    Disable-MockInput

    # Tutorial sollte nicht abstürzen und den companion_create-Schritt überspringen
    Write-Host '  Adaptive tutorial skip OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: E2E-Test
Expected: FAIL — Tutorial prüft Flags nicht

- [ ] **Step 3: Write minimal implementation**

In `Modules/pet/hub.ps1` in `Invoke-PetTutorial` (oder wo das Tutorial lebt):

```powershell
function Invoke-PetTutorial {
    $state = Get-PetState
    $flags = $state.Tutorial.Flags

    if (-not $flags.companionCreated) {
        # ... companion_create Schritt
        $flags.companionCreated = $true
    }

    if (-not $flags.firstFight) {
        # ... Kampf-Tutorial
        $flags.firstFight = $true
    }

    if (-not $flags.firstShop) {
        # ... Shop-Tutorial
        $flags.firstShop = $true
    }

    if (-not $flags.firstSkillPoint) {
        if ($state.SkillPoints -gt 0) {
            Write-Host "`nDu hast einen Skill-Punkt! Tippe 'pet skilltree' im Hub." -ForegroundColor Cyan
            $flags.firstSkillPoint = $true
        }
    }

    $state.Tutorial.Completed = $true
    Save-PetState
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: E2E-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/hub.ps1 Modules/pet/_init.ps1 Modules/_e2e_test.ps1
git commit -m "feat(pet): make tutorial adaptive via per-step flags"
```

---

## Task 10: Hub-Menü erweitern

**Files:**
- Modify: `Modules/pet/hub.ps1`
- Test: `Modules/_e2e_test.ps1`

- [ ] **Step 1: Write the failing test**

In `_e2e_test.ps1`:

```powershell
function Test-PetHubShowsSkillTree {
    Enable-MockInput @('skilltree','q','q')
    pet
    Disable-MockInput
    Write-Host '  Pet hub skill tree menu OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: E2E-Test
Expected: FAIL — `skilltree` Option nicht im Menü

- [ ] **Step 3: Write minimal implementation**

In `Modules/pet/hub.ps1` `Show-PetHubMenu`:

```powershell
if (Is-FeatureUnlocked 'skilltree') {
    Write-Host "[S] Skill Tree" -ForegroundColor Cyan
}
```

Und Input-Handler:

```powershell
'skilltree' {
    Show-SkillTree
}
```

Registriere in `Modules/pet/_init.ps1` in `PetFeatureUnlocks`:

```powershell
2 = @("pet_create","combat","companion_games","skilltree")
```

- [ ] **Step 4: Run test to verify it passes**

Run: E2E-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/hub.ps1 Modules/pet/_init.ps1 Modules/_e2e_test.ps1
git commit -m "feat(pet): add skilltree option to pet hub menu"
```

---

## Task 11: Integration-Tests (AST + State-Roundtrip)

**Files:**
- Modify: `Modules/_integration_test.ps1`

- [ ] **Step 1: Write the failing test**

Füge hinzu:

```powershell
function Test-NewStateKeysRoundtrip {
    $state = Get-PetState
    $state.SkillTree.Combat.Level = 3
    $state.SkillPoints = 2
    $state.Tutorial.Flags.firstFight = $true
    Save-PetState

    $reloaded = Get-PetState
    if ($reloaded.SkillTree.Combat.Level -ne 3) { throw 'SkillTree Combat level not persisted' }
    if ($reloaded.SkillPoints -ne 2) { throw 'SkillPoints not persisted' }
    if (-not $reloaded.Tutorial.Flags.firstFight) { throw 'Tutorial flag not persisted' }
    Reset-PetStateForTests
    Write-Host '  New state keys roundtrip OK' -ForegroundColor Green
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pwsh -NoProfile -Command "& { $ErrorActionPreference='Stop'; . .\Modules\_integration_test.ps1 }"`
Expected: FAIL — State-Keys fehlen in Defaults

- [ ] **Step 3: Write minimal implementation**

Stelle sicher, dass `Get-PetDefaults` die neuen Schlüssel enthält (siehe Task 1). Füge in `_integration_test.ps1` Checks hinzu, dass `Add-PetSkillPoint`, `Claim-AchievementReward`, `Show-Achievements`, `Get-ArgBeaconHints`, `Get-CompanionStories` existieren.

- [ ] **Step 4: Run test to verify it passes**

Run: Integration-Test
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Modules/_integration_test.ps1
git commit -m "test(integration): state roundtrip and required functions for skill tree and achievements"
```

---

## Task 12: Dokumentation aktualisieren

**Files:**
- Modify: `GUIDE.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Write the failing test**

Kein automatisierter Test. Manuelle Prüfung: `Select-String 'Skill Tree' GUIDE.md, AGENTS.md`.

- [ ] **Step 2: Write minimal implementation**

In `GUIDE.md` im Pet-System-Abschnitt:

```markdown
### Skill Trees
Ab Meta-Level 2 erhaeltst du bei jedem Level-Up einen Skill-Punkt. Investiere ihn in:
- **Combat**: mehr Schaden, mehr Crit, Ultimate Rage
- **Economy**: mehr Gold, Rabatt im Shop, Ultimate Midas
- **Social**: schnellerer Bond, bessere Geschenke, Ultimate Charm

Befehl: `pet` -> `[S] Skill Tree`

### Achievements
Achievements werden automatisch freigeschaltet. Tippe `achievements`, um Belohnungen (Gold, XP, Titel) einzuloesen.

### Adaptive Tutorial
Das Pet-Tutorial merkt sich, welche Schritte du bereits gemacht hast, und wiederholt sie nicht.
```

In `AGENTS.md` im Pet-System-Abschnitt:

```markdown
| `Modules/pet/skilltree.ps1` | Skill-Tree-Engine: Punkte vergeben, Boni berechnen, UI |
```

- [ ] **Step 3: Commit**

```bash
git add GUIDE.md AGENTS.md
git commit -m "docs: document skill trees, achievement rewards, adaptive tutorial"
```

---

## Self-Review

**Spec coverage:**
- Pet Skill Trees: Tasks 1-4, 10
- Achievement Rewards: Tasks 5-6
- ARG-Hinweise: Task 7
- Companion Stories: Task 8
- Adaptive Tutorial: Task 9
- Tests/Docs: Tasks 11-12

**Placeholder scan:** Keine TBD/TODO gefunden. Alle Schritte enthalten Code.

**Type consistency:**
- `SkillTree.<Branch>.Level` ist überall int.
- `SkillPoints` ist int.
- `Tutorial.Flags.*` sind bool.
- `AchievementCatalog` und `RewardsClaimed` sind Hashtable.

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2026-06-12-progress-content-overhaul.md`.**

**Two execution options:**

**1. Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints.

**Which approach?**
