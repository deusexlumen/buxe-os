# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Doku-Sprache dieses Repos ist Deutsch (Ausnahme: `LUCASARTS.md`). Kommentare und
> User-facing Output auf Deutsch, Funktions-/Variablennamen auf Englisch.

## Was ist das

BUXE_OS — ein PowerShell-Profil-System fuer Windows (PS 7 / 5.1), das die Shell in eine
Spielwelt verwandelt: Casino, Arcade, Strategy, Text-Adventure, Pet/Companion-RPG,
Desktop-Pet, TTS, Alias-Sammlung. Kein Build-Step, kein Paketmanager — alles wird per
Dot-Sourcing aus `Microsoft.PowerShell_profile.ps1` geladen.

## Zuerst lesen

| Datei | Inhalt |
|---|---|
| `AGENTS.md` | Architektur, Modul-Inventar, State-Schema, Style-Guide. Ausfuehrlich, aber auf Stand v24 (siehe "Stale" unten). |
| `LUCASARTS.md` | **Pflicht vor jedem user-facing Text.** Companion-Stimmen-Tabelle, 7 Design-Regeln, 47-Gag. |
| `GUIDE.md` | Endbenutzer-Befehlsliste. |
| `docs/superpowers/{specs,plans}/` | Design-Specs und Implementierungsplaene, `YYYY-MM-DD-name.md`. Neue Features bekommen hier zuerst eine Spec. |

## Tests

```powershell
& .\Modules\_smoke_test.ps1        # Engines, State, Pet, Adventure (~65 Checks)
& .\Modules\_integration_test.ps1  # AST-Checks: Duplikate, script:-Konflikte (~30 Checks)
& .\Modules\_e2e_test.ps1          # Laedt das ganze Profil + 17 Game-Flows via Mock-Input
& .\Scripts\watch-test.ps1         # Watch-Loop: Smoke+Integration bei jeder Modul-Aenderung
```

**Exit-Codes sind unzuverlaessig.** Smoke- und Integration-Test setzen *keinen* Exit-Code —
sie schreiben `[PASS]`/`[FAIL]` plus Summary nach stdout. Ergebnis nur ueber die
Ausgabe pruefen:

- Smoke: `"ALL TESTS PASSED"`
- Integration: `"ALL INTEGRATION TESTS PASSED"`
- E2E: `"=== ALL E2E CHECKS PASSED ==="` — nutzt zusaetzlich echtes `exit 1` bei Fehlern

Ein Crash im Smoke-Test endet in `[CRITICAL]` und ueberspringt die Summary komplett —
fehlende Pass-Zeile heisst also immer "nicht bestanden", nie "keine Ausgabe".

**Einzelne Tests gibt es nicht** — es existiert kein Filter/`-Name`-Parameter. Entweder
eines der drei Skripte komplett laufen lassen, oder das Modul direkt dot-sourcen und
die Funktion aufrufen:

```powershell
. .\Modules\engine-state-core.ps1; . .\Modules\pet\_init.ps1; Get-PetState
```

Es gibt **keinen Linter und kein Pester-Setup** — `Modules/Pester/` ist gitignorte
Drittanbieter-Software, die drei Test-Skripte sind handgeschriebene `Test-Assert`-Loops.

**Tests sind nicht hermetisch.** Sie laden die echten Module und schreiben in den echten
State (`%LOCALAPPDATA%\buxe\buxe_state_v24.json`). Der Smoke-Test sichert und restauriert
nur den Pet-Teil. Vorher sichern, wenn der eigene Spielstand wichtig ist.

## Debugging

`$env:BUXE_DEBUG=1` schaltet das globale try/catch im Profil ab, damit echte Stacktraces
sichtbar werden. Ohne das verschluckt das Profil jeden Ladefehler und startet im
Fallback-State (Gold 500).

Profil neu laden: `reload`. Nach jeder Modul-Aenderung noetig.

## Load-Order (die eigentliche Architektur-Regel)

`Microsoft.PowerShell_profile.ps1` ist der einzige Ort, an dem die Reihenfolge stimmt, und
sie ist nicht beliebig:

1. `engine-state-core` → `engine-state-migration` → `engine-state-advanced` → `engine-bus`
2. `Load-State` (muss vor allen Feature-Modulen laufen)
3. restliche Engines, Feature-Module, Pet-System
4. `pet/combat-core.ps1` **nach** `pet/combat.ps1` (liest `$script:BPAttacks`) — das
   Pet-Glob im Profil schliesst `combat-core.ps1` explizit aus und laedt es danach
5. `world-events.ps1` **als letztes** — hier wird alles verdrahtet

Die Test-Loader machen das *nicht* nach: sie globben `pet\*.ps1` naiv (`combat-core.ps1`
sortiert vor `combat.ps1`) und laden `engine-bus`, `world-events`, `engine-render`,
`engine-input`, `engine-scene` teilweise gar nicht. Aktuell harmlos (combat-core greift
auf `BPAttacks` erst zur Laufzeit zu), aber jeder neue Top-Level-Zugriff bricht genau hier.

**Ein neues Modul heisst: bis zu vier Loader anfassen** — Profil, `_smoke_test.ps1`,
`_integration_test.ps1` (hand-gepflegte `$modules`-Liste), `_e2e_test.ps1` (`$required`-Liste).

## Event-Bus (v25, fehlt in AGENTS.md)

Seit v25 rufen Subsysteme einander nicht mehr direkt auf:

- `engine-bus.ps1` — `Publish-BuxeEvent -Topic "casino.jackpot" -Data @{...}`,
  `Subscribe-BuxeEvent -Topic "combat.*" -Priority 50 -Handler {...}`. Wildcards,
  Prioritaeten, Deferred Queue gegen Reentranz, isolierte Handler-Fehler,
  Dead-Letter-Log (`Show-BuxeBusDebug`).
- `world-events.ps1` — der **einzige** Ort, an dem Casino/Pet/ARG/Quests voneinander
  wissen. Neue Cross-System-Effekte gehoeren hierhin, nicht ins Feature-Modul.
- `pet/combat-core.ps1` — reiner Reducer `(State, Action) -> { State, Events }`.
  Zero UI, kein `Write-Host`, kein `Read-Host`, kein `Save-State`; headless simulierbar
  (`Invoke-CombatSimulation`). UI liegt getrennt in `pet/combat-ui.ps1`.

Neue Spiel-Logik in diesem Stil schreiben: Kernel rein, UI aussen.

## State

- Haupt-State: `%LOCALAPPDATA%\buxe\buxe_state_v24.json` (+ `.bak1`–`.bak5` Rotation,
  atomarer Write via `.tmp` → `Move-Item`, Corrupt-Recovery auf Defaults).
- Adventure separat: `%LOCALAPPDATA%\buxe\buxe_adventure.json`.
- ARG separat: `%APPDATA%\BUXE_OS\arg-state.json` — ueberlebt bewusst `reset-buxe`.
- TTS-Stimme: `%USERPROFILE%\.kimi\tts-config.json`.
- Nur `$script:`-Scope, nie `$global:`. Neue Felder in `Get-StateDefaults`
  (`engine-state-core.ps1`) bzw. `Get-PetDefaults` registrieren, sonst fehlen sie nach
  Migration.

## Konventionen, die Tests durchsetzen

- Jedes Modul komplett in `try { ... } catch { }` — ein Syntaxfehler darf nie das ganze
  Profil killen.
- Keine doppelten Funktionsnamen und keine kollidierenden `$script:`-Variablen ueber
  Module hinweg — der Integration-Test prueft das per AST.
- `[Console]::CursorPosition`, `CursorVisible`, `Clear-Host`, `$Host.UI.RawUI` immer in
  try/catch: in headless/E2E-Kontexten werfen sie "Das Handle ist ungueltig".
- Engine-Module (`engine-*`, `casino-engine`) sind **reines ASCII** — keine Umlaute,
  Emojis, Box-Drawing. Game-Module duerfen UTF-8/Umlaute in User-Strings nutzen;
  `pet/_ui.ps1` nutzt Unicode-Frames als bewusste Ausnahme.
- Datei-Header: `# BUXE_OS v<ver> -- MODULNAME`.
- Interaktive Flows: `Show-Frame` oben, `Wait-Enter` unten, `[Q]` = Quit/Back.
- TUI-Spiele bauen Scenes (`New-Scene` / `Add-SceneText` / `Add-SceneFrame` /
  `Add-SceneBar` / `Add-SceneBlock` / `Show-Scene`) statt direktem
  `Write-Host`, Input via `Read-GameChoice`. Neuen Game-Flow immer mit
  `Enable-MockInput` / `Queue-MockInput` in `_e2e_test.ps1` eintragen.
- Commits: Conventional Commits mit Scope (`feat(pet):`, `fix(adventure):`), deutsche
  Beschreibung, ASCII-only.

## Stale in AGENTS.md

`AGENTS.md` beschreibt v24 und kennt diese Module nicht: `engine-bus.ps1`,
`engine-arg.ps1` (ARG "Meridian Signal", eigener State), `world-events.ps1`,
`tts-engine.ps1` (TTS lebt nicht mehr nur im Profil), `pet/combat-core.ps1`,
`pet/combat-ui.ps1`, `pet/memory.ps1`, `pet/companion-story.ps1`,
`pet/companion-story-data.ps1`, `pet/_hollow.ps1`, `pet/act1-session47.ps1`.

Ausserdem falsch: AGENTS.md (Zeilen 170, 182-183, 524) und der Kommentar in
`engine-scene.ps1:107` nennen ein `Add-ToScene`. Diese Funktion existiert nicht —
die echten Namen sind `Add-SceneElement` / `-SceneText` / `-SceneFrame` / `-SceneBar` /
`-SceneBlock`. Bei Architektur-Aussagen aus AGENTS.md gegen das Profil gegenpruefen.

`SESSION_NOTES.md` und `achievements.json` sind gitignored — kein geteilter Kontext.
