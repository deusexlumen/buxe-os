# BUXE_OS - Agent Guide

> Dieses Dokument ist fuer AI-Coding-Agenten bestimmt. Es beschreibt die Architektur, Konventionen und Regeln dieses Projekts.

---

## Project Overview

**BUXE_OS** ist ein hochgradig personalisiertes PowerShell-Profil-System fuer Windows. Es wird als "Betriebssystem" fuer die Shell bezeichnet und enthaelt dutzende interaktive Features: Arcade-Spiele, Casino-Suite, RPG-Systeme (Companion + Battlepet), Text-Adventure, Desktop-Pet, Git-Aliase, Navigation-Shortcuts, TTS, API-Integrationen und einen selbstbewussten Boot-Sequence.

- **Sprache**: PowerShell 7/5.1-kompatibel
- **Hauptsprache der Doku/Kommentare**: Deutsch
- **Profil-Pfad**: `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- **Modul-Pfad**: `%USERPROFILE%\Documents\PowerShell\Modules\`
- **Daten-Persistenz**: `%LOCALAPPDATA%\buxe\buxe_state_v24.json` (unified JSON)
- **Module**: 57 Produktions-Dateien in `Modules\` plus 13 Dateien in `Modules\pet\` = 70 Produktions-Module (73 .ps1-Dateien inkl. 3 Test-Dateien)

---

## Project Structure

```
Documents\PowerShell\
├── Microsoft.PowerShell_profile.ps1      # Entry point (~277 Zeilen), TTS-System
├── buxe.omp.json                         # Oh-My-Posh Theme (JSON-Schema v2)
├── achievements.json                     # Legacy-Achievement-Datei (nicht mehr aktiv)
├── GUIDE.md                              # Benutzer-Handbuch (deutsch, vollstaendig)
├── GUIDE_v23.md                          # Legacy-Handbuch v23
├── LUCASARTS.md                          # Design-Regeln fuer Companion-Dialoge
├── AGENTS.md                             # Diese Datei
├── SESSION_NOTES.md                      # Session-Notizen fuer LYRA/Memory
├── docs\                                 # Dokumentation und Spezifikationen
│   └── superpowers\                      # Plaene und Specs fuer Features
│       ├── plans\                        # z.B. Anti-Grind-Tutorial-Plan
│       └── specs\                        # z.B. Pet-Tutorial-Design-Spec
└── Modules\
    ├── engine-state-core.ps1             # State-Core: Defaults, Save/Load, Accessors, Audit
    ├── engine-state-migration.ps1        # State-Migration: v23->v24, Export/Import
    ├── engine-state-advanced.ps1         # State-Advanced: Transactions
    ├── engine-ui.ps1                     # UI-Framework: Frames, Bars, Animationen, klassisches Input
    ├── engine-render.ps1                 # TUI Render Engine: Double-Buffering, Delta-Render, kein Clear-Host
    ├── engine-scene.ps1                  # TUI Scene Engine: Deklarative Screen-Komposition
    ├── engine-input.ps1                  # TUI Input Engine: Polling-Loop, Mock Input fuer E2E, Game Loop
    ├── engine-game.ps1                   # Game-Mechanics: Karten, Wuerfel, Element-System
    ├── engine-aliases.ps1                # Alias-Wrapper (laedt Sub-Module)
    ├── engine-aliases-git.ps1            # Git-Aliase
    ├── engine-aliases-nav.ps1            # Navigation (z, zi, .., ...)
    ├── engine-aliases-sys.ps1            # System-Aliase (admin, env, path, kill-port)
    ├── engine-aliases-pnpm.ps1           # PNPM-Aliase (p, pi, ps, pb, pd, pt, ...)
    ├── engine-aliases-buxe.ps1           # BUXE-Core-Commands (bank, daily, status, ego, capsule)
    ├── boot.ps1                          # Boot-Sequenz mit Session-Tracking
    ├── casino-engine.ps1                 # Shared Casino-Framework (Bets, Bust, Luck)
    ├── casino-blackjack.ps1              # Blackjack (Hit/Stand/Double/Split/Insurance)
    ├── casino-roulette.ps1               # Europaeisches Roulette
    ├── casino-craps.ps1                  # Pass/Don't Pass Craps
    ├── casino-hilo.ps1                   # Higher/Lower mit Multiplier
    ├── casino-baccarat.ps1               # Baccarat mit 3rd-Card-Regeln
    ├── casino-slot.ps1                   # 3-Walzen Slot mit Animation
    ├── casino-keno.ps1                   # Keno (Lotto-Style)
    ├── casino-wheel.ps1                  # Wheel of Fortune
    ├── casino.ps1                        # Casino Hub Router + Stats
    ├── arcade.ps1                        # Arcade Wrapper (laedt alle Arcade-Submodul)
    ├── arcade-legacy.ps1                 # Zork & Hangman (TUI-migriert)
    ├── arcade-minesweeper.ps1            # Minesweeper 10x10 (TUI, WASD+E/F/Q)
    ├── arcade-tetris.ps1                 # Tetris (TUI, WASD+Q)
    ├── arcade-monkeytype.ps1             # Monkeytype WPM-Test
    ├── arcade-snake.ps1                  # Snake (TUI)
    ├── arcade-wordle.ps1                 # Wordle
    ├── arcade-breakout.ps1               # Breakout (TUI)
    ├── arcade-2048.ps1                   # 2048 Puzzle
    ├── arcade-dino.ps1                   # Dino Jump
    ├── arcade-memory.ps1                 # Memory Match
    ├── strategy-poker.ps1                # Texas Hold'em
    ├── strategy-td.ps1                   # Tower Defense (TUI)
    ├── strategy-rogue.ps1                # Dungeon Crawler (TUI)
    ├── adventure-engine.ps1              # Parser-basierte Adventure-Engine (Room, Inventory, Parser)
    ├── adventure-world.ps1               # Adventure-Welt (16 Raeume, Objekte, NPCs)
    ├── adventure-companion-ai.ps1        # Adventure Companion AI (Mood, Running Gags, Easter Eggs)
    ├── adventure.ps1                     # Adventure Main Router
    ├── adventure-insult.ps1              # Insult Swordfighting (29 Paare)
    ├── desktop-pet.ps1                   # Desktop Pet (Prompt-Override, Command-Comments)
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
    ├── _smoke_test.ps1                   # Unit/Engine Smoke Test
    ├── _integration_test.ps1             # Integrationstest (AST-Checks, State, Duplikate)
    ├── _e2e_test.ps1                     # End-to-End Game-Flow Tests
    └── pet\                              # PET SYSTEM v2.0 (13 Module)
        ├── _init.ps1                     # State, Schema, Meta-Progression, Feature-Unlocks
        ├── _ui.ps1                       # LucasArts-Style Frames, Dialog-Engine, Easter Eggs
        ├── _unlock.ps1                   # Unlock-Logik fuer Features basierend auf Meta-Level
        ├── companion.ps1                 # Companion Core (7 Girls, Bond, Mood, Actions)
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
| edge-tts + ffplay | Erweiterte TTS via Edge (primary) |
| System.Speech (.NET) | Lokale TTS (Fallback, nicht aktiv) |
| Nerd Font (CaskaydiaCove) | Icon-Font fuer Oh-My-Posh |

**Externe APIs** (genutzt in `fun.ps1` und `engine-aliases.ps1`):
- `wttr.in` (Wetter, HTTPS)
- `ip` zeigt lokale IPv4 (kein externer API-Call mehr)
- `api.chucknorris.io` (Jokes)
- `api.coingecko.com` (Bitcoin-Kurs)
- `icanhazdadjoke.com`, `zenquotes.io`, `api.kanye.rest`, etc.

---

## Module Architecture

### Entry Point (`Microsoft.PowerShell_profile.ps1`)

Laedt externe Module und sourcet alle eigenen Module via Dot-Sourcing in einer festen Reihenfolge:

1. **Engine-Module** (muessen zuerst geladen werden): `engine-state-core`, `engine-state-migration`, `engine-state-advanced`
2. **State laden**: `Load-State`
3. **Weitere Engine-Module**: `engine-ui`, `engine-game`, `engine-render`, `engine-input`, `engine-scene`, `engine-aliases`
4. **Boot**: `boot.ps1`
5. **Casino-Engine**: `casino-engine.ps1`
6. **Casino-Games** (einzeln): blackjack, roulette, craps, hilo, baccarat, slot, keno, wheel
7. **Casino-Router**: `casino.ps1`
8. **Arcade Wrapper**: `arcade.ps1` (laedt alle `arcade-*.ps1` Sub-Module)
9. **Strategy**: `strategy-poker.ps1`, `strategy-td.ps1`, `strategy-rogue.ps1`
10. **Adventure System**: `adventure-engine.ps1`, `adventure-world.ps1`, `adventure-companion-ai.ps1`, `adventure.ps1`, `adventure-insult.ps1`
11. **Desktop Pet**: `desktop-pet.ps1`
12. **Pet System v2.0**: Alle `pet\*.ps1` automatisch per `Get-ChildItem | Sort-Object Name`
13. **Handbuch**: `handbook.ps1` (laedt alle `handbook-*.ps1` Kapitel)
14. **Fun & Misc**: `fun.ps1`

Am Ende wird `Invoke-BootSequence` aufgerufen.

Jedes Modul ist in einem `try { ... } catch { }` Block gewrappt, damit ein defektes Modul das gesamte Profil nicht zerstoert.

### Core Engine Modules

| Modul | Zweck |
|-------|-------|
| `engine-state-core.ps1` | State-Defaults, Save/Load, Backup-Rotation, Accessors, Audit-Log. |
| `engine-state-migration.ps1` | v23 -> v24 Migration, Export/Import. |
| `engine-state-advanced.ps1` | State-Transaktionen (Start/Complete/Rollback). |
| `engine-ui.ps1` | `Show-Frame`, `Show-Bar`, `Show-Menu`, `Wait-Enter`, `Read-Choice`, `Read-Bet`, `Confirm-Bust`, `Clear-Screen`, `Show-Bankroll` |
| `engine-render.ps1` | Double-Buffered Rendering. `Show-Buffer`, `Render-SceneDelta`. Kein `Clear-Host` — nur geaenderte Zeilen werden neu geschrieben. |
| `engine-scene.ps1` | Deklarative Scenes. `New-Scene`, `Add-ToScene`, `Show-Scene`. Spiele definieren WAS, nicht WIE. |
| `engine-input.ps1` | `Invoke-GameLoop` (Init/Tick/Render/Cleanup mit FPS), `Read-GameChoice` (Polling-Input), `Enable-MockInput` / `Queue-MockInput` / `Disable-MockInput` (E2E-Testing). |
| `engine-game.ps1` | `New-CardDeck`, `Draw-Card`, `Get-CardValue`, `Get-HandValue`, `Get-BaccaratValue`, `New-DiceRoll`, `Get-ElementModifier`, `Get-CasinoLuckModifier`, `Get-StrategyInsightModifier` |
| `engine-aliases.ps1` | Laedt Sub-Module: `engine-aliases-git.ps1`, `engine-aliases-nav.ps1`, `engine-aliases-pnpm.ps1`, `engine-aliases-sys.ps1`, `engine-aliases-buxe.ps1` |

### TUI Framework (v24.4)

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

**Spiele, die TUI verwenden:** Minesweeper, Snake, Tower Defense, Rogue, Zork, Hangman, Tetris, Breakout

### Unified State (`engine-state-core.ps1`)

Alle Savegame-Daten leben in **einer** Datei:
- `%LOCALAPPDATA%\buxe\buxe_state_v24.json`

Struktur (Hashtable mit Depth 20):
```
Version = 24
Bank = { Gold, CasinoWinnings, CasinoLosses, TotalEarned, TotalSpent, PokerIncome, DailyStreak, LastDaily }
Companion = { ... }
Battlepet = { ... }
Pet = { Meta, Companion, Pet, Economy, Achievements, Memories, Tutorial }
Casino = { Blackjack, Roulette, Craps, HiLo, Baccarat, Slot, Keno, Wheel }
Strategy = { Poker, TowerDefense, Rogue }
Arcade = { MonkeyType, Snake, Wordle, Zork, Hangman, Minesweeper, Tetris, Breakout, Game2048, DinoJump, MemoryMatch }
Achievements = @{}
Story = @{}
Boot = { Loads, TotalCommands, FavoriteCommand, LastBoot }
Capsules = @()
```

**Wichtig**: `Save-State` schreibt atomar (`.tmp` -> `Move-Item`). Bei korruptem JSON wird automatisch ein Backup erstellt und Defaults geladen. Migration von v23 (mehrere JSON-Dateien) zu v24 (unified) geschieht automatisch beim ersten Start.

**Backup-Rotation**: `Save-State` behaelt 5 rotierende Backups (`.bak1` bis `.bak5`). Die aktuelle Datei wird vor dem Speichern nach `.bak1` kopiert, aeltere Backups werden kaskadiert.

### Adventure System (`Modules/adventure-*.ps1`)

Ein parser-basiertes Text-Adventure im LucasArts-Stil mit eigenem State-File:
- **State**: `%LOCALAPPDATA%\buxe\buxe_adventure.json` (separat vom Haupt-State)
- **Engine**: `adventure-engine.ps1` — Room-System, Inventory, Kommandoparser (Verb/Noun), Use-Handler, Oxygen-System, Hack-Command
- **Welt**: `adventure-world.ps1` — 16 Raeume (Hangar, Corridor, Bridge, EVA, Core, Airlock, Engine, Medbay, Armory, Quarters, Observatory, Cafeteria, Vent, Secret, Lab, Server), Objekte, Exits, Flags
- **Companion AI**: `adventure-companion-ai.ps1` — Mood-System (Curious/Excited/Bored/Scared), Running Gags (3x gleiche Aktion = Witz), Absurd-Combos, JINX (Jester-Companion)
- **Insult Swordfighting**: `adventure-insult.ps1` — 29 Insult/Comeback-Paare im Monkey-Island-Stil
- **Commands**: `adv` startet das Adventure, `insult` startet Schwertkampf

### Desktop Pet (`Modules/desktop-pet.ps1`)

Companion kommentiert Shell-Befehle in Echtzeit via Prompt-Override.
- **Command Database**: Regex-Pattern -> zufaellige Sprueche (Git, npm, Docker, rm, etc.)
- **Aktivierung**: Opt-in via `dp-on`. Kein Auto-Install mehr (entfernt in v24.2 wegen Prompt-Latency).
- **Deaktivierung**: `dp-off`

### Pet System v2.0 (`Modules/pet/`)

Das Pet System ist in 13 Sub-Module aufgeteilt, die automatisch geladen werden:

| Modul | Zweck |
|-------|-------|
| `_init.ps1` | State-Defaults, XP-Tabelle, Feature-Unlocks per Meta-Level (0-10), Tutorial-System |
| `_ui.ps1` | LucasArts-Style Unicode-Frames, Companion-Dialoge mit Typewriter-Effekt, Easter-Egg-Engine |
| `_unlock.ps1` | Feature-Freischaltung basierend auf `PetFeatureUnlocks` |
| `companion.ps1` | 7 Girls (NEON, RAVEN, PIXEL, LUNA, IVY, VERA, JINX), Bond-System (0-100), Mood-System, Actions (talk/gift/date/work/train/punish/headpat) |
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

**Tutorial**: Seit v24.5 gibt es ein interaktives Tutorial (`Invoke-PetTutorial`, `Get-TutorialLines`) fuer neue Spieler. Es fuehrt durch Companion-Erstellung, ersten Kampf und Shop. Kann uebersprungen werden.

### Casino Framework (`casino-engine.ps1`)

`Invoke-CasinoGame` ist ein generischer Wrapper fuer alle Casino-Spiele:
- Parametrisiert mit `$GameName` und `$PlayRound` (ScriptBlock)
- Automatische Bust-Behandlung (0 Gold -> Reset auf 100G)
- Casino-Luck-Modifier (Companion Skill)
- Automatische Bank-Updates mit TrackCasino
- Companion-Reaktionen auf grosse Gewinne/Verluste
- Achievement-Unlocks

**Casino-Spiele**: Blackjack, Roulette, Craps, Hi-Lo, Baccarat, Slot, Keno, Wheel of Fortune

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
| `%LOCALAPPDATA%\buxe\buxe_state_v24.json` | Unified State (Bank, Companion, Battlepet, Pet, Casino, Strategy, Arcade, Achievements, Boot, Capsules, Story) |
| `%LOCALAPPDATA%\buxe\buxe_state_v24.json.bak1` bis `.bak5` | Rotierende Auto-Backups |
| `%LOCALAPPDATA%\buxe\buxe_adventure.json` | Adventure Savegame (separater State) |
| `%LOCALAPPDATA%\buxe\v23_archive\` | Archivierte alte v23 JSON-Dateien nach Migration |
| `%LOCALAPPDATA%\buxe\buxe_export_*.json` | Manuelle Export-Backups |
| `%USERPROFILE%\.kimi\tts-config.json` | TTS-Stimmen-Einstellung |

**State-Accessors** (aus `engine-state-core.ps1`):
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

Testet ca. 65+ Checks:
- State Defaults (Version 24, Bank, Casino inkl. Keno/Wheel)
- Kartendeck-Generatoren (52 Karten)
- Hand-Evaluation (Blackjack 21, Baccarat 7)
- Wuerfel-Engine
- Element-Modifier (Fire vs Ice = 1.5x)
- UI Framework (Show-Bar Laenge)
- Pet System v2.0 (Get-PetState, Get-EffectiveStats, Show-PetFrame, Tutorial-System)
- State Accessors (Get-Bankroll, Load-State)
- State Transactions (Start/Rollback/Complete)
- Corrupt JSON Recovery (Backup + Defaults)
- Adventure Engine (Parser, Inventory, Rooms, Companion AI, EVA-Tod, Oxygen, Hack)
- Tetris Engine (Collision, Lock, Line-Clear)
- Breakout Engine (Bricks, Collision, Score)
- Desktop Pet (Command Comments)
- Insult Swordfighting (Pairs, State)
- Backup-Rotation (5 Backups)
- Modul-Ladevorgang (alle Module inkl. Pet System, Keno, Wheel)

### Integration Test
```powershell
& "$PSScriptRoot\Modules\_integration_test.ps1"
```

Testet 30 Checks:
- State Defaults v24
- Gold-Transaktionen (Add-Gold, Spend-Gold Roundtrip)
- UI Framework (Show-Bar)
- Game Engine (Deck, Blackjack-Wert)
- Element-Modifier
- Pet System v2.0 (State, Defaults, Tutorial, XP-Tabelle, Effective-Stats)
- Required Functions (ca. 35 Commands)
- State Persistence (Save-State, Datei-Existenz)
- Keine duplizierten Funktionen in Produktionsmodulen (AST-Check)
- Keine konfliktbehafteten `script:`-Variablen zwischen Modulen (AST-Check)
- Handbook-Funktionen
- Pet Shop-Items und Hub
- Tutorial-Dialoge und Tutorial-Fight
- Adventure Engine (Parser-Coverage, State-Roundtrip, Room-Connectivity, 16 Raeume)
- Companion AI (State, Running Gags, Absurd-Combos, Mood-Transitions)
- Sauerstoff-System
- EVA-Tod ohne Suit
- True-Ending-Flag
- JINX Companion (7 Companions total)
- LucasArts Easter Eggs (Rubber Chicken, Skull, Tree)
- Insult Swordfighting (29 Paare, valid Structure)
- Desktop Pet (Comment Generation)

### End-to-End Test
```powershell
& "$PSScriptRoot\Modules\_e2e_test.ps1"
```

Testet das komplette Profil plus 17+ Game-Flows:
- Komplettes Laden des Profils (`Microsoft.PowerShell_profile.ps1`)
- Verfuegbarkeit aller required Functions (status, bank, pet, blackjack, keno, wheel, etc.)
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
  - Roulette (Rot/Schwarz + `Q`)
  - Craps (Pass + `Q`)
  - Baccarat (Banker + `Q`)
  - Snake (`Q`)
  - Wordle (`Q` auf erstem Guess)
  - Monkeytype (`Q` auf Pre-Game)
  - Tetris (`Q` auf Start-Screen)
  - Breakout (`Q`)
  - Adventure (`quit`)
  - Insult Swordfighting (`q`)
- JINX Companion existiert
- 29 Insult-Paare sind geladen

### Manuelles Modul-Reload
```powershell
# Einzelne Engine-Module neu laden:
. $PROFILE\..\modules\engine-state-core.ps1
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
# BUXE_OS v24.4 -- MODULNAME
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
- Das Adventure System verwendet `Get-AdventureDefaults` / `Load-AdventureState` / `Save-AdventureState`

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
- **Engine-Module** (`engine-*.ps1`, `casino-engine.ps1`) verwenden **reines ASCII** ohne Umlaute, Emojis oder Box-Drawing-Chars
- **Game-Module** (Arcade, Strategy, Adventure, Desktop-Pet) duerfen **UTF-8** mit deutschen Umlauten in User-facing Strings verwenden
- `pet/_ui.ps1` verwendet Unicode-Box-Drawing fuer LucasArts-Style Frames (Ausnahme)
- TUI-Module (`engine-render.ps1`, `engine-scene.ps1`) verwenden ASCII-Zeichen fuer Rahmen

### LucasArts Design Philosophy (PROJECT-WIDE)
ALL user-facing text in BUXE_OS — especially companion dialogs, random events, arcade flavor text, casino commentary, and boot messages — MUST follow the LucasArts adventure design rules documented in [`LUCASARTS.md`](./LUCASARTS.md).

Before writing any user-facing text, read `LUCASARTS.md`. The core rules are:
1. **Self-aware** — characters know they are code in a PowerShell session
2. **Fourth-wall breaks** — speak to the User directly, reference buttons and commands
3. **No generic text** — every line must have a specific voice and observation
4. **Character voice is everything** — each NPC/companion has an immutable, distinct voice
5. **Humor over drama** — even "sad" moments are played for laughs
6. **The 47 Rule** — running gag, used sparingly but consistently
7. **No game over** — wrong choices end humorously, never punishingly

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

### Prompt-Function Override (Desktop Pet)
`desktop-pet.ps1` ueberschreibt die PowerShell-`prompt`-Funktion, um Befehle zu intercepten und Companion-Kommentare auszugeben. Dies ist lokal und sendet keine Daten nach aussen, aber es modifiziert das Shell-Verhalten global. Seit v24.2 ist der Desktop Pet **opt-in** (`dp-on` / `dp-off`).

### TTS-System
- `Say` nutzt `edge-tts` (externes Python-Tool) und `ffplay` (FFmpeg)
- `stop-say` terminiert diese Prozesse via `Stop-Process`
- Temp-Dateien werden automatisch nach dem Abspielen geloescht

### Clipboard
`clip-say` liest die Zwischenablage (`Get-Clipboard`) und gibt sie als TTS aus.

### Keine Code-Signing
Das Profil ist unsigniertes PowerShell-Skript. Es laeuft im FullLanguage-Modus des Benutzers.

### API-Keys
Keine API-Keys erforderlich. Alle genutzten APIs sind oeffentlich und keylos.

---

## Adding New Features

1. **Neues Modul**: `.ps1`-Datei in `Modules\` (oder `Modules\pet\`) erstellen und in `Microsoft.PowerShell_profile.ps1` eintragen
2. **Neue Commands**: In das passende Modul einfuegen (siehe GUIDE.md fuer Kategorien)
3. **Neue Persistenz**: Im `Get-StateDefaults` von `engine-state-core.ps1` registrieren (oder eigenes Savefile wie Adventure)
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
| `Modules/engine-state-core.ps1` | Zentraler State-Store, Backup-Rotation, Accessors |
| `Modules/engine-state-migration.ps1` | Migration, Export/Import |
| `Modules/engine-state-advanced.ps1` | Transaktionen |
| `Modules/engine-ui.ps1` | UI-Framework fuer ALLE interaktiven Module |
| `Modules/engine-render.ps1` | TUI Render Engine (Double-Buffering, Delta-Render) |
| `Modules/engine-scene.ps1` | TUI Scene Engine (Deklarative Screens) |
| `Modules/engine-input.ps1` | Game Loop, Polling Input, Mock Input fuer E2E |
| `Modules/engine-game.ps1` | Karten, Wuerfel, Element-System |
| `Modules/engine-aliases.ps1` | Alle Terminal-Commands, Git, System, Bank, PNPM |
| `Modules/casino-engine.ps1` | Shared Casino-Wrapper |
| `Modules/arcade-tetris.ps1` | Tetris TUI-Spiel (Referenz-Implementierung) |
| `Modules/arcade-minesweeper.ps1` | Minesweeper TUI-Spiel |
| `Modules/arcade-breakout.ps1` | Breakout TUI-Spiel |
| `Modules/adventure-engine.ps1` | Adventure Engine (Parser, State, Inventory) |
| `Modules/adventure-world.ps1` | Adventure Welt-Daten |
| `Modules/desktop-pet.ps1` | Desktop Pet (Prompt-Override) |
| `Modules/pet/_init.ps1` | Pet System Schema, Meta-Progression, Tutorial |
| `Modules/pet/hub.ps1` | Pet Hub Router mit dynamischem Menu |
| `Modules/pet/skilltree.ps1` | Skill-Tree-Engine: Punkte vergeben, Boni berechnen, UI |
| `Modules/pet/companion.ps1` | Companion-Datenmodell und Actions |
| `Modules/pet/combat.ps1` | Battlepet Kampf-Engine |
| `Modules/handbook.ps1` | Vollstaendige Spiele-Mechanik-Doku |
| `Modules/_smoke_test.ps1` | Regressionstests fuer Engines |
| `Modules/_integration_test.ps1` | AST-basierte Checks auf Duplikate/Konflikte |
| `Modules/_e2e_test.ps1` | Automatisierte Game-Flow Tests |
| `LUCASARTS.md` | Design-Regeln fuer Companion-Dialoge und User-facing Text |
| `GUIDE.md` | Vollstaendige Feature-Liste fuer Endbenutzer |

---

## Version History Convention

Versionen werden in Datei-Headern und der Boot-Sequence angezeigt:
- Hauptprofil: v24.0 (stabil)
- Einzelne Module tragen ihre eigene Versionsnummer im Header (z.B. v24.5 fuer Arcade, v24.9 fuer Desktop Pet)
- Die `status`-Funktion zeigt die aktuelle Version an
- State-Version ist im JSON als `Version = 24` gespeichert
