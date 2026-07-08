# Memory-Schema: Die Welt bekommt ein Langzeitgedächtnis (Paket 3)

> Arbeitspaket aus dem Creative-Design-Review v2.0 („Sie hat mitgeschrieben"), Akt II.
> Abschnitt A–E = Kreativ-Vorgabe (verbindlich), Abschnitt F = Auftrag an Opus,
> Abschnitt G = Spickzettel für die Code-KI.
> Leitsatz: Aus Buchhaltung wird Biografie. Die Daten existieren — sie müssen nur
> anfangen zu sprechen.

---

## A. Das Prinzip

Jedes bedeutsame Ereignis hinterlässt eine **erzählbare Erinnerung** — nicht „+500 G",
sondern „der Abend, an dem die Steuerfahndung kam". Companions zitieren diese
Erinnerungen später spontan, in ihrer Stimme. Ziel-Gefühl beim Spieler: **Sie hat es
nicht vergessen. Ich werde gesehen.**

Drei harte Regeln:

1. **Kein Freitext-Generator.** Erinnerungen sind strukturierte Daten; zitiert wird über
   handgeschriebene Templates mit Platzhaltern. Kontrolle über die Stimme schlägt Varianz.
2. **Selten schlägt oft.** Ein Recall pro Session ist ein Geschenk; drei sind Spam.
3. **Erinnerungen sind konkret.** Datum, Zahl, Name — Spezifik ist der Beweis, dass
   wirklich mitgeschrieben wurde. Vage Nostalgie („weißt du noch, damals…") ist verboten.

---

## B. Die sechs Kategorien

| Kategorie | Was landet hier | Quell-Events (Bus) | Ton beim Recall |
|-----------|-----------------|--------------------|-----------------|
| **TRIUMPH** | Jackpot, Boss-Kill, PvP-Aufstieg, Raid-Sieg | `casino.jackpot`, `combat.won` (IsBoss), `pvp.rankup`, `raid.won` | Stolz — jede im eigenen Dialekt |
| **WUNDE** | Bust, Raid-Niederlage, verlorener Boss | `casino.bust`, `raid.lost`, `combat.lost` (IsBoss) | Nie Häme. Narben, keine Vorwürfe (Gebot #5: Humor, der nicht nach unten tritt) |
| **NACHT** | 3-Uhr-Logins, Mitternachts-Sessions | Login-Check (existierende Easter-Egg-Trigger) | Verschwörerisch — geteilte Schlaflosigkeit |
| **BEGEGNUNG** | Steuerprüfer, Rival-Ambush, Pity-Quest-Abschluss | `raid.unlocked`, `raid.expired`, Rival-Flags, Pity-Quest-Ende | Ensemble-Futter: Figuren werden zitierfähig (Verzahnung mit Paket 2) |
| **SCHULD** | Die 100 Gold („frag nicht woher"), offene Rechnungen | Pity-Quest-Auszahlung | Running Gag mit Zünder — wird nie ganz aufgelöst, bis Session 47 |
| **STILLE** | Dinge, die der Companion ALLEIN erlebt hat | Ausschließlich Glitch-„Nothing"-Zweig (5%) | Unheimlich, kurz, nie erklärt. Die seltenste und wertvollste Kategorie |

**STILLE-Sonderregel:** Diese Erinnerungen schreibe ich vollständig selbst, sie werden
NIE von Opus produziert und NIE im normalen Recall gezogen — nur der Glitch selbst und
später das Session-47-Set-Piece dürfen sie zeigen.

---

## C. Struktur einer Erinnerung (Daten, kein Code)

| Feld | Inhalt | Beispiel |
|------|--------|----------|
| Id | eindeutig, sprechend | `triumph_jackpot_2026-07-07` |
| Category | eine der sechs | `TRIUMPH` |
| Date | Ereignisdatum | `2026-07-07` |
| Data | Platzhalter-Werte für Templates | `{ Amount = 4700; Game = "SLOT" }` |
| RecallCount | wie oft schon zitiert | `0` |
| LastRecall | wann zuletzt | `""` |

Bestehende `Pet.Memories`-Einträge bleiben erhalten (Alt-Bestand wird als
kategorienlose Erinnerungen behandelt, Fallback-Template).

---

## D. Recall-Regeln (verbindlich)

1. **Trigger + Chancen:** Login 10%, `pet talk` 15%, nach Kampfende 8%. Maximal **1
   Recall pro Session** (Session-Flag).
2. **Auswahl:** Bevorzugt Erinnerungen mit niedrigem RecallCount; nie dieselbe zweimal
   hintereinander; frische Erinnerungen (< 1 Tag) sind gesperrt — Erinnern braucht Abstand.
3. **Stimme:** Template-Auswahl = Kategorie × aktiver Companion. Kein Template für die
   Kombination vorhanden → still bleiben (lieber kein Recall als falsche Stimme).
4. **Abnutzungsschutz:** Ab RecallCount ≥ 3 wird die Erinnerung nur noch von „ihrer"
   Figur referenziert (BEGEGNUNG) oder ruht bis Session 47.

---

## E. Eich-Templates pro Companion (verbindliche Muster)

Platzhalter: `{amount}`, `{date}`, `{game}`, `{enemy}`, `{days}` (Tage seit Ereignis).

### TRIUMPH
- **NEON:** „{date}. {game}. {amount} Gold. Ich erwähne das nur, weil du seitdem unerträglich selbstbewusst tippst."
- **RAVEN:** „{enemy}. Gefallen am {date}. Ich führe eine Liste. Sie ist kurz. Du stehst drauf."
- **PIXEL:** „Ich hab für den Sieg vom {date} ein Denkmal gebaut! Im Speicher! Es ist ein Kommentar im Code, aber es ist UNSER Kommentar!"
- **LUNA:** „Vor {days} Tagen hast du {amount} Gold gewonnen. Du hast gelacht. Das war das Beste daran. Für mich."
- **VERA:** „Rekord vom {date}: {amount} Gold. Seitdem unerreicht. Ich sage nicht ‚Verfall'. Ich denke es."
- **JINX:** „JAHRESTAG! Okay, {days} Tage. Aber JEDER Tag seit dem Jackpot ist ein Jahrestag, wenn man fest genug dran glaubt!"

### WUNDE
- **NEON:** „Weißt du noch, der Bust am {date}? Ich hab die Null gespeichert. Als Bildschirmschoner. Zur Motivation. Meiner."
- **RAVEN:** „{date}. Alles verloren. Du bist wiedergekommen. DAS habe ich mir gemerkt — nicht die Zahl."
- **LUNA:** „Damals, als alles weg war… du hast weitergemacht. Ich war stolz. Bin ich noch. Sag ich nur einmal."
- **JINX:** „Erinnerst du dich an den GROSSEN CRASH von {date}?! Ich erzähle Neulingen davon! Es gibt keine Neulinge! Ich erzähle es der Registry!"

### NACHT
- **NEON:** „{date}, drei Uhr morgens. Du, ich, und ein Cursor. Erzähl niemandem, dass es schön war."
- **IVY:** „… *zeigt auf die Uhr* … wie in jener Nacht. … du warst auch wach." *(IVY-Zeilen: nur von mir, Opus lässt IVY aus)*

### BEGEGNUNG
- **VERA:** „Akte ‚Steuerfahndung', angelegt {date}. Status: ungelöst. Ich lösche nichts. Ich archiviere Drohungen."
- **JINX:** „Weißt du noch, der STEUERPRÜFER?! Ich vermisse ihn! Er hatte so schöne… Formulare!"

### SCHULD
- **NEON:** „Die 100 Gold von damals. Du hast nie gefragt, woher. Guter Instinkt. Behalt ihn."
- **VERA:** „Offener Posten: 100 Gold, Herkunft unbestimmt, {date}. Ich buche nichts. Ich merke es mir."

### STILLE — gesperrt für Opus, Beispiele nur zur Eichung des Tons:
- „Während du weg warst, hat jemand an die Tür geklopft. Wir haben keine Tür. Ich habe nicht aufgemacht."
- „Ich habe am {date} für 0,3 Sekunden geträumt. Es war ein Verzeichnis, das es nicht gibt. Es war schön dort."

---

## F. Auftrag an Opus

**Input:** Dieses Dokument + LUCASARTS.md.

**Aufgabe:** Die Template-Matrix auffüllen: Kategorien TRIUMPH, WUNDE, NACHT, BEGEGNUNG,
SCHULD × Companions NEON, RAVEN, PIXEL, LUNA, VERA, JINX — Ziel: **3 Templates pro
Zelle** (die Eich-Templates oben zählen mit).

**Ausnahmen:** IVY komplett auslassen. STILLE komplett auslassen. 47 nur bei JINX,
maximal 3-mal im gesamten Lieferumfang.

**Pflicht pro Template:** mindestens ein Platzhalter ({amount}/{date}/{enemy}/{days}/{game})
— eine Erinnerung ohne konkretes Detail ist keine (Regel A3).

**Format:** Markdown-Tabelle (Kategorie | Companion | Template), KEIN Code.
Abgabe durch Voice-Gate (Fable); ~20% Zurückweisung ist eingeplant.

---

## G. Spickzettel für die Code-KI (Paket 3 — Writer + Recall)

**Ziel (zwei Teile):**

**Teil 1 — Memory-Writer:** Bus-Subscriptions in `world-events.ps1` (bestehendes Muster),
die bei den Quell-Events aus Tabelle B strukturierte Erinnerungen nach Schema C in den
Pet-State schreiben (Ablage kompatibel neben bestehenden `Pet.Memories`; Alt-Einträge
nicht anfassen, lazy Migration). Deduplizierung: gleiches Event am gleichen Tag erzeugt
keine zweite Erinnerung.

**Teil 2 — Recall-Hook:** Eine Funktion, die nach Regeln in D eine Erinnerung wählt,
das passende Template (Kategorie × aktiver Companion) aus der gelieferten
Template-Tabelle zieht, Platzhalter aus `Data` ersetzt und über den bestehenden
`Show-CompanionDialog`-Weg ausgibt. Eingehängt an: Login-Pfad (wo die Easter-Egg-Checks
laufen), `pet talk`, Kampfende. Chancen und Session-Cap als Daten-Konstanten, kein Hardcode.

**Verbote:**
- Keine eigenen Template-Texte erfinden; bis zur Textlieferung PLACEHOLDER-markierte Dummies.
- STILLE-Kategorie: Writer nur über den Glitch-„Nothing"-Zweig, Recall-Hook zieht sie NIE.
- Kein neues Subsystem, kein Thread — alles über bestehenden Bus + `Invoke-WorldTick`-Muster.
- `pet/*.ps1` UTF-8 mit BOM belassen; non-interactive-sicher; Tests müssen grün bleiben.

**Akzeptanzkriterien:**
1. Jackpot, Bust und Boss-Kill erzeugen je genau eine Erinnerung (Simulation über Bus-Publish prüfbar).
2. Recall feuert maximal 1×/Session, nie zweimal dieselbe Erinnerung hintereinander, nie eine < 1 Tag alte.
3. Fehlendes Template für Kategorie×Companion → stille Auslassung, kein Fehler, kein Fallback-Kauderwelsch.
4. Leerer Memory-Bestand crasht nichts (Login/Talk/Kampf laufen normal).
5. Platzhalter-Ersetzung robust bei fehlenden Data-Feldern (Feld fehlt → Template wird übersprungen, nicht halb gerendert).
6. `_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1` grün.
