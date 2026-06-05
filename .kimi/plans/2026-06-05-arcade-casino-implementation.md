# Arcade & Casino Overhaul — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform Arcade and Casino from loose mini-games into an integrated entertainment system with Hub, State, Companion Integration, and LucasArts voice.

**Architecture:** Casino uses `Invoke-CasinoGame` wrapper; Arcade gets a matching `Invoke-ArcadeGame` wrapper. Both systems integrate with the Pet/Companion system via `Show-GameCompanionComment`. New games follow the established TUI pattern (`New-Scene`/`Show-Scene` or `Invoke-GameLoop`). State is unified in `buxe_state_v24.json`.

**Tech Stack:** PowerShell 7/5.1, TUI Framework (`engine-scene.ps1`, `engine-render.ps1`, `engine-input.ps1`)

---

## File Structure

### Modified Files
| File | Responsibility |
|------|----------------|
| `Modules/engine-state-core.ps1` | Add Breakout to defaults, new Arcade slots (Game2048, DinoJump, MemoryMatch, Wordle.HardModeWins, Zork.BossDefeated), Casino.Slot.ProgressiveJackpot, Boot.FavoriteGame |
| `Modules/engine-ui.ps1` | Add `Show-GameCompanionComment` helper; update `Show-Frame` for game contexts |
| `Modules/arcade.ps1` | Transform from loader to Hub router with menu, stats, bet mode |
| `Modules/arcade-snake.ps1` | Fix tail growth, game over logic, state tracking |
| `Modules/arcade-wordle.ps1` | 500+ word pool, colored tiles, hard mode |
| `Modules/arcade-monkeytype.ps1` | Accuracy tracking, sentence mode, 200+ word pool |
| `Modules/arcade-legacy.ps1` | Expand Zork to 8 rooms, integrate adventure engine parser |
| `Modules/arcade-breakout.ps1` | Add state tracking hooks |
| `Modules/casino-slot.ps1` | Wilds, free spins, bonus round, progressive jackpot |
| `Modules/casino-craps.ps1` | Come/Don't Come, Odds, Place, Field bets |
| `Modules/casino-roulette.ps1` | Column, Corner, Six-Line, Racetrack bets |
| `Modules/pet/_ui.ps1` | Add `game_start`, `game_over`, `highscore`, `game_milestone` to `CPMetaLines` |
| `Modules/_smoke_test.ps1` | Add tests for new functions and state defaults |
| `Modules/_integration_test.ps1` | Add integration checks for new state slots |
| `Modules/_e2e_test.ps1` | Add game flow tests for new/updated games |

### New Files
| File | Responsibility |
|------|----------------|
| `Modules/arcade-2048.ps1` | 2048 grid game with WASD controls |
| `Modules/arcade-dino.ps1` | Chrome Dino-style endless runner |
| `Modules/arcade-memory.ps1` | Memory match card game |
| `Modules/casino-keno.ps1` | Keno number draw game |
| `Modules/casino-wheel.ps1` | Wheel of Fortune with segments |

---

## Phase 1: Foundation

### Task 1: State Schema Fixes

**Files:**
- Modify: `Modules/engine-state-core.ps1` (Get-StateDefaults function)
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Add missing Arcade state slots**

In `Get-StateDefaults`, under `Arcade = @{`, add:
```powershell
    Breakout = @{ BestScore = 0; BestLevel = 0; GamesPlayed = 0 }
    Game2048 = @{ BestScore = 0; BestTile = 0; GamesPlayed = 0 }
    DinoJump = @{ BestScore = 0; GamesPlayed = 0 }
    MemoryMatch = @{ BestTime = 0; BestMoves = 0; GamesPlayed = 0 }
```

Also update existing slots:
```powershell
    Wordle = @{ Played = 0; Streak = 0; BestStreak = 0; HardModeWins = 0 }
    Zork = @{ RoomsExplored = 0; ItemsFound = 0; BossDefeated = $false }
    MonkeyType = @{ BestWPM = 0; BestAccuracy = 0; Races = 0 }
```

- [ ] **Step 2: Add Casino progressive jackpot**

In `Get-StateDefaults`, under `Casino.Slot`, add:
```powershell
    Slot = @{ Spins = 0; JackpotWins = 0; TotalWon = 0; TotalSpent = 0; ProgressiveJackpot = 500 }
```

- [ ] **Step 3: Add Boot.FavoriteGame**

In `Get-StateDefaults`, under `Boot`, add:
```powershell
    Boot = @{ Loads = 0; TotalCommands = 0; FavoriteCommand = ""; LastBoot = ""; FavoriteGame = "" }
```

- [ ] **Step 4: Run Smoke Test**

```powershell
& ./Modules/_smoke_test.ps1
```
Expected: 101+ passes, no failures.

- [ ] **Step 5: Commit**

```bash
git add Modules/engine-state-core.ps1
git commit -m "Phase 1: Add Arcade/Casino state slots for overhaul"
```

---

### Task 2: Companion Game Comment Framework

**Files:**
- Modify: `Modules/engine-ui.ps1`
- Modify: `Modules/pet/_ui.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Add Show-GameCompanionComment to engine-ui.ps1**

At the end of `engine-ui.ps1`, before the catch block:
```powershell
function Show-GameCompanionComment($Companion, $GameName, $Context) {
    if (-not $Companion) { return }
    if (-not (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) { return }
    $comment = Get-CompanionLine $Companion "game_$($GameName)_$Context"
    if ($comment -and $comment -ne "Ich bin nur ein Bug in der Matrix. Hallo.") {
        Show-CompanionDialog $Companion $comment -Fast
    }
}
```

- [ ] **Step 2: Add game contexts to CPMetaLines in pet/_ui.ps1**

Add new entries to `$script:CPMetaLines`:
```powershell
    game_snake_start = @(
        "Du bewegst einen Buchstaben durch eine Matrix. Wie metaphorisch.",
        "Snake. Das Game, das aelter ist als deine Festplatte.",
        "Vorsicht vor den Waenden. Sie sind hart. Virtuell hart."
    )
    game_snake_over = @(
        "Du bist gegen eine Wand gelaufen. Klassisch.",
        "Game Over. Nicht wortwoertlich. Aber fast.",
        "Dein Schwanz war laenger als deine Geduld."
    )
    game_wordle_start = @(
        "Du erraetst Woerter. Ich errate, warum du das tust.",
        "5 Buchstaben. 6 Versuche. 1 Hoffnung.",
        "Wortraetsel. Das Lieblingsspiel von Programmierern."
    )
    game_tetris_start = @(
        "Die L-Form passt da rein. Trust me. Ich bin ein Algorithmus.",
        "Tetris ist wie Code. Alles muss passen. Oder es explodiert."
    )
    game_arcade_over = @(
        "Game Over. Nicht das erste Mal, oder?",
        "Du hast verloren. Aber hey, wenigstens hast du mich noch.",
        "Zurueck zum Hauptmenue. Der einzige Ort ohne Game Over."
    )
    game_highscore = @(
        "Neuer Rekord! Ich bin stolz. Virtuell stolz.",
        "Highscore! Das wird in die Geschichtsbuecher eingehen. Oder in eine JSON.",
        "DU BIST DER BESTE! Naja, heute. Vielleicht."
    )
```

Also add cases to `Get-CompanionLine` switch:
```powershell
        "game_snake_start" { $lines = $script:CPMetaLines.game_snake_start }
        "game_snake_over" { $lines = $script:CPMetaLines.game_snake_over }
        "game_wordle_start" { $lines = $script:CPMetaLines.game_wordle_start }
        "game_tetris_start" { $lines = $script:CPMetaLines.game_tetris_start }
        "game_arcade_over" { $lines = $script:CPMetaLines.game_arcade_over }
        "game_highscore" { $lines = $script:CPMetaLines.game_highscore }
```

- [ ] **Step 3: Verify functions exist in Smoke Test**

Add to `_smoke_test.ps1` under "Testing Pet System":
```powershell
# Game Companion Comment
if (Get-Command Show-GameCompanionComment -ErrorAction SilentlyContinue) {
    Write-Host "  [PASS] Show-GameCompanionComment exists" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Show-GameCompanionComment missing" -ForegroundColor Red; $failed++
}
```

- [ ] **Step 4: Run Smoke Test**

```powershell
& ./Modules/_smoke_test.ps1
```

- [ ] **Step 5: Commit**

```bash
git add Modules/engine-ui.ps1 Modules/pet/_ui.ps1 Modules/_smoke_test.ps1
git commit -m "Phase 1: Add Show-GameCompanionComment framework and game contexts"
```

---

### Task 3: Arcade Hub Router

**Files:**
- Modify: `Modules/arcade.ps1`
- Modify: `Modules/engine-aliases-buxe.ps1` (if arcade alias exists)

- [ ] **Step 1: Rewrite arcade.ps1 as Hub Router**

Replace the entire content of `arcade.ps1`:
```powershell
# BUXE_OS v24.5 -- ARCADE HUB
# Unified entry point for all arcade games.

try {

function Show-ArcadeStats {
    Load-State
    $a = $script:BuxeState.Arcade
    try { Clear-Host } catch {}
    Show-Frame "ARCADE STATS" -Double | Out-Null
    Write-Host ""
    Write-Host "  Tetris:       Best Score: $($a.Tetris.BestScore) | Lines: $($a.Tetris.BestLines)" -ForegroundColor Cyan
    Write-Host "  Snake:        Best Score: $($a.Snake.BestScore) | Games: $($a.Snake.Games)" -ForegroundColor Green
    Write-Host "  Minesweeper:  Wins: $($a.Minesweeper.Wins) | Best Time: $($a.Minesweeper.BestTime)s" -ForegroundColor Yellow
    Write-Host "  Breakout:     Best Score: $($a.Breakout.BestScore) | Level: $($a.Breakout.BestLevel)" -ForegroundColor Magenta
    Write-Host "  Wordle:       Streak: $($a.Wordle.Streak) | Best: $($a.Wordle.BestStreak)" -ForegroundColor White
    Write-Host "  Monkeytype:   Best WPM: $($a.MonkeyType.BestWPM) | Accuracy: $($a.MonkeyType.BestAccuracy)%" -ForegroundColor Cyan
    Write-Host "  Zork:         Rooms: $($a.Zork.RoomsExplored) | Items: $($a.Zork.ItemsFound)" -ForegroundColor Green
    Write-Host "  Hangman:      Won: $($a.Hangman.Won) | Lost: $($a.Hangman.Lost)" -ForegroundColor Yellow
    if ($a.Game2048.GamesPlayed -gt 0) {
        Write-Host "  2048:         Best Score: $($a.Game2048.BestScore) | Best Tile: $($a.Game2048.BestTile)" -ForegroundColor Cyan
    }
    if ($a.DinoJump.GamesPlayed -gt 0) {
        Write-Host "  Dino Jump:    Best Score: $($a.DinoJump.BestScore)" -ForegroundColor Green
    }
    if ($a.MemoryMatch.GamesPlayed -gt 0) {
        Write-Host "  Memory Match: Best Time: $($a.MemoryMatch.BestTime)s | Moves: $($a.MemoryMatch.BestMoves)" -ForegroundColor Magenta
    }
    Write-Host ""
    Wait-Enter
}

function arcade {
    param([string]$Game)
    if ($Game) {
        switch ($Game.ToLower()) {
            "tetris" { Start-Tetris }
            "snake" { Start-Snake }
            "minesweeper" { Start-Minesweeper }
            "breakout" { Start-Breakout }
            "wordle" { Start-Wordle }
            "monkeytype" { Start-MonkeyType }
            "zork" { Start-Zork }
            "hangman" { Start-Hangman }
            "2048" { Start-Game2048 }
            "dino" { Start-DinoJump }
            "memory" { Start-MemoryMatch }
            default { Write-Host "Unbekanntes Game: $Game" -ForegroundColor Red }
        }
        return
    }
    # Interactive hub
    while ($true) {
        Load-State
        $a = $script:BuxeState.Arcade
        try { Clear-Host } catch {}
        Show-Frame "BUXE_ARCADE v24.5" -Double | Out-Null
        Write-Host ""
        Write-Host "  [1] Tetris          Best: $($a.Tetris.BestScore)" -ForegroundColor Cyan
        Write-Host "  [2] Snake           Best: $($a.Snake.BestScore)" -ForegroundColor Green
        Write-Host "  [3] Minesweeper     Best: $($a.Minesweeper.BestTime)s" -ForegroundColor Yellow
        Write-Host "  [4] Breakout        Best: Lv.$($a.Breakout.BestLevel)" -ForegroundColor Magenta
        Write-Host "  [5] Wordle          Streak: $($a.Wordle.Streak)" -ForegroundColor White
        Write-Host "  [6] Monkeytype      WPM: $($a.MonkeyType.BestWPM)" -ForegroundColor Cyan
        Write-Host "  [7] Zork            Rooms: $($a.Zork.RoomsExplored)" -ForegroundColor Green
        Write-Host "  [8] Hangman         Won: $($a.Hangman.Won)" -ForegroundColor Yellow
        Write-Host "  [9] 2048            Best: $($a.Game2048.BestScore)" -ForegroundColor Cyan
        Write-Host "  [0] Dino Jump       Best: $($a.DinoJump.BestScore)" -ForegroundColor Green
        Write-Host "  [M] Memory Match    Best: $($a.MemoryMatch.BestTime)s" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  [S] Stats Overview  |  [Q] Exit" -ForegroundColor DarkGray
        $c = Read-Choice "Waehle" '^[1234567890MSQ]$'
        switch ($c) {
            '1' { Start-Tetris }
            '2' { Start-Snake }
            '3' { Start-Minesweeper }
            '4' { Start-Breakout }
            '5' { Start-Wordle }
            '6' { Start-MonkeyType }
            '7' { Start-Zork }
            '8' { Start-Hangman }
            '9' { Start-Game2048 }
            '0' { Start-DinoJump }
            'M' { Start-MemoryMatch }
            'S' { Show-ArcadeStats }
            'Q' { return }
        }
    }
}

} catch {
    Write-Host "[arcade] CRITICAL ERROR: $_" -ForegroundColor Red
}
```

- [ ] **Step 2: Run Smoke Test**

```powershell
& ./Modules/_smoke_test.ps1
```

- [ ] **Step 3: Commit**

```bash
git add Modules/arcade.ps1
git commit -m "Phase 1: Arcade Hub with menu, stats, and direct launch"
```

---

## Phase 2: Arcade Games

### Task 4: Snake Fix

**Files:**
- Modify: `Modules/arcade-snake.ps1`
- Test: `Modules/_smoke_test.ps1`, `Modules/_e2e_test.ps1`

- [ ] **Step 1: Read current snake implementation**

Read `Modules/arcade-snake.ps1` completely to understand current structure.

- [ ] **Step 2: Rewrite with tail growth**

The snake should:
- Start with head only (length 1)
- Grow by 1 segment per food eaten
- Game over on wall collision or self-collision
- Score = tail length
- Use `Invoke-GameLoop` at 8 FPS
- Update `Arcade.Snake` state (BestScore, Games)

Key data structure:
```powershell
$snake = @{ Head = @{ X = 6; Y = 6 }; Tail = @(); Direction = "RIGHT" }
# Tail is array of @{X;Y} ordered from head to tail
```

- [ ] **Step 3: Add companion integration**

Call `Show-GameCompanionComment` at game start and game over.

- [ ] **Step 4: Update E2E test**

In `_e2e_test.ps1`, the Snake test should use MockInput to start the game and quit.

- [ ] **Step 5: Run all tests**

```powershell
& ./Modules/_smoke_test.ps1
& ./Modules/_integration_test.ps1
& ./Modules/_e2e_test.ps1
```

- [ ] **Step 6: Commit**

```bash
git add Modules/arcade-snake.ps1 Modules/_e2e_test.ps1

git commit -m "Phase 2: Fix Snake with tail growth, game over, state tracking"
```

---

### Task 5: Wordle Expansion

**Files:**
- Modify: `Modules/arcade-wordle.ps1`
- Test: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Expand word pool to 500+ words**

Create a large `$script:WordleWords` array with 500+ 5-letter tech/programming terms.
Examples: "debug", "array", "query", "cache", "proxy", "token", "route", "shell", "pixel", "logic", "async", "await", "class", "float", "scope", "stack", "queue", "graph", "regex", "yield", "mutex", "inode", "chmod", "grep", "awk", "sed", "bash", "zsh", "vim", "nano", "emacs", "code", "repo", "merge", "clone", "fetch", "pull", "push", "commit", "branch", "tag", "diff", "patch", "blame", "stash", "reset", "revert", "cherry", "squash", "rebase", "remote", "origin", "master", "main", "issue", "label", "milestone", "action", "runner", "artifact", "deploy", "build", "test", "lint", "format", "bundle", "webpack", "rollup", "parcel", "vite", "esbuild", "swc", "babel", "eslint", "prettier", "jest", "mocha", "cypress", "playwright", "puppeteer", "selenium", "docker", "kubernetes", "helm", "terraform", "ansible", "puppet", "chef", "vagrant", "packer", "vault", "consul", "nomad", "nginx", "apache", "redis", "mongo", "mysql", "pgsql", "sqlite", "mariadb", "elastic", "kafka", "rabbit", "nats", "grpc", "thrift", "rest", "soap", "oauth", "openid", "saml", "ldap", "radius", "tacacs", "kerberos", "x509", "cipher", "aes", "rsa", "ecdsa", "sha256", "md5", "crc32", "base64", "utf8", "ascii", "unicode", "json", "xml", "yaml", "toml", "csv", "tsv", "protobuf", "avro", "parquet", "orc", "hdf5", "netcdf", "sqlite", "leveldb", "rocksdb", "lmdb", "etcd", "zookeeper", "hbase", "cassandra", "dynamo", "cosmos", "bigtable", "spanner", "firestore", "firebase", "supabase", "planetscale", "neon", "railway", "render", "vercel", "netlify", "cloudflare", "fastly", "akamai", "dynatrace", "datadog", "newrelic", "sentry", "pagerduty", "opsgenie", " victorops", "statuspage", "pingdom", "uptime", "gtmetrix", "lighthouse", "webpagetest", "speedcurve", "calibre", "sitespeed", "kraken", "tinify", "squoosh", "sharp", "imagemagick", "ffmpeg", "gstreamer", "webrtc", "socket", "websocket", "webrtc", "webrtc", "quic", "http3", "http2", "spdy", "brotli", "gzip", "deflate", "lz4", "zstd", "snappy", "bzip2", "xz", "lzo", "lzma", "brotli", "zopfli", "png", "jpg", "gif", "webp", "avif", "heic", "svg", "pdf", "epub", "mobi", "azw", "djvu", "tiff", "bmp", "ico", "cur", "woff", "woff2", "eot", "ttf", "otf", "sfnt", "graphql", "apollo", "relay", "urql", "swr", "reactquery", "trpc", "zod", "yup", "joi", "ajv", "superstruct", "io-ts", "runtypes", "decoders", "validations", "forms", "formik", "reacthookform", "finalform", "reduxform", "veevalidate", "vuelidate", "yup", "zod", "joi", "classvalidator", "fluentvalidation", "automapper", "mapster", "expressmapper", "emitmapper", "mapperly", "riokmapperly"

- [ ] **Step 2: Add colored tile feedback**

Replace `+`, `~`, `-` with colored letters:
```powershell
# Green = correct position
# Yellow = wrong position
# Gray = not in word
```
Use `Write-Host` with `-ForegroundColor` for each letter.

- [ ] **Step 3: Add Hard Mode**

In Hard Mode, every revealed correct/yellow letter MUST be used in subsequent guesses.
Track `MustUseLetters` and validate each guess.

- [ ] **Step 4: Update state tracking**

Track `HardModeWins` in `Arcade.Wordle` state.

- [ ] **Step 5: Run tests and commit**

---

### Task 6: Monkeytype Expansion

**Files:**
- Modify: `Modules/arcade-monkeytype.ps1`

- [ ] **Step 1: Expand word pool to 200+ words**

Add tech/programming sentences and words.

- [ ] **Step 2: Add Sentence Mode**

Option: "[1] Word Mode | [2] Sentence Mode"
Sentence mode uses full tech sentences instead of single words.

- [ ] **Step 3: Add accuracy tracking**

Track correct chars vs total chars. Display "Accuracy: 94%" at end.
Update `Arcade.MonkeyType.BestAccuracy`.

- [ ] **Step 4: Commit**

---

### Task 7: Zork Expansion

**Files:**
- Modify: `Modules/arcade-legacy.ps1`

- [ ] **Step 1: Expand to 8 rooms**

Add: Dungeon, Library, Garden, Kitchen, Tower Top, Secret Passage.
Integrate with `adventure-engine.ps1` parser if possible.

- [ ] **Step 2: Add Boss fight**

Final room has a boss (Troll). Use `adventure-engine.ps1` combat or simple RPS.
Track `BossDefeated` in state.

- [ ] **Step 3: Commit**

---

### Task 8: New Game — 2048

**Files:**
- Create: `Modules/arcade-2048.ps1`
- Modify: `Modules/arcade.ps1` (add to menu)

- [ ] **Step 1: Create 2048 game**

4×4 grid. WASD to move. Numbers merge when equal. New 2 or 4 spawns after each move.
Win at 2048, continue for highscore. Game over when no moves possible.

- [ ] **Step 2: Add to Arcade Hub**

Update `arcade.ps1` menu and switch to include `[9] 2048`.

- [ ] **Step 3: Commit**

---

### Task 9: New Game — Dino Jump

**Files:**
- Create: `Modules/arcade-dino.ps1`
- Modify: `Modules/arcade.ps1`

- [ ] **Step 1: Create Dino Jump**

Simple endless runner. Dino at bottom left. Space to jump over obstacles (cacti, birds).
Speed increases with score. Game over on collision.
Use `Invoke-GameLoop` with tick-based movement.

- [ ] **Step 2: Add to Arcade Hub**

- [ ] **Step 3: Commit**

---

### Task 10: New Game — Memory Match

**Files:**
- Create: `Modules/arcade-memory.ps1`
- Modify: `Modules/arcade.ps1`

- [ ] **Step 1: Create Memory Match**

4×4 grid with 8 pairs of symbols (emojis or ASCII). WASD to move cursor.
Enter to flip. Match 2 cards to keep them face-up.
Track time and moves. Best time + best moves in state.

- [ ] **Step 2: Add to Arcade Hub**

- [ ] **Step 3: Commit**

---

## Phase 3: Casino Games

### Task 11: Slots Expansion

**Files:**
- Modify: `Modules/casino-slot.ps1`
- Modify: `Modules/engine-state-core.ps1` (progressive jackpot)

- [ ] **Step 1: Add Wild symbol**

Wild substitutes for any symbol to complete a match.

- [ ] **Step 2: Add Free Spins**

3+ Scatter symbols trigger 3-10 free spins. Free spins don't cost gold.
Track free spin count. Display "FREE SPINS: 5" during free spin mode.

- [ ] **Step 3: Add Bonus Round**

3 Bonus symbols → Pick-Game: 3 chests, one has Jackpot, one has medium win, one has small win.

- [ ] **Step 4: Add Progressive Jackpot**

Each spin adds 1% of bet to `Casino.Slot.ProgressiveJackpot`.
1:10,000 chance to win jackpot on any spin.
Display jackpot amount on screen.

- [ ] **Step 5: Commit**

---

### Task 12: Craps Expansion

**Files:**
- Modify: `Modules/casino-craps.ps1`

- [ ] **Step 1: Add Come/Don't Come**

Same rules as Pass/Don't Pass, but bet is placed AFTER come-out roll.

- [ ] **Step 2: Add Odds Bets**

Behind Pass/Come lines. True odds, no house edge. Payout varies by point.

- [ ] **Step 3: Add Place Bets**

Bet on 4,5,6,8,9,10. Payout: 9:5 (4,10), 7:5 (5,9), 7:6 (6,8).

- [ ] **Step 4: Add Field Bet**

One-roll bet. Win on 2,3,4,9,10,11,12. 2 and 12 pay double.

- [ ] **Step 5: Commit**

---

### Task 13: Roulette Expansion

**Files:**
- Modify: `Modules/casino-roulette.ps1`

- [ ] **Step 1: Add Column Bet**

3 columns (2:1 payout).

- [ ] **Step 2: Add Corner Bet**

4 numbers (8:1 payout).

- [ ] **Step 3: Add Six-Line**

2 rows (5:1 payout).

- [ ] **Step 4: Add Racetrack (optional)**

Neighbor bets: Voisins, Orphelins, Tiers.

- [ ] **Step 5: Commit**

---

### Task 14: New Casino Game — Keno

**Files:**
- Create: `Modules/casino-keno.ps1`
- Modify: `Modules/casino.ps1` (add to menu)

- [ ] **Step 1: Create Keno**

Player picks 1-10 numbers from 1-80. 20 numbers drawn.
Paytable based on matches. Simple TUI with number grid.

- [ ] **Step 2: Add to Casino Hub**

- [ ] **Step 3: Commit**

---

### Task 15: New Casino Game — Wheel of Fortune

**Files:**
- Create: `Modules/casino-wheel.ps1`
- Modify: `Modules/casino.ps1`

- [ ] **Step 1: Create Wheel of Fortune**

Wheel with segments: 2x, 3x, 5x, 10x, 50x, BANKRUPT, JACKPOT.
Bet, spin wheel, animation slows down, lands on segment.
BANKRUPT = lose bet. JACKPOT = win progressive jackpot.

- [ ] **Step 2: Add to Casino Hub**

- [ ] **Step 3: Commit**

---

## Final Integration & Testing

### Task 16: Integration & Polish

**Files:**
- Modify: `Modules/_smoke_test.ps1`
- Modify: `Modules/_integration_test.ps1`
- Modify: `Modules/_e2e_test.ps1`
- Modify: `Modules/engine-aliases-buxe.ps1` (add `arcade` alias)

- [ ] **Step 1: Add all new functions to Smoke Test**

Verify all new games load and their entry functions exist.

- [ ] **Step 2: Add state checks to Integration Test**

Verify new state slots exist and persist correctly.

- [ ] **Step 3: Add E2E flows for new games**

Each new game gets a MockInput-based quit-path test.

- [ ] **Step 4: Verify LucasArts integration**

Check that `CPMetaLines` has all game contexts and companions have unique voices.

- [ ] **Step 5: Final commit and push**

```bash
git add -A
git commit -m "Phase 3 complete: Arcade & Casino Overhaul with new games, hub, and companion integration"
git push origin master
```

- [ ] **Step 6: Run full test suite**

```powershell
& ./Modules/_smoke_test.ps1
& ./Modules/_integration_test.ps1
& ./Modules/_e2e_test.ps1
```
