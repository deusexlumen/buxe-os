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
}

function Show-PetFrame($Title, [switch]$Double) {
    $w = 50
    $hc = if ($Double) { "═" } else { "─" }
    $vc = if ($Double) { "║" } else { "│" }
    $tl = if ($Double) { "╔" } else { "┌" }
    $tr = if ($Double) { "╗" } else { "┐" }
    $bl = if ($Double) { "╚" } else { "└" }
    $br = if ($Double) { "╝" } else { "┘" }
    $top = $tl + ($hc * $w) + $tr
    $bot = $bl + ($hc * $w) + $br
    $pad = [math]::Max(0, $w - $Title.Length)
    $mid = $vc + " " + $Title + (" " * $pad) + $vc
    Write-Host $top -ForegroundColor Cyan
    Write-Host $mid -ForegroundColor Cyan
    Write-Host $bot -ForegroundColor Cyan
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
        "jinx_first_boot" { $lines = $script:CPMetaLines.jinx_first_boot }
        "jinx_casino" { $lines = $script:CPMetaLines.jinx_casino }
        "jinx_adventure" { $lines = $script:CPMetaLines.jinx_adventure }
        "jinx_insult" { $lines = $script:CPMetaLines.jinx_insult }
        "jinx_fourth_wall" { $lines = $script:CPMetaLines.jinx_fourth_wall }
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
    
    foreach ($egg in $found) {
        if (-not ($pet.Meta.EasterEggsFound -contains $egg)) {
            $pet.Meta.EasterEggsFound += $egg
            Add-PetXP 50 "Easter Egg: $egg"
        }
    }
    Save-PetState $pet
}

} catch {
    Write-Host "[pet/_ui] CRITICAL ERROR: $_" -ForegroundColor Red
}
