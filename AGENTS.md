# BUXE_OS - Agent Guide

> Dieses Dokument ist fuer AI-Coding-Agenten bestimmt. Es beschreibt die Architektur, Konventionen und Regeln dieses Projekts.

---

## Project Overview

**BUXE_OS** ist ein hochgradig personalisiertes PowerShell-Profil-System fuer Windows. Es wird als "Betriebssystem" fuer die Shell bezeichnet und enthaelt dutzende interaktive Features: Arcade-Spiele, Casino-Suite, RPG-Systeme (Companion + Battlepet), Git-Aliase, Navigation-Shortcuts, TTS, API-Integrationen und einen selbstbewussten Boot-Sequence.

- **Sprache**: PowerShell 7/5.1-kompatibel
- **Hauptsprache der Doku/Kommentare**: Deutsch
- **Profil-Pfad**: `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- **Modul-Pfad**: `%USERPROFILE%\Documents\PowerShell\Modules\`
- **Daten-Persistenz**: `%LOCALAPPDATA%\buxe\buxe_state_v24.json` (unified JSON)

---

## Project Structure

```
Documents\PowerShell\
├── Microsoft.PowerShell_profile.ps1      # Entry point (~250 Zeilen), TTS-System
├── buxe.omp.json                         # Oh-My-Posh Theme (JSON-Schema v2)
├── achievements.json                     # Legacy-Achievement-Datei (nicht mehr aktiv)
├── GUIDE.md                              # Benutzer-Handbuch (deutsch, vollstaendig)
├── AGENTS.md                             # Diese Datei
└── Modules\
    ├── engine-state.ps1                  # Zentraler State-Store v24 (atomic save/load, migration, backup rotation)
    ├── engine-ui.ps1                     # UI-Framework: Frames, Bars, Animationen, klassisches Input
    ├── engine-render.ps1                 # TUI Render Engine: Double-Buffering, Delta-Render, kein Clear-Host
    ├── engine-scene.ps1                  # TUI Scene Engine: Deklarative Screen-Komposition
    ├── engine-input.ps1                  # TUI Input Engine: Polling-Loop, Mock Input fuer E2E, Game Loop
    ├── engine-game.ps1                   # Game-Mechanics: Karten, Wuerfel, Element-System
    ├── engine-aliases.ps1                # Alias-Wrapper (laedt Sub-Module)
    ├── engine-aliases-git.ps1            # Git-Aliase
    ├── engine-aliases-nav.ps1            # Navigation (z, zi, .., ...)
    ├── engine-aliases-sys.ps1            # System-Aliase (admin, env, path, kill-port)
    ├── engine-aliases-buxe.ps1           # BUXE-Core-Commands (bank, daily, status, ego, capsule)
    ├── boot.ps1                          # Boot-Sequenz mit Session-Tracking
    ├── casino-engine.ps1                 # Shared Casino-Framework (Bets, Bust, Luck)
    ├── casino-blackjack.ps1              # Blackjack (Hit/Stand/Double/Split/Insurance)
    ├── casino-roulette.ps1               # Europaeisches Roulette
    ├── casino-craps.ps1                  # Pass/Don't Pass Craps
    ├── casino-hilo.ps1                   # Higher/Lower mit Multiplier
    ├── casino-baccarat.ps1               # Baccarat mit 3rd-Card-Regeln
    ├── casino-slot.ps1                   # 3-Walzen Slot mit Animation
    ├── casino.ps1                        # Casino Hub Router + Stats
    ├── arcade.ps1                        # Arcade Wrapper (laedt alle Arcade-Submodul)
    ├── arcade-legacy.ps1                 # Zork & Hangman (TUI-migriert)
    ├── arcade-minesweeper.ps1            # Minesweeper 10x10 (TUI, WASD+E/F/Q)
    ├── arcade-monkeytype.ps1             # Monkeytype WPM-Test
    ├── arcade-snake.ps1                  # Snake (TUI)
    ├── arcade-wordle.ps1                 # Wordle
    ├── strategy-poker.ps1                # Texas Hold'em
    ├── strategy-td.ps1                   # Tower Defense (TUI)
    ├── strategy-rogue.ps1                # Dungeon Crawler (TUI)
    ├── fun.ps1                           # TTS-Fallback, APIs, Gags
    ├── handbook.ps1                      # Handbuch-Wrapper (laedt 9 Kapitel)
    ├── handbook-core.ps1                 # Kapitel 1-2: Grundlagen, Navigation
    ├── handbook-casino.ps1               # Kapitel 3: Casino-Mechaniken
    ├── handbook-combat.ps1               # Kapitel 4: Kampf-System
    ├── handbook-companion.ps1            # Kapitel 5: Companion-Guide
    ├── handbook-elements.ps1             # Kapitel 6: Element-Tabelle
    ├── handbook-equipment.ps1            # Kapitel 7: Equipment
    ├── handbook-skills.ps1               # Kapitel 8: Skills & Abilities
    ├── handbook-status.ps1               # Kapitel 9: Status-Effekte
    ├── handbook-commands.ps1             # Komplett-Befehlsliste
    ├── ralph-loop.ps1                    # Kimi CLI Aliase (kimir, kimia, kimix, kimis)
    ├── _smoke_test.ps1                   # Unit/Engine Smoke Test (38 Tests)
    ├── _integration_test.ps1             # Integrationstest (18 Checks)
    ├── _e2e_test.ps1                     # End-to-End Game-Flow Tests (8 Spiele)
    └── pet\                              # PET SYSTEM v2.0 (13 Module)
        ├── _init.ps1                     # State, Schema, Meta-Progression, Feature-Unlocks
        ├── _ui.ps1                       # LucasArts-Style Frames, Dialog-Engine, Easter Eggs
        ├── _unlock.ps1                   # Unlock-Logik fuer Features basierend auf Meta-Level
        ├── companion.ps1                 # Companion Core (5 Girls, Bond, Mood, Actions)
        ├── combat.ps1                    # Battlepet Kampf-Engine (A/V/S RPS-System)
        ├── economy.ps1                   # Shop, Cooking, Buffs
        ├── events.ps1                    # Random Events, Daily Login, Quests
        ├── hub.ps1                       # Pet Hub Router (dynamisches Menu)
        ├── pvp.ps1                       # PvP Arena (Bronze -> Master)
        ├── raid.ps1                      # 3-Phasen Raid (Cyber Golem -> Omega Core)
        ├── rival.ps1                     # Rival-System (taegliche Events)
        ├── breed.ps1                     # Pet Breeding
        └── soul.ps1                      # Soul Link (Endgame-Feature)
```

---

## Technology Stack

| Komponente | Zweck |
|------------|-------|
| PowerShell 7 / 5.1 | Runtime |
| Oh-My-Posh | Prompt-Theming (`buxe.omp.json`) |
| Terminal-Icons | Datei-Icons im Listing |
| PSFzf | Fuzzy Finding |
| Zoxide | Smartes Directory-Jumping |
| System.Speech (.NET) | Lokale TTS (Fallback) |
| edge-tts + ffplay | Erweiterte TTS via Edge |
| Nerd Font (CaskaydiaCove) | Icon-Font fuer Oh-My-Posh |

**Externe APIs** (genutzt in `fun.ps1` und `engine-aliases.ps1`):
- `wttr.in` (Wetter)
- `ipinfo.io` (Public IP)
- `api.chucknorris.io` (Jokes)
- `api.coingecko.com` (Bitcoin-Kurs)
- `icanhazdadjoke.com`, `zenquotes.io`, `api.kanye.rest`, etc.

---

## Module Architecture

### Entry Point (`Microsoft.PowerShell_profile.ps1`)

Laedt externe Module und sourcet alle eigenen Module via Dot-Sourcing in einer festen Reihenfolge:

1. **Engine-Module** (muessen zuerst geladen werden): `engine-state`, `engine-ui`, `engine-render`, `engine-scene`, `engine-input`, `engine-game`, `engine-aliases`
2. **Boot**: `boot.ps1`
3. **Casino-Engine**: `casino-engine.ps1`
4. **Casino-Games** (einzeln): blackjack, roulette, craps, hilo, baccarat, slot
5. **Casino-Router**: `casino.ps1`
6. **Arcade Wrapper**: `arcade.ps1` (laedt alle `arcade-*.ps1` Sub-Module)
7. **Strategy**: `strategy-poker.ps1`, `strategy-td.ps1`, `strategy-rogue.ps1`
8. **Pet System v2.0**: Alle `pet\*.ps1` automatisch per `Get-ChildItem | Sort-Object Name`
9. **Handbuch**: `handbook.ps1` (laedt alle `handbook-*.ps1` Kapitel)
10. **Fun & Misc**: `fun.ps1`, `ralph-loop.ps1`

Am Ende wird `Invoke-BootSequence` aufgerufen.

Jedes Modul ist in einem `try { ... } catch { }` Block gewrappt, damit ein defektes Modul das gesamte Profil nicht zerstoert.

### Core Engine Modules

| Modul | Zweck |
|-------|-------|
| `engine-state.ps1` | Einheitlicher State-Store. Alle Daten in einer JSON-Datei. Automatische Migration v23 -> v24. Export/Import. Corrupt-Backup. Backup-Rotation (5 Backups). |
| `engine-ui.ps1` | `Show-Frame`, `Show-Bar`, `Show-Menu`, `Wait-Enter`, `Read-Choice`, `Read-Bet`, `Confirm-Bust`, `Show-Animation`, `Show-SlotSpin`, `Show-CardHand`, `Show-DiceRoll`, `Clear-Screen`, `Show-Bankroll`, `Show-StatusBar` |
| `engine-render.ps1` | Double-Buffered Rendering. `Show-Buffer`, `Render-SceneDelta`. Kein `Clear-Host` — nur geaenderte Zeilen werden neu geschrieben. |
| `engine-scene.ps1` | Deklarative Scenes. `New-Scene`, `Add-ToScene`, `Show-Scene`. Spiele definieren WAS, nicht WIE. |
| `engine-input.ps1` | `Invoke-GameLoop` (Init/Tick/Render/Cleanup mit FPS), `Read-GameChoice` (Polling-Input), `Enable-MockInput` / `Queue-MockInput` / `Disable-MockInput` (E2E-Testing). |
| `engine-game.ps1` | `New-CardDeck`, `Draw-Card`, `Get-CardValue`, `Get-HandValue`, `Get-BaccaratValue`, `New-DiceRoll`, `Get-ElementModifier`, `Get-CasinoLuckModifier`, `Get-StrategyInsightModifier` |
| `engine-aliases.ps1` | Laedt Sub-Module: `engine-aliases-git.ps1`, `engine-aliases-nav.ps1`, `engine-aliases-sys.ps1`, `engine-aliases-buxe.ps1` |

### TUI Framework (v24.3)

Das TUI-Framework besteht aus drei Engine-Modulen, die zusammenarbeiten:

1. **`engine-scene.ps1`** — Spiele bauen eine Scene als Hashtable von Zeilen:
   ```powershell
   $scene = New-Scene -Width 60 -Height 20
   Add-ToScene $scene 0 0 "TITLE" "Yellow"
   Add-ToScene $scene 2 2 "Health: 100" "Green"
   Show-Scene $scene
   ```

2. **`engine-render.ps1`** — Rendert Scenes mit Double-Buffering. Speichert den vorherigen Frame und schreibt nur Zeilen, die sich geaendert haben (Delta-Render). Vermeidet `Clear-Host`-Flackern.

3. **`engine-input.ps1`** — Polling-basiertes Input-Handling statt blocking `Read-Host`. Unterstuetzt Mock-Input fuer automatisierte E2E-Tests.

**Spiele, die TUI verwenden:** Minesweeper, Snake, Tower Defense, Rogue, Zork, Hangman

### Unified State (`engine-state.ps1`)

Alle Savegame-Daten leben in **einer** Datei:
- `%LOCALAPPDATA%\buxe\buxe_state_v24.json`

Struktur (Hashtable mit Depth 20):
```
Version = 24
Bank = { Gold, CasinoWinnings, CasinoLosses, TotalEarned, TotalSpent, PokerIncome, DailyStreak, LastDaily }
Companion = { ... }
Battlepet = { ... }
Pet = { Meta, Companion, Pet, Economy, Achievements, Memories }
Casino = { Blackjack, Roulette, Craps, HiLo, Baccarat, Slot }
Strategy = { Poker, TowerDefense, Rogue }
Arcade = { MonkeyType, Snake, Wordle, Zork, Hangman, Minesweeper }
Achievements = @{}
Boot = { Loads, TotalCommands, FavoriteCommand, LastBoot }
Capsules = @()
```

**Wichtig**: `Save-State` schreibt atomar (`.tmp` -> `Move-Item`). Bei korruptem JSON wird automatisch ein Backup erstellt und Defaults geladen. Migration von v23 (mehrere JSON-Dateien) zu v24 (unified) geschieht automatisch beim ersten Start.

**Backup-Rotation**: `Save-State` behaelt 5 rotierende Backups (`.bak1` bis `.bak5`). Die aktuelle Datei wird vor dem Speichern nach `.bak1` kopiert, aeltere Backups werden kaskadiert.

### Pet System v2.0 (`Modules/pet/`)

Das Pet System ist in 13 Sub-Module aufgeteilt, die automatisch geladen werden:

| Modul | Zweck |
|-------|-------|
| `_init.ps1` | State-Defaults, XP-Tabelle, Feature-Unlocks per Meta-Level (0-10) |
| `_ui.ps1` | LucasArts-Style Unicode-Frames, Companion-Dialoge mit Typewriter-Effekt, Easter-Egg-Engine |
| `_unlock.ps1` | Feature-Freischaltung basierend auf `PetFeatureUnlocks` |
| `companion.ps1` | 5 Girls (NEON, RAVEN, PIXEL, LUNA, IVY), Bond-System (0-100), Mood-System, Actions (talk/gift/date/work/train/punish/headpat) |
| `combat.ps1` | 5 Starter-Pets, 8 Enemy-Typen, A/V/S Rock-Paper-Scissors Kampf, Element-Modifier, Boss-Kaempfe (jeder 5. Sieg) |
| `economy.ps1` | Schwarzmarkt-Shop (Chips/Armor/Accessory), Cooking (Ramen, Energy Drink, Sushi, Curry) |
| `events.ps1` | Random Events, Daily Login, Quests, Memory-System |
| `hub.ps1` | Zentraler `pet` Command Router mit dynamischem Menu (nur freigeschaltete Features werden angezeigt) |
| `pvp.ps1` | PvP Arena mit 6 Ranks (Bronze -> Master), Punkte-System |
| `raid.ps1` | Taeglicher 3-Phasen-Raid (Cyber Golem, Net Titan, Omega Core), Raid-Tokens, Companion-Sync-Boni |
| `rival.ps1` | Taeglicher Rival (20% Chance), 3-Runden-Kampf |
| `breed.ps1` | Pet Breeding (ab Meta-Level 7) |
| `soul.ps1` | Soul Link (ab Meta-Level 9, Endgame-Feature) |

**Meta-Progression**: Das Pet System hat ein eigenes Level-System (0-10) basierend auf XP. Jedes Level schaltet neue Features frei:
- Lv 0: talk, companion_create
- Lv 1: gift, mood
- Lv 2: pet_create, combat
- Lv 3: train, work, gold
- Lv 4: shop, cooking, equipment
- Lv 5: pvp
- Lv 6: raid
- Lv 7: breed
- Lv 8: rival
- Lv 9: soul_link
- Lv 10: architect

### Casino Framework (`casino-engine.ps1`)

`Invoke-CasinoGame` ist ein generischer Wrapper fuer alle Casino-Spiele:
- Parametrisiert mit `$GameName` und `$PlayRound` (ScriptBlock)
- Automatische Bust-Behandlung (0 Gold -> Reset auf 100G)
- Casino-Luck-Modifier (Companion Skill)
- Automatische Bank-Updates mit TrackCasino
- Companion-Reaktionen auf grosse Gewinne/Verluste
- Achievement-Unlocks

### TTS-System (im Hauptprofil)

Das TTS-System lebt direkt im `Microsoft.PowerShell_profile.ps1` (nicht in `fun.ps1`):
- `Show-Voices` / `voices` — Zeigt alle verfuegbaren Stimmen
- `Set-Voice EN|ML <Num>` / `svoice` — Waehlt eine Stimme
- `Say 'Text' [-Wait]` — Spricht Text mit edge-tts + ffplay
- `Clip-Say` — Liest Zwischenablage vor
- Stimmen werden in `$env:USERPROFILE\.kimi\tts-config.json` persistiert

---

## Data Persistence

| Datei | Inhalt |
|-------|--------|
| `%LOCALAPPDATA%\buxe\buxe_state_v24.json` | Unified State (Bank, Companion, Battlepet, Pet, Casino, Strategy, Arcade, Achievements, Boot, Capsules) |
| `%LOCALAPPDATA%\buxe\buxe_state_v24.json.bak1` bis `.bak5` | Rotierende Auto-Backups |
| `%LOCALAPPDATA%\buxe\v23_archive\` | Archivierte alte v23 JSON-Dateien nach Migration |
| `%LOCALAPPDATA%\buxe\buxe_export_*.json` | Manuelle Export-Backups |
| `%USERPROFILE%\.kimi\tts-config.json` | TTS-Stimmen-Einstellung |

**State-Accessors** (aus `engine-state.ps1`):
- `Get-Bankroll`, `Set-Bankroll`, `Add-Gold`, `Spend-Gold`
- `Load-CompanionState`, `Save-CompanionState`
- `Load-BattlepetState`, `Save-BattlepetState`
- `Get-CasinoStats`, `Set-CasinoStats`
- `Get-StrategyStats`, `Set-StrategyStats`
- `Get-ArcadeStats`, `Set-ArcadeStats`
- `Unlock-Achievement`
- `Export-State`, `Import-State`

---

## Build and Test Commands

### Profil neu laden
```powershell
reload
```

### Profil bearbeiten
```powershell
profile   # oeffnet Notepad mit dem Hauptprofil
```

### Smoke Test (Unit/Engine)
```powershell
& "$PSScriptRoot\Modules\_smoke_test.ps1"
```

Testet (38 Tests):
- State Defaults (Version 24, Bank, Casino)
- Kartendeck-Generatoren (52 Karten)
- Hand-Evaluation (Blackjack 21, Baccarat 7)
- Wuerfel-Engine
- Element-Modifier (Fire vs Ice = 1.5x)
- UI Framework (Show-Bar Laenge)
- Pet System v2.0 (Get-PetState, Get-EffectiveStats, Show-PetFrame)
- State Accessors (Get-Bankroll, Load-State)
- Modul-Ladevorgang (alle Module inkl. Pet System)
- Backup-Rotation

### Integration Test
```powershell
& "$PSScriptRoot\Modules\_integration_test.ps1"
```

Testet (18 Checks):
- Gold-Transaktionen (Add-Gold, Spend-Gold Roundtrip)
- State Persistence (Save-State, Datei-Existenz)
- Keine duplizierten Funktionen in Produktionsmodulen (AST-Check)
- Keine konfliktbehafteten `script:`-Variablen zwischen Modulen (AST-Check)
- Handbook-Funktionen
- Pet Shop-Items und Effective-Stats-Berechnung

### End-to-End Test
```powershell
& "$PSScriptRoot\Modules\_e2e_test.ps1"
```

Testet (8 Game-Flows):
- Komplettes Laden des Profils (`Microsoft.PowerShell_profile.ps1`)
- Verfuegbarkeit aller 35 required Functions
- State-File Existenz und Groesse
- `SessionStart` wurde gesetzt
- **Game-Flows** (automatisiert mit Mock-Input):
  - Zork (`Q`)
  - Rogue (`Q`)
  - Hi-Lo (`C` zum Cashout)
  - Slot (`space` zum Spin)
  - Minesweeper (`Q`)
  - Blackjack (`Q`)
  - Poker (`F` zum Fold)
  - Tower Defense (`Q`)

### Manuelles Modul-Reload
```powershell
# Einzelne Engine-Module neu laden:
. $PROFILE\..\modules\engine-state.ps1
```

---

## Code Style Guidelines

### Sprache
- **Kommentare und Dokumentation**: Deutsch
- **Funktions-/Variablennamen**: Englisch (PascalCase fuer Funktionen, camelCase fuer Variablen)
- **User-facing Output**: Deutsch (mit Ausnahme einiger API-Rueckgaben)

### Datei-Header
Jede Datei beginnt mit einer Versionszeile:
```powershell
# BUXE_OS v24.3 -- MODULNAME
```

### Error Handling
Jedes Modul muss in einem `try { ... } catch { }` Block stehen, damit ein einzelner Syntaxfehler nicht das gesamte Profil zerstoert.

### Non-Interactive Shell Hardening
Alle `[Console]::CursorPosition`, `[Console]::CursorVisible`, `Clear-Host`, und `$Host.UI.RawUI.CursorPosition` Zugriffe muessen in `try/catch {}` gewrappt sein. In headless/E2E-Kontexten (z.B. GitHub Actions, automatisierte Tests) werfen diese Aufrufe "Das Handle ist ungueltig".

### State-Mutation
- State wird ausschliesslich in `$script:`-Scoped Variablen gehalten
- Keine globale `$global:`-Variablen verwenden
- Save-Funktionen schreiben sofort nach `$script:BuxeStateDir`
- Das Pet System verwendet `Get-PetState` / `Save-PetState` als Abstraktion

### UI-Konventionen
- `Clear-Host` vor jedem interaktiven Screen (oder `Clear-Screen` Wrapper)
- `Write-Host` mit `-ForegroundColor` fuer farbige Ausgabe
- `Show-Frame` / `Show-PetFrame` fuer Ueberschriften
- `Wait-Enter` am Ende jedes interaktiven Flows
- `[Q]` als universelles Quit/Back
- `[1-9]` als Menue-Optionen
- Companion-Dialoge nutzen `Show-CompanionDialog` mit Typewriter-Effekt
- **TUI-Spiele** nutzen `New-Scene` + `Show-Scene` statt direktem `Write-Host`

### Zahlenformatierung
- Gold wird immer als Ganzzahl angezeigt (keine Dezimalstellen)
- Prozentbalken nutzen `Show-Bar` (20 Zeichen Standard, Style: Classic/Retro/Minimal)
- Zeitstempel: `yyyy-MM-dd HH:mm`

### Encoding
- BUXE_OS v24 verwendet **reines ASCII** in allen Engine- und Casino-Modulen
- Keine Umlaute, keine Emojis, keine Box-Drawing-Chars in den Engine-Modulen
- `pet/_ui.ps1` verwendet Unicode-Box-Drawing fuer LucasArts-Style Frames (Ausnahme)
- TUI-Module (`engine-render.ps1`, `engine-scene.ps1`) verwenden ASCII-Zeichen fuer Rahmen

---

## Testing Instructions

1. **Nach jeder Aenderung** das Profil mit `reload` neu laden
2. **Smoke Test** ausfuehren: `& .\Modules\_smoke_test.ps1`
3. **Integration Test** ausfuehren: `& .\Modules\_integration_test.ps1`
4. **E2E Test** ausfuehren: `& .\Modules\_e2e_test.ps1`
5. **Manuelle Tests**: Einzelne Spiele starten und `[Q]` druecken (Quit-Pfad-Test)
6. **Corrupt-JSON-Test**: Die State-Datei mit ungueltigem JSON fuellen und pruefen, ob das Backup erstellt wird

---

## Security Considerations

### Browser-History-Zugriff
`companion.ps1` (v23, archiviert) konnte bei 3+ Verlusten in Folge die Browser-History von Chrome, Edge und Firefox lesen. In v24 wurde dieses Feature **entfernt**. Das Pet System greift nicht auf Browser-Daten zu.

### TTS-System
- `Say` nutzt `edge-tts` (externes Python-Tool) und `ffplay` (FFmpeg)
- `stop-say` terminiert diese Prozesse via `Stop-Process`
- Temp-Dateien werden automatisch nach dem Abspielen geloescht

### Clipboard
`clip-say` liest die Zwischenablage (`Get-Clipboard`) und gibt sie als TTS aus. Keine Daten werden uebertragen.

### Keine Code-Signing
Das Profil ist unsigniertes PowerShell-Skript. Es laeuft im FullLanguage-Modus des Benutzers.

### API-Keys
Keine API-Keys erforderlich. Alle genutzten APIs sind oeffentlich und keylos.

---

## Adding New Features

1. **Neues Modul**: `.ps1`-Datei in `Modules\` (oder `Modules\pet\`) erstellen und in `Microsoft.PowerShell_profile.ps1` eintragen
2. **Neue Commands**: In das passende Modul einfuegen (siehe GUIDE.md fuer Kategorien)
3. **Neue Persistenz**: Im `Get-StateDefaults` von `engine-state.ps1` registrieren
4. **Neue Achievements**: `Unlock-Achievement "Name"` aufrufen; die Unlock-Logik prueft automatisch auf Duplikate
5. **UI**: `Show-Frame`, `Show-Bar`, `Wait-Enter` verwenden
6. **TUI-Spiel**: `New-Scene`, `Add-ToScene`, `Show-Scene` verwenden; Input via `Read-GameChoice`
7. **Pet Features**: In `Get-PetDefaults` und `PetFeatureUnlocks` registrieren, dann im Hub freischalten
8. **E2E-Test**: Game-Flow in `_e2e_test.ps1` mit `Enable-MockInput` + `Queue-MockInput` hinzufuegen

---

## Key Files for Agents

| Datei | Warum wichtig |
|-------|---------------|
| `Microsoft.PowerShell_profile.ps1` | Entry point, Modul-Loader, TTS-System |
| `Modules/engine-state.ps1` | Zentraler State-Store, Migration, Export/Import, Backup-Rotation |
| `Modules/engine-ui.ps1` | UI-Framework fuer ALLE interaktiven Module |
| `Modules/engine-render.ps1` | TUI Render Engine (Double-Buffering, Delta-Render) |
| `Modules/engine-scene.ps1` | TUI Scene Engine (Deklarative Screens) |
| `Modules/engine-input.ps1` | Game Loop, Polling Input, Mock Input fuer E2E |
| `Modules/engine-game.ps1` | Karten, Wuerfel, Element-System |
| `Modules/engine-aliases.ps1` | Alle Terminal-Commands, Git, System, Bank |
| `Modules/casino-engine.ps1` | Shared Casino-Wrapper |
| `Modules/arcade-minesweeper.ps1` | Neuestes TUI-Spiel (Referenz-Implementierung) |
| `Modules/pet/_init.ps1` | Pet System Schema und Meta-Progression |
| `Modules/pet/hub.ps1` | Pet Hub Router mit dynamischem Menu |
| `Modules/pet/companion.ps1` | Companion-Datenmodell und Actions |
| `Modules/pet/combat.ps1` | Battlepet Kampf-Engine |
| `Modules/handbook.ps1` | Vollstaendige Spiele-Mechanik-Doku |
| `Modules/_smoke_test.ps1` | Regressionstests fuer Engines |
| `Modules/_integration_test.ps1` | AST-basierte Checks auf Duplikate/Konflikte |
| `Modules/_e2e_test.ps1` | Automatisierte Game-Flow Tests |
| `GUIDE.md` | Vollstaendige Feature-Liste fuer Endbenutzer |

---

## Version History Convention

Versionen werden in Datei-Headern und der Boot-Sequence angezeigt:
- Hauptprofil: v24.3
- Pet System: v24.2
- Module tragen ihre eigene Versionsnummer im Header
- Die `status`-Funktion zeigt die aktuelle Version an
- State-Version ist im JSON als `Version = 24` gespeichert
