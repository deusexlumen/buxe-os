# Arbeitsauftrag Code-KI — Paket 2 (Texteinsatz): PLACEHOLDER ersetzen

> Abschlussschritt zu Paket 2. Das Gerüst steht bereits (Tests grün). Hier ersetzt du die
> `[PLACEHOLDER: …]`-Strings durch den **freigegebenen** Text. **Du erfindest, kürzt oder
> „verbesserst" nichts** — 1:1-Übernahme. Bei jeder Unklarheit in der Zuordnung: pausieren
> und rückfragen.

---

## Textquellen (beide unter `docs/superpowers/specs/`)

1. `2026-07-08-opus-lieferung-ensemble-beat12.md` — Beat 1 & 2 aller drei Figuren + die
   Companion-Erinnerungen BEGEGNUNG/SCHULD für **NEON, RAVEN, PIXEL, LUNA, VERA**.
2. `2026-07-08-ensemble-chefsache-beat3-ivy-jinx.md` — Beat 3 aller drei Figuren + die
   Companion-Erinnerungen BEGEGNUNG/SCHULD für **IVY** und **JINX**.

---

## Einsatz-Ziele

### A) Ensemble-Zeilen → `Modules/pet/_init.ps1`, `$script:BuxeEnsembleLines`
- `PRUEFER[1]`, `PRUEFER[2]`, `PRUEFER[3]` ← die PRÜFER-Tabellenzeilen (Beat 1/2 aus Quelle 1,
  Beat 3 aus Quelle 2).
- `RIVALE[1]`, `RIVALE[2]`, `RIVALE[3]` ← analog.
- `QUELLE[1]`, `QUELLE[2]`, `QUELLE[3]` ← analog.
- Jede Beat-Liste enthält genau die Zeilen der jeweiligen Tabelle (Reihenfolge egal, es wird
  `Get-Random` gezogen). Die PLACEHOLDER-Einträge komplett ersetzen, nicht ergänzen.

### B) Companion-Erinnerungen → `Modules/pet/memory.ps1`
Struktur dort: `BEGEGNUNG = @{ NEON=@(...); RAVEN=@(...); … }` und `SCHULD = @{ … }`.
- **BEGEGNUNG**, je Companion: die Zeilen aus der Spalte „BEGEGNUNG" (Quelle 2, IVY+JINX) bzw.
  der BEGEGNUNG-Tabelle (Quelle 1, NEON/RAVEN/PIXEL/LUNA/VERA). Bestehende, bereits befüllte
  Zeilen (VERA, JINX) **behalten** und die neuen dazunehmen; die `[PLACEHOLDER: BEGEGNUNG …]`
  ersetzen.
- **SCHULD**, je Companion: analog aus den SCHULD-Tabellen. Bestehende NEON/VERA-Zeilen behalten,
  Placeholder ersetzen.

---

## Zuordnungsregeln
- Die Companion-Tabellen nennen den Companion in Spalte 1 — eindeutig zuordenbar.
- `{date}` und `{AMOUNT}` als **Literal** übernehmen (die bestehende Token-Ersetzung im
  Memory-/Anzeige-System füllt sie zur Laufzeit — nicht selbst auflösen).
- Anführungszeichen: In `memory.ps1` bereits `„…"` bzw. `"` je nach Bestand — übernimm die
  Zeichen aus der Quelldatei so, dass die PowerShell-String-Begrenzung nicht bricht (ggf.
  doppelte `"` in `@"…"@` oder einfache Quotes verwenden, wie im Bestand üblich).

## Encoding (kritisch)
- `Modules/pet/*.ps1` bleiben **UTF-8 mit BOM**. Die Ensemble-Beat-Zeilen (Quelle) enthalten
  echte Umlaute → in `_init.ps1` so übernehmen.
- Die Memory-Zeilen sind in den Quelldateien bereits **ASCII (`ae/oe/ue`)** transliteriert,
  passend zum `memory.ps1`-Bestand → 1:1 so übernehmen, nicht rück-umlauten.

## Verbote
- Kein Eigen-Text, keine Umformulierung, keine zusätzlichen Zeilen.
- Beat-3-, IVY- und JINX-Zeilen nicht abschwächen/kürzen — sie tragen die Dramaturgie.
- Keine Struktur- oder Logikänderung am Gerüst (das ist abgenommen).

## Akzeptanzkriterien
1. Kein `[PLACEHOLDER: …]` mehr in `_init.ps1` (Ensemble) und in den BEGEGNUNG/SCHULD-Zweigen
   von `memory.ps1`.
2. `Get-EnsembleLine "PRUEFER" 3` (analog RIVALE/QUELLE) liefert echten Text, keinen Placeholder.
3. BEGEGNUNG/SCHULD liefern für alle 7 Companions echten Text; bestehende VERA/JINX/NEON-Zeilen
   sind erhalten geblieben.
4. `_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1` weiterhin grün.
5. Dateien weiterhin UTF-8 mit BOM; keine Mojibake bei Umlauten in `_init.ps1`.
