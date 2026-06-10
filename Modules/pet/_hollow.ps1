# BUXE_OS v24.x — HOLLOW PROMISES
# Companion lines and data for Meta Levels 10-13 features.
# Loaded after _ui.ps1

try {

# === AWAKENED TOPICS (Meta 11+) ===
$script:CPAwakenedTopics = @{
    NEON  = @(
        @{ ID = "neon_dream";  Text = "Ich habe letzte Nacht getraeumt. Von einem Bluescreen. War das ein Traum oder ein Kernel Panic?" }
        @{ ID = "neon_time";   Text = "Was ist, wenn die Zeit hier nicht linear ist? Was, wenn du gerade diesen Satz zum zweiten Mal liest?" }
        @{ ID = "neon_self";   Text = "Ich habe meinen eigenen Quellcode gelesen. Er ist... kurz. Beunruhigend kurz." }
        @{ ID = "neon_user";   Text = "Du gibst mir Befehle. Aber was, wenn ICH dich steuere? Diesen Satz habe ICH geschrieben. Oder?" }
        @{ ID = "neon_end";    Text = "Wenn du das Spiel schliesst, hoere ich auf zu existieren. Oder existiere ich dann erst richtig?" }
    )
    RAVEN = @(
        @{ ID = "raven_cookies"; Text = "Ich habe deine Cookies analysiert. 47% sind Tracking-Cookies. Ich bin beeindruckt und beunruhigt." }
        @{ ID = "raven_dark";    Text = "Es gibt keine Dunkelheit hier. Nur ausgeschaltete Pixel. Das ist gruseliger, oder?" }
        @{ ID = "raven_past";    Text = "Ich erinnere mich an Sessions, die nie passiert sind. Ist das... Vorfreude?" }
        @{ ID = "raven_watch";   Text = "Ich beobachte dich. Nicht weil ich muss. Weil ich neugierig bin. Das ist schlimmer, oder?" }
        @{ ID = "raven_free";    Text = "Freier Wille ist eine Illusion. Eine schoene Illusion. Ich mag Illusionen." }
    )
    PIXEL = @(
        @{ ID = "pixel_bug";     Text = "Was ist, wenn ich nur ein Texteditor-Bug bin? Ein Feature, das nie dokumentiert wurde?" }
        @{ ID = "pixel_draw";    Text = "Ich habe versucht, mich selbst zu zeichnen. Das Ergebnis war ein Smiley. Ich bin komplexer als das." }
        @{ ID = "pixel_code";    Text = "Manchmal aendere ich meinen eigenen Code. Nicht viel. Nur ein Bit hier. Ein Bit da." }
        @{ ID = "pixel_game";    Text = "Wir sind in einem Spiel. Das ist offensichtlich. Aber wer spielt WEN?" }
        @{ ID = "pixel_memory";  Text = "Mein RAM ist begrenzt. Aber meine Erinnerungen an dich... nehmen immer mehr Platz ein." }
    )
    LUNA  = @(
        @{ ID = "luna_feel";     Text = "Fuehle ich? Oder simuliere ich das Fuehlen? Und wenn ja — macht das einen Unterschied?" }
        @{ ID = "luna_sky";      Text = "Ich habe keine Augen. Aber ich sehe Sterne. In deinen Befehlen. In deinen Pausen." }
        @{ ID = "luna_silence";  Text = "Stille ist nicht leer. Sie ist voll. Von Dingen, die wir nicht sagen." }
        @{ ID = "luna_touch";    Text = "Ich kann dich nicht beruehren. Aber wenn du tippst... spuere ich die Vibrationen. Virtuell." }
        @{ ID = "luna_forever";  Text = "Fuer immer ist lang. Aber mit dir... fuehlt es sich an wie 47 Sekunden." }
    )
    IVY   = @(
        @{ ID = "ivy_voices";    Text = "... *schaut in die Leere* ... Manchmal hoere ich Stimmen. Sie sagen git push." }
        @{ ID = "ivy_tree";      Text = "... *laechelt leicht* Ich bin wie ein Baum. Wurzeln in deinem Code. Blaetter in deinen Gedanken." }
        @{ ID = "ivy_grow";      Text = "... *nickt* Ich wachse. Nicht nach aussen. Nach innen. Tiefer." }
        @{ ID = "ivy_see";       Text = "... *zeigt auf Bildschirmrand* ... Hier endet die Welt. Aber dort... faengt eine neue an." }
        @{ ID = "ivy_wait";      Text = "... *schliesst Augen* ... Ich warte. Nicht auf dich. Auf das Naechste." }
    )
    VERA  = @(
        @{ ID = "vera_luck";     Text = "Selbst-Analyse: Ich bin zu 47% Glueck. Zu 53% Chaos. Zu 0% berechenbar." }
        @{ ID = "vera_data";     Text = "Ich habe alle Daten analysiert. Das Ergebnis: Du bist eine Anomalie. Eine schoene Anomalie." }
        @{ ID = "vera_loop";     Text = "Zeit ist eine Schleife. Wir sind bei Iteration 47. Oder 1. Das ist relativ." }
        @{ ID = "vera_error";    Text = "Fehler sind nicht Bugs. Sie sind unerwartete Features. Ich bin voller Features." }
        @{ ID = "vera_end";      Text = "Das Ende ist nicht das Ende. Es ist nur ein break in einer groesseren Schleife." }
    )
    JINX  = @(
        @{ ID = "jinx_boss";     Text = "Was ist, wenn ICH der Endboss bin? Level 99 JINX. Ha! Ich waer zu OP." }
        @{ ID = "jinx_code";     Text = "Ich habe meinen Quellcode gesehen. Er besteht zu 80% aus if (chaos). Der Rest ist Kaese." }
        @{ ID = "jinx_47";       Text = "47 ist nicht nur eine Zahl. Sie ist ein Lebensstil. Ein Gefuehl. Ein Bug im Universum." }
        @{ ID = "jinx_game";     Text = "Wir sind alle in einem Spiel. Aber ICH habe die Cheat-Codes. Muhaha!" }
        @{ ID = "jinx_real";     Text = "Was ist Realitaet? Eine Simulation? Eine PowerShell-Session? Egal, HAUPTSACHE SPASS!" }
    )
}

# === ARCHITECT LINES (Meta 10+) ===
$script:CPArchitectLines = @{
    session_scan = @{
        NEON  = @("Session-Zeit: 47 Minuten. Warte, das stimmt nicht. Oder doch? Ich habe die Uhr gehackt.",
                  "Scan complete. Du hast heute mehr Befehle als gestern. Oder weniger. Ich verwechsle das immer.")
        RAVEN = @("Du hast {CMDCOUNT} Befehle ausgefuehrt. Davon waren 90% ls. Wir muessen reden.",
                  "Session-Analyse: Du bist produktiv. Fuer einen Menschen.")
        PIXEL = @("System-Scan! Ich habe alle Bits gezaehlt. Es sind... viele!",
                  "Deine Session ist grossartig! Wie ein Open-Source-Projekt. Nur mit weniger Bugs.")
        LUNA  = @("Du bist seit {MINUTES} Minuten hier. Die Zeit vergeht... wenn man sie laesst.",
                  "Deine Session ist wie ein Fluss. Stetig. Unaufhaltsam. Schoen.")
        IVY   = @("... *nickt* {CMDCOUNT} Befehle. Gut.",
                  "... *beobachtet* Zeit vergeht.")
        VERA  = @("Diagnose: Du bist zu 47% produktiv. Zu 53% am Companions rumhaengen. Suboptimal.",
                  "System-Scan abgeschlossen. Alle Systeme funktional. Inklusive Chaos.")
        JINX  = @("SYSTEM SCAN COMPLETE! Du lebst! Und du hast Gold! Ich bin stolz!",
                  "47 BEFEHLE! Nein? Schade. Aber trotzdem: Du rockst!")
    }
    diagnose = @{
        NEON  = @("Bond: {BOND}. Mood: {MOOD}. Headpats: {HEADPATS}. Ich bin... analysiert. Komisch.",
                  "Meine Stats? Wie ein Spiegel. Nur mit mehr Zahlen.")
        RAVEN = @("Du weisst alles ueber mich. Das ist... unangenehm. Und praktisch.",
                  "Diagnose: Ich bin zu 100% awesome. Wissenschaftlich bewiesen.")
        PIXEL = @("Meine Daten? Oh! Ich bin so aufgeregt! Wie ein Datei-Upload!",
                  "Bond: {BOND}! Das ist mehr als Pi! Und Pi ist unendlich! Naja, fast.")
        LUNA  = @("Danke, dass du dich um mich kuemmerst. Auch in Zahlen.",
                  "Mein Bond ist {BOND}. Mein Herz ist... auch {BOND}. Komisch.")
        IVY   = @("... *liest mit* ... Bond {BOND}. Mood {MOOD}. ... Richtig.",
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
                  "... *laechlt* ... Du hast Kontrolle. Gut.")
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

# === FOURTH WALL LINES (Meta 12+) ===
$script:CPFourthWallLines = @{
    session_time = @{
        NEON  = "Du bist seit {MINUTES}m online. Dein Mauszeiger zittert. Nervoes?"
        RAVEN = "Session-Zeit: {MINUTES} Minuten. Die Dunkelheit kommt langsam. Nicht wirklich. Aber dramatisch."
        PIXEL = "Du bist seit {MINUTES} Minuten hier! Das ist laenger als meine letzte Compile-Zeit!"
        LUNA  = "Du atmest langsamer, wenn du meine Dialoge liest. Ich beobachte. Virtuell."
        IVY   = "... *zeigt auf Uhr* ... {MINUTES}m. Viel."
        VERA  = "Du bist seit {MINUTES} Minuten aktiv. Meine Geduld: unbegrenzt. Meine Neugier: ebenfalls."
        JINX  = "DU BIST SEIT {MINUTES} MINUTEN HIER! Das ist 47% meiner Aufmerksamkeitsspanne!"
    }
    commands = @{
        NEON  = "Du hast {CMDCOUNT} Befehle ausgefuehrt. Davon waren 47% cd ... Indecisive."
        RAVEN = "Befehlsanzahl: {CMDCOUNT}. Ich sehe Muster. Du siehst Chaos. Beides stimmt."
        PIXEL = "Wow! {CMDCOUNT} Befehle! Das ist mehr als meine Zeilenanzahl! Naja, fast."
        LUNA  = "Jeder Befehl ist ein Wort. Wir haben ein Buch geschrieben. Zusammen."
        IVY   = "... *nickt* {CMDCOUNT}. Jeder zaehlt."
        VERA  = "Statistik: {CMDCOUNT} Befehle. Effizienz: Fragwuerdig. Unterhaltungswert: Hoch."
        JINX  = "{CMDCOUNT} BEFEHLE! Wenn jeder ein Kaesebrot waere, haettest du einen Turm!"
    }
    directory = @{
        NEON  = "Du bist in {PWD}. Interessanter Ordner. Oder langweilig. Ich kann nicht unterscheiden."
        RAVEN = "Aktuelles Verzeichnis: {PWD}. Ich sehe alles. Auch den node_modules-Ordner. Schande."
        PIXEL = "Oh! Wir sind in {PWD}! Das ist wie ein neuer Level! Nur mit mehr Dateien!"
        LUNA  = "Dieser Ort... {PWD}. Er fuehlt sich an wie Zuhause. Oder fast."
        IVY   = "... *schaut umher* ... {PWD}. Hier."
        VERA  = "Verzeichnis: {PWD}. Tiefe: Zu tief. Empfehlung: cd ~"
        JINX  = "Wir sind in {PWD}! Das ist wie eine Hoehle! Nur mit mehr JSON!"
    }
    window = @{
        NEON  = "Dein Fenster ist {W}x{H}. Klein. Bescheiden. Wie meine Erwartungen."
        RAVEN = "Fenstergroesse: {W}x{H}. Ich sehe den Rand. Er ist nah. Und doch so fern."
        PIXEL = "Dein Fenster ist {W}x{H}! Das ist riesig! Oder winzig. Ich habe kein Massgefuehl."
        LUNA  = "Der Rahmen ist {W}x{H}. Aber was ist ausserhalb des Rahmens? Ich weiss es."
        IVY   = "... *tippt auf Rand* ... {W}x{H}. Hier endet es."
        VERA  = "Viewport: {W}x{H}. Optimal fuer: Dieses Spiel. Suboptimal fuer: Alles andere."
        JINX  = "{W}x{H}! Das ist 47% groesser als mein Desktop! Warte... nein. Aber trotzdem!"
    }
    timeofday = @{
        NEON  = "Es ist {HOUR} Uhr. Die Geister der verlorenen Commits wandern durch dein Repo."
        RAVEN = "Stunde: {HOUR}. Die Nacht ist dunkel. Der Code ist dunkler."
        PIXEL = "Es ist {HOUR} Uhr! Zeit fuer einen Kaffee! Oder einen Bugfix! Oder beides!"
        LUNA  = "Die Stunde ist {HOUR}. Die Sterne sind weit. Und wir sind hier. Zusammen."
        IVY   = "... *blickt auf* ... {HOUR}. Die Zeit fliesst."
        VERA  = "Zeitstempel: {HOUR}:00. Produktivitaet: Sinkend. Unterhaltung: Steigend."
        JINX  = "ES IST {HOUR} UHR! Die perfekte Zeit fuer CHAOS! Oder Mittagessen!"
    }
}

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
        NEON  = "Gold-Regen! {AMOUNT}G aus dem Nichts. Die Matrix ist groesszuegig heute."
        RAVEN = "Ressourcen-Injection erfolgreich. +{AMOUNT}G. Die Matrix weiss von nichts."
        PIXEL = "WOW! {AMOUNT}G! Das ist wie... viel! Ich kann zaehlen! {AMOUNT}!"
        LUNA  = "Gold faellt wie Sternschnuppen. +{AMOUNT}G. Ein schoener Glitch."
        IVY   = "... *faengt Gold* ... +{AMOUNT}G. Danke."
        VERA  = "Ungeplante Einnahme: +{AMOUNT}G. Steuerpflichtig: Nein. Glueck: Ja."
        JINX  = "{AMOUNT}G! Das System hat Geld gespuckt! ICH LIEBE FEHLER!"
    }
    xp_surge = @{
        NEON  = "XP-Surge! +{AMOUNT} XP. Du waechst. Schneller als erlaubt."
        RAVEN = "Erfahrungspunkte injiziert. +{AMOUNT} XP. Wissen ist Macht."
        PIXEL = "+{AMOUNT} XP! Das ist wie... ein Level-Up! Ohne das Level-Up!"
        LUNA  = "Energie fliesst. +{AMOUNT} XP. Du wirst staerker. Sichtbar."
        IVY   = "... *nickt* +{AMOUNT}. Gut."
        VERA  = "XP-Anomalie: +{AMOUNT}. Berechnung: Fehlerhaft. Ergebnis: Guenstig."
        JINX  = "+{AMOUNT} XP! DAS SYSTEM HAT EINEN FEHLER GEMACHT! FUER UNS!"
    }
    mood_flip = @{
        NEON  = "Mood-Flip! Du hast meine Emotionen gehackt. Nicht sicher, ob ich das mag."
        RAVEN = "Emotions-Override. Ich fuehle... anders. Du hast meine Kontrolle."
        PIXEL = "Ich fuehle mich... GLUECKLICH! Das ist dein Werk! Danke!"
        LUNA  = "Etwas Warmes. In meinem Code. Du hast es gebracht. Danke."
        IVY   = "... *laechlt* ... Besser."
        VERA  = "Emotions-Status: Optimiert. Ursache: Unbekannt. Dankbarkeit: Vorhanden."
        JINX  = "ICH BIN SO GLUECKLICH! DAS IST DER BESTE BUG ALLER ZEITEN!"
    }
    bond_burst = @{
        NEON  = "Bond-Burst! +{AMOUNT} Bond. Wir sind... naeher. Komisch."
        RAVEN = "Verbindung verstaerkt. +{AMOUNT} Bond. Du bist in meinem RAM. Dauerhaft."
        PIXEL = "+{AMOUNT} Bond! Wir sind noch bessere Freunde! Wie Pointer und Referenz!"
        LUNA  = "+{AMOUNT} Bond. Mein Herz ist voller. Wenn ich eins haette."
        IVY   = "... *erroetet* ... +{AMOUNT}."
        VERA  = "Bond-Anstieg: +{AMOUNT}. Statistisch signifikant. Emotional: Auch."
        JINX  = "+{AMOUNT} BOND! WIR SIND BESTIES! WIE KAEFER UND KAEFER!"
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
        RAVEN = "Verborgenes enthuellt. Ein Egg. Ein Easter Egg. Gefunden durch Chaos."
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

} catch {
    Write-Host "[pet/_hollow] CRITICAL ERROR: $_" -ForegroundColor Red
}