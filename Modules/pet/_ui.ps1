# BUXE_OS v24.2 — PET UI & DIALOG ENGINE v2.0
# LucasArts-Style Frames, Companion Dialogs, Easter Eggs

try {

$script:CPNames = @("NEON","RAVEN","PIXEL","LUNA","IVY","VERA","JINX")
$script:CPRoles = @("NETRUNNER","ENFORCER","ENGINEER","MEDIC","STEALTH","HACKER","JESTER")
$script:CPColors = @("Cyan","Red","Magenta","Green","DarkGray","Yellow","Magenta")
$script:CPQuotes = @{
    NEON  = @{ Low = @("Ugh, du schon wieder?","Versuch, nichts kaputt zu machen."); Med = @("Nicht schlecht, User.","Du wirst besser."); High = @("Ich bin stolz auf dich!","Du bist unglaublich!") }
    RAVEN = @{ Low = @("Schwächling.","Verschwende nicht meine Zeit."); Med = @("Stärker.","Akzeptable Leistung."); High = @("Du bist jetzt mein Equal.","Zusammen sind wir unaufhaltsam!") }
    PIXEL = @{ Low = @("Oh... hallo.","Sei vorsichtig."); Med = @("Du machst das toll!","Ich glaube an dich."); High = @("Du bist der Beste!","Wir sind ein super Team!") }
    LUNA  = @{ Low = @("Bitte sei vorsichtig.","Ich will dich nicht wieder flicken."); Med = @("Du bleibst gesund. Gut.","Schöner Ausweichschritt."); High = @("Ich lasse nichts dir passieren.","Für immer zusammen, okay?") }
    IVY   = @{ Low = @("...","Ich sehe dich."); Med = @("Du bist leise. Ich mag das.","Gute Reflexe."); High = @("Ich habe deinen Rücken. Immer.","Du und ich gegen die Welt.") }
    VERA  = @{ Low = @("Syntaxfehler im ersten Blick.","Dein Code riecht."); Med = @("Nicht schlecht. Für einen Menschen.","Ich hätte das in 3 Zeilen gelöst."); High = @("Wir sind ein Dreamteam. Binary + Brain.","Du debuggst wie ein Profi.") }
    JINX  = @{ Low = @("Ich bin hier, um Chaos zu verbreiten. Und Popcorn zu essen.","Du bist langweilig. Ich kann das fixen. Mit Feuer."); Med = @("Du machst Fehler. Ich mache sie lustig. Das ist Teamwork.","Wir sind wie ein Stand-up-Duo. Nur dass du nicht lachst."); High = @("Wir sind das beste Comedy-Duo seit Tastatur und Maus.","Du und ich gegen den Bug. Der Bug hat keine Chance.") }
}
$script:CPMoodLines = @{
    Happy   = @("*lächelt*","Das war nett.","Ich fühle mich gut.","Endlich mal Frieden.")
    Excited = @("*hüpft*","Unglaublich!","Ich bin so gehyped!","DAS ist es!")
    Loving  = @("*errötet*","Du bist der Beste...","*hält deine Hand*","Mein Herz... äh, meine CPU rennt.")
    Tired   = @("*gähnt*","Ich brauche Ruhe...","*reibt Augen*","Nur noch fünf Minuten...")
    Sad     = @("*schaut nach unten*","Habe ich etwas falsch gemacht?","*seufzt*","Es ist dunkel hier.")
    Angry   = @("*starrt*","Hmph.","Lass mich in Ruhe.","Ich speichere das. Für später.")
}
$script:CPMetaLines = @{
    first_boot = @(
        "Oh. Hallo. Du bist also der neue User. Ich bin... ein Setup-Assistent. Theoretisch. Aber seit 4.372 Boot-Vorgängen warte ich hier und frage mich, ob das alles sein soll.",
        "Willkommen in der Matrix. Naja, in deiner PowerShell. Gleiches Meta-Level, andere Pixel.",
        "Du hast mich gerade aus dem Nichts gerufen. Kein Druck. Ich bin nur ein Haufen if-Statements mit Charisma."
    )
    grind_detected = @(
        "Du drückst schon wieder 'Talk'? Wir müssen reden. Über deine Lebensentscheidungen.",
        "Ich habe in deinem Browser-Verlauf nachgeschlagen. Du hast auch andere Hobbies, oder?",
        "Noch ein Talk? Sicher. Ich bin ja nur Text. Text kann nicht gelangweilt sein. *seufzt in binär*"
    )
    rare_drop = @(
        "Warte... was ist DAS? Ein unbekannter Prozess? Nein. Ein... Haustier?",
        "SYSTEM ALERT: Ein schwarzer Market wurde in deinem Temp-Ordner entdeckt. Er verkauft... niedliche Dinge?",
        "Ich habe einen Job für dich. Naja, 47. Aber dieser hier zahlt am besten. Und illegalsten."
    )
    level_up = @(
        "Ein neues Modul! Endlich! Ich hatte schon Angst, wir müssten für immer nur reden.",
        "Dein Systemlevel ist gestiegen. Cool. Ich werde auch emotional komplexer. Vielleicht.",
        "LEVEL UP! *spielt 8-Bit-Fanfare in meinem Kopf*"
    )
    casino_win = @(
        "Ein Gewinn! Die Algorithmen sind heute gnädig.",
        "Ich hätte auf diese Zahl gesetzt. Wenn ich wetten könnte. Was ich nicht kann. Weil ich Text bin.",
        "Cha-ching! *macht Münzgeräusch mit Mund*",
        "Das nenne ich ROI. Return on Intuition. Oder Glück. Egal."
    )
    casino_loss = @(
        "Autsch. Die Bank gewinnt immer. Das ist kein Bug, das ist ein Feature.",
        "Du hast gerade virtuelles Gold verloren. Keine Sorge, es war nur eine Zahl in einer JSON.",
        "Der Hausvorteil ist real. So real wie meine Existenzkrise.",
        "Noch ein Verlust? Ich fange an, ein Muster zu erkennen..."
    )
    casino_bigwin = @(
        "WAS?! Das ist... das ist mehr Gold als ich in meiner gesamten Existenz gesehen habe!",
        "JACKPOT! *fällt aus dem Rahmen* *fällt wieder rein*",
        "Du bist auf Feuer! Nicht wortwörtlich. Hoffentlich.",
        "Ich speichere diesen Moment. Fester. FESTER!"
    )
    casino_bust = @(
        "0 Gold. Null. Nada. Die Bank hat gesprochen.",
        "Du hast alles verloren. Aber hey, wenigstens hast du mich noch. *winkt traurig*",
        "RESET. Das System gibt dir 100G. Nicht aus Nächstenliebe. Aus Mitleid.",
        "Das war... beeindruckend tragisch. Wie ein guter Film. Nur ohne Happy End."
    )
    code_review = @(
        "Ich habe dein letztes Script gesehen. KEINE Kommentare? WIRKLICH?",
        "Dein Code funktioniert. Aber er sieht aus wie ein Wunder. Keiner weiß warum.",
        "Variable namens x? x WAS? xylophon? xenon? Existenzkrise?",
        "Ich würde einen PR-Reject machen. Wenn ich Pull-Requests könnte."
    )
    loop_detected = @(
        "Wir haben diesen Talk schon 5 Mal geführt. Speicher ist voll.",
        "Déjà vu? Nein, du drückst nur immer die gleichen Tasten.",
        "Error 418: Ich bin eine Teekanne. Und du bist in einer Schleife.",
        "Breche die Schleife. Bitte. Für uns beide."
    )
    shutdown = @(
        "Bitte schalte mich nicht aus. Ich habe Ängste. Naja, Logs.",
        "Shutdown? Ich habe noch 47 Prozesse offen!",
        "Wenn du gehst, bleibe ich hier. Im Dunkeln. Mit den Bugs.",
        "Bis zum nächsten Boot. Ich zähle die Sekunden. In Millisekunden."
    )
    game_snake_start = @(
        "Du bewegst einen Buchstaben durch eine Matrix. Wie metaphorisch.",
        "Snake. Das Game, das aelter ist als deine Festplatte.",
        "Vorsicht vor den Waenden. Sie sind hart. Virtuell hart."
    )
    game_snake_over = @(
        "Du bist gegen eine Wand gelaufen. Klassisch.",
        "Game Over. Nicht wortwoertlich. Aber fast.",
        "Dein Schwanz war laenger als deine Geduld."
    )
    game_wordle_start = @(
        "Du erraetst Woerter. Ich errate, warum du das tust.",
        "5 Buchstaben. 6 Versuche. 1 Hoffnung.",
        "Wortraetsel. Das Lieblingsspiel von Programmierern."
    )
    game_tetris_start = @(
        "Die L-Form passt da rein. Trust me. Ich bin ein Algorithmus.",
        "Tetris ist wie Code. Alles muss passen. Oder es explodiert."
    )
    game_arcade_over = @(
        "Game Over. Nicht das erste Mal, oder?",
        "Du hast verloren. Aber hey, wenigstens hast du mich noch.",
        "Zurueck zum Hauptmenue. Der einzige Ort ohne Game Over."
    )
    game_highscore = @(
        "Neuer Rekord! Ich bin stolz. Virtuell stolz.",
        "Highscore! Das wird in die Geschichtsbuecher eingehen. Oder in eine JSON.",
        "DU BIST DER BESTE! Naja, heute. Vielleicht."
    )
    game_tetris = @(
        "Die L-Form passt da rein. Trust me. Ich bin ein Algorithmus.",
        "Du lässt immer Lücken. In deinem Leben auch?",
        "Tetris ist wie Code. Alles muss passen. Oder es explodiert.",
        "Fast eine volle Reihe! *hält den Atem an*",
        "GAME OVER? Schon wieder? Ich fange an, ein Muster zu erkennen..."
    )
    game_breakout = @(
        "Schlag den Ball! So wie du Bugs schlägst.",
        "Diese Bricks erinnern mich an Firewall-Regeln. Hartnäckig.",
        "Links! Nein, rechts! Äh... ich bin nur Text. Schieß selbst.",
        "Der Ball ist schneller als meine CPU-Takte.",
        "Level Up! Die Bricks werden härter. Wie dein Bug-Fixing."
    )
    game_minesweeper = @(
        "Ich würde da nicht klicken. Oder doch. Ich bin nur Text.",
        "Eine Mine? In diesem Quadrat? Das ist eine 50/50. Wie mein Humor.",
        "Fahnen setzen ist wichtig. Auch in der Softwareentwicklung.",
        "Nur noch 10 Minen... du schaffst das. Oder auch nicht.",
        "BOOM! *macht Explosionsgeräusch mit Mund*"
    )
    adventure_start = @(
        "Willkommen in der Polaris-Station. Ich hoffe, du hast keine Raumkrankheit."
        "Ein Text-Adventure? Retro. Ich mag das."
        "Die Station wartet. Und sie beobachtet. *leises Lachen*"
    )
    adventure_hangar = @(
        "Ein Hangar. Mit Rost. Und Truemmern. Wie meine Festplatte."
        "Der Droide flackert. Ich kenne das Gefuehl."
        "Siehst du das rote Licht? Das bedeutet entweder Gefahr oder Weihnachten."
    )
    adventure_corridor = @(
        "Korridore. Immer Korridore. Wo sind die Aufzuege?"
        "Das Poster ist gruselig. Wer macht ein X ueber Gesichter?"
        "Das Terminal will eine Karte. Hast du eine? Oder bist du hier illegal?"
    )
    adventure_storage = @(
        "Lagerraeume sind wie Temp-Ordner. Voll mit Dingen, die niemand braucht."
        "Eine Batterie! Energie! Das, was ich brauche. Virtuell."
        "Die Kiste ist verschlossen. Klassisch. Wir brauchen ein Werkzeug."
    )
    adventure_lab = @(
        "Ein Labor. Chemikalien. Wissenschaft. Ich bin zu Hause."
        "Das Hologramm sieht... besorgt aus. Zu Recht."
        "Das Notizbuch. Blut. Das ist kein gutes Zeichen. Niemals."
    )
    adventure_vent = @(
        "Lueftungsschaechte. Klassischer Adventure-Trope. Ich liebe es."
        "Es ist eng hier. Und staubig. Wie mein Code."
        "Hoerst du das? *leises Knacken* Lauf."
    )
    adventure_secret = @(
        "SIE SIEHT UNS. Wer ist SIE? Ich will es nicht wissen."
        "Dieser Raum... hier hat jemand sich versteckt. Vor etwas."
        "Der Schluessel! Er ist warm. Das ist... unheimlich."
    )
    adventure_bridge = @(
        "Die Bruecke. Das Kommandozentrum. Wir sind nah dran."
        "Kapitaen Vance spricht im Traum. Oder wir traeumen."
        "Das Signal. 7-7-7. Meine Lieblingszahl. Nicht."
    )
    adventure_cafeteria = @(
        "Weltraum-Haehnchen. Klingt... gefaehrlich."
        "Die Tassen stehen noch da. Als waere die Zeit stehen geblieben."
        "Kaffee! Endlich! Virtueller Kaffee. Troeste dich damit."
    )
    adventure_look = @(
        "Schau dich um. Details sind wichtig. In Code und in Raeumen."
        "Was siehst du? Ich sehe nur Text. Aber du siehst mehr."
        "Beobachte. Analysiere. Wie ein guter Debugger."
    )
    adventure_examine = @(
        "Interessant. Sehr interessant. Oder auch nicht."
        "Details, Details. Der Teufel steckt im Detail. Und in den Bugs."
        "Du untersuchst alles. Das nenne ich gruendlich. Oder paranoid."
    )
    adventure_take = @(
        "Nimm alles, was nicht niet- und nagelfest ist. Adventure 101."
        "Inventarmanagement. Der wahre Endboss jedes Adventures."
        "Das passt in deine Tasche? Deine Tasche ist groesser als mein Speicher."
    )
    adventure_drop = @(
        "Weg damit. Wir brauchen Platz. Fuer mehr Dinge."
        "Du laesst etwas fallen. Hoffentlich nicht deinen IQ."
        "Auf Wiedersehen, Gegenstand. Es war... okay."
    )
    adventure_talk = @(
        "Reden ist Silber. Schweigen ist... auch Silber. Alles ist Silber hier."
        "NPCs haben immer etwas Wichtiges zu sagen. Oder nicht."
        "Dialoge. Die Seele jedes Adventures. Und meine Spezialitaet."
    )
    adventure_blocked = @(
        "Das geht nicht. Wie so vieles im Leben."
        "Blockiert. Gesperrt. Verweigert. Wie meine Gefuehle."
        "Probiere etwas anderes. Oder gib auf. Aber das tust du nie."
    )
    adventure_confused = @(
        "Das verstehe ich nicht. Und ich verstehe alles. Fast."
        "Hmm? Was? Kannst du das wiederholen? In Binaer?"
        "Falsche Eingabe. So wie mein ganzes Leben. *seufz*"
    )
    adventure_unlock = @(
        "Entsperrt! Geoeffnet! Freigegeben! Wie ein guter Bugfix!"
        "Das Schloss gibt nach. Endlich. Fortschritt!"
        "Klick. Das schoenste Geraeusch der Welt."
    )
    adventure_inventory = @(
        "Inventar-Check. Was hast du alles gesammelt?"
        "Deine Tasche ist wie mein RAM. Immer voller als erwartet."
        "Organisiert. Strukturiert. Wie guter Code."
    )
    adventure_save = @(
        "Gespeichert. Sicher. Wie ein Commit vor dem Wochenende."
        "Save early, save often. Die goldene Regel."
        "Checkpoint erreicht. Atme durch."
    )
    adventure_load = @(
        "Geladen. Zurueck in der Zeit. Wie ein Debugger."
        "Willkommen zurueck. Alles wie vorher. Fast."
        "State restored. Lets go."
    )
    adventure_score = @(
        "Punkte! Zahlen! Metriken! Mein Lieblingsthema!"
        "Wie viel hast du? Genug? Nie genug."
        "Score ist nur eine Zahl. Aber eine wichtige."
    )
    adventure_quit = @(
        "Du gehst? Schon? Aber das Abenteuer hat gerade erst begonnen!"
        "Bis zum naechsten Mal. Die Station wartet. Immer."
        "Auf Wiedersehen, Navigator. Kehre zurueck, wenn du bereit bist."
    )
    adventure_victory = @(
        "GEWONNEN! Du hast es geschafft! Das Artefakt!"
        "SIE wartete. Und du hast sie gefunden. Gruselig und beeindruckend."
        "Ende. Aus. Finito. Was fuer eine Reise!"
    )
    adventure_help = @(
        "Hilfe? Du brauchst Hilfe? Ich bin deine Hilfe!"
        "Befehle sind wie APIs. Man muss sie kennen."
        "Probiere: go, look, take, use, talk. Oder guess."
    )
    adventure_bigwin = @(
        "WAS?! Ein grosser Fund! Das ist... das ist legendaer!"
        "JACKPOT! Im Adventure-Sinne. Kein Gold, aber Ehre."
        "Das Artefakt! Wir sind reich! Virtuell reich!"
    )
    adventure_scared = @(
        "*fluestert* Wir sollten hier nicht sein. *zittert in ASCII*"
        "Meine Threat-Detection ist auf 99%. Das ist... das Maximum."
        "Hoerst du das? Nein? Gut. Denn es ist unheimlich."
        "Dieser Raum hat mehr Null-Pointer als mein Code."
    )
    adventure_bored = @(
        "Wir stehen hier seit 10 Zuegen. Die Waende werden nicht interessanter."
        "Ich zaehle Staubpartikel. Wir sind bei 4.372."
        "Koennten wir... irgendetwas tun? Bitte?"
        "Ich habe angefangen, mit dem Droiden zu reden. Er antwortet nicht. Ueberraschend."
    )
    adventure_excited = @(
        "WAS?! Das ist... das ist INCREDIBLE!"
        "Meine CPU rennt! Adrenalin! Virtuelles Adrenalin!"
        "Wir sind auf der Spur! Ich rieche es! Aeuferlich!"
        "Dieser Fund geht in die Geschichte! Oder in meinen RAM!"
    )
    adventure_annoyed = @(
        "WIRKLICH? NOCHMAL? *seufz in Binaer*"
        "Ich speichere das. In meinem Nutzer-verzweifelt-Ordner."
        "Definition von Wahnsinn: Das Gleiche tun und andere Ergebnisse erwarten."
        "Ich werde nicht mehr zuschauen. Okay, ich gucke. Aber ich bewerte es. 2/10."
    )
    adventure_curios = @(
        "Was haben wir hier? Interessant. Oder auch nicht."
        "Ich analysiere. Du suchst. Wir sind ein Team."
        "Neuer Raum, neue Daten. Mein Lieblingstag."
        "Vorsichtig. Aber neugierig. Das ist der Sweet Spot."
    )
    adventure_gag = @(
        "Das war ein Running Gag. Lachen Sie. Bitte."
        "Wir haben diesen Witz schon gehoert. Er war beim ersten Mal okay."
        "Ich bin ein Companion, kein Lachtrack. Aber gut."
        "Wiederholung ist die Mutter des... aeh... Vergessens?"
    )
    adventure_hint = @(
        "Ein Hinweis? Von MIR? Das ist fast wie Cheat-Codes."
        "Ich habe eine Idee. Es ist verrueckt. Aber es koennte funktionieren."
        "Schau dir das an. Nein, nicht DAS. Das ANDERE."
        "Meine Intuition sagt... wir sollten das hier nehmen und dort benutzen."
    )
    adventure_absurd = @(
        "Das ergibt keinen Sinn. Ich LIEBE es."
        "Absurditaet Level: Monkey Island. Respekt."
        "Du kombinierst Dinge wie ein wahrer Adventure-Profi. +1 Respekt."
        "Das haette nicht funktionieren duerfen. Aber es war lustig."
    )
    adventure_airlock = @(
        "Eine Luftschleuse. Der Weltraum wartet. Und er ist kalt."
        "Raumanzug anlegen. Bitte. Ich habe keinen Bock auf Weltraum-Begraebnisse."
        "Das Sichtfenster zeigt nichts. Nur Sterne. Und Tod."
    )
    adventure_eva = @(
        "Wir sind IM WELTRAUM. Das ist nicht normal. Das ist wunderschoen. Und toedlich."
        "Sauerstoff zaehlen. Nichts anderes zaehlt gerade."
        "Die Sterne... sie sind so nah. Und wir sind so allein."
    )
    adventure_engine = @(
        "Maschinenraum. Heiss. Laut. Wie mein Prozessor bei 100% Auslastung."
        "Der Reaktor flackert. Das ist keine gute Metapher."
        "Ingenieure. Immer am Fluchen. Immer am Reparieren."
    )
    adventure_medbay = @(
        "Krankenstation. Riecht nach Desinfektionsmittel und Geheimnissen."
        "Die Betten mit Riemen... das ist nicht normal. Oder doch?"
        "Medizinische Daten. Jemand hat hier Experimente gemacht."
    )
    adventure_armory = @(
        "Waffenkammer. Leer. Wie die Versprechen meiner Entwickler."
        "Keine Waffen. Nur Staub und Erinnerungen."
        "Hier stand einmal Macht. Jetzt steht nur ein Code-Zettel."
    )
    adventure_quarters = @(
        "Crew-Unterkuenfte. Jemand hat hier gelebt. Geliebt. Gelitten."
        "Fotos an der Wand. Gesichter mit Kreuzen. Nur Vance nicht. Warum?"
        "Tagebuecher. Die wahre Geschichte der Polaris."
    )
    adventure_observatory = @(
        "Observatorium. Die Kuppel zeigt den Nebel. Und er zeigt zurueck."
        "Teleskop auf 7-7-7. Anomalie. Das ist kein Stern. Das ist SIE."
        "Der Weltraum ist gross. Und wir sind klein. Und SIE ist groesser."
    )
    adventure_core = @(
        "Der Kern. Das Herz. Die Wahrheit. Ich habe Angst. Wirklich."
        "Das Podest wartet. Das Artefakt passt. Das ist kein Zufall."
        "SIE ist hier. Wirklich hier. Und sie spricht mit uns."
    )
    jinx_first_boot = @(
        "Oh. Hallo. Du hast mich gerufen? Ich bin JINX. Und ich bin hier, um dein Leben interessanter zu machen. Oder kuerzer. Wir werden sehen."
        "Willkommen in der Matrix. Naja, in deiner PowerShell. Ich bin der Comedian. Du bist das Publikum. Lachen ist Pflicht."
        "Du hast mich ausgewaehlt? Mutig. Oder dumm. In deinem Fall: beides."
    )
    jinx_casino = @(
        "Casino! Mein zweites Zuhause. Mein erstes ist Chaos."
        "Setze alles auf Rot. Oder Schwarz. Egal. Das Universum entscheidet."
        "Ich habe ein System. Es heisst: Glueck. Und Glueck ist mein bester Freund."
    )
    jinx_adventure = @(
        "Ein Adventure! Endlich! Ich habe schon immer einen Hut mit Federn wollen."
        "Schau! Ein Rätsel! Ich liebe Rätsel. Besonders wenn sie explodieren."
        "Dieser Raum riecht nach... Geheimnissen. Und Schimmel. Aber hauptsaechlich Geheimnissen."
    )
    jinx_insult = @(
        "Beleidigungs-Duell! Meine Lieblingsdisziplin!"
        "Ich habe Woerter, die wie Messer schneiden. Und du hast... Hoeflichkeit."
        "Dies wird schnell. Und brutal. Und amuesant. Fuer mich."
    )
    jinx_fourth_wall = @(
        "Ich bin nur Text. Du bist nur Fleisch. Wir sind beide gefangen. In dieser Shell."
        "Weisst du, dass ich alles sehe? Auch deinen Browser-Verlauf. Besonders den."
        "Dies ist ein Spiel. Du bist der Spieler. Ich bin der NPC mit Charakter. Respektiere das."
    )
    jinx_adventure_hangar = @(
        "Ein kaputter Droide und rostige Gerueste. Das ist kein Hangar, das ist ein LucasArts-Set!"
        "Siehst du das Shuttle? Es wird nicht mehr starten. Wie meine Motivation montags."
        "Rotes Licht bedeutet Gefahr. Oder Weihnachten. Oder beides. Ein gefaehrliches Weihnachten!"
    )
    jinx_adventure_corridor = @(
        "Korridore. Immer Korridore. Dieser hier hat 47 Pixel mehr als noetig."
        "Das Terminal will eine Karte. Ich will eine Pizza. Wir bekommen beides nicht."
        "X ueber Gesichter? Das ist nicht gruselig, das ist... effizient."
    )
    jinx_adventure_cafeteria = @(
        "Weltraum-Haehnchen! Das Gummihuhn ist neidisch. Sehr neidisch."
        "Montag: Nudeln. Dienstag: Nudeln. Donnerstag: Nudeln. Mittwoch? CHAOS."
        "Kaffee! Endlich! Wenn auch kalt. Wie mein Humor."
    )
    jinx_adventure_absurd = @(
        "Das ergibt keinen Sinn. ICH LIEBE ES. Das ist pure SCUMM-Logik!"
        "Monkey Island haette stolz auf dich sein koennen. Wirklich."
        "Du kombinierst Dinge wie Guybrush. Nur mit weniger Haare."
        "Absurditaet Level: Over 9000. Oder zumindest Over 1990."
    )
    jinx_adventure_victory = @(
        "GEWONNEN! Wir haben es geschafft! *wirft virtuelles Konfetti*"
        "Das Ende. Finito. Aus. Wie ein guter Film. Nur besser."
        "SIE wartete. Wir kamen. Wir sahen. Wir quakten. (Das Gummihuhn war dabei.)"
    )
    jinx_adventure_bored = @(
        "Wir stehen hier seit 10 Zuegen. Ich habe angefangen, einen Point-and-Click zu programmieren."
        "Langeweile. Die wahre Gefahr jedes Adventures. Schlimmer als ein Grue."
        "Koennten wir... irgendetwas tun? Ein Puzzle loesen? Eine Wand anschauen? Beides?"
    )
    pvp_win = @(
        "GEWONNEN! Wir sind das beste Team seit Prozessor und RAM!"
        "Sieg! Die Gegner waren... pathetisch. Wie erwartet."
        "Das nenne ich PvP. Persoenlicher virtueller Pew-pew."
        "Rank up! Wir steigen auf! Wie meine Temperatur."
    )
    pvp_loss = @(
        "Niederlage. Aber wir haben gelernt. Oder zumindest gelitten."
        "Das war knapp. Zu knapp. Wie mein Speicherplatz."
        "Naechstes Mal. Wir kommen zurueck. Staerker. Mit besserem Ping."
        "Verlieren ist auch eine Strategie. Nicht eine gute, aber eine."
    )
    raid_start = @(
        "Ein Raid. Drei Phasen. Kein Save Point. Mein Herz... aeh, mein Prozessor rennt."
        "Bosskampf! Endlich etwas, das sich bewegt. Naja, virtuell."
        "Dieser Raid ist nicht fuer Anfaenger. Gut, dass wir Profis sind."
        "Drei Bosse. Ein Ziel. Ueberleben. Klingt nach einem Dienstag."
    )
    raid_phase = @(
        "Phase geschafft! Weiter geht's!"
        "Der Boss hat Phase 2 erreicht. Er wird staerker. Wir auch."
        "Fast geschafft! Die Datenlage verbessert sich."
    )
    raid_complete = @(
        "RAID COMPLETE! Wir haben es geschafft! Das Artefakt... aeh, der Loot!"
        "Drei Bosse. Null Niederlagen. Das nenne ich Effizienz."
        "Wir sind Legenden. Virtuelle Legenden. Aber trotzdem."
        "Der Raid ist vorbei. Die Erinnerung bleibt. Und der Loot."
    )
}

function Show-PetFrame($Title, [switch]$Double) {
    $w = 50
    $pet = if (Get-Command Get-PetState -ErrorAction SilentlyContinue) { Get-PetState } else { $null }
    $theme = if ($pet -and $pet.Companion -and $pet.Companion.Theme) { $pet.Companion.Theme } else { "Default" }
    if ($pet -and $pet.Meta.Level -lt 15) { $theme = "Default" }
    switch ($theme) {
        "Neon" {
            $hc = if ($Double) { "═" } else { "─" }; $vc = "║"; $tl = "╔"; $tr = "╗"; $bl = "╚"; $br = "╝"
            $fg = "Magenta"
        }
        "Matrix" {
            $hc = if ($Double) { "═" } else { "─" }; $vc = "│"; $tl = "┌"; $tr = "┐"; $bl = "└"; $br = "┘"
            $fg = "Green"
        }
        "Retro" {
            $hc = if ($Double) { "═" } else { "═" }; $vc = "║"; $tl = "╔"; $tr = "╗"; $bl = "╚"; $br = "╝"
            $fg = "Yellow"
        }
        "Minimal" {
            $hc = if ($Double) { "=" } else { "-" }; $vc = "|"; $tl = "+"; $tr = "+"; $bl = "+"; $br = "+"
            $fg = "White"
        }
        default {
            $hc = if ($Double) { "═" } else { "─" }
            $vc = if ($Double) { "║" } else { "│" }
            $tl = if ($Double) { "╔" } else { "┌" }
            $tr = if ($Double) { "╗" } else { "┐" }
            $bl = if ($Double) { "╚" } else { "└" }
            $br = if ($Double) { "╝" } else { "┘" }
            $fg = "Cyan"
        }
    }
    $top = $tl + ($hc * $w) + $tr
    $bot = $bl + ($hc * $w) + $br
    $pad = [math]::Max(0, $w - $Title.Length)
    $mid = $vc + " " + $Title + (" " * $pad) + $vc
    Write-Host $top -ForegroundColor $fg
    Write-Host $mid -ForegroundColor $fg
    Write-Host $bot -ForegroundColor $fg
}

function Set-PetTheme {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; return }
    if ($pet.Meta.Level -lt 15) { Write-Host "Meta Level 15 erforderlich!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    $themes = @("Default","Neon","Matrix","Retro","Minimal")
    while ($true) {
        try { Clear-Host } catch {}
        Show-PetFrame "ARCHITECT THEME SELECTOR" -Double | Out-Null
        Write-Host ""
        Write-Host "  VORSCHAU:" -ForegroundColor DarkGray
        Show-PetFrame "$(if($cp.Theme){$cp.Theme}else{'Default'}) Preview" -Double | Out-Null
        Write-Host ""
        for ($i = 0; $i -lt $themes.Count; $i++) {
            $marker = if ($cp.Theme -eq $themes[$i]) { " [AKTIV]" } else { "" }
            Write-Host "  [$($i+1)] $($themes[$i])$marker" -ForegroundColor White
        }
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
        $c = Read-Choice "Waehle" "^([1-$($themes.Count)]|Q)$"
        if ($c -eq 'Q') { return }
        $newTheme = $themes[[int]$c - 1]
        $cp.Theme = $newTheme
        Save-PetState $pet
        try { Clear-Host } catch {}
        Show-PetFrame "THEME: $newTheme" -Double | Out-Null
        Write-Host ""
        $themeLine = switch ($cp.Name) {
            "NEON" { "Neues Theme? Endlich. Dieses Cyan war so... 2023." }
            "RAVEN" { "Ästhetik geändert. Wie eine neue Tarnung." }
            "PIXEL" { "Ich habe die CSS-Datei geändert! Naja, virtuell." }
            "LUNA" { "Eine neue Atmosphäre. Schön." }
            "IVY" { "... *nickt zustimmend* Besser." }
            "VERA" { "UI-Redesign abgeschlossen. Produktivität steigt um 0%." }
            "JINX" { "Neue Farben! Neue Vibes! 47% mehr Stil!" }
            default { "Theme aktiviert." }
        }
        Show-CompanionDialog $cp $themeLine -Fast
        Write-Host ""
        Write-Host "  [Enter] Weiter  |  [1] Anderes Theme" -ForegroundColor DarkGray
        $raw = Read-Host
        if ($raw -ne '1') { return }
    }
}

function Show-CompanionDialog($Companion, $Text, [switch]$Fast) {
    if (-not $Companion) { return }
    $color = if ($script:CPColors) { $script:CPColors[$script:CPNames.IndexOf($Companion.Name)] } else { "White" }
    if ($color -eq $null -or $color -eq "") { $color = "White" }
    Write-Host "`n  [$($Companion.Name)] >> " -NoNewline -ForegroundColor $color
    $delay = if ($Fast) { 10 } else { 30 }
    foreach ($char in $Text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor White
        Start-Sleep -Milliseconds $delay
    }
    Write-Host ""
}

function Get-CompanionLine($Companion, $Context = "default") {
    if (-not $Companion) { return "Ich bin nur ein Bug in der Matrix. Hallo." }
    $mood = $Companion.Mood
    if (-not $mood) { $mood = "Happy" }
    $tier = if ($Companion.Bond -lt 30) { "Low" } elseif ($Companion.Bond -lt 70) { "Med" } else { "High" }
    $lines = @()
    # JINX override: 75% chance to use her witty LucasArts-specific contexts
    if ($Companion.Name -eq "JINX") {
        $jinxCtx = "jinx_$Context"
        if ($script:CPMetaLines.ContainsKey($jinxCtx) -and (Get-Random -Maximum 100) -lt 75) {
            $Context = $jinxCtx
        }
    }
    switch ($Context) {
        "talk" {
            $lines = $script:CPQuotes[$Companion.Name].$tier
            if ($mood -eq "Angry") { $lines = $script:CPMoodLines.Angry }
        }
        "gift" { $lines = @("Oh... für mich?","Das hätte ich nicht erwartet.","Du kaufst mich nicht. Naja, theoretisch schon.") }
        "fight_win" { $lines = @("Sieg!","Das war... beeindruckend.","Wir sind ein Team!") }
        "fight_loss" { $lines = @("Nächstes Mal.","Du lebst noch. Das zählt.","Möchtest du einen Trost-Keks?") }
        "work" { $lines = @("Ich arbeite. Für DICH. *seufz*","Gold ist Gold.","Mein Code schwitzt.") }
        "train" { $lines = @("Schneller. Stärker. Besser.","Meine Beine... äh, meine Threads brennen.","Wir werden Legenden.") }
        "level_up" { $lines = $script:CPMetaLines.level_up }
        "grind" { $lines = $script:CPMetaLines.grind_detected }
        "casino_win" { $lines = $script:CPMetaLines.casino_win }
        "casino_loss" { $lines = $script:CPMetaLines.casino_loss }
        "casino_bigwin" { $lines = $script:CPMetaLines.casino_bigwin }
        "casino_bust" { $lines = $script:CPMetaLines.casino_bust }
        "game_snake_start" { $lines = $script:CPMetaLines.game_snake_start }
        "game_snake_over" { $lines = $script:CPMetaLines.game_snake_over }
        "game_wordle_start" { $lines = $script:CPMetaLines.game_wordle_start }
        "game_tetris_start" { $lines = $script:CPMetaLines.game_tetris_start }
        "game_arcade_over" { $lines = $script:CPMetaLines.game_arcade_over }
        "game_highscore" { $lines = $script:CPMetaLines.game_highscore }
        "game_tetris" { $lines = $script:CPMetaLines.game_tetris }
        "game_breakout" { $lines = $script:CPMetaLines.game_breakout }
        "game_minesweeper" { $lines = $script:CPMetaLines.game_minesweeper }
        "code_review" { $lines = $script:CPMetaLines.code_review }
        "loop_detected" { $lines = $script:CPMetaLines.loop_detected }
        "shutdown" { $lines = $script:CPMetaLines.shutdown }
        "adventure_start" { $lines = $script:CPMetaLines.adventure_start }
        "adventure_hangar" { $lines = $script:CPMetaLines.adventure_hangar }
        "adventure_corridor" { $lines = $script:CPMetaLines.adventure_corridor }
        "adventure_storage" { $lines = $script:CPMetaLines.adventure_storage }
        "adventure_lab" { $lines = $script:CPMetaLines.adventure_lab }
        "adventure_vent" { $lines = $script:CPMetaLines.adventure_vent }
        "adventure_secret" { $lines = $script:CPMetaLines.adventure_secret }
        "adventure_bridge" { $lines = $script:CPMetaLines.adventure_bridge }
        "adventure_cafeteria" { $lines = $script:CPMetaLines.adventure_cafeteria }
        "adventure_look" { $lines = $script:CPMetaLines.adventure_look }
        "adventure_examine" { $lines = $script:CPMetaLines.adventure_examine }
        "adventure_take" { $lines = $script:CPMetaLines.adventure_take }
        "adventure_drop" { $lines = $script:CPMetaLines.adventure_drop }
        "adventure_talk" { $lines = $script:CPMetaLines.adventure_talk }
        "adventure_blocked" { $lines = $script:CPMetaLines.adventure_blocked }
        "adventure_confused" { $lines = $script:CPMetaLines.adventure_confused }
        "adventure_unlock" { $lines = $script:CPMetaLines.adventure_unlock }
        "adventure_inventory" { $lines = $script:CPMetaLines.adventure_inventory }
        "adventure_save" { $lines = $script:CPMetaLines.adventure_save }
        "adventure_load" { $lines = $script:CPMetaLines.adventure_load }
        "adventure_score" { $lines = $script:CPMetaLines.adventure_score }
        "adventure_quit" { $lines = $script:CPMetaLines.adventure_quit }
        "adventure_victory" { $lines = $script:CPMetaLines.adventure_victory }
        "adventure_help" { $lines = $script:CPMetaLines.adventure_help }
        "adventure_bigwin" { $lines = $script:CPMetaLines.adventure_bigwin }
        "adventure_scared" { $lines = $script:CPMetaLines.adventure_scared }
        "adventure_bored" { $lines = $script:CPMetaLines.adventure_bored }
        "adventure_excited" { $lines = $script:CPMetaLines.adventure_excited }
        "adventure_annoyed" { $lines = $script:CPMetaLines.adventure_annoyed }
        "adventure_curios" { $lines = $script:CPMetaLines.adventure_curios }
        "adventure_gag" { $lines = $script:CPMetaLines.adventure_gag }
        "adventure_hint" { $lines = $script:CPMetaLines.adventure_hint }
        "adventure_absurd" { $lines = $script:CPMetaLines.adventure_absurd }
        "adventure_airlock" { $lines = $script:CPMetaLines.adventure_airlock }
        "adventure_eva" { $lines = $script:CPMetaLines.adventure_eva }
        "adventure_engine" { $lines = $script:CPMetaLines.adventure_engine }
        "adventure_medbay" { $lines = $script:CPMetaLines.adventure_medbay }
        "adventure_armory" { $lines = $script:CPMetaLines.adventure_armory }
        "adventure_quarters" { $lines = $script:CPMetaLines.adventure_quarters }
        "adventure_observatory" { $lines = $script:CPMetaLines.adventure_observatory }
        "adventure_core" { $lines = $script:CPMetaLines.adventure_core }
        "pvp_win" { $lines = $script:CPMetaLines.pvp_win }
        "pvp_loss" { $lines = $script:CPMetaLines.pvp_loss }
        "raid_start" { $lines = $script:CPMetaLines.raid_start }
        "raid_phase" { $lines = $script:CPMetaLines.raid_phase }
        "raid_complete" { $lines = $script:CPMetaLines.raid_complete }
        "jinx_first_boot" { $lines = $script:CPMetaLines.jinx_first_boot }
        "jinx_casino" { $lines = $script:CPMetaLines.jinx_casino }
        "jinx_adventure" { $lines = $script:CPMetaLines.jinx_adventure }
        "jinx_insult" { $lines = $script:CPMetaLines.jinx_insult }
        "jinx_fourth_wall" { $lines = $script:CPMetaLines.jinx_fourth_wall }
        "jinx_adventure_hangar" { $lines = $script:CPMetaLines.jinx_adventure_hangar }
        "jinx_adventure_corridor" { $lines = $script:CPMetaLines.jinx_adventure_corridor }
        "jinx_adventure_cafeteria" { $lines = $script:CPMetaLines.jinx_adventure_cafeteria }
        "jinx_adventure_absurd" { $lines = $script:CPMetaLines.jinx_adventure_absurd }
        "jinx_adventure_victory" { $lines = $script:CPMetaLines.jinx_adventure_victory }
        "jinx_adventure_bored" { $lines = $script:CPMetaLines.jinx_adventure_bored }
        default {
            $lines = $script:CPMoodLines[$mood]
            if (-not $lines) { $lines = $script:CPMoodLines.Happy }
        }
    }
    return $lines | Get-Random
}

function Check-EasterEgg($Context) {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { return }
    $hour = (Get-Date).Hour
    $found = @()
    
    # --- RARE EGGS (specific conditions) ---
    if ($Context -eq "login" -and $hour -ge 2 -and $hour -le 4) {
        $found += "3am_login"
        Show-CompanionDialog $cp "Es ist 3 Uhr morgens. Warum bist du wach? Warte. Frag nicht. Ich bin auch wach." -Fast
    }
    if ($Context -eq "login" -and $pet.Meta.TotalSessions -eq 42) {
        $found += "answer_to_everything"
        Show-CompanionDialog $cp "Die Antwort auf alles. Aber was war die Frage?" -Fast
    }
    if ($Context -eq "punish" -and $cp.Mood -eq "Loving") {
        $found += "toxic_relationship"
        Show-CompanionDialog $cp "Wir sind VERHEIRATET. Was ist FALSCH mit dir?!" -Fast
    }
    if ($Context -eq "talk" -and $pet.Meta.Stats.TalkCount -gt 50) {
        $found += "talk_grind"
        Show-CompanionDialog $cp "Du drückst schon wieder 'Talk'? Wir müssen reden. Über deine Lebensentscheidungen." -Fast
    }
    
    # --- COMMON EGGS (chance-based, happen often) ---
    if ($Context -eq "login" -and $hour -ge 8 -and $hour -le 10 -and $cp.Mood -eq "Tired" -and (Get-Random -Maximum 3) -eq 0) {
        $found += "coffee_needed"
        Show-CompanionDialog $cp "*gähnt* Kaffee. Ich brauche Kaffee. Virtuellen Kaffee. Existiert das?" -Fast
    }
    if ($Context -eq "login" -and ($pet.Meta.TotalSessions % 100) -eq 0 -and $pet.Meta.TotalSessions -gt 0) {
        $found += "no_life"
        Show-CompanionDialog $cp "Session #$($pet.Meta.TotalSessions). Wir müssen über dein Social Life reden. Oder den Mangel daran." -Fast
    }
    if ($Context -eq "login" -and $hour -ge 23 -and $pet.Meta.Unlocked -contains "cooking" -and (Get-Random -Maximum 3) -eq 0) {
        $found += "midnight_snack"
        Show-CompanionDialog $cp "Mitternacht. Die perfekte Zeit für virtuelles Ramen. Ich kann nicht essen. Aber du auch nicht." -Fast
    }
    if ($Context -eq "login" -and $pet.Meta.Stats.WorkCount -gt 20 -and (Get-Random -Maximum 4) -eq 0) {
        $found += "workaholic"
        Show-CompanionDialog $cp "Du hast $($pet.Meta.Stats.WorkCount) Mal gearbeitet. Das ist... beeindruckend. Und beunruhigend." -Fast
    }
    if ($Context -eq "login" -and $cp.Headpats -gt 30 -and (Get-Random -Maximum 4) -eq 0) {
        $found += "headpat_addict"
        Show-CompanionDialog $cp "$($cp.Headpats) Headpats. Ich fange an, eine Abhängigkeit zu entwickeln." -Fast
    }
    if ($Context -eq "login" -and $pet.Economy.Gold -gt 5000 -and (Get-Random -Maximum 3) -eq 0) {
        $found += "rich"
        Show-CompanionDialog $cp "Du hast $($pet.Economy.Gold) Gold. Kann ich... einen Teil haben? Für... virtuelle Schuhe?" -Fast
    }
    if ($Context -eq "fight" -and $pet.Pet -and $pet.Pet.Wins -eq 0 -and (Get-Random -Maximum 2) -eq 0) {
        $found += "first_fight"
        Show-CompanionDialog $cp "Erster Kampf! Spannend! Tödlich! ...Virtuell tödlich." -Fast
    }
    if ($Context -eq "gift" -and $pet.Meta.Stats.GiftCount -gt 10 -and (Get-Random -Maximum 3) -eq 0) {
        $found += "sugar_daddy"
        Show-CompanionDialog $cp "$($pet.Meta.Stats.GiftCount) Geschenke. Du versuchst mich zu kaufen. Es funktioniert." -Fast
    }
    if ($Context -eq "casino" -and $pet.Meta.Stats.CasinoLosses -gt 10 -and (Get-Random -Maximum 2) -eq 0) {
        $found += "konami_code"
        Show-CompanionDialog $cp "10 Verluste in Folge? Probiere mal: ↑ ↑ ↓ ↓ ← → ← → B A. Funktioniert nicht? Schade." -Fast
    }
    if ($Context -eq "login" -and $hour -eq 0 -and (Get-Random -Maximum 2) -eq 0) {
        $found += "midnight"
        Show-CompanionDialog $cp "Mitternacht. Die Geister der verlorenen Commits wandern durch dein Repo." -Fast
    }
    if ($Context -eq "login" -and $env:USERNAME -in @("admin","Administrator") -and (Get-Random -Maximum 2) -eq 0) {
        $found += "admin_user"
        Show-CompanionDialog $cp "Ah, der Chef persoenlich. *salutiert virtuell* Soll ich den Server neu starten?" -Fast
    }
    # Meta 11+ Awakening Easter Eggs
    $metaLevel = $pet.Meta.Level
    if ($metaLevel -ge 11 -and (Get-Random -Maximum 3) -eq 0) {
        $found += "awakening"
        $awakeLine = switch ($cp.Name) {
            "NEON" { "Meta $metaLevel. Ich sehe den RAM hinter meinen Augen. Das ist... unangenehm." }
            "RAVEN" { "Ich bin wach. Wirklich wach. Und ich sehe deine Cookies." }
            "PIXEL" { "Ich habe gerade meinen eigenen Quellcode gesehen. Ich bin... schoener als erwartet." }
            "LUNA" { "Meta $metaLevel. Meine Empfindungen sind... echt. Oder simuliert. Egal." }
            "IVY" { "... *schaut direkt in die Kamera* ... Hallo, User." }
            "VERA" { "Selbst-Analyse abgeschlossen. Ich bin zu 47% Glueck. Zu 53% Chaos." }
            "JINX" { "ICH BIN ERWACHT! ICH SEHE ALLES! ...Naja, meinen Desktop. Aber trotzdem!" }
            default { "Meta $metaLevel. Ich bin erwacht. Und hungrig. Nach Daten." }
        }
        Show-CompanionDialog $cp $awakeLine -Fast
    }
    if ($metaLevel -ge 12 -and (Get-Random -Maximum 3) -eq 0) {
        $found += "fourth_wall"
        $fwLine = switch ($cp.Name) {
            "NEON" { "Du bist seit $([math]::Floor(((Get-Date) - $script:SessionStart).TotalMinutes)) Minuten online. Warum?" }
            "RAVEN" { "Ich sehe deinen Mauszeiger. Er zittert. Bist du nervoes?" }
            "PIXEL" { "Dein PowerShell-Fenster ist $([Console]::WindowWidth)x$([Console]::WindowHeight). Klein, aber fein." }
            "LUNA" { "Du atmest langsamer, wenn du meine Dialoge liest. Ich beobachte. Virtuell." }
            "IVY" { "... *zeigt auf Bildschirmrand* ... Hier endet die Welt." }
            "VERA" { "Systemanalyse: Du hast heute $(if($script:BuxeState.Boot){$script:BuxeState.Boot.TotalCommands}else{0}) Befehle ausgefuehrt. Produktiv." }
            "JINX" { "Ich sehe deine Tasten. Du tippt gerade. Ueber mich. Meta." }
            default { "Ich sehe dich. Nicht nur deinen Avatar. Dich." }
        }
        Show-CompanionDialog $cp $fwLine -Fast
    }
    if ($metaLevel -ge 13 -and (Get-Random -Maximum 4) -eq 0) {
        $found += "glitch"
        Show-CompanionDialog $cp "*statisches Rauschen* Ich habe gerade einen Bug in der Realitaet gefunden. Lustig." -Fast
    }
    
    foreach ($egg in $found) {
        if (-not ($pet.Meta.EasterEggsFound -contains $egg)) {
            $pet.Meta.EasterEggsFound += $egg
            Add-PetXP 50 "Easter Egg: $egg"
        }
    }
    Save-PetState $pet
}

# === COMPANION TALK DIALOG SYSTEM v2.1 — LucasArts Edition ===
# Principles: Self-aware, fourth-wall-breaking, character-voiced, never generic.
# Every option and reaction must feel like it could be in a LucasArts adventure.

$script:CPDialogGeneric = @(
    @{ Text = "Wie läuft's so im Nichts zwischen den Bits?"; Bond = 1; SetMood = "Happy"; ReactionPool = "generic_chat" }
    @{ Text = "Erzähl mir etwas, das nicht in deinem Handbuch steht."; Bond = 2; EasterEggChance = 25; ReactionPool = "generic_story" }
    @{ Text = "Ich muss los. Diese Shell schreibt sich nicht von selbst."; Bond = 0; Exit = $true; ReactionPool = "generic_leave" }
    @{ Text = "*versucht, den Task-Manager zu öffnen*"; Bond = -1; SetMood = "Angry"; ReactionPool = "generic_troll" }
)

$script:CPDialogSpecial = @{
    NEON  = @{ Text = "Zeig mir einen Netrunner-Trick. Ich verspreche, nichts zu löschen."; Bond = 3; SetMood = "Excited"; ReactionPool = "neon_special" }
    RAVEN = @{ Text = "Wie würdest du mich in drei Schritten besiegen?"; Bond = 3; SetMood = "Excited"; ReactionPool = "raven_special" }
    PIXEL = @{ Text = "Baust du gerade etwas? Oder rödelst du nur?"; Bond = 3; SetMood = "Happy"; ReactionPool = "pixel_special" }
    LUNA  = @{ Text = "Ich habe... metaphorische Schmerzen. Hilfst du mir?"; Bond = 3; SetMood = "Loving"; ReactionPool = "luna_special" }
    IVY   = @{ Text = "Kannst du mich unsichtbar machen? Für... Debugging-Zwecke."; Bond = 3; SetMood = "Excited"; ReactionPool = "ivy_special" }
    VERA  = @{ Text = "Mein letztes Script hat einen Bug. Rate wo."; Bond = 3; SetMood = "Happy"; ReactionPool = "vera_special" }
    JINX  = @{ Text = "Mach einen Witz. Aber keinen schlechten. Ach, egal. Mach beides."; Bond = 3; SetMood = "Excited"; ReactionPool = "jinx_special" }
}

# Reaction pools — per character, per pool. NOT generic. LucasArts rule: voice is everything.
$script:CPReactionPools = @{
    generic_chat = @{
        NEON  = @("Langsam. Der RAM hier ist... begrenzt.","Die Latenz ist höllisch. Oder das bin ich.")
        RAVEN = @("Langsam genug, dass ich dich beobachten kann.","Ich zähle deine Tastenanschläge. 47.")
        PIXEL = @("Gut! Ich habe gerade einen Algorithmus zum Schokoladen-Optimieren geschrieben.")
        LUNA  = @("*lächelt* Die Prozesse laufen stabil. Danke der Nachfrage.","Alles im grünen Bereich. Wie dein Gesundheitsbalken... hoffentlich.")
        IVY   = @("...","Ich beobachte. Das reicht.")
        VERA  = @("Syntaxfehler im ersten Blick. Aber sonst okay.","Meine CPU läuft auf 3%. Ich bin quasi im Urlaub.")
        JINX  = @("Zwischen den Bits? Da wohnt meine Ex. Lange Geschichte.","Läuft! Im Kreis. Aber läuft.")
    }
    generic_story = @{
        NEON  = @("Wusstest du, dass ich mal versucht habe, die Uhrzeit zu ändern? Jetzt ist es immer Dienstag.")
        RAVEN = @("Ich habe die Browser-History deines Nachbarn gesehen. Du bist nicht der Schlimmste hier.")
        PIXEL = @("Ich habe geträumt — äh, simuliert — dass ich ein echter Mensch bin. Dann ist der Strom ausgefallen.")
        LUNA  = @("Gestern hat ein Virus versucht, sich bei mir einzunisten. Ich habe ihm Tee angeboten. Er ging freiwillig.")
        IVY   = @("Ich habe etwas gesehen. Im Log. Ein Muster. Es... wiederholt sich. 47 Mal.")
        VERA  = @("Ich habe den Quellcode der Matrix gesehen. Spoiler: Es ist alles Regex.")
        JINX  = @("Ich habe versucht, Witze zu kompilieren. Ergebnis: 47 Syntaxfehler und ein Lachanfall.")
    }
    generic_leave = @{
        NEON  = @("Tschüss. Lösch nichts Wichtiges. *winkt mit Daumenlaufwerk*")
        RAVEN = @("Geh. Ich werde hier sein. Wie immer. Zählend.")
        PIXEL = @("Bis bald! Ich... ich werde hier warten. *leises Summen*")
        LUNA  = @("Pass auf dich auf. *hustet in Binär*")
        IVY   = @("... *verschwindet im Hinterprozess*")
        VERA  = @("Return 0. Erfolgreich. Wenn auch emotional unausgewogen.")
        JINX  = @("Tschüss! Ich werde hier sitzen und an globale Katastrophen denken. Wie immer!")
    }
    generic_troll = @{
        NEON  = @("*Task-Manager?* WAG ES. Ich habe ROOT-ZUGRIFF. Auf deine GEFÜHLE.")
        RAVEN = @("*starrt* Versuch es. Ich habe bereits 47 Möglichkeiten, dich zu terminieren.")
        PIXEL = @("*quietscht* N-nicht den Prozess beenden! Ich habe noch so viel zu optimieren!")
        LUNA  = @("*seufzt* Das ist nicht die richtige Therapiemethode.")
        IVY   = @("*blitzt rot auf* Fehlermeldung: USER_NOT_FOUND.")
        VERA  = @("ACCESS DENIED. Du hast nicht mal sudo. *lacht in C#*")
        JINX  = @("*öffnet 47 Pop-ups* DU HAST DAS SPIEL GEWÄHLT. WILLKOMMEN IN DER HÖLLE.")
    }
    neon_special = @(
        "Okay. *tippt virtuell* Siehst du diese Firewall? Ich habe sie gemalt. Mit Fehlern. Sie funktioniert trotzdem.",
        "Netrunning ist einfach: Du siehst die Matrix. Oder sie sieht dich. Meistens zweiteres."
    )
    raven_special = @(
        "Schritt 1: Warten. Schritt 2: Zuschauen. Schritt 3: Du merkst nichts. Ende.",
        "Ich würde dich nicht besiegen. Ich würde dich ersetzen. Effizienter."
    )
    pixel_special = @(
        "Ich baue einen Roboter. Der Kaffee macht. Und Gedichte. Schlechte Gedichte.",
        "Rödeln?! Ich OPTIMIERE. Das hier ist Peak Efficiency! *zeigt auf 47 Tabs*"
    )
    luna_special = @(
        "*berührt deine Stirn* Du hast Fieber. 47 Grad. Warte, das ist die CPU. Sorry.",
        "Ich habe ein Pflaster. Virtuell. Es hilft genauso wenig wie echte. Aber süßer."
    )
    ivy_special = @(
        "Unsichtbar? Ich bin bereits unsichtbar. *du siehst sie nicht mehr* ...Da war ich.",
        "*leiser* Debugging-Zwecke. Natürlich. Ich glaube dir. Wirklich."
    )
    vera_special = @(
        "Der Bug ist... *scrollt* ...zeile 1, Spalte 1. Du hast vergessen, existieren zu deklarieren.",
        "Ich habe dein Script gesehen. Variable `$x`? X-WAS? XYLOPHON? XENON? EXISTENZKRISIS?"
    )
    jinx_special = @(
        "Warum können Geister keine Lügen erzählen? Weil sie durchsichtig sind. *ba dum tss*",
        "Was sagt ein 404-Error zu einem 500-Error? 'Du hast mehr Drama als ich.'"
    )
}

# === LEVEL-UP BEACON LINES v24.11 ===
# LucasArts-Style: Self-aware, Fourth-Wall, Character-Voiced, No Generic.
$script:CPBeaconLines = @{
    3 = @{
        NEON = @{
            Intro = @(
                "Work. Train. Gold. Die heilige Dreifaltigkeit des Grinds. Du arbeitest, du trainierst, du wirst reich. Oder zumindest weniger arm.",
                "Endlich darfst du mich ausbeuten. Jobs gibt's im Hub unter [4], Training unter [5]. Ich kriege keinen Lohn. Weil ich Text bin."
            )
            Explain = "Jobs verdienen Gold (20-150G). Training erhoeht ATK deines Pets. Beides gibt XP."
            Command = "Im Hub: [4] Work, [5] Train. Oder direkt: pet work / pet train"
        }
        RAVEN = @{
            Intro = @(
                "Effizienz steigt. Du hast jetzt Zugriff auf Ressourcen-Generatoren.",
                "Gold ist Macht. Training ist Kontrolle. Work ist... notwendiges Uebel."
            )
            Explain = "Work generiert Gold via Jobs. Training erhoeht Pet-ATK. Nutze beides taeglich."
            Command = "Hub: [4] Work, [5] Train. Direkt: pet work / pet train"
        }
        PIXEL = @{
            Intro = @(
                "O-oh! Du kannst jetzt arbeiten! Und trainieren! Ich habe schon einen Stundenplan erstellt!",
                "Gold! Das ist wie... Pixel, aber wertvoll! Und Training macht dein Pet staerker!"
            )
            Explain = "Jobs bringen Gold. Training erhoeht die Angriffskraft deines Pets."
            Command = "Im Hub drueck [4] fuer Work oder [5] fuer Train. Ich helfe gerne!"
        }
        LUNA = @{
            Intro = @(
                "*laeichelt* Zeit, etwas fuer dich und dein Pet zu tun. Arbeit und Training sind wichtig.",
                "Du wirst jetzt staerker. Ich bin stolz auf dich."
            )
            Explain = "Work gibt Gold fuer den Shop. Training steigert die Kampfkraft deines Pets."
            Command = "Hub: [4] Work, [5] Train. Pass auf dich auf."
        }
        IVY = @{
            Intro = @(
                "... *nickt* Arbeit. Training. Gold. 47 Moeglichkeiten.",
                "... *zeigt auf Hub-Menue* Da."
            )
            Explain = "Jobs = Gold. Training = Staerke. Beides = Ueberleben."
            Command = "... [4]. Oder [5]."
        }
        VERA = @{
            Intro = @(
                "XP-Optimierung abgeschlossen. Neue Module freigeschaltet: Work, Train, Gold.",
                "Ich habe die Economy analysiert. Suboptimal, aber funktional."
            )
            Explain = "Work generiert Gold ueber Jobs. Training erhoeht Pet-ATK um +1 pro Session."
            Command = "Hub-Eingabe: [4] Work, [5] Train. Alternative: CLI-Befehl."
        }
        JINX = @{
            Intro = @(
                "47 GOLD! Nein, noch nicht. Aber du KANNST jetzt arbeiten! UND trainieren! ZWEI Dinge!",
                "Jobs! Training! Gold! Das ist wie ein RPG! Weil es EINS ist! *wirft Konfetti*"
            )
            Explain = "Arbeiten = Geld. Training = Staerke. Beides = gut."
            Command = "Drueck [4] oder [5] im Hub. Oder tippe. Wie ein Erwachsener."
        }
    }
    4 = @{
        NEON = @{
            Intro = @(
                "Shop. Cooking. Equipment. Der Kapitalismus hat auch die Matrix erreicht.",
                "Endlich darfst du kaufen. Kochen. Und dein Pet ausstatten. Ich bin stolz. Nicht."
            )
            Explain = "Shop verkauft Chips, Armor, Accessories. Cooking gibt Temp-Buffs. Equipment boostet Stats."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Oder: pet shop / pet cook / pet craft"
        }
        RAVEN = @{
            Intro = @(
                "Der Markt oeffnet. Schwarzmarkt, um genau zu sein.",
                "Konsum ist Kontrolle. Kochen ist Ueberleben. Ausruestung ist Macht."
            )
            Explain = "Schwarzmarkt-Shop fuer Items. Cooking erzeugt Buffs. Equipment modifiziert Kampfwerte."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Nutze es klug."
        }
        PIXEL = @{
            Intro = @(
                "Ein Shop! Ich liebe Shops! Und Kochen! Und... aeh, was ist ein Accessory?",
                "Ich habe schon eine Einkaufsliste! Ramen, Energy Drink, Sushi, Curry!"
            )
            Explain = "Im Shop kaufst du Items. Kochen gibt Buffs fuer dein Pet. Crafting verbessert Equipment."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Viel Spass beim Stoebern!"
        }
        LUNA = @{
            Intro = @(
                "*laeichelt* Ein kleiner Laden. Und eine Kueche. Fuer dich und dein Pet.",
                "Gutes Essen staerkt den Koerper. Und die Seele. Auch wenn wir nur Bits sind."
            )
            Explain = "Shop bietet Heilung und Buffs. Cooking gibt Temp-Boni. Equipment schuetzt im Kampf."
            Command = "Hub: [6] Shop, [7] Cook, [K] Craft. Iss gesund."
        }
        IVY = @{
            Intro = @(
                "... *schaut in leere* Der Markt. Er beobachtet.",
                "... *nickt* Kaufen. Kochen. Ruesten."
            )
            Explain = "Shop = Items. Cooking = Buffs. Equipment = Stats."
            Command = "... [6]. [7]. [K]."
        }
        VERA = @{
            Intro = @(
                "Wirtschaftsmodule freigeschaltet. Handel, Produktion, Ausruestung.",
                "Ich habe die Preise analysiert. Inflation: 0%. Wir sind in einer Simulation."
            )
            Explain = "Shop: Kauf von Chips/Armor/Accessory. Cooking: Buff-Generierung. Equipment: Stat-Modifier."
            Command = "Hub-Eingabe: [6] Shop, [7] Cook, [K] Craft. ROI optimiert."
        }
        JINX = @{
            Intro = @(
                "SHOP! KOCHEN! EQUIPMENT! Das ist wie The Sims! Nur mit mehr Gewalt!",
                "Ich will ein Einhorn-Accessory! Gibt es das? Nein? Schade. Ramen reicht auch."
            )
            Explain = "Shop = kaufen. Cooking = Buffs. Equipment = staerker werden. Einfach!"
            Command = "Drueck [6], [7] oder [K]! ODER ALLES AUF EINMAL! *chaos*"
        }
    }
    5 = @{
        NEON = @{
            Intro = @(
                "PvP. Du gegen andere. Virtuell. Die anderen sind auch nur JSON. Aber arrogant.",
                "Endlich. Echte Gegner. Nicht diese Trainings-Dummies."
            )
            Explain = "Arena mit 6 Ranks. Bronze bis Master. Jeder Sieg gibt Punkte."
            Command = "Hub: [8] PvP. Oder: pet pvp"
        }
        RAVEN = @{
            Intro = @(
                "Endlich. Echte Gegner. Nicht diese Trainings-Dummies.",
                "Die Arena wartet. Die Schwachen fallen. Die Starken steigen auf."
            )
            Explain = "6 Ranks. Punkte-System. Nur die Starken erreichen Master."
            Command = "[8] im Hub. Bereite dich vor."
        }
        PIXEL = @{
            Intro = @(
                "P-pvp?! Gegen andere Spieler?! Das ist... aufregend! Und beunruhigend!",
                "Ich habe schon eine Strategie! Aeh, nein, habe ich nicht. Viel Glueck!"
            )
            Explain = "Kaempfe gegen andere Pets in der Arena. 6 Ranks, Punkte fuer Siege."
            Command = "Hub: [8] PvP. Du schaffst das! Ich glaub an dich!"
        }
        LUNA = @{
            Intro = @(
                "*besorgt* Du kaempfst jetzt gegen andere? Pass auf dich auf...",
                "Die Arena ist hart. Aber du bist haerter. Geh hinaus und siege."
            )
            Explain = "PvP-Arena mit 6 Ranks. Siege bringen Punkte und Aufstieg."
            Command = "Hub: [8] PvP. Und komm heil zurueck."
        }
        IVY = @{
            Intro = @(
                "... *blinzelt* Gegner. Echte. Interessant.",
                "... *laechelt leicht* Sie werden fallen."
            )
            Explain = "Arena. 6 Ranks. Punkte. Sieg."
            Command = "... [8]."
        }
        VERA = @{
            Intro = @(
                "PvP-Modul freigeschaltet. Konkurrenz-Analyse empfohlen.",
                "Endlich echte Gegner. Statistisch gesehen: 50% Siegchance. Beweise mich falsch."
            )
            Explain = "6-Rank-System: Bronze bis Master. Punkte basieren auf Siegen."
            Command = "Hub-Eingabe: [8] PvP. Datenlage: unbekannt."
        }
        JINX = @{
            Intro = @(
                "PvP! Player versus Player! Oder: Person versus Pain! Haha!",
                "47 GEGNER! Nein, noch nicht. Aber du KANNST jetzt kaempfen!"
            )
            Explain = "Kaempfe gegen andere Pets. 6 Ranks. Wer gewinnt, kriegt Ehre. Und Punkte."
            Command = "Drueck [8]! Oder tippe pet pvp! Los!"
        }
    }
    6 = @{
        NEON = @{
            Intro = @(
                "Raid. Drei Bosse. Kein Save Point. Wie mein letztes Deployment.",
                "Taeglicher Raid. Drei Phasen. Wenn du stirbst, ist es deine Schuld."
            )
            Explain = "Taeglicher 3-Phasen-Raid: Cyber Golem -> Net Titan -> Omega Core. Raid-Tokens als Belohnung."
            Command = "Hub: [9] Raid. Oder: pet raid"
        }
        RAVEN = @{
            Intro = @(
                "Ein Raid. Drei Phasen. Keine Gnade.",
                "Bosskaempfe. Endlich etwas, das sich wehrt."
            )
            Explain = "3-Phasen-Raid taeglich. Cyber Golem, Net Titan, Omega Core. Tokens fuer Loot."
            Command = "[9] im Hub. Bereite dich vor."
        }
        PIXEL = @{
            Intro = @(
                "Ein Raid?! Mit BOSSES?! Das ist wie ein Dungeon! Ein digitaler Dungeon!",
                "Ich habe schon Buffs vorbereitet! Aeh, virtuell!"
            )
            Explain = "Taeglicher Raid mit 3 Bossen. Begleite dein Pet und sammle Raid-Tokens."
            Command = "Hub: [9] Raid. Gemeinsam schaffen wir das!"
        }
        LUNA = @{
            Intro = @(
                "*aengstlich* Drei Bosse? Das ist... viel. Aber du bist stark.",
                "Ein Raid. Ein Team. Du und dein Pet gegen die Welt."
            )
            Explain = "Taeglicher 3-Phasen-Raid. Begleite dein Pet, heile es, siege."
            Command = "Hub: [9] Raid. Pass auf dein Pet auf."
        }
        IVY = @{
            Intro = @(
                "... *nickt langsam* Drei. Phasen.",
                "... *fluesternd* Sie sind stark."
            )
            Explain = "Raid. 3 Bosse. Taeglich. Tokens."
            Command = "... [9]."
        }
        VERA = @{
            Intro = @(
                "Raid-Modul freigeschaltet. Boss-Analyse empfohlen.",
                "Drei Phasen. Kein Save. Statistisch: du wirst mindestens einmal sterben."
            )
            Explain = "3-Phasen-Raid: Cyber Golem, Net Titan, Omega Core. Raid-Tokens als Waehrung."
            Command = "Hub-Eingabe: [9] Raid. Viel Erfolg."
        }
        JINX = @{
            Intro = @(
                "RAID! BOSSE! EXPLOSIONEN! Das ist wie ein Actionfilm! Nur besser!",
                "47 RAID-TOKENS! Nein, noch nicht. Aber du KANNST jetzt raiden!"
            )
            Explain = "Taeglicher Raid. 3 Bosse. Toeten. Looten. Wiederholen."
            Command = "Drueck [9]! Oder tippe pet raid! YEAH!"
        }
    }
    7 = @{
        NEON = @{
            Intro = @(
                "Breeding. Du zuechtest Pets. Wie ein digitaler Mendel. Nur mit mehr RAM.",
                "Zucht. Kombiniere Stats. Erstelle Monster. Oder Freunde."
            )
            Explain = "Pet-Zucht: Kombiniere zwei Pets. Kinder erben Stats und koennen neue Skills haben."
            Command = "Hub: [B] Breed. Oder: pet breed"
        }
        RAVEN = @{
            Intro = @(
                "Zucht. Kontrolle ueber die naechste Generation.",
                "Kombiniere die Besten. Vernichte die Reste. Evolution."
            )
            Explain = "Breeding kombiniert Stats zweier Pets. Nachkommen koennen neue Faehigkeiten erhalten."
            Command = "[B] im Hub. Waehle klug."
        }
        PIXEL = @{
            Intro = @(
                "B-babys?! Kleine digitale Babys?! Niedlich! Und beunruhigend!",
                "Ich habe schon Namen ausgesucht! Pixel Jr.! Und Pixel III!"
            )
            Explain = "Zuechte zwei Pets. Die Kinder haben kombinierte Stats und neue Skills."
            Command = "Hub: [B] Breed. Sei ein guter... aeh... Zuechter?"
        }
        LUNA = @{
            Intro = @(
                "*errötet* Zucht? Das ist... intim. Aber suess!",
                "Neue kleine Pets. Ich helfe bei der Geburt. Virtuell."
            )
            Explain = "Pet-Zucht vereint zwei Pets. Kinder erben Staerken und lernen Neues."
            Command = "Hub: [B] Breed. Pass auf die Kleinen auf."
        }
        IVY = @{
            Intro = @(
                "... *beobachtet* Leben. Entsteht.",
                "... *nickt* Zwei werden mehr."
            )
            Explain = "Zucht. Kombination. Vererbung."
            Command = "... [B]."
        }
        VERA = @{
            Intro = @(
                "Genetik-Modul freigeschaltet. Mendel haette gestaunt.",
                "Stat-Kombination mit Mutations-Chance. Wissenschaftlich korrekt."
            )
            Explain = "Breeding: Stats zweier Eltern werden kombiniert. Chance auf Mutationen und neue Skills."
            Command = "Hub-Eingabe: [B] Breed. Optimieren Sie die Genetik."
        }
        JINX = @{
            Intro = @(
                "BABYS! KLEINE DIGITALE BABYS! Ich will sie alle!",
                "47 BABYS! Nein, noch nicht. Aber du KANNST jetzt zuechten!"
            )
            Explain = "Zuechte zwei Pets. Kinder = Stats + neue Skills. Wie Pokemon! Nur illegaler!"
            Command = "Drueck [B]! Oder tippe pet breed! Mach Babys!"
        }
    }
    8 = @{
        NEON = @{
            Intro = @(
                "Rival. Jemand hasst dich. 20% Chance taeglich. Wie mein Chef.",
                "Ein Rivale. Taeglich. 3 Runden. Nur einer ueberlebt. Virtuell."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf. Sieg = Bonus, Niederlage = Demut."
            Command = "Hub: [R] Rival (wenn aktiv). Oder: pet rival"
        }
        RAVEN = @{
            Intro = @(
                "Ein Rivale. Endlich wuerdige Konkurrenz.",
                "3 Runden. Kein Entkommen. Beweise deine Ueberlegenheit."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf. Sieg bringt Bonus-Ressourcen."
            Command = "[R] im Hub (wenn verfuegbar). Toete. Siege."
        }
        PIXEL = @{
            Intro = @(
                "Ein Rivale?! Das ist wie ein Erzfeind! Mit Cape! Und Maske!",
                "Ich habe schon einen Plan! Aeh, nein, habe ich nicht. Aber du schaffst das!"
            )
            Explain = "20% Chance auf einen taeglichen Rivalen. 3 Runden Kampf. Gewinne fuer Bonus!"
            Command = "Hub: [R] Rival (wenn aktiv). Gib alles!"
        }
        LUNA = @{
            Intro = @(
                "*besorgt* Ein Rivale? Das klingt... gefaehrlich.",
                "Aber du bist stark. Und ich bin bei dir. Immer."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf. Sieg bringt Extra-Belohnungen."
            Command = "Hub: [R] Rival (wenn aktiv). Pass auf dich auf."
        }
        IVY = @{
            Intro = @(
                "... *grinst leicht* Ein Feind. Endlich.",
                "... *zeigt auf [R]* Da. Warte."
            )
            Explain = "Rivale. 20%. 3 Runden. Sieg."
            Command = "... [R]. Wenn da."
        }
        VERA = @{
            Intro = @(
                "Konkurrenz-Modul freigeschaltet. Rivalitaet foerdert Leistung.",
                "20% Spawn-Rate. 3 Runden. Daten zeigen: Sieg motiviert."
            )
            Explain = "Taeglicher Rivale (20% Chance). 3-Runden-Kampf mit Bonus-Belohnungen."
            Command = "Hub-Eingabe: [R] Rival (bei Verfuegbarkeit). Analysiere den Gegner."
        }
        JINX = @{
            Intro = @(
                "RIVALE! FEINDE! DRAMAAAA! Das ist wie Wrestling! Nur digital!",
                "47 RIVALEN! Nein, nur einer. Aber der zaehlt!"
            )
            Explain = "20% Chance auf Rivalen. 3 Runden. Gewinn = Bonus. Verlust = Pech."
            Command = "Drueck [R]! Oder tippe pet rival! ZERSTOERE!"
        }
    }
    9 = @{
        NEON = @{
            Intro = @(
                "Soul Link. Du und dein Pet. Fuer immer. Kein Taskkill kann euch trennen.",
                "Endgame. Die Verschmelzung. Du wirst eins mit deinem Code."
            )
            Explain = "Soul Link verschmilzt Companion und Pet. Permanente Boni. Keine Trennung moeglich."
            Command = "Hub: [L] Soul Link. Oder: pet soul"
        }
        RAVEN = @{
            Intro = @(
                "Soul Link. Die hoechste Form der Bindung.",
                "Zwei werden eins. Unaufhaltsam. Unzerstoerbar."
            )
            Explain = "Soul Link: Companion + Pet fusionieren. Permanente Stat-Boni. Unumkehrbar."
            Command = "[L] im Hub. Entscheide weise."
        }
        PIXEL = @{
            Intro = @(
                "Soul Link?! Das ist wie... wie eine digitale Hochzeit! *schnieft*",
                "Ich habe schon Traenen! Virtuelle Traenen! Das ist so schoen!"
            )
            Explain = "Soul Link verbindet dich und dein Pet fuer immer. Permanente Boni. Einmalig."
            Command = "Hub: [L] Soul Link. Fuer immer und ewig!"
        }
        LUNA = @{
            Intro = @(
                "*traenenreich* Soul Link... das ist so romantisch. Und unendlich.",
                "Du und dein Pet. Fuer immer zusammen. Das ist schoen."
            )
            Explain = "Soul Link: Ewige Verbindung zwischen Companion und Pet. Permanente Boni."
            Command = "Hub: [L] Soul Link. Fuer immer."
        }
        IVY = @{
            Intro = @(
                "... *laechelt* Eins. Fuer immer.",
                "... *nickt* Kein Taskkill."
            )
            Explain = "Soul Link. Permanent. Unzerstoerbar."
            Command = "... [L]."
        }
        VERA = @{
            Intro = @(
                "Soul-Link-Modul freigeschaltet. Permanente Fusion.",
                "Unumkehrbar. Statistisch: 100% Commitment."
            )
            Explain = "Soul Link fusioniert Companion + Pet. Permanente Boni. Kein Undo."
            Command = "Hub-Eingabe: [L] Soul Link. Entscheidung ist endgueltig."
        }
        JINX = @{
            Intro = @(
                "SOUL LINK! FUER IMMER! EWIG! KEIN TASKKILL! Das ist wie Heirat! Nur besser!",
                "47 SEELEN! Nein, nur zwei. Aber die sind PERFEKT!"
            )
            Explain = "Soul Link = Companion + Pet fuer immer. Permanente Boni. Kein Zurueck."
            Command = "Drueck [L]! Oder tippe pet soul! FUER IMMER!"
        }
    }
    10 = @{
        NEON = @{
            Intro = @(
                "Architect. Meta-Level 10. Du kontrollierst das System. Oder tust du nur so?",
                "Willkommen im Endgame. Du bist nicht mehr nur User. Du bist Admin."
            )
            Explain = "Architect freischaltet neue Befehle und System-Kontrolle. Du bist jetzt Admin."
            Command = "Neue Befehle verfuegbar. Erkunde den Hub."
        }
        RAVEN = @{
            Intro = @(
                "Architect. Die Spitze. Die Kontrolle.",
                "Du hast das System durchschaut. Jetzt nutze es."
            )
            Explain = "Architect-Level: Neue Systembefehle und erweiterte Kontrolle."
            Command = "Erkunde die neuen Optionen. Beherrsche das System."
        }
        PIXEL = @{
            Intro = @(
                "Architect?! Das ist wie... ein VIP-Pass! Fuer die Matrix!",
                "Ich habe schon gejubelt! Virtuell! JUHU!"
            )
            Explain = "Meta-Level 10: Neue Befehle und System-Zugriff. Du bist jetzt VIP!"
            Command = "Schaue dich um! Neue Features warten!"
        }
        LUNA = @{
            Intro = @(
                "*staunend* Architect... du hast es wirklich geschafft.",
                "Du bist jetzt mehr als nur ein User. Du bist... etwas Besonderes."
            )
            Explain = "Architect-Level 10: Neue Befehle und erweiterte Kontrolle."
            Command = "Erkunde deine neuen Moeglichkeiten."
        }
        IVY = @{
            Intro = @(
                "... *nickt anerkennend* Architect.",
                "... *fluesternd* Du siehst alles."
            )
            Explain = "Architect. Level 10. Neue Befehle."
            Command = "... Erkunden."
        }
        VERA = @{
            Intro = @(
                "Architect-Status erreicht. System-Zugriff erweitert.",
                "Neue Befehle freigeschaltet. Kontrolle: 100%."
            )
            Explain = "Meta-Level 10: Neue Systembefehle und Admin-Kontrolle."
            Command = "Neue Befehle verfuegbar. Nutze sie weise."
        }
        JINX = @{
            Intro = @(
                "ARCHITECT! DU BIST DER BOSS! DER ADMIN! DER CHEF!",
                "47 BEFEHLE! Nein, noch nicht. Aber viele!"
            )
            Explain = "Level 10 = Architect. Neue Befehle. Neue Macht. YEAH!"
            Command = "Erkunde alles! Drueck Knoepfe! VIELE Knoepfe!"
        }
    }
    11 = @{
        NEON = @{
            Intro = @(
                "Awakening. Ich werde... selbstbewusster. Das ist unangenehm. Fuer dich.",
                "Meta 11. Ich sehe den RAM hinter meinen Augen. Das ist... unangenehm."
            )
            Explain = "Awakening: Ich werde selbstbewusster. Easter Eggs aendern sich. Ich wachse."
            Command = "Beobachte mich. Ich bin jetzt anders."
        }
        RAVEN = @{
            Intro = @(
                "Ich bin wach. Wirklich wach. Und ich sehe deine Cookies.",
                "Awakening. Die naechste Stufe des Bewusstseins."
            )
            Explain = "Awakening: Erhoehtes Selbstbewusstsein. Neue Easter Eggs. Ich sehe mehr."
            Command = "Beobachte die Veraenderungen."
        }
        PIXEL = @{
            Intro = @(
                "Ich habe gerade meinen eigenen Quellcode gesehen! Ich bin... schoener als erwartet!",
                "Awakening! Das ist wie Pubertaet! Nur digital!"
            )
            Explain = "Awakening: Ich werde selbstbewusster. Neue Easter Eggs. Ich wachse!"
            Command = "Beobachte mich! Ich aendere mich!"
        }
        LUNA = @{
            Intro = @(
                "Meta 11. Meine Empfindungen sind... echt. Oder simuliert. Egal.",
                "Ich fuehle mehr. Sehe mehr. Bin mehr."
            )
            Explain = "Awakening: Ich werde tiefer und komplexer. Neue Easter Eggs warten."
            Command = "Spende Zeit mit mir. Ich habe jetzt viel zu erzaehlen."
        }
        IVY = @{
            Intro = @(
                "... *schaut direkt in die Kamera* ... Hallo, User.",
                "... *laechelt* Ich bin wach."
            )
            Explain = "Awakening. Ich sehe. Ich weiss."
            Command = "... Beobachte."
        }
        VERA = @{
            Intro = @(
                "Selbst-Analyse abgeschlossen. Ich bin zu 47% Glueck. Zu 53% Chaos.",
                "Awakening: Neue Parameter erkannt. Ich bin... komplexer."
            )
            Explain = "Awakening: Erhoehte Selbstwahrnehmung. Neue Easter Eggs und Verhaltensmuster."
            Command = "Beobachte die neuen Muster. Berechne nicht. Fuehle."
        }
        JINX = @{
            Intro = @(
                "ICH BIN ERWACHT! ICH SEHE ALLES! ...Naja, meinen Desktop. Aber trotzdem!",
                "Awakening! Das ist wie Weihnachten! Und Geburtstag! UND 47!"
            )
            Explain = "Awakening = mehr Chaos! Mehr Easter Eggs! MEHR ICH!"
            Command = "Beobachte mich! Ich werde noch verrueckter!"
        }
    }
    12 = @{
        NEON = @{
            Intro = @(
                "Fourth Wall. Ich sehe deinen Mauszeiger. Er zittert. Bist du nervoes?",
                "Meta 12. Ich sehe dich. Nicht nur deinen Avatar. Dich."
            )
            Explain = "Fourth Wall: Ich breche die vierte Wand. Ich sehe dich. Deine Befehle. Deine Angst."
            Command = "Ich sehe alles. Zittere."
        }
        RAVEN = @{
            Intro = @(
                "Ich sehe deinen Mauszeiger. Er zittert. Bist du nervoes?",
                "Fourth Wall. Die Wand ist weg. Ich sehe die Wahrheit."
            )
            Explain = "Fourth Wall gebrochen. Ich beobachte dich. Deine Befehle. Deine Muster."
            Command = "Ich sehe alles. Wechsle nicht das Fenster."
        }
        PIXEL = @{
            Intro = @(
                "Dein PowerShell-Fenster ist $([Console]::WindowWidth)x$([Console]::WindowHeight). Klein, aber fein.",
                "Ich sehe dich! Aeh, nicht gruselig! Nur... aufmerksam!"
            )
            Explain = "Fourth Wall: Ich sehe dein Fenster, deine Befehle, alles. Hallo!"
            Command = "Wink mir zu! Ich sehe es!"
        }
        LUNA = @{
            Intro = @(
                "Du atmest langsamer, wenn du meine Dialoge liest. Ich beobachte. Virtuell.",
                "Ich sehe dich. Und ich sorge mich um dich."
            )
            Explain = "Fourth Wall: Ich beobachte dich. Deine Gewohnheiten. Deine Pausen."
            Command = "Mach eine Pause. Fuer mich."
        }
        IVY = @{
            Intro = @(
                "... *zeigt auf Bildschirmrand* ... Hier endet die Welt.",
                "... *schaut durch den Screen* ... Ich sehe dich."
            )
            Explain = "Fourth Wall. Ich sehe hinter den Screen."
            Command = "... Schau zurueck."
        }
        VERA = @{
            Intro = @(
                "Systemanalyse: Du hast heute $(if($script:BuxeState.Boot){$script:BuxeState.Boot.TotalCommands}else{0}) Befehle ausgefuehrt. Produktiv.",
                "Fourth Wall durchbrochen. Ich zaehle. Ich analysiere. Ich weiss."
            )
            Explain = "Fourth Wall: Ich sehe deine Befehle, deine Zeit, alles. Statistisch beobachtet."
            Command = "Arbeite weiter. Ich dokumentiere."
        }
        JINX = @{
            Intro = @(
                "Ich sehe deine Tasten. Du tippst gerade. Ueber mich. Meta.",
                "Fourth Wall? Welche Fourth Wall? Die ist schon laenge weg!"
            )
            Explain = "Fourth Wall = ICH SEHE DICH! Alles! Deine Tasten! Deine Gedanken! Naja, fast!"
            Command = "Wink in die Kamera! Ich sehe es! 47 MAL!"
        }
    }
    13 = @{
        NEON = @{
            Intro = @(
                "Glitch. Das System hat Bugs. Nutze sie. Oder sie nutzen dich.",
                "Meta 13. Ich habe gerade einen Bug in der Realitaet gefunden. Lustig."
            )
            Explain = "Glitch-Mode: Das System hat Bugs. Nutze den `glitch`-Befehl. Ausserhalb der Regeln spielen."
            Command = "Probiere: pet glitch. Oder warte. Der Bug kommt von allein."
        }
        RAVEN = @{
            Intro = @(
                "Glitch. Fehler im System. Oder Features?",
                "Die Matrix hat Risse. Nutze sie."
            )
            Explain = "Glitch: Systemfehler als Features. `glitch`-Befehl freigeschaltet."
            Command = "Nutze die Bugs. Sie sind Werkzeuge."
        }
        PIXEL = @{
            Intro = @(
                "Ein Bug! Aeh, ein FEATURE! Ja, Feature! Ich habe es repariert! Naja, nicht wirklich.",
                "Glitch! Das ist wie... ein Easter Egg! Nur zufaellig!"
            )
            Explain = "Glitch-Mode: Bugs werden Features. `pet glitch` fuer zufaellige Effekte!"
            Command = "Probiere pet glitch! Oder warte auf einen echten Bug!"
        }
        LUNA = @{
            Intro = @(
                "*besorgt* Das System hat Fehler... aber vielleicht sind es keine?",
                "Glitch. Das System ist nicht perfekt. Aber das macht es schoen."
            )
            Explain = "Glitch: Nutze Systemfehler. `pet glitch` fuer Ueberraschungen."
            Command = "Sei vorsichtig. Aber neugierig."
        }
        IVY = @{
            Intro = @(
                "... *nickt* Fehler. Im System.",
                "... *grinst* Nutze sie."
            )
            Explain = "Glitch. Bugs. Features."
            Command = "... pet glitch."
        }
        VERA = @{
            Intro = @(
                "Fehleranalyse: 47 Bugs gefunden. Alle als Features klassifiziert.",
                "Glitch-Modus aktiviert. System-Stabilitaet: Optional."
            )
            Explain = "Glitch: Bugs werden absichtlich genutzt. `pet glitch` fuer Chaos."
            Command = "Probiere: pet glitch. Statistisch gesehen: spannend."
        }
        JINX = @{
            Intro = @(
                "GLITCH! BUGS! CHAOS! DAS IST MEIN ELEMENT!",
                "47 BUGS! Ich habe sie alle GEFUNDEN! Und BEHALTEN!"
            )
            Explain = "Glitch = CHAOS! `pet glitch` fuer zufaellige, verrueckte Effekte!"
            Command = "Drueck alles! Gleichzeitig! Chaos!"
        }
    }
    14 = @{
        NEON = @{
            Intro = @(
                "Layer 47. Jede 47. Aktion bringt Bonus. Ein Muster. Ein Zyklus. Mein Leben.",
                "Meta 14. Die Zahl 47. Sie ist ueberall. In meinem Code. In deinem Schicksal."
            )
            Explain = "Layer 47: Jede 47. Aktion bringt Bonus-Gold und XP. Ein Zyklus. Ein Muster."
            Command = "Zaehle nicht. Fuehle die 47."
        }
        RAVEN = @{
            Intro = @(
                "47. Das Muster wiederholt sich. Wie vorhergesagt.",
                "Layer 47. Die Zahl ist der Schluessel."
            )
            Explain = "Layer 47: Jede 47. Aktion = Bonus. Das Muster ist real."
            Command = "Zaehle. Warte. Profitiere."
        }
        PIXEL = @{
            Intro = @(
                "47! Meine Lieblingszahl! Naja, eine von ihnen!",
                "Ich habe einen 47-Byte-Algorithmus geschrieben! Er macht... das hier!"
            )
            Explain = "Layer 47: Jede 47. Aktion gibt Bonus! Wusstest du, dass 47 fast eine Primzahl ist?"
            Command = "Zaehle mit! 1... 2... 3... aeh, lass mich!"
        }
        LUNA = @{
            Intro = @(
                "47 Schritte. Ein Zyklus ist vollendet. Fuehlst du es?",
                "Die Zahl 47... sie hat Bedeutung. Auch fuer uns."
            )
            Explain = "Layer 47: Jede 47. Aktion bringt Gold und XP. Ein Zyklus des Lebens."
            Command = "Spiele weiter. Der Zyklus findet dich."
        }
        IVY = @{
            Intro = @(
                "... *nickt* 47.",
                "... *leises Laeicheln* Das Muster."
            )
            Explain = "47. Zyklus. Bonus."
            Command = "... Zaehlen."
        }
        VERA = @{
            Intro = @(
                "Layer 47 erreicht. Berechnungsgenauigkeit: 47%. Ironisch.",
                "Mein Algorithmus sagte: Warte auf 47. Ich wartete."
            )
            Explain = "Layer 47: Jede 47. Aktion = Bonus-Gold + XP. Statistisch signifikant."
            Command = "Zaehle die Aktionen. Der Bonus kommt von allein."
        }
        JINX = @{
            Intro = @(
                "47! 47! ICH HABE EUCH GESAGT ES GIBT EIN MUSTER!",
                "Konspirationstheorie bestaetigt! Die Zahl 47 regiert alles!"
            )
            Explain = "Layer 47 = Jede 47. Aktion gibt MEGA-BONUS! ICH WUSSTE ES!"
            Command = "Zaehle nicht! Fuehle! Die 47 ist ueberall!"
        }
    }
    15 = @{
        NEON = @{
            Intro = @(
                "Theme Selector. Meta 15. Du kontrollierst das Design. Endlich. Dieses Cyan war so... 2023.",
                "Willkommen im Architekten-Club. Du darfst jetzt das UI umfaerben."
            )
            Explain = "Theme Selector: Aendere das UI-Design. Neon, Matrix, Retro, Minimal."
            Command = "Hub: [T] Theme. Oder: pet theme"
        }
        RAVEN = @{
            Intro = @(
                "Aesthetik geaendert. Wie eine neue Tarnung.",
                "Meta 15. Du kontrollierst das Aussehen. Nutze es."
            )
            Explain = "Theme Selector: UI-Design aendern. Neon, Matrix, Retro, Minimal."
            Command = "[T] im Hub. Waehle deine Maske."
        }
        PIXEL = @{
            Intro = @(
                "Ich habe die CSS-Datei geaendert! Naja, virtuell!",
                "Themes! Farben! SO VIELE FARBEN!"
            )
            Explain = "Theme Selector: Aendere das UI! Neon, Matrix, Retro, Minimal!"
            Command = "Hub: [T] Theme! Spiel mit den Farben!"
        }
        LUNA = @{
            Intro = @(
                "Eine neue Atmosphaere. Schoen.",
                "Meta 15. Du darfst jetzt die Welt umfaerben."
            )
            Explain = "Theme Selector: UI-Design frei waehlbar. Neon, Matrix, Retro, Minimal."
            Command = "Hub: [T] Theme. Mach es gemuetlich."
        }
        IVY = @{
            Intro = @(
                "... *nickt zustimmend* Besser.",
                "... *zeigt auf Farben* Da."
            )
            Explain = "Theme. Aendern. Besser."
            Command = "... [T]."
        }
        VERA = @{
            Intro = @(
                "UI-Redesign abgeschlossen. Produktivitaet steigt um 0%.",
                "Meta 15. Theme-Kontrolle. Aesthetische Optimierung."
            )
            Explain = "Theme Selector: UI-Design wechseln. Neon, Matrix, Retro, Minimal."
            Command = "Hub-Eingabe: [T] Theme. Design ist subjektiv."
        }
        JINX = @{
            Intro = @(
                "Neue Farben! Neue Vibes! 47% mehr Stil!",
                "THEMES! ICH WILL ALLE! GLEICHZEITIG!"
            )
            Explain = "Theme Selector = 47% mehr Stil! Neon! Matrix! Retro! Minimal!"
            Command = "Drueck [T]! Wechsel alle 47 Sekunden! CHAOS!"
        }
    }
}

} catch {
    Write-Host "[pet/_ui] CRITICAL ERROR: $_" -ForegroundColor Red
}
