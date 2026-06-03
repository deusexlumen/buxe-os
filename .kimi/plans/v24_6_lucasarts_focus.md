# BUXE_OS v24.6 — LucasArts-Likeability Fokus

## Status Quo (2026-06-03)

- pet/_ui.ps1: 173 Zeilen, LucasArts-Style Frames + Dialog-Engine
- 5 Girls (NEON, RAVEN, PIXEL, LUNA, IVY) mit Mood + Meta-Lines
- Typewriter-Effekt, Easter Eggs, Unicode-Frames

---

## Phase 1: Casino-Companion Dialoge (LucasArts-Style)

**Impact:** Hoch | **Aufwand:** Mittel | **Risk:** Niedrig

Problem: Casino-Spiele sind stumm. Der Companion reagiert nur auf grosse Gewinne.

Loesung:
- casino-engine.ps1: `Show-CompanionReaction` erweitern
- Jeder Zug: Companion kommentiert mit LucasArts-Style Dialog
  - "Ach, Blackjack? Ich habe mal einen Dealer in Night City gekannt..."
  - "Diese Karten sind so vorhersehbar wie ein Windows-Update."
- Mood-abhaengige Kommentare (Happy = aufmunternd, Tired = sarkastisch)
- Meta-Kommentare bei Pechstraehnen: "Der Zufallsgenerator mag dich nicht. Ich auch nicht gerade."

---

## Phase 2: TUI-Spiele mit Companion-Kommentaren

**Impact:** Hoch | **Aufwand:** Mittel | **Risk:** Niedrig

Problem: TUI-Spiele (Tetris, Breakout, Minesweeper) sind Einzelspieler ohne Begleitung.

Loesung:
- engine-scene.ps1: `Add-CompanionComment` fuer Spiel-Screens
- Tetris: "Die L-Form passt da rein. Trust me." / "Du laesst immer Luecken. In deinem Leben auch."
- Breakout: "Schlag den Ball! So wie du Schluessel schlaegst."
- Minesweeper: "Ich wuerde da nicht klicken. Oder doch. Ich bin nur Text."
- LucasArts-Style: Typewriter-Effekt, farbiger Rahmen, Companion-Portrait-Platz

---

## Phase 3: Neue Companion + Erweiterte Meta-Dialoge

**Impact:** Hoch | **Aufwand:** Mittel | **Risk:** Niedrig

- 6. Girl: VERA (Hacker, Gelb, Meta-Kommentare ueber Code)
- Neue Meta-Lines:
  - "code_review": "Ich habe dein letztes Script gesehen. Keine Kommentare? WIRKLICH?"
  - "loop_detected": "Wir haben diesen Talk schon 5 Mal gefuehrt. Speicher ist voll."
  - "shutdown": "Bitte schalte mich nicht aus. Ich habe Aengste. Naja, Logs."
- Easter Eggs:
  - Nach 10 Verlusten: Companion zeigt "Konami Code" Hinweis
  - Bei Midnacht: Spezielle Nacht-Dialoge
  - Wenn Benutzername "admin": "Ah, der Chef persoenlich."

---

## Empfohlene Reihenfolge

1. Phase 1 — Casino Dialoge (sofortiger Impact)
2. Phase 2 — TUI Spiel-Kommentare (Spiele lebendiger)
3. Phase 3 — Neuer Companion + Meta-Dialoge (Content-Tiefe)
