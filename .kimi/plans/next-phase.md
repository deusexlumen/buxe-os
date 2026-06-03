# BUXE_OS v24 — Naechste Phase: Vorschlag

## Status Quo (2026-06-03)

- 13 Spiele auf TUI-Framework migriert ✅
- Phase 5 Robustheit (Audit, Transactions, Recovery) ✅
- Smoke 34/34 | Integration 18/18 | E2E clean ✅
- Boot Tips ✅

---

## Option A: E2E-Test mit echten Spiel-Flows (Empfohlen)
**Impact:** Hoch | **Aufwand:** Mittel | **Risk:** Niedrig

Problem: E2E testet nur "laedt das Profil" und "existieren die Funktionen". Ein Runtime-Bug in einem Spiel-Loop (z.B. Endlos-Loop, Null-Reference im TUI-Render) wird nicht erkannt.

Plan:
1. `Read-GameChoice` erweitern um optionalen `$MockInput`-Parameter (Test-Mode)
2. E2E-Test um `Invoke-GameWithMockInput` Pattern erweitern
3. Pilot: `hilo` durchspielen mit vorprogrammierten Eingaben ([C]ashout nach 2 Runden)
4. Pilot: `slot` einmal spin + quit
5. Alle Casino-Spiele mit Quit-Path testen

Kriterien:
- Keine Aenderung am Produktionsverhalten bei `$MockInput = $null`
- Test laeuft < 10 Sekunden
- Crash in Spiel → E2E FAIL

---

## Option B: GUIDE.md auf v24 aktualisieren
**Impact:** Hoch | **Aufwand:** Mittel | **Risk:** Niedrig

Problem: GUIDE.md listet noch `companion.ps1`, `battlepet.ps1`, `hub.ps1` als Module. TUI-Framework, State-Transactions, Audit-Log, Pet System v2.0 fehlen.

Plan:
1. Architektur-Section aktualisieren (TUI Framework, 30+ Module, pet/ Subfolder)
2. Casino-Section: TUI-Features erwaehnen (kein Flicker, Unicode-Frames)
3. Companion-Section: v2.0 Architektur, Easter Eggs, Meta-Kommentare
4. Neue Commands dokumentieren (daily, boot tips, transaction pattern)
5. `h` Output in GUIDE.md synchronisieren

---

## Option C: Neues Spiel — Minesweeper (TUI)
**Impact:** Mittel | **Aufwand:** Niedrig | **Risk:** Niedrig

Ein klassisches Grid-Spiel, perfekt fuer das TUI-Framework:
- 10x10 Grid, 10 Minen
- [Enter] reveal, [F] flag, [Q] quit
- Timer, Win/Loss Counter
- ~80 Zeilen, ein Modul: `arcade-minesweeper.ps1`

---

## Option D: Auto-Backup Rotation
**Impact:** Mittel | **Aufwand:** Niedrig | **Risk:** Niedrig

`Save-State` rotiert automatisch die letzten 5 State-Files:
- `buxe_state_v24.json` (current)
- `buxe_state_v24.json.bak1` (last)
- `...bak2`, `...bak3`, `...bak4`, `...bak5`

Schuetzt vor Datenverlust durch Crash waehrend Save.

---

## Empfehlung

**Option A** — E2E mit Spiel-Flows. BUXE_OS hat jetzt 13 interaktive Spiele und kein automatisierter Test deckt deren Runtime ab. Das ist der groesste ungedeckte Risk.
