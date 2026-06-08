# 🎮 BUXE_OS

> *„Deine PowerShell ist kein Terminal. Sie ist eine Welt.“*

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2F5.1-blue?logo=powershell)](https://docs.microsoft.com/powershell/)
[![Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Smoke%20%7C%20Integration%20%7C%20E2E-brightgreen)](#testing)
[![Version](https://img.shields.io/badge/Version-v24.0-orange)](#)

**BUXE_OS** ist ein hochgradig personalisiertes PowerShell-Profil-System für Windows — eine vollständige „Betriebssystem“-Schicht für deine Shell. Von Arcade-Klassikern über eine Casino-Suite bis hin zu RPG-Systemen, Text-Adventures und einem Desktop-Pet: BUXE_OS verwandelt dein Terminal in eine interaktive Spielwelt.

---

## ✨ Features

### 🕹️ Arcade
Klassische TUI-Spiele, direkt im Terminal:
- 🐍 **Snake** — Wachse und überlebe
- 💣 **Minesweeper** — 10×10 Feld, WASD-Steuerung
- 🧱 **Tetris** — Der zeitlose Klassiker
- 🏓 **Breakout** — Baue zerstören
- 🦕 **Dino Jump** — Der Chrome-Klassiker im Terminal
- 🧩 **2048** — Zahlen-Puzzle
- 🧠 **Memory Match** — Merkfähigkeit testen
- ⌨️ **Monkeytype** — WPM-Typing-Test
- 🎯 **Wordle** — Wörter erraten

### 🎰 Casino Suite
Vollständige Casino-Erfahrung mit unified Bankroll:
- 🃏 **Blackjack** — Hit, Stand, Double, Split, Insurance
- 🎡 **Roulette** — Europäisches Roulette
- 🎲 **Craps** — Pass/Don't Pass
- ⬆️⬇️ **Hi-Lo** — Multiplier-basiert
- 🏛️ **Baccarat** — Mit 3rd-Card-Regeln
- 🎰 **Slot Machine** — 3-Walzen mit Animation
- 🎱 **Keno** — Lotto-Style
- 🎯 **Wheel of Fortune**

### 🐾 Pet System v2.0
Ein vollständiges RPG-System mit 13 Modulen:
- 👩 **7 einzigartige Companions** (NEON, RAVEN, PIXEL, LUNA, IVY, VERA, JINX)
- 💕 **Bond- & Mood-System** — Jede Companion hat Persönlichkeit
- ⚔️ **Battlepet-Kampf** — A/V/S Rock-Paper-Scissors mit Element-Modifiern
- 🏪 **Shop & Cooking** — Schwarzmarkt, Buffs, Ramen, Sushi, Curry
- 🏆 **PvP Arena** — Bronze → Master Rank-System
- 🐉 **3-Phasen Raids** — Cyber Golem → Net Titan → Omega Core
- 🧬 **Breeding** — Ab Meta-Level 7
- 🔗 **Soul Link** — Endgame-Feature ab Level 9
- 📖 **Meta-Progression** — 10 Level mit Feature-Unlocks
- 🎮 **Companion Mini-Games** — ChaosChips, 42or47, Memory

### 🗺️ Text-Adventure
Parser-basiertes LucasArts-Style Adventure:
- **16 Räume** — Hangar, Bridge, Core, EVA, Airlock, Medbay, Armory, Secret, Lab ...
- **Inventory-System** — Sammle, benutze, kombiniere
- **Companion AI** — Mood-gesteuerte Dialoge, Running Gags, Easter Eggs
- **Insult Swordfighting** — 29 Insult/Comeback-Paare im Monkey-Island-Stil
- **Oxygen-System** — Überlebe im Weltraum
- **True Ending** — Mehrere Enden möglich

### 🖥️ Desktop Pet
Companion kommentiert deine Shell-Befehle in Echtzeit:
- Opt-in via `dp-on`
- Kommentiert Git, npm, Docker, `rm`, Systembefehle ...
- Deaktivierung jederzeit mit `dp-off`

### 🛠️ Developer Tools
- **TTS-System** — `Say 'Text'` via Edge-TTS + ffplay
- **Git-Aliase** — `gs`, `ga`, `gc`, `gp`, `glog`, ...
- **Navigation** — `..`, `...`, `tmp`, `dl`, `docs`, `mkcd`
- **System** — `weather`, `ip`, `mem`, `port`, `sysinfo`
- **PNPM-Aliase** — `p`, `pi`, `ps`, `pb`, `pd`, `pt`

---

## 🏗️ Architektur

```
BUXE_OS v24 (Engine-First)
│
├── 🔧 Core Engines
│   ├── engine-state-core      # Unified JSON State, Backup-Rotation
│   ├── engine-state-migration # v23 → v24 Migration
│   ├── engine-state-advanced  # State-Transaktionen
│   ├── engine-ui              # Frames, Bars, Menüs, Animationen
│   ├── engine-render          # Double-Buffering, Delta-Render
│   ├── engine-scene           # Deklarative Screen-Komposition
│   ├── engine-input           # Polling-Loop, Mock Input (E2E)
│   ├── engine-game            # Karten, Würfel, Element-System
│   └── engine-aliases         # Terminal-Commands
│
├── 🎰 Casino Framework
│   ├── casino-engine          # Shared Wrapper (Bet, Bust, Luck)
│   └── 8 Casino-Games         # Blackjack, Roulette, Craps, ...
│
├── 🕹️ Arcade & Strategy
│   ├── 10 Arcade-Games        # Snake, Tetris, Minesweeper, ...
│   └── 3 Strategy-Games       # Poker, Tower Defense, Rogue
│
├── 🗺️ Adventure System
│   ├── adventure-engine       # Parser, Inventory, Rooms
│   ├── adventure-world        # 16 Räume, Objekte, NPCs
│   ├── adventure-companion-ai # Mood, Gags, Easter Eggs
│   └── adventure-insult       # 29 Insult-Paare
│
├── 🐾 Pet System v2.0 (13 Module)
│   ├── _init, _ui, _unlock    # Core, Dialog, Progression
│   ├── companion, combat      # Bond, Kampf
│   ├── economy, events        # Shop, Quests
│   ├── hub, pvp, raid         # Router, Arena, Dungeon
│   ├── rival, breed, soul     # Daily, Genetik, Endgame
│   └── companion-games        # ChaosChips, 42or47, Memory
│
└── 📚 Handbook & Tests
    ├── handbook (9 Kapitel)   # In-Game Hilfe
    └── _smoke, _integration, _e2e  # 100+ Tests
```

### TUI Framework
BUXE_OS verwendet ein eigenes Terminal-UI-Framework:
- **Double-Buffering** — Kein `Clear-Host`-Flackern
- **Delta-Rendering** — Nur geänderte Zeilen werden neu geschrieben
- **Deklarative Scenes** — Spiele definieren WAS, nicht WIE
- **Mock Input** — Vollständig automatisierbare E2E-Tests

---

## 🚀 Installation

### Voraussetzungen
- Windows 10/11
- PowerShell 7 oder 5.1
- [Nerd Font](https://www.nerdfonts.com/) (empfohlen: CaskaydiaCove)
- [Oh My Posh](https://ohmyposh.dev/)
- [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- [PSFzf](https://github.com/kelleyma49/PSFzf)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)
- `edge-tts` + `ffplay` (optional, für TTS)

### Setup
```powershell
# 1. Repository klonen
git clone https://github.com/deusexlumen/buxe-os.git

# 2. In dein PowerShell-Profile-Verzeichnis wechseln
cd "$env:USERPROFILE\Documents\PowerShell"

# 3. Dateien kopieren (oder symlinken)
Copy-Item -Path ".\buxe-os\*" -Destination "." -Recurse -Force

# 4. Profil neu laden
. $PROFILE
```

Beim ersten Start wird automatisch ein Unified State (`%LOCALAPPDATA%\buxe\buxe_state_v24.json`) angelegt. Alte v23-States werden migriert.

---

## 🎮 Schnellstart

| Befehl | Was passiert |
|--------|-------------|
| `status` | Bankroll, Companion, Session-Info |
| `bank` | Gold einzahlen / abheben |
| `daily` | Tägliche Belohnung abholen |
| `pet` | Pet Hub öffnen |
| `casino` | Casino Menu |
| `arcade` | Arcade Menu |
| `adv` | Text-Adventure starten |
| `insult` | Schwertkampf starten |
| `say 'Hallo'` | Text-to-Speech |
| `h` | In-Game Handbuch |
| `reload` | Profil neu laden |

---

## 🧪 Testing

```powershell
# Smoke Test (65+ Checks: Engines, State, Spiele)
& .\Modules\_smoke_test.ps1

# Integration Test (30 Checks: AST, Duplikate, Konflikte)
& .\Modules\_integration_test.ps1

# End-to-End Test (17+ Game-Flows mit Mock-Input)
& .\Modules\_e2e_test.ps1
```

Alle Tests sind **automatisiert** und laufen ohne menschliche Interaktion ab.

---

## 🎨 Design-Philosophie

BUXE_OS folgt den LucasArts-Adventure-Design-Regeln:

- **Self-aware** — Charaktere wissen, dass sie Code in einer PowerShell-Session sind
- **Fourth-wall breaks** — Sprechen direkt den User an, referenzieren Commands
- **Kein generischer Text** — Jede Zeile hat eine spezifische Stimme
- **Humor vor Drama** — Selbst „traurige" Momente sind komisch
- **The 47 Rule** — Running Gag, sparsam aber konsistent genutzt
- **Kein Game Over** — Falsche Wahlen enden humorvoll, nie bestrafend

> *„You are about to enter a PowerShell session. It will be fun. Probably."*

---

## 📁 Projektstruktur

```
Documents\PowerShell\
├── Microsoft.PowerShell_profile.ps1   # Entry Point, TTS-System
├── buxe.omp.json                      # Oh-My-Posh Theme
├── Modules\
│   ├── engine-*.ps1                   # Core Engines (9)
│   ├── casino-*.ps1                   # Casino Games (8)
│   ├── arcade-*.ps1                   # Arcade Games (10)
│   ├── strategy-*.ps1                 # Strategy Games (3)
│   ├── adventure-*.ps1                # Adventure System (5)
│   ├── handbook-*.ps1                 # Handbuch (9 Kapitel)
│   ├── desktop-pet.ps1                # Desktop Pet
│   ├── boot.ps1                       # Boot-Sequenz
│   ├── fun.ps1                        # APIs, Gags
│   ├── _*_test.ps1                    # Tests (3)
│   └── pet\                           # Pet System v2.0 (13 Module)
└── docs\superpowers\                  # Pläne und Spezifikationen
```

---

## 📊 Stats & Persistenz

Alles wird in **einer** Datei gespeichert:
- `%LOCALAPPDATA%\buxe\buxe_state_v24.json`
- 5 rotierende Backups (`.bak1` bis `.bak5`)
- Automatische Korruptionserkennung + Recovery

**Enthaltene Daten:**
- Bankroll, Casino-Stats, Arcade-Highscores
- Companion-State, Battlepet, Pet-System
- Achievements, Story-Progress, Time-Capsules
- Boot-Stats (Loads, Favorite Command, Last Boot)

---

## 🤝 Mitwirken

1. Fork erstellen
2. Feature-Branch: `git checkout -b feature/dein-feature`
3. Änderungen committen: `gc "feat: ..."`
4. Push: `gp`
5. Pull Request öffnen

Bitte stelle sicher, dass alle Tests bestehen:
```powershell
& .\Modules\_smoke_test.ps1
& .\Modules\_integration_test.ps1
& .\Modules\_e2e_test.ps1
```

---

## 📜 Lizenz

MIT — Mach damit, was du willst. Aber sag niemals, dass es langweilig war.

---

> *„Willkommen zurück, User. Das Terminal hat dich vermisst. Oder zumindest behauptet das die KI."* — **BUXE_OS Boot Sequence**
