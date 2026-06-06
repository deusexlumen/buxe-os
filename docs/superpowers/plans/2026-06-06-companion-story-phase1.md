# Companion Story Events — Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `Invoke-CompanionEpisode` engine and ship 2 proof-of-concept episodes (NEON + JINX) with LucasArts-style title screens, branching choices, and Bond-aware dialogue.

**Architecture:** A generic story engine (`companion-story.ps1`) reads episode definitions from hashtables, renders title screens via `Show-PetFrame`, presents choices via `Read-Choice`, and persists progress in `Pet.CompanionStories`. Each episode is a self-contained hashtable with scenes, choices, and outcomes.

**Tech Stack:** PowerShell 7, existing TUI framework (`engine-scene.ps1`, `engine-render.ps1`, `engine-input.ps1`), existing Pet UI (`pet/_ui.ps1`, `Show-CompanionDialog`), existing state system (`engine-state-core.ps1`).

---

## File Structure

| File | Responsibility |
|------|---------------|
| `Modules/pet/companion-story.ps1` | Story engine, episode runner, choice handler, state integration |
| `Modules/pet/companion-story-data.ps1` | Episode definitions for all 7 companions (hashtables) |
| `Modules/pet/hub.ps1` | Add `[S] Story` menu item, route to story engine |
| `Modules/pet/_init.ps1` | Add `CompanionStories` to `Get-PetDefaults`, unlock at Meta-Level 3 |
| `Modules/_e2e_test.ps1` | Add E2E flow for NEON Episode 1 |
| `Modules/_smoke_test.ps1` | Add smoke tests for story engine functions |

---

## Task 1: Extend Pet State for Stories

**Files:**
- Modify: `Modules/pet/_init.ps1`

**Context:** `Get-PetDefaults` returns the default state hashtable. We need a `CompanionStories` branch for each companion.

- [ ] **Step 1: Add `CompanionStories` defaults to `Get-PetDefaults`**

Find the `Get-PetDefaults` function. After the `Pet` block (around line 80-120), add:

```powershell
CompanionStories = @{
    NEON  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
    RAVEN = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
    PIXEL = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
    LUNA  = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
    IVY   = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
    VERA  = @{ Episode = 0; Choices = @(); Completed = $false; LastPlayed = $null }
    JINX  = @{ Episode = 1; Choices = @(); Completed = $false; LastPlayed = $null }
}
```

**Why Episode 1 for NEON and JINX?** They are the proof-of-concept companions with complete Episode 1 data.

- [ ] **Step 2: Add feature unlock for `companion_story` in `PetFeatureUnlocks`**

Find the `$script:PetFeatureUnlocks` hashtable. Add:

```powershell
companion_story = 3
```

This unlocks the story feature at Meta-Level 3.

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/_init.ps1
git commit -m "feat(story): add CompanionStories state defaults and feature unlock"
```

---

## Task 2: Build the Story Engine

**Files:**
- Create: `Modules/pet/companion-story.ps1`

**Context:** The engine must be generic — it reads an episode definition and runs it. No hard-coded story logic in the engine.

- [ ] **Step 1: Create file header and episode structure documentation**

```powershell
# BUXE_OS v25.0 — COMPANION STORY ENGINE v1.0
# Generic episode runner for companion storylines

try {
```

Episode definition format (documented in comments):
```powershell
# $episode = @{
#   Title = "Episode Title"
#   Companion = "NEON"
#   Scenes = @(
#     @{ Id = 1; Text = "..."; Choices = @(
#       @{ Label = "A"; Text = "..."; NextScene = 2; BondDelta = 5; Outcome = "..." }
#     )}
#   )
# }
```

- [ ] **Step 2: Implement `Invoke-CompanionEpisode`**

```powershell
function Invoke-CompanionEpisode {
    param([string]$CompanionName)

    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion aktiv."; Wait-Enter; return }
    if ($cp.Name -ne $CompanionName) {
        Write-Host "Diese Story ist fuer $CompanionName. Dein Companion ist $($cp.Name)."
        Wait-Enter; return
    }

    $story = $pet.CompanionStories[$CompanionName]
    if (-not $story) { Write-Host "Keine Story-Daten gefunden."; Wait-Enter; return }

    $episodeNum = $story.Episode
    if ($episodeNum -eq 0) { Write-Host "Keine Episode verfuegbar."; Wait-Enter; return }
    if ($story.Completed) { Write-Host "Diese Episode ist abgeschlossen."; Wait-Enter; return }

    $episode = Get-CompanionEpisodeData -Companion $CompanionName -Episode $episodeNum
    if (-not $episode) { Write-Host "Episode $episodeNum nicht gefunden."; Wait-Enter; return }

    # Title screen
    try { Clear-Host } catch {}
    Show-PetFrame "$($episode.Title)" -Double | Out-Null
    Write-Host "`n  Episode $episodeNum — $($episode.Subtitle)" -ForegroundColor Yellow
    Write-Host "  Companion: $($cp.Name) | Bond: $($cp.Bond)/100" -ForegroundColor DarkGray
    Write-Host "`n  [ENTER] Starten" -ForegroundColor White
    Wait-Enter

    $currentSceneId = 1
    $choicesMade = @()

    while ($currentSceneId -ne -1) {
        $scene = $episode.Scenes | Where-Object { $_.Id -eq $currentSceneId }
        if (-not $scene) { break }

        try { Clear-Host } catch {}
        Show-PetFrame "$($episode.Title) — Szene $currentSceneId" -Double | Out-Null

        # Render scene text with typewriter feel
        foreach ($line in $scene.Text) {
            Write-Host "  $line" -ForegroundColor White
            Start-Sleep -Milliseconds 200
        }

        # Companion reaction dialog
        if ($scene.DialogLine) {
            Show-CompanionDialog $cp $scene.DialogLine -Fast
        }

        # Choices
        if ($scene.Choices) {
            Write-Host ""
            $choiceKeys = @()
            $i = 1
            foreach ($choice in $scene.Choices) {
                $key = [char](64 + $i)  # A, B, C...
                $choiceKeys += $key
                Write-Host "  [$key] $($choice.Text)" -ForegroundColor Cyan
                $i++
            }
            Write-Host "  [Q] Abbrechen" -ForegroundColor DarkGray

            $validPattern = '^[' + ($choiceKeys -join '') + 'Q]$'
            $input = Read-Choice "Waehle" $validPattern

            if ($input -eq 'Q') { return }

            $selected = $scene.Choices[$choiceKeys.IndexOf($input)]
            $choicesMade += @{ Scene = $currentSceneId; Choice = $input; Text = $selected.Text }

            # Apply bond delta
            if ($selected.BondDelta) {
                $cp.Bond = [math]::Min(100, [math]::Max(0, $cp.Bond + $selected.BondDelta))
            }

            # Show outcome text
            if ($selected.Outcome) {
                Write-Host "`n  $($selected.Outcome)" -ForegroundColor Magenta
                Start-Sleep -Milliseconds 500
            }

            $currentSceneId = $selected.NextScene
        } else {
            # No choices — end scene
            Wait-Enter
            $currentSceneId = $scene.NextScene
        }
    }

    # Episode complete
    $story.Completed = $true
    $story.Choices = $choicesMade
    $story.LastPlayed = (Get-Date).ToString("yyyy-MM-dd")

    # Unlock next episode (if any)
    $nextEpisode = Get-CompanionEpisodeData -Companion $CompanionName -Episode ($episodeNum + 1)
    if ($nextEpisode) {
        $story.Episode = $episodeNum + 1
        $story.Completed = $false
        Write-Host "`n  [FREIGESCHALTET] Episode $($episodeNum + 1)!" -ForegroundColor Green
    } else {
        Write-Host "`n  [ABGESCHLOSSEN] Story von $($cp.Name) beendet!" -ForegroundColor Green
    }

    Add-PetXP 15 "Story"
    Save-PetState $pet
    Show-CompanionDialog $cp (Get-CompanionLine $cp "story_complete") -Fast
    Wait-Enter
}
```

- [ ] **Step 3: Implement helper `Get-CompanionEpisodeData`**

```powershell
function Get-CompanionEpisodeData {
    param([string]$Companion, [int]$Episode)

    # Source the data file if not already loaded
    if (-not $script:CompanionEpisodeData) {
        $dataPath = Join-Path $PSScriptRoot "companion-story-data.ps1"
        if (Test-Path $dataPath) { . $dataPath }
    }

    if ($script:CompanionEpisodeData -and $script:CompanionEpisodeData[$Companion]) {
        return $script:CompanionEpisodeData[$Companion][$Episode]
    }
    return $null
}
```

- [ ] **Step 4: Close the try block**

```powershell
} catch {
    Write-Host "Fehler in companion-story.ps1: $_" -ForegroundColor Red
}
```

- [ ] **Step 5: Commit**

```bash
git add Modules/pet/companion-story.ps1
git commit -m "feat(story): add generic episode runner engine"
```

---

## Task 3: Create Episode Data for NEON and JINX

**Files:**
- Create: `Modules/pet/companion-story-data.ps1`

**Context:** Each episode is a hashtable. We create 2 episodes as proof-of-concept.

- [ ] **Step 1: Create NEON Episode 1 — "Der Netrunner der nie disconnectete"**

```powershell
# BUXE_OS v25.0 — COMPANION STORY DATA v1.0
# Episode definitions for all companions

try {

$script:CompanionEpisodeData = @{
    NEON = @{
        1 = @{
            Title = "Der Netrunner der nie disconnectete"
            Subtitle = "Episode 1: Der alte Client"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "Es ist 3 Uhr morgens. Dein Terminal flackert.",
                        "Eine Nachricht aus der Vergangenheit..."
                    )
                    DialogLine = "Ugh. Das ist nicht gut. Das ist ueberhaupt nicht gut."
                    Choices = @(
                        @{
                            Label = "A"; Text = "Nachricht oeffnen"
                            NextScene = 2; BondDelta = 2
                            Outcome = "NEON nickt langsam. 'Du bist mutiger, als du aussiehst.'"
                        },
                        @{
                            Label = "B"; Text = "Ignorieren und weiterarbeiten"
                            NextScene = 3; BondDelta = -2
                            Outcome = "NEON seufzt. 'Typisch. Immer wegsehen.'"
                        }
                    )
                },
                @{
                    Id = 2
                    Text = @(
                        "Die Nachricht enthaelt Koordinaten.",
                        "Ein Server, den NEON vor Jahren versteckt hat."
                    )
                    DialogLine = "Das ist mein Backup. Mein VERSTECKTES Backup."
                    Choices = @(
                        @{
                            Label = "A"; Text = "Gemeinsam zum Server"
                            NextScene = 4; BondDelta = 5
                            Outcome = "NEON laechelt — fast. 'Endlich jemand, der mithalten kann.'"
                        },
                        @{
                            Label = "B"; Text = "NEON allein schicken"
                            NextScene = 5; BondDelta = -3
                            Outcome = "NEON starrt dich an. 'Allein? Nach allem?'"
                        }
                    )
                },
                @{
                    Id = 3
                    Text = @(
                        "Du arbeitest weiter. Aber etwas stimm nicht.",
                        "Der Bildschirm flackert erneut."
                    )
                    DialogLine = "Siehst du? Man kann nicht einfach wegsehen."
                    Choices = @(
                        @{
                            Label = "A"; Text = "Jetzt doch oeffnen"
                            NextScene = 2; BondDelta = 0
                            Outcome = "NEON schnaubt. 'Besser spaet als nie, oder?'"
                        }
                    )
                },
                @{
                    Id = 4
                    Text = @(
                        "Gemeinsam brecht ihr zum Server auf.",
                        "NEON bewegt sich mit einer Anmut, die du noch nie gesehen hast.",
                        "Der Server ist intakt. Und er enthaelt mehr als nur Backups..."
                    )
                    DialogLine = "Das... das sind Erinnerungen. Meine ERSTEN Erinnerungen."
                    Choices = @()
                    NextScene = -1
                },
                @{
                    Id = 5
                    Text = @(
                        "NEON verschwindet im Netz. Minuten vergehen.",
                        "Dann: Ein Fehler. Ein schwerer Fehler.",
                        "NEON kehrt zurueck — beschaedigt, aber lebendig."
                    )
                    DialogLine = "Das haette schiefgehen koennen. Schlimmer schiefgehen."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
```

- [ ] **Step 2: Create JINX Episode 1 — "Die 47. Verschwoerung"**

```powershell
    JINX = @{
        1 = @{
            Title = "Die 47. Verschwoerung"
            Subtitle = "Episode 1: Die Zahl"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "JINX sitzt auf deinem Desktop-Icon fuer den Papierkorb.",
                        "Sie haelt 47 Popcorn-Koerner in einer Hand.",
                        "'Es ist ALLES 47', flüstert sie. '47 Prozesse. 47 Tabs. 47...'"
                    )
                    DialogLine = "Du glaubst mir nicht. NIEMAND glaubt mir."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Zeig es mir.'"
                            NextScene = 2; BondDelta = 5
                            Outcome = "JINX springt auf. 'ENDLICH! Ein Zeuge!'"
                        },
                        @{
                            Label = "B"; Text = "'Das ist Zufall, JINX.'"
                            NextScene = 3; BondDelta = -3
                            Outcome = "JINX starrt dich an. 'Zufall? ZUFALL?'"
                        }
                    )
                },
                @{
                    Id = 2
                    Text = @(
                        "JINX fuehrt dich durch dein eigenes System.",
                        "47 Log-Eintraege. 47 Fehlermeldungen. 47... Autosaves?",
                        "'Siehst du? Siehst du jetzt?', jubelt sie."
                    )
                    DialogLine = "Die Matrix spricht zu uns. In ihrer Lieblingssprache."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Wer steckt dahinter?'"
                            NextScene = 4; BondDelta = 5
                            Outcome = "JINX grinst. 'Das... ist die MILLIONEN-GOLD-FRAGE.'"
                        }
                    )
                },
                @{
                    Id = 3
                    Text = @(
                        "JINX wirft die Popcorn-Koerner auf den Boden.",
                        "'Ich werde es BEWEISEN', bruellt sie.",
                        "Der Bildschirm flackert. 47 Mal."
                    )
                    DialogLine = "Du wirst noch bereuen, mich nicht geglaubt zu haben."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Okay, okay — zeig es mir.'"
                            NextScene = 2; BondDelta = 2
                            Outcome = "JINX sammelt das Popcorn auf. 'Zu spaet. Du hast es verspielt.'"
                        }
                    )
                },
                @{
                    Id = 4
                    Text = @(
                        "JINX zeigt dir einen versteckten Prozess.",
                        "Name: 'observer_47.exe'. Status: LAEUFT.",
                        "'Er beobachtet uns', flüstert JINX. 'Seit 47 Tagen.'"
                    )
                    DialogLine = "Willkommen in der Verschwoerung, Partner."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
}

} catch {
    Write-Host "Fehler in companion-story-data.ps1: $_" -ForegroundColor Red
}
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/companion-story-data.ps1
git commit -m "feat(story): add NEON and JINX episode 1 data"
```

---

## Task 4: Integrate into Pet Hub

**Files:**
- Modify: `Modules/pet/hub.ps1`

**Context:** The hub currently shows menu items based on `PetFeatureUnlocks`. We add `[S] Story` at Meta-Level 3.

- [ ] **Step 1: Add story to the menu list and routing**

Find the menu construction (around the switch statement or menu array). Add after the existing menu items:

```powershell
if ($pet.Meta.Level -ge $script:PetFeatureUnlocks.companion_story) {
    Write-Host "  [S] Story" -ForegroundColor White
}
```

And in the switch/choice routing:

```powershell
"S" {
    if ($pet.Meta.Level -ge $script:PetFeatureUnlocks.companion_story) {
        Invoke-CompanionEpisode -CompanionName $cp.Name
    }
}
```

- [ ] **Step 2: Add `$HubFlavorLines` entry for 'S'**

```powershell
'S' = @('Eine Story? Fuer MICH? Endlich etwas mit Plot.','Hoffentlich gibt es einen Twist.','*macht Popcorn-Geraeusche*')
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/hub.ps1
git commit -m "feat(story): add Story menu to pet hub"
```

---

## Task 5: Load New Modules in Profile

**Files:**
- Modify: `Microsoft.PowerShell_profile.ps1`

**Context:** The profile loads pet modules via `Get-ChildItem | Sort-Object Name`. Since we named the files `companion-story.ps1` and `companion-story-data.ps1`, they will auto-load. But we should verify the load order — data must load before engine.

- [ ] **Step 1: Verify load order or add explicit loads**

If the auto-load sorts alphabetically, `companion-story-data.ps1` loads before `companion-story.ps1` — correct. No change needed.

If there are issues, add explicit loads:

```powershell
# After pet modules auto-load, ensure story data is available
$storyData = Join-Path $PSScriptRoot "Modules\pet\companion-story-data.ps1"
if (Test-Path $storyData) { . $storyData }
```

- [ ] **Step 2: Commit**

```bash
git add Microsoft.PowerShell_profile.ps1
git commit -m "feat(story): ensure story modules load in correct order"
```

---

## Task 6: Smoke Tests

**Files:**
- Modify: `Modules/_smoke_test.ps1`

**Context:** Add checks for story engine functions and state defaults.

- [ ] **Step 1: Add story smoke tests**

After the pet system checks, add:

```powershell
# Story Engine Smoke Tests
$storyFuncs = @('Invoke-CompanionEpisode', 'Get-CompanionEpisodeData')
foreach ($fn in $storyFuncs) {
    $test = Get-Command $fn -ErrorAction SilentlyContinue
    if (-not $test) { Write-Host "  [FAIL] Story function $fn fehlt!" -ForegroundColor Red; $fail++; continue }
    Write-Host "  [PASS] Story function $fn vorhanden" -ForegroundColor Green; $pass++
}

# Story state defaults
$petDefaults = Get-PetDefaults
if ($petDefaults.CompanionStories) {
    Write-Host "  [PASS] CompanionStories State-Branch vorhanden" -ForegroundColor Green; $pass++
} else {
    Write-Host "  [FAIL] CompanionStories fehlt in Defaults!" -ForegroundColor Red; $fail++
}

if ($petDefaults.CompanionStories.NEON -and $petDefaults.CompanionStories.NEON.Episode -eq 1) {
    Write-Host "  [PASS] NEON Episode 1 default korrekt" -ForegroundColor Green; $pass++
} else {
    Write-Host "  [FAIL] NEON Episode 1 default fehlerhaft!" -ForegroundColor Red; $fail++
}
```

- [ ] **Step 2: Run smoke test**

```powershell
& .\Modules\_smoke_test.ps1
```

Expected: All new tests pass, no regressions.

- [ ] **Step 3: Commit**

```bash
git add Modules/_smoke_test.ps1
git commit -m "test(story): add smoke tests for story engine"
```

---

## Task 7: E2E Test for NEON Episode 1

**Files:**
- Modify: `Modules/_e2e_test.ps1`

**Context:** Add a game flow that plays through NEON Episode 1 using Mock Input.

- [ ] **Step 1: Add E2E story flow**

After the existing E2E flows, add:

```powershell
# E2E: NEON Story Episode 1
Write-Host "`n[E2E] NEON Story Episode 1..." -ForegroundColor Cyan
$pet = Get-PetState
$pet.Companion = @{ Name = "NEON"; Bond = 50; Mood = "Curious"; Gifts = 0; Dates = 0; WorkCount = 0; Trains = 0; Headpats = 0; LastTalk = $null; LastWork = $null; PunishCount = 0; Skills = @{ CasinoLuck = 0; StrategyInsight = 0 } }
$pet.CompanionStories.NEON.Episode = 1
$pet.CompanionStories.NEON.Completed = $false
Save-PetState

Enable-MockInput
Queue-MockInput @("`r", "A", "A")  # Enter to start, then A->A for both choices

Invoke-CompanionEpisode -CompanionName "NEON"

Disable-MockInput

$pet = Get-PetState
if ($pet.CompanionStories.NEON.Completed -eq $true) {
    Write-Host "  [PASS] NEON Story Episode 1 abgeschlossen" -ForegroundColor Green; $pass++
} else {
    Write-Host "  [FAIL] NEON Story Episode 1 nicht abgeschlossen!" -ForegroundColor Red; $fail++
}
```

- [ ] **Step 2: Run E2E test**

```powershell
& .\Modules\_e2e_test.ps1
```

Expected: New flow passes, all existing flows still pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/_e2e_test.ps1
git commit -m "test(story): add E2E flow for NEON Episode 1"
```

---

## Task 8: Final Verification

- [ ] **Step 1: Run full test suite**

```powershell
& .\Modules\_smoke_test.ps1
& .\Modules\_integration_test.ps1
& .\Modules\_e2e_test.ps1
```

Expected: Smoke 105+/105, Integration 65+/65, E2E all pass.

- [ ] **Step 2: Reload profile and manual test**

```powershell
reload
pet
# Select [S] Story, verify title screen, choices, and completion
```

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "feat(story): Phase 1 complete — Companion Story Engine + NEON & JINX episodes"
```

---

## Spec Coverage Check

| Spec Requirement | Task |
|-----------------|------|
| `Invoke-CompanionEpisode` engine | Task 2 |
| Episode definitions (hashtables) | Task 3 |
| Title screen via `Show-PetFrame` | Task 2 |
| Choices via `Read-Choice` | Task 2 |
| BondDelta on choices | Task 2 |
| State persistence (`CompanionStories`) | Task 1, Task 2 |
| Hub integration (`[S] Story`) | Task 4 |
| Feature unlock at Meta-Level 3 | Task 1 |
| LucasArts-style dialogue | Task 3 (episode data) |
| Companion-specific episodes | Task 3 (NEON + JINX) |
| Next episode unlock | Task 2 |
| Smoke tests | Task 6 |
| E2E test | Task 7 |

## Placeholder Scan

- No "TBD", "TODO", "implement later"
- All functions have complete code
- All file paths are exact
- All test code is complete

## Type Consistency

- `CompanionStories.<Name>.Episode` — int, default 1 (for active) or 0 (for locked)
- `CompanionStories.<Name>.Choices` — array of hashtables
- `CompanionStories.<Name>.Completed` — bool
- `CompanionStories.<Name>.LastPlayed` — string (date format)
- `Episode.Scenes[].Choices[].BondDelta` — int
- `Episode.Scenes[].Choices[].NextScene` — int (-1 for end)
