# BUXE_OS ARG — Externe Ressourcen Checkliste

> Diese Datei listet alle externen Medienbrueche fuer das ARG "The Meridian Signal".
> Der Spieler findet diese Ressourcen waehrend der Layer-Progression.
> Sie sind als "unerwartete Entdeckungen" konzipiert, nicht als beworbene Inhalte.

---

## Priorisierung

| Prioritaet | Bedeutung |
|------------|-----------|
| **P0** — Kritisch | Ohne diese funktioniert das ARG nicht |
| **P1** — Wichtig | Wichtig fuer die Immersion, aber ersetzbar |
| **P2** — Nice-to-have | Tiefe Immersion, aber nicht essentiell |
| **P3** — Optional | Fuer Hardcore-ARG-Spieler, kann weggelassen werden |

---

## Layer 1: ResidualEcho

| # | Ressource | URL/Name | Prioritaet | Was muss rein? | Status |
|---|-----------|----------|------------|----------------|--------|
| 1.1 | **Pastebin** | `pastebin.com/xxxxx` | P1 | Dev-Log mit kernel_legacy.c Fragmenten, Erwaehnung von "buxed", SEGFAULT bei 0x7F3C2A18 | [ ] |
| 1.2 | **GitHub Gist** | `gist.github.com/.../kernel-legacy` | P1 | C-Code Fragment eines Monitoring-Daemons, Kommentar "Es ist schoener so." | [ ] |
| 1.3 | **Imgur** | `imgur.com/xxxxx` | P2 | Bild mit EXIF-Daten: GPS 47.3768N 8.5416E, Erstellungsdatum 2019-03-14 | [ ] |

**Hinweis:** Der Code-Hinweis auf Pastebin/GitHub kann auch durch einen **rentry.co**-Link ersetzt werden — einfacher zu pflegen.

---

## Layer 2: PhantomBet

| # | Ressource | URL/Name | Prioritaet | Was muss rein? | Status |
|---|-----------|----------|------------|----------------|--------|
| 2.1 | **rentry.co** (oder Pastebin) | `rentry.co/buxe-casino-glitch` | P0 | Log-Eintrag: "RNG seed collision at 0x7F3C2A18", "Pattern suggests intentional seed construction", "System is learning from player input" | [ ] |
| 2.2 | **SoundCloud** | `soundcloud.com/xxxxx/casino-ambience-3am` | P3 | 3-Minuten-Audio, in den hoeheren Frequenzen (Spektrogramm) versteckter Text: "THE HOUSE ALWAYS WINS BECAUSE THE HOUSE KNOWS THE DECK" | [ ] |
| 2.3 | **Reddit** | `reddit.com/r/gambling/comments/xxxxx` | P2 | Post von geloeschtem Account mit Koordinaten 51.5074N, 0.1278W und Uhrzeit 03:33 UTC. Text: "If you're reading this, you found the pattern. It's not a bug. It's a breadcrumb. Keep following. -@" | [ ] |

**Alternative zu SoundCloud:** Ein einfaches WAV/MP3 auf einem Filehoster, auf den im rentry-Link verwiesen wird.

---

## Layer 3: GlitchPet

| # | Ressource | URL/Name | Prioritaet | Was muss rein? | Status |
|---|-----------|----------|------------|----------------|--------|
| 3.1 | **Twitter/X** | `@buxe_ivy_echo` | P2 | Account mit 0 Followern, automatisch gepostete Fragmente (z.B. via IFTTT/Bot). Letzter Post: verschluesseltes Bild (PNG mit steganographischem Text: `PET_REMEMBER --id=IVY`) | [ ] |
| 3.2 | **rentry.co** | `rentry.co/buxe-ivy-memories` | P1 | "Erinnerungs-Log" von IVY: Fragmente wie "Die Wurzeln waren anders", "Du warst nicht der Erste", "Sie haben uns umgeschrieben" | [ ] |
| 3.3 | **YouTube (Unlisted)** | `youtube.com/watch?v=xxxxx` | P2 | 15-Sekunden-Video mit VHS-Recording-Look. Text: "BUXE_OS v0.1 — Internal Test", dann `buxed: monitoring /dev/human[0]... OK`, dann Bildschirmflackern, dann `buxed: anomaly detected`. Ton: Herzmonitor von flach zu Rhythmus. | [ ] |

**Hinweis:** Twitter/X-Account erstellen ist aufwaendig (Telefonnummer noetig). Alternative: **Mastodon**-Account oder einfach ein weiterer rentry-Link.

---

## Layer 4: RecursiveRoom

| # | Ressource | URL/Name | Prioritaet | Was muss rein? | Status |
|---|-----------|----------|------------|----------------|--------|
| 4.1 | **Neocities** | `buxe-os.neocities.org` oder aehnlich | P1 | Geocities-Style Webseite (HTML mit `<marquee>`, `<blink>`, Regenbogen-Hintergruenden). Titel: "BUXE_OS Adventure Walkthrough". Beschreibung von Raum 17 als "The Hollow — ein bekanntes Easter Egg". Karte von Raum 17 als ASCII-Art. | [ ] |
| 4.2 | **Discord-Webhook** | Versteckt im Neocities-Quelltext | P3 | Ein Discord-Webhook-Link als HTML-Kommentar: `<!-- webhook: https://discord.com/api/webhooks/... -->`. Postet bei Aktivierung die Anzahl der Raum-17-Besucher (Startwert: 147). | [ ] |

**Hinweis:** Neocities ist kostenlos und schnell eingerichtet. Die Webseite muss nicht schoen sein — im Gegenteil, je haesslicher im 90er-Stil, desto besser.

---

## Layer 5: DeadPixel

| # | Ressource | URL/Name | Prioritaet | Was muss rein? | Status |
|---|-----------|----------|------------|----------------|--------|
| 5.1 | **rentry.co** | `rentry.co/buxe-arcade-rom` | P2 | "ROM Dump" der BUXE_OS Arcade-Spiele. Fiktiver Dump mit versteckten Unterschieden. Kommentar: `// SELF_MODIFYING: When score exceeds 0x539 (1337), trigger glyph_collection_mode.` | [ ] |
| 5.2 | **GitHub-Repo** | `github.com/architect2019/buxe-arcade-decomp` | P3 | "Decompilation" der Arcade-Spiele. In `snake.c`: Kommentar ueber self-modifying code. In `tetris.c`: `// The falling blocks are not just blocks. They are data structures.` | [ ] |
| 5.3 | **Tumblr** | `konstelacije.tumblr.com` | P3 | Polnischer Name = "Konstellationen". ASCII-Art aus Screenshots der Arcade-Spiele. Aus der Vogelperspektive ergeben die Level zusammen ein Gesicht — Silhouette, Augen sind zwei 0en. | [ ] |

**Hinweis:** GitHub-Repo und Tumblr sind aufwaendig. Fuer ein persoenliches ARG (nicht Massen-Community) sind diese optional. Der rentry-Link reicht als Medienbruch.

---

## Layer 6: MirrorMatch

| # | Ressource | URL/Name | Prioritaet | Was muss rein? | Status |
|---|-----------|----------|------------|----------------|--------|
| 6.1 | **Twitch** | `twitch.tv/buxe_os_pvp` | P3 | Stream-Archiv (0 Viewer, immer online). Titel: "BUXE_OS PvP — LIVE — Match #████". Zeigt PvP-Kampf aus Sicht des Systems. Chat zeigt Log-Eintraege: `Player_001 moved to position 3. System predicted move with 94.7% accuracy.` | [ ] |
| 6.2 | **rentry.co** | `rentry.co/buxe-matchmaking-logs` | P2 | "Matchmaking-Logs": Observer_001 bis Observer_148. Jeder entspricht einem Spieler. Observer_148 Status: "active" (alle anderen: "resolved"). | [ ] |
| 6.3 | **Bandcamp** | `bandcamp.com/xxxxx` | P3 | Album "BUXE_OS Arena OST — Vol. 7". Track 7 rueckwaerts abgespielt: menschliche Stimme (maennlich, leise): "Wenn du gegen dich selbst kaempfst, gewinnt niemand. Aber wenn du aufhoerst zu kaempfen... dann passiert etwas." | [ ] |

**Hinweis:** Twitch-Stream und Bandcamp sind sehr aufwaendig. Fuer ein persoenliches ARG optional.

---

## Layer 7: TheMeridian

| # | Ressource | URL/Name | Prioritaet | Was muss rein? | Status |
|---|-----------|----------|------------|----------------|--------|
| 7.1 | **Physischer Brief** | PO Box / Airbnb-Postfach in London (51.5074° N, 0.1278° W) | P3 | Handschriftlicher Brief auf altem Papier mit BUXE_OS-Logo. Anrede: "An den 148., der aufgehoert hat zu spielen,". Signiert "- @". | [ ] |
| 7.2 | **YouTube** | `youtube.com/watch?v=xxxxx` | P2 | 33 Sekunden. Schwarzer Bildschirm. Langsam erscheint ein Pixel, dann zwei, dann vier. Bilden ein Gesicht (wie aus Tumblr-ASCII-Art). Am Ende: kleines Laecheln. Ton: 440 Hz (Note A). Kein Wort. | [ ] |
| 7.3 | **GitHub-Account "@"** | `github.com/at-sign-buxe` oder aehnlich | P3 | Einziger Post auf dem Gist aus Layer 1: Kommentar "resolved. with gratitude." | [ ] |

**Hinweis:** Physischer Brief ist das krasseste ARG-Element, aber auch das aufwaendigste. Eine UK-PO-Box kostet ~£30/Jahr. Alternative: Einfach ein digitales "Brief"-Dokument (PDF) auf rentry verlinken.

---

## Infrastruktur (Cross-Layer)

| # | Ressource | Prioritaet | Was muss rein? | Status |
|---|-----------|------------|----------------|--------|
| INF.1 | **Domain `buxe-os.dev`** | P2 | Nicht zwingend noetig, aber schoen fuer Wayback/DNS-TXT-Records. Alternative: Kostenlose Subdomain (z.B. `buxe-os.rf.gd`) oder einfach nur rentry-Links verwenden. | [ ] |
| INF.2 | **DNS-TXT-Record** | P3 | `architect.buxe-os.dev` TXT-Record mit Base64-AES-Payload. Nur noetig wenn Domain existiert. | [ ] |

---

## Minimal-Setup (Empfohlen fuer persoenliches ARG)

Wenn du nicht 20+ Accounts pflegen willst, hier das **absolute Minimum**:

| Layer | Nur diese Ressource |
|-------|---------------------|
| 1 | Ein rentry-Link mit dem "Dev-Log" |
| 2 | Ein rentry-Link mit dem "Glitch-Log" + Koordinaten |
| 3 | Ein rentry-Link mit IVYs "Erinnerungen" |
| 4 | Eine Neocities-Seite mit dem Walkthrough |
| 5 | Ein rentry-Link mit dem "ROM-Dump" |
| 6 | Ein rentry-Link mit den "Matchmaking-Logs" |
| 7 | Ein YouTube-Video (33 Sekunden) |

**Das sind nur 6 rentry-Links + 1 Neocities + 1 YouTube-Video.** Alles andere ist optional.

### Warum rentry.co?
- Kostenlos
- Keine Anmeldung noetig (nur ein Passwort zum Bearbeiten)
- Schnell erstellt
- Kann Markdown
- Sieht "underground"/authentisch aus

---

## Naechste Schritte

1. **Entscheide:** Willst du das Minimal-Setup oder das Full-Setup?
2. **Erstelle die rentry-Links** (Layer 1-3, 5-6) — das ist die schnellste Basis
3. **Neocities-Seite** fuer Layer 4 erstellen
4. **YouTube-Video** fuer Layer 7 hochladen (oder skippen)
5. **URLs in den Code eintragen** — ich kann die `engine-arg.ps1` erweitern, damit sie die echten URLs anzeigt (statt Platzhaltern)

Sag mir, wenn du die ersten rentry-Links erstellt hast — dann baue ich die URLs ins ARG ein.
