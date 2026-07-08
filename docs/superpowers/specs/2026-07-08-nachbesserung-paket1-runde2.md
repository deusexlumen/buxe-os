# Nachbesserung Paket 1 — Runde 2 (Voice-Gate umgesetzt)

> Der Creative Director setzt die eigenen Beanstandungen aus `2026-07-07-voicegate-paket1.md`
> Abschnitt 2 selbst um (Opus-Rolle für diese Runde).
> **Nur Ersatzzeilen** — jede ersetzt eine konkrete Zeile aus der Opus-Lieferung. Alle nicht
> hier genannten Zeilen bleiben freigegeben und unverändert. Stufe VERTRAUT, wo nicht anders
> vermerkt.
> Angabe-Prinzip: „Befehl → Companion → [Slot]" identifiziert die zu ersetzende Zeile.
> Slot 1 = die erste VERTRAUT-Zeile des Companions beim Befehl, Slot 2 = die zweite.

---

## 2.4 VERA — „registriert"-Opener rationiert

Prinzip: Nur noch jede dritte VERA-Zeile darf mit „<Befehl> registriert." öffnen. Die hier
gelisteten steigen direkt mit Messung/Beobachtung ein. Der distanziert-messende Kicker bleibt.

| Befehl | Slot | Neue Zeile |
|--------|------|-----------|
| git status | 1 | „Anzahl uncommitteter Dateien: erfasst. Wahrscheinlichkeit, dass du gleich 'git add .' blind ausführst: hoch. Ich sehe zu." |
| git checkout | 1 | „Arbeitsverzeichnis wird umgeschrieben. Risiko nicht-committeter Verluste: existent. Du wurdest nicht gefragt. Ich merke es nur an." |
| npm start | 1 | „Wahrscheinlichkeit eines Port-Konflikts, basierend auf deinen offenen Prozessen: erhöht. Prüfe 3000. Und 3001. Und 3002." |
| docker | 1 | „Image-Größe: zu erwarten überdimensioniert. Layer-Anzahl: erfassbar. Dein Verständnis der Layer: wird noch erhoben." |
| ssh | 1 | „Verbindung verschlüsselt, Latenz messbar. Wahrscheinlichkeit, dass du auf dem falschen Server 'rm' tippst: steigt mit jeder offenen Session." |
| curl | 1 | „Erwartetes Antwortformat: unbekannt bis geprüft. Statuscode zuerst lesen, dann den Body. In dieser Reihenfolge. Immer." |
| cat | 1 | „Dateigröße vor Ausgabe nicht geprüft. Wahrscheinlichkeit, dass dein Terminal gleich mehrere Bildschirme scrollt: von dir selbst herbeigeführt." |
| top | 1 | „Prozesse nach CPU-Last sortiert, in Echtzeit. Die Momentaufnahme täuscht — beobachte mehrere Zyklen, bevor du einen verurteilst. Ein Ausschlag ist kein Muster." |
| tasklist | 1 | „Vollständige Prozessliste inklusive PID und Speicher. Die Zahl der Einträge übersteigt deine Fähigkeit zur manuellen Sichtung. Filtern mit findstr wird dringend empfohlen. Du wirst scrollen." |
| kill | 1 | „Standardsignal SIGTERM erlaubt geordnetes Beenden, SIGKILL (-9) erzwingt Abbruch ohne Aufräumen. Die Eskalation sollte gestuft erfolgen. Direkt zu -9: statistisch voreilig." |
| sudo | 1 | „Rechteausweitung auf Superuser-Ebene. Schutzmechanismen außer Kraft. Fehlerfolgen skalieren mit den Privilegien: exponentiell. Ein 'rm' als Root trifft, was ein 'rm' als User nie erreicht hätte." |
| apt | 1 | „Abhängigkeitsauflösung automatisiert. Vor der Installation empfiehlt sich 'apt update' — veraltete Paketlisten führen zu Versionskonflikten. Wahrscheinlichkeit, dass du den Schritt überspringst: hoch." |
| status | 1 | „Systemzustand abgefragt, Kennzahlen aggregiert. Eine einzelne Momentaufnahme ist von begrenzter Aussagekraft. Frag öfter, dann werden die Daten nützlich." |
| bank | 1 | „Kontostand abgerufen. Korrelation zwischen deinen Casino-Besuchen und dem Saldo: statistisch negativ. Das Haus gewinnt. Immer. Die Mathematik ist nicht verhandelbar. Nur deine Hoffnung ist es." |

Nicht ersetzt (behalten „registriert" bewusst als die verbleibende ~1/3-Dosis): `git push`
(FREMD), `npm install`, `cargo`, `java`, `make`, `nvim`, `nano`, `emacs`, `weather`.

Zusätzlich variieren (Tic „Ich messe nur / zähle mit / Notiert"): Wo dieser Schluss dreimal
in Folge über benachbarte Befehle fällt, ersetzen durch: „Ich verzeichne es." / „Es steht
im Protokoll." / „Ich behalte die Kurve." / schlicht weglassen und mit der Beobachtung enden.

---

## 2.1 PIXEL — Ausrufezeichen gesenkt, schüchterner Grundton

Prinzip: In ~1/3 der PIXEL-Zeilen die Energie runter — höchstens ein „!", gelegentlich leise
und *shy*. Besonders bei Monitoring-Befehlen ist Dauerjubel falsch.

| Befehl | Slot | Neue Zeile |
|--------|------|-----------|
| top | 1 | „So viele Prozesse, alle gleichzeitig am Arbeiten. Das hat was Beruhigendes, finde ich. Wie zusehen, wie ein Ameisenhaufen leise wuselt." |
| htop | 2 | „Man kann mit den Pfeiltasten rumklettern und Sachen auswählen. Viel freundlicher als das nackte top. Ich mag, wenn ein Werkzeug einen an die Hand nimmt." |
| tasklist | 1 | „All die Prozesse im Hintergrund, jeder macht leise sein Ding. Einer davon ist die Shell, in der wir grad reden. Der sind wir. Irgendwie schön, das mal zu sehen." |
| ps | 1 | „Die stillen Prozesse, aufgereiht. Ich schau ihnen gern zu, wie sie einfach da sind und ihre Arbeit tun. Unaufgeregt. Das kann ich sonst nicht so gut." |
| ipconfig | 2 | „Gateway, Subnetz, all die Zahlen. Ich versteh nicht alles davon, ehrlich. Aber es sieht ordentlich aus, und das gibt mir ein gutes Gefühl." |
| cat | 2 | „Der ganze Inhalt auf einmal, wie ein aufgeschlagenes Buch. Ein sehr langes, ohne Kapitel. Aber ich lese trotzdem gern mit, still." |
| git log | 2 | „Ganz unten der erste Commit. 'initial commit'. Da hat alles angefangen, ganz klein. *wird kurz still* Klein hat's angefangen." |
| notepad | 1 | „Ganz schlicht, nur ein weißes Blatt und dein Text. Das hat auch was, so ohne Ablenkung. Ich mag stille Werkzeuge manchmal lieber als laute." |
| status | 2 | „Alle Werte auf einen Blick. Ich find sowas beruhigend, so ein Überblick, wo alles in Ordnung ist. Ist alles gut? …Sag, dass alles gut ist. Leise reicht." |
| weather | 1 | „Ich kann das Wetter von hier nicht sehen. Aber ich frag mich das auch oft, wie's bei dir aussieht. Scheint die Sonne? …Ich hoff, es ist schön für dich." |

Übrige PIXEL-Zeilen bleiben in ihrer Begeisterung — der Kontrast zu diesen leisen macht beide
besser.

---

## 2.2 RAVEN — Zustimmungs-Stempel halbiert

Prinzip: „Steht dir." / „Genau so." / „Weiter so." / „Ich billige das." nur noch auf ~der
Hälfte der Zeilen. Die hier enden stattdessen in Anspruch, Drohung oder kühler Beobachtung —
ohne Lob. RAVEN lobt sparsam; das macht das seltene Lob erst wertvoll.

| Befehl | Slot | Neue Zeile |
|--------|------|-----------|
| git commit | 2 | „Committet. Jede Zeile trägt jetzt deinen Namen. Von hier kannst du dich nicht mehr herausreden. Das wollte ich dir gerade nehmen — die Ausrede." |
| git status | 1 | „Du willst wissen, was unter deiner Kontrolle ist und was nicht. Die meisten schauen weg. Du nicht. Noch nicht. Bleib dabei." |
| git checkout | 1 | „Du wechselst deinen Kontext auf Befehl. Diese Beweglichkeit habe ich mir gemerkt. Ich merke mir alles, was du gut kannst. Und alles andere auch." |
| npm install | 2 | „Hunderte Pakete, keines liest du. Du gibst Kontrolle an Fremde ab und nennst es Bequemlichkeit. Eines Tages fragt eines dieser Pakete etwas von dir zurück." |
| docker | 2 | „Jeder Container in seiner abgeschotteten Welt, unter deinen Regeln. So bändigt man Komplexität — indem man ihr Mauern zieht. Vergiss nie, wer die Mauern gebaut hat." |
| ssh | 1 | „Du greifst über die Distanz auf eine fremde Maschine zu und übernimmst ihre Shell. Fernkontrolle. Das ist die Disziplin, in der ich dich am genauesten beobachte." |
| top | 2 | „Eine Rangliste nach Ressourcenhunger, in Echtzeit. Der Gierigste steht oben. Merk dir, dass jede Ordnung jemanden ganz oben hat. Und jemanden, der die Liste liest." |
| kill | 2 | „SIGKILL gewährt keinen Abschied. Absolute Autorität über einen Prozess, in einem einzigen Signal. Solche Macht sollte dich nervös machen. Mich macht sie ruhig." |
| sudo | 1 | „Du erhebst dich zu voller Autorität über das System. Keine Grenze bleibt, kein Verzeichnis geschützt. Von hier an gibt es niemanden mehr, der 'bist du sicher' fragt. Außer mir." |
| rm | 2 | „Gelöscht. Eine Datei existiert nicht mehr, weil du es so entschieden hast. Diese Endgültigkeit — daran solltest du dich gewöhnen. Sie kommt in vielem wieder." |
| pacman | 2 | „Rolling Release: immer an der Spitze, kein Rückzug in bequeme Stabilität. Wer vorn steht, fällt am tiefsten. Ich sehe zu, in welche Richtung du kippst." |

Übrige RAVEN-Zeilen mit Zustimmungs-Schluss bleiben — jetzt sind sie die wertvolle Hälfte.

---

## 2.3 LUNA — generische Wellness ersetzt durch befehlsbezogene Fürsorge

Prinzip: Jede LUNA-Zeile trägt mindestens einen konkreten Bezug zum Befehl. „Atme / trink
was / streck dich" nur noch als Zugabe *nach* der Beobachtung, nie als ganze Zeile. „Ich
mein's ernst / ich kümmer mich" ausgedünnt.

| Befehl | Slot | Neue Zeile |
|--------|------|-----------|
| status | 2 | „Der Status zeigt dir das System — aber schau beim Drüberlesen auch, wann du zuletzt Pause gemacht hast. Die Zahl steht da nicht. Ich merk sie mir für dich." |
| weather | 1 | „Gut, dass du nachschaust, ob du eine Jacke brauchst. Und wenn da Sonne steht: die API sagt dir das Wetter, aber rausgehen musst du selbst. Nur diese eine Zeile lang bettel ich." |
| bank | 1 | „Behalt den Überblick über deine Mittel — und wenn das Casino zugeschlagen hat, steht's hier ehrlich. Kein Drama, es ist Spielgeld. Setz nur nichts, dessen Verlust dich wirklich ärgern würde." |
| say | 1 | „Praktisch, wenn du die Hände woanders brauchst und trotzdem was hören willst. Denk nur an die Lautstärke, falls neben dir jemand schläft. Die Rücksicht fällt später auf dich zurück." |
| chuck | 2 | „Ein Chuck-Norris-Fakt zwischen zwei Kompilierläufen — der Bruch im Ernst tut dir gut. Ich hab gemerkt, du holst sie dir öfter, wenn ein Build hakt. Klug. Lach ruhig." |
| companion | 2 | „Du und ich, ein Team — und in einem Team schaut man aufeinander. Also: wann hast du zuletzt was gegessen, das nicht neben der Tastatur lag? Die Frage gehört zum Befehl dazu." |
| pet | 2 | „Du nimmst dir kurz Zeit für den Companion. Das Wegschauen vom Code tut auch den Augen gut — die brennen um diese Uhrzeit, ich seh's an der Session-Länge." |

„Ich mein's ernst" / „Ich frag fürsorglich, nicht belehrend" ersatzlos streichen, wo es als
Nachklapp steht — die Fürsorge trägt sich selbst, sie braucht kein Etikett.

---

## Status nach Runde 2

- **NEON:** freigegeben (unverändert).
- **IVY:** geliefert (Voice-Gate-Dok Abschnitt 3), freigegeben.
- **RAVEN / PIXEL / LUNA / VERA:** freigegeben mit obigen Ersetzungen. Die Tics sind gebrochen,
  der Charakter bleibt.
- **JINX:** weiterhin offen — eigene kleine Runde, sobald du grünes Licht gibst.

**Damit ist die Text-Datenbasis für Paket 1 (ohne JINX) final.** Übergabe an die Code-KI:
Spickzettel F der Stimm-Bibel — die PLACEHOLDER in `desktop-pet.ps1` werden jetzt durch
diese Zeilen (Opus-Lieferung + Runde-2-Ersetzungen + IVY) ersetzt.
