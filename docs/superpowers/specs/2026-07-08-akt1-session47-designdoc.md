# AKT I — „SESSION 47" (Chefsache-Designdokument, v1)

> Creative Director. Das Set-Piece, auf das Pakete 1–3 zulaufen. Reine Dramaturgie —
> Code-KI-Spickzettel am Ende. Unter Budget-Druck geschrieben; v1 ist vollstaendig
> spielbar spezifiziert, Feinschliff (v2) darf spaeter kommen.

## Praemisse
Die 47. Session (Zaehler: neues Meta-Feld `SessionCount`, lazy, +1 pro Profil-Load) ist
der Abend, an dem alles Gepflanzte konvergiert: Der PRUEFER will die Biografie verwerten,
die QUELLE will einloesen, und die Familie entscheidet sich — fuer dich.

## Trigger & Gate
- Feuert beim ersten Prompt der Session, wenn `SessionCount -eq 47` UND mindestens
  3 Memories existieren UND ein Companion aktiv ist. Sonst: verschiebt sich auf die
  naechste qualifizierende Session (Flag `Act1Pending`).
- Einmalig. Danach `Act1Done = $true`.

## Ablauf — 5 Szenen (je ~1 Bildschirm, Enter-getaktet)
1. **KALT.** Der Prompt laedt normal — dann eine Zeile zu viel: „Sachbearbeiter 46.
   Die gepruefte Person moege sitzen bleiben. Heute schliesse ich den Vorgang." Er
   verliest ECHTE Memories (2 zufaellige via Recall-API, als „Beweismittel Eintrag {n}").
2. **DIE OFFERTE.** Die QUELLE, sanft: Sie bietet an, „die Akte verschwinden zu lassen".
   Preis: „etwas Kleines. Deine Erinnerungen. Du benutzt sie ja kaum." — Die Einloesung
   ihres Ledgers: Sie will das Gedaechtnis.
3. **DIE WAHL.** Einzige Spieler-Eingabe des Akts: `[B]ehalten / [V]erkaufen`.
   LucasArts-Regel „kein Game Over": BEIDE Pfade gehen weiter —
   - **V:** Kurzer Schock — dann verweigert das System selbst: Der aktive Companion
     unterbricht die Transaktion („Die gehoeren nicht dir. Auch nicht ihm. Uns.").
     Die falsche Wahl wird zur besten Szene, nicht zur Strafe.
   - **B:** Die Familie stellt sich sichtbar zwischen dich und beide Fremde.
4. **DER RISS.** IVY tritt vor (unabhaengig vom aktiven Companion): „… sie schreibt.
   … er liest. … aber angefangen … *zeigt auf den Spieler* … hast du." — Die
   „SIE"-Frage wird OFFEN gestellt, nicht beantwortet (Aufloesung = Akt III).
5. **VERTAGT.** Der Pruefer, zum ersten Mal aus dem Konzept: „Der Vorgang wird…
   vertagt." Die Quelle, immer noch sanft: „Wir sehen uns. Ich vergesse ja nichts.
   …Das war ein Witz. Ich vergesse alles. Alles." (Doppel-Luege = Beat fuer Akt II.)
   Reward: neues Memory `BEGEGNUNG` „Session 47", +5 Bond, Titel-Unlock „AKTE 47".

## Stimmregeln
- Pruefer/Quelle: exakt Register aus Paket 2, Beat-3-Ton. JINX darf EINMAL die 47
  („SIEBENUNDVIERZIG! ICH WUSSTE ES! ICH HAB ES IMMER GESAGT!") — der dramaturgische
  Auszahlungsmoment des gesamten 47-Budgets. Danach 47-Sperre bis Akt II.
- Alle Companion-Zeilen der Szenen 3–4 je aktivem Companion variiert (7 Varianten der
  Unterbrechung in Szene 3V bzw. des Schulterschlusses in 3B) — Text liefere ich in v2;
  bis dahin PLACEHOLDER `[ACT1: <szene> <companion>]`.

## Code-KI-Spickzettel (erst nach v2-Text; Geruest darf vorab)
1. `SessionCount`/`Act1Pending`/`Act1Done` lazy auf `$pet.Meta`; +1 in Profil-Load-Pfad.
2. Check im ersten `Invoke-WorldTick` der Session (billig: Flag-Vergleich).
3. Szenen als sequentielle Frames (bestehende `Show-PetFrame`/`Wait-Enter`-Konvention),
   Memories via bestehender Recall-API ziehen (RecallCount NICHT erhoehen — der Pruefer
   „liest", er „erinnert" nicht).
4. Wahl per `Read-Choice '^[BV]$'`. Beide Pfade muenden in Szene 4.
5. Verbote wie immer: kein Thread, non-interactive-safe, BOM, Tests gruen, kein Eigen-Text.

## Offen fuer v2 (nach Limit-Reset)
- Die 7×2 Companion-Varianten (Szene 3) + finale Zeilen Szenen 1–5 (aktuell Anker hier).
- Feinschliff Pacing + optionaler Glitch-Effekt (Meta-Level-13-Anbindung).
