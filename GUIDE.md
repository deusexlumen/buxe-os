# BUXE_OS v24.0 -- Der Guide

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

## Architektur v24.3 (Engine-First)

BUXE_OS ist jetzt in **40+ Module** aufgeteilt, organisiert nach dem Prinzip:
**Engine zuerst, dann Games.**

**Core Engines (werden zuerst geladen):**
- `engine-state.ps1` -- Einheitlicher State-Manager. Alle Daten in einer Datei: `%LOCALAPPDATA%\buxe\buxe_state_v24.json`
- `engine-ui.ps1` -- Shared UI: Frames, Progress-Bars, Menus, Animationen, DialogueTree
- `engine-game.ps1` -- Game-Mechanics: Karten, Wuerfel, Element-System, Kampf-Logik
- `engine-aliases.ps1` + 4 Sub-Module -- Terminal-Aliase, Git, System, BUXE-Core-Commands
- `engine-input.ps1` -- Polling-Input-Handler, Mock-Input fuer Tests
- `engine-render.ps1` -- Frame-basiertes Double-Buffering (kein Flicker)
- `engine-scene.ps1` -- Deklarative Scenes (`New-Scene`, `Add-SceneText`, etc.)

**TUI Framework:**
- Spiele rendern in einem virtuellen Framebuffer (`New-Frame`, `Render-Frame`)
- Delta-Rendering: nur geaenderte Zeichen werden neu gezeichnet
- Kein `Clear-Host`-Flackern mehr
- Unicode-Box-Drawing fuer Rahmen und Menues

**Casino Framework:**
- `casino-engine.ps1` -- Shared Casino-Wrapper (Bet-Handling, Bust-Check, Companion-Comments)
- `casino-blackjack.ps1`, `casino-roulette.ps1`, `casino-craps.ps1`, `casino-hilo.ps1`, `casino-baccarat.ps1`, `casino-slot.ps1` -- 6 Spiele (alle TUI)
- `casino.ps1` -- Casino-Hub Router

**Arcade & Strategy:**
- `arcade-snake.ps1`, `arcade-monkeytype.ps1`, `arcade-wordle.ps1`, `arcade-legacy.ps1` (Zork, Hangman) -- 5 Spiele (alle TUI)
- `arcade.ps1` -- Thin Arcade-Hub Router
- `strategy-poker.ps1` -- Texas Hold'em (TUI)
- `strategy-td.ps1` -- Tower Defense (TUI)
- `strategy-rogue.ps1` -- Dungeon Crawler (TUI)

**Pet System v2.0 (`Modules/pet/`):**
- `_init.ps1` -- State, Schema, Meta-Progression, XP/Level-System
- `_ui.ps1` -- Dialog-Engine, LucasArts-Frames, Easter-Egg-Checker
- `_unlock.ps1` -- Progressive Feature-Unlocks
- `companion.ps1` -- Bond, Mood, Talk, Gift, Date, Work, Train, Punish
- `combat.ps1` -- Kampf-Engine (RPS-Logik), Enemy-Gen, Level-Up
- `economy.ps1` -- Shop, Cooking
- `events.ps1` -- "While you were away", Random Events
- `hub.ps1` -- Dynamic Menu, zentraler Entry Point `pet`
- `pvp.ps1` -- Arena mit Rank-System
- `raid.ps1` -- 3-Phasen Dungeon
- `breed.ps1` -- Genetik-Labor
- `rival.ps1` -- Rivale mit Mood-abhaengigem Spawn
- `soul.ps1` -- Soul Link Endgame

**Boot & Fun:**
- `boot.ps1` -- Boot-Sequenz mit Companion-Gruß, Time-Capsel-Check, Random Tips
- `fun.ps1` -- APIs, TTS, Entertainment

**Handbook:**
- `handbook.ps1` + 9 Sub-Module -- In-Game Hilfe (`h` Command)

**Tests:**
- `_smoke_test.ps1` -- 34 Unit-Tests (Engines, State, Spiele)
- `_integration_test.ps1` -- 18 Integration-Tests (Pet System, Module-Load)
- `_e2e_test.ps1` -- End-to-End (Profile-Load + Game-Flows)

**State Migration:**
Beim ersten Start werden alte v23 JSON-Dateien automatisch in das neue unified Format migriert und nach `v23_archive/` verschoben.

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

## Files & Tools

| Command | Funktion |
|---------|----------|
| `ll` | Dateien als Tabelle |
| `la` | Alle Dateien (inkl. hidden) |
| `touch <file>` | Datei erstellen / Timestamp aktualisieren |
| `rmrf <path>` | Rekursiv loeschen |
| `c <file>` | Dateiinhalt anzeigen |
| `which <cmd>` | Pfad eines Commands |
| `grep <pattern> <file>` | Text in Datei suchen |

---

## Git (erweitert)

| Alias | Befehl |
|-------|--------|
| `g` | `git` |
| `gs` | `git status -sb` |
| `ga` | `git add` |
| `gc "msg"` | `git commit -m` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gco` | `git checkout` |
| `gb` | `git branch -v` (oder `-d` zum loeschen) |
| `gd` | `git diff` |
| `glog` | `git log --oneline --graph --decorate -20` |
| `gcm` | `git checkout (current branch)` |

---

## System

| Command | Funktion |
|---------|----------|
| `sysinfo` | OS, PS-Version, User, Uptime, RAM |
| `uptime` | Wie lange laeuft der PC |
| `weather` | Wetter via wttr.in |
| `ip` | Public IP + Location |
| `port <port>` | Testet ob Port offen ist |
| `mem` | RAM-Usage in GB mit % |
| `sudo` | PowerShell als Admin |
| `reload` | Profil neu laden |
| `profile` | Profil in Notepad oeffnen |

---

## BUXE Core Commands

| Command | Funktion |
|---------|----------|
| `status` | Full Dashboard: Bank, Companion, Battlepet, Achievements |
| `bank` | Kontostand, Verdient/Ausgegeben, Casino W/L, Poker |
| `daily` | Taeglicher Bonus (100G + Streak-Bonus) |
| `achievements` | Freigeschaltete Achievements anzeigen + Belohnungen einloesen |
| `ego` | Session-Stats, Bank, Achievements-Count |
| `capsule <text>` | Zeitkapsel erstellen (oeffnet nach 1-14 Tagen) |
| `h` | Alle verfuegbaren Commands auf einen Blick |
| `reset-buxe` | ALLE Fortschritte zurücksetzen (mit Bestätigung + Backup) |

---

## Meta Cheats (LucasArts-Style — Deep Integration)

Jeder Cheat ist **self-aware**, bricht die **vierte Wand** und reagiert auf deinen **Companion-Bond**.

| Command | Funktion | System-Integration |
|---------|----------|-------------------|
| `motherlode` | +50.000 G | 7 Companions × 3 Bond-Level = 21 einzigartige Dialoge. Triggert Pet-Memory. |
| `rosebud` | +1.000 G | 10x hintereinander = motherlode (Running Gag). |
| `konami` | Konami-Code (↑↑↓↓←→←→BA) | **47 Sekunden** Konami-Mode: +50% Casino-Luck, +50% Pet-XP. |
| `iddqd` | Doom-Godmode | 1 Casino-Runde ohne Verluste möglich. Danach abgelaufen. |
| `matrix` | Matrix-Regen / Layer 47 | Meta-Level 14+: Forcierter Layer 47 Trigger. Sonst: Regen. |
| `meta-debug` | Interne State-Diagnose | Easter-Egg-Fortschritt, Konami/IDDQD-Status, Companion-Mood. |
| `noclip` | Durch Wände gehen | Setzt Adventure-NoClip-Flag. Companion kommentiert. |
| `fourthwall` | Meta-Stats | TotalCommands, FavoriteCommand, Casino W/L, Achievements. |
| `useless` | Useless Fact of the Day | LucasArts-Style Absurd-Comedy. |
| `delorean` | Time Travel | Daily-Streak retten (gestern simulieren). 88 Meilen/Stunde. |
| `bsod` | Fake Bluescreen | Prank. Companion bekommt Herzinfarkt. |
| `shiny` | Seltenes Pet | 1% Chance auf Regenbogen-Variante. Pokemon-Referenz. |
| `hunt` | Easter Egg Hunt | Hinweise auf Rubber Chicken, Skull, Tree. |
| `chaos` | Chaos-Modus | Zufälliger Effekt: +/- Geld, Mood, XP, Streak, Kapsel. |
| `summon` | Companion-Summon | Ruft zufälligen Companion mit einzigartigem Dialog. |
| `tpose` | T-Pose Dominance | ASCII-Art T-Pose. Companion reagiert mit Respekt/Angst. |
| `inventory` | Adventure-Items | Zeigt 8 versteckte Items + Fundstatus. Theoretische Items inklusive. |
| `sv_cheats` | Cheat-Übersicht | Liste aller verfügbaren Cheats. |

**LucasArts-Design:**
- Companion-Dialoge ändern sich basierend auf **Bond-Level** (0-30, 30-70, 70-100)
- Jeder Companion hat eine **unverwechselbare Stimme** (NEON=sarkastisch, RAVEN=berechnend, PIXEL=hyperaktiv, LUNA=mystisch, IVY=stillschweigend, VERA=bürokratisch, JINX=chaotisch)
- Cheats werden als **Pet-Memories** gespeichert
- Alle Cheats triggern **Achievements**
- Die Zahl **47** ist überall präsent (Konami-Mode-Dauer, Layer 47)

---

## Casino Suite (6 Spiele, alle TUI)

| Command | Beschreibung |
|---------|-------------|
| `blackjack` | Hit/Stand/Double/Split/Insurance. 3:2 Blackjack-Payout. Dealer hit < 17. |
| `roulette` | Europaeisches Roulette (0-36). Red/Black, Even/Odd, Number, Dozen, Street. |
| `craps` | Pass/Don't Pass Line mit Point-Establishment. |
| `hilo` | Karte raten (hoeher/tiefer). Multiplier steigt 0.5x pro Runde. Cash-out moeglich. |
| `baccarat` | Player/Banker/Tie. 3rd-Card-Regeln automatisch. 5% Commission auf Banker. |
| `slot` | 3-Walzen mit Animation. Jackpot/Match/Pair Payouts. |

Alle Casino-Spiele nutzen das shared `casino-engine.ps1` Framework:
- **TUI-Rendering**: Unicode-Frames, keine Flicker, Delta-Render
- Automatische Bank-Checks (Bust bei 0G -> Reset auf 100G, 1x/Stunde)
- Companion reagiert auf grosse Gewinne/Verluste
- Automatisches Speichern nach jeder Runde
- Casino-Luck-Bonus (Skill-System): Bonus-Gold bei Wins

---

## Arcade (5 Spiele, alle TUI)

| Command | Beschreibung |
|---------|-------------|
| `snake` | Spielbares Snake mit Pfeiltasten. Highscore wird gespeichert. |
| `monkeytype` | WPM Typing-Test. Companion kommentiert bei schlechten Ergebnissen. |
| `wordle` | 5-Buchstaben-Raetsel. 6 Versuche. Farb-Feedback. |
| `zork` | Text-Adventure mit Raeumen, Items, Inventory. |
| `hangman` | Galgenmaennchen mit 3 Schwierigkeitsstufen und Wetten. |
| `minesweeper` | 10x10 Minenfeld. WASD + E/F/Q. Timer + Win/Loss Stats. |

---

## Strategy (3 Spiele, alle TUI)

| Command | Beschreibung |
|---------|-------------|
| `poker` | Texas Hold'em vs 1 AI-Gegner. Hand-Ranking, Betting Rounds, AI mit Random-Style. |
| `td` | Tower Defense. Eintritt 100 G, Sieg gecappt auf 1000 G. |
| `rogue` | Dungeon-Crawler. Eintritt 50 G. Floors, Kampf, Shop, Inventory, Procedural Map. |

---

## Pet System v2.0

Companion + Battlepet in einem unified System. Der `pet` Command ist der zentrale Einstieg.

### Companion

Deine Netrunner-Girl. Lebt im Terminal. Reagiert auf deine Actions.

**7 Girls zur Auswahl:**
- **NEON** (Netrunner, Cyan) - Sarkastisch, cool
- **RAVEN** (Enforcer, Red) - Dominant, hart
- **PIXEL** (Engineer, Magenta) - Schuechtern, sued
- **LUNA** (Medic, Green) - Fuersorglich, mutterlich
- **IVY** (Stealth, DarkGray) - Geheimnisvoll, kalt
- **VERA** (Scientist, Yellow) - Buerokratisch, analytisch
- **JINX** (Jester, Magenta) - Chaotisch, verschwoerungstheoretisch

**Progressive Unlock-System:**
Neue Features werden durch Meta-XP freigeschaltet (nicht sofort verfuegbar):
1. Talk + Companion-Erstellung (sofort)
2. Gift (Meta-Level 1)
3. Combat (Meta-Level 2)
4. Work (Meta-Level 3)
5. Shop + Cooking (Meta-Level 4)
6. PvP Arena (Meta-Level 5)
7. Raid (Meta-Level 6)
8. Breed (Meta-Level 7)
9. Rival (Meta-Level 8)
10. Soul Link (Meta-Level 9)
11. Architect (Meta-Level 10)
12. Awakening (Meta-Level 11)
13. Fourth Wall (Meta-Level 12)
14. Glitch (Meta-Level 13)
15. Layer 47 (Meta-Level 14)

**Commands (via `pet` Hub):**
- `pet talk` -- Chat mit Typewriter-Effekt, +2 Bond
- `pet gift` -- Geschenk, +5 Bond
- `pet date` -- Date, +4 Bond (ab 30 Bond)
- `pet work` -- Sie arbeitet, verdient 20-70 Gold (Netrunner riskant)
- `pet train` -- Training, +3 Bond
- `pet headpat` -- Headpat, +1 Bond
- `pet punish` -- Strafe (wenn sie versagt)
- `pet status` -- Full Status mit Skills, Quests, Cooking, Memories, Rival, Equipment Durability
- `pet sleep` -- Schlaf-Animation
- `pet-transfer <Amount>` -- Pet-Gold -> Main Bank (50% Steuer)
- `pet architect` -- System Terminal (Session-Scan, Diagnose, Override)
- `pet awaken` -- Tiefe Gespraeche mit Companion
- `pet fourthwall` -- Meta-Sicht (Session, Commands, Verzeichnis)
- `pet glitch` -- 1x/Tag Reality-Bug (Gold/XP/Mood/Luck/Memory)

**Mood-System:**
Dynamisch basierend auf Uhrzeit, Bond, Verlusten.
- Sleepy (22:00 - 06:00)
- Disappointed (bei 3+ Verlusten)
- Excited (ab 80 Bond)
- Cold (unter 20 Bond)
- Happy (Default)

**Easter Eggs:**
- Chance-basierte Kommentare (Coffee, No-Life, Midnight Snack, Workaholic, etc.)
- Meta-Kommentare im Hub-Menue (Companion reagiert auf Menuewahl)
- Spezielle Dialoge bei 3am-Login, 42x pet-Aufruf, etc.

**Skill Trees:**
Ab Meta-Level 2 erhaeltst du bei jedem Level-Up einen Skill-Punkt. Investiere ihn in:
- **Combat**: mehr Schaden, mehr Crit, Ultimate Rage
- **Economy**: mehr Gold, Rabatt im Shop, Ultimate Midas
- **Social**: schnellerer Bond, bessere Geschenke, Ultimate Charm

Befehl: `pet` -> `[I] Skill Tree`

**Companion Story Episodes:**
Jede der 7 Companions hat eine Episode 1 Story, die du im Hub unter `[S] Story` erleben kannst (ab Meta-Level 3). Deine Entscheidungen beeinflussen den Bond.

**Adaptive Tutorial:**
Das Pet-Tutorial merkt sich, welche Schritte du bereits gemacht hast (Companion erstellen, Talk, Gift, erster Kampf, erster Shop-Besuch, erster Skill-Punkt) und wiederholt sie nicht.

**Cooking:**
Sie kann Buff-Food kochen: Ramen, Energy Drink, Sushi Platter.
Cooking-Buffs geben temporaere Casino-Luck oder Combat-Boosts.

### Battlepet

Dein Monster, das du leveln und mit dem du kaempfen kannst.

**Starter (5 zur Auswahl):**
- `GLITCH_WOLF` (Virus) -> evolviert zu `CORRUPT_HOUND`
- `CYBER_RAPTOR` (Elec) -> evolviert zu `THUNDER_REX`
- `VOID_TURTLE` (Dark) -> evolviert zu `ABYSS_TORTOISE`
- `FLAME_FOX` (Fire) -> evolviert zu `INFERNO_VULPES`
- `FROST_BUNNY` (Ice) -> evolviert zu `BLIZZARD_HARE`

**Commands (via `pet` Hub):**
- `pet fight` -- Zufaelliger Gegner oder Boss (Eintrittsgebuehr: 5 + Level*2 G)
- `pet pvp` -- Shadow Arena (Ranked: Bronze -> Master)
- `pet raid` -- Taeglicher 3-Phasen-Raid-Boss
- `pet breed` -- Genetik-Labor (Companion Bond 50+, 50 Gold)
- `pet shop` -- Potions, Stat-Boosts, Equipment (Preise skalieren mit Pet-Level)
- `pet rival` -- Rivale mit Mood-abhaengigem Spawn
- `pet soul` -- Soul Link Endgame (ab Meta-Level 9)

**Equipment Durability:**
Jedes ausgeruestete Item hat 10 Kaempfe Haltbarkeit. Nach 10 Kaempfen zerfaellt es automatisch und muss neu gekauft werden.

**Element-System:**
Fire > Ice > Elec > Water > Fire (1.5x Schaden)
Virus, Dark, Norm, Hack sind neutral/spezial

**Status-Effekte:**
BURN, POISON, STUN, REGEN, BUFF

**Titel-System (basierend auf Wins):**
Rookie (0) -> Veteran (5) -> Elite (15) -> Master (30) -> Legend (50) -> Net God (100)

**Skills (aktiviert durch Meta-Progression):**
- `CombatBoost`: +2G pro Win pro Level
- `CasinoLuck`: Bonus-Gold bei Casino-Wins, levelbar via `pet work`
- `StrategyInsight`: Bonus-XP bei Poker/TD/Rogue-Wins, levelbar via `pet train`

---

## Fun

| Command | Funktion |
|---------|----------|
| `say <text>` | Text vorlesen (System.Speech) |
| `voice <n>` | Stimme wechseln |
| `voices` | Verfuegbare Stimmen |
| `clip-say` | Zwischenablage vorlesen |
| `chuck` | Chuck Norris Fact |
| `dadjoke` | Vater-Witz |
| `zen` | Programmierer-Zen |
| `kanye` | Kanye West Zitat |
| `btc` | Bitcoin-Kurs |
| `bored` | Aktivitaetsvorschlag |
| `pomodoro` | 25-Minuten-Timer |
| `roast` | Die KI roasted dich |
| `sudo-insult` | Klassische sudo-Beleidigung |
| `parrot` | ASCII-Papagei |
| `genact` | Hollywood-Hacking-Simulation |
| `rig` | Fake-Identitaet |
| `bs` | Corporate Bullshit Generator |
| `uwu <text>` | UWU-Sprache |
| `sneakers` | "No More Secrets" Effekt |

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
| `ip` | Public IP + Location |
| `chuck` | Chuck Norris Fact |
| `btc` | Bitcoin-Kurs |
| `bored` | Aktivitaetsvorschlag |
| `kanye` | Kanye West Zitat |
| `dadjoke` | Vater-Witz |
| `zen` | Programmierer-Zen |

---

## Self-Aware Boot & Achievements

Das Profil ist selbstbewusst. Es trackt:
- `Loads` -- wie oft du gebootet hast
- `TotalCommands` -- wie viele Befehle du insgesamt ausgefuehrt hast
- `DailyStreak` -- wie viele Tage in Folge Daily-Bonus geholt
- `TimeCapsules` -- gespeicherte Zeitkapseln

**Meilensteine:**
- Ab 10 Sessions: Kommentar
- Ab 50 Sessions: "Regular"
- Ab 100 Sessions: "Addicted"
- Spaete Nacht (ab 3 Uhr): Kommentar zur Schlafenszeit
- Unpushed Git Commits: "You have unpushed commits. Stop procrastinating."

**Boot Tips:**
Bei jedem Login wird ein zufaelliger Tipp angezeigt:
- `daily` fuer taeglichen Bonus
- `pet status` fuer Companion + Battlepet
- `bank` fuer Finanzhistorie
- Jede 5. Runde im Kampf ist ein Boss
- `h` listet ALLE Commands
- Und mehr...

**Achievements:**
Freischaltbar durch Events:
- "Pet Evolution" (Battlepet Lv.10)
- "Week Streak" (7 Tage Daily)
- "Month Streak" (30 Tage Daily)
- "HiLo Legend" (5x richtig bei Hi-Lo)
- "Jackpot" (Slot Machine Jackpot)
- "Blackjack Pro" (Blackjack mit 21)
- Und mehr...

---

## Troubleshooting

**Profil laedt nicht?**
1. `profile` tippen -> Datei in VS Code oeffnen
2. Fehler suchen (meist fehlende Klammer oder Anfuehrungszeichen)
3. Speichern -> `reload`

**Oh My Posh zeigt komische Zeichen?**
- CaskaydiaCove Nerd Font nicht installiert oder nicht in Windows Terminal ausgewaehlt.

**Module nicht gefunden?**
- Alle Module muessen in `Documents\PowerShell\Modules` liegen.
- Oh My Posh muss ueber winget installiert sein.

**State File korrupt?**
- `engine-state.ps1` erkennt korrupte JSON automatisch.
- Backup wird erstellt: `buxe_state_v24.json.corrupt.<timestamp>`
- Frischer Start mit Defaults wird initiiert.

**Audit-Log:**
Jede Gold-Transaktion wird in `buxe_audit.log` protokolliert:
- Format: `Timestamp | Action | Amount | Balance`
- Actions: `EARN`, `SPEND`, `BANKROLL`

**State-Transaktionen:**
- `Start-StateTransaction` -- Backup erstellen
- `Complete-StateTransaction` -- Speichern (bei Depth=0)
- `Rollback-StateTransaction` -- Backup wiederherstellen
- Atomare Saves: `.tmp` -> `Move-Item`

**Unicode/Encoding:**
- Die meisten Module verwenden **reines ASCII** (keine Umlaute, keine Emojis).
- `pet/*.ps1` Dateien verwenden **UTF-8 BOM** fuer Unicode-Box-Drawing-Zeichen.
- Alle anderen Dateien sind UTF-8 ohne BOM.

---

## Datei-Struktur

| Pfad | Beschreibung |
|------|-------------|
| `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | Hauptprofil (Entry Point) |
| `%USERPROFILE%\Documents\PowerShell\Modules\` | Alle 18 Module |
| `%USERPROFILE%\Documents\PowerShell\buxe.omp.json` | Oh My Posh Theme |
| `%LOCALAPPDATA%\buxe\buxe_state_v24.json` | Unified State File |
| `%LOCALAPPDATA%\buxe\v23_archive\` | Alte v23 Dateien (nach Migration) |

**Module (40+ total):**
```
# Core Engines
engine-state.ps1, engine-ui.ps1, engine-game.ps1, engine-aliases.ps1
engine-aliases-buxe.ps1, engine-aliases-git.ps1, engine-aliases-nav.ps1, engine-aliases-sys.ps1
engine-input.ps1, engine-render.ps1, engine-scene.ps1

# Casino
casino-engine.ps1, casino-blackjack.ps1, casino-roulette.ps1, casino-craps.ps1,
casino-hilo.ps1, casino-baccarat.ps1, casino-slot.ps1, casino.ps1

# Arcade
arcade.ps1, arcade-snake.ps1, arcade-monkeytype.ps1, arcade-wordle.ps1, arcade-legacy.ps1

# Strategy
strategy-poker.ps1, strategy-td.ps1, strategy-rogue.ps1

# Pet System (Modules/pet/)
_init.ps1, _ui.ps1, _unlock.ps1, companion.ps1, combat.ps1, economy.ps1,
events.ps1, hub.ps1, pvp.ps1, raid.ps1, breed.ps1, rival.ps1, soul.ps1

# Boot, Fun, Handbook, Tests
boot.ps1, fun.ps1
handbook.ps1, handbook-casino.ps1, handbook-combat.ps1, handbook-commands.ps1,
handbook-companion.ps1, handbook-core.ps1, handbook-elements.ps1,
handbook-equipment.ps1, handbook-skills.ps1, handbook-status.ps1
_smoke_test.ps1, _integration_test.ps1, _e2e_test.ps1
```

**Smoke Test:**
```powershell
. "$env:USERPROFILE\Documents\PowerShell\Modules\_smoke_test.ps1"
```
Testet alle Engines, State, Companion, Battlepet, Module-Loading.

---

*Profil-Pfad:* `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

*Theme-Pfad:* `%USERPROFILE%\Documents\PowerShell\buxe.omp.json`

*Modul-Pfad:* `%USERPROFILE%\Documents\PowerShell\Modules\`

*State-Pfad:* `%LOCALAPPDATA%\buxe\buxe_state_v24.json`

*Profil-Groesse:* ~20 Zeilen Hauptprofil + 18 Module (~3500+ Zeilen total), 80+ Commands, PS7/PS5.1-kompatibel.
