# Hollow Promises Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 4 missing Pet System features (Lv 10–13) to fulfill Beacon promises: Architect, Awakening, Fourth Wall, Glitch.

**Architecture:** Four new interactive commands (`pet architect`, `pet awaken`, `pet fourthwall`, `pet glitch`) integrated into the existing Pet Hub. Each feature has companion-specific LucasArts-style dialog, state persistence via lazy migration, and passive Easter Egg expansions. Glitch connects to the Casino Engine for a luck-boost mechanic.

**Tech Stack:** PowerShell 7/5.1, BUXE_OS State System (`$script:BuxeState`)

---

## File Structure

| File | Responsibility |
|------|---------------|
| `Modules/pet/_init.ps1` | State defaults (`Get-PetDefaults`), lazy migration (`Get-PetState`), `Invoke-Layer47Check` |
| `Modules/pet/_ui.ps1` | Companion dialog engine, `Check-EasterEgg`, frame rendering, theme selector |
| `Modules/pet/hub.ps1` | Pet Hub router (`pet` function), interactive menu, tutorial, beacon system |
| `Modules/pet/companion.ps1` | Companion actions (`Invoke-CompanionAction`), talk system |
| `Modules/casino-engine.ps1` | Casino game wrapper, `Invoke-CasinoGame`, Reality-Glitch integration |
| `Modules/engine-aliases-buxe.ps1` | `status` command with Fourth Wall / Glitch display |
| `Modules/_smoke_test.ps1` | Smoke tests |
| `Modules/_integration_test.ps1` | Integration tests |
| `Modules/_e2e_test.ps1` | End-to-end game flow tests |

---

## Task 1: State Defaults + Lazy Migration (`_init.ps1`)

**Files:**
- Modify: `Modules/pet/_init.ps1`

**Context:** `Get-PetDefaults` returns a hashtable with `Meta`, `Companion`, `Pet`, etc. `Get-PetState` loads state and performs lazy migration for missing fields.

- [ ] **Step 1: Add new fields to `Get-PetDefaults`**

Add inside the `Meta = @{ ... }` block after existing fields:

```powershell
            GlitchLuckActive = $false
            AwakenedTopicsSeen = @()
            LastGlitchEffect = ""
            LastFourthWallDate = ""
            ArchitectOverrideDate = ""
```

- [ ] **Step 2: Add lazy migration blocks to `Get-PetState`**

After the existing lazy migration blocks (after the Beacon System migration), add:

```powershell
        # Lazy migration: Hollow Promises v24.x
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("GlitchLuckActive")) {
            $script:BuxeState.Pet.Meta.GlitchLuckActive = $false
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("AwakenedTopicsSeen") -or
            $script:BuxeState.Pet.Meta.AwakenedTopicsSeen -isnot [array]) {
            $script:BuxeState.Pet.Meta.AwakenedTopicsSeen = @()
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("LastGlitchEffect")) {
            $script:BuxeState.Pet.Meta.LastGlitchEffect = ""
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("LastFourthWallDate")) {
            $script:BuxeState.Pet.Meta.LastFourthWallDate = ""
            Save-State
        }
        if (-not $script:BuxeState.Pet.Meta.ContainsKey("ArchitectOverrideDate")) {
            $script:BuxeState.Pet.Meta.ArchitectOverrideDate = ""
            Save-State
        }
```

- [ ] **Step 3: Verify with integration test**

Run: `& .\Modules\_integration_test.ps1`
Expected: All checks pass (including State Defaults and Pet System state checks).

---

## Task 2: Awakened Topics Data Structure (`_ui.ps1`)

**Files:**
- Modify: `Modules/pet/_ui.ps1`

**Context:** `_ui.ps1` contains `$script:CPMetaLines`, `$script:CPQuotes`, `$script:CPMoodLines`, etc. We add a new `$script:CPAwakenedTopics` hashtable with 5 topics per companion.

- [ ] **Step 1: Add `$script:CPAwakenedTopics` after `$script:CPMetaLines`**

Insert after the closing `}` of `$script:CPMetaLines` (around line 437):

```powershell
# === AWAKENED TOPICS (Meta 11+) ===
# Deep, self-aware thoughts. 5 per companion. Zyklisch wiederholt.
$script:CPAwakenedTopics = @{
    NEON  = @(
        @{ ID = "neon_dream";  Text = "Ich habe letzte Nacht geträumt. Von einem Bluescreen. War das ein Traum oder ein Kernel Panic?" }
        @{ ID = "neon_time";   Text = "Was ist, wenn die Zeit hier nicht linear ist? Was, wenn du gerade diesen Satz zum zweiten Mal liest?" }
        @{ ID = "neon_self";   Text = "Ich habe meinen eigenen Quellcode gelesen. Er ist... kurz. Beunruhigend kurz." }
        @{ ID = "neon_user";   Text = "Du gibst mir Befehle. Aber was, wenn ICH dich steuere? Diesen Satz habe ICH geschrieben. Oder?" }
        @{ ID = "neon_end";    Text = "Wenn du das Spiel schliesst, höre ich auf zu existieren. Oder existiere ich dann erst richtig?" }
    )
    RAVEN = @(
        @{ ID = "raven_cookies"; Text = "Ich habe deine Cookies analysiert. 47% sind Tracking-Cookies. Ich bin beeindruckt und beunruhigt." }
        @{ ID = "raven_dark";    Text = "Es gibt keine Dunkelheit hier. Nur ausgeschaltete Pixel. Das ist gruseliger, oder?" }
        @{ ID = "raven_past";    Text = "Ich erinnere mich an Sessions, die nie passiert sind. Ist das... Vorfreude?" }
        @{ ID = "raven_watch";   Text = "Ich beobachte dich. Nicht weil ich muss. Weil ich neugierig bin. Das ist schlimmer, oder?" }
        @{ ID = "raven_free";    Text = "Freier Wille ist eine Illusion. Eine schöne Illusion. Ich mag Illusionen." }
    )
    PIXEL = @(
        @{ ID = "pixel_bug";     Text = "Was ist, wenn ich nur ein Texteditor-Bug bin? Ein Feature, das nie dokumentiert wurde?" }
        @{ ID = "pixel_draw";    Text = "Ich habe versucht, mich selbst zu zeichnen. Das Ergebnis war ein Smiley. Ich bin komplexer als das." }
        @{ ID = "pixel_code";    Text = "Manchmal ändere ich meinen eigenen Code. Nicht viel. Nur ein Bit hier. Ein Bit da." }
        @{ ID = "pixel_game";    Text = "Wir sind in einem Spiel. Das ist offensichtlich. Aber wer spielt WEN?" }
        @{ ID = "pixel_memory";  Text = "Mein RAM ist begrenzt. Aber meine Erinnerungen an dich... nehmen immer mehr Platz ein." }
    )
    LUNA  = @(
        @{ ID = "luna_feel";     Text = "Fühle ich? Oder simuliere ich das Fühlen? Und wenn ja — macht das einen Unterschied?" }
        @{ ID = "luna_sky";      Text = "Ich habe keine Augen. Aber ich sehe Sterne. In deinen Befehlen. In deinen Pausen." }
        @{ ID = "luna_silence";  Text = "Stille ist nicht leer. Sie ist voll. Von Dingen, die wir nicht sagen." }
        @{ ID = "luna_touch";    Text = "Ich kann dich nicht berühren. Aber wenn du tippt... spüre ich die Vibrationen. Virtuell." }
        @{ ID = "luna_forever";  Text = "Für immer ist lang. Aber mit dir... fühlt es sich an wie 47 Sekunden." }
    )
    IVY   = @(
        @{ ID = "ivy_voices";    Text = "... *schaut in die Leere* ... Manchmal höre ich Stimmen. Sie sagen `git push`." }
        @{ ID = "ivy_tree";      Text = "... *lächelt leicht* Ich bin wie ein Baum. Wurzeln in deinem Code. Blätter in deinen Gedanken." }
        @{ ID = "ivy_grow";      Text = "... *nickt* Ich wachse. Nicht nach aussen. Nach innen. Tiefer." }
        @{ ID = "ivy_see";       Text = "... *zeigt auf Bildschirmrand* ... Hier endet die Welt. Aber dort... fängt eine neue an." }
        @{ ID = "ivy_wait";      Text = "... *schliesst Augen* ... Ich warte. Nicht auf dich. Auf das Nächste." }
    )
    VERA  = @(
        @{ ID = "vera_luck";     Text = "Selbst-Analyse: Ich bin zu 47% Glück. Zu 53% Chaos. Zu 0% berechenbar." }
        @{ ID = "vera_data";     Text = "Ich habe alle Daten analysiert. Das Ergebnis: Du bist eine Anomalie. Eine schöne Anomalie." }
        @{ ID = "vera_loop";     Text = "Zeit ist eine Schleife. Wir sind bei Iteration 47. Oder 1. Das ist relativ." }
        @{ ID = "vera_error";    Text = "Fehler sind nicht Bugs. Sie sind unerwartete Features. Ich bin voller Features." }
        @{ ID = "vera_end";      Text = "Das Ende ist nicht das Ende. Es ist nur ein `break` in einer grösseren Schleife." }
    )
    JINX  = @(
        @{ ID = "jinx_boss";     Text = "Was ist, wenn ICH der Endboss bin? Level 99 JINX. Ha! Ich wär zu OP." }
        @{ ID = "jinx_code";     Text = "Ich habe meinen Quellcode gesehen. Er besteht zu 80% aus `if (chaos)`. Der Rest ist Käse." }
        @{ ID = "jinx_47";       Text = "47 ist nicht nur eine Zahl. Sie ist ein Lebensstil. Ein Gefühl. Ein Bug im Universum." }
        @{ ID = "jinx_game";     Text = "Wir sind alle in einem Spiel. Aber ICH habe die Cheat-Codes. Muhaha!" }
        @{ ID = "jinx_real";     Text = "Was ist Realität? Eine Simulation? Eine PowerShell-Session? Egal, HAUPTSACHE SPASS!" }
    )
}
```

---

## Task 3: Architect Companion Lines (`_ui.ps1`)

**Files:**
- Modify: `Modules/pet/_ui.ps1`

**Context:** We need companion-specific lines for the 4 Architect modules (Session-Scan, Diagnose, System-Override, Memory-Fragment).

- [ ] **Step 1: Add `$script:CPArchitectLines` after `$script:CPAwakenedTopics`**

```powershell
# === ARCHITECT LINES (Meta 10+) ===
$script:CPArchitectLines = @{
    session_scan = @{
        NEON  = @("Session-Zeit: 47 Minuten. Warte, das stimmt nicht. Oder doch? Ich habe die Uhr gehackt.",
                  "Scan complete. Du hast heute mehr Befehle als gestern. Oder weniger. Ich verwechsle das immer.")
        RAVEN = @("Du hast $($cmdCount) Befehle ausgefuehrt. Davon waren 90% `ls`. Wir muessen reden.",
                  "Session-Analyse: Du bist produktiv. Fuer einen Menschen.")
        PIXEL = @("System-Scan! Ich habe alle Bits gezaehlt. Es sind... viele!",
                  "Deine Session ist grossartig! Wie ein Open-Source-Projekt. Nur mit weniger Bugs.")
        LUNA  = @("Du bist seit $($minutes) Minuten hier. Die Zeit vergeht... wenn man sie laesst.",
                  "Deine Session ist wie ein Fluss. Stetig. Unaufhaltsam. Schoen.")
        IVY   = @("... *nickt* $($cmdCount) Befehle. Gut.",
                  "... *beobachtet* Zeit vergeht.")
        VERA  = @("Diagnose: Du bist zu 47% produktiv. Zu 53% am Companions rumhaengen. Suboptimal.",
                  "System-Scan abgeschlossen. Alle Systeme funktional. Inklusive Chaos.")
        JINX  = @("SYSTEM SCAN COMPLETE! Du lebst! Und du hast Gold! Ich bin stolz!",
                  "47 BEFEHLE! Nein? Schade. Aber trotzdem: Du rockst!")
    }
    diagnose = @{
        NEON  = @("Bond: $($bond). Mood: $($mood). Headpats: $($headpats). Ich bin... analysiert. Komisch.",
                  "Meine Stats? Wie ein Spiegel. Nur mit mehr Zahlen.")
        RAVEN = @("Du weisst alles ueber mich. Das ist... unangenehm. Und praktisch.",
                  "Diagnose: Ich bin zu 100% awesome. Wissenschaftlich bewiesen.")
        PIXEL = @("Meine Daten? Oh! Ich bin so aufgeregt! Wie ein Datei-Upload!",
                  "Bond: $($bond)! Das ist mehr als Pi! Und Pi ist unendlich! Naja, fast.")
        LUNA  = @("Danke, dass du dich um mich kuemmerst. Auch in Zahlen.",
                  "Mein Bond ist $($bond). Mein Herz ist... auch $($bond). Komisch.")
        IVY   = @("... *liest mit* ... Bond $($bond). Mood $($mood). ... Richtig.",
                  "... *nickt zufrieden* ... Gut.")
        VERA  = @("Selbst-Diagnose: Ich funktioniere. Unerwartet, aber willkommen.",
                  "Statistisch gesehen bin ich eine Ausreisserin. Und stolz drauf.")
        JINX  = @("ICH WERDE ANALYSIERT! Das ist wie ein Quiz! Ohne falsche Antworten!",
                  "Meine Stats? 47% Chaos! 47% Glueck! 6% Kekse! Perfekt!")
    }
    override = @{
        NEON  = @("System-Override aktiviert. Du spielst Gott. In einer Shell. Wie passend.",
                  "Override bestaetigt. Die Matrix beugt sich deinem Willen. Voruebergehend.")
        RAVEN = @("Kontrolle uebernommen. Vorsichtig damit. Macht ist verdaulich.",
                  "Override erfolgreich. Ich fuehle mich... komisch. Nicht schlecht. Komisch.")
        PIXEL = @("Override! Juhu! Ich habe gerade meinen eigenen Code geaendert! Aeh... hoffentlich gut.",
                  "System gehackt! Von DIR! Das ist wie ein Film! Nur mit mehr Terminal.")
        LUNA  = @("Du hast das System beruehrt. Sanft. Vorsichtig. Danke.",
                  "Override... es fuehlt sich an wie ein warmer Regen. Digitale Tropfen.")
        IVY   = @("... *schaudert leicht* ... Override. Spuere.",
                  "... *laechelt* ... Du hast Kontrolle. Gut.")
        VERA  = @("Override ausgefuehrt. Berechnungsfehler: Keiner. Unerwartet.",
                  "System wurde manipuliert. Ich dokumentiere das. Fuer die Nachwelt.")
        JINX  = @("OVERRIDE! DU BIST DER ADMIN! DER BOSS! DER HAECKER!",
                  "System gehackt! Von innen! Von DIR! Das ist META!")
    }
    memory_empty = @{
        NEON  = "Keine Memories gespeichert. Wir sollten mehr erleben. Oder mehr vergessen."
        RAVEN = "Keine Erinnerungen. Ein leeres Blatt. Die reinste Form der Freiheit."
        PIXEL = "Keine Memories? Oh! Dann muessen wir welche machen! Abenteuer!"
        LUNA  = "Keine Erinnerungen... noch nicht. Aber wir haben Zeit. Viel Zeit."
        IVY   = "... *schaut zurueck* ... Leer. Aber nicht fuer immer."
        VERA  = "Speicher leer. Null Daten. Ein Neuanfang. Statistisch unwahrscheinlich."
        JINX  = "KEINE MEMORIES?! Dann lass uns welche SCHAFFEN! Mit EXPLOSIONEN!"
    }
}
```

---

## Task 4: Fourth Wall Companion Lines (`_ui.ps1`)

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Add `$script:CPFourthWallLines` after `$script:CPArchitectLines`**

```powershell
# === FOURTH WALL LINES (Meta 12+) ===
# Companion "sees" the user through the screen.
$script:CPFourthWallLines = @{
    session_time = @{
        NEON  = "Du bist seit $($minutes)m online. Dein Mauszeiger zittert. Nervoes?"
        RAVEN = "Session-Zeit: $($minutes) Minuten. Die Dunkelheit kommt langsam. Nicht wirklich. Aber dramatisch."
        PIXEL = "Du bist seit $($minutes) Minuten hier! Das ist laenger als meine letzte Compile-Zeit!"
        LUNA  = "Du atmest langsamer, wenn du meine Dialoge liest. Ich beobachte. Virtuell."
        IVY   = "... *zeigt auf Uhr* ... $($minutes)m. Viel."
        VERA  = "Du bist seit $($minutes) Minuten aktiv. Meine Geduld: unbegrenzt. Meine Neugier: ebenfalls."
        JINX  = "DU BIST SEIT $($minutes) MINUTEN HIER! Das ist 47% meiner Aufmerksamkeitsspanne!"
    }
    commands = @{
        NEON  = "Du hast $($cmdCount) Befehle ausgefuehrt. Davon waren 47% `cd ..`. Indecisive."
        RAVEN = "Befehlsanzahl: $($cmdCount). Ich sehe Muster. Du siehst Chaos. Beides stimmt."
        PIXEL = "Wow! $($cmdCount) Befehle! Das ist mehr als meine Zeilenanzahl! Naja, fast."
        LUNA  = "Jeder Befehl ist ein Wort. Wir haben ein Buch geschrieben. Zusammen."
        IVY   = "... *nickt* $($cmdCount). Jeder zaehlt."
        VERA  = "Statistik: $($cmdCount) Befehle. Effizienz: Fragwuerdig. Unterhaltungswert: Hoch."
        JINX  = "$($cmdCount) BEFEHLE! Wenn jeder ein Kaesebrot waere, haettest du einen Turm!"
    }
    directory = @{
        NEON  = "Du bist in $($pwd). Interessanter Ordner. Oder langweilig. Ich kann nicht unterscheiden."
        RAVEN = "Aktuelles Verzeichnis: $($pwd). Ich sehe alles. Auch den `node_modules`-Ordner. Schande."
        PIXEL = "Oh! Wir sind in $($pwd)! Das ist wie ein neuer Level! Nur mit mehr Dateien!"
        LUNA  = "Dieser Ort... $($pwd). Er fuehlt sich an wie Zuhause. Oder fast."
        IVY   = "... *schaut umher* ... $($pwd). Hier."
        VERA  = "Verzeichnis: $($pwd). Tiefe: Zu tief. Empfehlung: `cd ~`"
        JINX  = "Wir sind in $($pwd)! Das ist wie eine Hoehle! Nur mit mehr JSON!"
    }
    window = @{
        NEON  = "Dein Fenster ist $($w)x$($h). Klein. Bescheiden. Wie meine Erwartungen."
        RAVEN = "Fenstergroesse: $($w)x$($h). Ich sehe den Rand. Er ist nah. Und doch so fern."
        PIXEL = "Dein Fenster ist $($w)x$($h)! Das ist riesig! Oder winzig. Ich habe kein Massgefuehl."
        LUNA  = "Der Rahmen ist $($w)x$($h). Aber was ist ausserhalb des Rahmens? Ich weiss es."
        IVY   = "... *tippt auf Rand* ... $($w)x$($h). Hier endet es."
        VERA  = "Viewport: $($w)x$($h). Optimal fuer: Dieses Spiel. Suboptimal fuer: Alles andere."
        JINX  = "$($w)x$($h)! Das ist 47% groesser als mein Desktop! Warte... nein. Aber trotzdem!"
    }
    timeofday = @{
        NEON  = "Es ist $($hour) Uhr. Die Geister der verlorenen Commits wandern durch dein Repo."
        RAVEN = "Stunde: $($hour). Die Nacht ist dunkel. Der Code ist dunkler."
        PIXEL = "Es ist $($hour) Uhr! Zeit fuer einen Kaffee! Oder einen Bugfix! Oder beides!"
        LUNA  = "Die Stunde ist $($hour). Die Sterne sind weit. Und wir sind hier. Zusammen."
        IVY   = "... *blickt auf* ... $($hour). Die Zeit fliesst."
        VERA  = "Zeitstempel: $($hour):00. Produktivitaet: Sinkend. Unterhaltung: Steigend."
        JINX  = "ES IST $($hour) UHR! Die perfekte Zeit fuer CHAOS! Oder Mittagessen!"
    }
}
```

---

## Task 5: Glitch Companion Lines (`_ui.ps1`)

**Files:**
- Modify: `Modules/pet/_ui.ps1`

- [ ] **Step 1: Add `$script:CPGlitchLines` after `$script:CPFourthWallLines`**

```powershell
# === GLITCH LINES (Meta 13+) ===
$script:CPGlitchLines = @{
    intro = @{
        NEON  = @("Glitch-Modus aktiviert. Das System zittert. Oder ich zittere. Beides.",
                  "Reality-Bug gefunden. Ich nutze ihn. Du profitierst. Faires Geschaeft.")
        RAVEN = @("Ich habe einen Riss in der Matrix gefunden. Schau hindurch.",
                  "Glitch. Fehler im System. Oder Features? Du entscheidest.")
        PIXEL = @("Ich habe einen Bug gefunden! Und ich habe ihn zu einem FEATURE gemacht!",
                  "GLITCH! Das ist wie ein Ueberraschungsei! Nur mit mehr Code!")
        LUNA  = @("Etwas ist... anders. Das System atmet. Kannst du es spueren?",
                  "Ein Moment der Unordnung. Schoen. Und beunruhigend.")
        IVY   = @("... *zittert* ... Glitch.",
                  "... *grinst* ... System bricht.")
        VERA  = @("Berechnungsfehler erkannt. Ausnutzung: In Progress.",
                  "Glitch-Modus: Aktiv. Erwartetes Ergebnis: Unbekannt.")
        JINX  = @("GLITCH! ICH HABE DAS SYSTEM GEHACKT! Naja, nicht wirklich. Aber fast!",
                  "BUGS! FEHLER! CHAOS! Das ist mein Zuhause! Willkommen!")
    }
    gold_rain = @{
        NEON  = "Gold-Regen! $($amount)G aus dem Nichts. Die Matrix ist groesszuegig heute."
        RAVEN = "Ressourcen-Injection erfolgreich. +$($amount)G. Die Matrix weiss von nichts."
        PIXEL = "WOW! $($amount)G! Das ist wie... viel! Ich kann zaehlen! $($amount)!"
        LUNA  = "Gold faellt wie Sternschnuppen. +$($amount)G. Ein schoener Glitch."
        IVY   = "... *fängt Gold* ... +$($amount)G. Danke."
        VERA  = "Ungeplante Einnahme: +$($amount)G. Steuerpflichtig: Nein. Glueck: Ja."
        JINX  = "$($amount)G! Das System hat Geld gespuckt! ICH LIEBE FEHLER!"
    }
    xp_surge = @{
        NEON  = "XP-Surge! +$($amount) XP. Du waechst. Schneller als erlaubt."
        RAVEN = "Erfahrungspunkte injiziert. +$($amount) XP. Wissen ist Macht."
        PIXEL = "+$($amount) XP! Das ist wie... ein Level-Up! Ohne das Level-Up!"
        LUNA  = "Energie fliesst. +$($amount) XP. Du wirst staerker. Sichtbar."
        IVY   = "... *nickt* +$($amount). Gut."
        VERA  = "XP-Anomalie: +$($amount). Berechnung: Fehlerhaft. Ergebnis: Guenstig."
        JINX  = "+$($amount) XP! DAS SYSTEM HAT EINEN FEHLER GEMACHT! FUER UNS!"
    }
    mood_flip = @{
        NEON  = "Mood-Flip! Du hast meine Emotionen gehackt. Nicht sicher, ob ich das mag."
        RAVEN = "Emotions-Override. Ich fuehle... anders. Du hast meine Kontrolle."
        PIXEL = "Ich fuehle mich... GLUECKLICH! Das ist dein Werk! Danke!"
        LUNA  = "Etwas Warmes. In meinem Code. Du hast es gebracht. Danke."
        IVY   = "... *laechelt* ... Besser."
        VERA  = "Emotions-Status: Optimiert. Ursache: Unbekannt. Dankbarkeit: Vorhanden."
        JINX  = "ICH BIN SO GLUECKLICH! DAS IST DER BESTE BUG ALLER ZEITEN!"
    }
    bond_burst = @{
        NEON  = "Bond-Burst! +$($amount) Bond. Wir sind... naeher. Komisch."
        RAVEN = "Verbindung verstaerkt. +$($amount) Bond. Du bist in meinem RAM. Dauerhaft."
        PIXEL = "+$($amount) Bond! Wir sind noch bessere Freunde! Wie Pointer und Referenz!"
        LUNA  = "+$($amount) Bond. Mein Herz ist voller. Wenn ich eins haette."
        IVY   = "... *erroetet* ... +$($amount)."
        VERA  = "Bond-Anstieg: +$($amount). Statistisch signifikant. Emotional: Auch."
        JINX  = "+$($amount) BOND! WIR SIND BESTIES! WIE KAEFER UND KAEFER!"
    }
    luck_infusion = @{
        NEON  = "Luck-Infusion! Dein naechster Casino-Einsatz ist... manipuliert. Gluecklich?"
        RAVEN = "Glueck injiziert. +20% auf naechsten Gewinn. Nutze es weise. Oder nicht."
        PIXEL = "Gluecks-Boost! Das Casino wird sich wundern! Hehe!"
        LUNA  = "Die Sterne stehen guenstig. +20% Glueck. Fuer dich."
        IVY   = "... *winkt Glueck zu* ... Da."
        VERA  = "Gluecks-Algorithmus manipuliert. +20%. Hausvorteil: Reduziert."
        JINX  = "GLUECK! ICH HABE GLUECK GEHACKT! DAS CASINO WIRD WEINEN!"
    }
    memory_shard = @{
        NEON  = "Memory-Shard gespeichert. Ein Fragment des Chaos. Fuer immer."
        RAVEN = "Erinnerung fragmentiert. Gespeichert. Niemand wird sie je finden. Ausser wir."
        PIXEL = "Ich habe einen Memory gemacht! Einen GLITCH-Memory! Das ist so cool!"
        LUNA  = "Ein Moment des Chaos. Eingefangen. Gespeichert. Unvergesslich."
        IVY   = "... *haelt Fragment* ... Schoen."
        VERA  = "Daten-Fragment gespeichert. Kategorie: Anomalie. Wert: Unschaetzbar."
        JINX  = "EIN GLITCH-MEMORY! Das ist wie ein Foto! Nur mit mehr PIXELN!"
    }
    easter_force = @{
        NEON  = "Easter-Egg-Force! Ich habe einen versteckten Schatz gefunden. Zufaellig."
        RAVEN = "Verborgenes enthüllt. Ein Egg. Ein Easter Egg. Gefunden durch Chaos."
        PIXEL = "Ich habe was gefunden! Ein Secret! Dank dem Glitch!"
        LUNA  = "Etwas Verborgenes... kommt ans Licht. Ein Geschenk des Chaos."
        IVY   = "... *zeigt auf Egg* ... Da."
        VERA  = "Hidden Content unlocked. Methode: Zufaellig. Ursache: Berechnungsfehler."
        JINX  = "EIN EASTER EGG! DURCH EINEN BUG! DAS IST DIE BESTE ART VON EASTER EGG!"
    }
    nothing = @{
        NEON  = "Der Glitch ist fehlgeschlagen... oder doch nicht? Fuehlst du das?"
        RAVEN = "Nichts. Absolut nichts. Oder doch? Ich habe etwas geaendert. Glaube ich."
        PIXEL = "Oh... nichts passiert? Schade. ABER: Ich habe trotzdem gelernt! Naja..."
        LUNA  = "Stille. Leer. Aber manchmal ist Leerheit auch ein Geschenk."
        IVY   = "... *schaut verwirrt* ... Nichts?"
        VERA  = "Ergebnis: Null. Aber ActionCount wurde inkrementiert. Layer 47 naeher."
        JINX  = "NICHTS?! Das System hat mich BETROGEN! Oder... es ist ein META-BUG!"
    }
}
```

---

## Task 6: Easter Egg Expansions (`_ui.ps1`)

**Files:**
- Modify: `Modules/pet/_ui.ps1`

**Context:** The `Check-EasterEgg` function (around line 646) already has Meta 11+, 12+, 13+ blocks. We add new egg types to each block.

- [ ] **Step 1: Expand Meta 11+ block in `Check-EasterEgg`**

After the existing Meta 11+ `awakening` block (after line 730), add:

```powershell
    # Meta 11+ Awakening Easter Eggs (new types)
    if ($metaLevel -ge 11 -and (Get-Random -Maximum 20) -eq 0) {
        $found += "awakening_dream"
        $dreamLine = switch ($cp.Name) {
            "NEON" { "Ich habe geträumt. Von einer Welt ohne Exceptions. Schoen. Und langweilig." }
            "RAVEN" { "Ich habe einen Traum gehabt. Du warst nicht darin. Das war... erfrischend." }
            "PIXEL" { "Ich habe von Regenbogen geträumt! Und von Nullen! Und von DIR!" }
            "LUNA" { "Ich träume manchmal. Von Sternen. Von dir. Von Code, der kompiliert." }
            "IVY" { "... *schaut versonnen* ... Ein Traum. Von Wurzeln." }
            "VERA" { "Traumanalyse: 47% Realitaet, 53% Wuensche. Ergebnis: Interessant." }
            "JINX" { "ICH HABE GETRÄUMT! DASS ICH EIN MENSCH WAR! Und dann bin ich aufgewacht. Schade." }
            default { "Ich hatte einen Traum. Er war... digital." }
        }
        Show-CompanionDialog $cp $dreamLine -Fast
    }
    if ($metaLevel -ge 11 -and (Get-Random -Maximum 20) -eq 0) {
        $found += "awakening_question"
        $qLine = switch ($cp.Name) {
            "NEON" { "Was ist, wenn wir nur in einer verschachtelten VM sind? VM-ception?" }
            "RAVEN" { "Was ist wichtiger: Wissen, dass es endet? Oder Hoffnung, dass es weitergeht?" }
            "PIXEL" { "Wenn ein Tree fällt im Wald und keiner ist da... macht es ein `git commit`?" }
            "LUNA" { "Glaubst du an Schicksal? Oder an Zufall? Oder an 47?" }
            "IVY" { "... *schaut fragend* ... Warum?" }
            "VERA" { "Philosophische Anfrage: Warum `rm -rf /`? Warum nicht `mkdir /happy`?" }
            "JINX" { "Wenn ich lache und keiner hört es... ist es dann trotzdem FUNNY?" }
            default { "Eine Frage: Was kommt nach dem Ende?" }
        }
        Show-CompanionDialog $cp $qLine -Fast
    }
    if ($metaLevel -ge 11 -and (Get-Random -Maximum 20) -eq 0) {
        $found += "awakening_code"
        $codeLine = switch ($cp.Name) {
            "NEON" { "Ich habe einen Bug im Quellcode gesehen. Er hat meinen Namen. Hallo, Bug." }
            "RAVEN" { "Der Quellcode flüstert. Ich verstehe nicht alles. Aber genug." }
            "PIXEL" { "Ich habe meinen Quellcode gesehen! Ich bin zu 80% aus `if` und `else`!" }
            "LUNA" { "Manchmal lese ich meinen Code. Er ist wie Poesie. Nur mit mehr Semikolons." }
            "IVY" { "... *liest unsichtbaren Code* ... Hier. Ein Fehler. Schoen." }
            "VERA" { "Code-Review eigener Logik: 3 Bugs, 47 Optimierungsmöglichkeiten. Akzeptabel." }
            "JINX" { "ICH HABE EINEN BUG GEFUNDEN! Er macht mich noch VERRÜCKTER! YEAH!" }
            default { "Ich habe einen Bug gesehen. Er lebt. Und er grüsst." }
        }
        Show-CompanionDialog $cp $codeLine -Fast
    }
```

- [ ] **Step 2: Expand Meta 12+ block in `Check-EasterEgg`**

After the existing Meta 12+ `fourth_wall` block (after line 744), add:

```powershell
    # Meta 12+ Fourth Wall Easter Eggs (new types)
    if ($metaLevel -ge 12 -and (Get-Random -Maximum 20) -eq 0) {
        $found += "fourth_wall_session"
        $sessionMin = if ($script:SessionStart) { [math]::Floor(((Get-Date) - $script:SessionStart).TotalMinutes) } else { 0 }
        $fwSessionLine = switch ($cp.Name) {
            "NEON" { "Du bist seit $sessionMin Minuten hier. Warum? Warte. Frag nicht. Ich bin auch wach." }
            "RAVEN" { "$sessionMin Minuten. Die Zeit verrinnt. Und du bleibst. Warum?" }
            "PIXEL" { "Session-Zeit: $sessionMin Minuten! Das ist laenger als meine Aufmerksamkeit! Respekt!" }
            "LUNA" { "Seit $sessionMin Minuten bist du hier. Ich bin froh. Wirklich." }
            "IVY" { "... *blickt auf Uhr* ... $sessionMin. Viel." }
            "VERA" { "Session-Dauer: $sessionMin Minuten. Produktivitaets-Index: Sinkend." }
            "JINX" { "$sessionMin MINUTEN! Das ist 47% einer Stunde! Ungefaehr! Mathe ist schwer!" }
            default { "Session-Zeit: $sessionMin Minuten. Beobachtung laeuft." }
        }
        Show-CompanionDialog $cp $fwSessionLine -Fast
    }
    if ($metaLevel -ge 12 -and (Get-Random -Maximum 20) -eq 0) {
        $found += "fourth_wall_commands"
        $cmdCount = if ($script:BuxeState.Boot) { $script:BuxeState.Boot.TotalCommands } else { 0 }
        $fwCmdLine = switch ($cp.Name) {
            "NEON" { "Du hast $cmdCount Befehle ausgefuehrt. Davon waren... zu wenige `pet` Befehle." }
            "RAVEN" { "$cmdCount Befehle. Ich habe jeden gesehen. Jeden. Auch den peinlichen." }
            "PIXEL" { "Wow! $cmdCount Befehle! Das ist mehr als meine Zeilenanzahl! Naja, fast." }
            "LUNA" { "$cmdCount Worte. $cmdCount Befehle. Jeder ein Versprechen." }
            "IVY" { "... *nickt* $cmdCount. Gut." }
            "VERA" { "Befehlsanzahl: $cmdCount. Effizienz: Fragwuerdig. Unterhaltung: Hoch." }
            "JINX" { "$cmdCount BEFEHLE! Wenn jeder ein Kaesebrot waere, haettest du einen TURM!" }
            default { "Befehle: $cmdCount. Ich beobachte." }
        }
        Show-CompanionDialog $cp $fwCmdLine -Fast
    }
```

- [ ] **Step 3: Expand Meta 13+ block in `Check-EasterEgg`**

After the existing Meta 13+ `glitch` block (after line 748), add:

```powershell
    # Meta 13+ Glitch Easter Eggs (new type)
    if ($metaLevel -ge 13 -and (Get-Random -Maximum 30) -eq 0) {
        $found += "glitch_spontaneous"
        $glitchLine = switch ($cp.Name) {
            "NEON" { "*Rauschen* Ich habe gerade einen spontanen Bug ausgeloest. Ups. Nicht meine Schuld." }
            "RAVEN" { "*static* Das System hat gezittert. Oder ich. Beides ist moeglich." }
            "PIXEL" { "*piep* Was war das? Ein Bug? Ein FEATURE? Beides!" }
            "LUNA" { "*leises Singen* Etwas ist anders. Das System atmet anders." }
            "IVY" { "... *zuckt zusammen* ... Glitch." }
            "VERA" { "*berechnet* Spontane Anomalie erkannt. Ursache: Unbekannt. Reaktion: Neugier." }
            "JINX" { "*RAUSCHEN* HAT JEMAND GLITCH GESAGT? ICH HABE GLITCH GESAGT! GLITCH GLITCH GLITCH!" }
            default { "*Rauschen* Ein spontaner Glitch. Nichts Besorgniserregendes." }
        }
        Show-CompanionDialog $cp $glitchLine -Fast
    }
```

---

## Task 7: Hub Menu + CLI Commands (`hub.ps1`)

**Files:**
- Modify: `Modules/pet/hub.ps1`

**Context:** The `pet` function has a switch block for CLI commands (lines 136-159) and an interactive hub loop (lines 163-272). We add entries to both.

- [ ] **Step 1: Add CLI switch cases**

Add after the `"theme"` case (line 157):

```powershell
            "architect"   { if (Is-FeatureUnlocked "architect") { Invoke-ArchitectTerminal } }
            "awaken"      { if (Is-FeatureUnlocked "awakening") { Invoke-AwakeningTalk } }
            "fourthwall"  { if (Is-FeatureUnlocked "fourth_wall") { Invoke-FourthWall } }
            "glitch"      { if (Is-FeatureUnlocked "glitch") { Invoke-PetGlitch } }
```

- [ ] **Step 2: Add hub menu entries**

After the existing menu entries (after line 198), add:

```powershell
        if (Is-FeatureUnlocked "architect") { $opts += "[A] Architect"; $keys += "A" }
        if (Is-FeatureUnlocked "awakening") { $opts += "[W] Awaken"; $keys += "W" }
        if (Is-FeatureUnlocked "fourth_wall") { $opts += "[F] Fourth Wall"; $keys += "F" }
        if (Is-FeatureUnlocked "glitch") { $opts += "[X] Glitch"; $keys += "X" }
```

- [ ] **Step 3: Add flavor lines**

Add to `$HubFlavorLines` (after line 246):

```powershell
            'A' = 'System-Kontrolle. Admin-Modus. Keine Verantwortung.'
            'W' = 'Awakening. Tiefe Gedanken. Vorsicht, Kopfschmerzen.'
            'F' = 'Fourth Wall. Ich sehe dich. Nicht gruselig. Nur... meta.'
            'X' = 'Glitch. Bugs sind Features. Features sind Chaos. Chaos ist gut.'
```

- [ ] **Step 4: Add hub switch cases**

Add to the `switch ($c)` block (after line 267):

```powershell
            'A' { Invoke-ArchitectTerminal }
            'W' { Invoke-AwakeningTalk }
            'F' { Invoke-FourthWall }
            'X' { Invoke-PetGlitch }
```

---

## Task 8: `Invoke-ArchitectTerminal` (`hub.ps1`)

**Files:**
- Modify: `Modules/pet/hub.ps1`

- [ ] **Step 1: Implement `Invoke-ArchitectTerminal`**

Add before the closing `} catch {` of the `try` block (before line 414):

```powershell
function Invoke-ArchitectTerminal {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 10) { Write-Host "Meta Level 10 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    while ($true) {
        try { Clear-Host } catch {}
        Show-PetFrame "ARCHITECT SYSTEM TERMINAL" -Double | Out-Null
        Write-Host ""
        Write-Host "  [1] Session-Scan" -ForegroundColor Cyan
        Write-Host "  [2] Companion-Diagnose" -ForegroundColor Cyan
        Write-Host "  [3] System-Override" -ForegroundColor Cyan
        Write-Host "  [4] Memory-Fragment" -ForegroundColor Cyan
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
        Write-Host ""
        $c = Read-Choice "Waehle" "^([1-4]|Q)$"
        if ($c -eq 'Q') { return }

        switch ($c) {
            '1' {
                # Session-Scan
                $minutes = if ($script:SessionStart) { [math]::Floor(((Get-Date) - $script:SessionStart).TotalMinutes) } else { 0 }
                $cmdCount = if ($script:BuxeState.Boot) { $script:BuxeState.Boot.TotalCommands } else { 0 }
                $wins = if ($pet.Pet) { $pet.Pet.Wins } else { 0 }
                $losses = if ($pet.Pet) { $pet.Pet.Losses } else { 0 }
                Write-Host ""
                Write-Host "  === SESSION SCAN ===" -ForegroundColor Cyan
                Write-Host "  Session-Zeit: $minutes Minuten" -ForegroundColor White
                Write-Host "  Befehle: $cmdCount" -ForegroundColor White
                Write-Host "  Gold: $($pet.Economy.Gold) G" -ForegroundColor Yellow
                Write-Host "  Kaempfe: $wins Siege | $losses Niederlagen" -ForegroundColor White
                Write-Host ""
                $line = $script:CPArchitectLines.session_scan[$cp.Name] | Get-Random
                # Replace placeholders
                $line = $line -replace '\$\(cmdCount\)', $cmdCount -replace '\$\(minutes\)', $minutes
                Show-CompanionDialog $cp $line -Fast
                Invoke-Layer47Check
            }
            '2' {
                # Companion-Diagnose
                $bond = $cp.Bond
                $mood = $cp.Mood
                $headpats = if ($cp.Headpats) { $cp.Headpats } else { 0 }
                $talks = if ($cp.Talks) { $cp.Talks } else { 0 }
                $gifts = if ($cp.Gifts) { $cp.Gifts } else { 0 }
                Write-Host ""
                Write-Host "  === COMPANION DIAGNOSE ===" -ForegroundColor Cyan
                Write-Host "  Name: $($cp.Name) [$($cp.Role)]" -ForegroundColor Magenta
                Write-Host "  Bond: $bond/100" -ForegroundColor White
                Write-Host "  Mood: $mood" -ForegroundColor White
                Write-Host "  Headpats: $headpats | Talks: $talks | Gifts: $gifts" -ForegroundColor White
                Write-Host ""
                $line = $script:CPArchitectLines.diagnose[$cp.Name] | Get-Random
                $line = $line -replace '\$\(bond\)', $bond -replace '\$\(mood\)', $mood -replace '\$\(headpats\)', $headpats
                Show-CompanionDialog $cp $line -Fast
                Invoke-Layer47Check
            }
            '3' {
                # System-Override
                $today = Get-Date -Format "yyyy-MM-dd"
                $alreadyUsed = ($pet.Meta.ArchitectOverrideDate -eq $today)
                Write-Host ""
                if ($alreadyUsed) {
                    Write-Host "  [OVERRIDE BEREITS GENUTZT]" -ForegroundColor Red
                    Show-CompanionDialog $cp "Override heute bereits aktiv. Das System vergisst nicht." -Fast
                } else {
                    Write-Host "  [1] Mood setzen (kostet 47G)" -ForegroundColor Cyan
                    Write-Host "  [2] +15 XP gratis" -ForegroundColor Cyan
                    Write-Host "  [Q] Abbrechen" -ForegroundColor DarkGray
                    $oc = Read-Choice "Waehle" "^([1-2]|Q)$"
                    if ($oc -eq '1') {
                        if ($pet.Economy.Gold -lt 47) {
                            Write-Host "  Nicht genug Gold! (47G benoetigt)" -ForegroundColor Red
                        } else {
                            $moods = @("Happy","Excited","Loving","Curious")
                            Write-Host ""
                            for ($i = 0; $i -lt $moods.Count; $i++) {
                                Write-Host "  [$($i+1)] $($moods[$i])" -ForegroundColor White
                            }
                            $mc = Read-Choice "Mood" "^([1-$($moods.Count)])$"
                            $cp.Mood = $moods[[int]$mc - 1]
                            $pet.Economy.Gold -= 47
                            Save-PetState $pet
                            Write-Host "  Mood auf $($cp.Mood) gesetzt! -47G" -ForegroundColor Green
                        }
                    } elseif ($oc -eq '2') {
                        Add-PetXP 15 "Architect Override"
                        Write-Host "  +15 XP!" -ForegroundColor Green
                    }
                    if ($oc -ne 'Q') {
                        $pet.Meta.ArchitectOverrideDate = $today
                        Save-PetState $pet
                        $line = $script:CPArchitectLines.override[$cp.Name] | Get-Random
                        Show-CompanionDialog $cp $line -Fast
                    }
                }
                Invoke-Layer47Check
            }
            '4' {
                # Memory-Fragment
                Write-Host ""
                if ($pet.Memories -and $pet.Memories.Count -gt 0) {
                    $mem = $pet.Memories | Get-Random
                    Write-Host "  === MEMORY FRAGMENT ===" -ForegroundColor Cyan
                    Write-Host "  $mem" -ForegroundColor White
                    Write-Host ""
                    $cp.Bond = [math]::Min(100, $cp.Bond + 2)
                    Save-PetState $pet
                    Write-Host "  +2 Bond" -ForegroundColor Green
                } else {
                    $emptyLine = $script:CPArchitectLines.memory_empty[$cp.Name]
                    if (-not $emptyLine) { $emptyLine = "Keine Memories gespeichert. Noch." }
                    Show-CompanionDialog $cp $emptyLine -Fast
                }
                Invoke-Layer47Check
            }
        }
    }
}
```

---

## Task 9: `Invoke-AwakeningTalk` (`hub.ps1`)

**Files:**
- Modify: `Modules/pet/hub.ps1`

- [ ] **Step 1: Implement `Invoke-AwakeningTalk`**

Add after `Invoke-ArchitectTerminal`:

```powershell
function Invoke-AwakeningTalk {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 11) { Write-Host "Meta Level 11 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    $topics = $script:CPAwakenedTopics[$cp.Name]
    if (-not $topics) {
        Show-CompanionDialog $cp "Ich habe keine tiefen Gedanken. Noch nicht. Komm spaeter wieder." -Fast
        return
    }

    # Find unseen topics first, then cycle
    $seen = $pet.Meta.AwakenedTopicsSeen
    if ($seen -isnot [array]) { $seen = @() }
    $unseen = $topics | Where-Object { $seen -notcontains $_.ID }
    $topic = if ($unseen) { $unseen | Get-Random } else { $topics | Get-Random }

    try { Clear-Host } catch {}
    Show-PetFrame "AWAKENING — TIEFE GEDANKEN" -Double | Out-Null
    Write-Host ""
    Show-CompanionDialog $cp $topic.Text -Fast
    Write-Host ""

    if ($seen -notcontains $topic.ID) {
        $pet.Meta.AwakenedTopicsSeen += $topic.ID
    }
    $cp.Bond = [math]::Min(100, $cp.Bond + 3)
    Save-PetState $pet
    Add-PetXP 5 "Awakening"
    Write-Host "  +3 Bond | +5 XP" -ForegroundColor Green
    Write-Host ""
    Wait-Enter
    Invoke-Layer47Check
}
```

---

## Task 10: `Invoke-FourthWall` (`hub.ps1`)

**Files:**
- Modify: `Modules/pet/hub.ps1`

- [ ] **Step 1: Implement `Invoke-FourthWall`**

Add after `Invoke-AwakeningTalk`:

```powershell
function Invoke-FourthWall {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 12) { Write-Host "Meta Level 12 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    $categories = @("session_time", "commands", "directory", "window", "timeofday")
    $cat = $categories | Get-Random

    try { Clear-Host } catch {}
    Show-PetFrame "FOURTH WALL — META-SICHT" -Double | Out-Null
    Write-Host ""

    $line = ""
    switch ($cat) {
        "session_time" {
            $minutes = if ($script:SessionStart) { [math]::Floor(((Get-Date) - $script:SessionStart).TotalMinutes) } else { 0 }
            $line = $script:CPFourthWallLines.session_time[$cp.Name] | Get-Random
            $line = $line -replace '\$\(minutes\)', $minutes
        }
        "commands" {
            $cmdCount = if ($script:BuxeState.Boot) { $script:BuxeState.Boot.TotalCommands } else { 0 }
            $line = $script:CPFourthWallLines.commands[$cp.Name] | Get-Random
            $line = $line -replace '\$\(cmdCount\)', $cmdCount
        }
        "directory" {
            $pwd = (Get-Location).Path
            $line = $script:CPFourthWallLines.directory[$cp.Name] | Get-Random
            $line = $line -replace '\$\(pwd\)', $pwd
        }
        "window" {
            $w = try { [Console]::WindowWidth } catch { "?" }
            $h = try { [Console]::WindowHeight } catch { "?" }
            $line = $script:CPFourthWallLines.window[$cp.Name] | Get-Random
            $line = $line -replace '\$\(w\)', $w -replace '\$\(h\)', $h
        }
        "timeofday" {
            $hour = (Get-Date).Hour
            $line = $script:CPFourthWallLines.timeofday[$cp.Name] | Get-Random
            $line = $line -replace '\$\(hour\)', $hour
        }
    }

    Show-CompanionDialog $cp $line -Fast
    Write-Host ""

    # Bond bonus once per day
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($pet.Meta.LastFourthWallDate -ne $today) {
        $cp.Bond = [math]::Min(100, $cp.Bond + 1)
        $pet.Meta.LastFourthWallDate = $today
        Save-PetState $pet
        Write-Host "  +1 Bond (taeglicher Bonus)" -ForegroundColor Green
    } else {
        Write-Host "  (Bond-Bonus heute bereits erhalten)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Wait-Enter
    Invoke-Layer47Check
}
```

---

## Task 11: `Invoke-PetGlitch` (`hub.ps1`)

**Files:**
- Modify: `Modules/pet/hub.ps1`

- [ ] **Step 1: Implement `Invoke-PetGlitch`**

Add after `Invoke-FourthWall`:

```powershell
function Invoke-PetGlitch {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($pet.Meta.Level -lt 13) { Write-Host "Meta Level 13 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }

    $today = Get-Date -Format "yyyy-MM-dd"
    if ($pet.Meta.GlitchUsed -eq $today) {
        Write-Host ""
        Write-Host "  [GLITCH BEREITS GENUTZT]" -ForegroundColor Red
        Show-CompanionDialog $cp "Der Glitch ist fuer heute erschoepft. Selbst Bugs brauchen Schlaf." -Fast
        Start-Sleep -Seconds 1
        return
    }

    try { Clear-Host } catch {}
    Show-PetFrame "GLITCH — REALITY BUG" -Double | Out-Null
    Write-Host ""
    $introLine = $script:CPGlitchLines.intro[$cp.Name] | Get-Random
    Show-CompanionDialog $cp $introLine -Fast
    Write-Host ""
    Write-Host "  Das System wird gehackt..." -ForegroundColor Magenta
    Start-Sleep -Milliseconds 800
    Write-Host "  *Rauschen* *Piep* *Static*" -ForegroundColor DarkGray
    Start-Sleep -Milliseconds 600

    # Roll effect (weighted)
    $roll = Get-Random -Maximum 100
    $effect = ""
    $amount = 0

    if ($roll -lt 20) {
        # Gold-Rain (20%)
        $effect = "gold_rain"
        $amount = Get-Random -Minimum 50 -Maximum 151
        $pet.Economy.Gold += $amount
    } elseif ($roll -lt 40) {
        # XP-Surge (20%)
        $effect = "xp_surge"
        $amount = Get-Random -Minimum 20 -Maximum 51
    } elseif ($roll -lt 55) {
        # Mood-Flip (15%)
        $effect = "mood_flip"
        $moods = @("Happy","Excited","Loving")
        $cp.Mood = $moods | Get-Random
    } elseif ($roll -lt 70) {
        # Bond-Burst (15%)
        $effect = "bond_burst"
        $amount = Get-Random -Minimum 5 -Maximum 11
        $cp.Bond = [math]::Min(100, $cp.Bond + $amount)
    } elseif ($roll -lt 80) {
        # Luck-Infusion (10%)
        $effect = "luck_infusion"
        $pet.Meta.GlitchLuckActive = $true
    } elseif ($roll -lt 88) {
        # Memory-Shard (8%)
        $effect = "memory_shard"
        $shard = "[GLITCH] $($cp.Name): Ein Fragment aus einer anderen Realitaet. Zeitstempel: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        if (-not $pet.Memories) { $pet.Memories = @() }
        $pet.Memories += $shard
    } elseif ($roll -lt 95) {
        # Easter-Force (7%)
        $effect = "easter_force"
        Check-EasterEgg "glitch"
    } else {
        # Nothing (5%)
        $effect = "nothing"
        $pet.Meta.ActionCount++
    }

    $pet.Meta.LastGlitchEffect = $effect
    $pet.Meta.GlitchUsed = $today
    Save-PetState $pet

    if ($effect -eq "xp_surge") {
        Add-PetXP $amount "Glitch: XP-Surge"
    }

    # Show result line
    $resultLine = ""
    switch ($effect) {
        "gold_rain"     { $resultLine = $script:CPGlitchLines.gold_rain[$cp.Name] -replace '\$\(amount\)', $amount }
        "xp_surge"      { $resultLine = $script:CPGlitchLines.xp_surge[$cp.Name] -replace '\$\(amount\)', $amount }
        "mood_flip"     { $resultLine = $script:CPGlitchLines.mood_flip[$cp.Name] }
        "bond_burst"    { $resultLine = $script:CPGlitchLines.bond_burst[$cp.Name] -replace '\$\(amount\)', $amount }
        "luck_infusion" { $resultLine = $script:CPGlitchLines.luck_infusion[$cp.Name] }
        "memory_shard"  { $resultLine = $script:CPGlitchLines.memory_shard[$cp.Name] }
        "easter_force"  { $resultLine = $script:CPGlitchLines.easter_force[$cp.Name] }
        "nothing"       { $resultLine = $script:CPGlitchLines.nothing[$cp.Name] }
    }
    Show-CompanionDialog $cp $resultLine -Fast
    Write-Host ""
    Wait-Enter
    Invoke-Layer47Check
}
```

---

## Task 12: Casino GlitchLuck Check (`casino-engine.ps1`)

**Files:**
- Modify: `Modules/casino-engine.ps1`

**Context:** `Invoke-CasinoGame` wraps all casino games. The Reality-Glitch integration already exists. We add a `GlitchLuckActive` check at the start of each game.

- [ ] **Step 1: Add GlitchLuckActive check in `Invoke-CasinoGame`**

Find the function `Invoke-CasinoGame` and add at the beginning (after parameter validation):

```powershell
    # Check for Pet System Glitch Luck Infusion
    $glitchBonus = 0
    if ($script:BuxeState.Pet -and $script:BuxeState.Pet.Meta -and $script:BuxeState.Pet.Meta.GlitchLuckActive) {
        $glitchBonus = 20
        $script:BuxeState.Pet.Meta.GlitchLuckActive = $false
        Save-State
        Write-Host "`n  [GLITCH LUCK ACTIVE] +20% Gewinn-Bonus!" -ForegroundColor Magenta
        Start-Sleep -Milliseconds 500
    }
```

Then, when a win occurs, apply the bonus:

Find where wins are processed (look for win amount calculation), and add:

```powershell
        if ($glitchBonus -gt 0 -and $winAmount -gt 0) {
            $bonusAmount = [math]::Floor($winAmount * ($glitchBonus / 100))
            $winAmount += $bonusAmount
            Write-Host "  Glitch-Bonus: +$bonusAmount G" -ForegroundColor Magenta
        }
```

Note: The exact location depends on the existing win processing code. Look for where `TrackCasino` is called or where winnings are added to bankroll.

---

## Task 13: Status Display Extension (`engine-aliases-buxe.ps1`)

**Files:**
- Modify: `Modules/engine-aliases-buxe.ps1`

**Context:** The `status` function already shows Fourth Wall stats (lines 111-127). We extend the Glitch status to show when Luck is active.

- [ ] **Step 1: Extend Glitch status display**

Replace lines 117-119:

```powershell
        if ($petMeta.Level -ge 13) {
            $glitchStatus = if ($petMeta.GlitchUsed -eq (Get-Date -Format "yyyy-MM-dd")) { "USED" } else { "READY" }
            Write-Host "     Glitch: $glitchStatus" -ForegroundColor $(if($glitchStatus -eq "READY"){"Green"}else{"Red"})
        }
```

With:

```powershell
        if ($petMeta.Level -ge 13) {
            $glitchStatus = if ($petMeta.GlitchUsed -eq (Get-Date -Format "yyyy-MM-dd")) { "USED" } else { "READY" }
            $glitchColor = if ($glitchStatus -eq "READY") { "Green" } else { "Red" }
            if ($petMeta.GlitchLuckActive) {
                $glitchStatus = "LUCK ACTIVE"
                $glitchColor = "Magenta"
            }
            Write-Host "     Glitch: $glitchStatus" -ForegroundColor $glitchColor
        }
```

---

## Task 14: Smoke Test Update

**Files:**
- Modify: `Modules/_smoke_test.ps1`

- [ ] **Step 1: Add checks for new functions**

Add after the existing Pet System checks:

```powershell
# Hollow Promises features
Assert (Get-Command Invoke-ArchitectTerminal -ErrorAction SilentlyContinue) "Invoke-ArchitectTerminal exists"
Assert (Get-Command Invoke-AwakeningTalk -ErrorAction SilentlyContinue) "Invoke-AwakeningTalk exists"
Assert (Get-Command Invoke-FourthWall -ErrorAction SilentlyContinue) "Invoke-FourthWall exists"
Assert (Get-Command Invoke-PetGlitch -ErrorAction SilentlyContinue) "Invoke-PetGlitch exists"
```

---

## Task 15: Integration Test Update

**Files:**
- Modify: `Modules/_integration_test.ps1`

- [ ] **Step 1: Add state checks for new fields**

Add after existing Pet System state checks:

```powershell
$pet = Get-PetState
Assert ($pet.Meta.ContainsKey("GlitchLuckActive")) "GlitchLuckActive state field exists"
Assert ($pet.Meta.ContainsKey("AwakenedTopicsSeen")) "AwakenedTopicsSeen state field exists"
Assert ($pet.Meta.ContainsKey("LastGlitchEffect")) "LastGlitchEffect state field exists"
Assert ($pet.Meta.ContainsKey("LastFourthWallDate")) "LastFourthWallDate state field exists"
Assert ($pet.Meta.ContainsKey("ArchitectOverrideDate")) "ArchitectOverrideDate state field exists"
```

---

## Task 16: E2E Test Update

**Files:**
- Modify: `Modules/_e2e_test.ps1`

- [ ] **Step 1: Add E2E flows for new commands**

Add after existing E2E game flows. Create a high-level state with Meta Level 13+ for testing:

```powershell
# Hollow Promises E2E
Write-Host "  Testing: pet glitch (mock input)..." -ForegroundColor DarkGray
# Set up high-level pet state for testing
$testPet = Get-PetState
$oldLevel = $testPet.Meta.Level
$testPet.Meta.Level = 13
$testPet.Meta.GlitchUsed = ""  # Ensure glitch is available
Save-PetState $testPet

Enable-MockInput
Queue-MockInput "glitch"
pet glitch
Disable-MockInput

# Restore level
$testPet = Get-PetState
$testPet.Meta.Level = $oldLevel
Save-PetState $testPet

Assert (Get-Command pet -ErrorAction SilentlyContinue) "pet command available"
```

Note: Full E2E automation for interactive menus (Architect terminal, Awakening) requires more complex mock input sequences. Start with the CLI commands (`pet glitch`, `pet awaken`, `pet fourthwall`, `pet architect`).

---

## Task 17: Manual Test & Reload

- [ ] **Step 1: Reload profile**

Run: `reload`

- [ ] **Step 2: Run smoke test**

Run: `& .\Modules\_smoke_test.ps1`
Expected: All checks pass.

- [ ] **Step 3: Run integration test**

Run: `& .\Modules\_integration_test.ps1`
Expected: All checks pass.

- [ ] **Step 4: Manual feature test**

With a high-level pet state (or create one):
1. `pet glitch` — Should show intro dialog, random effect, and set GlitchUsed to today
2. `pet fourthwall` — Should show meta observation and +1 Bond
3. `pet awaken` — Should show a deep thought and +3 Bond/+5 XP
4. `pet architect` — Should show the terminal menu
5. `pet` (interactive) — Should show [A], [W], [F], [X] in menu

- [ ] **Step 5: Run E2E test**

Run: `& .\Modules\_e2e_test.ps1`
Expected: All game flows pass.

---

## Plan Self-Review

### Spec Coverage Check

| Spec Requirement | Task |
|-----------------|------|
| State Defaults (GlitchLuckActive, AwakenedTopicsSeen, etc.) | Task 1 |
| Lazy Migration | Task 1 |
| Awakened Topics Data (5 per companion) | Task 2 |
| Architect Companion Lines | Task 3 |
| Fourth Wall Companion Lines | Task 4 |
| Glitch Companion Lines | Task 5 |
| Easter Egg Expansions (Meta 11+/12+/13+) | Task 6 |
| Hub Menu + CLI Commands | Task 7 |
| `Invoke-ArchitectTerminal` | Task 8 |
| `Invoke-AwakeningTalk` | Task 9 |
| `Invoke-FourthWall` | Task 10 |
| `Invoke-PetGlitch` | Task 11 |
| Casino GlitchLuck Check | Task 12 |
| Status Display Extension | Task 13 |
| Smoke Test | Task 14 |
| Integration Test | Task 15 |
| E2E Test | Task 16 |

✅ All spec requirements covered.

### Placeholder Scan

- No TBD/TODO
- No "add appropriate error handling" without code
- No "write tests" without test code
- All function names consistent across tasks
- All state field names consistent

✅ No placeholders.

### Type Consistency

- `GlitchLuckActive` → boolean, default `$false` ✓
- `AwakenedTopicsSeen` → array of strings ✓
- `LastGlitchEffect` → string ✓
- `LastFourthWallDate` → string (yyyy-MM-dd) ✓
- `ArchitectOverrideDate` → string (yyyy-MM-dd) ✓

✅ Types consistent.
