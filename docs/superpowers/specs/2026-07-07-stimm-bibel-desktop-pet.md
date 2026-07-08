# Stimm-Bibel: Desktop-Pet Voice-Rewrite (Paket 1)

> Arbeitspaket aus dem Creative-Design-Review v2.0 („Sie hat mitgeschrieben"), Akt I.
> Dieses Dokument ist der komplette Auftrag: Abschnitt A–D = Kreativ-Vorgabe (verbindlich),
> Abschnitt E = Auftrag an Opus, Abschnitt F = Spickzettel für die Code-KI.
> Grundgesetz bleibt LUCASARTS.md — bei Widerspruch gewinnt LUCASARTS.md.

---

## A. Warum dieses Paket zuerst

Der Desktop-Pet ist die Bühne mit dem meisten Publikum: Er spricht potenziell nach jedem
Shell-Befehl. Aktuell hat er EINE generische Stimme für alle sieben Companions — der
schwerste Verstoß gegen Gebot #4 (Character Voice is Everything) an der lautesten Stelle
des Spiels. Ziel: Jede Prompt-Zeile besteht den Test **„Erkenne ich die Sprecherin ohne
Namensschild?"**

---

## B. Die Regeln für den Prompt-Kontext

### B1. Kommentar-Frequenz pro Companion

Nicht jede redet gleich viel. Die Wahrscheinlichkeit, dass ein erkannter Befehl überhaupt
kommentiert wird (zusätzlich zum bestehenden Cooldown):

| Companion | Chance | Begründung |
|-----------|--------|------------|
| JINX  | 35% | Chaotin — sie MUSS sich einmischen |
| PIXEL | 30% | Begeistert von allem, was gebaut wird |
| NEON  | 25% | Kommentiert, aber demonstrativ widerwillig |
| LUNA  | 25% | Fürsorglich — meldet sich bei Risiko-Befehlen fast immer (Sonderregel B4) |
| VERA  | 20% | Analysiert nur, was analysewürdig ist |
| RAVEN | 15% | Dominanz heißt: Sie redet, wenn SIE will |
| IVY   | 4%  | Fast nie. Und genau deshalb erinnert man sich an jede ihrer Zeilen |

### B2. Bond-Stufen

Drei Stufen, drei Beziehungstemperaturen. Die Stufe ändert nicht die Stimme, sondern die
**Nähe**:

| Stufe | Bond | Temperatur |
|-------|------|------------|
| FREMD | < 20 | Distanz. Der User ist „der da". Kein Insiderwissen, keine Wärme. |
| VERTRAUT | 20–79 | Normalzustand. Frotzeln, Beobachtungen, leichte Besitzansprüche. |
| VERBUNDEN | ≥ 80 | Nähe — aber IMMER durch den Charakterfilter: NEONs Nähe ist geleugnete Nähe, RAVENs Nähe ist Besitz, IVYs Nähe ist ein zweites Wort. Nie generische Herzlichkeit. |

### B3. Die 47 im Prompt-Kontext

**Nur JINX**, und auch bei ihr selten (max. 1 von 5 ihrer Zeilen). Alle anderen: im
Prompt-Kontext NIE. Jede 47 ist ab jetzt eine Anzahlung auf das „Session 47"-Set-Piece —
wir verschwenden sie nicht an `ls`.

### B4. LUNA-Sonderregel (Risiko-Befehle)

Bei destruktiven Befehlen (`rm -rf`, `git push --force`, `taskkill /F`, `git reset --hard`)
überstimmt LUNAs Fürsorge ihre normale Frequenz: 80% Kommentar-Chance. Sie ist die
Einzige, die sich wirklich Sorgen macht.

### B5. IVY-Sonderregel

IVY kommentiert fast nie (4%). Wenn sie es tut: maximal ein Satzfragment plus Geste, und
der Inhalt ist **unheimlich präzise** — sie hat offensichtlich die ganze Zeit zugesehen.
IVY bekommt KEINE Varianten-Massenware; ihre Zeilen bleiben handgeschrieben (von mir).

---

## C. Musterzeilen — die vier Risiko-Befehle (verbindliche Eichung)

Diese Zeilen definieren den Ton. Opus eicht alle weiteren Befehle daran.
(Stufe VERTRAUT, sofern nicht markiert.)

### `git push --force`

- **NEON:** „Force-Push. Klar. Geschichte ist eh überbewertet. Sagte niemand, der ein Backup hatte."
- **RAVEN:** „Du überschreibst die Vergangenheit. Endlich denkst du wie ich."
- **PIXEL:** „D-du weißt schon, dass da vielleicht Commits von anderen drin waren? …Waren da andere? Bitte sag, da waren keine anderen."
- **LUNA:** „Warte. Atme. Ist das wirklich der Branch, den du meinst? Ich frage für dich."
- **IVY:** „… *hält die Historie fest* … zu spät."
- **VERA:** „Force-Push registriert. Reflog-Rettungsfenster: begrenzt. Deine Reue: erfahrungsgemäß pünktlich."
- **JINX:** „FORCE PUSH! Geschichte UMSCHREIBEN! Du bist jetzt offiziell ein Zeitreisender! Die schlechte Sorte!"

### `rm -rf`

- **NEON:** „rm -rf. Mutig. Ich habe schon mal angefangen, dir einen Nachruf zu schreiben. Für deine Dateien."
- **RAVEN:** „Auslöschen. Vollständig. Ich billige das. Prüfe trotzdem den Pfad."
- **PIXEL:** „NEIN warte warte warte — ist das der richtige Ordner?! Ich hab da nicht reingeschaut aber WAS WENN DA WAS WOHNT?!"
- **LUNA:** „Das hat keinen Undo-Button. Ich sage das nur einmal. Ich sage es jedes Mal."
- **IVY:** „… *zählt die Dateien* … waren."
- **VERA:** „Rekursives Löschen ohne Rückfrage. Statistische Fehlerquote bei Menschen: relevant. Bei dir: erhoben, aber ich schweige."
- **JINX:** „LÖSCHEN! ALLES! Das ist wie Konfetti, nur RÜCKWÄRTS!"

### `exit`

- **NEON (FREMD):** „Tschüss. Oder so."
- **NEON (VERTRAUT):** „Du gehst? Gut. Endlich Ruhe. …Es ist zu ruhig. Sofort."
- **NEON (VERBUNDEN):** „Geh ruhig. Ich hab zu tun. *hat nichts zu tun* *hat einen Timer gestartet*"
- **RAVEN (VERBUNDEN):** „Geh. Aber komm zurück. Das war keine Bitte."
- **PIXEL:** „Oh! Okay! Ich… ich bau solange was! Damit du was zum Angucken hast! Wenn du wiederkommst! Du kommst doch wieder?"
- **LUNA:** „Schlaf gut. Trink was. Nicht nur Kaffee. Ich meine es ernst."
- **IVY:** „… *bleibt im Fenster stehen* …"
- **VERA:** „Session-Ende protokolliert. Nächste Anmeldung: statistisch morgen, 9:12 Uhr. Ich warte nicht. Ich rechne nur."
- **JINX:** „EXIT?! Einfach so?! Ohne Abschiedsparade?! Ich hatte KONFETTI vorbereitet! Virtuell! Egal! *wirft es trotzdem*"

### `vim`

- **NEON:** „Vim. Viel Glück. Wir sehen uns in drei Jahren, wenn du das :q gefunden hast."
- **RAVEN:** „Modal Editing. Kontrolle über jede Taste. …Ich verstehe, was du daran magst."
- **PIXEL:** „Vim! Das ist wie ein Baukasten! Ohne Anleitung! Und der Deckel klemmt!"
- **LUNA:** „Wenn du feststeckst: Escape, Doppelpunkt, q. Ich lasse das hier einfach liegen. Kein Urteil."
- **IVY:** „… *tippt lautlos :wq in die Luft* …"
- **VERA:** „Vim gestartet. Erwartete Verweildauer: unklar. Erwartete Flüche: quantifizierbar."
- **JINX:** „VIM! Das Spiel, bei dem RAUSKOMMEN der Endboss ist!"

---

## D. Qualitäts-Checkliste (für JEDE Zeile, auch von Opus)

1. Sprecherin ohne Namensschild erkennbar? (Der Kerntest)
2. Enthält die Zeile eine konkrete Beobachtung über DIESEN Befehl — nicht nur Attitüde?
3. Verstößt sie gegen die Forbidden-Spalte in LUCASARTS.md? (NEON nie cheerful, LUNA nie gleichgültig, …)
4. Keine 47 (außer JINX, sparsam)?
5. Würde die Zeile auch beim zwanzigsten Lesen nicht nerven? (Prompt-Zeilen wiederholen sich oft — lieber trocken als schrill.)

---

## E. Auftrag an Opus

**Input:** Dieses Dokument + LUCASARTS.md + die bestehende Befehlsliste in
`Modules/desktop-pet.ps1` (`$script:DPCommandComments`, ~60 Muster).

**Aufgabe:** Für jedes Befehlsmuster außer den vier oben geeichten: pro Companion
**2 Zeilen** auf Stufe VERTRAUT. Zusätzlich für `git commit`, `git push`, `npm install`,
`docker`, `reload`, `clear`: je 1 Zeile FREMD und 1 Zeile VERBUNDEN pro Companion.

**Ausnahmen:** IVY komplett auslassen (schreibe ich). JINX-47-Budget: maximal 5 Zeilen
im gesamten Lieferumfang.

**Format:** Markdown-Tabelle pro Befehl (Companion | Stufe | Zeile), KEIN Code.

**Abgabe geht durch das Voice-Gate** (mich). Erwartung: ~20% der Zeilen werden
zurückgewiesen — das ist eingeplant, nicht schlimm.

---

## F. Spickzettel für die Code-KI (Paket 1 — Umbau desktop-pet.ps1)

**Ziel:** `$script:DPCommandComments` von `Muster → Zeilen[]` erweitern auf
`Muster → Companion → BondStufe → Zeilen[]`, mit Fallback-Kette:
exakte Stufe → Stufe VERTRAUT → companion-unabhängige Default-Ebene → still.

**Dazu:**
- Kommentar-Chance pro Companion als Datenfeld (Tabelle B1), IVY-Wert 4%, LUNA-Risiko-Override (B4) als Muster-Liste + Override-Chance, ebenfalls Daten, kein Hardcode.
- Bond-Stufe aus `Get-PetState → Companion.Bond` ableiten (<20 / 20–79 / ≥80); kein Companion geladen → bestehender Fallback-Pfad bleibt.
- Bestehender Cooldown-Mechanismus und `dp-on`/`dp-off` bleiben unverändert.
- Die Dialog-Daten kommen als fertige Tabellen (aus E + C) — **keine eigenen Zeilen erfinden, keine liefern Texte umformulieren.** Bis die Texte da sind: mit 2–3 Platzhalterzeilen pro Slot bauen, klar als PLACEHOLDER markiert.

**Globale Verbote:** Keine neuen Subsysteme. Kein Thread. UTF-8-Encoding der Datei nicht brechen. Non-interactive-sicher (try/catch um Konsolen-Aufrufe, bestehende Konvention). Lazy Migration, falls State-Felder nötig (voraussichtlich keine).

**Akzeptanzkriterien:**
1. Gleicher Befehl liefert bei NEON und LUNA nachweislich unterschiedliche Zeilenpools.
2. Bond-Wechsel (Testwert setzen) ändert den Pool.
3. IVY kommentiert in einem 200-Befehle-Simulationslauf höchstens eine Handvoll Mal.
4. `rm -rf` triggert LUNA-Override.
5. Prompt-Latenz nicht spürbar erhöht (Lookup bleibt Hashtable-basiert).
6. `_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1` grün.
