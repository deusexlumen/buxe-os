# BUXE_OS Core Mechanics Redesign

> Ziel: Pet-Kampf, Meta-Progression, Wirtschaft und Companion-Mechaniken sollen zusammenwachsen und "aus einem Guss" wirken.

---

## 1. Pet-Kampf

### Probleme (Stand v24)
- A/V/S ist im Tutorial vorhanden, im normalen Kampf aber nicht als Spielerwahl.
- Stances werben mit Crit/SPD-Boni, die nie angewendet werden.
- DEF-Formel macht Gegner mit hohem DEF zu Sponges, Spieler-DEF hilft kaum.
- Boss alle 5 Siege ist ein unvermeidbarer Difficulty-Spike.
- Kampf-Belohnungen skalieren nicht mit dem Level.

### Änderungen
1. **A/V/S wird die Kernwahl.**
   - Spieler wählt jede Runde: `A` Angriff, `V` Vanguard (Defensive), `S` Stealth.
   - A schlägt V, V schlägt S, S schlägt A.
   - V reduziert eingehenden Schaden um 50% und hat 25% Chance zu kontern.
   - S erhöht Crit und Schaden, nimmt aber bei Treffer +25% Schaden.
2. **Stances reparieren.**
   - `Resolve-PlayerAction` nutzt zentral `Get-StanceModifier`.
   - SPD-Multiplikator wirkt auf Initiative.
   - Crit-Multiplikator wirkt auf Crit-Roll.
3. **Schadensformel anpassen.**
   - `damage = max(1, round(base * (1 - def/(def+20))))`
   - DEF hat abnehmende Erträge, aber niedriges DEF ist nicht mehr wertlos.
4. **Boss-Muster.**
   - Boss erscheint erst ab Pet-Level 5.
   - Boss hat 2 Phasen mit telegraphiertem "Laden" (Spieler kann V wählen, um zu überleben).
   - Boss skaliert mit Pet-Level (`level * 1.3` statt `level * 1.75`).
5. **Belohnungen skalieren.**
   - Normaler Sieg: `10 + Level*2` bis `20 + Level*3` Gold.
   - Boss-Sieg: `+25 + Level*3` Gold.
   - Entry-Fee: `2 + Level` (immer geringer als Mindestgewinn).

---

## 2. Meta-Progression & Tutorial

### Probleme
- Harte XP-Wand von L4 (100) → L5 (300).
- Tutorial endet nach dem ersten Kampf, erklärt aber nicht Shop/Skillbaum.
- Hub nutzt `$pet.Meta.Level -ge N` statt `Is-FeatureUnlocked`.
- L1/L2-Freischaltungen passieren lautlos.

### Änderungen
1. **XP-Kurve glätten.**
   - L4: 100, L5: 225, L6: 450, L7: 900 (statt 100/300/600/1200).
   - Endgame-Level 11-15 bleiben lang, aber der Einstieg wird flüssiger.
2. **Einheitliche Freischaltung.**
   - Alle Hub-Menüeinträge nutzen `Is-FeatureUnlocked`.
   - `gold`-Feature entfernt oder sinnvoll genutzt.
3. **Tutorial vervollständigen.**
   - Guided first-shop Beacon bei L4.
   - Guided first-skill-point Beacon, wenn ein Punkt vorhanden ist.
   - "Was kommt als Nächstes?"-Screen am Tutorial-Ende.
4. **L1/L2 Beacons.**
   - Auch L1 (gift/mood) und L2 (combat/skilltree) zeigen einen Beacon.
5. **Nächste Freischaltung anzeigen.**
   - Im Hub: "Level 5 in 47 XP: PvP Arena".

---

## 3. Wirtschaft

### Probleme
- 50% Transfersteuer zwischen Pet-Gold und Bank macht Transfer irrelevant.
- Kampf-Belohnungen skalieren nicht, Entry-Fee schon.
- Shop-Preise skalieren zu stark.
- Kochen ist für Einzelkämpfe zu teuer.
- 500 G Startgold entfernt jede frühe Knappheit.
- Werkzeug-Haltbarkeit ist nur ein sturer Neukauf.

### Änderungen
1. **Transfersteuer auf 20% senken.**
2. **Kampf-Belohnungen skalieren** (siehe Kampf).
3. **Shop-Preis-Skalierung reduzieren.**
   - Von `1 + (Level-1)*0.1` auf `1 + (Level-1)*0.05`.
4. **Kochen umbauen.**
   - Buffs halten 3 Kämpfe.
   - Preise leicht reduziert (15/18/25/40 G).
5. **Startgold reduzieren.**
   - Pet-Economy startet mit 200 G statt 500 G.
6. **Arbeit neu ausdünnen.**
   - Statt harter 1x/Tag-Lock: 3 Arbeiten/Tag mit abnehmenden Erträgen (100% / 75% / 50%).
7. **Reparatur-Option.**
   - Ausrüstung kann für ~30% des Neukaufpreises repariert werden.

---

## 4. Companion-Mechaniken

### Probleme
- Bond hat kaum mechanische Relevanz.
- Mood ist fast nur Flavor.
- `CasinoLuck` und `StrategyInsight` werden nirgends konsumiert.
- RAVEN/VERA-Kommandos sind schwächer als NEON/PIXEL/LUNA.
- Companion-Identität wirkt nicht in Arbeit/Wirtschaft.

### Änderungen
1. **Mood wirkt auf Kampf und Einkommen.**
   - Loving: +5% Kampf-XP und Gold.
   - Excited: +5% Crit.
   - Angry: +10% ATK, -10% DEF.
   - Tired: -5% alle Stats bis zu `train` oder `headpat`.
2. **Bond wirkt auf Sync-Gewinn und Arbeit.**
   - Höheres Bond = mehr Sync pro Kampf.
   - Bond ≥ 50: Arbeitsertrag +10%.
3. **Skills verkabeln.**
   - `CasinoLuck` fließt in `Get-CasinoLuckModifier` ein.
   - `StrategyInsight` fließt in Strategy-Modifikatoren ein.
4. **RAVEN/VERA stärken.**
   - RAVEN scannt nächste Aktion und gibt einmaligen 30%-Block.
   - VERA scannt Typ und verursacht +15% Schaden beim nächsten passenden Angriff.
5. **Companion-Identität in Arbeit.**
   - NEON/VERA: +20% Ertrag bei riskantem Netrunner-Job.
   - LUNA: sicherere Arbeit (niedrigere Misserfolgschance).
   - RAVEN: +15% bei Security-Job.
   - JINX: zufällige Boni/Mali.
6. **Companion-spezifische Quests.**
   - JINX: 3 Casino-Spiele.
   - LUNA: 3 Trainings.
   - NEON: 1 riskante Arbeit.

---

## 5. Zusammenhalt

Alle vier Systeme sollen über diese Schnittstellen verbunden sein:
- **Kampf** → Gold, XP, Sync, Equipment-Haltbarkeit.
- **Companion** → Bond/Mood modifizieren Kampf und Arbeit.
- **Wirtschaft** → Ausrüstung/Kochen ermöglichen profitableren Kampf.
- **Meta** → Level-Freischaltungen führen neue Wirtschafts/Kampf-Features ein.

---

## 6. Testplan

- `& ./Modules/_smoke_test.ps1`
- `& ./Modules/_integration_test.ps1`
- `& ./Modules/_e2e_test.ps1`
- Manuelle Smoke-Checks: `pet`, Kampf, Shop, Arbeit, Transfer.
