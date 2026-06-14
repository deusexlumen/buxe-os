# Adventure LucasArts Overhaul — Phase 1: Engine Messages & Death Reset

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Alle generischen Engine-Meldungen im Adventure werden LucasArts-konform ersetzt, und Tod wird von einem dramatischen `GAME OVER` in einen humorvollen Respawn-Text mit `Death = $true` umgewandelt.

**Architecture:** Eine zentrale `Get-AdventureMessage`-Lookup-Tabelle in `adventure-engine.ps1` hält alle Standard-Strings. `Process-AdventureCommand` ruft sie anstelle von hartkodiertem Text auf und setzt bei Todesfällen zusätzlich `Death = $true`. Neue Companion-Kontexte (`adventure_death_eva`, `adventure_death_oxygen`, `adventure_death_hollow`) werden in `pet/_ui.ps1` registriert.

**Tech Stack:** PowerShell 7/5.1, BUXE_OS State-System, bestehende Tests `_smoke_test.ps1` und `_integration_test.ps1`.

---

## File Structure

| Datei | Verantwortung |
|-------|---------------|
| `Modules/adventure-engine.ps1` | `Get-AdventureMessage` + `Process-AdventureCommand` String-Updates + `Death`-Flag |
| `Modules/pet/_ui.ps1` | Neue `adventure_death_*`-Kontexte in `CPMetaLines` + `Get-CompanionLine` Switch-Einträge |
| `Modules/_smoke_test.ps1` | `EVA without suit = death` prüft `$result.Death` statt `-match "GAME OVER"` |
| `Modules/_integration_test.ps1` | `EVA without suit = death` prüft `$result.Death` statt `-match "GAME OVER"` |

---

## Task 1: Zentrale Adventure-Message-Tabelle

**Files:**
- Modify: `Modules/adventure-engine.ps1` (nach `Show-Inventory`, ca. Zeile 140)

- [ ] **Step 1: Füge `Get-AdventureMessage` ein**

```powershell
function Get-AdventureMessage($Key, $Params = @()) {
    $messages = @{
        empty_inventory    = "Deine Taschen sind so leer wie mein Entwickler-Testverzeichnis. Sogar der Staub hat sich verzogen."
        inventory_prefix   = "Aktueller Speicherbelegung: {0}"
        cannot_go          = "Dorthin geht nur die Wand. Und meine Geduld, wenn du es nochmal probierst."
        not_here           = "Nicht in diesem Raum. Nicht in diesem Universum. Nicht in meiner JSON."
        not_here_examine   = "Meine Render-Pipeline findet hier kein Objekt mit diesem Namen."
        not_takeable       = "Dieser Gegenstand ist an den Boden gepinnt. Wortwörtlich."
        take               = "+1 {0} in den 8-Bit-Inventarslot gepackt."
        already_have       = "Doppelter Eintrag. Selbst mein Array würde das ablehnen."
        not_in_inventory   = "Nicht gefunden. Weder im Inventar noch im Cache."
        drop               = "Du dropst {0}. Hoffentlich bleibt es im Savegame."
        talk_no_target     = "Mit wem willst du reden? Der Spiegel ist in einem anderen Raum."
        save               = "State committed – wie ein git push vor dem Wochenende."
        load               = "State restored. Alle Fehler stehen wieder zur Verfügung."
        unknown_command    = "Parser-Fehler 0xBADC0DE. Probier mal 'help'. Oder bete."
        use_fail           = "Diese Kombination ist so illegal wie ein goto in 2026."
        hack_what          = "Was willst du hacken? Ein Gefühl? Probier 'help'."
        hack_not_hackable  = "Das kannst du nicht hacken. Nicht alles ist ein Terminal."
        hack_terminal_locked  = "Du hackst das Terminal. Die Kartenleser-Sicherheit ist lächerlich. Die Brücke ist jetzt zugänglich."
        hack_medbay_terminal  = "Du hackst das Med-Terminal. Patientendaten entschlüsselt. Jemand hat Experimente an der Crew durchgeführt. Und du hast den Schlüssel gefunden: 7-7-7."
        hack_terminal_done = "Das Terminal ist bereits entsperrt oder nicht hackbar."
        jump_useless       = "Das bringt hier nichts. Schwerkraft ist auch nur eine Convention."
        die_not_here       = "Nicht hier. Nicht jetzt. Speichere erst, wenn du unbedingt willst."
        void_not_here      = "Void ist kein Ort. Noch nicht. Du brauchst dafür mehr Absurdes."
        oxygen_low         = "O₂-Buffer läuft voll. Bald bootest du als Weltraum-Eiswürfel neu."
        death_eva          = "Oh. Du hast die Luftschleuse ohne Anzug geöffnet. Das ist wie Remove-Item ohne -WhatIf.`n`n*Ladegeräusch*`n`nDrück 'load', dann reden wir über Risikomanagement."
        death_oxygen       = "Sauerstoff = 0. Du bist jetzt ein kleiner, gefriergetrockneter Satellit. Kein Drama – dein Savegame ist noch warm.`n`nDrück 'load' für Take 2."
        death_hollow_jump  = "Du springst in die Leere. Der Fall ist endlos, aber unten steht schon ein Respawn-Punkt. Typisches LucasArts-Debugging.`n`nDrück 'load'."
        death_hollow_die   = "Du gibst auf. Die Dunkelheit umarmt dich. Sie ist warm. Fast wie ein Windows-Update-Reboot.`n`nDrück 'load'."
        death_hollow_void  = "Du wirst eins mit der Leere. Kein Licht. Nur... Code. Und ein Compilier-Fehler, der dich zurückholt.`n`nDrück 'load'."
    }
    $msg = $messages[$Key]
    if (-not $msg) { return "" }
    if ($Params.Count -gt 0) { $msg = $msg -f $Params }
    return $msg
}
```

- [ ] **Step 2: Smoke-Test sicherstellen, dass `Get-AdventureMessage` existiert**

Füge in `Modules/_smoke_test.ps1` in der Adventure-Sektion (nach Zeile 368) hinzu:

```powershell
Test-Assert "Get-AdventureMessage exists" ((Get-Command Get-AdventureMessage -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "Get-AdventureMessage returns string" ((Get-AdventureMessage "cannot_go") -is [string])
```

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-engine.ps1 Modules/_smoke_test.ps1
git commit -m "feat(adventure): add Get-AdventureMessage lookup table"
```

---

## Task 2: Inventar-Meldungen LucasArts-ifizieren

**Files:**
- Modify: `Modules/adventure-engine.ps1` Zeile 129-139 (`Show-Inventory`)

- [ ] **Step 1: Ersetze `Show-Inventory`**

```powershell
function Show-Inventory {
    $inv = $script:AdvState.Inventory
    if ($inv.Count -eq 0) { return Get-AdventureMessage "empty_inventory" }
    $items = @()
    foreach ($id in $inv) {
        $name = $id
        foreach ($room in $script:AdvRooms.Values) {
            if ($room.Objects[$id]) { $name = $room.Objects[$id].Name; break }
        }
        $items += $name
    }
    return (Get-AdventureMessage "inventory_prefix" @(($items -join ", ")))
}
```

- [ ] **Step 2: Smoke-Test laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_smoke_test.ps1"`
Expected: weiterhin grün (Tests: 220/220)

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-engine.ps1
git commit -m "feat(adventure): LucasArts-style inventory messages"
```

---

## Task 3: Engine-Command-Strings zentralisieren

**Files:**
- Modify: `Modules/adventure-engine.ps1` (`Process-AdventureCommand` switch, ca. Zeile 236-471)

- [ ] **Step 1: Ersetze String-Returns im `switch`-Block**

Suche und ersetze die folgenden Zeilen exakt:

| Zeile (alt) | Ersetzen durch |
|-------------|----------------|
| `Du kannst nicht nach $($Cmd.Noun) gehen.` | `Get-AdventureMessage "cannot_go"` |
| `Du oeffnest die Luftschleuse... GAME OVER ... Tippe 'load' um fortzufahren.` | `Get-AdventureMessage "death_eva"` und füge `Death = $true` zum Result-Hash hinzu |
| `Dein Sauerstoff ist aufgebraucht... GAME OVER ... Tippe 'load' um fortzufahren.` | `Get-AdventureMessage "death_oxygen"` und `Death = $true` |
| `Das siehst du hier nicht.` (beide Vorkommen) | `Get-AdventureMessage "not_here_examine"` |
| `Das gibt es hier nicht.` | `Get-AdventureMessage "not_here"` |
| `Das kannst du nicht mitnehmen.` | `Get-AdventureMessage "not_takeable"` |
| `Du nimmst $($obj.Name).` | `Get-AdventureMessage "take" @($obj.Name)` |
| `Du hast das schon.` | `Get-AdventureMessage "already_have"` |
| `Das hast du nicht.` | `Get-AdventureMessage "not_in_inventory"` |
| `Du legst $($objDef.Name) hin.` | `Get-AdventureMessage "drop" @($objDef.Name)` |
| `Mit wem willst du reden?` | `Get-AdventureMessage "talk_no_target"` |
| `Spiel gespeichert.` | `Get-AdventureMessage "save"` |
| `Spiel geladen.` | `Get-AdventureMessage "load"` |
| `Das verstehe ich nicht. Tippe 'help' für Hilfe.` | `Get-AdventureMessage "unknown_command"` |
| `Das funktioniert nicht.` | `Get-AdventureMessage "use_fail"` |
| `Was willst du hacken?` | `Get-AdventureMessage "hack_what"` |
| `Das kannst du nicht hacken.` | `Get-AdventureMessage "hack_not_hackable"` |
| `Du hackst das Terminal. Die Kartenleser-Sicherheit ist laecherlich. Die Bruecke ist jetzt zugaenglich.` | `Get-AdventureMessage "hack_terminal_locked"` |
| `Du hackst das Med-Terminal...` | `Get-AdventureMessage "hack_medbay_terminal"` |
| `Das Terminal ist bereits entsperrt oder nicht hackbar.` | `Get-AdventureMessage "hack_terminal_done"` |
| `Das bringt hier nichts.` | `Get-AdventureMessage "jump_useless"` |
| `Nicht hier. Nicht jetzt.` | `Get-AdventureMessage "die_not_here"` |
| `Void ist kein Ort. Noch nicht.` | `Get-AdventureMessage "void_not_here"` |
| `Du springst in die Leere... GAME OVER ... Tippe 'load' um fortzufahren.` | `Get-AdventureMessage "death_hollow_jump"` + `Death = $true` |
| `Du gibst auf. Die Dunkelheit... GAME OVER ... Tippe 'load' um fortzufahren.` | `Get-AdventureMessage "death_hollow_die"` + `Death = $true` |
| `Du wirst eins mit der Leere... GAME OVER ... Tippe 'load' um fortzufahren.` | `Get-AdventureMessage "death_hollow_void"` + `Death = $true` |

Das CompanionContext für Todesfälle soll von `adventure_scared` auf folgende Kontexte geändert werden:
- EVA-Tod: `adventure_death_eva`
- Sauerstoff-Tod: `adventure_death_oxygen`
- Hollow `jump`/`die`/`void`: `adventure_death_hollow`

Beispiel für die neuen Result-Hashtables:

```powershell
$result = @{ Success = $false; Message = (Get-AdventureMessage "death_eva"); Death = $true; CompanionContext = "adventure_death_eva" }
```

- [ ] **Step 2: Sauerstoff-Warnung im Renderer**

Ändere in `Show-AdventureRoom` (Zeile ~574):

```powershell
if ($Room.Id -eq "eva" -and $script:AdvState.Oxygen -le 5) {
    Write-Host "  $(Get-AdventureMessage "oxygen_low") $($script:AdvState.Oxygen)/10" -ForegroundColor Red
}
```

- [ ] **Step 3: Smoke-Test laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_smoke_test.ps1"`
Expected: Tests laufen, aber `EVA without suit = death` schlägt noch fehl, weil er auf `GAME OVER` matched. Das wird in Task 4 behoben.

- [ ] **Step 4: Commit**

```bash
git add Modules/adventure-engine.ps1
git commit -m "feat(adventure): centralize command messages and convert deaths to respawn texts"
```

---

## Task 4: Neue Death-Companion-Kontexte im Pet-UI

**Files:**
- Modify: `Modules/pet/_ui.ps1` (`$script:CPMetaLines` und `Get-CompanionLine` switch)

- [ ] **Step 1: Füge `adventure_death_*` zu `$script:CPMetaLines` hinzu**

Füge nach `adventure_absurd` (ca. Zeile 253 im `CPMetaLines`-Block) hinzu:

```powershell
    adventure_death_eva = @(
        "Oh. Ohne Anzug. Das ist wie ein rm -rf / im Weltraum."
        "Du bist jetzt ein Eiswürfel. Kein Game Over, nur Game-Over-Angst."
        "Respawn steht bereit. Die Station lacht nicht. Sie ist nur enttäuscht."
    )
    adventure_death_oxygen = @(
        "Sauerstoff aus. Du schläfst jetzt. Virtuell. Für immer. Naja, bis 'load'."
        "Atmen ist wichtig. Das hast du gerade gelernt."
        "Dein Savegame ist noch warm. Drück 'load', bevor es kalt wird."
    )
    adventure_death_hollow = @(
        "Die Leere hat dich. Sie ist warm. Fast wie ein Windows-Update-Reboot."
        "Du bist eins mit dem Void. Kein Licht. Nur... Code."
        "Respawn-Punkt unten. Wie praktisch. Typisch Adventure."
    )
```

- [ ] **Step 2: Füge Switch-Cases in `Get-CompanionLine` hinzu**

Suche den Switch-Block in `Get-CompanionLine` (ca. Zeile 927) und füge nach `adventure_absurd` hinzu:

```powershell
        "adventure_death_eva" { $lines = $script:CPMetaLines.adventure_death_eva }
        "adventure_death_oxygen" { $lines = $script:CPMetaLines.adventure_death_oxygen }
        "adventure_death_hollow" { $lines = $script:CPMetaLines.adventure_death_hollow }
```

- [ ] **Step 3: Smoke-Test laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_smoke_test.ps1"`
Expected: `EVA without suit = death` schlägt noch fehl (Test-Update folgt in Task 5).

- [ ] **Step 4: Commit**

```bash
git add Modules/pet/_ui.ps1
git commit -m "feat(adventure): add companion death contexts"
```

---

## Task 5: Tests auf `Death`-Flag umstellen

**Files:**
- Modify: `Modules/_smoke_test.ps1` Zeile 462
- Modify: `Modules/_integration_test.ps1` Zeile 345

- [ ] **Step 1: Smoke-Test anpassen**

Ersetze:

```powershell
Test-Assert "EVA without suit = death" ($result.Message -match "GAME OVER")
```

durch:

```powershell
Test-Assert "EVA without suit = death" ($result.Death -eq $true)
```

- [ ] **Step 2: Integration-Test anpassen**

Ersetze:

```powershell
Test-Assert "EVA without suit = death" ($result.Message -match "GAME OVER")
```

durch:

```powershell
Test-Assert "EVA without suit = death" ($result.Death -eq $true)
```

- [ ] **Step 3: Smoke + Integration laufen lassen**

Run:
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_smoke_test.ps1"
pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_integration_test.ps1"
```
Expected:
- Smoke: 220/220 passed
- Integration: 116/116 passed

- [ ] **Step 4: Commit**

```bash
git add Modules/_smoke_test.ps1 Modules/_integration_test.ps1
git commit -m "test(adventure): assert Death flag instead of GAME OVER string"
```

---

## Task 6: E2E-Regression

**Files:**
- Keine Änderungen, nur Verifikation.

- [ ] **Step 1: E2E laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_e2e_test.ps1"`
Expected: `=== ALL E2E CHECKS PASSED ===`

- [ ] **Step 2: Manuelles Quick-Check (optional aber empfohlen)**

```powershell
pwsh -NoProfile -Command "& { . $PROFILE; adv }"
# Im Adventure: 'go west' im Hangar -> blockierte Richtung sollte neuen Text zeigen
# 'q' um zu beenden
```

- [ ] **Step 3: Commit (falls nur E2E-Log erwünscht)**

Falls keine Änderungen nötig waren, kein Commit. Falls E2E-Test einen Fehler gefunden hat, fixen und committen.

---

## Self-Review Checklist

- [ ] Spec coverage: Alle Punkte aus Phase 1 des Specs sind in Tasks abgebildet.
- [ ] Keine `TBD` / `TODO` / Platzhalter im Plan.
- [ ] Typen konsistent: `$result.Death` ist Boolean, `Get-AdventureMessage` akzeptiert `$Params` als Array.
- [ ] Keine neuen `script:`-Variablenkonflikte geplant.
- [ ] Tests werden aktualisiert, bevor der neue `Death`-Text live wird.
