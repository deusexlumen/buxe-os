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

## Architektur v24.0 (Engine-First)

BUXE_OS ist jetzt in **18 Module** aufgeteilt, organisiert nach dem Prinzip:
**Engine zuerst, dann Games.**

**Core Engines (werden zuerst geladen):**
- `engine-state.ps1` -- Einheitlicher State-Manager. Alle Daten in einer Datei: `%LOCALAPPDATA%\buxe\buxe_state_v24.json`
- `engine-ui.ps1` -- Shared UI: Frames, Progress-Bars, Menus, Animationen
- `engine-game.ps1` -- Game-Mechanics: Karten, Wuerfel, Element-System, Kampf-Logik
- `engine-aliases.ps1` -- Terminal-Aliase, Git, System, BUXE-Core-Commands

**Casino Framework:**
- `casino-engine.ps1` -- Shared Casino-Wrapper (Bet-Handling, Bust-Check, Companion-Comments)
- `casino-blackjack.ps1`, `casino-roulette.ps1`, `casino-craps.ps1`, `casino-hilo.ps1`, `casino-baccarat.ps1`, `casino-slot.ps1` -- 6 Spiele
- `casino.ps1` -- Casino-Hub Router

**Arcade & Strategy:**
- `arcade.ps1` -- Snake, Monkeytype, Wordle, Zork, Hangman
- `strategy-poker.ps1` -- Texas Hold'em
- `strategy-td.ps1` -- Tower Defense
- `strategy-rogue.ps1` -- Dungeon Crawler

**Companion & Battlepet:**
- `companion.ps1` -- Companion v6 (dekompliziert)
- `battlepet.ps1` -- Battlepet v24 (Full RPG)
- `hub.ps1` -- Unified `pet` Command Router

**Boot & Fun:**
- `boot.ps1` -- Boot-Sequenz mit ASCII-Art
- `fun.ps1` -- APIs, TTS, Entertainment
- `ralph-loop.ps1` -- Kimi CLI Wrapper

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
| `achievements` | Freigeschaltete Achievements anzeigen |
| `ego` | Session-Stats, Bank, Achievements-Count |
| `capsule <text>` | Zeitkapsel erstellen (oeffnet nach 1-14 Tagen) |
| `h` | Alle verfuegbaren Commands auf einen Blick |

---

## Casino Suite (6 Spiele)

| Command | Beschreibung |
|---------|-------------|
| `blackjack` | Hit/Stand/Double/Split/Insurance. 3:2 Blackjack-Payout. Dealer hit < 17. |
| `roulette` | Europaeisches Roulette (0-36). Red/Black, Even/Odd, Number, Dozen, Street. |
| `craps` | Pass/Don't Pass Line mit Point-Establishment. |
| `hilo` | Karte raten (hoeher/tiefer). Multiplier steigt 0.5x pro Runde. Cash-out moeglich. |
| `baccarat` | Player/Banker/Tie. 3rd-Card-Regeln automatisch. 5% Commission auf Banker. |
| `slot` | 3-Walzen mit Animation. Jackpot/Match/Pair Payouts. |

Alle Casino-Spiele nutzen das shared `casino-engine.ps1` Framework:
- Automatische Bank-Checks (Bust bei 0G -> Reset auf 100G)
- Companion reagiert auf grosse Gewinne/Verluste
- Automatisches Speichern nach jeder Runde

---

## Arcade

| Command | Beschreibung |
|---------|-------------|
| `snake` | Spielbares Snake mit Pfeiltasten. Highscore wird gespeichert. |
| `monkeytype` | WPM Typing-Test. Companion kommentiert bei schlechten Ergebnissen. |
| `wordle` | 5-Buchstaben-Raetsel. 6 Versuche. Farb-Feedback. |
| `zork` | Text-Adventure mit Raeumen, Items, Inventory. |
| `hangman` | Galgenmaennchen mit 3 Schwierigkeitsstufen und Wetten. |

---

## Strategy

| Command | Beschreibung |
|---------|-------------|
| `poker` | Texas Hold'em vs 1 AI-Gegner. Hand-Ranking, Betting Rounds, AI mit Random-Style. |
| `td` | Tower Defense. Wellen, 3 Turm-Typen (Sniper/Blaster/Freezer), Gegner bewegen sich zur Base. |
| `rogue` | Dungeon-Crawler. Floors, Kampf, Shop, Inventory, Procedural Map. |

---

## Companion v6

Deine Netrunner-Girl. Lebt im Terminal. Reagiert auf deine Actions.

**5 Girls zur Auswahl:**
- **NEON** (Netrunner, Cyan) - Sarkastisch, cool
- **RAVEN** (Enforcer, Red) - Dominant, hart
- **PIXEL** (Engineer, Magenta) - Schuechtern, sued
- **LUNA** (Medic, Green) - Fuersorglich, mutterlich
- **IVY** (Stealth, DarkGray) - Geheimnisvoll, kalt

**Relationship Levels:**
Stranger (0-14) -> Acquaintance (15-29) -> Friend (30-49) -> Close Friend (50-69) -> Partner (70-89) -> Soulmate (90-99) -> Spouse (100)

**Commands (via `pet` Hub oder direkt):**
- `pet talk` -- Chat, +2 Bond
- `pet gift` -- Geschenk, +5 Bond
- `pet train` -- Training, +3 Bond
- `pet story` -- Geschichte, +2 Bond
- `pet headpat` -- Headpat, +1 Bond
- `pet date` -- Date, +4 Bond (ab 30 Bond)
- `pet work` -- Sie arbeitet, verdient 10-40 Gold
- `pet outfit` -- 4 Outfits wechseln
- `pet status` -- Full Status mit Skills, Quests, Cooking, Memories, Rival
- `pet sleep` -- Schlaf-Animation
- `pet petcare` -- Haustier versorgen (Haustier-System)
- `pet confess` -- True Love Ending (ab 100 Bond)
- `pet marry` -- Heirat! (ab 100 Bond)

**Mood-System:**
Dynamisch basierend auf Uhrzeit, Bond, Verlusten, Eifersucht.
- Sleepy (22:00 - 06:00)
- Disappointed (bei 3+ Verlusten)
- Excited (ab 80 Bond)
- Cold (unter 20 Bond)
- Happy (Default)

**Cooking:**
Sie kann Buff-Food kochen: Ramen, Energy Drink, Sushi Platter.
Cooking-Buffs geben temporaere Casino-Luck oder Combat-Boosts.

**Rival-System:**
Ein Rival taucht auf mit HP, ATK, DEF. Kann besiegt werden fuer Belohnungen.

**Quests:**
Taegliche Quests mit Gold/XP-Belohnungen.

---

## Battlepet v24

Dein Monster, das du leveln und mit dem du kaempfen kannst.

**Starter (5 zur Auswahl):**
- `GLITCH_WOLF` (Virus) -> evolviert zu `CORRUPT_HOUND`
- `CYBER_RAPTOR` (Elec) -> evolviert zu `THUNDER_REX`
- `VOID_TURTLE` (Dark) -> evolviert zu `ABYSS_TORTOISE`
- `FLAME_FOX` (Fire) -> evolviert zu `INFERNO_VULPES`
- `FROST_BUNNY` (Ice) -> evolviert zu `BLIZZARD_HARE`

**Commands (via `pet` Hub):**
- `pet fight` -- Zufaelliger Gegner oder Boss
- `pet status` -- Stats + Titel + Equipment + Elemente
- `pet shop` -- Potions, Stat-Boosts, Equipment
- `pet breed` -- Pet Breeding (Companion Bond 50+, 50 Gold)
- `pet pvp` -- Shadow Arena (Ranked: Bronze -> Master)
- `pet raid` -- Taeglicher 3-Phasen-Raid-Boss
- `pet tournament` -- Woechentliches Turnier
- `pet adventure` -- Pet auf zeitbegrenzte Quest schicken
- `pet switch` -- Zwischen mehreren Pets wechseln

**Element-System:**
Fire > Ice > Elec > Water > Fire (1.5x Schaden)
Virus, Dark, Norm, Hack sind neutral/spezial

**Status-Effekte:**
BURN, POISON, STUN, REGEN, BUFF

**Titel-System (basierend auf Wins):**
Rookie (0) -> Veteran (5) -> Elite (15) -> Master (30) -> Legend (50) -> Net God (100)

**Multi-Pet System:**
Du kannst mehrere Pets besitzen und mit `pet switch` wechseln.

---

## Unified Pet Hub

Der `pet` Command ist der zentrale Einstieg fuer Companion und Battlepet:

```
pet          -- Zeigt Hub-Menu
pet talk     -- Mit Companion reden
pet fight    -- Battlepet Kampf starten
pet status   -- Beide Status anzeigen
pet daily    -- Taegliche Challenges
```

**Intelligente Routing:**
- `pet fight` -> Battlepet Kampf
- `pet talk` -> Companion Dialog
- `pet status` -> Beide Systeme anzeigen
- `pet daily` -> Daily Challenges fuer beide

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

## Ralph Loop (Kimi CLI)

| Command | Funktion |
|---------|----------|
| `kimir` | Kimi Reasoning |
| `kimia` | Kimi Architect |
| `kimix` | Kimi Mixed |
| `kimis` | Kimi Summary |

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

**Achievements:**
Freischaltbar durch Events:
- "Pet Evolution" (Battlepet Lv.10)
- "Week Streak" (7 Tage Daily)
- "Month Streak" (30 Tage Daily)
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

**Unicode/Encoding-Probleme?**
- BUXE_OS v24.0 verwendet **reines ASCII** in allen Dateien.
- Keine Umlaute, keine Emojis, keine Box-Drawing-Chars.
- Das verhindert Parser-Fehler bei verschiedenen Encoding-Einstellungen.

---

## Datei-Struktur

| Pfad | Beschreibung |
|------|-------------|
| `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | Hauptprofil (Entry Point) |
| `%USERPROFILE%\Documents\PowerShell\Modules\` | Alle 18 Module |
| `%USERPROFILE%\Documents\PowerShell\buxe.omp.json` | Oh My Posh Theme |
| `%LOCALAPPDATA%\buxe\buxe_state_v24.json` | Unified State File |
| `%LOCALAPPDATA%\buxe\v23_archive\` | Alte v23 Dateien (nach Migration) |

**Module (18 total):**
```
engine-state.ps1, engine-ui.ps1, engine-game.ps1, engine-aliases.ps1
casino-engine.ps1, casino-blackjack.ps1, casino-roulette.ps1, casino-craps.ps1,
casino-hilo.ps1, casino-baccarat.ps1, casino-slot.ps1, casino.ps1
arcade.ps1, strategy-poker.ps1, strategy-td.ps1, strategy-rogue.ps1
companion.ps1, battlepet.ps1, hub.ps1, boot.ps1, fun.ps1, ralph-loop.ps1
_smoke_test.ps1
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
