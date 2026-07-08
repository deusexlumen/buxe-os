# Arbeitsauftrag Code-KI — Paket 2 (Gerüst): Ensemble-Mechanik

> Vollständiger, in sich geschlossener Auftrag. Du baust **nur Mechanik und Datenstruktur** —
> **keinen einzigen Dialogtext**. Alle Textzeilen bleiben in diesem Schritt der Literal-String
> `"[PLACEHOLDER: <Kennung>]"`. Der echte Text wird später vom Creative Director geliefert und
> in genau diese Slots eingesetzt. Lies zuerst "Kontext & Ziel", dann arbeite die Schritte der
> Reihe nach ab.

---

## Kontext & Ziel

BUXE_OS hat drei wiederkehrende Welt-Figuren, die aktuell nur als gesichtslose Mechanik
existieren: **DER PRÜFER** (Steuer-Raid), **DER RIVALE** (`Modules/pet/rival.ps1`) und
**DIE QUELLE** (Pity-Quest bei `casino.bust`). Ziel dieses Auftrags: das mechanische Gerüst,
damit jede Figur je nach einseitigem Beziehungs-State einen von **drei Beats** (1/2/3) zeigen
kann. Der Dialogtext folgt später — du baust die Slots, die Auswahllogik und die State-Felder.

**Design-Grundgesetz (unbedingt einhalten):** Das Ensemble ist WELT, nicht FAMILIE.
- Kein Ensemble-Mitglied wird je in `Get-DesktopPetComment` eingehängt (kein Shell-Kommentar).
- Kein Ensemble-Mitglied bekommt einen `Bond`. Jede Figur hat einen eigenen, einseitigen
  State (unten).
- Auftritte passieren nur an den genannten Triggern, nie sonst.

---

## Zieldatenstruktur

Neue Konstante (Ablageort: passendes Modul, z. B. ein neues `Modules/pet/ensemble.ps1` oder
in `world-events.ps1` — wähle konsistent zum Projekt). Beats statt Bond-Stufen:

```powershell
$script:BuxeEnsembleLines = @{
    PRUEFER = @{
        1 = @("[PLACEHOLDER: PRUEFER BEAT1 1]", "[PLACEHOLDER: PRUEFER BEAT1 2]")
        2 = @("[PLACEHOLDER: PRUEFER BEAT2 1]", "[PLACEHOLDER: PRUEFER BEAT2 2]")
        3 = @("[PLACEHOLDER: PRUEFER BEAT3 1]")   # Beat 3 = Chefsache, bleibt PLACEHOLDER
    }
    RIVALE = @{
        1 = @("[PLACEHOLDER: RIVALE BEAT1 1]", "[PLACEHOLDER: RIVALE BEAT1 2]")
        2 = @("[PLACEHOLDER: RIVALE BEAT2 1]", "[PLACEHOLDER: RIVALE BEAT2 2]")
        3 = @("[PLACEHOLDER: RIVALE BEAT3 1]")
    }
    QUELLE = @{
        1 = @("[PLACEHOLDER: QUELLE BEAT1 1]", "[PLACEHOLDER: QUELLE BEAT1 2]")
        2 = @("[PLACEHOLDER: QUELLE BEAT2 1]", "[PLACEHOLDER: QUELLE BEAT2 2]")
        3 = @("[PLACEHOLDER: QUELLE BEAT3 1]")
    }
}
```

Hilfsfunktion zum Ziehen einer Zeile:

```powershell
function Get-EnsembleLine($Figure, $Beat) {
    $set = $script:BuxeEnsembleLines[$Figure]
    if (-not $set -or -not $set[$Beat] -or $set[$Beat].Count -eq 0) { return $null }
    return ($set[$Beat] | Get-Random)
}
```

---

## Umsetzung — Schritte

### 1. State-Felder (lazy migrieren, wie `GlitchUsed`)
Auf `$pet.Meta` bei Bedarf anlegen, nie hart voraussetzen:
- `AuditSuspicion` (int, Default 0) — Prüfer.
- `SourceDebt` (int, Default 0) — Quelle.
- `RivalWins` **existiert bereits** (`rival.ps1`) — nicht neu anlegen, nur lesen.

Muster für lazy Default (Konvention im Projekt):
`if ($null -eq $pet.Meta.AuditSuspicion) { $pet.Meta.AuditSuspicion = 0 }`

### 2. Beat-Ermittlung je Figur
Reine Schwellwert-Funktionen, keine Zufallskomponente (Wiederkehr = Bogen, nicht Schleife):

```powershell
function Get-PrueferBeat($n) { if ($n -ge 4) { 3 } elseif ($n -ge 2) { 2 } else { 1 } }
function Get-RivaleBeat($n)  { if ($n -ge 7) { 3 } elseif ($n -ge 1) { 2 } else { 1 } }
function Get-QuelleBeat($n)  { if ($n -ge 4) { 3 } elseif ($n -ge 1) { 2 } else { 1 } }
```

### 3. DER RIVALE (kleinster Eingriff, `rival.ps1`)
- Namens-Würfel (`$script:PetRivalNames | Get-Random`, Zeile ~14) **bleibt unverändert** —
  er ist ab jetzt der „Alias" der Figur, keine neue Identität.
- Beim Auftritt (`Invoke-PetRivalBattle`, Vorstellungs-Text ~Zeile 31) statt festem Text die
  Beat-Zeile ziehen: `Get-EnsembleLine "RIVALE" (Get-RivaleBeat $pet.Meta.RivalWins)`.
  Solange PLACEHOLDER: Fallback auf den bestehenden Text, damit nichts leer bleibt.
- Keine Änderung an der Kampf-Mechanik selbst.

### 4. DER PRÜFER (Gesicht für den Raid)
- Neuer Anzeige-Pfad, ausgelöst am bereits existierenden Event
  `raid.unlocked` mit `RaidId = "TAX_AUDIT"` (`world-events.ps1:34, 238`). Statt nur der
  Magenta-Systemzeile zusätzlich den Prüfer-Auftritt zeigen:
  `Get-EnsembleLine "PRUEFER" (Get-PrueferBeat $pet.Meta.AuditSuspicion)`.
- `AuditSuspicion` um 1 erhöhen, **wenn** `casino.jackpot` feuert **während** ein Audit offen
  ist (`$pet.Meta.JackpotRaidPending -eq $true`). Sauberster Ort: ein zusätzlicher Handler auf
  `casino.jackpot` mit niedrigerer Priority als der bestehende, oder Erweiterung des
  Memory-Writers. Wähle den Weg mit dem kleinsten Eingriff.
- Bestehende `raid.expired`-Zeile (`world-events.ps1:182`) im Wortlaut ändern:
  statt „…hat aufgegeben." → „…hat den Vorgang **vertagt**." (Der Prüfer gibt nie auf.)

### 5. DIE QUELLE (Stimme für die Pity-Quest)
- Im `casino.bust`-Handler (`world-events.ps1:44-55`) einen **Nacht-Check** ergänzen: Auftritt
  der Quelle nur, wenn Nacht ist (nutze vorhandenen `login.night`-Marker falls im State
  greifbar, sonst simpler Uhrzeit-Check `(Get-Date).Hour -ge 22 -or (Get-Date).Hour -lt 5`).
- Der Companion **überbringt weiter** das bestehende Angebot (Zeile ~51 unverändert). Zusätzlich
  ein **getrennter** Anzeige-Pfad für die Antwort-Stimme der Quelle:
  `Get-EnsembleLine "QUELLE" (Get-QuelleBeat $pet.Meta.SourceDebt)`.
- `SourceDebt` um 1 erhöhen, wenn eine Gabe tatsächlich angenommen/ausgezahlt wird — sauberster
  Ort ist der bestehende `pet.pityquest.completed`-Pfad (`world-events.ps1:122-129`), wo die
  100 Gold gutgeschrieben werden.

### 6. Memory bleibt unangetastet
Die BEGEGNUNG-/SCHULD-Zeilen in `memory.ps1` **nicht** anfassen — sie werden in einem separaten
Text-Schritt gefüllt, nicht hier. Die Event-Verdrahtung dafür existiert bereits
(`world-events.ps1:238-264`).

---

## Globale Verbote
- **Kein Dialogtext.** Alle Beat-Arrays bleiben `"[PLACEHOLDER: …]"`. Nur der geänderte
  `raid.expired`-Wortlaut (Schritt 4) ist erlaubt, weil das eine bestehende Systemzeile ist,
  kein Figuren-Dialog.
- Ensemble **nie** in `Get-DesktopPetComment` / den Shell-Kommentar-Pfad einhängen.
- Kein neues Bond-Feld, keine neuen Threads, keine Breaking Changes am State-Schema
  (neue Meta-Felder lazy migrieren wie `GlitchUsed`).
- `Modules/pet/*.ps1` bleiben UTF-8 **mit BOM** (SESSION_NOTES.md). Bestehende Kodierung der
  berührten Dateien erhalten.
- Konsolen-/State-Aufrufe non-interactive-sicher (try/catch um Clear/Cursor, Projektkonvention).
- Nach Abschluss `_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1` grün.

## Akzeptanzkriterien
1. `Get-EnsembleLine` liefert für jede Figur je nach Beat einen Eintrag (aktuell PLACEHOLDER),
   und `null`, wenn ein Beat-Array leer wäre.
2. Rivale zeigt bei `RivalWins` = 0 / 5 / 8 nachweislich Beat 1 / 2 / 3 (per PLACEHOLDER-Kennung
   prüfbar), ohne die Kampf-Mechanik zu verändern.
3. Ein zweiter `casino.jackpot` bei offenem Audit erhöht `AuditSuspicion` und wechselt den
   Prüfer-Beat gemäß `Get-PrueferBeat`.
4. Die Quelle erscheint **nur** bei `casino.bust` **und** Nacht; `SourceDebt` steigt pro
   ausgezahlter Gabe.
5. Kein Ensemble-Text erscheint je als Shell-Kommentar.
6. `memory.ps1` unverändert. Alle drei Testsuiten grün.

## Rückfragen
Bei Unklarheit über den kleinsten Eingriffspunkt (z. B. wo genau `AuditSuspicion` erhöht wird):
Auftrag pausieren und rückfragen statt zu raten. Struktur- und Encoding-Treue haben Vorrang vor
Fortschritt.
