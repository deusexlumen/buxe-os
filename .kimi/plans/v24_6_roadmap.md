# BUXE_OS v24.6 — Roadmap

## Status Quo (2026-06-03)

- v24.5 fertig: Sound-Effekte, Breakout, Gags entfernt
- 46 Module in Modules/, 13 Pet-Module
- Smoke 50/50, Integration 18/18, E2E 17/17

---

## Phase 1: Neues Casino-Spiel — Keno

**Impact:** Mittel | **Aufwand:** Niedrig | **Risk:** Niedrig

- 80 Zahlen, waehle 1-10
- 20 Zufallszahlen gezogen
- Auszahlung nach Treffern (1:1 bis 10:10000)
- TUI: Show-Scene + Read-GameChoice
- E2E: Quit-Path

---

## Phase 2: TUI-Framework Background-Farben

**Impact:** Mittel | **Aufwand:** Niedrig | **Risk:** Niedrig

- engine-render.ps1: BgColor Support in Delta-Render
- engine-scene.ps1: Add-SceneText/Frame mit BgColor
- Spiele: Tetris/Breakout farbige Bloecke

---

## Phase 3: Neues Arcade-Spiel — Space Invaders

**Impact:** Hoch | **Aufwand:** Mittel | **Risk:** Niedrig

- Spieler-Schiff (A/D), Schiessen (W/Leertaste)
- Aliens bewegen sich, schiessen zurueck
- Bunker/Deckung
- Wellen-System, Highscore
- TUI + Invoke-GameLoop

---

## Empfohlene Reihenfolge

1. Phase 1 — Keno (schnell, neuer Casino-Content)
2. Phase 2 — Background-Farben (Framework-Upgrade)
3. Phase 3 — Space Invaders (Highlight)
