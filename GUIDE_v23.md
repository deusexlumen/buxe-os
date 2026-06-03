# BUXE_OS v21.6 - Der Guide

> Kurz & knackig. Wenn etwas unklar ist: `profile` tippen -> Datei editieren -> `reload`.

---

## Schriftart (WICHTIG!)

Oh My Posh zeigt Icons an, die normale Fonts nicht haben. Du brauchst einen **Nerd Font**.

**Empfehlung:** **CaskaydiaCove Nerd Font** (Cascadia Code + Icons)
- Super lesbar, perfekt fuer Windows Terminal
- Klare Unterscheidung: `0` vs `O`, `1` vs `l` vs `I`
- Ligaturen: `=>`, `!=`, `>=` sehen fancy aus

**Download:** [nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads) -> such nach **CaskaydiaCove**.

**Einrichten:**
1. Font installieren (Rechtsklick -> Fuer alle Benutzer installieren).
2. Windows Terminal oeffnen -> `Strg + ,` -> Links dein PS7-Profil waehlen ->
   **Darstellung** -> **Schriftart** -> `CaskaydiaCove Nerd Font` auswaehlen.
3. Terminal neu starten.

---

## Das Prompt

Dein Prompt zeigt (von links nach rechts):
- OS-Icon + Username
- Aktueller Pfad (mit `~` statt `%USERPROFILE%`)
- Git-Branch + `*` wenn uncommitted changes
- Ausfuehrungszeit des letzten Commands
- Status: Haken oder X
- Rechts: Uhrzeit

---

## Navigation

| Command | Was passiert |
|---------|-------------|
| `..` | Ein Ordner hoch |
| `...` | Zwei Ordner hoch |
| `....` | Drei Ordner hoch |
| `tmp` | Zu `%TEMP%` springen |
| `dl` | Zu Downloads springen |
| `docs` | Zu Documents springen |
| `mkcd <name>` | Ordner erstellen UND reingehen |

---

## Git

| Alias | Befehl |
|-------|--------|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc "msg"` | `git commit -m` |
| `gp` | `git push` |
| `gl` | `git log --oneline -10` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `gd` | `git diff` |
| `glog` | `git log --graph --oneline --decorate -15` |
| `yolo` | add all + commit + push |

---

## System

| Command | Funktion |
|---------|----------|
| `sysinfo` | OS, PS-Version, User, Uptime |
| `uptime` | Wie lange laeuft der PC |
| `weather` | Wetter via wttr.in |
| `ip` | Public IP |
| `port <host> <port>` | Testet ob Port offen ist |
| `mem` | RAM-Usage |
| `sudo` | PowerShell als Admin |
| `reload` | Profil neu laden |
| `profile` | Profil in VS Code oeffnen |

---

## Fun

| Command | Funktion |
|---------|----------|
| `quote` | Zufaelliger Coder-Quote |
| `coin` | Muenzwurf |
| `dice` | Wuerfel (1-6) |
| `cowsay <text>` | ASCII-Kuh spricht |
| `rainbow <text>` | Regenbogen-Text |

---

## FX

| Command | Beschreibung |
|---------|-------------|
| `matrix` | Matrix-Digital-Regen |
| `fire` | Doom-Fire-Effekt |
| `decrypt <text>` | Sneakers-Style Entschluesselung |
| `big <text>` | Grosse ASCII-Buchstaben |
| `sl` | Steam Locomotive ASCII-Art (mit bounds-check) |

---

## Deep Cuts (Die obskuren Features)

| Command | Beschreibung |
|---------|-------------|
| `genact` | Hollywood-Hacking-Simulation. Faked Compiling, Mining, etc. |
| `parrot` | ASCII-Papagei fliegt in Regenbogenfarben durchs Terminal |
| `sneakers` | "No More Secrets" Entschluesselungseffekt aus dem Film |
| `uwu <text>` | Text in UWU-Sprache umwandeln |
| `rig` | Fake-Identitaet generieren (Name, Adresse, Telefon) |
| `bs` | Corporate Bullshit Generator |

---

## Games

| Command | Beschreibung |
|---------|-------------|
| `tetris` | Vollwertiges Tetris. 7 Tetrominoes, Rotation, Line-Clear, Next-Preview, Score |
| `snake` | Spielbares Snake mit Pfeiltasten |
| `battlepet` | RPG-Monster-Kampf-System (siehe eigene Sektion) |

---

## Casino Suite

| Command | Beschreibung |
|---------|-------------|
| `blackjack` | Vollwertiges Blackjack mit Split, Double Down, Insurance, Multi-Hand, Soft 17 |
| `roulette` | Europaeisches Roulette (37 Zahlen). Alle Wetttypen, Spin-History |
| `slot` | Einarmiger Bandit mit 3 Walzen |
| `hangman` | Galgenmaennchen mit 7 ASCII-Stufen |

---

## Strategy

| Command | Beschreibung |
|---------|-------------|
| `poker` | Texas Hold'em gegen AI-Gegner. Hand-Ranking, Bluff, All-In, Showdown |
| `td` | ASCII Tower Defense. 20x12 Grid, 4 Turm-Typen, Pathfinding, Wellen |
| `rogue` | Procedural Dungeon-Crawler. 8-15 Raeume pro Floor, FOG (Radius 5), Loot, Bosse alle 3 Floors |

---

## Music (Console.Beep)

| Command | Beschreibung |
|---------|-------------|
| `piano` | Interaktives Terminal-Piano |
| `tetris-music` | Korobeiniki (Tetris Theme A) |
| `mario` | Super Mario Bros. Theme |
| `starwars` | Imperial March |
| `impossible` | Mission Impossible Theme |

---

## TTS (Text-to-Speech)

| Command | Funktion |
|---------|----------|
| `say <text>` | Text vorlesen |
| `voice <n>` | Stimme wechseln (1-3) |
| `voices` | Verfuegbare Stimmen anzeigen |
| `clip-say` | Zwischenablage vorlesen |

---

## APIs

| Command | Funktion |
|---------|----------|
| `weather` | Wetter via wttr.in |
| `ip` | Public IP |
| `chuck` | Chuck Norris Fact |
| `cat` | Zufaelliges Katzenbild (ASCII) |
| `dog` | Zufaelliges Hundebild (ASCII) |
| `btc` | Bitcoin-Kurs |
| `bored` | Aktivitaetsvorschlag gegen Langeweile |
| `kanye` | Kanye West Zitat |
| `dadjoke` | Vater-Witz |
| `zen` | Programmierer-Zen |

---

## BATTLEPET v3.0

Dein Monster, das du leveln und mit dem du kaempfen kannst.

**Starter (5 zur Auswahl):**
- `GLITCH_WOLF` (Virus) -> evolviert zu `CORRUPT_HOUND`
- `CYBER_RAPTOR` (Elec) -> evolviert zu `THUNDER_REX`
- `VOID_TURTLE` (Dark) -> evolviert zu `ABYSS_TORTOISE`
- `FLAME_FOX` (Fire) -> evolviert zu `INFERNO_VULPES`
- `FROST_BUNNY` (Ice) -> evolviert zu `BLIZZARD_HARE`

**Commands:**
- `battlepet` -> Hauptmenue
- `[1] Fight` -> Zufaelliger Gegner oder Boss (in gewaehlter Arena)
- `[2] Rest` -> HP auffuellen
- `[3] Status` -> Stats + Titel + Equipment + Elemente + Status-Effekte
- `[4] Shop` -> Potions, Stat-Boosts, Revive Tokens, Equipment (mit Bank-Gold)
- `[5] Rename` -> Eigenen Namen vergeben (Companion reagiert)
- `[6] Equipment` -> Equip/Dequip Items aus dem Inventar
- `[7] Arena` -> Arena wechseln (freigeschaltete)
- `[8] Breed` -> Pet Breeding (Companion Bond 50+, 50 Gold, 24h Cooldown)
- `[9] PvP` -> Shadow Arena (Ranked: Bronze -> Master)
- `[10] Raid` -> Taeglicher 3-Phasen-Raid-Boss (Raid-Tokens als Belohnung)
- `[11] Tournament` -> Woechentliches Turnier mit Spezialregeln
- `[12] Switch Pet` -> Zwischen mehreren Pets wechseln
- `[13] Adventure` -> Pet auf zeitbegrenzte Quest schicken
- `[14] Reset` -> Neues Pet

**Multi-Pet System:**
Du kannst jetzt mehrere Pets besitzen! Neue Pets durch Breeding oder als Starter.
`switchpet` wechselt das aktive Pet.

**Pet Breeding:**
- Kaufe einen Partner im Breeding Lab (100 Gold)
- Brute dein aktives Pet mit dem Partner (50 Gold, 24h Cooldown)
- Baby bekommt gemischte Stats (+/- 10% Mutation), erbt Attacken, 10% Chance fuer HYBRID-Type
- Baby startet als Level 1 mit hoeheren Base-Stats

**PvP Shadow Arena:**
- Basiert auf deinem aktuellen Rank (Bronze/Silver/Gold/Platinum/Diamond/Master)
- Schnelle Kaempfe (max 5 Runden)
- Siege geben PvP-Punkte, Niederlagen ziehen ab
- Belohnung: Gold pro Sieg

**Raids:**
- Taeglich 1 Raid-Boss (THE APOCALYPSE, THE OVERSEER, THE ENDLESS)
- 3 Phasen: Boss wird staerker bei jedem Phasenwechsel
- Companion-Buff bei Bond 30+ essentiell
- Belohnung: Raid-Tokens fuer exklusives Equipment (Legendary Chip, Aegis Plate, Flash Collar)

**Weekly Tournament:**
- 7 AI-Gegner, Single-Elimination
- Jede Woche neue Spezialregel (No Equipment, Fire Only, No Potions, Speed Doubled, etc.)
- Platzierung 1-8 mit Gold-Belohnungen
- Reset jeden Montag

**Pet Personality:**
Jedes Pet hat eine von 5 Persoenlichkeiten (zufaellig bei Erstellung):
- Aggressive: +10% ATK, -5% DEF
- Defensive: -5% ATK, +10% DEF
- Balanced: +5% Crit
- Trickster: +10% SPD, +10% Status-Chance
- Berserker: +20% ATK unter 50% HP, -10% DEF

**Pet Skill Tree:**
8 passive Skills, die automatisch gelernt werden:
- Regeneration: Heilt 1% MaxHP pro Runde
- Critical Master: +15% Crit
- Elemental Shield: 50% Chance Status zu resistieren
- Life Steal: Heilt 10% des Schadens
- Iron Will: +20% DEF unter 30% HP
- Speed Demon: +20% SPD ueber 70% HP
- Poison Touch: 20% Chance Poison bei Treffer
- Overclock: +10% ATK, aber 5% Recoil-Schaden

Skills werden freigeschaltet durch:
- Level-Up: 25% Chance (max 1 Skill alle 5 Level)
- Boss-Sieg: 50% Chance
- Max 4 Skills pro Pet

**Infinity Tower:**
- Endlos-Modus: Stockwerk 1, 2, 3... ohne Limit
- Jede 5. Etage: Boss mit +20% Stats
- Stats skalieren mit +10% pro Stockwerk
- Cash Out jederzeit moeglich (Belohnungen mitnehmen)
- Best Floor wird gespeichert

**Pet Fusion:**
- Waehle 2 Pets, verschmelze sie zu einem FUSED-Pet
- Kosten: 200 Gold
- Ergebnis: Durchschnitts-Level + 2, Stats +10%, bis zu 4 Skills + 6 Attacken
- Max Level 50 fuer Fused Pets
- Die beiden alten Pets werden verbraucht!

**Pet Bestiary:**
- Trackt automatisch alle gesehenen Gegner und Bosse
- Anzeige mit Completion-Prozent
- ??? fuer noch nicht gesehene Kreaturen

**Daily Challenges:**
- 3 zufaellige Quests jeden Tag (Reset um Mitternacht)
- Beispiele: "Gewinne 3 Kaempfe", "Besiege 1 Boss", "Spende 50 Gold", "Erreiche Tower-Etage 5"
- Belohnungen: Gold + XP
- `[C] Claim` im Challenge-Menue

**Pet Adventures:**
Sende dein Pet auf zeitbegrenzte Quests:
- Short (30 min): 10-20 Gold, 5-15 XP
- Medium (2h): 25-50 Gold, 15-40 XP + Item-Chance
- Long (4h): 50-100 Gold, 40-80 XP + Partner-Chance
- Epic (8h): 100-200 Gold, 80-150 XP + Legendary-Chance

**Companion Combat v2:**
Dein Companion greift jetzt DIREKT im Kampf an!
- Ab Bond 30: Alle 3 Runden
- Ab Bond 50: Alle 2 Runden
- Ab Bond 70: Jede Runde
- 3 Companion-Attacken: Net Slash, Data Beam, System Shock

**Battlepet Achievements:**
- First Blood, Boss Slayer, Arena Master
- Breeder, PvP Legend, Raid Hero
- Skill Master, Tournament Champion
- Adventurer, Net God

**Arenas:**
- `Cyber-Wastes` (Start) - Gegner: Spam Bot, Trojan Horse, Phishing Worm. Boss: THE PLAGUE
- `Neon-District` (ab 1 Boss-Sieg) - Gegner: Glitch Rat, Firewall Demon, Holo Snake. Boss: THE STORM
- `Void-Deeps` (ab 2 Boss-Siege) - Gegner: Shadow Crawler, Null Pointer, Data Wraith. Boss: THE VOID

**Wetter:** Jeder Kampf hat zufaelliges Wetter:
- Clear (nichts)
- Acid Rain (Wasser +20%, Feuer -20%, Poison-DOT)
- Thunderstorm (Elec +20%, Ice -20%, Stun-Chance +10%)
- Void Fog (Dark +20%, Norm -20%)

**Equipment (Shop):**
- Chip: Neural Chip Mk.1/2 (ATK+, Crit%)
- Armor: Plasma Armor/Quantum Plate (DEF+, Immunity/Regen)
- Accessory: Speed Collar/Lucky Charm (SPD+, Loot+)

**Titel-System (basierend auf Wins):**
Rookie -> Veteran (5) -> Elite (15) -> Master (30) -> Legend (50) -> Net God (100)

**Element-System:**
Fire > Ice > Elec > Water > Fire (1.5x Schaden)
Virus, Dark, Norm sind neutral (1.0x)

**Status-Effekte:**
- BURN: 8% MaxHP Schaden pro Runde
- POISON: 6% MaxHP Schaden pro Runde
- STUN: Zug wird uebersprungen
- REGEN: 8% MaxHP Heilung pro Runde
- BUFF: 1.3x Heilung

**Mechaniken:**
- 8 Basis-Angriffe mit Element-Typ und Status-Chance
- Boss-Kaempfe alle 5 Siege (THE PLAGUE, THE STORM, THE VOID, THE INFERNO, THE FROST)
- Evolution bei Lv.10 (Name aendert sich, Stats +20/+5/+3/+3)
- Potions (+50% HP im Kampf)
- Crit-Chance: 10% fuer 1.5x Schaden
- Initiative basiert auf SPD-Stat
- Level-Up gibt neue Attacken (ab Lv 2, 3, 4, 5, 6, 7, 8, 9, 10, 12)
- Companion-Synergy: +ATK/+DEF/+HP basierend auf Bond
- Companion-Assist: Cheer/Heal/Distract/Analyze im Kampf
- Tandem-Attacke ab Bond 50
- Persistenz in `$env:TEMP\buxe_battlepet.json`

---

## COMPANION v4.0 (Ecchi Edition)

Deine Netrunner-Girl. Lebt im Terminal. Reagiert auf deine Actions.

**5 Girls zur Auswahl:**
- **NEON** (Netrunner, Cyan) - Sarkastisch, cool
- **RAVEN** (Enforcer, Red) - Dominant, hart
- **PIXEL** (Engineer, Magenta) - Schuechtern, sued
- **LUNA** (Medic, Green) - Fuersorglich, mutterlich
- **IVY** (Stealth, DarkGray) - Geheimnisvoll, kalt

**Relationship Levels:**
Stranger (0-14) -> Acquaintance (15-29) -> Friend (30-49) -> Close Friend (50-69) -> Partner (70-89) -> Soulmate (90-99) -> Spouse (100)

**Commands (auch als Standalone-Shortcuts nutzbar):**
- `companion` -> Status + ASCII-Art + Mood + Sync-Level + Married-Status
- `talk` -> Chat, +2 Bond (mit Tageszeit-Dialogen)
- `gift` -> Geschenk, +5 Bond (ab Bond 50 gibt sie manchmal etwas zurueck). Gift-History wird getrackt.
- `train` -> Training (+3 Bond, +1 Pet ATK) ODER Auto-Train Pet (15 Gold, +XP)
- `story` -> Geschichte, +2 Bond
- `pet` -> Headpat... oder mehr, +1 Bond. **Jealousy:** Wenn Pet viel staerker ist als Sync-Wins, wird sie eifersuechtig.
- `date` -> Date, +4 Bond (ab 30 Bond). **Dating Milestones:** 1/3/5/10 Dates mit besonderen Texten.
- `work` -> Sie arbeitet taeglich, verdient 10-40 Gold + Bond-Bonus
- `outfit` -> 4 Outfits pro Charakter wechseln
- `punish` -> Sie disst dich
- `confess` -> True Love Ending (ab 100 Bond)
- `marry` -> Heirat! (ab 100 Bond). +50% Gold aus Battlepet-Siegen. Sie zeigt Eheringe an.

**Mood-System:**
Der Companion hat einen Mood, der sich dynamisch aendert:
- Sleepy (22:00 - 06:00 Uhr)
- Disappointed (bei 3+ Verlusten in Folge)
- Excited (ab 80 Bond)
- Cold (unter 20 Bond)
- Happy (Default)

**Demuetigungs-System:**
Wenn du in Battlepet verlierst:
- Ab 2. Verlust in Folge: Bond sinkt, sie wird gemein
- Ab 3. Verlusten: "Losing Streak" mit extra brutalen Spruechen
- **Browser-History-Integration:** Ab 2 Verlusten liest sie deine Chrome/Edge/Firefox-History und demuetigt dich mit **konkreten Websites**, die du besucht hast. Die History wird einmal pro Tag gecached.

**Daily Login Bonus:** Jeden Tag, wenn du `companion` aufrufst, gibt es +3-7 Bonus-Bond.

---

## Original Creations

| Command | Beschreibung |
|---------|-------------|
| `capsule <text>` | Zeitkapsel erstellen. Oeffnet sich nach 1-14 Tagen automatisch. |
| `paranoid` | Paranoid Mode: Fake-Sicherheitswarnungen alle 30-120 Sekunden. `-Off` zum Stoppen. |
| `idle` | Wenn du nichts tippst, erscheint zufaellig ein kommentar am Bildschirm. |
| `oracle <frage>` | Das Orakel gibt Rat basierend auf Git-Commits, Wochentag und Mondphase. |

---

## Creative v21.2

| Command | Beschreibung |
|---------|-------------|
| `monkeytype` | Typing-Test. WPM, Accuracy. Companion kommentiert bei schlechten Ergebnissen. |
| `dvd` | DVD-Screensaver-Bouncing-Logo |
| `life` | Conways Game of Life |
| `bios` | Fake-BIOS-Boot-Screen |
| `zork` | Text-Adventure mit ASCII-Art |
| `roastme` | Die KI roasted dich basierend auf deinem Git-Status und Uhrzeit |
| `flip` | Muenze drehen mit Animation |
| `vibe` | ASCII-Vibe-Check mit Farben |

---

## Self-Aware Boot & Achievements

Das Profil ist selbstbewusst. Es trackt:
- `SessionCount` - wie oft du gebootet hast
- `TotalCommands` - wie viele Befehle du insgesamt ausgefuehrt hast
- `FavoriteCommand` - dein meistgenutzter Befehl
- `TimeCapsules` - gespeicherte Zeitkapseln

**Meilensteine:**
- Ab 10 Sessions: "Returning User"
- Ab 50 Sessions: "Regular"
- Ab 100 Sessions: "Addicted"
- Spaete Nacht (ab 3 Uhr): Kommentar zur Schlafenszeit
- Unpushed Git Commits: "You have unpushed commits. Stop procrastinating."

**Achievements:**
Es gibt 10 freischaltbare Achievements, die automatisch bei bestimmten Ereignissen freigeschaltet werden.
Bisher bekannte: "Pet Evolution" (wenn dein Battlepet sich bei Lv.10 entwickelt).

---

## Troubleshooting

**Profil laedt nicht?**
1. `profile` tippen -> Datei in VS Code oeffnen
2. Fehler suchen (meist fehlende Klammer oder Anfuehrungszeichen)
3. Speichern -> `reload`

**Oh My Posh zeigt komische Zeichen?**
- CaskaydiaCove Nerd Font nicht installiert oder nicht in Windows Terminal ausgewaehlt.

**Module nicht gefunden?**
- Terminal-Icons und PSFzf muessen in `Documents\PowerShell\Modules` liegen.
- Oh My Posh muss ueber winget installiert sein.

**Browser-History wird nicht gelesen?**
- Chrome/Edge/Firefox muessen installiert sein.
- Wenn der Browser laeuft, wird eine Kopie der DB gemacht (funktioniert trotzdem).
- Erster Scan kann 5-10 Sekunden dauern.

---

*Profil-Pfad:* `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

*Theme-Pfad:* `%USERPROFILE%\Documents\PowerShell\buxe.omp.json`

*Modul-Pfad:* `%USERPROFILE%\Documents\PowerShell\modules\`

*Profil-Groesse:* ~60 Zeilen Hauptprofil + 7 Module (~2370 Zeilen total), 55+ Commands, PS5.1-kompatibel.

**Modularisierung (v21.2+):**
Das Profil ist in Module aufgeteilt:
- `modules/core.ps1` - Navigation, Git, System, Fun, FX, Deep Cuts, Music, TTS, APIs, Original Creations, Help
- `modules/games.ps1` - Tetris, Snake, Battlepet
- `modules/companion.ps1` - Companion System
- `modules/bonus.ps1` - Hackertyper, Pomodoro, Starfield, Flip, Vibe, Roast, Clock, Dungeon, Doom, Wordle, Sudo-Insult
- `modules/creative.ps1` - Monkeytype, DVD, Life, BIOS, Zork, Roastme
- `modules/casino.ps1` - Blackjack, Roulette, Slot, Hangman
- `modules/strategy.ps1` - Poker, Tower Defense, Rogue-Like

**Troubleshooting Modularisierung:**
- Wenn ein Modul fehlerhaft ist, wird das gesamte Profil trotzdem geladen (try/catch um alle Module).
- Einzelne Module koennen mit `. $PROFILE\..\modules\<name>.ps1` manuell neu geladen werden.
- Fuege neue Module einfach im Hauptprofil unter `# === LOAD MODULES ===` hinzu.


