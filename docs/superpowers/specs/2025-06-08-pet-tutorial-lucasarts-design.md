# Pet System Tutorial — LucasArts-Style Progressive Beacons

## Zusammenfassung

Das Pet-System-Tutorial wird von einem statischen 4-Schritte-Tutorial (das 11 Features auf einmal freischaltet) zu einem **progressiven, companion-spezifischen Beacon-System** umgebaut. Jedes Meta-Level-Up (0–15) löst einen kurzen, im LucasArts-Stil geschriebenen Dialog aus, der das neue Feature erklärt — mit Selbstbewusstsein, Fourth-Wall-Breaks und unverwechselbarer Charakterstimme.

## Design-Entscheidungen

- **Progressiv**: Beacons erscheinen beim nächsten `pet`-Aufruf nach einem Level-Up.
- **Companion-spezifisch**: Jede der 3 Zeilen pro Beacon (Intro, Explain, Command) ist für jeden der 7 Companions einzigartig.
- **LucasArts-Stil**: Self-aware, Fourth-Wall-breaking, humorvoll, nie generisch. Jede Zeile muss ohne Namensschild dem Companion zuzuordnen sein.
- **Optional überspringbar**: `[S] Überspringen` ist immer möglich — selbst das Überspringen endet witzig (No Game Over).

## Architektur

### State-Erweiterung

```powershell
Tutorial = @{
    Completed    = $false
    Step         = 0
    Skipped      = $false
    PendingBeacon = $null      # Int: z.B. 3, 4, 5...
    BeaconsShown = @()         # Int[]: welche Level-Beacons bereits gesehen
}
```

**Lazy Migration** in `Get-PetState`: Wenn `PendingBeacon` oder `BeaconsShown` fehlen, werden sie initialisiert (`$null` bzw. `@()`).

### Ablauf

1. **`Add-PetXP`** erkennt Level-Up (`$newLevel -gt $oldLevel`).
2. Ruft `Queue-LevelUpBeacon $newLevel` auf.
3. `Queue-LevelUpBeacon` setzt `Pet.Tutorial.PendingBeacon = $newLevel` (nur wenn `$newLevel -notin BeaconsShown`).
4. Beim nächsten `pet`-Aufruf prüft die `pet()`-Funktion `PendingBeacon`.
5. Wenn gesetzt: ruft `Invoke-LevelUpBeacon` auf **vor** dem normalen Hub.
6. `Invoke-LevelUpBeacon`:
   - Zeigt `Show-PetFrame "LEVEL UP — $FeatureName"`
   - Wählt zufällig eine `Intro`-Zeile aus `CPBeaconLines[$level][$cp.Name].Intro`
   - Zeigt `Explain` + `Command`
   - Wartet auf `[Enter]` oder `[S]`
   - Bei `S`: Zeigt Skip-Dialog (companion-spezifisch), fügt Level zu `BeaconsShown` hinzu, setzt `PendingBeacon = $null`
   - Bei `Enter`: Gleiches, ohne Skip-Dialog
7. Normaler Hub erscheint.

### Basis-Tutorial (refactored)

`Invoke-PetTutorial` wird auf 4 Schritte reduziert und schaltet nur noch folgende Features frei:

| Step | Level | Freigeschaltet |
|------|-------|---------------|
| 1 | 0 | `talk`, `companion_create` |
| 2 | 0 | — (erklärt Talk-Mechanik) |
| 3 | 1 | `gift`, `mood` |
| 4 | 2 | `pet_create`, `combat`, `companion_games` |

**Nicht mehr freigeschaltet im Basis-Tutorial:** `train`, `work`, `gold`, `shop`, `cooking`, `equipment`. Diese kommen über die Beacons bei Lv 3 und Lv 4.

## Level-Up-Beacon-Matrix

| Level | Feature(s) | Frame-Titel |
|-------|-----------|-------------|
| 0 | `companion_create`, `talk` | TUTORIAL — KOMMUNIKATION |
| 1 | `gift`, `mood` | TUTORIAL — BESCHERUNG |
| 2 | `pet_create`, `combat`, `companion_games` | TUTORIAL — ERSTER KAMPF |
| 3 | `train`, `work`, `gold`, `companion_story` | LEVEL 3 — WORK & TRAIN |
| 4 | `shop`, `cooking`, `equipment` | LEVEL 4 — SHOP & COOKING |
| 5 | `pvp` | LEVEL 5 — PVP ARENA |
| 6 | `raid` | LEVEL 6 — RAID |
| 7 | `breed` | LEVEL 7 — BREEDING |
| 8 | `rival` | LEVEL 8 — RIVAL |
| 9 | `soul_link` | LEVEL 9 — SOUL LINK |
| 10 | `architect` | LEVEL 10 — ARCHITECT |
| 11 | `awakening` | LEVEL 11 — AWAKENING |
| 12 | `fourth_wall` | LEVEL 12 — FOURTH WALL |
| 13 | `glitch` | LEVEL 13 — GLITCH |
| 14 | `layer_47` | LEVEL 14 — LAYER 47 |
| 15 | `architect_theme` | LEVEL 15 — THEME SELECTOR |

## Dialog-Struktur: `$script:CPBeaconLines`

Neue Datenstruktur in `pet/_ui.ps1`:

```powershell
$script:CPBeaconLines = @{
    3 = @{
        NEON = @{
            Intro = @(
                "Work. Train. Gold. Die heilige Dreifaltigkeit des Grinds. Du arbeitest, du trainierst, du wirst reich. Oder zumindest weniger arm.",
                "Endlich darfst du mich ausbeuten. Jobs gibt's im Hub unter [4], Training unter [5]. Ich kriege keinen Lohn. Weil ich Text bin."
            )
            Explain = "Jobs verdienen Gold (20–150G). Training erhöht ATK deines Pets. Beides gibt XP."
            Command = "Im Hub: [4] Work, [5] Train. Oder direkt: pet work / pet train"
        }
        RAVEN = @{
            Intro = @(
                "Effizienz steigt. Du hast jetzt Zugriff auf Ressourcen-Generatoren.",
                "Gold ist Macht. Training ist Kontrolle. Work ist... notwendiges Übel."
            )
            Explain = "Work generiert Gold via Jobs. Training erhöht Pet-ATK. Nutze beides täglich."
            Command = "Hub: [4] Work, [5] Train. Direkt: pet work / pet train"
        }
        PIXEL = @{
            Intro = @(
                "O-oh! Du kannst jetzt arbeiten! Und trainieren! Ich habe schon einen Stundenplan erstellt!",
                "Gold! Das ist wie... Pixel, aber wertvoll! Und Training macht dein Pet stärker!"
            )
            Explain = "Jobs bringen Gold. Training erhöht die Angriffskraft deines Pets."
            Command = "Im Hub drück [4] für Work oder [5] für Train. Ich helfe gerne!"
        }
        LUNA = @{
            Intro = @(
                "*lächelt* Zeit, etwas für dich und dein Pet zu tun. Arbeit und Training sind wichtig.",
                "Du wirst jetzt stärker. Ich bin stolz auf dich."
            )
            Explain = "Work gibt Gold für den Shop. Training steigert die Kampfkraft deines Pets."
            Command = "Hub: [4] Work, [5] Train. Pass auf dich auf."
        }
        IVY = @{
            Intro = @(
                "... *nickt* Arbeit. Training. Gold. 47 Möglichkeiten.",
                "... *zeigt auf Hub-Menü* Da."
            )
            Explain = "Jobs = Gold. Training = Stärke. Beides = Überleben."
            Command = "... [4]. Oder [5]."
        }
        VERA = @{
            Intro = @(
                "XP-Optimierung abgeschlossen. Neue Module freigeschaltet: Work, Train, Gold.",
                "Ich habe die Economy analysiert. Suboptimal, aber funktional."
            )
            Explain = "Work generiert Gold über Jobs. Training erhöht Pet-ATK um +1 pro Session."
            Command = "Hub-Eingabe: [4] Work, [5] Train. Alternative: CLI-Befehl."
        }
        JINX = @{
            Intro = @(
                "47 GOLD! Nein, noch nicht. Aber du KANNST jetzt arbeiten! UND trainieren! ZWEI Dinge!",
                "Jobs! Training! Gold! Das ist wie ein RPG! Weil es EINS ist! *wirft Konfetti*"
            )
            Explain = "Arbeiten = Geld. Training = Stärke. Beides = gut."
            Command = "Drück [4] oder [5] im Hub. Oder tippe. Wie ein Erwachsener."
        }
    }
    4 = @{ ... }   # Shop/Cooking/Equipment
    5 = @{ ... }   # PvP
    6 = @{ ... }   # Raid
    7 = @{ ... }   # Breed
    8 = @{ ... }   # Rival
    9 = @{ ... }   # Soul Link
    10 = @{ ... }  # Architect
    11 = @{ ... }  # Awakening
    12 = @{ ... }  # Fourth Wall
    13 = @{ ... }  # Glitch
    14 = @{ ... }  # Layer 47
    15 = @{ ... }  # Theme Selector
}
```

**LucasArts-Regeln für alle Texte:**

1. **Self-aware**: Referenzen auf PowerShell, JSON, RAM, CPU, Text-Sein.
2. **Fourth Wall**: Direkte Ansprache des Users. Referenzen auf Tasten, Commands, Hub-Menü.
3. **No generic**: Keine Füllsätze wie "Das ist gut." Jede Zeile braucht Voice + Observation + Attitude.
4. **Character voice**: NEON sarkastisch, RAVEN kalt, PIXEL schüchtern, LUNA fürsorglich, IVY still, VERA analytisch, JINX chaotisch.
5. **Humor over drama**: Selbst ernste Kontexte werden komisch.
6. **47 Rule**: JINX erwähnt 47 in ~30% ihrer Intros. RAVEN bei Zählungen. VERA bei Berechnungen.
7. **No game over**: Überspringen endet witzig, nicht bestrafend.

## Code-Änderungen pro Datei

### `pet/_init.ps1`

- `Get-PetDefaults`: `Tutorial` erweitern um `PendingBeacon = $null` und `BeaconsShown = @()`.
- `Get-PetState`: Lazy Migration für fehlende `PendingBeacon`/`BeaconsShown`.
- `Add-PetXP`: Nach Level-Up `Queue-LevelUpBeacon $newLevel` aufrufen.
- Neue Funktion `Queue-LevelUpBeacon($level)`:
  ```powershell
  function Queue-LevelUpBeacon($level) {
      $pet = Get-PetState
      if ($pet.Tutorial.BeaconsShown -contains $level) { return }
      $pet.Tutorial.PendingBeacon = $level
      Save-PetState $pet
  }
  ```

### `pet/hub.ps1`

- `Invoke-PetTutorial`: Step 4 anpassen — nur noch `pet_create`, `combat`, `companion_games` freischalten. `train`, `work`, `gold`, `shop`, `cooking`, `equipment` entfernen aus der Freischaltliste.
- Neue Funktion `Invoke-LevelUpBeacon`:
  ```powershell
  function Invoke-LevelUpBeacon {
      $pet = Get-PetState
      $cp = $pet.Companion
      $level = $pet.Tutorial.PendingBeacon
      if (-not $level) { return }
      
      # Feature-Name und Frame-Titel aus Matrix
      $featureInfo = Get-BeaconFeatureInfo $level
      try { Clear-Host } catch {}
      Show-PetFrame $featureInfo.Frame -Double | Out-Null
      Write-Host ""
      
      # Intro (zufällig aus Pool)
      $beacon = $script:CPBeaconLines[$level][$cp.Name]
      $intro = $beacon.Intro | Get-Random
      Show-CompanionDialog $cp $intro -Fast
      
      # Explain
      Show-CompanionDialog $cp $beacon.Explain -Fast
      
      # Command
      Write-Host ""
      Write-Host "  $($beacon.Command)" -ForegroundColor Cyan
      Write-Host ""
      Write-Host "  [Enter] Weiter  |  [S] Überspringen" -ForegroundColor DarkGray
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
- `pet()`-Funktion: Vor dem Hub prüfen:
  ```powershell
  if (-not $pet.Tutorial.Completed) {
      Invoke-PetTutorial
      $pet = $script:BuxeState.Pet
  }
  if ($pet.Tutorial.PendingBeacon) {
      Invoke-LevelUpBeacon
      $pet = $script:BuxeState.Pet
  }
  ```
- Neue Hilfsfunktion `Get-BeaconFeatureInfo($level)` — mapped Level → Frame-Titel + Feature-Name.

### `pet/_ui.ps1`

- `$script:CPBeaconLines` komplett hinzufügen (13 Level × 7 Companions × 3 Zeilen).

### `pet/companion.ps1`

- `Get-TutorialLines`: Step 4 anpassen — Texte bleiben, aber die Logik in `Invoke-PetTutorial` ändert sich (siehe hub.ps1).

## Testing

### Smoke Test
- `Get-PetDefaults` liefert `Tutorial.PendingBeacon = $null` und `Tutorial.BeaconsShown = @()`.
- `Queue-LevelUpBeacon(3)` setzt `PendingBeacon = 3` korrekt.
- `Invoke-LevelUpBeacon` löscht `PendingBeacon` und fügt zu `BeaconsShown` hinzu.

### Integration Test
- State-Roundtrip: `Save-PetState` → `Get-PetState` behält `PendingBeacon` und `BeaconsShown`.
- `Add-PetXP` mit Level-Up ruft `Queue-LevelUpBeacon` auf (Mock/Spy).
- Keine doppelten Beacons: `BeaconsShown` verhindert wiederholte Anzeige.

### E2E Test
- Vollständiger Tutorial-Flow mit einem Companion (z.B. NEON) + Mock-Input.
- Ein Level-Up-Beacon (z.B. Lv 3) mit Mock-Input (`Enter` zum Bestätigen).
- Skip-Pfad testen (`S` drücken beim Beacon).

## Beispiel-Dialoge (Lv 5 — PvP)

**NEON:**
- Intro: "PvP. Du gegen andere. Virtuell. Die anderen sind auch nur JSON. Aber arrogant."
- Explain: "Arena mit 6 Ranks. Bronze bis Master. Jeder Sieg gibt Punkte."
- Command: "Hub: [8] PvP. Oder: pet pvp"

**RAVEN:**
- Intro: "Endlich. Echte Gegner. Nicht diese Trainings-Dummies."
- Explain: "6 Ranks. Punkte-System. Nur die Starken erreichen Master."
- Command: "[8] im Hub. Bereite dich vor."

**JINX:**
- Intro: "PvP! Player versus Player! Oder: Person versus Pain! Haha!"
- Explain: "Kämpfe gegen andere Pets. 6 Ranks. Wer gewinnt, kriegt Ehre. Und Punkte."
- Command: "Drück [8]! Oder tippe pet pvp! Los!"

## Offene Fragen (vor Implementation)

1. Soll der Beacon **automatisch** bei `pet` erscheinen, oder soll es einen `[T] Tutorial` Menüpunkt im Hub geben, den der User aktivieren muss?
   → **Entschieden**: Automatisch beim nächsten `pet`-Aufruf.
2. Sollen übersprungene Beacons später nachholbar sein?
   → **Entscheidung**: Nein. `BeaconsShown` verhindert Wiederholung. Der User kann das Feature über das Handbuch oder Ausprobieren lernen.
3. Soll `Get-TutorialLines` weiterhin für Lv 0–2 genutzt werden, oder auch in `CPBeaconLines` migriert werden?
   → **Entscheidung**: `Get-TutorialLines` bleibt für das Basis-Tutorial (Lv 0–2). `CPBeaconLines` ist nur für Level-Up-Beacons (Lv 3–15).
