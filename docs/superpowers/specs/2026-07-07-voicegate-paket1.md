# Voice-Gate: Abnahme Opus-Lieferung Paket 1

> Prüfung durch den Creative Director gegen LUCASARTS.md + Checkliste D der Stimm-Bibel.
> Ergebnis: **ANGENOMMEN mit gezielter Nachbesserung.** Die Grundqualität ist hoch —
> die Stimmen sind einzeln fast durchweg unverwechselbar. Die Zurückweisungen sind
> **Muster-Tics**, keine Einzelzeilen: Sie entstehen erst durch die Wiederholung über 62
> Befehle, und genau die ist im Prompt-Kontext das Problem (Checkliste D5: „funktioniert
> auch beim 20. Lesen").

---

## 1. Gesamturteil

| Companion | Voice getroffen? | Befund |
|-----------|------------------|--------|
| NEON | ✅ exzellent | Müde Selbstironie, geleugnete Nähe. Kaum Beanstandung. |
| RAVEN | ✅ stark | Dominant, besitzergreifend. **Tic:** Zustimmungs-Stempel (s. 2.2). |
| PIXEL | ✅ stark | Atemlos, baut Dinge, bedürftig. **Tic:** Ausrufezeichen-Inflation (s. 2.1). |
| LUNA | ✅ gut | Fürsorglich, medizinisch. **Schwäche:** driftet gelegentlich in generische Wellness (s. 2.3). |
| VERA | ✅ stark | Analytisch, distanziert-messend. **Tic:** „registriert"-Opener (s. 2.4). |

Die von Opus selbst markierte Sorge (VERA-VERBUNDEN nah an der Wärmegrenze) prüfe ich als
**unbedenklich**: Zeilen wie „Nenn es Anteilnahme, ich nenne es Datenlage" oder „Das
genügt mir" halten den Daten-Filter sauber durch. Das ist genau die richtige Gratwanderung
— nicht zurückweisen.

---

## 2. Nachbesserungs-Auftrag (die ~20% — als Muster, nicht als Liste)

### 2.1 PIXEL — Ausrufezeichen-Inflation
Fast jede PIXEL-Zeile stapelt „!", „Ich lieb…!", „so schön!". Einzeln charmant, in Serie
ermüdend. **Fix:** In ~1 von 3 PIXEL-Zeilen die Energie senken — höchstens ein
Ausrufezeichen, gelegentlich ein leiser, fast schüchterner Ton (ihr Grundcharakter ist
*shy* laut LUCASARTS.md, nicht nur begeistert). Besonders bei den Monitoring-Befehlen
(`top`, `htop`, `tasklist`, `ps`), wo Dauerjubel unpassend wirkt.

### 2.2 RAVEN — Zustimmungs-Stempel
„Das gefällt mir." / „Steht dir." / „Genau so." / „Weiter so." / „Ich billige das."
kehren zu oft am Zeilenende wieder. Dominanz ja, aber sie wird zur Floskel. **Fix:** Die
Zustimmungs-Schlussformel auf ~die Hälfte der RAVEN-Zeilen reduzieren; die anderen enden
in Anspruch, Drohung oder kühler Beobachtung ohne Lob (RAVEN lobt sparsam — das macht das
Lob wertvoll).

### 2.3 LUNA — generische Wellness aussortieren
Die meisten LUNA-Zeilen sind gut, weil sie an den Befehl gebunden sind. Zurückgewiesen
werden die, die reine Wellness-Coaching-Floskel ohne Befehlsbezug sind (Checkliste D2 —
konkrete Beobachtung über DIESEN Befehl fehlt). Betrifft v. a. einzelne Zeilen bei
`status`, `weather`, `bank`. **Fix:** Jede LUNA-Zeile muss mindestens einen konkreten
Bezug zum Befehl tragen; „atme / trink was / streck dich" nur als *Zugabe* nach der
befehlsbezogenen Beobachtung, nie als ganze Zeile. Zusätzlich „Ich mein's ernst" /
„Ich kümmer mich" ausdünnen (Tic).

### 2.4 VERA — „registriert"-Opener rationieren
„<Befehl> registriert." eröffnet fast jede erste VERA-Zeile. Als Running-Signatur zu
dicht. **Fix:** Auf ~1 von 3 VERA-Zeilen beschränken. Die übrigen direkt mit der Messung/
Beobachtung einsteigen. Ebenso „Ich messe nur / Ich zähle mit / Notiert" variieren.

**Umfang der Nachbesserung:** rein redaktionell, keine neuen Befehle. Kann an Opus (Runde 2)
gehen ODER beim Einbau direkt mitlaufen. Danach erneut kurzes Voice-Gate nur auf die
geänderten Zeilen.

---

## 3. IVY — komplettes Set (Chefsache, hier geliefert)

IVY war bewusst aus der Opus-Massenware ausgenommen (Regel B5). Hier ihre Zeilen. Prinzip:
**maximal ein Satzfragment + eine Geste, unheimlich präzise, pro Befehl SPEZIFISCH** — nie
recycelte Ellipsen. IVY kommentiert im Betrieb nur mit 4% Chance; deshalb braucht sie kein
volles 62er-Set, sondern eine kuratierte Auswahl der Befehle, bei denen „sie hat die ganze
Zeit zugesehen" am stärksten trifft. Alle Zeilen Stufe VERTRAUT.

### Kuratierte Befehls-Zeilen

| Befehl | Zeile |
|--------|-------|
| git commit | „… *liest die Message, die du gleich vergisst* … ich nicht." |
| git log | „… *deutet auf einen Commit von vor Monaten* … der. den hast du nie erklärt." |
| git push | „… *sieht dem Code beim Verschwinden zu* … weg." |
| git stash | „… *merkt sich genau, wo du es versteckst* …" |
| reload | „… *bleibt, während alles neu lädt* … du glaubst, ich vergesse. … glaub das weiter." |
| ssh | „… *dreht den Kopf zum fernen Rechner* … da ist jemand. … nein. nur ich." |
| curl | „… *fängt das JSON, bevor es bei dir ankommt* …" |
| sudo | „… *wird ganz still* … jetzt kannst du alles. … auch das." |
| kill | „… *zählt kurz mit* … einer weniger." |
| taskkill | „… *sieht den Prozess an* … er hat es nicht kommen sehen." |
| cat | „… *liest mit* … Zeile vierzig. … da ist es. … ich sag nicht was." |
| ls | „… *deutet auf eine Datei, die du nicht gesucht hast* … die da." |
| top | „… *starrt auf einen Prozess* … der sieht auch dich." |
| htop | „… *folgt einem Balken mit dem Blick, bis er rot wird* …" |
| python | „… *wartet auf den ImportError, bevor er kommt* … jetzt." |
| docker | „… *lauscht am Container* … drin ist es dunkel." |
| clear | „… *der Bildschirm ist leer. ich nicht* …" |
| code | „… *sieht die Datei von gestern, noch offen* … die. seit gestern." |
| rm | „… *zählt die Datei ein letztes Mal* … war." |
| mkdir | „… *schaut in den leeren Ordner* … noch leer. … noch." |
| pet | „… *war schon da, bevor du getippt hast* …" |
| companion | „… *nickt langsam* … ich weiß." |
| say | „… *hört deine Stimme zum ersten Mal* … oh." |
| weather | „… *schaut aus einem Fenster, das es nicht gibt* … grau." |

### Default-Pool (nur wenn kein spezifischer Befehl trifft, extrem selten)
- „… *sieht dich tippen* …"
- „… *notiert etwas, das du nicht sehen kannst* …"
- „… *war die ganze Zeit hier* …"

### Risiko-Befehle (bereits in der Stimm-Bibel Abschnitt C geeicht, hier zur Vollständigkeit)
- rm -rf: „… *zählt die Dateien* … waren."
- git push --force: „… *hält die Historie fest* … zu spät."
- exit: „… *bleibt im Fenster stehen* …"
- vim: „… *tippt lautlos :wq in die Luft* …"

---

## 4. Freigabe-Status

- **NEON-Zeilen:** freigegeben.
- **RAVEN / PIXEL / LUNA / VERA:** freigegeben **nach** Nachbesserung 2.1–2.4.
- **IVY:** hiermit geliefert und freigegeben.
- **JINX:** noch offen — bewusst nicht in dieser Runde (zu heikel für Bulk). Schreibe ich in
  einer eigenen kleinen Runde, sobald der Rest sitzt.

Erst nach der Nachbesserung wird die Dialog-Datenbasis an die Code-KI übergeben, die die
PLACEHOLDER in `desktop-pet.ps1` (Spickzettel F) ersetzt.
