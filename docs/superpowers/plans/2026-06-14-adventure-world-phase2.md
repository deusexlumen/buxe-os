# Adventure LucasArts Overhaul — Phase 2: World Text

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Alle Schlüssel-Raum- und Objektbeschreibungen im Adventure durch LucasArts-konforme, selbstbewusste und humorvolle Texte ersetzen.

**Architecture:** Eine zentrale Nachschlage-Funktion `Get-AdventureWorldMessage` in `Modules/adventure-world.ps1` hält die neuen Welt-Texte. `Register-Room` und Objekt-Definitionen verwenden `(Get-AdventureWorldMessage "<key>")` statt hartkodierter Strings.

**Tech Stack:** PowerShell 7/5.1, BUXE_OS Adventure-Engine.

---

## File Structure

| Datei | Verantwortung |
|-------|---------------|
| `Modules/adventure-world.ps1` | `Get-AdventureWorldMessage`, `$script:AdventureWorldMessages`, alle `Register-Room`-Aufrufe, Objekt-Definitionen, Use-Handler, NPC-Dialoge |
| `Modules/adventure.ps1` | Intro- und Outro-Text des Adventure-Routers |
| `Modules/_smoke_test.ps1` | Optionaler Check, dass keine generischen Template-Beschreibungen mehr existieren |
| `Modules/_integration_test.ps1` | Keine String-Änderungen erwartet |

---

## Task 1: Zentrale Welt-Text-Tabelle einführen

**Files:**
- Modify: `Modules/adventure-world.ps1` (am Anfang der Datei, nach dem Header)

- [ ] **Step 1: Füge `$script:AdventureWorldMessages` und `Get-AdventureWorldMessage` ein**

Füge direkt nach der Versionszeile `# BUXE_OS v24.4 -- adventure-world` ein:

```powershell
$script:AdventureWorldMessages = @{
    # Router
    intro_title        = "BUXE_OS ADVENTURE v24.4"
    intro_subtitle     = "Ein Text-Abenteuer, das genau weiss, in welchem Terminal es läuft."
    intro_hint         = "Tipp 'help', wenn du vergisst, wer hier Programmierer ist."
    outro              = "Adventure beendet. Dein State wurde nicht gelöscht – das überlasse ich dir."

    # Rooms
    hangar_desc        = "Ein Hangar, der größer ist als nötig. Die Wände flüstern von Budget-Überschreitungen. Ein altes Shuttle steht herum und wartet auf einen Patch."
    hangar_exits       = "Ausgänge: Osten (Corridor). Mehr gibt das Leveldesign noch nicht her."
    corridor_desc      = "Ein langer, grauer Corridor. Neonlichter flackern im Takt eines schlechten Loops. Hier hätte das Art-Team mehr Budget gebraucht."
    bridge_desc        = "Die Brücke. Ein kapitalistischer Traum aus Stahl und kaputtem Glas. Ein Hologramm blinkt hilflos."
    eva_desc           = "Der EVA-Schacht. Draußen liegt der Weltraum, kalt und voller nicht-geladener Texturen. Ohne Anzug wirst du ein Bug-Report."
    core_desc          = "Der Reaktor-Core pulsiert. Die Kühlflüssigkeit riecht nach heissen Promises und einem Serverraum um 3 Uhr nachts."
    airlock_desc       = "Die Luftschleuse. Zwei Türen, ein rotes Blinklicht, und die Ahnung, dass das QA-Team diesen Raum nie getestet hat."
    engine_desc        = "Das Engine-Raum. Turbinen brummen wie ein schlecht gewarteter CI-Runner. Irgendwo tropft Öl auf das Kubernetes-Logo."
    medbay_desc        = "Die Medbay. Hier wurden Menschen geheilt, Experimente gemacht und mindestens einmal versehentlich der Produktivserver neu gestartet."
    armory_desc        = "Die Waffenkammer. Laser-Gewehre, Stun-Stäbe und ein Schild mit 'Bitte nicht auf den Prototypen schießen'."
    quarters_desc      = "Crew-Quarters. Betten, Spind, ein Poster von einem Katzen-Weltraumhelden. Niemand räumt hier auf."
    observatory_desc   = "Das Observatorium. Sterne, Planeten, und ein Teleskop, das ständig auf einen 404 im Himmel zeigt."
    cafeteria_desc     = "Die Cafeteria. Der Kaffee ist kalt, die Currywurst ist warm, und der Automat akzeptiert nur Bitcoin aus dem Jahr 2021."
    vent_desc          = "Ein Lüftungsschacht. Hier riecht es nach Staub, Schweiß und den Träumen des Leveldesigners. Eng, aber geheimnisvoll."
    secret_desc        = "Ein geheimer Raum. Wie du ihn gefunden hast, sagst du mir nicht? Gut. Das ist zwischen dir, mir und dem Debug-Log."
    lab_desc           = "Das Labor. Reagenzgläser, Monitore und ein Whiteboard voller Gleichungen, die jemand absichtlich unleserlich geschrieben hat."
    server_desc        = "Der Server-Raum. Lüfter rauschen, LEDs blinken, und irgendwo läuft ein Cronjob, den niemand mehr versteht."

    # Objects / examine
    terminal_examine   = "Ein Terminal mit einer Tastatur, die so alt ist, dass sie mechanisch klackt. Das Display zeigt 'login: root'. Jemand war faul."
    box_examine        = "Eine Metallkiste. Nicht verschlossen, nur resigniert. Sie seufzt, als wüsste sie, dass du sie gleich öffnest."
    notebook_examine   = "Ein Notizbuch. Die letzte Seite trägt die Aufschrift: 'Wenn du das liest, bist du zu weit gegangen. Gruss, Leveldesigner'."
    screen_examine     = "Ein Bildschirm mit Warnsymbolen. Er flackert, als würde er versuchen, dir auszuweichen."
    diary_examine      = "Ein Tagebuch. Captain Vance beschwert sich über die Crew, die KI und dass niemand den Drucker nachfüllt."
    computer_examine   = "Ein Computer. Der Desktop-Hintergrund ist ein Weltraumkätzchen. Die CPU-Auslastung: 47%. Natürlich."
    pedestal_examine   = "Ein Podest. Es fehlt ein Artefakt. Oder es ist nur unsichtbar. Mit Assets spart man ja gerne."
    warning_examine    = "Ein Warnschild: 'Nicht drücken'. Darunter, in Klammern: 'Ausser du willst den Plot vorantreiben'."
    cable_examine      = "Ein Kabel. Rot, dick, offensichtlich wichtig. Jemand hat es hier liegen gelassen wie einen Chekhov'schen Gewehr."
    rubber_chicken_examine = "Ein Gummihuhn. Ein klassisches Adventure-Item. Du fragst dich, wer es hier vergessen hat. Wahrscheinlich das QA-Team."
    skull_examine      = "Ein Plastikschädel. Er grinst. Nicht böse, eher so, als wüsste er über deinen Browser-Verlauf Bescheid."
    tree_examine       = "Ein Plastikbaum. Er steht in einem geheimen Raum und produziert Sauerstoff für genau niemanden. Dekorativer Sarkasmus."
    spacesuit_examine  = "Ein Raumanzug. Er riecht nach altem Schaumstoff und Helden. Mindestens ein Loch ist mit Tape geflickt."
    keycard_examine    = "Eine Keycard. Sie öffnet Türen, Herzen und vielleicht den Kühlschrank der Cafeteria."
    artifact_examine   = "Ein seltsames Artefakt. Es vibriert leicht und hört auf, wenn du hinsiehst. Typisch Undefined Behaviour."

    # Use / event texts
    bridge_unseal      = "Die Brücke entriegelt sich mit einem zufriedenen Klicken. Willkommen im Endgame – oder zumindest im nächsten Akt."
    core_unlock        = "Du steckst das Artefakt ins Podest. Der Core wird ruhiger, die Lichter werden grün, und irgendwo jubelt ein Achievement-Tracker."
    server_reboot      = "Du drückst den roten Knopf. Server fahren hoch, runter, dann wieder hoch. Systemadministratoren weinen Tränen der Freude."
    secret_tree_use    = "Du redest mit dem Plastikbaum. Er antwortet nicht. Ihr beide wisst, dass das normal ist."
    lab_computer_use   = "Du startest die Experiment-Simulation. Sie crasht sofort. 'Feature, not bug', flackert auf dem Bildschirm."
    vent_skull_use     = "Du hältst den Schädel ins Lüftungsgitter. Ein Windstoss lässt ihn klappern. Das klingt fast wie Applaus."
}

function Get-AdventureWorldMessage($Key, $Params = @()) {
    $msg = $script:AdventureWorldMessages[$Key]
    if (-not $msg) { return "" }
    if ($Params.Count -gt 0) { $msg = $msg -f $Params }
    return $msg
}
```

- [ ] **Step 2: Smoke-Test laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_smoke_test.ps1"`
Expected: 222/222 passed (no behavior change yet).

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-world.ps1
git commit -m "feat(adventure): add Get-AdventureWorldMessage lookup table"
```

---

## Task 2: Adventure-Router Intro/Outro umschreiben

**Files:**
- Modify: `Modules/adventure.ps1`

- [ ] **Step 1: Ersetze Intro-/Outro-Text**

**Old:**
```powershell
        Write-Host "=== BUXE_OS ADVENTURE ===" -ForegroundColor Cyan
        Write-Host "Ein text-basiertes Sci-Fi Adventure." -ForegroundColor Gray
        Write-Host "Tipp 'help' für Befehle. 'quit' beendet das Spiel.`n" -ForegroundColor Gray
```
**New:**
```powershell
        Write-Host (Get-AdventureWorldMessage "intro_title") -ForegroundColor Cyan
        Write-Host (Get-AdventureWorldMessage "intro_subtitle") -ForegroundColor Gray
        Write-Host "$(Get-AdventureWorldMessage "intro_hint") 'quit' beendet das Spiel.`n" -ForegroundColor Gray
```

**Old:**
```powershell
        Write-Host "`nAdventure beendet." -ForegroundColor Cyan
```
**New:**
```powershell
        Write-Host "`n$(Get-AdventureWorldMessage "outro")" -ForegroundColor Cyan
```

- [ ] **Step 2: Smoke + E2E laufen lassen**

Run smoke and E2E. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure.ps1
git commit -m "feat(adventure): LucasArts-style intro/outro text"
```

---

## Task 3: Raumbeschreibungen zentralisieren (Teil 1)

**Files:**
- Modify: `Modules/adventure-world.ps1`

- [ ] **Step 1: Ersetze Description und Exits für hangar, corridor, bridge**

**Hangar:**
**Old:**
```powershell
        Description = "Ein grosser Hangar mit einem alten Shuttle in der Mitte."
        Exits       = @{ east = "corridor" }
```
**New:**
```powershell
        Description = (Get-AdventureWorldMessage "hangar_desc")
        Exits       = @{ east = "corridor" }
```

**Corridor:**
**Old:**
```powershell
        Description = "Ein langer, grauer Corridor. Neonlichter flackern an der Decke."
        Exits       = @{ west = "hangar"; north = "bridge"; east = "airlock"; south = "engine" }
```
**New:**
```powershell
        Description = (Get-AdventureWorldMessage "corridor_desc")
        Exits       = @{ west = "hangar"; north = "bridge"; east = "airlock"; south = "engine" }
```

**Bridge:**
**Old:**
```powershell
        Description = "Die Bruecke des Schiffs. Ein Hologramm flackert auf dem Kommandopult."
        Exits       = @{ south = "corridor"; east = "observatory" }
```
**New:**
```powershell
        Description = (Get-AdventureWorldMessage "bridge_desc")
        Exits       = @{ south = "corridor"; east = "observatory" }
```

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-world.ps1
git commit -m "feat(adventure): LucasArts-style descriptions for hangar, corridor, bridge"
```

---

## Task 4: Raumbeschreibungen zentralisieren (Teil 2)

**Files:**
- Modify: `Modules/adventure-world.ps1`

- [ ] **Step 1: Ersetze Description für eva, core, airlock, engine**

**EVA:**
```powershell
        Description = (Get-AdventureWorldMessage "eva_desc")
```

**Core:**
```powershell
        Description = (Get-AdventureWorldMessage "core_desc")
```

**Airlock:**
```powershell
        Description = (Get-AdventureWorldMessage "airlock_desc")
```

**Engine:**
```powershell
        Description = (Get-AdventureWorldMessage "engine_desc")
```

Use the surrounding context to locate the exact `Description = "..."` lines.

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-world.ps1
git commit -m "feat(adventure): LucasArts-style descriptions for eva, core, airlock, engine"
```

---

## Task 5: Raumbeschreibungen zentralisieren (Teil 3)

**Files:**
- Modify: `Modules/adventure-world.ps1`

- [ ] **Step 1: Ersetze Description für medbay, armory, quarters, observatory, cafeteria**

```powershell
        Description = (Get-AdventureWorldMessage "medbay_desc")
        Description = (Get-AdventureWorldMessage "armory_desc")
        Description = (Get-AdventureWorldMessage "quarters_desc")
        Description = (Get-AdventureWorldMessage "observatory_desc")
        Description = (Get-AdventureWorldMessage "cafeteria_desc")
```

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-world.ps1
git commit -m "feat(adventure): LucasArts-style descriptions for medbay, armory, quarters, observatory, cafeteria"
```

---

## Task 6: Raumbeschreibungen zentralisieren (Teil 4)

**Files:**
- Modify: `Modules/adventure-world.ps1`

- [ ] **Step 1: Ersetze Description für vent, secret, lab, server**

```powershell
        Description = (Get-AdventureWorldMessage "vent_desc")
        Description = (Get-AdventureWorldMessage "secret_desc")
        Description = (Get-AdventureWorldMessage "lab_desc")
        Description = (Get-AdventureWorldMessage "server_desc")
```

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-world.ps1
git commit -m "feat(adventure): LucasArts-style descriptions for vent, secret, lab, server"
```

---

## Task 7: Schlüssel-Objekte mit Stimme versehen

**Files:**
- Modify: `Modules/adventure-world.ps1`

- [ ] **Step 1: Ersetze Examine-Texte für terminal, box, notebook, screen, diary, computer, pedestal, warning_sign, cable, rubber_chicken, skull, tree, spacesuit, keycard, artifact**

For each object, replace the `Examine` string with `(Get-AdventureWorldMessage "<key>")`:

| Object Key in Objects hashtable | New Examine value |
|---------------------------------|-------------------|
| `terminal`   | `(Get-AdventureWorldMessage "terminal_examine")` |
| `box`        | `(Get-AdventureWorldMessage "box_examine")` |
| `notebook`   | `(Get-AdventureWorldMessage "notebook_examine")` |
| `screen`     | `(Get-AdventureWorldMessage "screen_examine")` |
| `diary`      | `(Get-AdventureWorldMessage "diary_examine")` |
| `computer`   | `(Get-AdventureWorldMessage "computer_examine")` |
| `artifact_pedestal` | `(Get-AdventureWorldMessage "pedestal_examine")` |
| `warning_sign`      | `(Get-AdventureWorldMessage "warning_examine")` |
| `cable`      | `(Get-AdventureWorldMessage "cable_examine")` |
| `rubber_chicken` | `(Get-AdventureWorldMessage "rubber_chicken_examine")` |
| `skull`      | `(Get-AdventureWorldMessage "skull_examine")` |
| `plastic_tree` | `(Get-AdventureWorldMessage "tree_examine")` |
| `spacesuit`  | `(Get-AdventureWorldMessage "spacesuit_examine")` |
| `keycard`    | `(Get-AdventureWorldMessage "keycard_examine")` |
| `artifact`   | `(Get-AdventureWorldMessage "artifact_examine")` |

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-world.ps1
git commit -m "feat(adventure): LucasArts-style examine texts for key objects"
```

---

## Task 8: Use-Handler und NPC-Dialoge umschreiben

**Files:**
- Modify: `Modules/adventure-world.ps1`

- [ ] **Step 1: Ersetze hartkodierte Use-Handler-Texte**

Locate these exact strings and replace them:

**Bridge unseal (inside `card` Use block):**
**Old:**
```powershell
                $script:AdvState.Flags.BridgeUnsealed = $true
                return @{ Success = $true; Message = "Du schiebst die Keycard in den Kartenleser der Bruecke. Die Tueren oeffnen sich mit einem Zischen."; CompanionContext = "adventure_unlock" }
```
**New:**
```powershell
                $script:AdvState.Flags.BridgeUnsealed = $true
                return @{ Success = $true; Message = (Get-AdventureWorldMessage "bridge_unseal"); CompanionContext = "adventure_unlock" }
```

**Core artifact use:**
**Old:**
```powershell
            $script:AdvState.Flags.CoreStabilized = $true
            return @{ Success = $true; Message = "Du legst das Artefakt in das Podest. Der Core stabilisiert sich."; CompanionContext = "adventure_unlock" }
```
**New:**
```powershell
            $script:AdvState.Flags.CoreStabilized = $true
            return @{ Success = $true; Message = (Get-AdventureWorldMessage "core_unlock"); CompanionContext = "adventure_unlock" }
```

**Server reboot:**
**Old:**
```powershell
            $script:AdvState.Flags.ServerRebooted = $true
            return @{ Success = $true; Message = "Du drueckst den roten Knopf. Die Server fahren neu hoch."; CompanionContext = "adventure_unlock" }
```
**New:**
```powershell
            $script:AdvState.Flags.ServerRebooted = $true
            return @{ Success = $true; Message = (Get-AdventureWorldMessage "server_reboot"); CompanionContext = "adventure_unlock" }
```

**Secret tree:**
**Old:**
```powershell
            return @{ Success = $true; Message = "Du redest mit dem Plastikbaum. Er antwortet nicht. Vielleicht ist er schuechtern."; CompanionContext = "adventure_absurd" }
```
**New:**
```powershell
            return @{ Success = $true; Message = (Get-AdventureWorldMessage "secret_tree_use"); CompanionContext = "adventure_absurd" }
```

**Lab computer:**
**Old:**
```powershell
            return @{ Success = $true; Message = "Du startest die Experiment-Simulation. Sie crasht sofort. Vielleicht ist das ein Feature."; CompanionContext = "adventure_absurd" }
```
**New:**
```powershell
            return @{ Success = $true; Message = (Get-AdventureWorldMessage "lab_computer_use"); CompanionContext = "adventure_absurd" }
```

**Vent skull:**
**Old:**
```powershell
            return @{ Success = $true; Message = "Du haeltst den Plastikschaedel ans Lueftungsgitter. Der Wind laesst ihn klappern."; CompanionContext = "adventure_absurd" }
```
**New:**
```powershell
            return @{ Success = $true; Message = (Get-AdventureWorldMessage "vent_skull_use"); CompanionContext = "adventure_absurd" }
```

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-world.ps1
git commit -m "feat(adventure): LucasArts-style use-handler and NPC texts"
```

---

## Task 9: Tests auf vergessene Template-Strings prüfen

**Files:**
- Modify: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Füge einen Check hinzu, der beweist, dass keine alten Generika mehr existieren**

After the existing Adventure engine tests, add:

```powershell
$hangar = $script:AdvRooms["hangar"]
Test-Assert "Hangar description is not generic" ($hangar.Description -notmatch "grosser Hangar mit einem alten Shuttle")
Test-Assert "Hangar description uses message lookup" ($hangar.Description -notlike "*Ein grosser Hangar*")
```

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add Modules/_smoke_test.ps1
git commit -m "test(adventure): ensure generic room descriptions are gone"
```

---

## Task 10: E2E-Regression

**Files:**
- Keine Änderungen, nur Verifikation.

- [ ] **Step 1: E2E laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_e2e_test.ps1"`
Expected: `=== ALL E2E CHECKS PASSED ===`.

- [ ] **Step 2: Integration-Test laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_integration_test.ps1"`
Expected: 116/116 passed.

- [ ] **Step 3: Report**

If all pass, report DONE. If any fail, fix and report.

---

## Self-Review Checklist

- [ ] Spec coverage: Phase 2 des Specs (Welt-Texte) ist komplett abgebildet.
- [ ] Keine `TBD` / `TODO` / Platzhalter im Plan.
- [ ] Typen konsistent: `Get-AdventureWorldMessage` akzeptiert `$Params` als Array.
- [ ] Keine neuen `script:`-Konflikte geplant.
- [ ] Tests bleiben string-unabhängig (ausser dem neuen Negativ-Check).
