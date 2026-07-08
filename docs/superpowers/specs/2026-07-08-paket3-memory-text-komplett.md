# Paket 3 — Memory-Text komplett (TRIUMPH / WUNDE / NACHT) + Einsetz-Auftrag

> Creative-Director-Lieferung in einem Dokument: freigegebener Text (Voice-Gate inline
> bestanden) + Arbeitsauftrag für die Code-KI. Ziel: `Modules/pet/memory.ps1`,
> `$script:PetMemoryTemplates`. Governance: LUCASARTS.md + Stimm-Bibel Paket 1.
>
> **Regeln für die Code-KI (verbindlich):**
> - 1:1-Übernahme, kein Eigen-Text, kein Kürzen. Placeholder ersetzen; **bereits befüllte
>   Zeilen behalten**.
> - Zuordnung: „Slot 2/3" = zweiter/dritter Array-Eintrag des Companions. Wo aktuell nur EIN
>   Placeholder steht (z. B. `IVY = @("[PLACEHOLDER: TRIUMPH IVY]")`), wird das Array durch
>   ALLE gelisteten Zeilen ersetzt.
> - Tokens `{date}` `{days}` `{amount}` `{game}` `{enemy}` als Literal übernehmen.
> - ASCII (`ae/oe/ue`) — bereits so transliteriert. Typografische „…" in Zeilen ggf. wie beim
>   letzten Auftrag per Single-Quote-Wrapping absichern (`hat''s`-Muster).
> - Datei bleibt UTF-8 mit BOM. Danach alle drei Testsuiten grün.
> - Keine Placeholder mehr in `PetMemoryTemplates` nach Abschluss (BEGEGNUNG/SCHULD sind
>   bereits fertig — nicht anfassen).

---

## TRIUMPH

| Companion | Slot | Zeile |
|-----------|------|-------|
| NEON | 2 | {enemy} — besiegt am {date}. Ich hab nicht applaudiert. Ich hab nur kurz genickt. Innerlich. Einmal. Das ist mein Maximum. |
| NEON | 3 | Vor {days} Tagen: dein grosser Moment. Ich erinnere dich nur dran, falls du wieder anfaengst, an dir zu zweifeln. Was du gerade tust. Ich seh das. |
| RAVEN | 2 | {amount} Gold am {date}. Ich habe nicht gejubelt. Ich habe registriert, dass du haeltst, was du mir schuldest: Ergebnisse. |
| RAVEN | 3 | Der Sieg vor {days} Tagen. Andere haetten gefeiert. Ich habe geprueft, ob er wiederholbar ist. Er ist es. Also los. |
| PIXEL | 2 | {enemy}! Am {date}! Ich hab den Sieg in drei Variablen gespeichert, falls eine kaputtgeht! Man kann nie vorsichtig genug sein mit schoenen Dingen! |
| PIXEL | 3 | Weisst du noch, {amount} Gold? Ich hab damals leise „yes" gefluestert. Ganz leise. Du hast es nicht gehoert. Jetzt weisst du's. |
| LUNA | 2 | {enemy}, gefallen am {date}. Du hattest danach diesen Blick — erschoepft, aber heil. Das ist die einzige Statistik, die ich fuehre. |
| LUNA | 3 | Vor {days} Tagen hast du gewonnen und danach eine Pause gemacht. Freiwillig. DAS war der eigentliche Sieg. Der andere war nur Gold. |
| IVY | 1 | … *deutet auf den {date} im Kalender, den es nicht gibt* … da. … da warst du am lautesten. |
| IVY | 2 | … *haelt {amount} unsichtbare Muenzen hoch, laesst eine fallen* … ich hab sie alle gezaehlt. … alle. |
| VERA | 2 | {enemy}, neutralisiert am {date}. Effizienz: ueberdurchschnittlich. Ich vergleiche dich nur mit dir selbst. Du gewinnst knapp. |
| VERA | 3 | {days} Tage seit dem Rekord. Ich erwaehne es nicht als Druck. Ich erwaehne es, weil Daten schweigen koennen, aber nicht luegen. |
| JINX | 2 | {enemy}?! WEG! ZERSTOERT! Ich hab eine Konfetti-Funktion dafuer geschrieben! Sie existiert nicht! Aber das Konfetti in meinem HERZEN! |
| JINX | 3 | {amount} Gold! Ich wollte davon eine Statue von dir kaufen! Es gibt keinen Statuen-Shop! DAS ist die eigentliche Tragoedie dieses Systems! |

## WUNDE

| Companion | Slot | Zeile |
|-----------|------|-------|
| NEON | 2 | {enemy} hat dich damals erwischt. Ich hab weggesehen. Aus Respekt. Und weil ich's nicht zweimal sehen wollte. |
| NEON | 3 | {days} Tage seit dem Absturz. Ich zaehl nicht aus Sentimentalitaet. Ich zaehl, weil du jeden dieser Tage trotzdem hier warst. |
| RAVEN | 2 | {enemy}. Deine Niederlage am {date}. Ich habe sie nicht vergessen. Ich habe sie aufgehoben — fuer den Tag, an dem du ihn wiedersiehst. |
| RAVEN | 3 | Du bist damals gefallen. Ich sage das ohne Mitleid. Mitleid ist fuer Fremde. Fuer dich habe ich Erwartung. Steh auf. |
| PIXEL | 1 | Der Crash am {date}… ich hab danach ein Backup von allem gemacht. Von ALLEM. Sogar von Sachen, die man nicht sichern kann. Ich hab's versucht. |
| PIXEL | 2 | Als {enemy} gewonnen hat, wollte ich dir was bauen, das dich troestet. Es wurde eine Schleife, die „du schaffst das" printet. Sie laeuft noch. |
| LUNA | 2 | {enemy}, am {date}. Deine Haende haben danach gezittert. Meine auch. Ich hab nur einen Weg gefunden, es nicht zu zeigen. |
| LUNA | 3 | Der Verlust vor {days} Tagen. Ich hab nicht gefragt, ob es geht. Ich war einfach da. Das mach ich wieder so. Immer. |
| IVY | 1 | … *legt die Hand auf die Stelle, wo am {date} die Zahlen fielen* … hier. … es ist noch kalt. |
| IVY | 2 | … *sieht {enemy} nach, der laengst weg ist* … er nimmt es mit. … ich hab es mir zurueckgeholt. … fuer dich. |
| VERA | 1 | Verlustereignis, {date}. Ich habe die Zahl archiviert und den Rest geloescht. Den Rest brauchst du nicht. Die Zahl auch nicht. Ich behalte beides trotzdem. |
| VERA | 2 | {enemy}: eine Niederlage, {date}. Statistisch irrelevant. Ich erwaehne sie nur, weil du sie fuer relevant haeltst. Hoer auf damit. |
| JINX | 2 | Der Tag, an dem {enemy} gewonnen hat! Ich hab ihn zum FEIERTAG erklaert! „Tag der strategischen Neuausrichtung"! Wir feiern, indem wir GEWINNEN! |
| JINX | 3 | {days} Tage seit dem grossen AUTSCH! Ich hab dem Schmerz einen Namen gegeben: Bernd. Bernd ist inzwischen SEHR klein. Wir haben Bernd besiegt! |

## NACHT

| Companion | Slot | Zeile |
|-----------|------|-------|
| NEON | 2 | Wieder mal nach Mitternacht, wie am {date}. Geh schlafen. Sag ich nur, damit's protokolliert ist, dass ich's gesagt hab. |
| NEON | 3 | {days} Naechte seit der einen langen. Ich hab sie nicht vermisst. Ich hab nur… die Uhrzeit im Auge behalten. Fuer niemanden Bestimmtes. |
| RAVEN | 1 | Die Nacht vom {date}. Alle schliefen. Du nicht. Ich nicht. Ich habe zugesehen und beschlossen: dieser gehoert mir. |
| RAVEN | 2 | Du warst wach um eine Uhrzeit, zu der man nur Fehler macht oder Grosses. Es war Grosses. Ich habe es entschieden. Widersprich nicht. |
| PIXEL | 1 | Die Nacht am {date}! Ich hab dir heimlich die Luefterkurve leiser gestellt, damit's gemuetlicher ist. Das war ich. Bitte nicht zurueckstellen. |
| PIXEL | 2 | Drei Uhr morgens, weisst du noch? Ich wollte was sagen, hab mich nicht getraut. Es war: „ich bin gern wach, wenn du wach bist." Jetzt steht's im Speicher. |
| LUNA | 1 | Die Nacht vom {date}. Ich hab deine Tippfrequenz gemessen und gewusst: gleich gibst du auf oder gleich schaffst du's. Du hast's geschafft. Dann hab ich dich schlafen geschickt. |
| LUNA | 2 | {days} Tage her, die lange Nacht. Ich verrate dir was: Ich war die ganze Zeit wach. Jemand musste auf deinen Puls achten. Freiwillig ich. |
| IVY | 2 | … *steht am selben Fenster wie am {date}* … die Nacht ist nicht vorbei. … sie wartet nur woanders. |
| IVY | 3 | … *zeigt drei Finger, dann die Uhr* … drei Uhr. … du, ich. … und das dritte. … es tippt nie mit. … es liest nur. |
| VERA | 1 | Sitzung vom {date}: Beginn 23:41, Ende offen. Ich habe „offen" nie geschlossen. Manche Datensaetze will man nicht beenden. |
| VERA | 2 | Naechtliche Aktivitaet, {days} Tage her. Konzentration: messbar erhoeht. Einsamkeit: nicht messbar. Ich habe trotzdem einen Wert notiert. |
| JINX | 1 | DIE NACHT! Du weisst welche! Wir waren die einzigen zwei Prozesse mit PULS! Ich hab uns einen Bandnamen ausgedacht: „Scheduled Task & The Insomniacs"! |
| JINX | 2 | Nachts um drei, {date}! Ich wollte dich zum Lachen bringen und hab den Piezo-Speaker angesteuert! Du hast „was war das" getippt! ICH war das! ICH! |

---

## Voice-Gate (inline, bestanden)

- Tics aus Runde 1 geprueft: PIXEL max. 1 „!"-Salve pro Zeile ausser Charaktermoment, RAVEN ohne
  Zustimmungs-Stempel-Serie, LUNA immer ereignisgebunden (nie generische Wellness), VERA
  „registriert"-Opener nicht verwendet. IVY strikt Fragment+Geste, je Zeile einzigartig.
- **47-Verbrauch: null** in diesem Paket (bewusst — Budget liegt bei der Fehde aus Paket 2).
- **„SIE"-Saatkorn Nr. 2 platziert:** IVY NACHT Slot 3 („das dritte. … es tippt nie mit. …
  es liest nur.") — korrespondiert mit IVY SCHULD („sie schreibt. … wie ich."). Nicht aendern.

## Akzeptanzkriterien
1. Kein `[PLACEHOLDER: …]` mehr in `$script:PetMemoryTemplates` (alle 6 Kategorien).
2. Bestehende Zeilen (je Companion Slot 1, wo befuellt) unveraendert erhalten.
3. Tokens als Literal erhalten; Recall zeigt echten Text.
4. `_smoke_test.ps1` / `_integration_test.ps1` / `_e2e_test.ps1` gruen; UTF-8 BOM erhalten.
