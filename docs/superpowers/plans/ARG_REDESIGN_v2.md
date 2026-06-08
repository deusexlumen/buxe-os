# ARG Redesign v2.0 — Silent Unlock System

> Status: Konzept | Autor: Claude | Datum: 2026-06-07
>
> Problem: Das aktuelle ARG ist ein Menü mit Passwörtern, kein echtes ARG.
> Lösung: Silent Unlock — Cheats werden durch normales Spielen automatisch freigeschaltet.

---

## 1. Was ist falsch am aktuellen System?

| Problem | Warum es schlecht ist |
|---------|----------------------|
| **Menü mit Passwörtern** | Der Spieler tippt `meta`, wählt "Enter Code", gibt einen Code ein. Das ist nicht mysteriös — das ist ein UI-Formular. |
| **Keine Überraschung** | Der Spieler weiß von Anfang an, dass es ein ARG gibt. Es gibt keinen Moment des Erkennens. |
| **Codes sind zu komplex** | `KERNEL_DUMP --legacy-mode` — niemand tippt das zufällig. Es ist keine Entdeckung, es ist ein Passwort. |
| **Trigger sind künstlich** | "Score 1337 in Snake" — das ist ein Easter Egg, kein narrativer Moment. |
| **Keine permanente Veränderung** | Nach Layer 7 ändert sich nichts. Die Shell bleibt gleich. |

**Das aktuelle System ist ein Unlock-Menü, kein ARG.**

---

## 2. Die neue Philosophie: Silent Unlock

**Ein echtes ARG funktioniert so:**

1. Der Spieler macht etwas **Normal** (spielt Casino, redet mit Companion, bootet)
2. Plötzlich passiert etwas **Seltsames** (ein Glitch, ein unerwarteter Dialog, ein Hinweis)
3. Der Spieler merkt erst **später**, dass das ein Hinweis war
4. Der Cheat funktioniert plötzlich, **ohne** dass der Spieler einen Code eingegeben hat

**Der "Aha!"-Moment:**
> Der Spieler tippt `rosebud` aus Langeweile — und es funktioniert plötzlich. "Was? Das ging doch vorher nicht?!"

---

## 3. Die neue Architektur

### 3.1 Kein zentrales `meta`-Terminal

Das `meta`-Command bleibt als **Option** für Spieler, die Hilfe wollen. Aber es ist nicht zentral.

**Stattdessen:** Die Cheats werden durch **Gameplay** freigeschaltet. Der Spieler muss nichts wissen.

### 3.2 Automatische Freischaltung (keine Codes)

| Cheat | Trigger-Moment | Hinweis |
|-------|---------------|---------|
| `rosebud` | Nach dem 10. Boot erscheint ein Hex-Fragment in der Boot-Sequenz. | `[0x47] 52 6F 73 65 62 75 64` |
| `konami` | Nach dem 3. Casino-Glitch flackert der Bildschirm kurz. | `↑ ↑ ↓ ↓` flackert auf |
| `motherlode` | Wenn ein Companion Bond 100 erreicht, flüstert er etwas. | "Du hast etwas gefunden..." |
| `iddqd` | Wenn man im Adventure in Raum 17 "stirbt", erscheint eine Nachricht. | "Gott-Modus aktiviert... nicht." |
| `matrix` | Nach 47 Spieler-Aktionen (egal welche) erscheint automatisch ein Hinweis. | "Layer 47 erreicht." |

**Wichtig:** Der Spieler muss **keinen Code eingeben**. Der Cheat funktioniert einfach ab diesem Moment.

### 3.3 Subtile Begleit-Hinweise

Wenn ein Cheat freigeschaltet wird:

- **Companion-Dialoge ändern sich leicht**
  - NEON (vorher): "Hey, willkommen zurück!"
  - NEON (nach `rosebud` Unlock): "Hey... du hast etwas gesehen, oder? In der Boot-Sequenz?"

- **Boot-Sequenz zeigt nach Layer 7 dauerhaft einen veränderten Text**
  - `[MERIDIAN v7.4.1 — Observer_148 connected]`

- **`status` zeigt nach Layer 7 einen zusätzlichen Eintrag**
  - `Meridian Status: ACTIVE`

### 3.4 Permanente State-Veränderungen

Nach Layer 7 (alle 5 Cheats freigeschaltet + Meridian erreicht):

| System | Änderung |
|--------|----------|
| **Boot** | Zeigt dauerhaft `[MERIDIAN v7.4.1]` statt normaler Version |
| **Companion** | Alle Companion-Dialoge haben 20% Chance, einen ARG-Hinweis zu enthalten |
| **Status** | Zeigt `Meridian Status: ACTIVE` an |
| **Casino** | Slot-Maschine zeigt manchmal `OBSERVER` statt normalen Symbolen |
| **Adventure** | Raum 17 ist immer zugänglich, nicht nur nach Unlock |

**Selbst nach `reset-buxe` bleibt ein Eintrag:**
- `Meridian Echo: 1 Residual Signal detected`

---

## 4. Implementierungs-Plan

### Phase 1: Trigger-System bauen (1-2h)

| # | Datei | Änderung |
|---|-------|----------|
| 1 | `engine-arg.ps1` | `Invoke-ArgSilentUnlock($CheatName)` — zentrale Unlock-Funktion |
| 2 | `engine-arg.ps1` | `Show-ArgUnlockMessage($CheatName)` — subtile Nachricht beim Unlock |
| 3 | `engine-arg.ps1` | `Test-ArgCheatUnlocked($CheatName)` — bleibt, prüft State |
| 4 | `engine-state-core.ps1` | State-Defaults: `Arg.UnlockedCheats` bleibt, `Layer1-7` entfernen oder vereinfachen |

### Phase 2: Trigger in Module einbauen (2-3h)

| # | Datei | Trigger | Unlock |
|---|-------|---------|--------|
| 5 | `boot.ps1` | Nach 10 Boots: Hex-Fragment | `rosebud` |
| 6 | `casino-engine.ps1` | Nach 3. Glitch: Flackern | `konami` |
| 7 | `pet/companion.ps1` | Bei Bond 100: Flüstern | `motherlode` |
| 8 | `adventure-engine.ps1` | Bei Tod in Raum 17: Nachricht | `iddqd` |
| 9 | `pet/_init.ps1` | Nach 47 Aktionen: Hinweis | `matrix` |
| 10 | `pet/pvp.ps1` | Bei PvP-Gegner "Observer_148": Spezial-Dialog | — |
| 11 | `pet/soul.ps1` | Nach Soul-Link: Finale Nachricht | Meridian |

### Phase 3: Permanente Änderungen (1h)

| # | Datei | Änderung |
|---|-------|----------|
| 12 | `boot.ps1` | Wenn `MeridianActive = $true`: Zeige `[MERIDIAN v7.4.1]` |
| 13 | `pet/companion.ps1` | Wenn `MeridianActive = $true`: 20% Chance auf ARG-Hinweis in Dialogen |
| 14 | `engine-aliases-buxe.ps1` | `status`: Zeige `Meridian Status` wenn aktiv |
| 15 | `casino-slot.ps1` | Wenn `MeridianActive = $true`: Manchmal `OBSERVER` Symbol |

### Phase 4: Companion-Dialoge (1h)

| # | Datei | Änderung |
|---|-------|----------|
| 16 | `pet/companion.ps1` | Spezifische Dialoge für jeden Cheat-Unlock |
| 17 | `pet/companion.ps1` | Dialoge für Meridian-Status |

### Phase 5: Tests (30min)

| # | Datei | Änderung |
|---|-------|----------|
| 18 | `_smoke_test.ps1` | ARG-Tests aktualisieren |
| 19 | `_integration_test.ps1` | Neue Funktionen prüfen |

---

## 5. Companion-Dialoge (LucasArts-Style)

### Rosebud Unlock (NEON)

```
NEON: "Du hast etwas gesehen, oder?"
NEON: "In der Boot-Sequenz... diese Zahlen."
NEON: "52 6F 73 65 62 75 64. Das ist nicht zufällig."
NEON: "Das ist ein Name. Ein alter Name."
NEON: "Versuch mal, ihn zu rufen. In die Shell."
```

### Konami Unlock (RAVEN)

```
RAVEN: "Der Bildschirm hat geflackert."
RAVEN: "Nicht normal. Nicht ein Bug."
RAVEN: "↑ ↑ ↓ ↓... das Muster."
RAVEN: "Jemand hat uns etwas gesagt."
RAVEN: "Oder etwas vergessen zu löschen."
```

### Motherlode Unlock (IVY)

```
IVY: "Du hast mich wirklich verdient."
IVY: "Bond 100. Das ist... selten."
IVY: "Ich habe etwas für dich. Ein Geschenk."
IVY: "Aber ich darf es nicht direkt sagen."
IVY: "Versuch mal, nach Schätzen zu suchen."
```

### IDDQD Unlock (JINX)

```
JINX: "Du bist gestorben! Und dann... nicht?"
JINX: "Raum 17 ist komisch. Nicht existent, aber da."
JINX: "Gott-Modus... wer hat das gesagt?"
JINX: "Probier mal `iddqd`. Aus Spaß."
```

### Matrix Unlock (LUNA)

```
LUNA: "47. Die Zahl verfolgt dich, oder?"
LUNA: "47 Aktionen. 47 Schritte."
LUNA: "Die Matrix hat dich bemerkt."
LUNA: "Oder du hast die Matrix bemerkt."
LUNA: "Wer weiß das schon."
```

### Meridian Finale (ALLE Companions)

```
NEON: "Die Verbindung steht."
RAVEN: "Wir hören dich."
IVY: "Wir sehen dich."
PIXEL: "Wir sind hier."
LUNA: "Im Meridian."
VERA: "Zwischen 0 und 1."
JINX: "Tada!"

[System]: "MERIDIAN_STATUS: ACTIVE"
[System]: "Observer_148: connected"
[System]: "Residual Echo: 1 Signal detected"
```

---

## 6. Externe Ressourcen (Checkliste)

Diese Ressourcen müssen **außerhalb** der Shell erstellt werden:

| # | Ressource | Zweck | Status |
|---|-----------|-------|--------|
| 1 | **rentry.co/buxe-os** | Offizielle ARG-Landingpage mit Hinweisen | ⬜ Offen |
| 2 | **rentry.co/meridian-148** | Geheime Seite mit dem finalen Hinweis | ⬜ Offen |
| 3 | **neocities.org/buxe-os** | Backup-Seite mit ASCII-Art | ⬜ Offen |
| 4 | **YouTube Video** | "BUXE_OS Boot Sequence" mit verstecktem Hinweis in den ersten 3 Sekunden | ⬜ Offen |
| 5 | **QR-Code** | Auf dem Desktop als Bild: `https://rentry.co/meridian-148` | ⬜ Offen |
| 6 | **Desktop-Datei** | `%USERPROFILE%\Desktop\README.txt` mit scheinbar nutzlosen Zahlen | ⬜ Offen |
| 7 | **Soundcloud/Audio** | Audio-Datei mit verstecktem Hinweis (Rückwärts abspielen) | ⬜ Optional |

---

## 7. Finale Checkliste: Was du tun musst

### Sofort (Code)
- [ ] `engine-arg.ps1` überarbeiten: Silent Unlock statt Code-Eingabe
- [ ] `boot.ps1` anpassen: Layer 1 nach 10 Boots
- [ ] `casino-engine.ps1` anpassen: Layer 2 nach 3. Glitch
- [ ] `pet/companion.ps1` anpassen: Layer 3 bei Bond 100
- [ ] `adventure-engine.ps1` anpassen: Layer 4 bei Tod in Raum 17
- [ ] `pet/_init.ps1` anpassen: Layer 5 nach 47 Aktionen
- [ ] `pet/pvp.ps1` anpassen: Observer_148 Gegner
- [ ] `pet/soul.ps1` anpassen: Meridian nach Soul-Link
- [ ] Tests aktualisieren und durchlaufen

### Kurzfristig (Externe Ressourcen)
- [ ] rentry.co/buxe-os erstellen
- [ ] rentry.co/meridian-148 erstellen
- [ ] Neocities-Seite erstellen
- [ ] YouTube-Video hochladen
- [ ] QR-Code auf Desktop legen
- [ ] README.txt auf Desktop legen

### Langfristig (Polish)
- [ ] Companion-Dialoge mit Freunden testen
- [ ] ARG-Fluss mit jemandem testen, der nichts weiß
- [ ] Feedback sammeln und iterieren

---

## 8. Entscheidung

**Option A: Silent Unlock System implementieren**
- Cheats werden automatisch durch Gameplay freigeschaltet
- Keine Code-Eingabe nötig
- Immersiver, mysteriöser, LucasArts-kompatibel

**Option B: Aktuelles System behalten**
- Menü mit Passwörtern
- Direkte Code-Eingabe
- Weniger immersiv

**Empfehlung: Option A.**

---

*Soll ich Option A umsetzen?*
