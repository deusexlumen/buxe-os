# Pet Combat Redesign v24.12 — Tactical Combat System

## Zusammenfassung

Das Pet-Kampfsystem wird von einem statischen 3-Runden-RPS (Rock-Paper-Scissors) zu einem **taktischen, rundenbasierten Kampfsystem** mit echter strategischer Tiefe umgebaut. Kernfeatures: Initiative-System, Stances, Pet-Switch, Status Effects, Limit Breaks, Gegner-Tells, Companion Cooldowns, strategische Items, und ein globales Readability-Fix fuer `Show-CompanionDialog`.

## Design-Philosophie

- **D&D-artig mit LucasArts-Touch**: Jede Aktion wird narrativ beschrieben. Companion-Kommentare waehrend des Kampfes. Humor ueber Drama.
- **Nie unbesiegbar**: Ein Boss kann immun gegen deinen Typ sein — aber du kannst wechseln, buffen, debuffen, oder fliehen.
- **Nutzer bestimmt Tempo**: Nach jedem wichtigen Schritt `[Enter]` druecken. Nie wieder ueberlesene Texte.

## Architektur

### Kampf-Loop (pro Runde)

```
1. Initiative bestimmen (SPD-Stat)
2. Kampf-Screen anzeigen (HP-Balken, Runden-Log, Gegner-Tell)
3. Spieler waehlt Action:
   - [1] Attack — Waehle Attacke
   - [2] Defend — Schaden -50%
   - [3] Switch — Wechsle Pet (kostet Runde)
   - [4] Companion — Companion-Command (mit Cooldown)
   - [5] Item — Nutze Item
   - [6] Flee — Fluchtversuch
   - [F1-F4] Stance — Wechsle Stance
4. Aktion ausfuehren + narrativer Text
5. Gegner reagiert (Pattern-basiert bei Bossen, zufaellig bei Normal)
6. Status Effects ticken (Burn, Poison, etc.)
7. Limit Break-Check (unter 25% HP)
8. Kampfende? (HP = 0 oder Flee erfolgreich)
9. [Enter] zum Fortfahren
```

## Detaillierte Mechaniken

### 1. Initiative

```powershell
$playerInit = Get-Random -Minimum 1 -Maximum 100 + $playerStats.SPD
$enemyInit = Get-Random -Minimum 1 -Maximum 100 + $enemyStats.SPD
```

Wer hoehere Initiative hat, greift zuerst an. Bei Gleichstand: Münzwurf.

### 2. Stance-System

Pro Runde kann der Spieler eine Stance waehlen (aehnlich wie bei Pokemon):

| Stance | ATK | DEF | SPD | Heal/Runde | Beschreibung |
|--------|-----|-----|-----|-----------|-------------|
| Aggressiv | ×1.5 | ×0.5 | — | — | "Vollgas, Vollkatastrophe" |
| Defensiv | ×0.5 | ×1.5 | — | +5% MaxHP | "Nutzlose Panzerscheibe" |
| Speed | — | — | ×1.5 | — | "Lieber Feige als Tot" |
| Balanced | — | — | — | — | "Langweilig. Aber funktional." |

Stance wird zu Beginn der Runde gewaehlt und gilt fuer die gesamte Runde.

### 3. Pet-Switch

Wenn der Spieler mehrere Pets hat (Breeding, Zucht), kann er zwischen ihnen wechseln:
- Switch kostet eine volle Runde
- Der Gegner greift in dieser Runde frei an
- Das neue Pet kommt mit vollem HP (oder dem HP, das es beim letzten Kampf hatte)

Das loest das "eine Attacke gegen immunen Boss"-Problem.

### 4. Status Effects

Jede Attacke hat eine Chance, einen Status Effect zu verursachen:

| Effect | Typ | Chance | Dauer | Effekt |
|--------|-----|--------|-------|--------|
| Burn | FIRE | 30% | 3 Runden | -5% MaxHP/Runde |
| Freeze | ICE | 25% | 1 Runde | Gegner ueberspringt naechste Runde |
| Poison | VIRUS | 35% | 4 Runden | -3% MaxHP/Runde, stackbar bis 5× |
| Paralyze | ELEC | 20% | 2 Runden | 50% Chance, Zug zu ueberspringen |
| DEF-Down | DARK | 40% | 2 Runden | DEF -30% |
| ATK-Up | — | — | 2 Runden | ATK +20% (Buff, z.B. durch Item) |

Status Effects ticken am Ende jeder Runde (nach Gegner-Zug).

### 5. Limit Break

Wenn das Pet unter 25% HP faellt (erstmalig im Kampf), kann der Spieler einen Limit Break aktivieren:
- Einmal pro Kampf
- Mega-Schaden (×2.5 Basis-Power)
- Garantierter Status Effect
- Companion-Kommentar: "Das ist es! Unser finales Argument!"

### 6. Gegner-Tells (Boss-Gegner)

Jeder 5. Kampf = Boss. Boss-Gegner haben Phasen + Warnungen:

```powershell
$bossPatterns = @{
    "BOSS_OMEGA" = @{
        Phase1 = @{ HP = 100; Behavior = "Random" }
        Phase2 = @{ HP = 50; Behavior = "Aggressive"; Tell = "Der BOSS_OMEGA lädt seinen OMEGA-BEAM auf..." }
        Phase3 = @{ HP = 25; Behavior = "Desperate"; Tell = "BOSS_OMEGA überhitzt! Kerninstabilität erkannt!" }
    }
}
```

- **Phase 1**: Zufaelliges Verhalten
- **Phase 2** (HP < 50%): Bevorzugt Angriff, Warnung vor Stark-Attacke
- **Phase 3** (HP < 25%): Bevorzugt Special, extrem hoher Schaden, Warnung vor Ultra-Attacke

Der Spieler sieht die Warnung am Anfang der Runde und kann reagieren (Defend, Switch, Item).

### 7. Companion Cooldowns

Companion-Commands sind nicht jede Runde verfuegbar:

| Companion | Command | Cooldown | Effekt |
|-----------|---------|----------|--------|
| NEON | Hack | 3 Runden | Gegner-DEF -30% fuer 2 Runden |
| RAVEN | Predator Eye | 2 Runden | Zeigt Gegner-Zug vorher an |
| PIXEL | Shield Deploy | 3 Runden | Pet-DEF +40% fuer 2 Runden |
| LUNA | Heal | 3 Runden | +25% MaxHP |
| IVY | Silence | 4 Runden | Gegner kann keine Specials nutzen |
| VERA | Predict | 2 Runden | Zeigt Gegner-Zug + Schwäche |
| JINX | Chaos Roll | 1 Runde | Zufall: ATK+30%, SPD-20%, oder beides |

Cooldowns werden im Kampf-State gespeichert und pro Runde dekrementiert.

### 8. Strategische Items

Items aus dem Inventar koennen im Kampf genutzt werden:

| Item | Effekt | Nutzung |
|------|--------|---------|
| Heiltrank | +30% MaxHP | Pro Kampf 3× |
| Data Shard | Scannt Gegner (zeigt Stats, Schwäche, Muster) | Einmal pro Kampf |
| Overclock | ATK +50% diese Runde, -20% MaxHP nach Kampf | Einmal pro Kampf |
| EMP | Deaktiviert Gegner-Special fuer 2 Runden | Einmal pro Kampf |
| Smoke Bomb | Fluchtchance +40% | Einmal pro Kampf |

### 9. Weakness-Scanner

Nach dem ersten Treffer auf den Gegner (oder durch Data Shard / VERA Predict) wird angezeigt:
```
[SCAN] SPAM_BOT: SCHWACH gegen VIRUS(+50%) | STARK gegen NORM(-25%)
```

### 10. Kampf-Log

Die letzten 3 Runden werden angezeigt:
```
R5: SPAM_BOT → Angriff → GLITCH_WOLF: -12 HP
R6: GLITCH_WOLF → Neural Overload → SPAM_BOT: -23 HP [BURN]
R7: SPAM_BOT → Special → GLITCH_WOLF: -18 HP (Defensiv-Stance!)
```

## Datenstrukturen

### Neue Pet-Attacken

```powershell
$script:BPAttacks = @{
    "Neural Overload" = @{ Type = "VIRUS"; Power = 40; Accuracy = 95; Effect = "Poison"; EffectChance = 35 }
    "Bit Crusher"     = @{ Type = "NORM";  Power = 35; Accuracy = 100; Effect = $null; EffectChance = 0 }
    "Debug Patch"     = @{ Type = "NORM";  Power = 30; Accuracy = 100; Effect = "Heal"; EffectChance = 100 }
    "Plasma Lance"    = @{ Type = "FIRE";  Power = 50; Accuracy = 85;  Effect = "Burn"; EffectChance = 30 }
    "Ice Spike"       = @{ Type = "ICE";   Power = 45; Accuracy = 90;  Effect = "Freeze"; EffectChance = 25 }
    "System Purge"    = @{ Type = "VIRUS"; Power = 55; Accuracy = 80;  Effect = "Poison"; EffectChance = 40 }
    "Water Cannon"    = @{ Type = "WATER"; Power = 45; Accuracy = 90;  Effect = $null; EffectChance = 0 }
    "Overclock"       = @{ Type = "ELEC";  Power = 60; Accuracy = 75;  Effect = "Paralyze"; EffectChance = 20 }
    "Shadow Claw"     = @{ Type = "DARK";  Power = 50; Accuracy = 85;  Effect = "DEF-Down"; EffectChance = 40 }
    "Firewall"        = @{ Type = "FIRE";  Power = 40; Accuracy = 95;  Effect = "Burn"; EffectChance = 35 }
    "Zero-Day"        = @{ Type = "VIRUS"; Power = 70; Accuracy = 70;  Effect = "Poison"; EffectChance = 50 }
}
```

### Kampf-State (temporaer, nicht persistent)

```powershell
$script:CombatState = @{
    Round = 1
    PlayerStance = "Balanced"
    StatusEffects = @()  # @{ Target = "player/enemy"; Type = "Burn"; Turns = 3; Value = 0.05 }
    CompanionCooldowns = @{ "NEON" = 0; "RAVEN" = 0; ... }
    LimitBreakUsed = $false
    BattleLog = @()
    PlayerPetIndex = 0  # welches Pet aktuell im Kampf ist
}
```

### Gegner-Patterns

```powershell
$script:BossPatterns = @{
    "BOSS_OMEGA" = @{
        Phases = @(
            @{ HPPercent = 100; Behavior = "Random"; Tell = $null }
            @{ HPPercent = 50;  Behavior = "Aggressive"; Tell = "Der BOSS_OMEGA lädt seinen OMEGA-BEAM auf..."; WarnTurns = 1 }
            @{ HPPercent = 25;  Behavior = "Desperate"; Tell = "BOSS_OMEGA überhitzt! Kerninstabilität erkannt!"; WarnTurns = 1 }
        )
    }
}
```

## Code-Aenderungen pro Datei

### `Modules/pet/combat.ps1`

**KOMPLETT neu schreiben** — `Start-PetFight` wird ersetzt durch das neue taktische System:

1. `Invoke-TacticalCombat` — Hauptfunktion, verwaltet den Kampf-Loop
2. `Show-CombatScreen` — Zeigt HP-Balken, Runden-Log, Gegner-Tell, Menue
3. `Get-CombatInitiative` — Bestimmt, wer zuerst angreift
4. `Resolve-PlayerAction` — Fuehrt Spieler-Aktion aus
5. `Resolve-EnemyAction` — Fuehrt Gegner-Aktion aus (Pattern-basiert)
6. `Apply-StatusEffects` — Tickt Status Effects
7. `Show-CombatNarrative` — Zeigt D&D-artigen Beschreibungstext
8. `Invoke-LimitBreak` — Aktiviert Limit Break
9. `Use-CompanionCommand` — Fuehrt Companion-Command aus (mit Cooldown)
10. `Switch-CombatPet` — Wechselt das aktive Pet

**Alte Funktionen behalten** (fuer Kompatibilitaet):
- `Start-PetTutorialFight` — bleibt unveraendert (Tutorial muss einfach bleiben)
- `Get-EffectiveStats` — bleibt, wird erweitert um Stance-Modifier
- `Use-CompanionCombatAbility` — wird zu `Use-CompanionCommand`
- `Invoke-PetLevelUpCheck` — bleibt unveraendert

### `Modules/pet/_ui.ps1`

**Aenderung an `Show-CompanionDialog`:**

```powershell
function Show-CompanionDialog($Companion, $Text, [switch]$Fast, [switch]$NoWait) {
    # ... bestehender Typewriter-Code ...
    if (-not $NoWait -and -not $Fast) {
        Wait-Enter
    }
}
```

- `-Fast`: Typewriter schnell, aber KEIN Wait-Enter (fuer Flavour-Text in Loops)
- `-NoWait`: Kein Typewriter, kein Wait (fuer UI-Updates)
- Default: Typewriter + Wait-Enter (Nutzer bestimmt Tempo)

**Neue Funktion `Show-CombatLog`:**
Zeigt die letzten 3 Runden des Kampfes an.

**Neue Funktion `Show-HPBar`:**
```powershell
function Show-HPBar($Current, $Max, $Width = 20) {
    $filled = [math]::Round(($Current / $Max) * $Width)
    $bar = ("█" * $filled) + ("░" * ($Width - $filled))
    $color = if ($Current / $Max -gt 0.5) { "Green" } elseif ($Current / $Max -gt 0.25) { "Yellow" } else { "Red" }
    return @{ Bar = $bar; Color = $color }
}
```

### `Modules/pet/_init.ps1`

**Erweiterung der Pet-Datenstruktur:**
- `Pet.Attacks` wird erweitert um Attacken-Details (nicht nur Strings)
- `Pet.StatusEffects` (temporaer, im Kampf)
- `Pet.LimitBreakUnlocked` = $false (wird bei Level 5 freigeschaltet)

### `Modules/engine-ui.ps1`

**Neue Funktion `Show-HPBar`** (falls nicht in `_ui.ps1`): Siehe oben.

## Beispiel-Kampf

### Setup
- Spieler: GLITCH_WOLF (VIRUS), Lv 3, HP 100, ATK 16, DEF 7, SPD 12
- Companion: NEON
- Gegner: FIREWALL_DRAGON (FIRE), HP 100, ATK 14, DEF 10, SPD 9

### Runde 1
```
┌────────────────────────────────────────────┐
│  KAMPF — Runde 1                             │
│  [GLITCH_WOLF]  ██████████ 100/100 HP        │
│  [FIREWALL_DRA] ██████████ 100/100 HP        │
│                                              │
│  [SCAN] FIREWALL_DRAGON: SCHWACH vs ICE(+50%)│
│                         STARK vs FIRE(-25%)  │
│                                              │
│  [1] Attack — Neural Overload (VIRUS, Pwr40) │
│  [2] Defend                                  │
│  [3] Switch                                  │
│  [4] Companion — NEON: Hack (CD: 0)          │
│  [5] Item                                    │
│  [6] Flee — Chance: 57%                      │
│                                              │
│  [F1] Aggressiv [F2] Defensiv [F3] Speed    │
│  [F4] Balanced                              │
└────────────────────────────────────────────┘

> Spieler wählt [1] Attack + [F1] Aggressiv
> NEON: "Vollgas. Sein Firewall ist nur ein Wrapper. Hack es."
> [Enter]
> GLITCH_WOLF geht in Aggressiv-Stance! ATK steigt auf 24!
> [Enter]
> GLITCH_WOLF entlädt einen Neural Overload auf den FIREWALL_DRAGON!
> Der Virus-Code frisst sich durch die Firewall... Treffer! -36 HP!
> [Poison!] Der Virus infiziert die Systeme des Gegners!
> [Enter]
> FIREWALL_DRAGON spuckt einen Feuerball! -8 HP!
> [Enter]
> Kampf-Log:
> R1: GLITCH_WOLF → Neural Overload → FIREWALL_DRAGON: -36 HP [POISON]
> R1: FIREWALL_DRAGON → Feuerball → GLITCH_WOLF: -8 HP
> [Enter]
```

### Runde 2
```
> FIREWALL_DRAGON erleidet POISON! -5 HP! (HP: 59/100)
> Spieler wählt [4] Companion — NEON: Hack
> NEON: "Ich senke seine DEF. Jetzt. Angriff."
> [Enter]
> NEON hackt die Firewall-Routinen des Gegners! DEF -30%!
> [Enter]
> GLITCH_WOLF greift an! Bit Crusher! Treffer! -28 HP!
> [Enter]
> FIREWALL_DRAGON ist besiegt!
> [Enter]
> SIEG! +35 XP | +12 G | Loot: Data Shard
```

## Global Readability Fix

### Aenderung in `Show-CompanionDialog`

**BEFORE:**
```powershell
function Show-CompanionDialog($Companion, $Text, [switch]$Fast) {
    # Typewriter...
    # Nach Typewriter: SOFORT weiter
}
```

**AFTER:**
```powershell
function Show-CompanionDialog($Companion, $Text, [switch]$Fast, [switch]$NoWait) {
    # Typewriter...
    if (-not $NoWait -and -not $Fast) {
        Wait-Enter
    }
}
```

**Migration:** Alle bestehenden Aufrufe von `Show-CompanionDialog` bleiben unveraendert (kein `-Fast` = bekommt automatisch Wait-Enter). Aufrufe mit `-Fast` behalten das schnelle Verhalten (fuer Loops und Flavour-Texte).

## Testing

### Smoke Test
- `Get-CombatInitiative` bestimmt korrekt den Ersten
- `Show-HPBar` rendert korrekte Laengen und Farben
- Status Effects ticken korrekt (Burn, Poison)
- Companion Cooldowns dekrementieren pro Runde
- Limit Break aktiviert sich nur einmal und nur unter 25% HP
- Pet-Switch kostet eine Runde

### Integration Test
- Kampf-Start → Sieg → Save-State behaelt Wins/XP/Gold
- Kampf-Start → Niederlage → Save-State behaelt Losses
- Status Effects werden nicht persistiert (nur im Kampf)
- Companion Cooldowns werden nicht persistiert

### E2E Test
- Ein kompletter Kampf gegen Normal-Gegner mit Mock-Input
- Ein kompletter Boss-Kampf mit Phasen-Wechsel und Mock-Input
- Fluchtversuch-Test
- Limit Break-Test

## Offene Entscheidungen

1. **Soll das Tutorial-Kampf (`Start-PetTutorialFight`) auch umgebaut werden?**
   → **Entscheidung**: Nein. Tutorial bleibt einfach (3 Runden, scripted wins). Das neue System ist fuer echte Kämpfe.

2. **Soll `Show-CompanionDialog` in bestehenden Modulen (Casino, Arcade) auch geaendert werden?**
   → **Entscheidung**: Ja. Der Default-Behavior aendert sich global. Nur explizite `-Fast` Aufrufe bleiben schnell.

3. **Wie viele Pets kann man maximal haben?**
   → **Entscheidung**: Max 6 (wie Pokemon-Team). Breeding erzeugt neue Pets, alte Pets werden ins "Box"-System verschoben.
