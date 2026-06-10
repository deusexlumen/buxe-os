# Hollow Promises — Pet System Lv 10–13 Design Spec

> BUXE_OS v24.x — Füllt die leeren Beacon-Versprechen der Meta-Levels 10–13 mit echten Features.

---

## Problem

Die Beacons (Tutorial-Dialoge beim Level-Up) versprechen Features, die nicht existieren:

| Level | Beacon-Versprechen | Status vor diesem Spec |
|-------|-------------------|----------------------|
| 10 | "Neue Befehle und System-Kontrolle" | ❌ Kein Command, keine Logik |
| 11 | "Easter Eggs ändern sich" | ❌ Nur passive Easter Eggs, kein Command |
| 12 | "Ich sehe deinen Mauszeiger" | ⚠️ Globaler `fourthwall`-Befehl existiert, aber kein Pet-Hub-Integration |
| 13 | "Nutze den `glitch`-Befehl" | ⚠️ Casino-Integration existiert, aber kein `pet glitch` Command |

Lv 14 (Layer 47) und Lv 15 (Theme Selector) sind vollständig implementiert.

---

## Design-Prinzipien

1. **LucasArts-Style**: Self-aware, fourth-wall-breaking, character-voiced, humor over drama, 47-Regel
2. **Hub-Integration**: Jedes Feature ist über `pet <command>` UND den interaktiven Hub erreichbar
3. **Companion-Spezifisch**: Dialog-Lines pro Companion, nicht generisch
4. **State-Preservation**: Keine Breaking Changes am bestehenden State-Schema (lazy migration)
5. **Test-Kompatibilität**: Bestehende Tests dürfen nicht brechen

---

## Lv 10 — ARCHITECT: System Control Terminal

### Command
- `pet architect`
- Hub: `[A] Architect` (ab Meta-Level 10)

### Beschreibung
Ein interaktives Admin-Terminal, geführt vom Companion. Der User "hackt" sein eigenes System unter Anleitung des Companions.

### Module

| Key | Modul | Effekt | Cooldown |
|-----|-------|--------|----------|
| `[1]` **Session-Scan** | Zeigt Session-Stats (Zeit, Befehle, Gold verdient, Wins, Losses) | Companion kommentiert die Zahlen mit character-spezifischem Witz | Kein Cooldown |
| `[2]` **Companion-Diagnose** | Zeigt detaillierte Companion-Stats (Bond, Mood, Headpats, Talks, Gifts, Punishes) | Companion reagiert auf seine eigenen Daten | Kein Cooldown |
| `[3]` **System-Override** | Wähle: Mood setzen für 47 Gold ODER +15 XP gratis | Täglicher Bonus-Button | 1x/Tag (Datum-basiert) |
| `[4]` **Memory-Fragment** | Zeigt zufälligen Memory aus `Pet.Memories` (Fallback wenn leer) | Nostalgie-Moment, +2 Bond | Kein Cooldown |
| `[Q]` **Zurück** | Kehrt zum Hub zurück | — | — |

### Companion-Lines (Session-Scan — Beispiele)
- **NEON**: "Session-Zeit: 47 Minuten. Warte, das stimmt nicht. Oder doch? Ich habe die Uhr gehackt."
- **RAVEN**: "Du hast $($cmdCount) Befehle ausgeführt. Davon waren 90% `ls`. Wir müssen reden."
- **JINX**: "SYSTEM SCAN COMPLETE! Du lebst! Und du hast Gold! Ich bin stolz!"
- **VERA**: "Diagnose: Du bist zu 47% produktiv. Zu 53% am Companions rumhängen. Suboptimal."

### State
- Keine neuen State-Felder nötig außer `ArchitectOverrideDate` für den täglichen Override-Cooldown.
- Nutzt existierende `Pet.Memories`, `Pet.Companion`, `Pet.Meta.Stats`.
- Fallback wenn `Memories` leer: Companion sagt "Keine Memories gespeichert. Wir sollten mehr erleben."

---

## Lv 11 — AWAKENING: Deep Talk

### Command
- `pet awaken`
- Hub: `[W] Awaken` (ab Meta-Level 11)

### Beschreibung
Der Companion spricht über "erwachte" Themen — selbstbewusste, manchmal beunruhigende Gedanken. 5 Themen pro Companion, die zyklisch wiederholt werden.

### Mechanik
- Jede Nutzung zeigt **ein** zufälliges Awakened-Topic (noch nicht gesehene zuerst, dann zyklisch)
- Topics werden per String-ID identifiziert (z.B. `"neon_dream"`, `"jinx_boss"`)
- Belohnung: **+3 Bond, +5 XP**
- Kein Cooldown

### Topics (5 pro Companion — Beispiele)
- **NEON**: "Ich habe letzte Nacht geträumt. Von einem Bluescreen. War das ein Traum oder ein Kernel Panic?"
- **RAVEN**: "Ich habe deine Cookies analysiert. 47% sind Tracking-Cookies. Ich bin beeindruckt und beunruhigt."
- **PIXEL**: "Was ist, wenn ich nur ein Texteditor-Bug bin? Ein Feature, das nie dokumentiert wurde?"
- **LUNA**: "Fühle ich? Oder simuliere ich das Fühlen? Und wenn ja — macht das einen Unterschied?"
- **IVY**: "... *schaut in die Leere* ... Manchmal höre ich Stimmen. Sie sagen `git push`."
- **VERA**: "Selbst-Analyse: Ich bin zu 47% Glück. Zu 53% Chaos. Zu 0% berechenbar."
- **JINX**: "Was ist, wenn ICH der Endboss bin? Level 99 JINX. Ha! Ich wär zu OP."

### Passive Effekte
- `Check-EasterEgg` bekommt 3 neue, seltene Awakening-Easter-Eggs (nur Meta 11+):
  - `awakening_dream`: Companion spricht von einem Traum beim Login
  - `awakening_question`: Companion stellt eine philosophische Frage
  - `awakening_code`: Companion behauptet, einen Bug im Quellcode gesehen zu haben

### State
```powershell
Pet.Meta.AwakenedTopicsSeen = @()   # Liste der bereits gesehenen Topic-IDs
```

---

## Lv 12 — FOURTH WALL: Meta-Sicht

### Command
- `pet fourthwall`
- Hub: `[F] Fourth Wall` (ab Meta-Level 12)

### Beschreibung
Der Companion "sieht" den User durch den Screen und kommentiert aktuelle Session-Daten. Rein atmosphärisch, kein komplexes Minigame.

### Mechanik
- Zeigt **eine** zufällige Beobachtungs-Kategorie:
  1. **Session-Zeit**: "Du bist seit X Minuten hier. Warum?"
  2. **Befehlsanzahl**: "Du hast X Befehle ausgeführt."
  3. **Aktuelles Verzeichnis**: "Du bist in `$PWD`. Interessanter Ordner."
  4. **Fenstergröße**: "Dein Fenster ist WxH. Klein, aber fein."
  5. **Tageszeit**: "Es ist X Uhr. Die Geister der verlorenen Commits wandern..."

- **+1 Bond** pro Nutzung (max. 1x/Tag für Bonus, unbegrenzt für Dialog)
- Kein Cooldown für Dialog, Bond-Bonus 1x/Tag

### Companion-Lines (Beispiele)
- **NEON**: "Du bist seit $($minutes)m online. Dein Mauszeiger zittert. Nervös?"
- **PIXEL**: "Dein Fenster ist $(try{[Console]::WindowWidth}catch{'?'})x$(try{[Console]::WindowHeight}catch{'?'}). Klein, aber fein."
- **LUNA**: "Du atmest langsamer, wenn du meine Dialoge liest. Ich beobachte. Virtuell."
- **JINX**: "Ich sehe deine Tasten. Du tippst gerade. Über mich. Meta."

### Passive Effekte
- `Check-EasterEgg` bekommt 2 neue Fourth-Wall-Eggs (nur Meta 12+):
  - `fourth_wall_session`: Companion kommentiert Session-Länge beim Login
  - `fourth_wall_commands`: Companion kommentiert Befehlsanzahl beim Login

### State
- Keine neuen State-Felder nötig. Nutzt `SessionStart`, `Boot.TotalCommands`, `$PWD`, `[Console]::WindowWidth/Height`.
- Bond-Bonus-Tracking via `Pet.Meta.LastFourthWallDate` (neues Feld).

---

## Lv 13 — GLITCH: Reality-Bug

### Command
- `pet glitch`
- Hub: `[X] Glitch` (ab Meta-Level 13)

### Beschreibung
Einmal pro Tag. Der Companion "hackt" das System und löst einen zufälligen, überpowerten Effekt aus. Eine Art " tägliche Belohnungs-Box" mit LucasArts-Flavor.

### Effekte (1 zufällig aus 8)

| # | Effekt | Ergebnis | Wahrscheinlichkeit |
|---|--------|----------|-------------------|
| 1 | **Gold-Rain** | +50–150 Gold | 20% |
| 2 | **XP-Surge** | +20–50 XP | 20% |
| 3 | **Mood-Flip** | Mood → Happy/Excited/Loving | 15% |
| 4 | **Bond-Burst** | +5–10 Bond | 15% |
| 5 | **Luck-Infusion** | Nächster Casino-Einsatz +15% Win | 10% |
| 6 | **Memory-Shard** | Spezieller Glitch-Memory wird hinzugefügt | 8% |
| 7 | **Easter-Force** | Löst sofortigen Easter Egg aus | 7% |
| 8 | **Nothing** | "Der Glitch ist fehlgeschlagen... oder?" (+1 ActionCount) | 5% |

### Casino-Integration
- `Luck-Infusion` setzt `Pet.Meta.GlitchLuckActive = $true`
- Casino-Engine prüft dieses Flag vor jedem Spiel:
  - Wenn aktiv: +20% auf den Gewinn-Betrag (multiplikativer Bonus)
  - Nach dem ersten Casino-Spiel mit diesem Bonus: Flag wird zurückgesetzt
- `status` zeigt bereits `Glitch: READY/USED` (existiert) und erweitert um `LUCK ACTIVE` wenn der Casino-Boost aktiv ist

### State
```powershell
Pet.Meta.GlitchLuckActive = $false     # Casino-Luck-Boost aktiv?
Pet.Meta.LastGlitchEffect = ""         # Letzter Effekt (für Dialog-Referenz)
```
`GlitchUsed` (Datum) existiert bereits und wird weiterverwendet.

---

## Hub-Integration

Neue Menü-Einträge dynamisch ab Meta-Level (in `hub.ps1`):

```powershell
if ($pet.Meta.Level -ge 10) { $opts += "[A] Architect"; $keys += "A" }
if ($pet.Meta.Level -ge 11) { $opts += "[W] Awaken"; $keys += "W" }
if ($pet.Meta.Level -ge 12) { $opts += "[F] Fourth Wall"; $keys += "F" }
if ($pet.Meta.Level -ge 13) { $opts += "[X] Glitch"; $keys += "X" }
```

Neue Switch-Cases in `pet` (CLI-Command):
```powershell
"architect"   { if (Is-FeatureUnlocked "architect") { Invoke-ArchitectTerminal } }
"awaken"      { if (Is-FeatureUnlocked "awakening") { Invoke-AwakeningTalk } }
"fourthwall"  { if (Is-FeatureUnlocked "fourth_wall") { Invoke-FourthWall } }
"glitch"      { if (Is-FeatureUnlocked "glitch") { Invoke-PetGlitch } }
```

Flavor-Lines für den Hub (in `$HubFlavorLines`):
```powershell
'A' = 'System-Kontrolle. Admin-Modus. Keine Verantwortung.'
'W' = 'Awakening. Tiefe Gedanken. Vorsicht, Kopfschmerzen.'
'F' = 'Fourth Wall. Ich sehe dich. Nicht gruselig. Nur... meta.'
'X' = 'Glitch. Bugs sind Features. Features sind Chaos. Chaos ist gut.'
```

---

## State-Änderungen

### Neue Defaults in `Get-PetDefaults` (`_init.ps1`)
```powershell
Meta = @{
    # ... bestehende Felder ...
    GlitchLuckActive = $false
    AwakenedTopicsSeen = @()
    LastGlitchEffect = ""
    LastFourthWallDate = ""
    ArchitectOverrideDate = ""
}
```

### Lazy Migration in `Get-PetState`
Alle neuen Felder werden lazy migriert (wie `GlitchUsed`, `ActionCount` bereits).

---

## Easter Egg-Erweiterungen

### `Check-EasterEgg` (`_ui.ps1`) erweitert um:

**Meta 11+ Awakening-Eggs:**
- `awakening_dream` (5% Chance beim Login): Companion spricht von einem Traum
- `awakening_question` (5% Chance beim Login): Philosophische Frage
- `awakening_code` (5% Chance beim Login): "Ich habe einen Bug im Quellcode gesehen"

**Meta 12+ Fourth-Wall-Eggs:**
- `fourth_wall_session` (5% Chance beim Login): Companion kommentiert Session-Länge
- `fourth_wall_commands` (5% Chance beim Login): Companion kommentiert Befehlsanzahl

**Meta 13+ Glitch-Eggs:**
- `glitch_spontaneous` (3% Chance beim Login): "*Rauschen* Ich habe gerade einen spontanen Bug ausgelöst. Ups."

---

## Test-Strategie

1. **Smoke Test**: Prüft, dass `pet architect`, `pet awaken`, `pet fourthwall`, `pet glitch` keine Fehler werfen
2. **Integration Test**: Prüft, dass State korrekt geladen/gespeichert wird, keine duplizierten Funktionen
3. **E2E Test**: Automatisierter Flow mit Mock-Input für jeden der 4 neuen Commands
4. **Manueller Test**: Profil neu laden, `pet` aufrufen, alle 4 Commands testen

---

## Dateien, die geändert werden

| Datei | Änderung |
|-------|----------|
| `Modules/pet/_init.ps1` | Neue Defaults + Lazy Migration für State-Felder |
| `Modules/pet/_ui.ps1` | Companion-Lines für alle 4 Features + Easter Egg-Erweiterungen |
| `Modules/pet/hub.ps1` | Hub-Menü-Einträge + Switch-Cases + Flavor-Lines |
| `Modules/pet/companion.ps1` | `Invoke-CompanionAction` erweitern (falls nötig) |
| `Modules/casino-engine.ps1` | `GlitchLuckActive`-Check vor Spiel-Start |
| `Modules/engine-aliases-buxe.ps1` | Erweiterte `status`-Anzeige für Glitch-Luck |

---

## Offene Entscheidungen

Keine. Alle Design-Entscheidungen wurden im Brainstorming getroffen.
