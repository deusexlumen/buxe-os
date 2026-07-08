# Arbeitsauftrag Code-KI — Paket 1: Desktop-Pet Voice-Rewrite

> Dies ist ein vollständiger, in sich geschlossener Auftrag. Du brauchst keinen weiteren
> Kontext aus vorherigen Gesprächen — alles Nötige steht hier oder in den referenzierten
> Dateien. Lies zuerst die komplette Sektion "Kontext & Ziel", dann arbeite die Schritte
> in Sektion "Umsetzung" der Reihe nach ab.

---

## Kontext & Ziel

`Modules/desktop-pet.ps1` kommentiert Shell-Befehle des Users in Echtzeit über die
`prompt`-Funktion. Aktuell gibt es dafür genau EINE generische Stimme
(`$script:DPCommandComments`, Struktur: `Muster (string) -> Zeilen (string[])`), die für
alle sieben Companions des Pet-Systems (NEON, RAVEN, PIXEL, LUNA, IVY, VERA, JINX)
identisch ist.

**Ziel dieses Auftrags:** Diese eine Stimme wird durch sieben unterscheidbare Stimmen
ersetzt, mit Kommentar-Häufigkeit pro Companion und drei Beziehungsstufen (Bond-Werten).
Der fertige Dialogtext für alle 66 Befehlsmuster in allen 7 Stimmen liegt bereits fertig
vor (siehe "Textquellen" unten) — **du schreibst keinen einzigen Dialogtext selbst**, du
baust nur die Datenstruktur und die Auswahllogik drumherum.

---

## Textquellen (bereits fertig, nur einlesen und übernehmen)

Alle vier Dateien liegen unter `docs/superpowers/specs/`:

1. `2026-07-07-opus-lieferung-paket1.md` — Basis-Zeilen für NEON, RAVEN, PIXEL, LUNA, VERA
   (Stufe VERTRAUT für ~56 Befehle, plus FREMD/VERTRAUT×2/VERBUNDEN für 6 Spezialbefehle:
   `git commit`, `git push`, `npm install`, `docker`, `reload`, `clear`).
2. `2026-07-08-nachbesserung-paket1-runde2.md` — Ersetzt einzelne Zeilen aus Datei 1
   (klar durch "Befehl → Companion → Slot" gekennzeichnet). **Diese Ersetzungen haben
   Vorrang** vor der entsprechenden Zeile in Datei 1 — wo ein Slot hier überschrieben wird,
   nimm diese Version, nicht die alte.
3. `2026-07-07-voicegate-paket1.md`, Abschnitt 3 — Komplettes IVY-Zeilenset (kuratierte
   Befehlsliste + Default-Pool + die 4 bereits vorher geeichten Risiko-Befehle).
4. `2026-07-08-jinx-paket1.md` — Komplettes JINX-Zeilenset (Hero-Zeilen + Spezial-Bond-Zeilen
   + Default-Pool).

Zusätzlich, aus `2026-07-07-stimm-bibel-desktop-pet.md` Abschnitt C: die 4 Risiko-Befehle
`git push --force`, `rm -rf`, `exit`, `vim` — dort für ALLE 7 Companions fertig geeicht,
Stufe VERTRAUT (außer den bereits genannten Bond-Varianten für `exit`, die dort ebenfalls
stehen).

**Vorgehen zum Einlesen:** Extrahiere aus diesen vier Dateien für jeden der 66 Befehle
und jeden Companion die Zeilen-Liste je Bond-Stufe. Wo eine Stufe für einen
Companion/Befehl fehlt (z. B. IVY hat nur eine kuratierte Teilmenge der Befehle), bleibt
der Slot leer — das ist beabsichtigt, siehe Fallback-Kette unten.

---

## Zieldatenstruktur

Ersetze die flache Struktur

```powershell
$script:DPCommandComments = @{
    "git push" = @("Zeile1", "Zeile2", "Zeile3")
    ...
}
```

durch eine verschachtelte Struktur:

```powershell
$script:DPCommandComments = @{
    "git push" = @{
        NEON  = @{ FREMD = @(...); VERTRAUT = @(...); VERBUNDEN = @(...) }
        RAVEN = @{ FREMD = @(...); VERTRAUT = @(...); VERBUNDEN = @(...) }
        PIXEL = @{ ... }
        LUNA  = @{ ... }
        IVY   = @{ VERTRAUT = @(...) }   # IVY hat i.d.R. nur VERTRAUT befüllt
        VERA  = @{ ... }
        JINX  = @{ ... }
    }
    "git commit" = @{ ... }
    ...
    "default" = @(...)   # bleibt EIN flaches Array wie bisher — companion-unabhängiger
                          # Fallback, wird nur genutzt wenn gar nichts anderes greift
}
```

Der `"default"`-Eintrag bleibt unverändert als einfaches String-Array (aktueller Bestand
in der Datei) — er ist der letzte Fallback, keine Companion-Ebene nötig.

---

## Umsetzung — Schritte

### 1. Datenstruktur befüllen
Baue `$script:DPCommandComments` wie oben beschrieben, befüllt mit dem Text aus den vier
Quelldateien. Halte die Reihenfolge/Gruppierung der Quelldateien als Kommentar im Code
fest (z. B. `# Quelle: opus-lieferung-paket1.md + nachbesserung-runde2.md`), damit spätere
Textänderungen rückverfolgbar bleiben.

### 2. Companion-Frequenz-Tabelle ergänzen
Neue Konstante, z. B. `$script:DPCompanionChance`:

```powershell
$script:DPCompanionChance = @{
    NEON = 25; RAVEN = 15; PIXEL = 30; LUNA = 25; IVY = 4; VERA = 20; JINX = 35
}
```

(Werte aus der Stimm-Bibel Tabelle B1 — Prozentwert = Wahrscheinlichkeit, dass ein
erkannter Befehl überhaupt kommentiert wird, zusätzlich zum bestehenden Cooldown-Mechanismus.)

### 3. LUNA-Risiko-Override
Neue Konstante mit den Risiko-Mustern und ihrer Override-Chance für LUNA:

```powershell
$script:DPLunaRiskPatterns = @("git push.*--force", "rm -rf", "taskkill.*-?/F", "git reset --hard")
$script:DPLunaRiskChance = 80
```

Bei einem Treffer auf eines dieser Muster gilt für LUNA `DPLunaRiskChance` statt ihrer
normalen `DPCompanionChance`. Reine Datenwerte, kein Hardcode im Ablauf.

### 4. Bond-Stufen-Ermittlung
Neue Hilfsfunktion:

```powershell
function Get-DPBondTier($companionState) {
    if (-not $companionState -or -not $companionState.Bond) { return "VERTRAUT" }
    $bond = $companionState.Bond
    if ($bond -lt 20) { return "FREMD" }
    if ($bond -ge 80) { return "VERBUNDEN" }
    return "VERTRAUT"
}
```

Fällt `Get-PetState`/`Companion` aus (kein Companion vorhanden), bleibt der bestehende
Fallback-Pfad in `Show-DesktopPetDialog` unangetastet — dort wird bereits ohne Companion
ein generischer `[COMPANION]`-Präfix gezeigt.

### 5. `Get-DesktopPetComment` umbauen

Aktuelle Funktion (Zeilen ~349–381 in der Originaldatei) macht Pattern-Matching und zieht
danach `Get-Random` aus einem flachen Array. Neue Logik:

1. Bestehendes Pattern-Matching unverändert lassen (liefert weiterhin ein `$pattern`
   oder `$null` → Default-Pfad).
2. Companion + Bond-Stufe ermitteln (`Get-PetState`, `Get-DPBondTier`).
3. **Frequenz-Gate zuerst:** Wenn KEIN Risiko-Override greift, würfle gegen
   `$script:DPCompanionChance[$companionName]` (Prozent). Bei Fehlschlag: kein Kommentar
   (Funktion gibt `$null` zurück) — das ersetzt/ergänzt den bisherigen reinen
   Cooldown-Mechanismus, der unverändert zusätzlich weiterläuft.
4. Bei Erfolg: Fallback-Kette für die Zeilen-Auswahl:
   `$table[$pattern][$companionName][$bondTier]`
   → falls leer/nicht vorhanden: `$table[$pattern][$companionName]["VERTRAUT"]`
   → falls immer noch leer (Companion für dieses Muster gar nicht befüllt, z. B. IVY bei
     vielen Befehlen): **kein Kommentar**, NICHT auf eine andere Companion ausweichen.
   → nur wenn gar kein Pattern gematcht hat (bestehender `default`-Pfad): das bestehende
     10%-Chance-auf-`default`-Verhalten unverändert lassen, companion-unabhängig.
5. Aus der final ermittelten Liste `Get-Random` wie bisher.

### 6. `dp-on` / `dp-off` und Cooldown-Mechanismus unverändert lassen.

---

## Globale Verbote (gelten für diesen gesamten Auftrag)

- Keine eigenen Dialogzeilen erfinden, umformulieren oder "verbessern" — Text wird 1:1
  aus den vier Quelldateien übernommen.
- Keine neuen Subsysteme, keine Threads.
- `Modules/pet/*.ps1` müssen UTF-8 **mit BOM** bleiben (bekannter Encoding-Bug, siehe
  SESSION_NOTES.md); `desktop-pet.ps1` liegt außerhalb von `pet/`, prüfe trotzdem, dass die
  bestehende Kodierung der Datei erhalten bleibt (keine Konvertierung nach UTF-8 ohne BOM).
- Alle Konsolen-/State-Aufrufe non-interactive-sicher halten (try/catch um Cursor/Clear,
  wie im übrigen Projekt Konvention).
- Keine Breaking Changes am Pet-State-Schema; falls doch ein neues Feld nötig wird
  (aktuell nicht erwartet), lazy migrieren wie bei `GlitchUsed`.
- Nach Abschluss müssen `_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1` grün
  sein.

## Akzeptanzkriterien

1. Gleicher Befehl liefert bei NEON und LUNA nachweislich unterschiedliche Zeilenpools
   (manuell oder per Test-Skript prüfbar, z. B. `Get-DesktopPetComment "git push"` mit
   gemocktem Companion-Namen mehrfach aufrufen).
2. Ändern des Bond-Werts im State ändert den gezogenen Pool (FREMD/VERTRAUT/VERBUNDEN
   nachweisbar unterschiedlich, wo Daten vorhanden).
3. In einer Simulation über 200 zufällig generierte Befehle kommentiert IVY spürbar
   seltener als alle anderen Companions (im Rahmen von ~4% vs. 15–35%).
4. `rm -rf` (bzw. die anderen Risiko-Muster) lösen bei LUNA nachweislich die 80%-Override-
   Chance statt ihrer Basis-Chance aus.
5. Fehlt für einen Companion/Befehl-Kombination komplett der Eintrag (z. B. IVY bei einem
   Befehl außerhalb ihrer kuratierten Liste), gibt es für diesen Companion bei diesem
   Befehl still keinen Kommentar — kein Fehler, kein Fallback auf eine falsche Stimme.
6. Prompt-Latenz bleibt unauffällig (Datenzugriff bleibt Hashtable-Lookup, keine teuren
   Operationen pro Tastendruck/Befehl).
7. Alle drei Testsuiten (`_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1`) laufen
   grün durch.

## Rückfragen

Falls beim Einlesen der vier Quelldateien eine Zeilen-Zuordnung unklar ist (z. B. welcher
"Slot" in der Nachbesserungs-Datei welche Original-Zeile ersetzt), im Zweifel die
Original-Reihenfolge der Zeilen im jeweiligen Markdown-Tabellen-Abschnitt als Slot-Index
nehmen (erste Tabellenzeile eines Companions bei einem Befehl = Slot 1, zweite = Slot 2).
Bei echten Unklarheiten: Auftrag pausieren und Rückfrage stellen statt zu raten — Texttreue
hat Vorrang vor Fortschritt.
