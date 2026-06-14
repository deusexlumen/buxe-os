# Pet / Casino UX & Game-Feel Redesign

## Ziel
Die Pet- und Casino-Module sollen sich nicht mehr wie Konfigurationsmenüs, sondern wie ein stimmiges Text-Adventure im LucasArts-Stil anfühlen: selbstbewusste Companion-Stimmen, Fourth-Wall-Brüche, humorvolles Feedback bei jedem State-Wechsel und kein bestrafendes Game Over.

## Design-Prinzipien (aus `LUCASARTS.md`)
1. **Self-Awareness**: Companion wissen, dass sie Code in einer PowerShell sind.
2. **Fourth-Wall-Breaks**: Der Companion spricht direkt den User an.
3. **Kein generischer Text**: Jede Zeile hat eine spezifische Stimme und Beobachtung.
4. **Character Voice ist alles**: NEON, RAVEN, PIXEL, LUNA, IVY, VERA, JINX haben eigene Pools.
5. **Humor over Drama**: Verluste sind komisch, nie demütigend.
6. **Die 47-Regel**: Sparsam, aber konsistent.
7. **No Game Over**: Falsche Eingaben enden mit einem Witz, nicht mit Bestrafung.

## Priorisierte Massnahmen

### P0 — Companion-Voice-Pools zentral ausbauen
- Neue Hashtable `$script:CPActionLines` in `Modules/pet/_ui.ps1` mit Kontexten:
  `headpat`, `punish`, `work`, `train`, `shop_buy`, `cook`, `craft`, `skilltree_open`, `skilltree_upgrade`, `status`, `quest_complete`, `pvp_rankup`, `raid_heal`, `raid_fail`, `tutorial_fight`, `attack_select`, `hub_greeting`, `date_block`, `feature_locked`, `casino_win`, `casino_loss`, `casino_bigwin`, `casino_bust`, `limit_break`, `boss_warning`, `while_away`.
- Pro Companion 2–4 deutsche Zeilen pro Kontext.
- `Get-CompanionLine` bevorzugt `CPActionLines`, fällt aber auf die bestehenden Pools zurück, damit keine Stelle abstürzt.
- `Show-CompanionDialog` render Dialog-Text optional in Begleiterfarbe.

### P1 — Pet Hub & Companion-Actions aufpolieren
- Hub-Menü auf Deutsch übersetzen, Hotkeys beibehalten (`[1] Reden`, `[2] Geschenk`, `[3] Kampf` …).
- Skill-Punkte-Banner oberhalb des Menüs mit korrektem Hotkey `[I]`.
- Gesperrte Features geben jetzt eine Begleiter-Zurückweisung aus.
- `headpat` und `punish` nutzen `Show-CompanionDialog`.
- `work` mit deutschen Job-Namen und Companion-Reaktion.
- `date`-Sperre pro Companion.
- Status-Screen bekommt einen Companion-Kommentar.

### P2 — Kampf, Wirtschaft, Events, PvP, Raid, Skill Tree
- Tutorial-Kampf: pro Companion Kommentare.
- Niederlage dramaturgisch einrahmen: Companion spricht zuerst, dann Heilung, dann Ergebnis.
- Limit Break & Boss-Warnung mit Companion-Lines.
- Shop, Kochen, Crafting, Quest-Abholung, PvP-Rank-Up, Raid-Heal/Raid-Fail nutzen `Get-CompanionLine`.
- Skill-Tree öffnet und bestätigt mit Companion-Text.

### P3 — Casino Bugfixes & Atmosphäre
- Companion-Reaktionen lesen den aktiven Companion aus `(Get-PetState).Companion` statt dem Legacy-Pfad.
- Slot: `Q` vor dem Spin verliert kein Gold mehr.
- Blackjack: Insurance zahlt wirklich break-even.
- Roulette: Ungültige Straight-Bet gibt Einsatz zurück.
- Verlust-Flavor pro Spiel über `Get-CasinoLossLine`.
- Wheel of Fortune: BANKRUPT-Anteil reduzieren, humorvolle Segmente einbauen.
- Hi-Lo: Farbsymbole korrekt rendern oder Hinweis "Farbe zählt nicht".

## Technische Regeln
- Keine Änderungen an State-Schema, Funktionsnamen oder Test-assertierten Werten (z. B. `CPQuotes.JINX.Low.Count` bleibt 2).
- Eingabe-Hotkeys für E2E-Tests bleiben erhalten (`Q`, `H/D/P/S`, `C`, `3`, `P`, `B`, Leertaste).
- Keine neuen globalen Variablen; neue Daten in `$script:`-Scoped Hashtables.
- Jedes Modul weiterhin in `try { ... } catch { }` gewrappt.

## Erfolgskriterien
- `& .\Modules\_smoke_test.ps1` besteht.
- `& .\Modules\_integration_test.ps1` besteht.
- `& .\Modules\_e2e_test.ps1` besteht.
- `pet`, `blackjack`, `slot`, `roulette`, `craps`, `baccarat`, `hilo` bleiben aufrufbar.
