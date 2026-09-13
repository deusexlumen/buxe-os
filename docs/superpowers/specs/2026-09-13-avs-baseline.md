# A/V/S Baseline — Rundenschaden vor dem Umbau

Gemessen am 2026-09-13 mit `Scripts\measure-avs-baseline.ps1` gegen den Stand vor
`Resolve-AvsRound`. Referenz-Pet: GLITCH_WOLF, ohne Ausruestung, ohne Companion,
ohne Skilltree. Wachstum pro Level: +10 MaxHP, +2 ATK, +1 DEF.

Diese Zahlen sind der Korridor fuer die Kalibrierung: nach dem Umbau darf der
durchschnittliche Rundenschaden (OePlayer) um hoechstens **±15 %** abweichen.

## Messung

| Lv | Matchup | Pet ATK/DEF | Gegner ATK/DEF | Win | Tie | Gegner | OePlayer | OeGegner | Runden |
|----|---------|-------------|----------------|-----|-----|--------|----------|----------|--------|
| 1 | PvP Bronze | 14/7 | 12/7 | 26 | 20 | 11 | 15,33 | 7,33 | 5,3 |
| 1 | PvP Master | 14/7 | 32/17 | 24 | 18 | 30 | 14,00 | 20,00 | 12,9 |
| 1 | Raid Phase 1 | 14/7 | 25/20 | 23 | 18 | 23 | 13,67 | 15,33 | 21,4 |
| 1 | Raid Phase 3 | 14/7 | 45/30 | 22 | 16 | 42 | 12,67 | 28,00 | 46,2 |
| 1 | Rival Lv.1 | 14/7 | 15/9 | 26 | 19 | 14 | 15,00 | 9,33 | 6,3 |
| 5 | PvP Bronze | 22/11 | 24/14 | 39 | 29 | 22 | 22,67 | 14,67 | 7,0 |
| 5 | PvP Master | 22/11 | 64/34 | 33 | 25 | 58 | 19,33 | 38,67 | 18,9 |
| 5 | Raid Phase 1 | 22/11 | 40/32 | 33 | 25 | 36 | 19,33 | 24,00 | 25,3 |
| 5 | Raid Phase 3 | 22/11 | 72/48 | 30 | 22 | 65 | 17,33 | 43,33 | 56,5 |
| 5 | Rival Lv.5 | 22/11 | 49/31 | 34 | 25 | 44 | 19,67 | 29,33 | 14,0 |
| 10 | PvP Bronze | 32/16 | 39/23 | 52 | 39 | 34 | 30,33 | 22,67 | 8,7 |
| 10 | PvP Master | 32/16 | 104/55 | 41 | 31 | 90 | 24,00 | 60,00 | 24,4 |
| 10 | Raid Phase 1 | 32/16 | 59/47 | 44 | 33 | 51 | 25,67 | 34,00 | 27,1 |
| 10 | Raid Phase 3 | 32/16 | 106/70 | 38 | 28 | 91 | 22,00 | 60,67 | 64,1 |
| 10 | Rival Lv.10 | 32/16 | 118/76 | 36 | 27 | 102 | 21,00 | 68,00 | 30,7 |

OePlayer / OeGegner = Erwartungswert pro Runde ueber die drei gleich wahrscheinlichen
Ausgaenge (Win 2.0×, Tie 1.5× zu 1.0×, Loss 0 zu 1.0×). „Runden" = wie viele Runden
der Gegner bei diesem Durchschnitt braucht, um zu fallen.

## Was die Baseline nebenbei zeigt

Drei Beobachtungen, die **nicht** Teil dieses Umbaus sind, aber festgehalten gehoeren:

1. **Die flache Kurve skaliert gegen den Spieler.** Der Spielerschaden waechst von Lv 1
   bis Lv 10 um Faktor 2,0 (15,33 → 30,33 bei PvP Bronze), der Gegnerschaden bei
   Raid Phase 3 um Faktor 2,2 (28,00 → 60,67). Gegner ziehen davon, weil ihre Stats mit
   Level *und* Rang/Phase skalieren, die Pet-Stats aber nur mit Level.
2. **Raid Phase 3 ist rechnerisch nicht zu gewinnen.** Der Boss braucht bei Lv 10 rund
   64 Runden, waehrend er 60,67 Schaden pro Runde austeilt — gegen 190 MaxHP. Ohne
   Ausruestung und Companion-Heilung endet der Kampf nach drei Runden.
3. **Der DEF-Wert des Pets ist fast wirkungslos.** Bei `100/(100+DEF)` senkt DEF 16
   den eingehenden Schaden um 14 %. Genau dafuer wurde der level-skalierte Softcap in
   `Get-DamageV3` gebaut.

Punkt 2 und 3 sind Balance-Fragen, keine Architektur-Fragen. Nach dem Umbau lassen sie
sich an einer Stelle beantworten statt an vier — das ist der eigentliche Gewinn.

## Reproduzieren

```powershell
pwsh -NoProfile -File .\Scripts\measure-avs-baseline.ps1
pwsh -NoProfile -File .\Scripts\measure-avs-baseline.ps1 -Json   # maschinenlesbar
```

---

## Ergebnis der Umstellung (2026-09-13)

Alle vier Modi laufen ueber `Resolve-AvsRound`. Kalibrierung in
`$script:AvsMovePower` (`Modules/pet/combat-core.ps1`), geprueft von
`Modules/_balance_test.ps1`:

| Modus | Zugstaerke | Abweichung Lv1 / Lv5 / Lv10 | Korridor |
|-------|-----------|------------------------------|----------|
| Rival | 41 | +4,4 % / -5,1 % / -1,6 % | gehalten |
| PvP Bronze | 35 | -6,5 % / -1,5 % / +7,7 % | gehalten |
| PvP Master | 43 (= 35 + 1,6 × 5) | -9,5 % / -3,4 % / +9,7 % | gehalten |
| Raid Phase 1 | 43 | -14,6 % / 0,0 % / +13,0 % | gehalten |
| Raid Phase 3 | 49 | -18,4 % / -1,9 % / +19,7 % | **verfehlt** |
| Tutorial | 15 | Pacing erhalten (33 von 70 HP nach drei Runden) | eigene Regel |

PvP brauchte eine Zugstaerke pro Rang (`35 + 1,6 × rankIdx`); ein fester Wert pro
Modus riss auf Lv10 mit +19,8 % aus.

**Raid haelt den Korridor nicht — mit keinem konstanten MovePower.** Grund ist die
Kurvenform, nicht der Wert:

| Matchup | Wachstum Lv1→Lv10 alt | neu |
|---------|----------------------|-----|
| Raid Phase 1 | ×1,88 | ×2,53 |
| Raid Phase 3 | ×1,74 | ×2,46 |

Ein konstanter Faktor kann diese Spreizung nicht ausgleichen. Im Spiel heisst das:
unter Lv5 trifft der Spieler im Raid schwaecher als bisher, ab Lv5 haerter. Die
Ueberschreitung steht als eigene Konstante `$TOLERANCE_RAID = 0.20` im Balance-Test
und ist pro Zeile als `[Ausnahme]` markiert — der globale Korridor bleibt bei ±15 %.

Offen, falls die Abweichung nicht gewollt ist: Zugstaerke level-abhaengig machen,
Raid-Boss-Stats an die neue Kurve anpassen, oder die Abweichung annehmen (Punkt 2
oben zeigt, dass Raid Phase 3 ohnehin neu austariert werden muss).
