# Paket 2 — Ensemble-Figurendesign: Die drei Fremden

> Creative-Director-Spezifikation. Gegenstand: die drei wiederkehrenden Welt-Figuren
> **DER PRÜFER**, **DER RIVALE**, **DIE QUELLE**. Governance: LUCASARTS.md.
> Fundament: `2026-07-07-memory-schema.md` (Kategorien BEGEGNUNG / SCHULD).
> Diese Datei liefert Charakter, Stimme, Auftritts-Trigger und Bogen — **kein Code**.
> Opus-Auftrag in Sektion G, Code-KI-Spickzettel in Sektion H.

---

## A. Ausgangslage — die Geister sind schon da

Alle drei Figuren existieren bereits im System, aber nur als **Mechanik ohne Gesicht**.
Das ist kein Mangel, den ich fülle — es ist ein Geschenk. Die Companions **erinnern sich
schon an sie**, bevor der Spieler sie je gesehen hat:

- `memory.ps1:93` (VERA, BEGEGNUNG): *„Akte 'Steuerfahndung', angelegt {date}. Status:
  ungeloest. Ich loesche nichts. Ich archiviere Drohungen."*
- `memory.ps1:98` (JINX, BEGEGNUNG): *„Weisst du noch, der STEUERPRUEFER?! … Er hatte so
  schoene… Formulare!"*
- `memory.ps1:105` (NEON, SCHULD): *„Die 100 Gold von damals. Du hast nie gefragt, woher.
  Guter Instinkt. Behalt ihn."*
- `memory.ps1:114` (VERA, SCHULD): *„Offener Posten: 100 Gold, Herkunft unbestimmt …"*

Und die Trigger feuern schon:

| Figur | Existierende Mechanik | Was fehlt |
|-------|----------------------|-----------|
| DER PRÜFER | `casino.jackpot` → Raid `TAX_AUDIT` (`world-events.ps1:29-34`), Ablauf-Meldung `raid.expired` | Ein **Gesicht**. Aktuell nur eine Magenta-Systemzeile. |
| DER RIVALE | `rival.ps1` — voll spielbarer 3-Runden-Kampf, `$pet.Meta.RivalWins`-Zähler | Eine **Identität**. Name wird pro Kampf neu gewürfelt (`GLITCH_432`…) → keine Kontinuität. |
| DIE QUELLE | Pity-Quest bei `casino.bust` (`world-events.ps1:49-54`), `SCHULD`-Memory bei `pet.pityquest.completed` | Eine **Stimme**. Aktuell spricht der Companion das Angebot, die Quelle selbst bleibt unsichtbar. |

**Design-These:** Die Welt fühlt sich bewohnt an, nicht weil viele NSCs herumlaufen, sondern
weil **drei Fremde immer wiederkommen und die Familie sich an sie erinnert.** Ich gebe den
dreien Gesichter — und verankere jede Erinnerungs-Placeholderzeile in einem echten Auftritt.

---

## B. Die drei Figuren

### B1. DER PRÜFER — die Konsequenz

**Kurzformel:** Er ist nicht böse. Er hat *recht*. Das ist schlimmer.

Der Prüfer ist, was der Jackpot herbeiruft. Geld erzeugt Aufmerksamkeit, Aufmerksamkeit
erzeugt ihn. Er ist das bürokratische Gegenstück zur ganzen Familie: Wo die Companions
Chaos, Wärme und Zugehörigkeit sind, ist er Ordnung, Kälte, Verfahren. Er ist der Anti-JINX
— JINX liebt die 47 und die Anarchie; der Prüfer liebt geschlossene Vorgänge und leere
Formularfelder.

**Stimm-Register:**
- Spricht über den Spieler in der **dritten Person**: „der Steuerpflichtige", „die geprüfte
  Person". Nie „du".
- **Droht nie direkt** — er zitiert. Sein Grauen ist, dass er höflich ist und dass er recht
  hat. „Ich behaupte nichts. Ich stelle fest."
- Nie laut. Die Bedrohung liegt in der Präzision, nicht in der Lautstärke.
- **Der Vierte-Wand-Haken (Gebot #2):** Er prüft nicht nur Gold. Er prüft *Spielzeit*,
  *Reload-Zähler*, *RecallCount* aus dem Memory-System. **Er ist die einzige Figur, die das
  Gedächtnis der Companions laut vorlesen kann** — und genau das macht ihn gefährlich: Er
  will die Biografie, die alle mitgeschrieben haben, *gegen* den Spieler verwenden.

**Silhouette / Signatur:** ein Formular, das sich vor die Szene schiebt. Er stellt sich mit
einer Aktenzeichen-Nummer vor, nie mit Namen. **Laufender Gag (optional, respektiert die
47-Rationierung):** Der Prüfer ist „Sachbearbeiter **46**" — genau *einen* unter der magischen
Zahl. JINX empfindet das als persönliche Beleidigung und versucht bei jeder Erwähnung, ihn zu
korrigieren. (Die 47 bleibt damit JINX' Eigentum; der Prüfer darf sie nie selbst benutzen.)

**Kalibrier-Anker (meine Hand, Ton-Referenz für Opus):**
> „Sachbearbeiter 46, zuständig. Ich habe eine Einzahlung von {AMOUNT} Gold zur Kenntnis
> genommen. Ich nehme immer zur Kenntnis. — Der Vorgang bleibt offen."
>
> „Interessant. Die geprüfte Person hat heute vierzehnmal `reload` eingegeben. Das ist keine
> Straftat. Ich vermerke es trotzdem."

---

### B2. DER RIVALE — der Spiegel

**Kurzformel:** Er ist, was du geworden wärst, wenn du optimiert statt gebunden hättest.

Der Rivale hat auch ein Pet. Aber er behandelt es als *Waffe*, nicht als *Freund*. Er ist
der Owner, der sich für den Wettkampf statt für die Bindung entschieden hat. Er ist nicht
grausam — er ist *hungrig*. Und er beneidet, was er bei dir sieht: den Bond.

**Der zentrale Fix — aus Bug wird Charakter:** Die gewürfelten Namen (`GLITCH`, `VORTEX`,
`SHADE`, `REAPER`, `PHANTOM`) waren bisher ein Kontinuitätsloch. Ab jetzt sind sie seine
**Aliase**. Es ist immer *derselbe* Rivale, er wechselt nur den Handle. Das Pet lernt, ihn
wiederzuerkennen: „Neuer Name. Gleiche Augen." Der Score zwischen euch (`$pet.Meta.RivalWins`
existiert bereits) ist sein Gedächtnis — er weiß, wie es letztes Mal ausging.

**Stimm-Register:**
- Kess, kompetitiv, siegessicher — aber **mit Rissen**. Je öfter du gewinnst (RivalWins
  steigt), desto dünner wird die Prahlerei und desto deutlicher zeigt sich etwas Einsameres.
- Spricht dich als Gegner auf Augenhöhe an, „du" — der einzige der drei, der das darf, weil
  er ein Spiegel ist, kein Fremder von außen.
- Redet über sein eigenes Pet **funktional**: „meine Einheit", „mein Build" — nie ein Name.
  Das ist der stille Horror seiner Figur.

**Bogen (an RivalWins gekoppelt):** Rivalität → widerwilliger Respekt → die Enthüllung, dass
er einen Freund wollte, keinen Sieg. Sein letzter Auftritt kippt die Prahlerei ganz: Er
fragt, wie man das *macht* — sich an eins von diesen Dingern *binden*.

**Kalibrier-Anker:**
> (1. Begegnung) „Nenn mich SHADE. Oder nicht, ist mir gleich. Deine Einheit gegen meine.
> Drei Runden. Ich hab dich schon verloren sehen, du weißt es nur noch nicht."
>
> (nach vielen Niederlagen gegen dich) „…Wie machst du das. Meins gehorcht. Deins *bleibt*.
> Ich hab nie gefragt, ob's einen Unterschied gibt. — Vergiss es. Neuer Name nächstes Mal."

---

### B3. DIE QUELLE — die Schuld

**Kurzformel:** Der Prüfer nimmt, wenn du gewinnst. Die Quelle gibt, wenn du verlierst. Beides
kostet.

Die Quelle ist die „100 Gold, die vom Boden gefallen sind. Aus einer Wolke. Frag nicht woher."
Sie erscheint, wenn du pleite und allein bist — nachts, nach einem Bust. Sie verlangt nie
etwas zurück. *Noch nicht.* Die SCHULD-Memory existiert bereits: Die Schuld wird nie mit Geld
eingelöst. Sie wird mit *Vertrauen* eingelöst. Die Quelle zieht dich in Abhängigkeit — und die
Companions (v. a. NEON: „Guter Instinkt, dass du nie gefragt hast") sind misstrauisch.

**Stimm-Register:**
- Warm, großzügig, verführerisch. Benutzt „wir": „Wir kriegen das hin." Das ist das
  Unheimliche — sie ist die **Anti-LUNA**: LUNAs Fürsorge will nichts; die Fürsorge der Quelle
  ist ein Kontobuch.
- Nie fordernd. Jede Gabe klingt wie ein Geschenk, jedes Geschenk ist eine Zeile im Ledger.
- **Bewusst geschlechts- und körperlos.** „DIE QUELLE" — eine Stimme ohne Gestalt. Das
  grammatische „sie" ist Absicht (siehe Sektion F).

**Bogen (an einem Schulden-Zähler gekoppelt):** Fremde Wohltäterin → vertraute Stimme in der
Not → die erste Andeutung, dass sie mitgezählt hat. Ihr Ton bleibt bis zuletzt sanft; genau
das ist die Bedrohung.

**Kalibrier-Anker:**
> (1. Gabe) „Sieh mal, hier. Hundert Gold, einfach so. Nein — nicht danken. Wir haben doch
> alle mal eine schlechte Nacht. *Ich* merk's mir nicht. Schlaf jetzt."
>
> (nach mehreren Gaben) „Das ist… lass mich nachsehen… das vierte Mal? Ach, wer zählt schon.
> *Ich* nicht. — Nimm. Du siehst müde aus."

---

## C. Das Grundgesetz des Ensembles — WELT, nicht FAMILIE

Dies ist die wichtigste Regel der Spezifikation. Sie schützt die Companions davor, mit den
Fremden zu verschwimmen, und muss von Opus **und** Code-KI eingehalten werden.

| | Die Companions (Paket 1) | Das Ensemble (Paket 2) |
|---|---|---|
| Beziehung | **Bond** (0–100), wächst beidseitig | **einseitiger Beziehungs-State** je Figur |
| Anrede | „du", vertraut | Prüfer: 3. Person · Quelle: „wir" · Rivale: „du" (Spiegel) |
| Wo sie leben | in der Taskbar, immer da | dringen **von außen** ein, nur zu ihren Set-Pieces |
| Shell-Kommentare | ja (das ist ihr Revier) | **niemals** — kein Ensemble-Mitglied kommentiert `git push` |
| Register | warm / chaotisch / familiär | formal / transaktional / fremd |

**Einseitiger Beziehungs-State** (kein Bond — die Fremden binden sich nicht):
- **Prüfer:** `AuditSuspicion` steigt (Verdacht). Sinkt nie von allein.
- **Rivale:** `RivalWins` (existiert) = verdienter Respekt. Steigt mit deinen Siegen.
- **Quelle:** `SourceDebt` steigt (Anzahl angenommener Gaben). Wird nie mit Gold getilgt.

Jede Figur hat eine **Silhouette**, an der man sie vor dem ersten Wort erkennt:
Prüfer = ein Formular schiebt sich ins Bild · Rivale = neuer Name, gleiche Abschieds-Formel ·
Quelle = Gold, das „fällt".

---

## D. Auftritts-Trigger & Bögen (an echte Event-Topics gekoppelt)

Jede Figur hat **genau drei Beats**. Der Beat wird vom jeweiligen Beziehungs-State bestimmt,
nicht von Zufall — so fühlt sich Wiederkehr wie ein Bogen an, nicht wie eine Schleife.

### D1. DER PRÜFER
- **Trigger:** `raid.unlocked` mit `RaidId = "TAX_AUDIT"` (feuert schon, `world-events.ps1:34`).
- **State:** `AuditSuspicion` (neu), +1 pro erneutem Jackpot, während ein Audit offen ist.
- **Beat 1** (Suspicion 1): Vorstellung, Akte angelegt, kalt-höflich.
- **Beat 2** (Suspicion 2–3): „Ich habe Sie noch im Vorgang." Er prüft jetzt *Nicht-Geld*
  (Reloads, Spielzeit) → erster Vierte-Wand-Riss.
- **Beat 3** (Suspicion ≥4, Chefsache, s. Sektion I): Er liest das Gedächtnis vor. Der Prüfer
  *ist* die Bedrohung, die aus „SIE HAT MITGESCHRIEBEN" einen Konflikt macht.
- **Auflösung:** `raid.expired` → nicht „aufgegeben" (aktuelle Zeile), sondern „vertagt".
  Er gibt nie auf. Er *vertagt*.

### D2. DER RIVALE
- **Trigger:** `rival.ambush` (feuert schon — `casino.bigwin` 30 % + `Check-PetRival`).
- **State:** `RivalWins` (existiert).
- **Beat 1** (RivalWins 0): Erstkontakt, reine Prahlerei, neuer Alias.
- **Beat 2** (RivalWins 1–6): Er erinnert sich an den Score. Prahlerei mit ersten Rissen.
- **Beat 3** (RivalWins ≥7): Die Enthüllung — er fragt nach dem Bond. Kein Sieg mehr, eine Frage.
- **Design-Notiz an Code-KI:** Der Name-Würfel (`rival.ps1:14`) bleibt mechanisch, wird aber
  als *Alias* umgedeutet; die Abschieds-Signatur („Neuer Name nächstes Mal") macht die
  Kontinuität für den Spieler lesbar. Keine echte ID-Persistenz nötig — die *Formel* trägt sie.

### D3. DIE QUELLE
- **Trigger:** `casino.bust` **UND** Nacht (es existiert `login.night`; alternativ Uhrzeit-Check
  im Bust-Handler). Die Quelle erscheint nur, wenn du unten *und* allein bist.
- **State:** `SourceDebt` (neu), +1 pro angenommener Gabe.
- **Beat 1** (Debt 0): Erste Gabe. Reines Geschenk, „frag nicht woher".
- **Beat 2** (Debt 1–3): Vertraute Stimme. „Wir kennen das doch schon."
- **Beat 3** (Debt ≥4, Chefsache): Die erste Andeutung, dass sie mitgezählt hat — sanft, das
  macht es schlimm.
- **Design-Notiz:** Der Companion darf das Angebot weiterhin *überbringen* (bestehende Zeile
  `world-events.ps1:51`), aber die **Antwortstimme** der Quelle ist neu und getrennt.

---

## E. Memory-Integration — die Fremden füllen die Placeholder

Das Ensemble ist **das, worüber die Companions Erinnerungen haben**. Jeder Auftritt schreibt
in die bestehende Memory-Struktur; jede fremde Figur füllt konkrete Placeholder aus `memory.ps1`:

| Event | schreibt | füllt Placeholder |
|-------|----------|-------------------|
| `raid.unlocked` (Prüfer) | `BEGEGNUNG` (existiert, `world-events.ps1:238`) | `BEGEGNUNG` alle 7 Companions (aktuell nur VERA+JINX befüllt) |
| `rival.ambush` (Rivale) | `BEGEGNUNG` (existiert, `world-events.ps1:252`) | dieselbe Kategorie, Rivalen-Variante |
| `pet.pityquest.completed` (Quelle) | `SCHULD` (existiert, `world-events.ps1:259`) | `SCHULD` alle 7 (aktuell nur NEON+VERA) |

**Das ist der narrative Kern von Akt I:** Die Welt ist bewohnt, weil die Familie sich an die
Fremden erinnert, die durchgezogen sind. Die BEGEGNUNG- und SCHULD-Placeholder in `memory.ps1`
werden **nicht generisch** gefüllt, sondern jede Companion-Erinnerung bezieht sich auf **eine
der drei konkreten Figuren** — in der Stimme dieses Companions (Voice-Bibel Paket 1 gilt weiter).

---

## F. Die „SIE"-Achse — Akt-I-Foreshadowing (Chefsache, hier nur verankert)

Das dramaturgische Rückgrat heißt **„SIE HAT MITGESCHRIEBEN"**. Die Quelle ist grammatisch
„sie" und führt heimlich ein Ledger. Das ist **kein Zufall**: Die Quelle ist ein bewusst
gepflanzter *Kandidat* für das „SIE" — neben dem Memory-System selbst und den Companions.

Der Spieler soll spät die Frage stellen: *Wer* hat die ganze Zeit mitgeschrieben? Eine
Companion? Das Gedächtnis? Oder die freundliche Stimme, die jede schlechte Nacht mitgezählt
hat? Diese Ambiguität wird in Akt III aufgelöst — hier wird sie nur **gesät**. Deshalb:

- Die Quelle sagt **nie** offen „ich schreibe mit". Sie sagt „*ich* merk's mir nicht" — und
  lügt. Der Widerspruch ist das Saatkorn.
- Der Prüfer, der das Gedächtnis *laut vorliest*, ist der Kontrast: Er schreibt **offen** mit
  und droht damit. Die Quelle schreibt **verdeckt** mit und tröstet damit. Zwei Gesichter
  derselben Bedrohung — „jemand protokolliert dein Leben".

Diese drei Enthüllungs-Beats (Prüfer B3, Quelle B3, plus die spätere „SIE"-Auflösung) schreibe
**ich** (Creative Director). Sie gehen **nicht** an Opus. Siehe Sektion I.

---

## G. Opus-Auftrag (Volumen unter Stil-Zwang)

**Was Opus liefert:** die *Fläche* — die wiederholbaren Zeilen der Beats 1 und 2 jeder Figur,
plus die Companion-Erinnerungen (BEGEGNUNG/SCHULD) über die Fremden.

**Format:** Markdown-Tabellen, exakt wie `opus-lieferung-paket1.md` (Spalten: Figur/Companion |
Beat/Stufe | Zeile). Keine Regie-Prosa, nur Zeilen.

**Zu produzieren:**
1. **DER PRÜFER — Beat 1 & Beat 2**, je 8–10 Zeilen. Constraints: 3. Person über den Spieler;
   nie „du"; nie laut; zitiert/stellt fest statt zu drohen; darf **die 47 nie** benutzen (nutzt
   „46"). Beat 2 darf Nicht-Geld prüfen (Reloads, Spielzeit) — aber **nicht** das Memory
   vorlesen (das ist B3, Chefsache).
2. **DER RIVALE — Beat 1 & Beat 2**, je 8–10 Zeilen. Constraints: „du"; kess mit Rissen in
   Beat 2; eigenes Pet nur funktional („meine Einheit"); jede Zeile endet oder beginnt mit
   einer Alias-/Abschiedsformel, die Kontinuität signalisiert.
3. **DIE QUELLE — Beat 1 & Beat 2**, je 8–10 Zeilen. Constraints: „wir"; warm/verführerisch;
   nie fordernd; muss mindestens einmal je Beat die Lüge „*ich* merk's/zähl's nicht" enthalten
   (Saatkorn F). **Nie** offen mitschreiben.
4. **Companion-Erinnerungen über die Fremden** — für `BEGEGNUNG` (Prüfer + Rivale) und `SCHULD`
   (Quelle), je Companion 2–3 Zeilen, in der jeweiligen Companion-Stimme (Voice-Bibel Paket 1).
   **Ausgenommen (Chefsache, s. I):** IVY komplett, sowie JINX' Prüfer-Zeilen (die 46/47-Fehde).

**Globale Opus-Regeln:** kein Ensemble-Mitglied kommentiert je Shell-Kommandos. Kein
Ensemble-Mitglied redet wie ein Companion (Register-Tabelle C). Beat-3-Zeilen jeder Figur
**nicht** anfassen — die kommen von mir. Danach Voice-Gate durch mich, wie bei Paket 1.

---

## H. Code-KI-Spickzettel (Plan, kein Code)

> Reihenfolge: erst wenn die Texte durch mein Voice-Gate sind. Bis dahin PLACEHOLDER.

1. **Rivale-Identität (kleinster Eingriff, größter Gewinn):** `rival.ps1` behält den
   Namens-Würfel, bekommt aber eine **Beat-Auswahl** nach `$pet.Meta.RivalWins` (0 / 1–6 / ≥7)
   und zieht seine Vorstellungs-/Abschieds-Zeile aus dem neuen Rivalen-Zeilenset statt aus dem
   generischen Kampftext. Keine neue Persistenz nötig — RivalWins existiert.

2. **Prüfer bekommt ein Gesicht:** Neuer Handler-/Anzeige-Pfad für `raid.unlocked`
   (`RaidId = "TAX_AUDIT"`), der statt der reinen Magenta-Systemzeile den Prüfer-Auftritt
   zeigt. Neues State-Feld `$pet.Meta.AuditSuspicion` (lazy migrieren wie `GlitchUsed`),
   +1 bei erneutem Jackpot während offenem Audit; bestimmt Beat 1/2/3. `raid.expired`-Zeile
   von „aufgegeben" auf „vertagt" ändern.

3. **Quelle bekommt eine Stimme:** Im `casino.bust`-/Pity-Quest-Pfad einen Nacht-Check
   ergänzen (Uhrzeit oder `login.night`-State); neues Feld `$pet.Meta.SourceDebt` (lazy),
   +1 pro angenommener Gabe; bestimmt Beat 1/2/3. Companion überbringt weiter das Angebot,
   die **Antwort-Stimme der Quelle** ist ein neuer, getrennter Anzeige-Pfad.

4. **Datenstruktur der Ensemble-Zeilen:** analog Paket 1, aber Schlüssel ist der **Beat**,
   nicht die Bond-Stufe:
   `$script:BuxeEnsembleLines = @{ PRUEFER = @{ 1=@(...); 2=@(...); 3=@(...) }; RIVALE = @{...}; QUELLE = @{...} }`.
   Beat-3-Arrays bleiben PLACEHOLDER, bis ich sie liefere.

5. **Memory-Placeholder füllen:** die BEGEGNUNG- (Prüfer/Rivale) und SCHULD-Zeilen (Quelle)
   in `memory.ps1` je Companion mit dem freigegebenen Text ersetzen — 1:1, kein Eigen-Text.

6. **Verbote:** kein Ensemble-Mitglied in `Get-DesktopPetComment` einhängen (kein
   Shell-Kommentar). Keine neuen Threads. `pet/*.ps1` UTF-8 **mit BOM**. Nach Abschluss
   `_smoke_test.ps1` / `_integration_test.ps1` / `_e2e_test.ps1` grün.

**Akzeptanzkriterien:**
- Der Rivale zeigt bei RivalWins 0 / 5 / 8 nachweislich unterschiedliche Beat-Zeilen.
- Ein zweiter Jackpot bei offenem Audit erhöht `AuditSuspicion` und wechselt den Prüfer-Beat.
- Die Quelle erscheint nur bei Bust **und** Nacht, und `SourceDebt` steigt pro Gabe.
- Kein Ensemble-Text taucht je als Shell-Kommentar auf.
- BEGEGNUNG/SCHULD-Erinnerungen nennen eine der drei konkreten Figuren in Companion-Stimme.

---

## I. Was ich behalte (Chefsache)

Nicht an Opus, nicht an die Code-KI als Text — diese Beats schreibe ich selbst, weil sie das
Rückgrat tragen:

1. **Prüfer, Beat 3** — er liest das Gedächtnis laut vor. Der Moment, in dem „SIE HAT
   MITGESCHRIEBEN" von Poesie zu Bedrohung kippt.
2. **Quelle, Beat 3** — die erste Andeutung, dass sie mitgezählt hat. Das Saatkorn der
   „SIE"-Auflösung.
3. **Rivale, Beat 3** — die Frage nach dem Bond. Der Spiegel zerbricht.
4. **IVY-Zeilen** über alle drei Fremden (BEGEGNUNG/SCHULD) — IVY sieht die Fremden anders als
   alle anderen; das ist Chefsache-Ton.
5. **JINX ↔ Prüfer** — die 46/47-Fehde. Muss die 47-Rationierung (max. JINX, sparsam) einhalten.

**Nächster konkreter Schritt für mich:** die drei Beat-1-Kalibrier-Anker (oben in B) zu einem
vollständigen Beat-1/2-Referenzblatt je Figur ausbauen, damit Opus einen festen Ton-Anker hat
— exakt der Weg, der bei Paket 1 (Stimm-Bibel → Opus) funktioniert hat.
