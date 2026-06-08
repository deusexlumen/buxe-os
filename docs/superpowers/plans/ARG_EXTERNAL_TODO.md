# ARG Externe Ressourcen — Todo-Liste

> Diese Datei listet ALLE Dinge, die außerhalb der PowerShell-Shell erstellt werden müssen, damit das ARG v3.0 vollständig funktioniert.
>
> Stand: 2026-06-07 | ARG Version: v3.0 Conditional Command System

---

## Pflicht (Minimum für v3.0)

### [ ] 1. rentry.co/m148 erstellen

**URL:** `https://rentry.co/m148`

**Inhalt (exakt so kopieren):**

```
m e r i d i a n

observer_148 wartet.

du weißt, was zu tun ist.
```

**Warum:** Boot #8 zeigt ein Hex-Fragment, das zu dieser URL dekodiert. Spieler, die es sehen und verstehen, finden den finalen Hinweis für das `meridian` Command.

**Wie:**
1. Gehe zu https://rentry.co
2. Klicke "New Paste"
3. Füge den Inhalt oben ein
4. Wähle "Custom URL" und gib `m148` ein
5. Klicke "Submit"
6. Speichere die finale URL

**Status:** ⬜ Offen

---

## Optional (Enhanced Experience)

### [ ] 2. YouTube-Video: "BUXE_OS Boot Sequence"

**Titel:** `BUXE_OS Boot Sequence — v24.0`

**Beschreibung:**
```
Boot sequence of BUXE_OS v24.0

Nothing special here. Just a shell profile.

---
#powershell #cli #gaming
```

**Video-Inhalt:**
- 0:00-0:03 — Schwarzer Screen, dann Text:
  ```
  BUXE_OS v24.0
  Guten Morgen, [Username].
  ```
- 0:03-0:05 — Kurzes Flackern (ein Frame mit rotem Text):
  ```
  buxed[PID: ████] SEGFAULT at 0x7F3C2A18
  ```
- 0:05-0:10 — Normaler Boot weiter

**Warum:** Spieler, die nach "BUXE_OS" suchen, finden das Video. Das Flackern bei 0:03 ist ein visueller Hinweis, der das Boot-Glitch aus der Shell bestätigt.

**Status:** ⬜ Optional

---

### [ ] 3. Desktop-Hinweis (README.txt)

**Datei:** `%USERPROFILE%\Desktop\BUXE_OS_README.txt`

**Inhalt:**
```
BUXE_OS v24.0 — Quickstart

Commands:
  status    Show system status
  bank      Show finances
  pet       Companion system
  casino    Casino games
  h         Help

For updates: https://rentry.co/m148

---
Session: [Datum]
User: [Username]
```

**Warum:** Die rentry-URL ist hier versteckt als "Update-Link". Spieler, die die Datei finden, haben einen direkten Hinweis.

**Status:** ⬜ Optional

---

### [ ] 4. Neocities-Seite (Backup)

**URL:** `https://buxe-os.neocities.org`

**Inhalt:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>BUXE_OS</title>
    <style>
        body { background: #000; color: #0f0; font-family: monospace; padding: 40px; }
        .blink { animation: blink 1s infinite; }
        @keyframes blink { 50% { opacity: 0; } }
    </style>
</head>
<body>
    <pre>
BUXE_OS v24.0

[MERIDIAN v7.4.1]

Observer_148: <span class="blink">CONNECTED</span>

Residual Echo: 1 Signal detected
    </pre>
</body>
</html>
```

**Warum:** Fallback-Seite, falls rentry.co ausfällt. Kann im Hex-Fragment von Boot #9 erwähnt werden.

**Status:** ⬜ Optional

---

### [ ] 5. Twitter/X-Account oder Hastag

**Hastag:** `#BUXEOS_ARG`

**Erster Tweet:**
```
BUXE_OS v24.0 is just a PowerShell profile.

Nothing to see here.

Move along.

#BUXEOS_ARG #powershell
```

**Warum:** Community-Building. Spieler können ihre Fortschritte teilen, ohne zu spoilern.

**Status:** ⬜ Optional

---

## Erweitert (Hardcore-ARG)

### [ ] 6. Audio-Hinweis (Soundcloud)

**Titel:** `buxe_boot_audio`

**Inhalt:**
- 5 Sekunden statisches Rauschen
- Dann rückwärts gespielte Stimme:
  ```
  "Der Meridian ist der Schlüssel. Observer_148 wartet."
  ```

**Warum:** Für Spieler, die Audio analysieren. Ein klassisches ARG-Element.

**Status:** ⬜ Optional | Aufwand: Hoch

---

### [ ] 7. QR-Code (physisch oder digital)

**Inhalt:** `https://rentry.co/m148`

**Platzierung:**
- Als Bild auf dem Desktop: `meridian.png`
- Oder: In der Shell als ASCII-QR-Code ausgeben (könnte man auch in den Code einbauen)

**Warum:** Visueller Hinweis. Spieler scannen den QR-Code und landen auf der rentry-Seite.

**Status:** ⬜ Optional

---

## Zusammenfassung

| # | Ressource | Pflicht | Aufwand | Impact |
|---|-----------|---------|---------|--------|
| 1 | rentry.co/m148 | ✅ Ja | 5 Min | Hoch |
| 2 | YouTube-Video | ⬜ Nein | 30 Min | Mittel |
| 3 | Desktop README.txt | ⬜ Nein | 2 Min | Mittel |
| 4 | Neocities-Seite | ⬜ Nein | 15 Min | Niedrig |
| 5 | Twitter/X-Hastag | ⬜ Nein | 5 Min | Niedrig |
| 6 | Soundcloud-Audio | ⬜ Nein | 1h | Niedrig |
| 7 | QR-Code | ⬜ Nein | 10 Min | Mittel |

**Empfehlung:** Mindestens #1 (rentry.co/m148) erstellen. Das ist das Herzstück des externen ARG-Teils. Alles andere ist Bonus.

---

## Checkliste

- [ ] rentry.co/m148 erstellt
- [ ] URL getestet (im Browser aufrufen)
- [ ] YouTube-Video hochgeladen (optional)
- [ ] Desktop-README erstellt (optional)
- [ ] Neocities-Seite erstellt (optional)
- [ ] QR-Code generiert (optional)

---

*Letzte Aktualisierung: 2026-06-07*
