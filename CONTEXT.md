# CONTEXT.md — Domain-Glossar

Begriffe dieses Projekts, so wie sie im Code heissen sollen. Wer ein module benennt,
nimmt einen Begriff von hier — oder traegt den neuen hier ein.

Angelegt am 2026-09-13 beim Zusammenziehen der Kampfmathematik. Noch unvollstaendig:
Casino, Arcade und Adventure haben ihre Begriffe hier noch nicht.

---

## Kampf (Pet-System)

**A/V/S-Runde**
Eine Runde Schere-Stein-Papier zwischen Pet und Gegner: **A**ngriff schlaegt
**V**erteidigung, V schlaegt **S**pecial, S schlaegt A. Gleicher Zug = beide treffen,
der Angreifer haerter. Die Runde ist die kleinste Regel-Einheit des Pet-Kampfs — sie
entscheidet ueber Ausgang und Schaden, nicht ueber Anzeige, HP-Buchfuehrung oder Belohnung.
Nicht "RPS", nicht "Zug", nicht "Turn".

**Rundenausgang**
Das Ergebnis einer A/V/S-Runde aus Sicht des Spielers: `Win`, `Tie` oder `Loss`.
Bestimmt, welcher Multiplikator auf den Schaden geht. Der Ausgang kann erzwungen werden
— das Tutorial tut das, damit neue Spieler nicht verlieren.

**Zugstaerke** (`MovePower`)
Wie hart ein Zug grundsaetzlich zuschlaegt, unabhaengig von Stats. Referenzwert 40.
Einziger Stellhebel, mit dem ein Modus auf seine gewohnten Schadenszahlen kalibriert wird.

**Modus**
Ein Spielmodus, der eigene A/V/S-Kaempfe austraegt: Pet-Kampf, PvP, Raid, Rival, Tutorial.
Jeder Modus hat eigene Gegner, eigene Belohnung und eigene Anzeige — aber dieselben
Kampfregeln. Nicht "Spielmodus", nicht "Mode".

**Effektive Stats**
Die Werte eines Pets nach Ausruestung, Buffs, Status-Effekten und Companion-Boni
(`Get-EffectiveStats`). Was in die Schadensformel geht, sind immer effektive Stats,
nie die Basiswerte des Pets.

**Damage-Sponge**
Gegner, dessen DEF so hoch ist, dass Schaden gegen ihn praktisch auf 1 faellt.
Der level-skalierte DEF-Softcap in `Get-DamageV3` existiert, um genau das zu verhindern.

---

## Companion

**Companion**
Eine der sieben Figuren (NEON, RAVEN, PIXEL, LUNA, IVY, VERA, JINX). Kaempft nicht
selbst, sondern begleitet, kommentiert und gibt Boni.

**Bond**
Bindung zwischen Spieler und Companion, 0-100. Schaltet Verhalten frei, nicht Zahlen
allein — ab Bond 30 kommentiert die Companion den Kampf, ab 80 anders.

**Stimme**
Der unveraenderliche Sprechstil einer Companion. Die Regeln stehen in `LUCASARTS.md`;
eine Companion mischt ihre Stimme nie mit einer anderen.
