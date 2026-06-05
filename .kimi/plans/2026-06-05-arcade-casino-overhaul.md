# BUXE_OS Arcade & Casino Overhaul — Design Spec

## Vision

Arcade und Casino werden von einer Sammlung loser Mini-Games zu einem **integrierten Entertainment-System**.
Jedes Game ist ein First-Class-Citizen: Hub-Menü, State-Persistenz, Companion-Integration,
LucasArts-Style Voice, und Verbindung zur BUXE-Ökonomie.

> Für später: Companion Co-op / VS Mode (z.B. Tic-Tac-Toe, Schach-ähnliches,
> oder Companion als CPU-Gegner in Arcade-Games).

---

## Phase 1: Foundation — Arcade wird ein System

### 1.1 Arcade Hub (`arcade.ps1`)

**Problem:** `arcade.ps1` dot-sourcet nur Sub-Module. Kein Menü, keine Stats.

**Lösung:** Neuer `arcade` Router, analog zu `casino`:

```
========================================
  BUXE_ARCADE v24.5
========================================

  [1] Tetris          Best: 2,400
  [2] Snake           Best: 12
  [3] Minesweeper     Best: 45s
  [4] Breakout        Best: Lv.3
  [5] Wordle          Streak: 2
  [6] Monkeytype      WPM: 68
  [7] Zork            Rooms: 4/8
  [8] Hangman         Won: 3
  [9] 2048            Best: 1,024
  [0] Dino Jump       Best: 347

  [S] Stats Overview
  [B] Bet Mode (Arcade Economy)
  [Q] Exit
```

- `arcade` öffnet Hub
- `arcade <name>` startet direkt (z.B. `arcade tetris`)
- Stats werden aus `Arcade` State gelesen
- Bet-Mode: Vor Game-Start optionaler Einsatz. Score wird in Multiplier umgerechnet.

### 1.2 Bet Mode (Arcade Economy)

Optionaler Einsatz vor Arcade-Games:
- Spieler setzt z.B. 50G
- End-Score wird in Gewinn umgerechnet (z.B. Score / 100 * Einsatz)
- Max-Gewinn gecappt (z.B. 10x Einsatz)
- Bei Game Over = Einsatz verloren
- Integration mit CasinoLuck-Skill des Companions

### 1.3 Companion Integration Framework

Jedes Arcade-Game bekommt Companion-Kommentare:
- **Game-Start:** Companion gibt einen zufälligen LucasArts-One-Liner
- **Game Over:** Companion reagiert auf Niederlage (nicht verurteilend, humorvoll)
- **Highscore:** Companion feiert oder macht sich lustig
- **Milestone:** Jede 10. Session, 47. Aktion, etc. → Easter Egg

Neue Contexts in `CPMetaLines`:
- `game_start`, `game_over`, `highscore`, `game_milestone`

Jedes Game ruft `Show-GameCompanionComment` auf:
```powershell
Show-GameCompanionComment $cp "snake" "start"
```

### 1.4 State Fixes

**Breakout Stats fehlen in Defaults:**
```powershell
Breakout = @{ BestScore = 0; BestLevel = 0; GamesPlayed = 0 }
```

**Neue Games brauchen State-Slots:**
```powershell
Game2048 = @{ BestScore = 0; BestTile = 0; GamesPlayed = 0 }
DinoJump = @{ BestScore = 0; GamesPlayed = 0 }
```

Migration: Bestehende Breakout-Daten (dynamisch gespeichert) übernehmen.

---

## Phase 2: Arcade Games — Fixen & Neue

### 2.1 Snake Fix

**Problem:** Kein wachsender Tail. "O" sammelt "X" → bei 10 Punkten Sieg. Keine echte Snake-Mechanik.

**Fix:**
- Echter wachsender Tail (Array von Positionen)
- Kollision mit Wand = Game Over
- Kollision mit eigenem Tail = Game Over
- Score = Länge des Tails
- `Invoke-GameLoop` bei 8 FPS
- Highscore persistiert

### 2.2 Wordle Erweitern

**Problem:** 11 Wörter, keine farbigen Tiles, kein Hard Mode.

**Fix:**
- Word-Pool auf 500+ deutsch-englische Tech-Begriffe
- Farbige Letter-Tiles: 🟩 (richtig), 🟨 (falsch positioniert), ⬛ (nicht enthalten)
- Hard Mode: Jeder gefundene Buchstabe muss im nächsten Guess verwendet werden
- Streak-Tracking bleibt

### 2.3 Monkeytype Erweitern

**Problem:** 56 Wörter, kein Accuracy, nur Wort-Modus.

**Fix:**
- Word-Pool auf 200+ Tech-Begriffe
- Accuracy-Tracking (korrekte Zeichen / gesamte Zeichen)
- Sentence-Mode: Tech-Sätze statt einzelne Wörter
- Best-WPM + Best-Accuracy

### 2.4 Zork Erweitern

**Problem:** 4 Räume, kein realer Parser.

**Fix:**
- Erweitert auf 8 Räume (Nutzt `adventure-engine.ps1` Parser)
- Self-aware Story: "Du bist in einem Text-Adventure in einem PowerShell-Profil."
- Easter Eggs: 47-Referenz, Companion-Metionen, BUXE-Lore
- Items, Rätsel, ein Boss-Gegner

### 2.5 Neues Game: 2048

**Mechanik:**
- 4×4 Grid
- WASD zum Verschieben
- Gleiche Zahlen mergen
- Ziel: 2048 (oder weiter für Highscore)
- State: Best Score, Best Tile (64/128/256...), Games Played

### 2.6 Neues Game: Dino Jump

**Mechanik:**
- Chrome-Dino-Style Endless Runner
- Space zum Springen
- Hindernisse kommen von rechts
- Geschwindigkeit steigt mit Score
- State: Best Score, Games Played
- Einfach zu implementieren in TUI

### 2.7 Neues Game: Memory Match

**Mechanik:**
- 4×4 Grid mit verdeckten Karten (8 Paare)
- WASD zum Bewegen, Enter zum Umdrehen
- 2 Karten umdrehen → Match oder zurückdecken
- Timer + Züge gezählt
- Companion kommentiert schlechtes Gedächtnis
- State: Best Time, Best Moves, Games Played

---

## Phase 3: Casino Games — Tiefe & Neue

### 3.1 Slots Erweitern

**Problem:** Nur Match-3, keine Features.

**Erweiterungen:**
- **Wild Symbol:** Ersetzt jedes Symbol für Match
- **Scatter:** 3+ Scatter = Free Spins (3-10 Spins ohne Einsatz)
- **Bonus Round:** Bei 3 Bonus-Symbolen → Pick-Game (3 Kisten, eine hat Jackpot)
- **Progressiver Jackpot:** Jeder Spin addiert 1% des Einsatzes zum Jackpot
  - Jackpot wird in `Casino.Slot.ProgressiveJackpot` gespeichert
  - Gewinnchance: 1:10.000 pro Spin
  - Anzeige: "Progressiver Jackpot: 1,247 G"

### 3.2 Craps Erweitern

**Problem:** Nur Pass/Don't Pass.

**Erweiterungen:**
- **Come / Don't Come:** Wie Pass, aber nach Come-out roll
- **Odds Bets:** Hinter Pass/Come, true odds (no house edge)
- **Place Bets:** Auf 4,5,6,8,9,10 setzen
- **Field Bet:** Ein-Rollen-Wette auf 2,3,4,9,10,11,12

### 3.3 Roulette Erweitern

**Problem:** Nur 5 Bet-Typen.

**Erweiterungen:**
- **Column Bet:** 3 Spalten (2:1)
- **Corner Bet:** 4 Zahlen (8:1)
- **Six-Line:** 2 Reihen (5:1)
- **Racetrack:** Nachbar-Wetten (0-spiel, orphans, etc.)

### 3.4 Neues Game: Keno

**Mechanik:**
- Spieler wählt 1-10 Zahlen aus 80
- 20 Zahlen werden gezogen
- Paytable basierend auf Matches
- Einfache Implementierung, gute für entspanntes Spielen

### 3.5 Neues Game: Wheel of Fortune

**Mechanik:**
- Einrad mit Segmenten: 2x, 3x, 5x, 10x, 50x, BANKRUPT, JACKPOT
- Spieler setzt, dreht Rad
- Animation mit langsamerem Stop
- BANKRUPT = Einsatz verloren
- JACKPOT = Progressiver Jackpot gewonnen

---

## LucasArts-Integration (Projekt-weit)

### Companion-Kommentare pro Game

Jedes Game hat eine `Show-GameCompanionComment` Integration:

**Beispiele (Meta 11+ Awakening):**
- Snake: "Du bewegst einen Buchstaben durch eine Matrix. Wie metaphorisch."
- Wordle: "Du rate Wörter. Ich rate, warum du das tust."
- Slots: "Die Maschine ist ein RNG. Du bist auch ein RNG. Nur langsamer."

**Beispiele (Meta 12+ Fourth Wall):**
- Tetris: "Dein Window ist zu klein für Level 10. Trust me. Ich sehe die Pixel."
- Dino Jump: "Kein Internet? Nein, nur keine Motivation. Gleiches Meta-Level."

**Beispiele (47-Regel):**
- Beim 47. Snake-Punkt: "47! Du bist halbwegs zu 94! Weiter so!"
- Beim 47. Casino-Spin: "Spin #47. Die Statistik sagt: gleiche Chance. Ich sage: YOLO."

### Easter Eggs

- **Arcade Marathon:** 10 Arcade-Games in einer Session spielen → Achievement
- **Casino Bust → Arcade:** Nach Casino-Bust (0G) Arcade öffnen → Companion: "Rückzug in die Arcade? Klug."
- **3am Gaming:** Arcade/Casino zwischen 2-4 Uhr → spezielle Dialoge

---

## State Schema Erweiterungen

### Arcade State (engine-state-core.ps1)

```powershell
Arcade = @{
    MonkeyType = @{ BestWPM = 0; BestAccuracy = 0; Races = 0 }
    Snake = @{ BestScore = 0; Games = 0 }
    Wordle = @{ Played = 0; Streak = 0; BestStreak = 0; HardModeWins = 0 }
    Zork = @{ RoomsExplored = 0; ItemsFound = 0; BossDefeated = $false }
    Hangman = @{ Won = 0; Lost = 0 }
    Minesweeper = @{ Wins = 0; Losses = 0; BestTime = 0 }
    Tetris = @{ BestScore = 0; BestLines = 0; GamesPlayed = 0 }
    Breakout = @{ BestScore = 0; BestLevel = 0; GamesPlayed = 0 }
    Game2048 = @{ BestScore = 0; BestTile = 0; GamesPlayed = 0 }
    DinoJump = @{ BestScore = 0; GamesPlayed = 0 }
    MemoryMatch = @{ BestTime = 0; BestMoves = 0; GamesPlayed = 0 }
}
```

### Casino State Erweiterungen

```powershell
Slot = @{
    Spins = 0; JackpotWins = 0; TotalWon = 0; TotalSpent = 0
    ProgressiveJackpot = 500  # Startwert, wächst mit jedem Spin
}
```

### Boot Stats Erweiterung

```powershell
Boot = @{
    Loads = 0; TotalCommands = 0; FavoriteCommand = ""
    LastBoot = ""; FavoriteGame = ""  # Meistgespieltes Game
}
```

---

## Dateien & Module

### Neue Dateien
| Datei | Zweck |
|-------|-------|
| `arcade-2048.ps1` | 2048 Game |
| `arcade-dino.ps1` | Dino Jump Game |
| `arcade-memory.ps1` | Memory Match Game |
| `casino-keno.ps1` | Keno Game |
| `casino-wheel.ps1` | Wheel of Fortune |

### Geänderte Dateien
| Datei | Änderung |
|-------|----------|
| `arcade.ps1` | Hub-Router statt Loader |
| `arcade-snake.ps1` | Tail-Mechanik, Game Over |
| `arcade-wordle.ps1` | 500+ Wörter, farbige Tiles, Hard Mode |
| `arcade-monkeytype.ps1` | Accuracy, Sentences, 200+ Wörter |
| `arcade-legacy.ps1` | Zork erweitert auf 8 Räume |
| `arcade-breakout.ps1` | State-Tracking fix |
| `casino-slot.ps1` | Wilds, Free Spins, Bonus Round, Progressive Jackpot |
| `casino-craps.ps1` | Come, Odds, Place, Field bets |
| `casino-roulette.ps1` | Column, Corner, Six-Line, Racetrack |
| `engine-state-core.ps1` | Neue State-Slots, Breakout-Fix |
| `engine-ui.ps1` | Show-GameCompanionComment Helper |
| `pet/_ui.ps1` | Neue CPMetaLines für Games |

---

## Test-Plan

- Smoke Test: Alle neuen Funktionen laden, State-Defaults korrekt
- Integration Test: Keine doppelten Funktionen, State-Persistenz
- E2E Test: Jede neue/erweiterte Game-Flow mit Mock-Input
- Manuelle Tests: Theme-Wechsel, Bet Mode, Progressive Jackpot

---

## Implementierungs-Reihenfolge

1. **Foundation:** State-Fixes + Arcade Hub + Companion Framework
2. **Arcade Fixes:** Snake → Wordle → Monkeytype → Zork
3. **Neue Arcade Games:** 2048 → Dino Jump → Memory Match
4. **Casino Erweiterungen:** Slots → Craps → Roulette
5. **Neue Casino Games:** Keno → Wheel of Fortune
6. **Polish:** Easter Eggs, Theme-Integration, Tests
