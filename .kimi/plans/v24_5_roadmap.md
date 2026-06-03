# BUXE_OS v24.5 — Roadmap

## Status Quo (2026-06-03)

- v24.4 fertig: E2E 16/16, Tetris, State-Refactoring
- 45 Module in Modules/, 13 Pet-Module
- Alle 3 Test-Suiten gruen: Smoke 45/45, Integration 18/18, E2E 16/16

---

## Phase 1: AGENTS.md Update v24.4

**Impact:** Mittel | **Aufwand:** Niedrig | **Risk:** Niedrig

- engine-state.ps1 entfernt -> 3 neue Module dokumentieren
- Tetris als neues Spiel dokumentieren
- Test-Zahlen: Smoke 45, Integration 18, E2E 16
- Version: v24.4

---

## Phase 2: Sound-Effekte fuer TUI-Spiele

**Impact:** Niedrig | **Aufwand:** Niedrig | **Risk:** Niedrig

- `[Console]::Beep` Wrapper in engine-input.ps1
- Spiele: Tetris (Line-Clear, Game-Over), Minesweeper (Reveal, Flag, Explosion)
- Optional: TTS-Hooks fuer Casino-Gewinne

---

## Phase 3: Neues Arcade-Spiel — Breakout

**Impact:** Mittel | **Aufwand:** Mittel | **Risk:** Niedrig

- Klassisches Breakout/Arkanoid
- Paddle (A/D), Ball-Physik, Bricks
- Level-System, Power-Ups
- TUI-Framework: Show-Scene + Invoke-GameLoop

---

## Empfohlene Reihenfolge

1. Phase 1 — AGENTS.md (sofort)
2. Phase 2 — Sound (optional, schnell)
3. Phase 3 — Breakout (neuer Content)
