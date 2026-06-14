# Adventure System — LucasArts-Style UX Overhaul

> **Ziel:** Das Text-Adventure (`adv`) so textlich aufbohren, dass es sich nach den LucasArts-Regeln aus `LUCASARTS.md` anfühlt: selbstbewusst, fourth-wall-breaking, humorvoll, niemals wirklich bestrafend.
>
> **Scope:** Keine Spiel-Logik-Änderung. Nur User-facing Strings, neue Companion-Hooks und Testsicherheit.

---

## 1. Baustellen (aus Audit)

| Bereich | Problem | Massnahme |
|---------|---------|-----------|
| `adventure-engine.ps1` | Standardmeldungen sind generisch ("Das siehst du hier nicht.") | Zentrale `Get-AdventureMessage`-Tabelle mit LucasArts-Flavour |
| `adventure-engine.ps1` | Tod = `=== GAME OVER ===`, dramatisch | In humorvollen Respawn-Text umwandeln; neuer `Death`-Flag im Result |
| `adventure-world.ps1` | Raum-/Objektbeschreibungen neutral | 15+ Schlüssel-Räume/Objekte mit selbstreferentiellem Text |
| `adventure-companion-ai.ps1` | Running Gags, Hinweise, Events einheitsbrei | Per-Companion-Arrays für `examine`, `go`, `use`, `warn`, `find`, `atmo`, `egg`, `hint` |
| Adventure insgesamt | Tod/Sieg ohne Companion-Kommentar | Neue Kontexte `adventure_death_*`, `adventure_win_*`, `adventure_eva_*` in `pet/_ui.ps1` und Hooks im Adventure |

---

## 2. Systematischer Arbeitsplan

### Phase 1: Engine-Meldungen + Tod (Impact / Risiko: hoch / gering)
1. `Get-AdventureMessage($Key, $Params)` in `adventure-engine.ps1` einführen.
2. Alle hartkodierten Engine-Returns durch `Get-AdventureMessage` ersetzen.
3. Tod bei EVA/Sauerstoff/Hollow in `Process-AdventureCommand` umschreiben: kein "GAME OVER", stattdessen Respawn-Hinweis + `Death = $true`.
4. Smoke/Integration-Tests anpassen: statt `-match "GAME OVER"` prüfen auf `$result.Death -eq $true`.

### Phase 2: Welt-Texte (Impact / Risiko: mittel / gering)
1. Schlüssel-Räume (`hangar`, `corridor`, `bridge`, `eva`, `core`, `airlock`, `engine`, `medbay`, `armory`, `quarters`, `observatory`, `cafeteria`, `vent`, `secret`, `lab`, `server`) selektiv umschreiben.
2. Schlüssel-Objekte (`terminal`, `box`, `notebook`, `screen`, `diary`, `computer`, `artifact_pedestal`, `warning_sign`, `cable`) mit Stimme versehen.
3. NPC-Dialoge (Wächter-Droide, Kapitän Vance, SIE, Hologramme) auf per-Companion-Logik vorbereiten oder zumindest selbstbewusster machen.

### Phase 3: Companion-AI (Impact / Risiko: mittel / mittel)
1. In `adventure-companion-ai.ps1` generische Arrays (`$RunningGagLines`, `$FindLines`, `$AtmoLines`, `$WarnLines`, `$EggLines`, `$HintLines`) in per-Companion-Hashtables umwandeln.
2. `Test-RunningGag`, `Invoke-CompanionEvent`, `Get-CompanionHint` auf neue Struktur umstellen.
3. Fallback-Logik: fehlt ein Companion-Eintrag, wird die alte generische Zeile verwendet.

### Phase 4: Neue Adventure-Kontexte im Pet-UI (Impact / Risiko: mittel / gering)
1. In `Modules/pet/_ui.ps1` neue `CPActionLines`-Kontexte ergänzen:
   - `adventure_death_eva`, `adventure_death_oxygen`, `adventure_death_hollow`
   - `adventure_win_normal`, `adventure_win_true`
   - `adventure_eva_no_suit`, `adventure_eva_with_suit`
   - `adventure_take_keycard`, `adventure_take_rubber_chicken`, `adventure_take_skull`, `adventure_take_tree`
   - `adventure_use_terminal`, `adventure_bridge_unlocked`, `adventure_locked`
2. `Show-GameCompanionComment` ggf. um Adventure-Kontexte erweitern.

### Phase 5: Tests & Regression
1. Smoke, Integration, E2E laufen lassen.
2. Neue Smoke-Checks: `Death`-Flag wird gesetzt, `Get-AdventureMessage` existiert, 3 wichtige Räume haben nicht-generischen Text.
3. Keine Duplikate / keine neuen `script:`-Konflikte (Integration-Test-AST-Check).

---

## 3. Architektur

```
Parser -> Process-AdventureCommand
            |
            +--> Get-AdventureMessage($Key, $Params)   [Engine-Texte]
            |
            +--> Invoke-AdventureCompanionHook         [Companion-Kommentare]
            |        |
            |        +--> Get-CompanionLine $cp $context   [aus pet/_ui.ps1]
            |
            +--> Return @{ Success=...; Message=...; Death=...; ... }
```

### Neue / geänderte Funktionen

| Funktion | Datei | Zweck |
|----------|-------|-------|
| `Get-AdventureMessage` | `adventure-engine.ps1` | Zentrale Lookup-Tabelle für alle generischen Engine-Meldungen |
| `Invoke-AdventureCompanionHook` | `adventure-companion-ai.ps1` | Wird nach relevanten Befehlen aufgerufen; mapped auf `Get-CompanionLine` |
| `Get-AdventureCompanionContext` | `adventure-companion-ai.ps1` | Bestimmt Kontext aus Verb/Noun/Raum/Result |
| `Test-RunningGag` (modifiziert) | `adventure-companion-ai.ps1` | Nutzt per-Companion-Arrays |
| `Get-CompanionLine` (bereits vorhanden) | `pet/_ui.ps1` | Löst Kontext in zufällige Zeile auf |

---

## 4. Design-Regeln für neue Texte

1. **Kein echtes Game Over.** Tod wird als Respawn/Checkpoint/Witz behandelt.
2. **Self-aware.** Charaktere wissen, dass sie in einer PowerShell-Session leben (`save`, `load`, `Q`, JSON, State).
3. **Fourth-wall.** Direkte Ansprache des Users, Referenzen auf Tasten/Befehle.
4. **Kein generischer Fantasy-Text.** Jede Zeile hat eine konkrete Beobachtung oder Stimme.
5. **47-Rule.** Der Gag wird sparsam, aber konsistent eingestreut.
6. **Fallback-safe.** Fehlt ein Companion-Kontext, wird generischer Text verwendet, nie ein Crash.

---

## 5. Testing

- Smoke: `& .\Modules\_smoke_test.ps1` muss weiterhin 220/220 bestehen.
- Integration: `& .\Modules\_integration_test.ps1` muss weiterhin 116/116 bestehen.
- E2E: `& .\Modules\_e2e_test.ps1` muss `ALL E2E CHECKS PASSED` zeigen.
- Spezifische Test-Updates:
  - `EVA without suit = death` prüft `$result.Death -eq $true` statt `-match "GAME OVER"`.
  - Keine String-Assertions auf Texte, die wir gerade umschreiben.

---

## 6. Dateien, die geändert werden

- `Modules/adventure-engine.ps1`
- `Modules/adventure-world.ps1`
- `Modules/adventure-companion-ai.ps1`
- `Modules/adventure.ps1` (Intro/Outro)
- `Modules/pet/_ui.ps1` (neue Kontexte)
- `Modules/_smoke_test.ps1` (Test-Assertion anpassen)
- `Modules/_integration_test.ps1` (Test-Assertion anpassen)
- `docs/superpowers/specs/2026-06-14-adventure-lucasarts-design.md` (diese Datei)

---

## 7. Nicht im Scope

- Neue Räume, Objekte oder Puzzle.
- Adventure-State-Schema-Änderungen (ausser dem neuen `Death`-Flag im Befehlsresultat).
- Änderungen am Parser.
- Änderungen an Casino/Pet-Logik.
