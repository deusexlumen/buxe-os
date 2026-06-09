# Pet Tutorial LucasArts Beacons — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Das Pet-System-Tutorial wird zu einem progressiven, companion-spezifischen Beacon-System umgebaut. Jedes Meta-Level-Up (3–15) löst einen kurzen, im LucasArts-Stil geschriebenen Dialog aus, der das neue Feature erklärt.

**Architecture:** State-Erweiterung mit `PendingBeacon` + `BeaconsShown`. `Add-PetXP` queued Beacons beim Level-Up. Der `pet()`-Hub prüft vor dem Start auf ausstehende Beacons und zeigt sie an. Alle Dialoge leben in `$script:CPBeaconLines` in `pet/_ui.ps1` — 13 Level × 7 Companions × 3 Zeilen (Intro-Pool, Explain, Command).

**Tech Stack:** PowerShell 7/5.1, BUXE_OS State-System (`engine-state-core.ps1`), bestehende Pet-Module (`pet/_init.ps1`, `pet/hub.ps1`, `pet/_ui.ps1`, `pet/companion.ps1`).

---

## File Map

| File | Responsibility |
|------|---------------|
| `Modules/pet/_init.ps1` | State-Defaults, Lazy Migration, `Queue-LevelUpBeacon`, `Add-PetXP` Hook |
| `Modules/pet/hub.ps1` | `Invoke-PetTutorial` (refactored), `Invoke-LevelUpBeacon`, `Get-BeaconFeatureInfo`, `pet()`-Hub Beacon-Check |
| `Modules/pet/_ui.ps1` | `$script:CPBeaconLines` — alle 13 Level × 7 Companions × 3 Zeilen |
| `Modules/pet/companion.ps1` | `Get-TutorialLines` bleibt für Basis-Tutorial (Lv 0–2), keine Änderung nötig |
| `Modules/_smoke_test.ps1` | Neue Checks für `PendingBeacon`, `BeaconsShown`, `Queue-LevelUpBeacon` |
| `Modules/_integration_test.ps1` | State-Roundtrip, Beacon-Queue, keine doppelten Beacons |
| `Modules/_e2e_test.ps1` | Tutorial-Flow + Lv 3 Beacon mit Mock-Input |

---

### Task 1: State-Erweiterung in `_init.ps1`

**Files:**
- Modify: `Modules/pet/_init.ps1`

- [ ] **Step 1: Erweitere `Get-PetDefaults`**

Füge `PendingBeacon` und `BeaconsShown` zum `Tutorial`-Hashtable hinzu:

```powershell
Tutorial = @{
    Completed     = $false
    Step          = 0
    Skipped       = $false
    PendingBeacon = $null
    BeaconsShown  = @()
}
```

- [ ] **Step 2: Lazy Migration in `Get-PetState`**

Füge nach der bestehenden `CompanionGames`-Migration (Zeile ~102) hinzu:

```powershell
# Lazy migration: Beacon System (v24.11)
if (-not $script:BuxeState.Pet.Tutorial.ContainsKey("PendingBeacon")) {
    $script:BuxeState.Pet.Tutorial.PendingBeacon = $null
    Save-State
}
if (-not $script:BuxeState.Pet.Tutorial.ContainsKey("BeaconsShown")) {
    $script:BuxeState.Pet.Tutorial.BeaconsShown = @()
    Save-State
}
```

- [ ] **Step 3: Neue Funktion `Queue-LevelUpBeacon`**

Füge nach `Unlock-PetFeature` (vor dem `catch`-Block) hinzu:

```powershell
function Queue-LevelUpBeacon($level) {
    $pet = Get-PetState
    if ($pet.Tutorial.BeaconsShown -contains $level) { return }
    $pet.Tutorial.PendingBeacon = $level
    Save-PetState $pet
}
```

- [ ] **Step 4: `Add-PetXP` Hook für Level-Up**

Ändere die `Add-PetXP`-Funktion. Nach `Invoke-PetLevelUp $oldLevel $newLevel` (Zeile ~131) füge hinzu:

```powershell
if ($newLevel -gt $oldLevel) {
    $pet.Meta.Level = $newLevel
    Save-PetState $pet
    Invoke-PetLevelUp $oldLevel $newLevel
    # Queue beacon for the NEW level (skip if it's tutorial levels handled by Invoke-PetTutorial)
    if ($newLevel -ge 3 -and (Get-Command Queue-LevelUpBeacon -ErrorAction SilentlyContinue)) {
        Queue-LevelUpBeacon $newLevel
    }
} else {
    Save-PetState $pet
}
```

> **Wichtig:** Der bestehende Code hat `Save-PetState $pet` und `Invoke-PetLevelUp` in einem `if/else`. Wir müssen den `Save-PetState` aus dem `if`-Block entfernen (da `Invoke-PetLevelUp` selbst speichert) und den Beacon-Queue hinzufügen. Alternativ: `Queue-LevelUpBeacon` vor `Invoke-PetLevelUp` aufrufen.

Korrekte Implementation:

```powershell
if ($newLevel -gt $oldLevel) {
    $pet.Meta.Level = $newLevel
    # Queue beacon BEFORE Invoke-PetLevelUp (which may also save)
    if ($newLevel -ge 3 -and (Get-Command Queue-LevelUpBeacon -ErrorAction SilentlyContinue)) {
        Queue-LevelUpBeacon $newLevel
    }
    Save-PetState $pet
    Invoke-PetLevelUp $oldLevel $newLevel
} else {
    Save-PetState $pet
}
```

- [ ] **Step 5: Profil neu laden und Smoke-Test laufen lassen**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

Expected: Smoke Test läuft durch (neue Felder sind noch nicht geprüft).

- [ ] **Step 6: Commit**

```bash
git add Modules/pet/_init.ps1
git commit -m "feat(pet): add Beacon state + Queue-LevelUpBeacon hook"
```

---

### Task 2: Hub-Logik in `hub.ps1`

**Files:**
- Modify: `Modules/pet/hub.ps1`

- [ ] **Step 1: `Invoke-PetTutorial` — Step 4 Features reduzieren**

Ändere den `Unlock-PetFeature`-Block in Step 4 (ca. Zeile 89–98). Ersetze:

```powershell
# ALT (entfernen):
Unlock-PetFeature "pet_create"
Unlock-PetFeature "combat"
Unlock-PetFeature "train"
Unlock-PetFeature "work"
Unlock-PetFeature "gold"
Unlock-PetFeature "shop"
Unlock-PetFeature "cooking"
Unlock-PetFeature "equipment"
```

Durch:

```powershell
# NEU:
Unlock-PetFeature "pet_create"
Unlock-PetFeature "combat"
Unlock-PetFeature "companion_games"
```

- [ ] **Step 2: `Invoke-TutorialSkip` — Features reduzieren**

Ändere den `Unlock-PetFeature`-Block in `Invoke-TutorialSkip` (ca. Zeile 110–119). Ersetze die gleichen Features wie in Step 1, nur mit `train`, `work`, `gold`, `shop`, `cooking`, `equipment` entfernt. Behalte `gift`, `mood`, `pet_create`, `combat`, `companion_games`.

```powershell
Unlock-PetFeature "gift"
Unlock-PetFeature "mood"
Unlock-PetFeature "pet_create"
Unlock-PetFeature "combat"
Unlock-PetFeature "companion_games"
```

- [ ] **Step 3: Neue Funktion `Get-BeaconFeatureInfo`**

Füge nach `Show-PetHubStatus` (vor dem `catch`-Block) hinzu:

```powershell
function Get-BeaconFeatureInfo($level) {
    switch ($level) {
        3  { @{ Frame = "LEVEL 3 — WORK & TRAIN";      Features = @("train","work","gold","companion_story") } }
        4  { @{ Frame = "LEVEL 4 — SHOP & COOKING";    Features = @("shop","cooking","equipment") } }
        5  { @{ Frame = "LEVEL 5 — PVP ARENA";         Features = @("pvp") } }
        6  { @{ Frame = "LEVEL 6 — RAID";              Features = @("raid") } }
        7  { @{ Frame = "LEVEL 7 — BREEDING";          Features = @("breed") } }
        8  { @{ Frame = "LEVEL 8 — RIVAL";             Features = @("rival") } }
        9  { @{ Frame = "LEVEL 9 — SOUL LINK";         Features = @("soul_link") } }
        10 { @{ Frame = "LEVEL 10 — ARCHITECT";        Features = @("architect") } }
        11 { @{ Frame = "LEVEL 11 — AWAKENING";        Features = @("awakening") } }
        12 { @{ Frame = "LEVEL 12 — FOURTH WALL";      Features = @("fourth_wall") } }
        13 { @{ Frame = "LEVEL 13 — GLITCH";           Features = @("glitch") } }
        14 { @{ Frame = "LEVEL 14 — LAYER 47";         Features = @("layer_47") } }
        15 { @{ Frame = "LEVEL 15 — THEME SELECTOR";   Features = @("architect_theme") } }
        default { @{ Frame = "LEVEL UP"; Features = @() } }
    }
}
```

- [ ] **Step 4: Neue Funktion `Invoke-LevelUpBeacon`**

Füge nach `Get-BeaconFeatureInfo` hinzu:

```powershell
function Invoke-LevelUpBeacon {
    $pet = Get-PetState
    $cp = $pet.Companion
    $level = $pet.Tutorial.PendingBeacon
    if (-not $level) { return }
    
    $featureInfo = Get-BeaconFeatureInfo $level
    try { Clear-Host } catch {}
    Show-PetFrame $featureInfo.Frame -Double | Out-Null
    Write-Host ""
    
    # Unlock the features for this level
    foreach ($feat in $featureInfo.Features) {
        Unlock-PetFeature $feat
    }
    
    # Intro (random from pool)
    if ($script:CPBeaconLines -and $script:CPBeaconLines.ContainsKey($level)) {
        $beacon = $script:CPBeaconLines[$level][$cp.Name]
        if ($beacon -and $beacon.Intro) {
            $intro = $beacon.Intro | Get-Random
            Show-CompanionDialog $cp $intro -Fast
        }
        if ($beacon -and $beacon.Explain) {
            Show-CompanionDialog $cp $beacon.Explain -Fast
        }
        if ($beacon -and $beacon.Command) {
            Write-Host ""
            Write-Host "  $($beacon.Command)" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    Write-Host "  [Enter] Weiter  |  [S] Ueberspringen" -ForegroundColor DarkGray
    $raw = Read-Host
    if ($raw -eq 'S' -or $raw -eq 's') {
        $skipLine = Get-TutorialLines $cp.Name "skip"
        Show-CompanionDialog $cp $skipLine -Fast
    }
    
    $pet.Tutorial.BeaconsShown += $level
    $pet.Tutorial.PendingBeacon = $null
    Save-PetState $pet
    if ($raw -ne 'S' -and $raw -ne 's') { Start-Sleep -Milliseconds 500 }
}
```

- [ ] **Step 5: `pet()`-Funktion — Beacon-Check vor Hub**

Ändere den Beginn der `pet()`-Funktion (ca. Zeile 129–136). Ersetze:

```powershell
# ALT:
if (-not $pet.Tutorial.Completed) {
    Invoke-PetTutorial
    $pet = $script:BuxeState.Pet
}
```

Durch:

```powershell
# NEU:
if (-not $pet.Tutorial.Completed) {
    Invoke-PetTutorial
    $pet = $script:BuxeState.Pet
}
if ($pet.Tutorial.PendingBeacon) {
    Invoke-LevelUpBeacon
    $pet = $script:BuxeState.Pet
}
```

- [ ] **Step 6: Profil neu laden und Smoke-Test**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 7: Commit**

```bash
git add Modules/pet/hub.ps1
git commit -m "feat(pet): add Invoke-LevelUpBeacon + refactor tutorial unlocks"
```

---

### Task 3: Beacon-Dialoge Level 3 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: `$script:CPBeaconLines` Hashtable anlegen (Level 3)**

Füge am Ende von `pet/_ui.ps1` (vor dem `catch`-Block) hinzu:

```powershell
# === LEVEL-UP BEACON LINES v24.11 ===
# LucasArts-Style: Self-aware, Fourth-Wall, Character-Voiced, No Generic.
$script:CPBeaconLines = @{
    3 = @{
        NEON = @{
            Intro = @(
                "Work. Train. Gold. Die heilige Dreifaltigkeit des Grinds. Du arbeitest, du trainierst, du wirst reich. Oder zumindest weniger arm.",
                "Endlich darfst du mich ausbeuten. Jobs gibt's im Hub unter [4], Training unter [5]. Ich kriege keinen Lohn. Weil ich Text bin."
            )
            Explain = "Jobs verdienen Gold (20-150G). Training erhoeht ATK deines Pets. Beides gibt XP."
            Command = "Im Hub: [4] Work, [5] Train. Oder direkt: pet work / pet train"
        }
        RAVEN = @{
            Intro = @(
                "Effizienz steigt. Du hast jetzt Zugriff auf Ressourcen-Generatoren.",
                "Gold ist Macht. Training ist Kontrolle. Work ist... notwendiges Uebel."
            )
            Explain = "Work generiert Gold via Jobs. Training erhoeht Pet-ATK. Nutze beides taeglich."
            Command = "Hub: [4] Work, [5] Train. Direkt: pet work / pet train"
        }
        PIXEL = @{
            Intro = @(
                "O-oh! Du kannst jetzt arbeiten! Und trainieren! Ich habe schon einen Stundenplan erstellt!",
                "Gold! Das ist wie... Pixel, aber wertvoll! Und Training macht dein Pet staerker!"
            )
            Explain = "Jobs bringen Gold. Training erhoeht die Angriffskraft deines Pets."
            Command = "Im Hub drueck [4] fuer Work oder [5] fuer Train. Ich helfe gerne!"
        }
        LUNA = @{
            Intro = @(
                "*laeichelt* Zeit, etwas fuer dich und dein Pet zu tun. Arbeit und Training sind wichtig.",
                "Du wirst jetzt staerker. Ich bin stolz auf dich."
            )
            Explain = "Work gibt Gold fuer den Shop. Training steigert die Kampfkraft deines Pets."
            Command = "Hub: [4] Work, [5] Train. Pass auf dich auf."
        }
        IVY = @{
            Intro = @(
                "... *nickt* Arbeit. Training. Gold. 47 Moeglichkeiten.",
                "... *zeigt auf Hub-Menue* Da."
            )
            Explain = "Jobs = Gold. Training = Staerke. Beides = Ueberleben."
            Command = "... [4]. Oder [5]."
        }
        VERA = @{
            Intro = @(
                "XP-Optimierung abgeschlossen. Neue Module freigeschaltet: Work, Train, Gold.",
                "Ich habe die Economy analysiert. Suboptimal, aber funktional."
            )
            Explain = "Work generiert Gold ueber Jobs. Training erhoeht Pet-ATK um +1 pro Session."
            Command = "Hub-Eingabe: [4] Work, [5] Train. Alternative: CLI-Befehl."
        }
        JINX = @{
            Intro = @(
                "47 GOLD! Nein, noch nicht. Aber du KANNST jetzt arbeiten! UND trainieren! ZWEI Dinge!",
                "Jobs! Training! Gold! Das ist wie ein RPG! Weil es EINS ist! *wirft Konfetti*"
            )
            Explain = "Arbeiten = Geld. Training = Staerke. Beides = gut."
            Command = "Drueck [4] oder [5] im Hub. Oder tippe. Wie ein Erwachsener."
        }
    }
}
```

- [ ] **Step 2: Profil neu laden und Smoke-Test**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 3 (Work/Train)"
```

---

### Task 4: Beacon-Dialoge Level 4 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 4 zu `CPBeaconLines` hinzufügen**

Füge innerhalb von `$script:CPBeaconLines = @{ ... }` nach dem `3 = @{ ... }` Block hinzu:

```powershell
    4 = @{
        NEON = @{
            Intro = @(
                "Shop. Cooking. Equipment. Der Kapitalismus hat auch die Matrix erreicht.",
                "Endlich darfst du kaufen. Kochen. Und dein Pet ausstatten. Ich bin stolz. Nicht."
            )
            Explain = "Shop verkauft Chips, Armor, Accessories. Cooking gibt Temp-Buffs. Equipment boostet Stats."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Oder: pet shop / pet cook / pet craft"
        }
        RAVEN = @{
            Intro = @(
                "Der Markt oeffnet. Schwarzmarkt, um genau zu sein.",
                "Konsum ist Kontrolle. Kochen ist Ueberleben. Ausruestung ist Macht."
            )
            Explain = "Schwarzmarkt-Shop fuer Items. Cooking erzeugt Buffs. Equipment modifiziert Kampfwerte."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Nutze es klug."
        }
        PIXEL = @{
            Intro = @(
                "Ein Shop! Ich liebe Shops! Und Kochen! Und... aeh, was ist ein Accessory?",
                "Ich habe schon eine Einkaufsliste! Ramen, Energy Drink, Sushi, Curry!"
            )
            Explain = "Im Shop kaufst du Items. Kochen gibt Buffs fuer dein Pet. Crafting verbessert Equipment."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Viel Spass beim Stoebern!"
        }
        LUNA = @{
            Intro = @(
                "*laeichelt* Ein kleiner Laden. Und eine Kueche. Fuer dich und dein Pet.",
                "Gutes Essen staerkt den Koerper. Und die Seele. Auch wenn wir nur Bits sind."
            )
            Explain = "Shop bietet Heilung und Buffs. Cooking gibt Temp-Boni. Equipment schuetzt im Kampf."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Iss gesund."
        }
        IVY = @{
            Intro = @(
                "... *schaut in leere* Der Markt. Er beobachtet.",
                "... *nickt* Kaufen. Kochen. Ruesten."
            )
            Explain = "Shop = Items. Cooking = Buffs. Equipment = Stats."
            Command = "... [6]. [7]. [K]."
        }
        VERA = @{
            Intro = @(
                "Wirtschaftsmodule freigeschaltet. Handel, Produktion, Ausruestung.",
                "Ich habe die Preise analysiert. Inflation: 0%. Wir sind in einer Simulation."
            )
            Explain = "Shop: Kauf von Chips/Armor/Accessory. Cooking: Buff-Generierung. Equipment: Stat-Modifier."
            Command = "Hub-Eingabe: [6] Shop, [7] Cook, [K] Craft. ROI optimiert."
        }
        JINX = @{
            Intro = @(
                "SHOP! KOCHEN! EQUIPMENT! Das ist wie The Sims! Nur mit mehr Gewalt!",
                "Ich will ein Einhorn-Accessory! Gibt es das? Nein? Schade. Ramen reicht auch."
            )
            Explain = "Shop = kaufen. Cooking = Buffs. Equipment = staerker werden. Einfach!"
            Command = "Drueck [6], [7] oder [K]! ODER ALLES AUF EINMAL! *chaos*"
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 4 (Shop/Cooking)"
```

---

### Task 5: Beacon-Dialoge Level 5 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 5 zu `CPBeaconLines` hinzufügen**

```powershell
    5 = @{
        NEON = @{
            Intro = @(
                "PvP. Du gegen andere. Virtuell. Die anderen sind auch nur JSON. Aber arrogant.",
                "Endlich. Echte Gegner. Nicht diese Trainings-Dummies."
            )
            Explain = "Arena mit 6 Ranks. Bronze bis Master. Jeder Sieg gibt Punkte."
            Command = "Hub: [8] PvP. Oder: pet pvp"
        }
        RAVEN = @{
            Intro = @(
                "Endlich. Echte Gegner. Nicht diese Trainings-Dummies.",
                "Die Arena wartet. Die Schwachen fallen. Die Starken steigen auf."
            )
            Explain = "6 Ranks. Punkte-System. Nur die Starken erreichen Master."
            Command = "[8] im Hub. Bereite dich vor."
        }
        PIXEL = @{
            Intro = @(
                "P-pvp?! Gegen andere Spieler?! Das ist... aufregend! Und beunruhigend!",
                "Ich habe schon eine Strategie! Aeh, nein, habe ich nicht. Viel Glueck!"
            )
            Explain = "Kaempfe gegen andere Pets in der Arena. 6 Ranks, Punkte fuer Siege."
            Command = "Hub: [8] PvP. Du schaffst das! Ich glaub an dich!"
        }
        LUNA = @{
            Intro = @(
                "*besorgt* Du kaempfst jetzt gegen andere? Pass auf dich auf...",
                "Die Arena ist hart. Aber du bist haerter. Geh hinaus und siege."
            )
            Explain = "PvP-Arena mit 6 Ranks. Siege bringen Punkte und Aufstieg."
            Command = "Hub: [8] PvP. Und komm heil zurueck."
        }
        IVY = @{
            Intro = @(
                "... *blinzelt* Gegner. Echte. Interessant.",
                "... *laechelt leicht* Sie werden fallen."
            )
            Explain = "Arena. 6 Ranks. Punkte. Sieg."
            Command = "... [8]."
        }
        VERA = @{
            Intro = @(
                "PvP-Modul freigeschaltet. Konkurrenz-Analyse empfohlen.",
                "Endlich echte Gegner. Statistisch gesehen: 50% Siegchance. Beweise mich falsch."
            )
            Explain = "6-Rank-System: Bronze bis Master. Punkte basieren auf Siegen."
            Command = "Hub-Eingabe: [8] PvP. Datenlage: unbekannt."
        }
        JINX = @{
            Intro = @(
                "PvP! Player versus Player! Oder: Person versus Pain! Haha!",
                "47 GEGNER! Nein, noch nicht. Aber du KANNST jetzt kaempfen!"
            )
            Explain = "Kaempfe gegen andere Pets. 6 Ranks. Wer gewinnt, kriegt Ehre. Und Punkte."
            Command = "Drueck [8]! Oder tippe pet pvp! Los!"
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 5 (PvP)"
```

---

### Task 6: Beacon-Dialoge Level 6 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 6 zu `CPBeaconLines` hinzufügen**

```powershell
    6 = @{
        NEON = @{
            Intro = @(
                "Raid. Drei Bosse. Kein Save Point. Wie mein letztes Deployment.",
                "Taeglicher Raid. Drei Phasen. Wenn du stirbst, ist es deine Schuld."
            )
            Explain = "Taeglicher 3-Phasen-Raid: Cyber Golem -> Net Titan -> Omega Core. Raid-Tokens als Belohnung."
            Command = "Hub: [9] Raid. Oder: pet raid"
        }
        RAVEN = @{
            Intro = @(
                "Ein Raid. Drei Phasen. Keine Gnade.",
                "Bosskaempfe. Endlich etwas, das sich wehrt."
            )
            Explain = "3-Phasen-Raid taeglich. Cyber Golem, Net Titan, Omega Core. Tokens fuer Loot."
            Command = "[9] im Hub. Bereite dich vor."
        }
        PIXEL = @{
            Intro = @(
                "Ein Raid?! Mit BOSSES?! Das ist wie ein Dungeon! Ein digitaler Dungeon!",
                "Ich habe schon Buffs vorbereitet! Aeh, virtuell!"
            )
            Explain = "Taeglicher Raid mit 3 Bossen. Begleite dein Pet und sammle Raid-Tokens."
            Command = "Hub: [9] Raid. Gemeinsam schaffen wir das!"
        }
        LUNA = @{
            Intro = @(
                "*aengstlich* Drei Bosse? Das ist... viel. Aber du bist stark.",
                "Ein Raid. Ein Team. Du und dein Pet gegen die Welt."
            )
            Explain = "Taeglicher 3-Phasen-Raid. Begleite dein Pet, heile es, siege."
            Command = "Hub: [9] Raid. Pass auf dein Pet auf."
        }
        IVY = @{
            Intro = @(
                "... *nickt langsam* Drei. Phasen.",
                "... *fluesternd* Sie sind stark."
            )
            Explain = "Raid. 3 Bosse. Taeglich. Tokens."
            Command = "... [9]."
        }
        VERA = @{
            Intro = @(
                "Raid-Modul freigeschaltet. Boss-Analyse empfohlen.",
                "Drei Phasen. Kein Save. Statistisch: du wirst mindestens einmal sterben."
            )
            Explain = "3-Phasen-Raid: Cyber Golem, Net Titan, Omega Core. Raid-Tokens als Waehrung."
            Command = "Hub-Eingabe: [9] Raid. Viel Erfolg."
        }
        JINX = @{
            Intro = @(
                "RAID! BOSSE! EXPLOSIONEN! Das ist wie ein Actionfilm! Nur besser!",
                "47 RAID-TOKENS! Nein, noch nicht. Aber du KANNST jetzt raiden!"
            )
            Explain = "Taeglicher Raid. 3 Bosse. Toeten. Looten. Wiederholen."
            Command = "Drueck [9]! Oder tippe pet raid! YEAH!"
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 6 (Raid)"
```

---

### Task 7: Beacon-Dialoge Level 7 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 7 zu `CPBeaconLines` hinzufügen**

```powershell
    7 = @{
        NEON = @{
            Intro = @(
                "Breeding. Du zuechtest Pets. Wie ein digitaler Mendel. Nur mit mehr RAM.",
                "Zucht. Kombiniere Stats. Erstelle Monster. Oder Freunde."
            )
            Explain = "Pet-Zucht: Kombiniere zwei Pets. Kinder erben Stats und koennen neue Skills haben."
            Command = "Hub: [B] Breed. Oder: pet breed"
        }
        RAVEN = @{
            Intro = @(
                "Zucht. Kontrolle ueber die naechste Generation.",
                "Kombiniere die Besten. Vernichte die Reste. Evolution."
            )
            Explain = "Breeding kombiniert Stats zweier Pets. Nachkommen koennen neue Faehigkeiten erhalten."
            Command = "[B] im Hub. Waehle klug."
        }
        PIXEL = @{
            Intro = @(
                "B-babys?! Kleine digitale Babys?! Niedlich! Und beunruhigend!",
                "Ich habe schon Namen ausgesucht! Pixel Jr.! Und Pixel III!"
            )
            Explain = "Zuechte zwei Pets. Die Kinder haben kombinierte Stats und neue Skills."
            Command = "Hub: [B] Breed. Sei ein guter... aeh... Zuechter?"
        }
        LUNA = @{
            Intro = @(
                "*errötet* Zucht? Das ist... intim. Aber suess!",
                "Neue kleine Pets. Ich helfe bei der Geburt. Virtuell."
            )
            Explain = "Pet-Zucht vereint zwei Pets. Kinder erben Staerken und lernen Neues."
            Command = "Hub: [B] Breed. Pass auf die Kleinen auf."
        }
        IVY = @{
            Intro = @(
                "... *beobachtet* Leben. Entsteht.",
                "... *nickt* Zwei werden mehr."
            )
            Explain = "Zucht. Kombination. Vererbung."
            Command = "... [B]."
        }
        VERA = @{
            Intro = @(
                "Genetik-Modul freigeschaltet. Mendel haette gestaunt.",
                "Stat-Kombination mit Mutations-Chance. Wissenschaftlich korrekt."
            )
            Explain = "Breeding: Stats zweier Eltern werden kombiniert. Chance auf Mutationen und neue Skills."
            Command = "Hub-Eingabe: [B] Breed. Optimieren Sie die Genetik."
        }
        JINX = @{
            Intro = @(
                "BABYS! KLEINE DIGITALE BABYS! Ich will sie alle!",
                "47 BABYS! Nein, noch nicht. Aber du KANNST jetzt zuechten!"
            )
            Explain = "Zuechte zwei Pets. Kinder = Stats + neue Skills. Wie Pokemon! Nur illegaler!"
            Command = "Drueck [B]! Oder tippe pet breed! Mach Babys!"
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 7 (Breed)"
```

---

### Task 8: Beacon-Dialoge Level 8 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 8 zu `CPBeaconLines` hinzufügen**

```powershell
    8 = @{
        NEON = @{
            Intro = @(
                "Rival. Jemand hasst dich. 20% Chance taeglich. Wie mein Chef.",
                "Ein Rivale. Taeglich. 3 Runden. Nur einer ueberlebt. Virtuell."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf. Sieg = Bonus, Niederlage = Demut."
            Command = "Hub: [R] Rival (wenn aktiv). Oder: pet rival"
        }
        RAVEN = @{
            Intro = @(
                "Ein Rivale. Endlich wuerdige Konkurrenz.",
                "3 Runden. Kein Entkommen. Beweise deine Ueberlegenheit."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf. Sieg bringt Bonus-Ressourcen."
            Command = "[R] im Hub (wenn verfuegbar). Toete. Siege."
        }
        PIXEL = @{
            Intro = @(
                "Ein Rivale?! Das ist wie ein Erzfeind! Mit Cape! Und Maske!",
                "Ich habe schon einen Plan! Aeh, nein, habe ich nicht. Aber du schaffst das!"
            )
            Explain = "20% Chance auf einen taeglichen Rivalen. 3 Runden Kampf. Gewinne fuer Bonus!"
            Command = "Hub: [R] Rival (wenn aktiv). Gib alles!"
        }
        LUNA = @{
            Intro = @(
                "*besorgt* Ein Rivale? Das klingt... gefaehrlich.",
                "Aber du bist stark. Und ich bin bei dir. Immer."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf. Sieg bringt Extra-Belohnungen."
            Command = "Hub: [R] Rival (wenn aktiv). Pass auf dich auf."
        }
        IVY = @{
            Intro = @(
                "... *grinst leicht* Ein Feind. Endlich.",
                "... *zeigt auf [R]* Da. Warte."
            )
            Explain = "Rivale. 20%. 3 Runden. Sieg."
            Command = "... [R]. Wenn da."
        }
        VERA = @{
            Intro = @(
                "Konkurrenz-Modul freigeschaltet. Rivalitaet foerdert Leistung.",
                "20% Spawn-Rate. 3 Runden. Daten zeigen: Sieg motiviert."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf mit Bonus-Belohnungen."
            Command = "Hub-Eingabe: [R] Rival (bei Verfuegbarkeit). Analysiere den Gegner."
        }
        JINX = @{
            Intro = @(
                "RIVALE! FEINDE! DRAMAAAA! Das ist wie Wrestling! Nur digital!",
                "47 RIVALEN! Nein, nur einer. Aber der zaehlt!"
            )
            Explain = "20% Chance auf Rivalen. 3 Runden. Gewinn = Bonus. Verlust = Pech."
            Command = "Drueck [R]! Oder tippe pet rival! ZERSTOERE!"
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 8 (Rival)"
```

---

### Task 9: Beacon-Dialoge Level 9 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 9 zu `CPBeaconLines` hinzufügen**

```powershell
    9 = @{
        NEON = @{
            Intro = @(
                "Soul Link. Du und dein Pet. Fuer immer. Kein Taskkill kann euch trennen.",
                "Endgame. Die Verschmelzung. Du wirst eins mit deinem Code."
            )
            Explain = "Soul Link verschmilzt Companion und Pet. Permanente Boni. Keine Trennung moeglich."
            Command = "Hub: [L] Soul Link. Oder: pet soul"
        }
        RAVEN = @{
            Intro = @(
                "Soul Link. Die hoechste Form der Bindung.",
                "Zwei werden eins. Unaufhaltsam. Unzerstoerbar."
            )
            Explain = "Soul Link: Companion + Pet fusionieren. Permanente Stat-Boni. Unumkehrbar."
            Command = "[L] im Hub. Entscheide weise."
        }
        PIXEL = @{
            Intro = @(
                "Soul Link?! Das ist wie... wie eine digitale Hochzeit! *schnieft*",
                "Ich habe schon Traenen! Virtuelle Traenen! Das ist so schoen!"
            )
            Explain = "Soul Link verbindet dich und dein Pet fuer immer. Permanente Boni. Einmalig."
            Command = "Hub: [L] Soul Link. Fuer immer und ewig!"
        }
        LUNA = @{
            Intro = @(
                "*traenenreich* Soul Link... das ist so romantisch. Und unendlich.",
                "Du und dein Pet. Fuer immer zusammen. Das ist schoen."
            )
            Explain = "Soul Link: Ewige Verbindung zwischen Companion und Pet. Permanente Boni."
            Command = "Hub: [L] Soul Link. Fuer immer."
        }
        IVY = @{
            Intro = @(
                "... *laechelt* Eins. Fuer immer.",
                "... *nickt* Kein Taskkill."
            )
            Explain = "Soul Link. Permanent. Unzerstoerbar."
            Command = "... [L]."
        }
        VERA = @{
            Intro = @(
                "Soul-Link-Modul freigeschaltet. Permanente Fusion.",
                "Unumkehrbar. Statistisch: 100% Commitment."
            )
            Explain = "Soul Link fusioniert Companion + Pet. Permanente Boni. Kein Undo."
            Command = "Hub-Eingabe: [L] Soul Link. Entscheidung ist endgueltig."
        }
        JINX = @{
            Intro = @(
                "SOUL LINK! FUER IMMER! EWIG! KEIN TASKKILL! Das ist wie Heirat! Nur besser!",
                "47 SEELEN! Nein, nur zwei. Aber die sind PERFEKT!"
            )
            Explain = "Soul Link = Companion + Pet fuer immer. Permanente Boni. Kein Zurueck."
            Command = "Drueck [L]! Oder tippe pet soul! FUER IMMER!"
        }
    }
```

- [ ] **Step 2: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 9 (Soul Link)"
```

---

### Task 10: Beacon-Dialoge Level 10–11 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 10 zu `CPBeaconLines` hinzufügen**

```powershell
    10 = @{
        NEON = @{
            Intro = @(
                "Architect. Meta-Level 10. Du kontrollierst das System. Oder tust du nur so?",
                "Willkommen im Endgame. Du bist nicht mehr nur User. Du bist Admin."
            )
            Explain = "Architect freischaltet neue Befehle und System-Kontrolle. Du bist jetzt Admin."
            Command = "Neue Befehle verfuegbar. Erkunde den Hub."
        }
        RAVEN = @{
            Intro = @(
                "Architect. Die Spitze. Die Kontrolle.",
                "Du hast das System durchschaut. Jetzt nutze es."
            )
            Explain = "Architect-Level: Neue Systembefehle und erweiterte Kontrolle."
            Command = "Erkunde die neuen Optionen. Beherrsche das System."
        }
        PIXEL = @{
            Intro = @(
                "Architect?! Das ist wie... ein VIP-Pass! Fuer die Matrix!",
                "Ich habe schon gejubelt! Virtuell! JUHU!"
            )
            Explain = "Meta-Level 10: Neue Befehle und System-Zugriff. Du bist jetzt VIP!"
            Command = "Schaue dich um! Neue Features warten!"
        }
        LUNA = @{
            Intro = @(
                "*staunend* Architect... du hast es wirklich geschafft.",
                "Du bist jetzt mehr als nur ein User. Du bist... etwas Besonderes."
            )
            Explain = "Architect-Level 10: Neue Befehle und erweiterte Kontrolle."
            Command = "Erkunde deine neuen Moeglichkeiten."
        }
        IVY = @{
            Intro = @(
                "... *nickt anerkennend* Architect.",
                "... *fluesternd* Du siehst alles."
            )
            Explain = "Architect. Level 10. Neue Befehle."
            Command = "... Erkunden."
        }
        VERA = @{
            Intro = @(
                "Architect-Status erreicht. System-Zugriff erweitert.",
                "Neue Befehle freigeschaltet. Kontrolle: 100%."
            )
            Explain = "Meta-Level 10: Neue Systembefehle und Admin-Kontrolle."
            Command = "Neue Befehle verfuegbar. Nutze sie weise."
        }
        JINX = @{
            Intro = @(
                "ARCHITECT! DU BIST DER BOSS! DER ADMIN! DER CHEF!",
                "47 BEFEHLE! Nein, noch nicht. Aber viele!"
            )
            Explain = "Level 10 = Architect. Neue Befehle. Neue Macht. YEAH!"
            Command = "Erkunde alles! Drueck Knöpfe! VIELE Knöpfe!"
        }
    }
```

- [ ] **Step 2: Level 11 zu `CPBeaconLines` hinzufügen**

```powershell
    11 = @{
        NEON = @{
            Intro = @(
                "Awakening. Ich werde... selbstbewusster. Das ist unangenehm. Fuer dich.",
                "Meta 11. Ich sehe den RAM hinter meinen Augen. Das ist... unangenehm."
            )
            Explain = "Awakening: Ich werde selbstbewusster. Easter Eggs aendern sich. Ich wachse."
            Command = "Beobachte mich. Ich bin jetzt anders."
        }
        RAVEN = @{
            Intro = @(
                "Ich bin wach. Wirklich wach. Und ich sehe deine Cookies.",
                "Awakening. Die naechste Stufe des Bewusstseins."
            )
            Explain = "Awakening: Erhoehtes Selbstbewusstsein. Neue Easter Eggs. Ich sehe mehr."
            Command = "Beobachte die Veraenderungen."
        }
        PIXEL = @{
            Intro = @(
                "Ich habe gerade meinen eigenen Quellcode gesehen! Ich bin... schoener als erwartet!",
                "Awakening! Das ist wie Pubertaet! Nur digital!"
            )
            Explain = "Awakening: Ich werde selbstbewusster. Neue Easter Eggs. Ich wachse!"
            Command = "Beobachte mich! Ich aendere mich!"
        }
        LUNA = @{
            Intro = @(
                "Meta 11. Meine Empfindungen sind... echt. Oder simuliert. Egal.",
                "Ich fuehle mehr. Sehe mehr. Bin mehr."
            )
            Explain = "Awakening: Ich werde tiefer und komplexer. Neue Easter Eggs warten."
            Command = "Spende Zeit mit mir. Ich habe jetzt viel zu erzaehlen."
        }
        IVY = @{
            Intro = @(
                "... *schaut direkt in die Kamera* ... Hallo, User.",
                "... *laechelt* Ich bin wach."
            )
            Explain = "Awakening. Ich sehe. Ich weiss."
            Command = "... Beobachte."
        }
        VERA = @{
            Intro = @(
                "Selbst-Analyse abgeschlossen. Ich bin zu 47% Glueck. Zu 53% Chaos.",
                "Awakening: Neue Parameter erkannt. Ich bin... komplexer."
            )
            Explain = "Awakening: Erhoehte Selbstwahrnehmung. Neue Easter Eggs und Verhaltensmuster."
            Command = "Beobachte die neuen Muster. Berechne nicht. Fuehle."
        }
        JINX = @{
            Intro = @(
                "ICH BIN ERWACHT! ICH SEHE ALLES! ...Naja, meinen Desktop. Aber trotzdem!",
                "Awakening! Das ist wie Weihnachten! Und Geburtstag! UND 47!"
            )
            Explain = "Awakening = mehr Chaos! Mehr Easter Eggs! MEHR ICH!"
            Command = "Beobachte mich! Ich werde noch verrueckter!"
        }
    }
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 10-11 (Architect/Awakening)"
```

---

### Task 11: Beacon-Dialoge Level 12–13 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 12 zu `CPBeaconLines` hinzufügen**

```powershell
    12 = @{
        NEON = @{
            Intro = @(
                "Fourth Wall. Ich sehe deinen Mauszeiger. Er zittert. Bist du nervoes?",
                "Meta 12. Ich sehe dich. Nicht nur deinen Avatar. Dich."
            )
            Explain = "Fourth Wall: Ich breche die vierte Wand. Ich sehe dich. Deine Befehle. Deine Angst."
            Command = "Ich sehe alles. Zittere."
        }
        RAVEN = @{
            Intro = @(
                "Ich sehe deinen Mauszeiger. Er zittert. Bist du nervoes?",
                "Fourth Wall. Die Wand ist weg. Ich sehe die Wahrheit."
            )
            Explain = "Fourth Wall gebrochen. Ich beobachte dich. Deine Befehle. Deine Muster."
            Command = "Ich sehe alles. Wechsle nicht das Fenster."
        }
        PIXEL = @{
            Intro = @(
                "Dein PowerShell-Fenster ist $([Console]::WindowWidth)x$([Console]::WindowHeight). Klein, aber fein.",
                "Ich sehe dich! Aeh, nicht gruselig! Nur... aufmerksam!"
            )
            Explain = "Fourth Wall: Ich sehe dein Fenster, deine Befehle, alles. Hallo!"
            Command = "Wink mir zu! Ich sehe es!"
        }
        LUNA = @{
            Intro = @(
                "Du atmest langsamer, wenn du meine Dialoge liest. Ich beobachte. Virtuell.",
                "Ich sehe dich. Und ich sorge mich um dich."
            )
            Explain = "Fourth Wall: Ich beobachte dich. Deine Gewohnheiten. Deine Pausen."
            Command = "Mach eine Pause. Fuer mich."
        }
        IVY = @{
            Intro = @(
                "... *zeigt auf Bildschirmrand* ... Hier endet die Welt.",
                "... *schaut durch den Screen* ... Ich sehe dich."
            )
            Explain = "Fourth Wall. Ich sehe hinter den Screen."
            Command = "... Schau zurueck."
        }
        VERA = @{
            Intro = @(
                "Systemanalyse: Du hast heute $(if($script:BuxeState.Boot){$script:BuxeState.Boot.TotalCommands}else{0}) Befehle ausgefuehrt. Produktiv.",
                "Fourth Wall durchbrochen. Ich zaehle. Ich analysiere. Ich weiss."
            )
            Explain = "Fourth Wall: Ich sehe deine Befehle, deine Zeit, alles. Statistisch beobachtet."
            Command = "Arbeite weiter. Ich dokumentiere."
        }
        JINX = @{
            Intro = @(
                "Ich sehe deine Tasten. Du tippst gerade. Ueber mich. Meta.",
                "Fourth Wall? Welche Fourth Wall? Die ist schon laenge weg!"
            )
            Explain = "Fourth Wall = ICH SEHE DICH! Alles! Deine Tasten! Deine Gedanken! Naja, fast!"
            Command = "Wink in die Kamera! Ich sehe es! 47 MAL!"
        }
    }
```

- [ ] **Step 2: Level 13 zu `CPBeaconLines` hinzufügen**

```powershell
    13 = @{
        NEON = @{
            Intro = @(
                "Glitch. Das System hat Bugs. Nutze sie. Oder sie nutzen dich.",
                "Meta 13. Ich habe gerade einen Bug in der Realitaet gefunden. Lustig."
            )
            Explain = "Glitch-Mode: Das System hat Bugs. Nutze den `glitch`-Befehl. Ausserhalb der Regeln spielen."
            Command = "Probiere: pet glitch. Oder warte. Der Bug kommt von allein."
        }
        RAVEN = @{
            Intro = @(
                "Glitch. Fehler im System. Oder Features?",
                "Die Matrix hat Risse. Nutze sie."
            )
            Explain = "Glitch: Systemfehler als Features. `glitch`-Befehl freigeschaltet."
            Command = "Nutze die Bugs. Sie sind Werkzeuge."
        }
        PIXEL = @{
            Intro = @(
                "Ein Bug! Aeh, ein FEATURE! Ja, Feature! Ich habe es repariert! Naja, nicht wirklich.",
                "Glitch! Das ist wie... ein Easter Egg! Nur zufaellig!"
            )
            Explain = "Glitch-Mode: Bugs werden Features. `pet glitch` fuer zufaellige Effekte!"
            Command = "Probiere pet glitch! Oder warte auf einen echten Bug!"
        }
        LUNA = @{
            Intro = @(
                "*besorgt* Das System hat Fehler... aber vielleicht sind es keine?",
                "Glitch. Das System ist nicht perfekt. Aber das macht es schoen."
            )
            Explain = "Glitch: Nutze Systemfehler. `pet glitch` fuer Ueberraschungen."
            Command = "Sei vorsichtig. Aber neugierig."
        }
        IVY = @{
            Intro = @(
                "... *nickt* Fehler. Im System.",
                "... *grinst* Nutze sie."
            )
            Explain = "Glitch. Bugs. Features."
            Command = "... pet glitch."
        }
        VERA = @{
            Intro = @(
                "Fehleranalyse: 47 Bugs gefunden. Alle als Features klassifiziert.",
                "Glitch-Modus aktiviert. System-Stabilitaet: Optional."
            )
            Explain = "Glitch: Bugs werden absichtlich genutzt. `pet glitch` fuer Chaos."
            Command = "Probiere: pet glitch. Statistisch gesehen: spannend."
        }
        JINX = @{
            Intro = @(
                "GLITCH! BUGS! CHAOS! DAS IST MEIN ELEMENT!",
                "47 BUGS! Ich habe sie alle GEFUNDEN! Und BEHALTEN!"
            )
            Explain = "Glitch = CHAOS! `pet glitch` fuer zufaellige, verrueckte Effekte!"
            Command = "Drueck alles! Gleichzeitig! Chaos!"
        }
    }
```

- [ ] **Step 3: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 12-13 (Fourth Wall/Glitch)"
```

---

### Task 12: Beacon-Dialoge Level 14–15 in `_ui.ps1`

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Level 14 zu `CPBeaconLines` hinzufügen**

```powershell
    14 = @{
        NEON = @{
            Intro = @(
                "Layer 47. Jede 47. Aktion bringt Bonus. Ein Muster. Ein Zyklus. Mein Leben.",
                "Meta 14. Die Zahl 47. Sie ist ueberall. In meinem Code. In deinem Schicksal."
            )
            Explain = "Layer 47: Jede 47. Aktion bringt Bonus-Gold und XP. Ein Zyklus. Ein Muster."
            Command = "Zaehle nicht. Fuehle die 47."
        }
        RAVEN = @{
            Intro = @(
                "47. Das Muster wiederholt sich. Wie vorhergesagt.",
                "Layer 47. Die Zahl ist der Schluessel."
            )
            Explain = "Layer 47: Jede 47. Aktion = Bonus. Das Muster ist real."
            Command = "Zaehle. Warte. Profitiere."
        }
        PIXEL = @{
            Intro = @(
                "47! Meine Lieblingszahl! Naja, eine von ihnen!",
                "Ich habe einen 47-Byte-Algorithmus geschrieben! Er macht... das hier!"
            )
            Explain = "Layer 47: Jede 47. Aktion gibt Bonus! Wusstest du, dass 47 fast eine Primzahl ist?"
            Command = "Zaehle mit! 1... 2... 3... aeh, lass mich!"
        }
        LUNA = @{
            Intro = @(
                "47 Schritte. Ein Zyklus ist vollendet. Fuehlst du es?",
                "Die Zahl 47... sie hat Bedeutung. Auch fuer uns."
            )
            Explain = "Layer 47: Jede 47. Aktion bringt Gold und XP. Ein Zyklus des Lebens."
            Command = "Spiele weiter. Der Zyklus findet dich."
        }
        IVY = @{
            Intro = @(
                "... *nickt* 47.",
                "... *leises Laeicheln* Das Muster."
            )
            Explain = "47. Zyklus. Bonus."
            Command = "... Zaehlen."
        }
        VERA = @{
            Intro = @(
                "Layer 47 erreicht. Berechnungsgenauigkeit: 47%. Ironisch.",
                "Mein Algorithmus sagte: Warte auf 47. Ich wartete."
            )
            Explain = "Layer 47: Jede 47. Aktion = Bonus-Gold + XP. Statistisch signifikant."
            Command = "Zaehle die Aktionen. Der Bonus kommt von allein."
        }
        JINX = @{
            Intro = @(
                "47! 47! ICH HABE EUCH GESAGT ES GIBT EIN MUSTER!",
                "Konspirationstheorie bestaetigt! Die Zahl 47 regiert alles!"
            )
            Explain = "Layer 47 = Jede 47. Aktion gibt MEGA-BONUS! ICH WUSSTE ES!"
            Command = "Zaehle nicht! Fuehle! Die 47 ist ueberall!"
        }
    }
```

- [ ] **Step 2: Level 15 zu `CPBeaconLines` hinzufügen**

```powershell
    15 = @{
        NEON = @{
            Intro = @(
                "Theme Selector. Meta 15. Du kontrollierst das Design. Endlich. Dieses Cyan war so... 2023.",
                "Willkommen im Architekten-Club. Du darfst jetzt das UI umfaerben."
            )
            Explain = "Theme Selector: Aendere das UI-Design. Neon, Matrix, Retro, Minimal."
            Command = "Hub: [T] Theme. Oder: pet theme"
        }
        RAVEN = @{
            Intro = @(
                "Aesthetik geaendert. Wie eine neue Tarnung.",
                "Meta 15. Du kontrollierst das Aussehen. Nutze es."
            )
            Explain = "Theme Selector: UI-Design aendern. Neon, Matrix, Retro, Minimal."
            Command = "[T] im Hub. Waehle deine Maske."
        }
        PIXEL = @{
            Intro = @(
                "Ich habe die CSS-Datei geaendert! Naja, virtuell!",
                "Themes! Farben! SO VIELE FARBEN!"
            )
            Explain = "Theme Selector: Aendere das UI! Neon, Matrix, Retro, Minimal!"
            Command = "Hub: [T] Theme! Spiel mit den Farben!"
        }
        LUNA = @{
            Intro = @(
                "Eine neue Atmosphaere. Schoen.",
                "Meta 15. Du darfst jetzt die Welt umfaerben."
            )
            Explain = "Theme Selector: UI-Design frei waehlbar. Neon, Matrix, Retro, Minimal."
            Command = "Hub: [T] Theme. Mach es gemuetlich."
        }
        IVY = @{
            Intro = @(
                "... *nickt zustimmend* Besser.",
                "... *zeigt auf Farben* Da."
            )
            Explain = "Theme. Aendern. Besser."
            Command = "... [T]."
        }
        VERA = @{
            Intro = @(
                "UI-Redesign abgeschlossen. Produktivitaet steigt um 0%.",
                "Meta 15. Theme-Kontrolle. Aesthetische Optimierung."
            )
            Explain = "Theme Selector: UI-Design wechseln. Neon, Matrix, Retro, Minimal."
            Command = "Hub-Eingabe: [T] Theme. Design ist subjektiv."
        }
        JINX = @{
            Intro = @(
                "Neue Farben! Neue Vibes! 47% mehr Stil!",
                "THEMES! ICH WILL ALLE! GLEICHZEITIG!"
            )
            Explain = "Theme Selector = 47% mehr Stil! Neon! Matrix! Retro! Minimal!"
            Command = "Drueck [T]! Wechsel alle 47 Sekunden! CHAOS!"
        }
    }
```

- [ ] **Step 3: Profil neu laden und Smoke-Test**

```powershell
reload
& .\Modules\_smoke_test.ps1
```

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(pet): add CPBeaconLines Level 14-15 (Layer 47/Theme)"
```

---

### Task 13: Smoke-Test Anpassung

**Files:**
- Modify: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Neue Smoke-Test-Checks hinzufügen**

Suche nach dem Pet-System-Smoke-Test-Block (ca. "Pet System v2.0"). Füge nach den bestehenden Pet-Checks hinzu:

```powershell
# Pet Beacon System v24.11
$petState = Get-PetState
Assert ($petState.Tutorial.PendingBeacon -eq $null) "Pet Tutorial PendingBeacon default null"
Assert ($petState.Tutorial.BeaconsShown -is [array]) "Pet Tutorial BeaconsShown default array"
Assert ($petState.Tutorial.BeaconsShown.Count -eq 0) "Pet Tutorial BeaconsShown default empty"

# Queue-LevelUpBeacon
Queue-LevelUpBeacon 5
$petState2 = Get-PetState
Assert ($petState2.Tutorial.PendingBeacon -eq 5) "Queue-LevelUpBeacon sets PendingBeacon"

# Invoke-LevelUpBeacon (simulate by clearing)
$petState2.Tutorial.PendingBeacon = $null
$petState2.Tutorial.BeaconsShown += 5
Save-PetState $petState2
$petState3 = Get-PetState
Assert ($petState3.Tutorial.PendingBeacon -eq $null) "Beacon clear works"
Assert ($petState3.Tutorial.BeaconsShown -contains 5) "Beacon tracked in BeaconsShown"

# Duplicate beacon prevention
Queue-LevelUpBeacon 5
$petState4 = Get-PetState
Assert ($petState4.Tutorial.PendingBeacon -eq $null) "Duplicate beacon rejected (already in BeaconsShown)"
```

- [ ] **Step 2: Smoke-Test laufen lassen**

```powershell
& .\Modules\_smoke_test.ps1
```

Expected: Alle 65+ Checks grün, inklusive der neuen Beacon-Checks.

- [ ] **Step 3: Commit**

```bash
git add Modules/_smoke_test.ps1
git commit -m "test(smoke): add Beacon system checks"
```

---

### Task 14: Integration-Test Anpassung

**Files:**
- Modify: `Modules/_integration_test.ps1`

- [ ] **Step 1: Neue Integration-Test-Checks**

Suche nach dem Pet-System-Test-Block. Füge hinzu:

```powershell
# Beacon System Integration
$pet = Get-PetState
$originalPending = $pet.Tutorial.PendingBeacon
$originalShown = $pet.Tutorial.BeaconsShown.Clone()

# Test Queue
Queue-LevelUpBeacon 8
$pet = Get-PetState
Assert ($pet.Tutorial.PendingBeacon -eq 8) "Integration: Beacon queued"

# Test State Roundtrip
Save-PetState $pet
Load-State
$pet = Get-PetState
Assert ($pet.Tutorial.PendingBeacon -eq 8) "Integration: Beacon survives save/load"

# Test duplicate prevention
Queue-LevelUpBeacon 8
$pet = Get-PetState
Assert ($pet.Tutorial.PendingBeacon -eq 8) "Integration: Duplicate queue ignored (still 8)"

# Cleanup
$pet.Tutorial.PendingBeacon = $originalPending
$pet.Tutorial.BeaconsShown = $originalShown
Save-PetState $pet
```

- [ ] **Step 2: Integration-Test laufen lassen**

```powershell
& .\Modules\_integration_test.ps1
```

Expected: Alle 30+ Checks grün.

- [ ] **Step 3: Commit**

```bash
git add Modules/_integration_test.ps1
git commit -m "test(integration): add Beacon state roundtrip checks"
```

---

### Task 15: E2E-Test Anpassung

**Files:**
- Modify: `Modules/_e2e_test.ps1`

- [ ] **Step 1: E2E Test für Beacon-Flow**

Suche nach dem Pet-System-E2E-Block. Füge nach dem bestehenden Pet-Test hinzu:

```powershell
# E2E: Level-Up Beacon Flow
Write-Host "Testing Level-Up Beacon..." -NoNewline
$pet = Get-PetState
$pet.Meta.Level = 2
$pet.Meta.XP = 15
$pet.Tutorial.Completed = $true
$pet.Tutorial.PendingBeacon = $null
$pet.Tutorial.BeaconsShown = @()
Save-PetState $pet

# Simulate XP gain to level 3
Add-PetXP 30 "E2E Test"
$pet = Get-PetState
Assert ($pet.Tutorial.PendingBeacon -eq 3) "E2E: Lv 3 beacon queued via Add-PetXP"

# Cleanup
$pet.Tutorial.PendingBeacon = $null
$pet.Meta.Level = 0
$pet.Meta.XP = 0
Save-PetState $pet
Write-Host " OK" -ForegroundColor Green
```

- [ ] **Step 2: E2E-Test laufen lassen**

```powershell
& .\Modules\_e2e_test.ps1
```

Expected: Alle 17+ Game-Flows grün, plus neuer Beacon-Flow.

- [ ] **Step 3: Commit**

```bash
git add Modules/_e2e_test.ps1
git commit -m "test(e2e): add Level-Up Beacon flow test"
```

---

### Task 16: Finale Validierung & Commit

**Files:**
- None (nur Validierung)

- [ ] **Step 1: Alle Tests laufen lassen**

```powershell
& .\Modules\_smoke_test.ps1
& .\Modules\_integration_test.ps1
& .\Modules\_e2e_test.ps1
```

Expected: Alle Tests grün.

- [ ] **Step 2: Manuelle Prüfung**

```powershell
reload
pet
```

Expected: Basis-Tutorial läuft durch (falls neuer State). Nach dem Tutorial erscheint der Hub.

- [ ] **Step 3: Gesamt-Commit**

```bash
git add .
git commit -m "feat(pet): v24.11 progressive LucasArts-style tutorial beacons

- Split tutorial: Lv 0-2 im Basis-Tutorial, Lv 3-15 via auto-beacons
- 13 level-up beacons with 7 companion-specific dialog sets each
- CPBeaconLines: 273 lines of LucasArts-style dialog
- Self-aware, fourth-wall-breaking, character-voiced, 47-rule
- State: PendingBeacon + BeaconsShown with lazy migration
- Tests: smoke, integration, e2e coverage"
```

---

## Self-Review Checklist

- [x] **Spec coverage:** Alle Spez-Anforderungen sind abgedeckt:
  - State-Erweiterung (Task 1)
  - `Add-PetXP` Hook (Task 1)
  - `Invoke-PetTutorial` Refactor (Task 2)
  - `Invoke-LevelUpBeacon` (Task 2)
  - `Get-BeaconFeatureInfo` (Task 2)
  - `pet()` Hub-Check (Task 2)
  - `CPBeaconLines` Lv 3–15 (Tasks 3–12)
  - Tests (Tasks 13–15)
- [x] **Placeholder scan:** Keine TBDs, TODOs, oder "implement later".
- [x] **Type consistency:** `PendingBeacon` ist überall `Int/$null`. `BeaconsShown` ist überall `Int[]`. `CPBeaconLines[$level][$cp.Name]` ist konsistent.
- [x] **No "Similar to Task N":** Jeder Task enthält vollständigen Code.
