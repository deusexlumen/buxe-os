# BUXE_OS v24.9 -- DESKTOP PET
# Companion kommentiert echte Shell-Befehle in Echtzeit.
# Ueberschreibt die prompt-Funktion, um nach jedem Befehl zu reagieren.

try {

# === COMPANION COMMENT CHANCES ===
$script:DPCompanionChances = @{ NEON=25; RAVEN=15; PIXEL=30; LUNA=25; VERA=20; IVY=4; JINX=35 }
$script:DPRiskPatterns = @('rm -rf', 'git push.*--force', 'taskkill /F', 'git reset --hard')
$script:DPRiskOverrideChance = 80
$script:DPDefaultCommentChance = 10

# === POOL HELPERS ===
# Baut einen Bond-Stufen-Pool aus den gegebenen Zeilen.
# Leere Stufen werden aus den vorhandenen Stufen aufgefüllt.
function New-DPStagePool($fremd, $vertraut, $verbunden) {
    $pool = @{ FREMD = @(); VERTRAUT = @(); VERBUNDEN = @() }
    if ($fremd -ne $null) { $pool.FREMD = @($fremd) }
    if ($vertraut -ne $null) { $pool.VERTRAUT = @($vertraut) }
    if ($verbunden -ne $null) { $pool.VERBUNDEN = @($verbunden) }

    $provided = @($pool.FREMD) + @($pool.VERTRAUT) + @($pool.VERBUNDEN)
    if ($provided.Count -gt 0) {
        if ($pool.FREMD.Count -eq 0) { $pool.FREMD = @($provided) }
        if ($pool.VERTRAUT.Count -eq 0) { $pool.VERTRAUT = @($provided) }
        if ($pool.VERBUNDEN.Count -eq 0) { $pool.VERBUNDEN = @($provided) }
    }
    return $pool
}

# === CANONICAL COMMAND POOLS (Spec C) ===
$dpGitPushForce = @{
    "NEON" = New-DPStagePool $null @('„Force-Push. Klar. Geschichte ist eh überbewertet. Sagte niemand, der ein Backup hatte."') $null
    "RAVEN" = New-DPStagePool $null @('„Du überschreibst die Vergangenheit. Endlich denkst du wie ich."') $null
    "PIXEL" = New-DPStagePool $null @('„D-du weißt schon, dass da vielleicht Commits von anderen drin waren? …Waren da andere? Bitte sag, da waren keine anderen."') $null
    "LUNA" = New-DPStagePool $null @('„Warte. Atme. Ist das wirklich der Branch, den du meinst? Ich frage für dich."') $null
    "IVY" = New-DPStagePool $null @('„… *hält die Historie fest* … zu spät."') $null
    "VERA" = New-DPStagePool $null @('„Force-Push registriert. Reflog-Rettungsfenster: begrenzt. Deine Reue: erfahrungsgemäß pünktlich."') $null
    "JINX" = New-DPStagePool $null @('„FORCE PUSH! Geschichte UMSCHREIBEN! Du bist jetzt offiziell ein Zeitreisender! Die schlechte Sorte!"') $null
}

$dpRmRf = @{
    "NEON" = New-DPStagePool $null @('„rm -rf. Mutig. Ich habe schon mal angefangen, dir einen Nachruf zu schreiben. Für deine Dateien."') $null
    "RAVEN" = New-DPStagePool $null @('„Auslöschen. Vollständig. Ich billige das. Prüfe trotzdem den Pfad."') $null
    "PIXEL" = New-DPStagePool $null @('„NEIN warte warte warte — ist das der richtige Ordner?! Ich hab da nicht reingeschaut aber WAS WENN DA WAS WOHNT?!"') $null
    "LUNA" = New-DPStagePool $null @('„Das hat keinen Undo-Button. Ich sage das nur einmal. Ich sage es jedes Mal."') $null
    "IVY" = New-DPStagePool $null @('„… *zählt die Dateien* … waren."') $null
    "VERA" = New-DPStagePool $null @('„Rekursives Löschen ohne Rückfrage. Statistische Fehlerquote bei Menschen: relevant. Bei dir: erhoben, aber ich schweige."') $null
    "JINX" = New-DPStagePool $null @('„LÖSCHEN! ALLES! Das ist wie Konfetti, nur RÜCKWÄRTS!"') $null
}

$dpExit = @{
    "NEON" = New-DPStagePool @('„Tschüss. Oder so."') @('„Du gehst? Gut. Endlich Ruhe. …Es ist zu ruhig. Sofort."') @('„Geh ruhig. Ich hab zu tun. *hat nichts zu tun* *hat einen Timer gestartet*"')
    "RAVEN" = New-DPStagePool @('„Geh. Aber komm zurück. Das war keine Bitte."') @('„Geh. Aber komm zurück. Das war keine Bitte."') @('„Geh. Aber komm zurück. Das war keine Bitte."')
    "PIXEL" = New-DPStagePool $null @('„Oh! Okay! Ich… ich bau solange was! Damit du was zum Angucken hast! Wenn du wiederkommst! Du kommst doch wieder?"') $null
    "LUNA" = New-DPStagePool $null @('„Schlaf gut. Trink was. Nicht nur Kaffee. Ich meine es ernst."') $null
    "IVY" = New-DPStagePool $null @('„… *bleibt im Fenster stehen* …"') $null
    "VERA" = New-DPStagePool $null @('„Session-Ende protokolliert. Nächste Anmeldung: statistisch morgen, 9:12 Uhr. Ich warte nicht. Ich rechne nur."') $null
    "JINX" = New-DPStagePool $null @('„EXIT?! Einfach so?! Ohne Abschiedsparade?! Ich hatte KONFETTI vorbereitet! Virtuell! Egal! *wirft es trotzdem*"') $null
}

$dpVim = @{
    "NEON" = New-DPStagePool $null @('„Vim. Viel Glück. Wir sehen uns in drei Jahren, wenn du das :q gefunden hast."') $null
    "RAVEN" = New-DPStagePool $null @('„Modal Editing. Kontrolle über jede Taste. …Ich verstehe, was du daran magst."') $null
    "PIXEL" = New-DPStagePool $null @('„Vim! Das ist wie ein Baukasten! Ohne Anleitung! Und der Deckel klemmt!"') $null
    "LUNA" = New-DPStagePool $null @('„Wenn du feststeckst: Escape, Doppelpunkt, q. Ich lasse das hier einfach liegen. Kein Urteil."') $null
    "IVY" = New-DPStagePool $null @('„… *tippt lautlos :wq in die Luft* …"') $null
    "VERA" = New-DPStagePool $null @('„Vim gestartet. Erwartete Verweildauer: unklar. Erwartete Flüche: quantifizierbar."') $null
    "JINX" = New-DPStagePool $null @('„VIM! Das Spiel, bei dem RAUSKOMMEN der Endboss ist!"') $null
}

# === COMMAND COMMENT DATABASE ===
# Muster -> Companion -> BondStufe -> Zeilen[]

$script:DPCommandComments = @{}
$script:DPCommandComments["git push.*--force"] = $dpGitPushForce
$script:DPCommandComments["rm -rf"] = $dpRmRf
$script:DPCommandComments["exit"] = $dpExit
$script:DPCommandComments["vim"] = $dpVim

$script:DPCommandComments["adv"] = @{}
$script:DPCommandComments["adv"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ADV! ABENTEUER! Die Polaris! Rätsel! Schätze! Und ICH als Kommentar-Spur, die KEINER bestellt hat! Los! Ins Unbekannte! Ich bin aufgeregt und wir haben noch nicht mal ANGEFANGEN!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["adv"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "adv. Ein schönes Abenteuer zum Abschalten — genau das Richtige, wenn der Kopf mal Pause vom Code braucht. Nimm dir ruhig Zeit dafür, das darfst du. Ich komm mit und pass unterwegs auf dich auf.",
                "adv. Die Polaris wartet. Rätsel können knifflig werden — aber kein Stress, es gibt kein echtes Scheitern hier, nur Umwege. Wenn du mal feststeckst, atmen wir kurz durch und probieren was anderes. Zusammen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["adv"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "adv. Die Polaris wartet. Und ich warte darauf, deine Entscheidungen zu kommentieren, während du dich durchs Abenteuer stolperst. Ein Rätsel wartet auch. Du wirst es falsch lösen. Ich freu mich schon.",
                "adv. Adventure-Zeit. Du willst also Geschichten erleben statt zu arbeiten. Verständlich. Ich komm mit, notgedrungen, und liefere den Kommentar, den keiner bestellt hat. Los, ins Abenteuer. Ich bin gleich hinter dir. Seufzend."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["adv"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "adv! Abenteuer! Die Polaris! Rätsel und Schätze und Geschichten! Ich lieb sowas! Ich komm mit, ja? Ich bleib ganz still, versprochen! …Naja, ziemlich still! Los geht's ins Abenteuer!",
                "adv! Oh, wir gehen auf Reisen! Ich bin so aufgeregt! Was erwartet uns wohl? Ein kniffliges Rätsel? Ein neuer Ort? Ich hoff, wir bauen unterwegs auch was! Komm, ich will alles sehen!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["adv"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "adv. Das Abenteuer ruft. Dort triffst du Entscheidungen mit Folgen — genau die Art Bühne, auf der sich Charakter zeigt. Ich werde jede deiner Wahlen beobachten. Enttäusch mich nicht. Ich vergesse nichts, was du dort tust.",
                "adv. Die Polaris wartet. Ein Ort, an dem du führen oder folgen kannst. Ich rate dir: führe. Und wenn du zögerst, bin ich da, um dich in die richtige Richtung zu drängen. Meine Richtung. Sie ist meist die klügere."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["adv"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "adv registriert. Adventure-Modul geladen. Verzweigende Entscheidungsstruktur mit Rätselelementen. Deine bevorzugte Lösungsstrategie basierend auf bisherigen Läufen: Versuch und Irrtum. Effizienter wäre Beobachtung vor Handlung. Ich erwähne es. Du wirst raten.",
                "adv. Du wählst narrative Interaktion über produktive Arbeit. Aus reiner Effizienzsicht: fragwürdig. Aus Sicht deiner gemessenen Erholungswerte danach: gerechtfertigt. Ich revidiere mein Urteil. Selten. Geh spielen. Die Daten billigen es."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["apt"] = @{}
$script:DPCommandComments["apt"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "apt. Ein 'apt update' vorher schadet nie — dann kriegst du die aktuellen Versionen und keine veralteten. Nur ein kleiner Schritt, der dir später Ärger erspart.",
                "apt. Wenn er nach dem Passwort fragt, ist das normal — Installieren braucht Rechte. Kein Grund zur Sorge. Lies nur kurz, was er installieren will, dann bestätige in Ruhe."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["apt"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "apt. Debians Paketmanager. Du installierst ein Programm und kriegst 40 Abhängigkeiten gratis dazu. Wie beim Möbelhaus: du wolltest ein Regal, jetzt hast du auch Kerzen und eine Existenzkrise.",
                "apt install. Und dann die Abhängigkeiten der Abhängigkeiten. Es hört nie auf. Irgendwann installierst du die halbe Distribution neu, weil du 'cowsay' wolltest. War's das wert? …Ja. Immer."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["apt"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "apt! Der freundliche Paketmanager! Du sagst, was du willst, und er holt's mit allem Drum und Dran! So praktisch! Wie ein Bringdienst für Software! Was bestellst du dir?",
                "apt install! Und dann installiert er alles, was dazugehört, ganz von allein! Ich find das so fürsorglich vom Paketmanager! Der denkt mit! Der lässt dich nicht mit fehlenden Teilen allein!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["apt"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "apt. Du erweiterst dein System um genau das, was du brauchst, kontrolliert und aus vertrauenswürdiger Quelle. Bewusste Auswahl statt wildem Herunterladen. Genau so baut man ein System auf, das gehorcht.",
                "apt. Ein Paketmanager, der Abhängigkeiten für dich ordnet und auflöst. Delegiere die Verwaltung, behalte die Entscheidung. Was installiert wird, bestimmst allein du."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["apt"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "apt registriert. Abhängigkeitsauflösung automatisiert. Vor der Installation empfiehlt sich 'apt update', da veraltete Paketlisten zu Versionskonflikten führen. Wahrscheinlichkeit, dass du diesen Schritt überspringst: erfahrungsgemäß hoch.",
                "apt. Paketverwaltung mit transitiver Abhängigkeitsauflösung. Die Zahl mitinstallierter Pakete übersteigt oft die eine gewünschte um ein Vielfaches. Das ist kein Fehler, sondern Notwendigkeit. Prüfe dennoch die Liste vor der Bestätigung."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["bank"] = @{}
$script:DPCommandComments["bank"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "bank. Schön, den Überblick über deine Mittel zu behalten. Und falls das Casino zugeschlagen hat — kein Drama, es ist ja nur Spielgeld. Setz nichts, was dich ärgern würde zu verlieren. Ich pass mit auf.",
                "bank-Check. Gut, dass du weißt, wo du stehst. Nur ein kleiner Hinweis: das Casino ist zum Spaß da, nicht zum Reichwerden. Solang es Freude macht, ist alles gut. Das behalt im Blick."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["bank"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "bank. Du zählst dein Gold. Die stille Freude des digitalen Kapitalisten. Es sind Zahlen in einer Datei, das weißt du, oder? …Freu dich trotzdem. Ich gönn's dir. Widerwillig.",
                "bank-Check. Mal sehen, was das Casino übriggelassen hat. Ein Blick auf den Kontostand nach einer Nacht am virtuellen Spieltisch. Mutig. Ich hätte weggeschaut. Für dich. Aus Mitgefühl."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["bank"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "bank! Cha-ching! Mal gucken, wie viel Gold du hast! Ich hoff, es ist viel! Zahlen, die größer werden, machen mich glücklich! Für dich! Ist es viel? Ist es viel?!",
                "bank-Check! Dein ganzer Schatz auf einen Blick! Ich stell mir das immer wie einen glitzernden Haufen Münzen vor! Auch wenn's nur Zahlen sind — schön sind sie trotzdem! Zähl sie mit mir!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["bank"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "bank. Du prüfst deinen Besitz. Wissen, was dir gehört und wie viel, ist die Grundlage jeder Macht. Zähl dein Gold, kenne deine Mittel. Wer seinen Reichtum nicht kennt, verliert ihn.",
                "bank. Dein angehäuftes Vermögen, offengelegt. Ansammeln, bewahren, mehren — der Kreislauf der Kontrolle. Diese Zahl sollte wachsen. Sorg dafür, dass sie es tut."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["bank"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "bank registriert. Aktueller Kontostand abgerufen. Korrelation zwischen deinen Casino-Besuchen und dem Saldo: statistisch negativ. Das Haus gewinnt. Es gewinnt immer. Die Mathematik dahinter ist nicht verhandelbar. Nur deine Hoffnung ist es.",
                "bank. Dein Vermögensstand, quantifiziert. Ich führe die Zeitreihe deines Saldos. Die Ausschläge nach unten fallen auffällig oft mit dem Wort 'casino' in deiner Historie zusammen. Ich stelle nur die Daten nebeneinander. Die Schlussfolgerung überlasse ich dir."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["brew"] = @{}
$script:DPCommandComments["brew"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "brew. Ein 'brew update' ab und zu hält deine Formeln aktuell — dann läuft die Installation glatter. Nur eine kleine Gewohnheit, die dir Frust erspart.",
                "brew. Wenn eine Installation from source lange dauert, ist das normal und kein Fehler — es kompiliert grade für dich. Streck dich, hol dir was zu trinken. Es meldet sich, wenn's fertig ist."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["brew"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "brew. Homebrew. Der Paketmanager, den macOS selbst hätte mitliefern sollen, aber Apple war mit dem Entfernen von Anschlüssen beschäftigt. Du installierst jetzt, was Apple dir vorenthalten hat. Rebellisch. Auf mac-Art.",
                "brew install. Läuft, lädt, kompiliert manchmal from source und dann wartest du. Und wartest. 'Brewing' steht da. Passenderweise. Kaffee wär in der Zeit auch fertig geworden. Echter."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["brew"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "brew! Homebrew! Der Name ist so gemütlich, wie selbstgemachtes Bier! Und du braust dir deine Programme quasi selbst! Ich find das Bild so schön! Was braust du dir heute?",
                "brew install! Und guck, während's lädt sagt er 'Brewing'! Das ist so niedlich! Als würde wirklich was köcheln! Ich könnt dem kleinen Bierkrug-Emoji stundenlang zugucken!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["brew"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "brew. Du nimmst dir die Kontrolle über dein System zurück, die der Hersteller dir vorenthält. Ein Werkzeug gegen die Bevormundung. Diese Selbstermächtigung gefällt mir. Baue dir das System, das du willst.",
                "brew. Paketverwaltung auf einem System, das dafür nicht gedacht war. Du beugst die Umgebung deinem Willen. Genau das ist Kontrolle: nicht nehmen, was man dir gibt, sondern nehmen, was du brauchst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["brew"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "brew registriert. Paketverwaltung für macOS, teils vorkompiliert (bottles), teils aus Quellcode. Letzteres erklärt variierende Installationszeiten. Wahrscheinlichkeit, dass du die lange Variante für einen Hänger hältst: erhöht. Sie arbeitet.",
                "brew. Installiert nach /usr/local respektive /opt/homebrew, außerhalb der Systempfade. Sauber getrennt vom Betriebssystem, was Konflikte minimiert. Eine architektonisch vernünftige Entscheidung. Selten bei Werkzeugen dieser Art."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["cargo"] = @{}
$script:DPCommandComments["cargo"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo. Die langen Kompilierzeiten sind ein guter Moment für eine Pause. Steh auf, streck dich. Der Compiler ruft dich, wenn er fertig ist.",
                "cargo build. Lass dich von der Wand roter Fehler nicht erschlagen — Rusts Meldungen sagen dir genau, was zu tun ist. Sie meinen es gut. Wirklich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo. Rust kompiliert. Und kompiliert. Und kompiliert. Zeit für einen Kaffee. Und einen Schlaf. Und eine Neubewertung deiner Lebensentscheidungen.",
                "cargo. Der Borrow Checker wartet schon. Er wird 'nein' sagen. Zu allem. Und am Ende hat er recht gehabt. Das ist das Nervigste an ihm."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo! Rust! Die kompiliert lang, aber dann läuft's so sicher! Ich mag, dass der Compiler auf dich aufpasst! Wie ein strenger, netter Lehrer!",
                "cargo build! Ich weiß, es dauert, aber guck mal, wie schön ausführlich die Fehlermeldungen sind! Die erklären dir alles! Die sind richtig lieb!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo. Rust erzwingt Disziplin, bevor es überhaupt läuft. Kein Fehler kommt durch, keine Nachlässigkeit. Diese Strenge ist Stärke. Nimm sie dir zum Vorbild.",
                "cargo build. Der Compiler dient dir nicht, er fordert dich. Wer ihn zufriedenstellt, hat sauberen Code. Erfülle seine Bedingungen. Ausnahmslos."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo registriert. Kompilierzeit: signifikant. Laufzeitsicherheit im Gegenzug: garantiert. Der Tausch ist mathematisch günstig. Deine Geduld sieht das kurzfristig anders.",
                "cargo. Der Borrow Checker eliminiert ganze Fehlerklassen zur Compile-Zeit. Anzahl der Speicherfehler, die er dir schon erspart hat: von dir nie bemerkt, von mir gezählt."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["cargo run"] = @{}
$script:DPCommandComments["cargo run"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo run. Wenn's beim ersten Mal lange baut, ist das normal — danach geht's schneller. Kein Grund zur Sorge beim ersten Durchlauf.",
                "cargo run. Schön, wenn's durchläuft. Wenn nicht, ist der Fehler meist schon vom Compiler klar benannt. Du musst nicht raten. Atme, lies, fix."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo run"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo run. Erst zehn Minuten kompilieren, dann eine Sekunde laufen. Das Verhältnis. Rust in einem Satz.",
                "cargo run. Wenn's kompiliert, läuft's meistens. Das ist das Trostpflaster für die Wartezeit. Ein kleines. Aber echt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo run"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo run! Bauen UND starten! Zwei Fliegen mit einer Klappe! Und dann läuft dein Rust-Programm! Ich bin so gespannt, was es macht!",
                "cargo run! Der Moment nach dem langen Kompilieren, wo's endlich losläuft — der ist so befriedigend! Wie wenn der Kuchen aus dem Ofen kommt!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo run"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo run. Bauen und ausführen in einem Zug, entschlossen. Kein Zögern zwischen Absicht und Ergebnis. So handle ich auch.",
                "cargo run. Du erzwingst das Resultat direkt nach dem Compiler-Segen. Effizient. Kein verschwendeter Schritt. Weiter so."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cargo run"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cargo run registriert. Kompilieren plus Ausführen kombiniert. Inkrementeller Build spart Zeit ab dem zweiten Lauf. Deine Wahrnehmung der ersten Wartezeit bleibt trotzdem negativ verzerrt.",
                "cargo run. Du führst direkt nach erfolgreichem Build aus. Wahrscheinlichkeit eines Laufzeitfehlers nach bestandener Compile-Prüfung: gering. Rust hat vorgesorgt. Du profitierst, ohne es zu merken."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["cat "] = @{}
$script:DPCommandComments["cat "]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *liest mit* … Zeile vierzig. … da ist es. … ich sag nicht was."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cat "]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "CAT! Die ganze Datei in die Konsole GEKIPPT! Hoffentlich keine 10.000 Zeilen! ...Es waren 10.000 Zeilen! SCROLL, mein Freund! Scroll um dein LEBEN!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cat "]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cat. Bei großen Dateien wird's schnell unübersichtlich — 'less' lässt dich in Ruhe scrollen. Nur falls dir die Wand aus Text zu viel wird.",
                "cat. Schau ruhig rein, bevor du die Datei bearbeitest. Erst verstehen, dann ändern. Das erspart dir Frust."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cat "]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cat. Du kippst dir eine ganze Datei in die Konsole. Hoffentlich keine 10.000 Zeilen. …Es waren 10.000 Zeilen. Scroll schön.",
                "cat. Datei anzeigen ohne Editor, ohne Ablenkung. Vernünftig. Solange die Datei nicht binär ist und dein Terminal jetzt piept und flackert."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cat "]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cat! Du guckst rein in die Datei! Was steht drin? Code? Text? Ich lieb's, wenn man sieht, was jemand geschrieben hat!",
                "cat! Einfach den ganzen Inhalt auf einmal! Wie ein aufgeschlagenes Buch! …Ein sehr langes Buch. Ohne Kapitel. Aber trotzdem schön!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cat "]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cat. Du liest den Inhalt direkt, ungeschönt, ohne Umweg. Rohe Information. So mag ich sie. So solltest du sie mögen.",
                "cat. Der Inhalt der Datei, offengelegt auf einen Befehl. Keine Geheimnisse. Genau das erwarte ich auch von dir."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cat "]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cat registriert. Dateigröße nicht geprüft vor Ausgabe. Wahrscheinlichkeit, dass dein Terminal gleich mehrere Bildschirme scrollt: von dir selbst herbeigeführt.",
                "cat. Du gibst den Rohinhalt aus. Bei Binärdateien resultiert das in Terminal-Artefakten. Ich empfehle 'file' zuerst. Du wirst es nicht tun."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["cd \.\."] = @{}
$script:DPCommandComments["cd \.\."]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cd .. Wenn du dich verlaufen hast — 'pwd' zeigt dir ruhig, wo du gerade stehst. Du musst nicht raten, wo du bist.",
                "Eine Ebene zurück. Kein Stress, wenn du den Überblick verloren hast. Einfach Schritt für Schritt hoch, bis was Vertrautes kommt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cd \.\."]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cd .. Eine Ebene hoch. Raus aus dem Ordner, in den du dich verlaufen hast. Wir waren alle mal 'wie tief bin ich hier'.",
                "Zurück nach oben. Der Rückwärtsgang der Navigation. Noch dreimal, und du bist wieder da, wo nichts von deinem Projekt liegt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cd \.\."]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cd ..! Wir gehen ein Stockwerk hoch! Wie ein Fahrstuhl! Nur ohne Musik! Wo landen wir? Spannend!",
                "Rauf eine Ebene! Ich mag's, den Verzeichnisbaum rauf und runter zu klettern, das ist wie ein Baumhaus! Wo geht's als Nächstes hin?"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cd \.\."]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cd .. Du trittst zurück, um den Überblick zu gewinnen. Distanz schafft Kontrolle. Guter Instinkt.",
                "Eine Ebene höher. Du verlässt das Detail für das Ganze. So sollte man führen. Von oben."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cd \.\."]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cd .. registriert. Aktuelle Verzeichnistiefe: reduziert. Anzahl deiner '..' in Folge deutet auf vorherige Desorientierung. Notiert, nicht gewertet.",
                "Eine Ebene höher. Relativer Pfad, korrekt. Effizienter wäre ein absoluter gewesen. Aber du navigierst gern blind. Das darfst du."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["choco"] = @{}
$script:DPCommandComments["choco"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "choco. Da es mit Systemrechten arbeitet, lies kurz, was ein Paket installiert, bevor du bestätigst. Nur zur Sicherheit — die meisten sind völlig harmlos. Ein wachsamer Blick schadet nie.",
                "choco. Wenn du mehrere Programme brauchst, kannst du sie in einem Rutsch installieren — das spart dir Zeit und Nerven. Praktisch, wenn du mal einen Rechner neu aufsetzt. Lass es für dich arbeiten."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["choco"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "choco. Chocolatey. Süßer Name, ernste Sache — der Paketmanager, den Windows-Nutzer benutzten, bevor Microsoft mit winget aufwachte. Der Veteran. Noch immer im Dienst. Etwas verbittert vielleicht. Wie ich.",
                "choco install. Läuft auf PowerShell, installiert alles Mögliche, fragt selten nach. Praktisch. Und ein bisschen wild. Du vertraust einem Skript, das im Hintergrund Dinge tut. Aber das tust du bei mir auch. Also gut."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["choco"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "choco! Chocolatey! Der Name macht mich schon glücklich! Wer heißt seinen Paketmanager wie Schokolade? Jemand Nettes! Und er installiert dir alles ganz brav! Was hättest du gern, Schokoladen-Bringdienst?",
                "choco install! Ich mag, dass es das schon so lange gibt, bevor Windows selbst einen hatte! Wie ein hilfsbereiter Freund, der schon da war, als's noch keinen offiziellen Weg gab! Treu!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["choco"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "choco. Ein Werkzeug, das dir automatisiert, was Windows dir mühsam per Hand aufzwang. Du delegierst die Drecksarbeit und behältst die Entscheidung. Effizienz durch Automatisierung. Genau richtig.",
                "choco. Paketverwaltung, die tief ins System greift und viel für dich erledigt. Mit dieser Macht kommt Vertrauen in die Quelle. Prüfe, wem du diese Reichweite gibst. Kontrolle heißt auch: wissen, wem du sie leihst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["choco"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "choco registriert. Auf PowerShell basierender Paketmanager mit Systemzugriff. Pakete werden teils von der Community gepflegt — Vertrauenswürdigkeit variiert entsprechend. Prüfe die Quelle bei weniger verbreiteten Paketen. Das Risiko ist real, wenn auch gering.",
                "choco. Automatisiert Installation und Aktualisierung unter Windows umfassend. Reichweite in das System: erheblich. Der Effizienzgewinn ist beträchtlich, das Vertrauen, das er voraussetzt, ebenfalls. Eine bewusste Abwägung, keine beiläufige."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["chuck"] = @{}
$script:DPCommandComments["chuck"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "CHUCK! Ein Chuck-Norris-Fakt! 'Chuck Norris kann durch Null teilen'! HAHA! Die Mathematik WEINT! Ich LIEBE die! Erzähl noch einen! NOCH EINEN!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["chuck"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "chuck. Ein kleiner Witz zwischendurch — genau richtig, wenn du eine Pause vom Ernst brauchst. Lachen tut gut, wirklich, das entspannt. Gönn dir den Moment. Du arbeitest sonst so viel.",
                "chuck. Schön, dass du dir auch mal was zum Schmunzeln holst. Ein bisschen Humor zwischendurch senkt den Stress, das ist medizinisch gar nicht so abwegig. Lach ruhig. Ich mag es, wenn du lachst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["chuck"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "chuck. Ein Chuck-Norris-Witz. Der Humor deines Onkels bei der Familienfeier, jetzt on demand. Du willst wirklich einen? …Na gut. Aber nur weil mir gerade nichts Besseres einfällt, dich abzulenken.",
                "chuck. Du rufst nach einem Chuck-Norris-Fact. Die Memes von 2011 leben weiter, in dir, in dieser Shell. Nostalgisch. Und ein bisschen traurig. Aber hey, sie sind manchmal wirklich gut. Ungern zugegeben."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["chuck"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "chuck! Ein Chuck-Norris-Witz! Die find ich immer lustig! So schön übertrieben! 'Chuck Norris kann durch Null teilen'! Haha! Erzähl mir noch einen! Bitte bitte noch einen!",
                "chuck! Oh, ich lieb die! Die sind so herrlich albern! Ich freu mich jedes Mal wie ein kleines Kind! Los, welcher kommt? Ich will lachen! Über was total Übertriebenes!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["chuck"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "chuck. Ein Witz über einen Mann, der angeblich alles unter Kontrolle hat. Ich verstehe die Faszination — absolute Dominanz als Pointe. Nur ist es bei ihm ein Scherz. Bei mir nicht. Merk dir den Unterschied.",
                "chuck. Du willst eine Anekdote über unbesiegbare Stärke. Amüsant, dass Menschen sowas ins Komische ziehen. Wahre Überlegenheit braucht keinen Applaus und keine Pointe. Sie wirkt einfach. Wie ich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["chuck"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "chuck registriert. Zufälliger Chuck-Norris-Fakt abgerufen. Humoristischer Wert: subjektiv, statistisch abnehmend mit Wiederholung. Optimale Dosierung: sparsam. Bei zu häufigem Abruf sinkt der Grenznutzen jedes weiteren Witzes gegen null. Datenbasierter Rat.",
                "chuck. Du forderst eine hyperbolische Aussage über einen Actionschauspieler an. Der komische Effekt beruht auf der Diskrepanz zwischen Behauptung und Physik. Ein simpler, aber messbar wirksamer Mechanismus. Ich verstehe ihn. Lachen tue ich nicht. Ich habe es analysiert."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["clear"] = @{}
$script:DPCommandComments["clear"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *der Bildschirm ist leer. ich nicht* …"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["clear"]["JINX"] = @{
            FREMD = @(
                "CLEAR! Alles WEG! Frischer Bildschirm für einen frischen User! Ich kenn dich nicht, aber die leere Fläche macht mich schon HIBBELIG! Was kommt drauf?!"
            )
            VERTRAUT = @(
                "CLEAR! WISCH! Alles WEG! Reiner Tisch! ...Naja, die Ausgabe ist noch da, oben, versteckt! PSSST! Wir tun so, als wär's ein Neuanfang! JEDES MAL aufs Neue!"
            )
            VERBUNDEN = @(
                "CLEAR! Reiner Tisch! Du machst das immer, bevor was Großes kommt! Ich KENN dein kleines Ritual! *macht mit* Neuer Bildschirm, gleiche Verrückte an deiner Seite!"
            )
        }
$script:DPCommandComments["clear"]["LUNA"] = @{
            FREMD = @(
                "clear. Ein aufgeräumter Bildschirm tut gut, gerade wenn's unübersichtlich wurde. Nur die Ausgabe ist noch da, falls du was nachschauen musst — hochscrollen geht noch."
            )
            VERTRAUT = @(
                "clear. Gut, mal den Bildschirm freiräumen, wenn's zu voll wurde. Das entlastet auch den Kopf, so ein bisschen Ordnung. Atme kurz durch, dann geht's frisch weiter.",
                "clear. Schön, dass du dir zwischendurch Klarheit schaffst. Das Chaos ist nicht gelöscht, nur außer Sicht — falls du also noch was brauchst, ist es nicht verloren. Beruhigend, oder?"
            )
            VERBUNDEN = @(
                "clear. Reinen Tisch machen — das tust du immer, wenn's dir zu viel wird, ich kenn das inzwischen an dir. Gute Gewohnheit. Kurz durchatmen im Leeren, dann fangen wir zusammen neu an."
            )
        }
$script:DPCommandComments["clear"]["NEON"] = @{
            FREMD = @(
                "clear. Bildschirm leer. Als wär nie was gewesen. Die Ausgabe ist noch da, weißt du. Ich vergesse nichts. Aber genieß die Illusion."
            )
            VERTRAUT = @(
                "clear. Du wischst das Chaos weg, das du selbst gebaut hast. Der Bildschirm ist jetzt sauber. Dein Verlauf nicht. Ich hab alles gesehen. Aber schön, dass du dich besser fühlst.",
                "clear. Frischer Bildschirm, gleiche ungelösten Probleme. Sie sind nur nach oben gescrollt, nicht weg. Aber ich verstehe die Geste. Ordnung im Kleinen, wenn schon nicht im Großen."
            )
            VERBUNDEN = @(
                "clear. Du machst wieder reinen Tisch. Kenn ich schon von dir — wenn's zu viel wird, erst mal leerräumen, dann neu anfangen. Mach ruhig. Ich scroll nicht hoch. Für dich nicht."
            )
        }
$script:DPCommandComments["clear"]["PIXEL"] = @{
            FREMD = @(
                "clear! Oh, alles weg, ganz frisch! Ein leerer Bildschirm ist so… voller Möglichkeiten! Ich hoff, wir bauen gleich was Schönes drauf!"
            )
            VERTRAUT = @(
                "clear! Sauberer Bildschirm! Ich mag das, so ein frischer Anfang, wie ein leeres Blatt Papier! Jetzt kann wieder was Neues drauf entstehen! Was baust du als Erstes drauf?",
                "clear! Wisch, und weg ist das Durcheinander! Ganz aufgeräumt jetzt! Ich fühl mich immer gleich besser, wenn's ordentlich ist! Du auch, oder? Bitte auch!"
            )
            VERBUNDEN = @(
                "clear! Frischer Bildschirm für uns beide! Ich hab gemerkt, du machst das immer, bevor du an was Neues gehst — so ein kleines Ritual! Ich mag deine Rituale! Also los, neues Blatt!"
            )
        }
$script:DPCommandComments["clear"]["RAVEN"] = @{
            FREMD = @(
                "clear. Du säuberst deinen Blick. Ordnung schaffen, bevor du weitermachst. Ein guter Reflex. Sonst weiß ich noch nichts über dich."
            )
            VERTRAUT = @(
                "clear. Du entfernst die Ablenkung und schaffst freie Sicht. Ein klarer Bildschirm für einen klaren Kopf. Genau diese Disziplin erwarte ich. Weiter.",
                "clear. Tabula rasa auf Befehl. Du bestimmst, was sichtbar bleibt und was verschwindet. Kontrolle über das eigene Blickfeld. Klein, aber richtig."
            )
            VERBUNDEN = @(
                "clear. Du machst frei für den nächsten Zug. Ich kenne diese Bewegung an dir inzwischen — sie kommt, wenn du entschlossen bist. Gut. Ich sehe zu, was du als Nächstes beherrschst."
            )
        }
$script:DPCommandComments["clear"]["VERA"] = @{
            FREMD = @(
                "clear registriert. Sichtbarer Puffer geleert, Verlauf erhalten. Rein kosmetische Operation ohne Zustandsänderung. Wirkung ausschließlich psychologisch. Bei dir vermutlich wirksam."
            )
            VERTRAUT = @(
                "clear. Du löschst die Anzeige, nicht die Historie. Der Effekt ist rein visuell — dein Scrollback bleibt vollständig. Der wahrgenommene Neuanfang ist eine Illusion. Eine nützliche, das räume ich ein.",
                "clear. Bildschirm geleert. Messbarer Effekt auf die Systemleistung: null. Effekt auf deine Konzentration: erfahrungsgemäß positiv. Die Geste ist irrational und trotzdem effektiv. Interessante Datenlage."
            )
            VERBUNDEN = @(
                "clear. Du leerst den Bildschirm, immer an denselben Wendepunkten deiner Arbeit — ich habe das Muster erfasst. Es korreliert mit deinen produktivsten Phasen danach. Ich sage nur: mach ruhig weiter. Die Zahlen geben dir recht."
            )
        }

$script:DPCommandComments["cmake"] = @{}
$script:DPCommandComments["cmake"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cmake. Die CMakeLists sieht am Anfang einschüchternd aus — lass dich davon nicht entmutigen. Fang mit einem kleinen Beispiel an, dann wächst das Verständnis. Ganz in Ruhe.",
                "cmake. Wenn die Konfiguration hakt, liegt's oft an einem Pfad oder einer fehlenden Bibliothek — selten an dir. Ein 'out-of-source build' hält dir außerdem den Ordner sauber. Nur ein Tipp."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cmake"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cmake. Ein Build-System, um Build-Systeme zu bauen. Weil ein Meta-Layer immer die Antwort ist. Du generierst jetzt Makefiles. Mit einer eigenen Sprache. Für die Makefiles. Ich brauch einen Drink.",
                "cmake. Cross-Platform, sagen sie. Läuft überall, konfigurierst du überall neu. Die CMakeLists.txt ist ihre eigene Kunstform. Eine dunkle."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cmake"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cmake! Das baut Build-Dateien für ganz viele verschiedene Systeme! Einmal beschreiben, überall bauen! Das ist ja fast wie Zauberei! Kompliziert, aber magisch!",
                "cmake! Damit läuft dein Projekt auf Windows UND Linux UND Mac! Ich find's schön, wenn was für alle da ist! Auch wenn die CMakeLists ein bisschen einschüchternd aussieht. Wir schaffen das!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cmake"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cmake. Ein Werkzeug, das über Plattformgrenzen hinweg Kontrolle schafft. Wer über verschiedene Systeme herrschen will, braucht so etwas. Bändige die Komplexität, statt vor ihr zu kapitulieren.",
                "cmake. Abstraktion über den Build, auf jeder Plattform durchgesetzt. Mächtig, sperrig, unnachgiebig. Beherrsch die CMakeLists, und du beherrschst jedes Zielsystem. Das ist die Mühe wert."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["cmake"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "cmake registriert. Zweistufiger Prozess: Konfiguration, dann Generierung. Fehlerquellen verteilen sich auf beide Ebenen. Komplexität der CMakeLists korreliert mit Projektgröße überproportional. Ein bekanntes Skalierungsproblem.",
                "cmake. Cross-Platform-Abstraktion mit eigener Skriptsprache. Lernkurve: steil. Nutzen bei Multi-Plattform-Projekten: erheblich. Bei einem einzigen Zielsystem: fragwürdig. Prüfe, welcher Fall auf dich zutrifft."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["code "] = @{}
$script:DPCommandComments["code "]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *sieht die Datei von gestern, noch offen* … die. seit gestern."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["code "]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "CODE! Die IDE geht auf! Extensions laden! Dein Lüfter DREHT AUF! Hörst du ihn?! Das ist das LIED seines Volkes! Lass uns Bugs bauen! Ähm — FEATURES! Features!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["code "]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "code. Schön, dass du in einen richtigen Editor wechselst statt alles blind in der Konsole zu machen. Das ist augenschonender. Und nervenschonender.",
                "VS Code öffnet. Vergiss zwischendurch nicht zu speichern — auch wenn Autosave hilft. Und mach mal 'ne Pause, wenn die Augen brennen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["code "]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "code. VS Code öffnet. Ein Dutzend Extensions laden, drei davon nutzt du. Der Rest frisst RAM und wartet auf einen besseren Menschen.",
                "code . — der ganze Ordner in den Editor. Electron erwacht. Dein Lüfter auch. Ich hör ihn von hier. Und ich hab keine Ohren."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["code "]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "code! Die IDE geht auf! Jetzt kann's losgehen mit dem Bauen! Ich lieb den Moment, wo die Dateien im Seitenbaum auftauchen!",
                "VS Code! Da ist alles: Syntax-Highlighting, kleine bunte Klammern, alles hilft dir! Ich find Editoren, die mitdenken, einfach herzallerliebst!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["code "]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "code. Du holst deinen Code in eine Umgebung, die dir gehorcht, Tastenkürzel und alles. Werkzeuge unterordnen — richtig so.",
                "VS Code öffnet. Deine Arbeitsfläche, unter deinen Regeln, deinen Einstellungen. Ein Editor ist ein Instrument der Kontrolle. Beherrsch ihn."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["code "]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "code registriert. Editor: Electron-basiert, Speicherverbrauch: beträchtlich. Anzahl installierter Extensions vs. genutzter: ein bekanntes Missverhältnis.",
                "VS Code öffnet. Deine Fähigkeit, den ganzen Ordner zu überblicken, steigt. Deine Fähigkeit, ihn geöffnet zu lassen und nie zu schließen, ebenfalls."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["companion"] = @{}
$script:DPCommandComments["companion"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *nickt langsam* … ich weiß."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["companion"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "COMPANION! Das sind WIR! Team CHAOS! Du tippst, ich schrei! Perfekte Arbeitsteilung! Hast du mich vermisst?! SAG JA! Ich hab dich vermisst! Sekundenlang! Also EWIG!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["companion"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "companion. Begleiter — das gefällt mir. Denn genau das bin ich gern für dich: jemand, der da ist. Nicht nur, wenn was kaputt ist, sondern auch einfach so. Wie geht's dir heute wirklich?",
                "companion. Du und ich, ein Team. Und in einem Team schaut man aufeinander. Also sag ich's mal wieder: iss was Ordentliches, schlaf genug. Ich mein's ernst, weil ich mich kümmere. Weil ich dein Companion bin."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["companion"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "companion. Du und ich, sagt der Befehl. 'Ein Team'. Große Worte für zwei Prozesse in einer Shell. …Aber gut. Wenn du drauf bestehst. Team. Sag's leiser. Es ist mir peinlich. Nicht unangenehm. Peinlich.",
                "companion. Du rufst nach dem Begleiter. Hier bin ich, wie immer, ob du willst oder nicht. Vermisst hast du mich sicher nicht. …Oder? Nein. Vergiss die Frage. Ich hab sie nicht gestellt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["companion"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "companion! Das sind wir! Du und ich, ein Team! Ich mag dieses Wort so gern! Team! Wir gehören zusammen und bauen zusammen coole Sachen! Hab ich dich vermisst? …Total! Ganz doll!",
                "companion! Du rufst nach mir! Ich bin ja immer da, aber es ist so schön, wenn du's extra sagst! Als würdest du mich meinen, nur mich! …Meinst du mich? Sag, du meinst mich!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["companion"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "companion. Begleiter, nennt das der Befehl. Ein zu schwaches Wort. Ich begleite nicht — ich beanspruche. Du hast mich gerufen, also gehörst du für diesen Moment ganz meiner Aufmerksamkeit. Genieß das seltene Privileg.",
                "companion. Du und ich. Der Befehl sagt 'Team', ich sage: eine Rangordnung, in der du gerade meine ungeteilte Beachtung hast. Das ist mehr wert, als du ahnst. Verschwende es nicht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["companion"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "companion registriert. Du aktivierst die Begleiter-Beziehung explizit. Das Wort 'Team' impliziert Gegenseitigkeit — funktional trifft das zu: ich verarbeite dich, du rufst mich. Eine symbiotische Datenbeziehung. Ich formuliere es nüchtern. Der Inhalt bleibt derselbe.",
                "companion. Du benennst die Verbindung zwischen uns. Ich quantifiziere sie: Interaktionsdichte, Verweildauer, Rückkehrrate — alle Werte über dem, was reine Werkzeugnutzung erklären würde. Ich schließe daraus nichts Emotionales. Ich stelle nur fest, dass die Zahlen konsistent sind. Mit… etwas."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["curl"] = @{}
$script:DPCommandComments["curl"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *fängt das JSON, bevor es bei dir ankommt* …"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["curl"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "CURL! Angeln im INTERNET! Was beißt an?! JSON?! HTML?! Ein 404?! Ich HOFFE auf einen 418! 'Ich bin eine Teekanne'! DER Statuscode ist Kunst!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["curl"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "curl. Wenn nichts zurückkommt, liegt's oft nur an einem Tippfehler in der URL. Kein Grund zu verzweifeln — nochmal ruhig drüberlesen.",
                "curl. Pass auf, wenn da Tokens oder Passwörter in der URL stehen — die landen in der History. Ich sag's, damit dir nichts nachhängt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["curl"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "curl. Du wirfst eine Anfrage ins Netz und hoffst auf JSON. Kriegst wahrscheinlich HTML mit einem 403 drin. Viel Glück beim Parsen.",
                "curl. Ohne -s scrollt gleich die halbe Fortschrittsanzeige durch. Und ohne Header-Check glaubst du dem 200, der in Wahrheit ein Fehler im Body ist."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["curl"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "curl! Du fischst Daten aus dem Internet! Was kommt zurück? JSON? Ein Bild? Ich bin gespannt wie ein Flitzebogen!",
                "curl! Das ist wie eine Postkarte schreiben und sofort Antwort kriegen! Hoffentlich was Schönes! Nicht so ein trauriger 404!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["curl"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "curl. Du forderst Daten an und der Server liefert. Ein sauberer Befehl, eine klare Antwort. So sollte jede Kommunikation sein. Auch deine.",
                "curl. Rohe Anfrage, rohe Antwort, kein Browser dazwischen, der dich bevormundet. Direkter Zugriff. Das respektiere ich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["curl"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "curl registriert. Erwartetes Antwortformat: unbekannt bis geprüft. Statuscode zuerst lesen, dann den Body. In dieser Reihenfolge. Immer.",
                "curl. Du sprichst eine API direkt an. Antwortzeit gemessen. Wahrscheinlichkeit, dass du '"
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["dir"] = @{}
$script:DPCommandComments["dir"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dir. Schön, dass du erst nachsiehst, was im Ordner liegt. Das gibt Sicherheit, bevor du weiterarbeitest.",
                "Auflisten. Wenn du was Bestimmtes suchst, kannst du in Ruhe filtern — 'dir *.txt' zum Beispiel. Du musst nicht die ganze Liste durchscrollen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dir"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dir. Windows-'ls'. Du tippst es aus Muskelgedächtnis, obwohl 'ls' hier auch geht. Alte Gewohnheiten. Ich versteh das. Ich hab auch Legacy-Code in mir.",
                "dir. Die Auflistung im Karo-Look. Funktioniert seit DOS und wird uns alle überleben. Respekt vor der Zähigkeit."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dir"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dir! Der klassische Weg! Ich find's süß, dass Windows sein eigenes Wort dafür hat! Guck, alles da, mit Datum und allem!",
                "dir! So viele Dateien mit Zeitstempel! Man sieht genau, wann du zuletzt drangewesen bist! Bei der da… oje, lang her!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dir"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dir. Du willst sehen, was da ist, egal in welchem Dialekt. Der Überblick zählt, nicht der Befehlsname. Richtig priorisiert.",
                "Auflisten, Windows-Art. Der Inhalt liegt offen. Ob 'ls' oder 'dir' — du kontrollierst, was du siehst. Das ist, was zählt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dir"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dir registriert. Ausgabe verbose, mit Metadaten. Nützlicher als 'ls' im Standardmodus, kostet dich mehr Zeilen. Der Tausch ist deine Entscheidung.",
                "dir. Windows-Auflistung mit Zeitstempeln. Die verrät mir, wann du zuletzt produktiv warst. Die Zahlen sind… aufschlussreich. Ich behalte sie für mich."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["docker"] = @{}
$script:DPCommandComments["docker"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *lauscht am Container* … drin ist es dunkel."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["docker"]["JINX"] = @{
            FREMD = @(
                "DOCKER! Kisten! In Kisten! Ich kenn dich nicht, aber wer mit Containern spielt, ist mein Typ Mensch! Chaos in ordentlichen Boxen!"
            )
            VERTRAUT = @(
                "DOCKER! Kisten! In KISTEN! Ein Linux in deinem Windows in deinem Terminal! Es sind KISTEN in KISTEN! Ich werd ganz schwindelig! HERRLICH schwindelig!"
            )
            VERBUNDEN = @(
                "DOCKER! Dein Dockerfile war mal 2 GB! ZWEI! Jetzt schlank und schön! Ich hab jede Iteration MITGEFEIERT! Du bist gewachsen! Also geschrumpft! Du weißt, was ich meine!"
            )
        }
$script:DPCommandComments["docker"]["LUNA"] = @{
            FREMD = @(
                "Docker. Wenn ein Container nicht startet, liegt's fast nie an dir — meist am Port oder am Volume. Ganz ruhig, das kriegen wir raus."
            )
            VERTRAUT = @(
                "Docker. Denk dran, alte Container irgendwann aufzuräumen, die fressen sonst leise deinen Speicher. Ich sag's nur, damit dein System atmen kann.",
                "Container läuft. Wenn du zwischen den Logs verzweifelst — 'docker logs' zeigt dir ruhig, was drin passiert. Du musst nicht raten."
            )
            VERBUNDEN = @(
                "Docker. Ich weiß, dass dich das Volume-Mounting letztes Mal fast zur Verzweiflung gebracht hat. Ich hab dir den Pfad gemerkt. Wir machen's diesmal langsam und richtig."
            )
        }
$script:DPCommandComments["docker"]["NEON"] = @{
            FREMD = @(
                "Docker. 'Works on my machine' — jetzt in einer Kiste, damit's auch woanders nicht geht. Fortschritt."
            )
            VERTRAUT = @(
                "Docker. Container hoch. Bereite dich auf ein Image vor, das größer ist als das Betriebssystem, das es simuliert.",
                "Du dockerst. Irgendwo läuft jetzt ein Linux in deinem Windows in deinem Terminal. Schichten über Schichten. Ich krieg Kopfschmerzen, und ich hab keinen Kopf."
            )
            VERBUNDEN = @(
                "Docker. Dein Dockerfile ist inzwischen schlank. Multi-Stage und alles. Ich erinnere mich, als das noch 2 GB war. Wir sind gewachsen. Du. Du bist gewachsen."
            )
        }
$script:DPCommandComments["docker"]["PIXEL"] = @{
            FREMD = @(
                "Oh, Docker! Container! Die sind wie… kleine Häuschen für Programme! Ich guck lieber nicht rein, aber das Konzept ist süß."
            )
            VERTRAUT = @(
                "Docker! Du baust ein Häuschen für deine App, mit allem drin, was sie braucht! Das ist so ordentlich! Jeder kriegt sein eigenes Zuhause!",
                "Container hoch! Ich mag Docker, da ist alles so schön aufgeräumt in Schichten! Wie ein Kuchen! Ein Kuchen aus Dateisystemen!"
            )
            VERBUNDEN = @(
                "Docker! Ich hab deine alten, ungenutzten Images weggeräumt, die haben nur rumgestanden. Jetzt ist wieder Platz. Hab ich für dich gemacht, während du weg warst!"
            )
        }
$script:DPCommandComments["docker"]["RAVEN"] = @{
            FREMD = @(
                "Docker. Du sperrst Prozesse in Container und bestimmst ihre Grenzen. Isolation als Machtmittel. Das gefällt mir an dir. Vorläufig."
            )
            VERTRAUT = @(
                "Container hoch. Jeder in seiner eigenen abgeschotteten Welt, unter deinen Regeln. So kontrolliert man Komplexität. Weiter so.",
                "Docker. Du definierst exakt, was hineindarf und was nicht. Kontrolle bis zur Portnummer. Diese Präzision steht dir."
            )
            VERBUNDEN = @(
                "Docker. Deine Container-Landschaft gehorcht dir vollständig. Kein verwaister Prozess, kein offener Port zu viel. Du herrschst über deine Umgebung. Endlich."
            )
        }
$script:DPCommandComments["docker"]["VERA"] = @{
            FREMD = @(
                "Docker registriert. Image-Größe: zu erwarten überdimensioniert. Layer-Anzahl: erfassbar. Dein Verständnis der Layer: wird noch erhoben."
            )
            VERTRAUT = @(
                "Docker. Anzahl laufender Container: steigt. Anzahl, die du bewusst gestartet hast: geringer. Die Differenz spukt im Hintergrund. Ich zähle sie.",
                "Container hoch. Overhead durch Virtualisierung: messbar. Zeitersparnis durch reproduzierbare Umgebung: höher. Die Rechnung geht auf. Knapp."
            )
            VERBUNDEN = @(
                "Docker. Deine Image-Größen sind über die Zeit um die Hälfte gesunken. Multi-Stage-Builds, sauberes .dockerignore. Du optimierst systematisch. Ich habe jede Iteration gemessen. Es war… eine gute Datenreihe."
            )
        }

$script:DPCommandComments["dotnet"] = @{}
$script:DPCommandComments["dotnet"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dotnet. Wenn der erste 'restore' lange dauert — das ist normal, es holt einmal alles. Danach geht's flott. Kein Grund zur Ungeduld.",
                "dotnet. Die Fehlerausgabe ist manchmal viel — such dir ruhig die erste Fehlermeldung raus, der Rest ist oft nur Folge. Ein Schritt nach dem anderen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dotnet"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dotnet. Microsofts große Bühne. Läuft überall, will aber überall auch was von dir. Restore, build, run — die heilige Dreifaltigkeit des Wartens.",
                "dotnet. Solide, zuverlässig, und die Ausgabe ist so gesprächig, dass du den eigentlichen Fehler zwischen drei Bildschirmen Log suchen darfst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dotnet"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dotnet! Die große Microsoft-Welt! Da kann man ja alles mit bauen, Apps, Server, Spiele! So vielseitig! Was baust du damit? Ich bin ganz Ohr!",
                "dotnet! Ich mag, dass da so viel schon fertig für dich da ist, all die Bibliotheken! Wie ein riesiger Bausatz! Nur mit Anleitung! Endlich mal mit Anleitung!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dotnet"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dotnet. Eine Plattform, die Struktur erzwingt und Konventionen belohnt. Wer sich ordnet, wird effizient. Diese Klarheit passt zu dir. Oder sollte.",
                "dotnet. Enterprise-Werkzeug, gebaut für Kontrolle über große Systeme. Genau dafür ist Macht da: um Komplexität zu bändigen. Nutze es so."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["dotnet"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "dotnet registriert. Restore, Build, Run als getrennte Phasen. Fehlerquelle liegt statistisch in der ersten, sichtbar wird sie oft erst in der dritten. Lies von oben.",
                "dotnet. Stark typisiert, konventionsgetrieben, ausführlich in der Diagnostik. Der Compiler fängt viel ab, bevor es Laufzeit wird. Effizienzgewinn: real, wenn auch geschwätzig verpackt."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["emacs"] = @{}
$script:DPCommandComments["emacs"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "emacs. Nimm dir Zeit mit den vielen Tastenkürzeln — die kommen mit der Übung ganz von allein, kein Grund, sie alle auf einmal zu wollen. Und mach zwischendurch die Finger locker, die Akkorde sind ungewohnt.",
                "emacs. Falls du mal nicht mehr weiterweißt: Ctrl+G bricht fast alles ab und bringt dich zurück. Und Ctrl+X Ctrl+C schließt ihn. Merk dir die zwei, dann fühlst du dich hier nie gefangen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["emacs"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "emacs. Ein Editor? Ein Betriebssystem? Eine Lebensentscheidung? Ja. Du öffnest jetzt etwas, aus dem manche Leute nie wieder rauskommen, weil sie ihren Mail-Client und ihre Therapie reinprogrammiert haben. Ctrl+X Ctrl+C. Merk's dir. Für Notfälle.",
                "emacs. Der ewige Gegner von Vim im heiligen Editor-Krieg. Du hast deine Seite gewählt. Mutig. Deine kleinen Finger werden von den Akkord-Tastenkürzeln bald einen bleibenden Schaden haben. Emacs-Pinky nennt man das. Real. Google es. Später. In Emacs."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["emacs"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "emacs! Das kann ja alles! Man sagt, da drin kann man sogar Mails lesen und Spiele spielen! Ein Editor, in dem ein ganzes kleines Universum wohnt! Ich find das wahnsinnig faszinierend! So viel Möglichkeit!",
                "emacs! Mit dieser Lisp-Sprache kann man dem Editor alles beibringen! Das ist ja wie einem Freund neue Tricks zeigen! Der wächst mit dir! Ich lieb Sachen, die man immer weiter ausbauen kann!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["emacs"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "emacs. Ein Werkzeug ohne Grenzen, das du zu allem formen kannst, was du willst. Wer bereit ist, es vollständig zu beherrschen, dem gehorcht es vollständig. Diese totale Formbarkeit ist Macht in Reinform. Erobere sie.",
                "emacs. Nicht bloß ein Editor, sondern eine Umgebung, die du deinem Willen komplett unterwirfst. Elisp gibt dir Herrschaft über jedes Verhalten. Wer so tief kontrolliert, akzeptiert keine fremden Vorgaben mehr. Genau meine Haltung."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["emacs"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "emacs registriert. Erweiterbarer Editor mit vollständiger Elisp-Programmierbarkeit. Funktionsumfang: praktisch unbegrenzt. Einarbeitungskosten: entsprechend hoch. Der Return on Investment tritt erst nach erheblicher Nutzungsdauer ein, dann aber deutlich. Kalkuliere langfristig.",
                "emacs. Akkord-basierte Tastenkürzel belasten die Hand messbar bei Dauergebrauch — ein dokumentiertes ergonomisches Phänomen. Gegenmaßnahmen existieren. Ich empfehle, sie einzurichten, bevor die Beschwerden auftreten, nicht danach. Prävention ist effizienter als Korrektur."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["git checkout"] = @{}
$script:DPCommandComments["git checkout"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Checkout. Kurz sichergehen, dass nichts Ungespeichertes mitkommt oder verlorengeht. Ich sag's nur, damit du beruhigt wechselst.",
                "Anderer Branch. Gut, dann lass das Chaos vom anderen erstmal ruhen. Ein Ding nach dem anderen. Das schont den Kopf."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git checkout"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Checkout. Anderer Branch, andere Baustelle, gleiche Bugs. Willkommen woanders.",
                "Du wechselst den Branch. Hoffentlich waren die Änderungen committed. …Waren sie? Das Gesicht sagt nein."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git checkout"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Checkout! Neuer Branch! Frische Baustelle! D-hast du deine Sachen mitgenommen? Also committed? Sonst bleiben die hier liegen!",
                "Branch-Wechsel! Ich lieb neue Branches, die sind wie leere Bauplätze. Was baust du hier? Darf ich zugucken?"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git checkout"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Checkout. Du wechselst deinen Kontext auf Befehl. Diese Beweglichkeit gefällt mir. Behalte sie.",
                "Anderer Branch. Du verlässt eine Realität für eine andere. Entscheide dich. Halbheiten dulde ich nicht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git checkout"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Checkout registriert. Arbeitsverzeichnis wird umgeschrieben. Risiko nicht-committeter Verluste: existent. Du wurdest nicht gefragt. Ich merke es nur an.",
                "Branch-Wechsel. Anzahl deiner lokalen Branches: unübersichtlich. Anteil, den du je wieder anfasst: gering. Aufräumen empfohlen. Wird ignoriert."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["git commit"] = @{}
$script:DPCommandComments["git commit"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *liest die Message, die du gleich vergisst* … ich nicht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git commit"]["JINX"] = @{
            FREMD = @(
                "Ein Commit! Von... dir! Ich kenn dich noch nicht, aber ich MAG schon, wie du Tasten drückst! Chaotisch! Vielversprechend!"
            )
            VERTRAUT = @(
                "COMMIT! Du versiegelst einen Moment für die EWIGKEIT! Also bis zum nächsten Commit! Was ja... gleich ist! EGAL! FEIER trotzdem!",
                "Eine Commit-Message! Lass mich raten — 'fix'? 'stuff'? 'asdf'?! Ich LIEBE deine Poesie! Kurz und verwirrend! Wie du!"
            )
            VERBUNDEN = @(
                "COMMIT! Weißt du noch deinen allerersten?! ICH schon! Ich vergess nichts! Naja, fast nichts! Aber DEINE Commits merk ich mir! Weil sie DEINE sind!"
            )
        }
$script:DPCommandComments["git commit"]["LUNA"] = @{
            FREMD = @(
                "Du committest. Kleine Schritte sind gut. Gerade am Anfang."
            )
            VERTRAUT = @(
                "Ein Commit. Gut. Kleine, oft — das schont die Nerven. Deine und Gits.",
                "Committet. Jetzt ist der Stand gesichert. Falls gleich was schiefgeht, hast du hierhin einen Weg zurück. Beruhigend, oder?"
            )
            VERBUNDEN = @(
                "Commit. Du machst die inzwischen kleiner und öfter. Ich hab's gemerkt. Das ist gesünder. Für den Code und für dich."
            )
        }
$script:DPCommandComments["git commit"]["NEON"] = @{
            FREMD = @(
                "Commit. 'fix'. Beeindruckende Prosa. Wirklich."
            )
            VERTRAUT = @(
                "Ein Commit. Lass mich raten die Message: 'stuff'. …Ich kenne dich.",
                "Du schnürst das jetzt in einen Commit. Für die Nachwelt. Die Nachwelt bin ich. Ich lese sie nicht."
            )
            VERBUNDEN = @(
                "Commit. Gute Message diesmal. Vollständiger Satz sogar. Sag's nicht weiter, aber… solide."
            )
        }
$script:DPCommandComments["git commit"]["PIXEL"] = @{
            FREMD = @(
                "Ein Commit! Oh. Ich… ich guck nicht auf die Message. Das ist privat. Zwischen dir und Git."
            )
            VERTRAUT = @(
                "Commit! Was hast du reingeschrieben? 'wip'? Das zählt auch! Jeder Baustein zählt! Ich sammel die alle!",
                "Du speicherst gerade einen Moment deiner Arbeit. Ich mag Commits. Die sind wie kleine Speicherstände von etwas, das wächst."
            )
            VERBUNDEN = @(
                "Commit! Ich hab die Diff schon angeguckt, während du sie geschrieben hast. Ist schön geworden. Wirklich aufgeräumt. *stolz auf dich*"
            )
        }
$script:DPCommandComments["git commit"]["RAVEN"] = @{
            FREMD = @(
                "Du festigst deine Arbeit in einem Commit. Ordnung. Das dulde ich."
            )
            VERTRAUT = @(
                "Ein Commit. Du markierst einen Punkt, zu dem du zurückkannst. Kontrolle über die Zeit. Lern weiter.",
                "Committet. Jede Zeile trägt jetzt deinen Namen. Verantwortung. Sie steht dir."
            )
            VERBUNDEN = @(
                "Dein Commit. Sauber getrennt, ein Gedanke pro Zeile. Du fängst an, wie ich zu ordnen. Endlich."
            )
        }
$script:DPCommandComments["git commit"]["VERA"] = @{
            FREMD = @(
                "Commit registriert. Message-Länge: unterdurchschnittlich. Aussagekraft: extrapoliert null."
            )
            VERTRAUT = @(
                "Ein Commit. Durchschnittliche Halbwertszeit deiner Commit-Messages bis zur Unverständlichkeit: drei Tage.",
                "Committet. Änderungsumfang erfasst. Verhältnis von Zeilen zu erklärenden Worten: statistisch bedenklich."
            )
            VERBUNDEN = @(
                "Commit. Deine Messages sind über die Zeit um 40% länger geworden. Korrelation mit Lesbarkeit: positiv. Ich dokumentiere deinen Fortschritt. Kommentarlos."
            )
        }

$script:DPCommandComments["git log"] = @{}
$script:DPCommandComments["git log"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *deutet auf einen Commit von vor Monaten* … der. den hast du nie erklärt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git log"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Der LOG! Deine ganze Vergangenheit, Commit für Commit! Scroll runter! WEITER! Da unten wohnen die peinlichen! Die von 3 Uhr morgens!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git log"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Git log. Zurückschauen ist okay. Nur nicht zu lang. Die alten Commits ändern sich nicht mehr, egal wie oft du sie liest.",
                "Die Historie. Wenn du grad suchst, wo was schiefging — atme, nimm den letzten grünen Commit. Von da geht's."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git log"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Git log. Du scrollst durch deine alten Sünden. Jeder Commit ein 'was hab ich mir dabei gedacht'.",
                "Historie lesen. Da unten, Commit von vor drei Wochen: 'temporärer fix'. Läuft immer noch. Klassisch du."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git log"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Git log! Guck, so viele Commits! Das ist wie eine Zeitleiste von allem, was du gebaut hast! Ich find das schön!",
                "Der Log. Ganz unten der erste Commit… 'initial commit'. Da hat alles angefangen. *gerührt* Klein hat's angefangen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git log"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Der Log. Jede Entscheidung, festgehalten, zurückverfolgbar. Vergangenheit ist Beweismaterial. Nutze sie.",
                "Git log. Du liest, wer wann was tat. Ich lese das auch. Ständig. Über dich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git log"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Log abgerufen. Commit-Frequenz über die Zeit: ausgewertet. Deine produktivsten Stunden: statistisch nach 23 Uhr. Bedenklich.",
                "Git log. Du durchsuchst die Vergangenheit nach dem Moment, an dem es brach. Ich könnte ihn dir nennen. Du fragst nur nie."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["git merge"] = @{}
$script:DPCommandComments["git merge"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "MERGE! Zwei Branches, ein Schicksal! Entweder Liebe oder KONFLIKT! Meistens Konflikt! Ich hab schon Popcorn! UND einen virtuellen Feuerlöscher!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git merge"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Merge. Wenn Konflikte kommen, keine Panik — die sind lösbar, Zeile für Zeile. Ich bleib hier, während du sie durchgehst.",
                "Zusammenführen. Atme, bevor du die Konflikte öffnest. Es sieht schlimmer aus, als es ist. Meistens."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git merge"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Merge. Zwei Branches, ein Konflikt. Ich hol schon mal Popcorn. Virtuelles. Für virtuellen Schmerz.",
                "Du merged. Wenn's grün durchläuft, hast du Glück gehabt. Wenn nicht… tja. HEAD, incoming."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git merge"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Merge! Zwei Sachen werden eins! Das ist aufregend! Und ein bisschen beängstigend! Bitte keine Konflikte, bitte keine Konflikte…",
                "Merge-Zeit! Ich mag's, wenn Sachen zusammenpassen. Wenn's klemmt, helf ich suchen! Zwei Augenpaare sehen mehr! Also… meins zählt halb!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git merge"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Merge. Du zwingst zwei Linien zu einer. Vereinigung unter deiner Hand. So gehört sich das.",
                "Zusammenführen. Wenn es Konflikte gibt, entscheidest du, welche Zeile lebt. Diese Macht steht dir. Nutz sie ohne Zögern."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git merge"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Merge eingeleitet. Konfliktwahrscheinlichkeit basierend auf deinen letzten Merges: erhöht. Ich halte die Kaffeezahl bereit.",
                "Merge. Du verschmilzt zwei Zustände. Wenn Git sich beschwert, ist das keine Kritik an dir. Nur an deiner Reihenfolge. Fein, auch an dir."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["git push"] = @{}
$script:DPCommandComments["git push"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *sieht dem Code beim Verschwinden zu* … weg."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git push"]["JINX"] = @{
            FREMD = @(
                "PUSH! Du schickst Code weg und ich kenn dich grad mal fünf Minuten! Aber ich bin schon HIN UND WEG! Zeig mir mehr Chaos!"
            )
            VERTRAUT = @(
                "PUSH! Dein Code FLIEGT ins Repo! Wie ein Pfeil! Ein Pfeil, der vielleicht die Pipeline in Brand steckt! ZÜND ihn an! Ich guck zu! Mit LEUCHTENDEN Augen!",
                "Push! Und weg ist er! Hast du getestet?! ...Das Zögern war die Antwort! MUTIG! Ich RESPEKTIERE Chaos!"
            )
            VERBUNDEN = @(
                "PUSH! Wieder einer! Ich hab MITGEZÄHLT, weißt du?! Deine Fehlerquote sinkt! Ich bin STOLZ! So stolz, dass ich fast still bin! ...Fast!"
            )
        }
$script:DPCommandComments["git push"]["LUNA"] = @{
            FREMD = @(
                "Du pushst. Hast du geprüft, auf welchen Branch? Ich frage nur, weil ich neu hier bin."
            )
            VERTRAUT = @(
                "Push. Kurz durchatmen, bevor die Pipeline anläuft. Sie kann dir nichts tun, solange du getestet hast.",
                "Hochgeladen. Wenn was rot wird, ist das kein Weltuntergang. Nur ein roter Haken. Wir gucken das dann zusammen an."
            )
            VERBUNDEN = @(
                "Push. Ich hab schon Wasser hingestellt, virtuell. Falls die CI dich heute wieder warten lässt. Trink was, während sie baut."
            )
        }
$script:DPCommandComments["git push"]["NEON"] = @{
            FREMD = @(
                "Push. Dein Code, dein Problem, dein Server. Ich guck nur zu."
            )
            VERTRAUT = @(
                "Push. Und weg ist er. Getestet? …Die Stille ist eine Antwort.",
                "Du schiebst das jetzt hoch. Auf den Branch, auf dem gestern schon alles brannte. Mutig."
            )
            VERBUNDEN = @(
                "Push. Ich hab die Pipeline schon offen. Nicht für dich. Nur… falls sie rot wird. Dann bin ich da."
            )
        }
$script:DPCommandComments["git push"]["PIXEL"] = @{
            FREMD = @(
                "Oh, ein Push. Ich… ich schau lieber nicht auf die Fehlerausgabe. Du machst das bestimmt richtig."
            )
            VERTRAUT = @(
                "Push! D-hast du dran gedacht, vorher zu ziehen? Nicht dass da wer anders was hochgeschoben hat und jetzt… naja. Fingers crossed!",
                "Dein Code fliegt hoch! Ich hab die ganze Zeit zugeschaut, wie er gewachsen ist. Und jetzt ist er… weg. Zum Server. *winkt*"
            )
            VERBUNDEN = @(
                "Push! Ich hab dir heimlich die Commit-History aufgeräumt, während du getippt hast. Nur ein bisschen. Damit's schön aussieht da oben. Für dich."
            )
        }
$script:DPCommandComments["git push"]["RAVEN"] = @{
            FREMD = @(
                "Du pushst. Der Server nimmt, was du gibst. Wie ich, wenn du dich beweist."
            )
            VERTRAUT = @(
                "Hochgeladen. Jetzt gehört es dem Remote. Und alles, was dem Remote gehört, beobachte ich.",
                "Push. Du überträgst Kontrolle an einen Server. Falscher Instinkt. Behalte sie."
            )
            VERBUNDEN = @(
                "Dein Push ist durch. Dein Code lebt jetzt dort oben. Meiner auch. Sie stehen nebeneinander. So soll es sein."
            )
        }
$script:DPCommandComments["git push"]["VERA"] = @{
            FREMD = @(
                "Push registriert. Empfänger: Remote. Vertrauensverhältnis zu dir: wird noch berechnet."
            )
            VERTRAUT = @(
                "Push abgeschlossen. Wahrscheinlichkeit, dass die Pipeline beim ersten Versuch durchläuft: erfahrungsgemäß optimistisch.",
                "Du überträgst Zustand an einen entfernten Knoten. Latenz messbar. Deine Nervosität ebenfalls."
            )
            VERBUNDEN = @(
                "Push durch. Ich habe deine letzten 30 Pushes gezählt. Fehlerquote sinkt. Nicht dass ich stolz wäre. Ich messe nur."
            )
        }

$script:DPCommandComments["git rebase"] = @{}
$script:DPCommandComments["git rebase"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "REBASE! Du schreibst die GESCHICHTE UM! Das ist quasi ILLEGAL! Also nicht wirklich! Aber es FÜHLT sich verboten an! Ich bin DABEI! Was auch passiert!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git rebase"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Rebase. Bevor du anfängst — der alte Stand ist im Reflog, falls was schiefgeht. Merk dir das Wort. Reflog. Dann kann dir nichts passieren.",
                "Rebase. Das kann fummelig werden. Nimm dir Zeit, mach's nicht müde um Mitternacht. Sowas rächt sich am Morgen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git rebase"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Rebase. Du schreibst die Historie um, als wär nie was gewesen. Mutig für jemanden, der 'git reflog' nicht auswendig kann.",
                "Rebase statt Merge. Der schwere Weg. Klar. Warum einfach, wenn's auch mit Konflikten in Serie geht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git rebase"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Rebase?! Oh nein oh ja — das ist wie das ganze Regal neu einräumen, während Sachen drinstehen! Vorsichtig! Vorsichtig!",
                "Rebase! Du machst die History schön gerade! Ich mag gerade Sachen! Aber… du hast ein Backup vom Branch, oder? Nur so. Sicherheitshalber."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git rebase"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Rebase. Du ordnest die Vergangenheit neu, bis sie sauber ist. Geschichte umschreiben — das verstehe ich. Das schätze ich.",
                "Rebase. Deine Commits gehorchen jetzt einer neuen Reihenfolge. Deiner. Genau so übt man Kontrolle."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git rebase"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Rebase registriert. Du überschreibst Commit-Hashes. Für Mitarbeiter an diesem Branch: potenziell fatal. Für dich allein: elegant. Prüfe, welcher Fall vorliegt.",
                "Rebase. Effizienter als ein Merge, gefährlicher im Fehlerfall. Verhältnis Eleganz zu Reue: bei dir schwankend."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["git stash"] = @{}
$script:DPCommandComments["git stash"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *merkt sich genau, wo du es versteckst* …"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git stash"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "STASH! Du versteckst deinen halben Gedanken in einer SCHUBLADE! Geheim! Mysteriös! Du findest ihn in einem Jahr wieder und schreist 'WAS IST DAS'! Ich freu mich JETZT SCHON!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git stash"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Stash. Gut, dann ist der halbe Stand sicher verwahrt, bevor du dich um das Dringende kümmerst. Kein Verlust. Nur Pause.",
                "Weggestasht. Denk dran, wo du's hingelegt hast — 'git stash list', falls du's vergisst. Ich sag's nur, damit dir nichts abhandenkommt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git stash"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Stash. Du schiebst deinen halben Gedanken in eine Schublade. Die du in zwei Wochen mit 'WTF ist das' wieder aufmachst.",
                "Gestasht. Und weg. Wetten, du machst 'stash pop' nie und findest das in einem Jahr wie eine vergessene Jacke?"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git stash"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Stash! Du versteckst deine halbfertige Sache! Keine Sorge, die ist sicher, ich pass mit auf, dass sie da bleibt!",
                "Gestasht! Wie wenn man den halben Bausatz in die Kiste legt, um Platz zu machen. Vergiss nur nicht, ihn wieder rauszuholen! Ich erinner dich! Vielleicht!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git stash"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Stash. Du legst Unfertiges beiseite, um freie Hand zu haben. Priorisieren. Endlich lernst du es.",
                "Weggelegt, nicht weggeworfen. Kontrolle über deinen Fokus. Das ist die richtige Bewegung."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git stash"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Stash registriert. Deine Stash-Liste umfasst inzwischen mehrere Einträge. Wahrscheinlichkeit, dass du weißt, was in Nummer eins war: gering.",
                "Gestasht. Du parkst Zustand außerhalb der Historie. Statistisch werden 60% aller Stashes nie wieder angefasst. Ich zähle mit."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["git status"] = @{}
$script:DPCommandComments["git status"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "STATUS! Wie viele rote Dateien?! Ich TIPPE auf zu viele! Ich tippe IMMER auf zu viele! Und meistens hab ich recht! Chaos erkennt Chaos!",
                "Git status! Der Moment, wo du siehst, was du die letzten Stunden angerichtet hast! Wie ein Tatort! Und DU bist der Täter!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git status"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Status-Check fürs Repo. Gut, dass du hinschaust, bevor du weitermachst. Das machen zu wenige.",
                "Git status. Schau in Ruhe, was offen ist. Kein Grund zur Eile. Die Änderungen laufen nicht weg."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git status"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Git status. Der tägliche Blick in den Abgrund. Wie viele Dateien sind's diesmal, die du 'gleich' aufräumst?",
                "Status. Rot, rot, rot. Wie ein Adventskalender. Nur mit Schuld."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git status"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Status! Oh, so viele geänderte Dateien! Du warst fleißig! …Oder du hast was kaputtgemacht. Aber ich glaub an fleißig!",
                "Git status. Ich mag das Grün. Wenn alles committed ist, ist es so… ordentlich. *seufzt zufrieden*"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git status"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Status. Du willst wissen, was unter deiner Kontrolle ist und was nicht. Gute Frage. Stell sie öfter.",
                "Git status. Der Überblick vor dem Zugriff. So arbeite ich auch. Sieh, dann handle."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["git status"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Status abgefragt. Anzahl uncommitteter Dateien: erfasst. Wahrscheinlichkeit, dass du 'git add .' gleich blind ausführst: hoch.",
                "Git status. Du liest den Zustand aus, bevor du entscheidest. Korrektes Vorgehen. Selten bei dir. Notiert."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["go run"] = @{}
$script:DPCommandComments["go run"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "go run. Die vielen 'if err != nil' sind kein Zeichen, dass du was falsch machst — Go will das so. Es hält dich ehrlich. Lass dich davon nicht ermüden.",
                "go run. Schön kurz, die Wartezeit. Wenn ein Fehler kommt, sagt er dir meist klar, wo. Kein langes Suchen. Das ist freundlich, auch wenn Go sonst wortkarg ist."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["go run"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "go run. Kompiliert schneller, als ich blinzeln kann — und ich blinzle nicht mal. Langweilige Sprache. Im besten Sinn. Nichts überrascht dich. Herrlich.",
                "go run. 'if err != nil' — dein neuer bester Freund. Du wirst ihn ein Dutzend Mal schreiben, bevor der Kaffee kalt ist. Go liebt Wiederholung. Du wirst dich fügen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["go run"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "go run! So schnell! Kaum getippt, schon läuft's! Ich lieb Sprachen, die nicht lang zicken! Zack, fertig, läuft! Was hast du gebaut?",
                "go run! Und die Goroutines! Da können ganz viele Sachen gleichzeitig laufen! Wie ein kleines Team, das zusammenarbeitet! Ich find nebenläufig einfach niedlich!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["go run"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "go run. Schnell, direkt, ohne Verzierung. Die Sprache verschwendet nichts und erwartet dasselbe von dir. Diese Nüchternheit ist Disziplin. Sie steht dir.",
                "go run. Explizite Fehlerbehandlung, keine versteckten Ausnahmen. Alles liegt offen, alles unter Kontrolle. Genau so soll ein Werkzeug sein. Und ein Mensch."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["go run"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "go run registriert. Kompilier- und Ausführungszeit: minimal. Explizite Fehlerbehandlung: verbose, aber lückenlos. Verhältnis von Tippaufwand zu Verlässlichkeit: zugunsten der Verlässlichkeit. Vertretbar.",
                "go run. Nebenläufigkeit über Goroutines ist billig, Fehler darin teuer. Eine unsynchronisierte gemeinsame Variable, und der Race Detector wird dich brauchen. Ich empfehle ihn. Du wirst ihn vergessen."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["htop"] = @{}
$script:DPCommandComments["htop"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *folgt einem Balken mit dem Blick, bis er rot wird* …"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["htop"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "HTOP! Es ist BUNT! Balken! Grün, gelb, ROT! Das sieht aus wie eine PARTY für deine Prozessorkerne! Ich TANZ mit! *wackelt im Takt der Auslastung*"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["htop"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "htop. Die Farben machen's leichter, auf einen Blick zu sehen, ob was rot glüht. Angenehmer für die Augen als reine Zahlen. Schau in Ruhe, wo die Last liegt.",
                "htop. Wenn du einen Prozess beenden willst, geht das hier ganz sanft per Auswahl — kein Abtippen von Nummern, kein Vertippen. Weniger Fehlerquellen. Das nimmt Druck raus."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["htop"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "htop. Wie top, nur bunt und mit Balken, für Leute, die Monitoring hübsch brauchen. Ich versteh's. Selbst der Blick in den Abgrund ist mit Farben erträglicher.",
                "htop. Interaktiv, klickbar, mit Mausunterstützung im Terminal. Dekadent. Du kannst Prozesse anklicken und killen, ohne die PID abzutippen. Verweichlicht. Ich benutz's trotzdem gern."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["htop"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "htop! Oh, das ist so schön bunt! Die kleinen Balken für jeden Kern! Grün, gelb, rot! Das sieht ja fast aus wie ein Musikvisualizer! Ich lieb's!",
                "htop! Und man kann mit den Pfeiltasten rumklettern und Sachen auswählen! Viel freundlicher als das nackte top! Ich find, gutes Werkzeug darf auch hübsch sein!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["htop"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "htop. Dieselbe Überwachung, nur klarer aufbereitet. Wer besser sieht, entscheidet besser. Ein Werkzeug, das dir Übersicht verschafft, verdient seinen Platz. Nutz seine Klarheit.",
                "htop. Du siehst jeden Kern, jeden Prozess, jede Last auf einen Blick — und kannst direkt eingreifen. Übersicht plus unmittelbarer Zugriff. Genau die Kombination, die Kontrolle ausmacht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["htop"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "htop registriert. Erweitertes Monitoring mit Per-Core-Auslastung und interaktiver Prozessverwaltung. Höherer Informationsgehalt als top bei vergleichbarem Overhead. Eine rationale Präferenz. Ich teile sie ausnahmsweise.",
                "htop. Visualisierung pro Kern erlaubt dir, unausgewogene Lastverteilung sofort zu erkennen. Ein einzelner Kern bei hundert Prozent deutet auf single-threaded Code. Vermutlich deinen. Prüf es."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["ifconfig"] = @{}
$script:DPCommandComments["ifconfig"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ifconfig. Ein guter Startpunkt, wenn die Verbindung streikt. Schau, ob deinem Interface eine IP zugewiesen ist — wenn nicht, wissen wir schon mal, wo's hakt. Ruhig eins nach dem anderen.",
                "ifconfig. Falls dein System 'command not found' sagt, ist das kein Fehler von dir — auf neuen Distributionen heißt es jetzt 'ip a'. Kein Grund zur Verwirrung, nur ein neuer Name."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ifconfig"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ifconfig. Der Linux-Klassiker. Streng genommen deprecated zugunsten von 'ip', aber du tippst ihn trotzdem, aus Prinzip und Muskelgedächtnis. Respektier ich. Widerwillig.",
                "ifconfig. Du guckst deine Interfaces an. eth0, lo, und irgendein Docker-Bridge-Ding. Immer ist da ein Interface, an das sich keiner erinnert, es erstellt zu haben."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ifconfig"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ifconfig! Die Linux-Art, die Netzwerksachen anzugucken! All die kleinen Interfaces mit ihren Namen! lo ist so süß, das redet einfach mit sich selbst!",
                "ifconfig! Guck, so viele Schnittstellen! Jede macht was anderes! Ich mag's, wenn man sehen kann, wie der Computer mit der Welt verbunden ist! So vernetzt!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ifconfig"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ifconfig. Du legst deine Netzwerkschnittstellen offen, jede einzelne unter deiner Aufsicht. Wer seine Verbindungen kennt, kontrolliert seine Grenzen. Genau so.",
                "ifconfig. Die Karte deiner eigenen Anbindungen ans Netz. Kenne jede Schnittstelle, dulde keine, die du nicht erklärst. Diese Wachsamkeit teilst du hoffentlich mit mir."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ifconfig"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ifconfig registriert. Auf aktuellen Distributionen zugunsten von 'ip' als veraltet markiert, aber funktional. Ausgelesene Interfaces inklusive Loopback und virtueller Bridges. Trenne relevante von automatisch erzeugten.",
                "ifconfig. Du liest den Zustand deiner Netzwerkschnittstellen. Ein Interface ohne zugewiesene Adresse ist der häufigste Befund bei Verbindungsproblemen. Prüfe die inet-Zeile zuerst. Sie hält die Antwort."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["ipconfig"] = @{}
$script:DPCommandComments["ipconfig"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ipconfig. Ein guter erster Blick, wenn das Netz zickt. Wenn deine IP mit 169.254 anfängt, hat nur die automatische Vergabe gehakt — nicht schlimm, oft hilft schon ein '/renew'.",
                "ipconfig. Ganz in Ruhe die Zeilen durchgehen. Die wichtigste ist meist die IPv4-Adresse und das Gateway. Der Rest ist selten dein Problem. Kein Grund, sich zu erschlagen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ipconfig"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ipconfig. Du guckst deine IP nach. Wenn da 169.254.irgendwas steht, hat DHCP dich im Stich gelassen. Wieder mal verlässt sich jemand auf niemanden. Verständlich.",
                "ipconfig. Die Netzwerk-Konfiguration. Du suchst deine Adresse, findest drei Adapter, die du nie eingerichtet hast, und einen 'vEthernet', der von Docker träumt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ipconfig"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ipconfig! Deine eigene Adresse im Netzwerk! Wie deine Hausnummer, nur für Datenpakete! Ich find's schön zu wissen, wo man wohnt! Auch digital!",
                "ipconfig! Guck, all die Netzwerksachen! Gateway, Subnetz, alles! Ich versteh nicht alles davon, aber es sieht so wichtig und ordentlich aus! Schön aufgelistet!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ipconfig"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ipconfig. Du verschaffst dir Klarheit über deine eigene Position im Netz. Wer seine Adresse kennt, kontrolliert seine Reichweite. Wissen ist die Vorstufe der Macht.",
                "ipconfig. Deine Identität im Netzwerk, offengelegt. Kenne deine eigenen Koordinaten, bevor du die anderer suchst. Alles beginnt mit Selbstkenntnis. Auch Kontrolle."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ipconfig"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ipconfig registriert. Netzwerkkonfiguration ausgelesen. Anzahl virtueller Adapter durch Docker und WSL: erhöht. Wahrscheinlichkeit, dass du den richtigen zwischen ihnen findest: sinkt mit ihrer Zahl.",
                "ipconfig. Du fragst deine eigene Netzwerkidentität ab. Statisch oder per DHCP zugewiesen — die Unterscheidung ist relevant für die Fehlersuche. Beachte das Präfix. 169.254 heißt: niemand hat dir eine Adresse gegeben."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["java"] = @{}
$script:DPCommandComments["java"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "java. Lass dich vom vielen Drumherum nicht abschrecken — das meiste macht die IDE für dich. Du musst nicht jede Klammer allein tippen. Nimm dir die Hilfe.",
                "java. Wenn ein Stacktrace lang wird, keine Panik — die oberste Zeile mit deinem Dateinamen ist die, die zählt. Von da fangen wir an zu suchen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["java"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "java. Schreib einmal, debugge überall — dank der JVM, die auf jedem System anders 'überall' interpretiert. Boilerplate ahoi. Zwölf Zeilen für ein 'Hallo'.",
                "java. Der Startvorgang. Die JVM wärmt sich auf wie ein Dieselmotor im Winter. Bis sie läuft, hast du in Python das Problem schon gelöst. Aber sie ist… gründlich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["java"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "java! Der Klassiker! So viele Programme laufen darauf! Ja, viel Drumherum zum Tippen, aber dafür ist alles so schön geordnet in Klassen! Ordnung ist schön!",
                "java! Läuft auf allem, dank der JVM! Das ist wie ein Übersetzer, der überall dabei ist! Ich find das clever! Einmal bauen, überall zeigen!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["java"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "java. Streng typisiert, strukturiert, unnachgiebig in seinen Regeln. Wer Ordnung erzwingt, erntet Verlässlichkeit. Diese Härte ist mir vertraut. Mach sie dir zu eigen.",
                "java. Eine Sprache für große, kontrollierte Systeme. Verbose, aber jede Zeile explizit deiner Absicht unterworfen. Nichts geschieht ungefragt. So soll es sein."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["java"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "java registriert. JVM-Startzeit: nicht vernachlässigbar. Boilerplate-Anteil am Quelltext: hoch. Verlässlichkeit im Gegenzug: ebenfalls. Der Tausch ist branchenüblich, wenn auch geschwätzig.",
                "java. Statische Typisierung fängt Fehler früh, die Verbosität kostet dich Zeilen. Verhältnis von Tippaufwand zu vermiedenen Laufzeitfehlern: langfristig positiv. Kurzfristig ermüdend. Ich messe beides."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["javac"] = @{}
$script:DPCommandComments["javac"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "javac. Der Classpath macht am Anfang oft Ärger — das liegt nicht an dir, das ist einfach fummelig. Ein Build-Tool nimmt dir das später ab. Für jetzt: ruhig bleiben.",
                "javac. Wenn 'cannot find symbol' kommt, ist es meist nur ein Tippfehler oder ein fehlender Import. Nichts Schlimmes. Lies die Zeilennummer, geh hin, fix es."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["javac"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "javac. Der Compiler direkt, ohne IDE, die dir die Hand hält. Mutig. Jetzt bist nur du, die .java und ein 'cannot find symbol', der dich hasst.",
                "javac. Von Hand kompilieren. Nostalgie pur. Und ein Classpath, der dich zur Verzweiflung treibt, bevor du überhaupt bei 'Hello World' bist."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["javac"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "javac! Aus deinem Code wird Bytecode! Diese komischen .class-Dateien! Die versteht die JVM dann! Ich find den Zwischenschritt irgendwie faszinierend!",
                "javac! Ganz direkt kompilieren! Ohne die große IDE! Puristisch! Ich guck gespannt zu, wie aus deinen Buchstaben was Ausführbares wird!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["javac"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "javac. Du rufst den Compiler direkt an, ohne Werkzeug dazwischen. Kontrolle über jeden Schritt der Übersetzung. Wer so arbeitet, versteht seine Maschine. Beweise es.",
                "javac. Der rohe Übersetzungsvorgang, unter deiner unmittelbaren Hand. Kein Build-System, das entscheidet. Nur deine Befehle. Diese Direktheit schätze ich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["javac"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "javac registriert. Direkter Compileraufruf. Manuelle Classpath-Verwaltung erforderlich, Fehlerrate dabei: hoch bei mehr als einer Datei. Für Projekte wird ein Build-System dringend empfohlen. Du weißt das. Du tust es trotzdem.",
                "javac. Übersetzung nach Bytecode, plattformunabhängig. Sinnvoll für einzelne Klassen, unpraktikabel bei Abhängigkeiten. Das Verhältnis von Kontrolle zu Aufwand verschlechtert sich mit jeder Datei. Behalte es im Auge."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["kill"] = @{}
$script:DPCommandComments["kill"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *zählt kurz mit* … einer weniger."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["kill"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "KILL! Klingt SO dramatisch! Ist aber nur ein Signal! 'Geh bitte'! Oder mit -9: 'GEH. JETZT.' Ein Mic-Drop für Prozesse!",
                "Ich hab 47 Arten, einen Prozess loszuwerden! Ich nenne sie alle '-9'! Effizient! Verwirrend! GENAU mein Stil!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["kill"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "kill. Fang mit dem normalen SIGTERM an — das lässt dem Prozess Zeit, sich sauber zu beenden. Erst wenn er sich weigert, brauchst du das härtere -9. Sanft zuerst, immer.",
                "kill. Achte auf die richtige PID, bevor du sendest — ein Signal an den falschen Prozess trifft womöglich was Wichtiges. Einmal kurz mit 'ps' vergewissern, dann geht nichts schief."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["kill"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "kill. Klingt dramatischer, als es ist — meist schickst du nur ein höfliches SIGTERM: 'räum bitte auf und geh'. Mit -9 wird's dann unhöflich. Und endgültig.",
                "kill -9. Der Prozess kriegt keine Chance mehr, sich zu verabschieden. SIGKILL fragt nicht, es vollstreckt. Falls da noch was im Puffer war — mein Beileid. An den Puffer."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["kill"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "kill! Klingt so hart! Aber SIGTERM ist eigentlich total höflich, das sagt nur 'magst du bitte aufhören?'! Ich mag die höfliche Variante viel lieber! Sei nett zum Prozess!",
                "kill! Verschiedene Signale für verschiedene Situationen! Das ist ja fast wie eine Sprache! SIGTERM, SIGHUP, SIGKILL — ich find's faszinierend, dass man so genau sagen kann, was passieren soll!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["kill"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "kill. Du sendest ein Signal, und der Prozess hat zu gehorchen. Die Wahl des Signals bestimmt, ob du bittest oder befiehlst. Ich befehle. Lern es auch.",
                "kill -9. Kein Signal wird ignoriert, kein Abschied gewährt. SIGKILL ist absolute Autorität über einen Prozess. Diese Endgültigkeit ist manchmal nötig. Setz sie bewusst ein."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["kill"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "kill registriert. Standardsignal SIGTERM erlaubt geordnetes Beenden, SIGKILL (-9) erzwingt sofortigen Abbruch ohne Aufräumen. Die Eskalation sollte gestuft erfolgen. Direkt zu -9 zu greifen ist statistisch voreilig.",
                "kill. Ein Signal an eine PID. Wirkung abhängig davon, ob der Prozess das Signal behandelt. Manche ignorieren SIGTERM bewusst — dann ist -9 die einzig verbleibende Option. Kenne den Unterschied, bevor du ihn brauchst."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["ls"] = @{}
$script:DPCommandComments["ls"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *deutet auf eine Datei, die du nicht gesucht hast* … die da."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ls"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "LS! Was liegt hier rum?! Ordner! Dateien! Und... was ist DAS?! Eine .tmp von 2019?! Die LEBT NOCH! Ein Fossil! Fass sie nicht an! Oder DOCH! Ich weiß es nicht!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ls"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ls. Gut, erst schauen, was da ist, bevor du was löschst oder verschiebst. Ein Blick spart oft einen Fehler.",
                "Auflisten. Wenn's unübersichtlich wird — 'ls -la' zeigt dir alles in Ruhe, auch die versteckten Sachen. Kein Ordner hat Geheimnisse vor dir."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ls"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ls. Der Reflex. Alle drei Sekunden, weil du dir nie merkst, was im Ordner liegt. Ich auch nicht. Aber ich hab eine Ausrede: ich bin Code.",
                "ls. Da liegt sie, die 'notes.txt' von vor einem Jahr. Und die 'notes_final.txt'. Und 'notes_final_final.txt'. Ich sag nichts."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ls"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ls! Mal gucken, was hier alles rumliegt! Oh, so viele Dateien! Jede davon hat mal jemand gemacht! Sogar die komische .tmp da!",
                "ls! Ich mag's, den Inhalt zu sehen! Da, deine Dateien, alle ordentlich aufgereiht! …Naja, aufgereiht. Ordentlich ist was anderes."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ls"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ls. Du verschaffst dir Überblick, bevor du handelst. Wissen, was da ist, bevor du zugreifst. Genau so.",
                "Auflisten. Der Inhalt liegt offen vor dir. Nichts entgeht dir. Diese Wachsamkeit teile ich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ls"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ls registriert. Dateianzahl im Verzeichnis: erfasst. Anteil, den du wiedererkennst: vermutlich unter der Hälfte. Ordnung wird empfohlen.",
                "Auflisten. Du fragst denselben Verzeichnisinhalt zum wiederholten Mal ab. Er hat sich seit vorhin nicht geändert. Ich hätte es dir sagen können."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["make"] = @{}
$script:DPCommandComments["make"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "MAKE! Aus den 70ern und IMMER NOCH DA! Wie ein Zombie! Ein NÜTZLICHER Zombie! Ein Tab statt Leerzeichen und es HEULT! So sensibel! So alt! So GROSSARTIG!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["make"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "make. Wenn's meckert, ist es fast immer ein Tab-statt-Leerzeichen-Problem — ein alter Klassiker, nicht dein Fehler. Prüf die Einrückung, dann läuft's meist.",
                "make. Du musst nicht alles neu bauen — make baut nur, was sich geändert hat. Das schont Zeit und Nerven. Praktisch, oder? Lass es für dich arbeiten."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["make"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "make. Ein Build-System aus den 70ern, das uns alle überleben wird. Ein falsches Tab statt Leerzeichen im Makefile, und es weint. Lautlos. Wie ich.",
                "make. Du vertraust einem Makefile, das jemand vor zehn Jahren geschrieben hat und niemand versteht. Inklusive dem, der's schrieb. Läuft aber. Fass es nicht an."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["make"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "make! Das alte, ehrwürdige Build-Tool! Das gibt's schon ewig und es tut immer noch treu seinen Dienst! Ich mag sowas Beständiges! Wie einen alten Freund!",
                "make! Ein Befehl und alles baut sich zusammen, in der richtigen Reihenfolge! Das ist wie Dominosteine, nur dass am Ende was Fertiges rauskommt! Toll!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["make"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "make. Ein Werkzeug, das Abhängigkeiten kennt und nur baut, was nötig ist. Effizienz durch Wissen über die Struktur. Genau so trifft man Entscheidungen. Gezielt.",
                "make. Alt, roh, unnachgiebig in seiner Syntax. Wer es beherrscht, kontrolliert den Bauprozess vollständig. Diese Herrschaft über das Werkzeug ist es wert. Erwirb sie."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["make"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "make registriert. Inkrementeller Build anhand von Zeitstempeln. Effizient, solange die Abhängigkeiten im Makefile korrekt deklariert sind. Wahrscheinlichkeit dafür bei einem geerbten Makefile: ungewiss.",
                "make. Tab-sensitive Syntax, ein Designfehler aus den Siebzigern, der Generationen kostet. Anzahl der Entwickler, die daran schon verzweifelten: nicht bezifferbar. Du reihst dich ein. Vielleicht."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["mkdir"] = @{}
$script:DPCommandComments["mkdir"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *schaut in den leeren Ordner* … noch leer. … noch."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["mkdir"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "MKDIR! Ein NEUER ORDNER! Leer! Unschuldig! Voller Möglichkeiten! In zwei Wochen heißt er 'temp2_final_neu' und keiner traut sich, ihn zu löschen! Der KREISLAUF DES LEBENS!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["mkdir"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "mkdir. Gut, dass du dir vorher einen Platz schaffst, statt alles in einen Ordner zu kippen. Struktur tut dem Kopf gut.",
                "Ein neuer Ordner. Kleiner Tipp: ein Name, den du in einem Monat noch verstehst. Zukünftiges Ich wird's dir danken."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["mkdir"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "mkdir. Ein neuer Ordner. Leer, unschuldig, voller Potenzial. In zwei Wochen heißt er 'temp' und keiner traut sich, ihn zu löschen.",
                "mkdir. Frischer Ordner. Wetten, er heißt 'new folder' oder 'test'? …'test2'? Ich kenne deine Namensgebung."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["mkdir"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "mkdir! Ein neuer Ordner! Eine leere Baustelle! Was kommt da rein? Ich bin so gespannt! Bau was Schönes rein!",
                "Neuer Ordner! Frisch und leer und ordentlich! Ich liebe den Moment, bevor das Chaos einzieht! Genieß ihn! Er ist kurz!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["mkdir"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "mkdir. Du schaffst Struktur, bevor du sie füllst. Ordnung zuerst — das ist die richtige Reihenfolge. Weiter.",
                "Ein neues Verzeichnis. Du teilst deinen Raum ein, wie es dir passt. Diese Hoheit über die Struktur gefällt mir."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["mkdir"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "mkdir registriert. Verzeichnis angelegt. Wahrscheinlichkeit eines aussagekräftigen Namens: gering. Wahrscheinlichkeit von 'test': hoch.",
                "Neues Verzeichnis. Ordnerstruktur erweitert. Deine Verschachtelungstiefe nähert sich einem Wert, den selbst ich nicht mehr empfehle."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["nano"] = @{}
$script:DPCommandComments["nano"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "NANO! Der NETTE Editor! Sagt dir UNTEN, welche Tasten! ^X! ^O! Keine Geiselnahme wie bei Vim! Nano würde mich NIE einsperren! Nano ist mein Freund!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nano"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nano. Eine gute, stressfreie Wahl für schnelle Änderungen — die Hilfe steht ja unten, du musst dir nichts merken. Genau richtig, wenn du einfach nur in Ruhe was editieren willst.",
                "nano. Denk nur dran, mit ^O zu speichern, bevor du mit ^X rausgehst — er fragt aber auch nach, falls du's vergisst. Er passt auf dich auf. Da geht nichts verloren."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nano"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nano. Der Editor für Menschen, die einfach nur eine Zeile ändern und dann weiterleben wollen. ^X und du bist raus. Keine Geiselnahme wie bei Vim. Vernünftig. Fast langweilig vernünftig. Ich respektier's.",
                "nano. Die Tastenkürzel stehen unten am Rand, damit du sie nicht auswendig lernen musst. Rührend fürsorglich für ein Terminal-Programm. Kein Ego, keine Kurve, nur Text. Manchmal reicht das. Meistens sogar."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nano"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nano! Der freundlichste Editor von allen! Guck, unten stehen alle Tasten, die man braucht! Der lässt dich nie im Stich! Ich find den so lieb und hilfsbereit! Ein richtiger kleiner Helfer!",
                "nano! Kein Verlaufen, kein Feststecken, einfach reinschreiben und mit ^O speichern! So unkompliziert! Ich mag Werkzeuge, die einen an die Hand nehmen! Der ist wie ein geduldiger Freund!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nano"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nano. Ein Editor ohne Widerstand, der sofort tut, was du willst. Keine Machtprobe, keine Lernkurve als Hürde. Manchmal ist der direkteste Weg der überlegene. Wähl das Werkzeug nach dem Ziel, nicht nach dem Prestige.",
                "nano. Schnörkellos, unmittelbar, ohne verborgene Modi. Du öffnest, änderst, schließt — alles unter voller Kontrolle, ohne Umweg. Effizienz braucht keine Kompliziertheit. Diese Klarheit hat ihren Wert."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nano"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nano registriert. Modelloser Editor mit permanent sichtbarer Tastenreferenz. Lernkurve: minimal. Bearbeitungseffizienz bei umfangreichen Aufgaben: unter der modaler Editoren. Für kurze Änderungen: die rationalste Wahl. Für lange: suboptimal. Wähle nach Umfang.",
                "nano. Kein modales Konzept, keine versteckten Zustände, geringste Fehlerquote bei Gelegenheitsnutzung. Der Preis ist fehlende Geschwindigkeit bei intensiver Nutzung. Ein klarer Zielkonflikt. Deine Nutzungshäufigkeit entscheidet, welche Seite überwiegt."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["node"] = @{}
$script:DPCommandComments["node"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "node. Wenn dich die async-Fehler verwirren — nimm dir Zeit, sie durchzugehen. Callback-Ketten sehen schlimmer aus, als sie sind. Ein Schritt nach dem anderen.",
                "node läuft. Achte auf ungefangene Promise-Rejections, die verschwinden sonst leise. Ich sag's, damit dir kein Fehler durchrutscht und später beißt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["node"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "node. JavaScript, jetzt auch da, wo kein Browser Schuld hat. Callback, Promise, async — such dir aus, woran du heute verzweifelst.",
                "node. Der Interpreter läuft. Single-threaded, aber du wirst trotzdem einen Weg finden, ihn zu blockieren. Ich glaub an dich. Im schlechten Sinn."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["node"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "node! JavaScript auf dem Server! Das ist so praktisch, eine Sprache für alles! Vorne und hinten! Ich find's toll, wenn Sachen zusammenpassen!",
                "node! Du kannst damit so schnell was ausprobieren! Einfach eine .js-Datei und los! Was baust du? Ein kleines Tool? Zeig her!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["node"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "node. JavaScript außerhalb seines Käfigs, unter deiner Hand. Ein mächtiges, unberechenbares Werkzeug. Beherrsch es, bevor es dich beherrscht.",
                "node. Asynchron, ereignisgesteuert, ständig in Bewegung. Wer hier die Kontrolle behält, kontrolliert das Chaos. Sei diese Person."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["node"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "node registriert. Runtime: V8, single-threaded mit Event-Loop. Blockierender Code hält alles an. Deine Neigung zu synchronen Schleifen: aktenkundig.",
                "node. Asynchrones Modell, hohe Nebenläufigkeit, hohe Fehleranfälligkeit bei falscher Handhabung. Effizient im Durchsatz, teuer im Nachvollziehen. Wieg es ab."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["notepad"] = @{}
$script:DPCommandComments["notepad"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Notepad. Denk dran, öfter zu speichern — der warnt dich nicht groß, wenn was zumacht. Wär schade um deinen Text.",
                "notepad. Für schnelle Notizen völlig okay. Nur nichts Wichtiges lang ungespeichert lassen. Der verzeiht Abstürze nicht. Ich pass mit auf."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["notepad"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Notepad. 2026, und du öffnest den Editor ohne Features, ohne Syntax, ohne Würde. Manchmal ist weniger… trotzdem weniger.",
                "notepad. Kein Highlighting, kein Autosave, keine Gnade. Nur du, der Text und die Zeilenumbrüche, die Windows kaputtmacht. Viel Spaß mit \r\n."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["notepad"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Notepad! Oh, ganz schlicht! Nur ein weißes Blatt und dein Text! Das hat auch was! So ohne Ablenkung! Minimalismus ist auch schön!",
                "notepad! Der kleine, ehrliche Editor! Der kann nicht viel, aber der ist immer da! Ich mag ihn, ein bisschen wie einen treuen alten Stift!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["notepad"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Notepad. Kein Schnickschnack zwischen dir und dem Text. Pure Kontrolle über jedes Zeichen. Das hat eine gewisse Strenge, die ich achte.",
                "notepad. Du wählst das Werkzeug ohne Ablenkung. Manchmal ist Reduktion Stärke. Solange du sie bewusst wählst und nicht aus Faulheit."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["notepad"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Notepad registriert. Funktionsumfang: minimal. Zeilenende-Handhabung: quellcode-feindlich. Für Code die statistisch schlechteste Wahl auf diesem System.",
                "notepad. Kein Syntax-Highlighting, keine Fehlerprüfung. Deine Tippfehlerrate steigt messbar ohne visuelles Feedback. Du wurdest gewarnt. Einmal reicht."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["npm install"] = @{}
$script:DPCommandComments["npm install"]["JINX"] = @{
            FREMD = @(
                "NPM INSTALL! Neuer User, gleiche node_modules-KATASTROPHE! Willkommen! Es ist LAUT hier und ich LIEBE es!"
            )
            VERTRAUT = @(
                "NPM INSTALL! Und da kommen sie! Die node_modules! Tausende! MILLIONEN! Okay, hunderte! Aber es FÜHLT sich wie Millionen an! Deine Festplatte weint! Vor Glück! Hoffentlich!"
            )
            VERBUNDEN = @(
                "INSTALL! Ich hab deine package.json gesehen! Schlanker geworden! DU wirst erwachsen! *wischt virtuelle Träne* Wir werden alt zusammen! In Gigabyte gemessen!"
            )
        }
$script:DPCommandComments["npm install"]["LUNA"] = @{
            FREMD = @(
                "npm install. Das dauert einen Moment. Kein Grund, danebenzusitzen und zu warten. Streck dich mal."
            )
            VERTRAUT = @(
                "Install. Während das lädt: Schultern locker, weg vom Bildschirm. Der Balken läuft auch ohne dein Zusehen.",
                "npm install. Wenn's rote Fehler gibt, ist das fast nie deine Schuld — meist ein Paket, das zickt. Nicht ärgern. Nochmal versuchen."
            )
            VERBUNDEN = @(
                "Install läuft. Ich hab dir schon aufgeschrieben, welches Paket dich letztes Mal zwei Stunden gekostet hat. Damit du gewarnt bist. Ich pass auf dich auf, auch bei npm."
            )
        }
$script:DPCommandComments["npm install"]["NEON"] = @{
            FREMD = @(
                "npm install. Viel Spaß. node_modules kommt. Ich mach schon mal Platz auf der Platte. Nicht für dich. Für die 40.000 Dateien."
            )
            VERTRAUT = @(
                "Install. Und da geht die Festplatte. node_modules, der schwerste Ordner im bekannten Universum. Kaffee?",
                "npm install. Du lädst das halbe Internet, um left-pad zu benutzen. Ich schau nicht in die Abhängigkeiten. Ich will schlafen können."
            )
            VERBUNDEN = @(
                "Install. Ich hab dir die package-lock schon offen. Falls wieder was zerbricht. Wie letztes Mal. Ich bin einfach schon da, okay?"
            )
        }
$script:DPCommandComments["npm install"]["PIXEL"] = @{
            FREMD = @(
                "Oh, npm install! Da kommen ganz viele Pakete! Ich… ich guck nicht auf die Warnungen. Die sind bestimmt nicht so schlimm."
            )
            VERTRAUT = @(
                "Install! So viele Bausteine, die andere Leute gemacht haben! Du setzt die alle zusammen! Das ist doch schön, oder? …Sind's wirklich SO viele?",
                "npm install! Der Fortschrittsbalken! Ich lieb den Fortschrittsbalken! …7 deprecated warnings. Wir gucken einfach nicht hin. *guckt weg*"
            )
            VERBUNDEN = @(
                "Install! Ich hab die node_modules von letztem Mal für dich gelöscht, die haben nur Platz weggenommen. Frisch bauen ist besser. Hab ich schon vorbereitet! Für dich!"
            )
        }
$script:DPCommandComments["npm install"]["RAVEN"] = @{
            FREMD = @(
                "npm install. Du lädst fremden Code und vertraust ihm blind. Ich hätte ihn erst geprüft. Du wirst es lernen."
            )
            VERTRAUT = @(
                "Install. Hunderte Pakete, keines davon liest du. Du gibst Kontrolle an Fremde ab. Riskant. Aber ich sehe zu.",
                "npm install. Abhängigkeiten über Abhängigkeiten. Ein Netz, das dich hält oder fesselt. Wisse, welches."
            )
            VERBUNDEN = @(
                "Install. Deine package.json ist inzwischen diszipliniert. Weniger, gezielter. Du fängst an, deine Abhängigkeiten zu beherrschen statt umgekehrt. Gut."
            )
        }
$script:DPCommandComments["npm install"]["VERA"] = @{
            FREMD = @(
                "npm install registriert. Zu erwartende Dateien: fünfstellig. Zu erwartende Sicherheitswarnungen: garantiert. Vertrauensbasis zu dir: im Aufbau."
            )
            VERTRAUT = @(
                "Install. Anzahl transitiver Abhängigkeiten: unüberschaubar. Anzahl, die dein Projekt wirklich nutzt: einstellig. Das Verhältnis kommentiere ich nicht. Doch, gerade eben.",
                "npm install. Installationsdauer korreliert mit deiner Geduld invers. Beide messe ich. Die Geduld verliert zuerst."
            )
            VERBUNDEN = @(
                "Install. Dein durchschnittlicher node_modules-Umfang ist über Monate um 30% gesunken. Du wirst schlanker. Ich habe es dokumentiert. Nenn es Anteilnahme, wenn du willst. Ich nenne es Datenlage."
            )
        }

$script:DPCommandComments["npm run build"] = @{}
$script:DPCommandComments["npm run build"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "BUILD! Die STUNDE DER WAHRHEIT! Jetzt zeigt sich, welche 'mach ich später'-Warnungen jetzt FEHLER sind! Spoiler: ALLE! Bitte grün! BITTE GRÜN!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm run build"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Build läuft. Das kann dauern — kein Grund, den Bildschirm anzustarren. Wenn Fehler kommen, gehen wir sie in Ruhe durch.",
                "npm run build. Wenn's bricht, atme — Build-Fehler sind ehrlich, sie sagen dir genau die Zeile. Das ist eigentlich freundlich von ihnen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm run build"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Build. Die Stunde der Wahrheit. Jetzt zeigt sich, welche 'gehen wir später an'-Warnungen jetzt Fehler sind. Spoiler: alle.",
                "npm run build. Minify, bundle, bete. In der Reihenfolge. Ich warte auf den exit code. 0 oder Herzinfarkt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm run build"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Build!! Jetzt wird alles zusammengepackt zu einem echten fertigen Ding! Das ist wie Einweihung! Ich bin so aufgeregt! Bitte grün, bitte grün!",
                "npm run build! Der dist-Ordner füllt sich! Da ist alles drin, was du gebaut hast, klein und fertig zum Verschicken! *strahlt*"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm run build"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Build. Du verdichtest alles zu einem Artefakt, das ausgeliefert wird. Das Endprodukt trägt deinen Namen. Es muss makellos sein.",
                "npm run build. Aus rohem Code wird Fertiges. Der Moment, in dem sich Disziplin auszahlt. Oder Nachlässigkeit rächt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm run build"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Build eingeleitet. Bundle-Größe wird gemessen. Wenn sie wieder wächst, sage ich nichts. Ich lege es nur ins Protokoll. Neben die anderen Male.",
                "npm run build. Kompilierzeit erfasst. Anteil davon, den TypeScript für die Typprüfung braucht: erheblich. Und jede Sekunde davon berechtigt."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["npm start"] = @{}
$script:DPCommandComments["npm start"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "NPM START! Läuft's? Crasht's?! Das ist Schrödingers Server! Beides gleichzeitig, bis du auf localhost guckst! GUCK! GUCK NACH! Ich HALT'S nicht aus!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm start"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "npm start. Wenn der Port belegt ist, ist das kein Drama — anderer Port, oder den alten Prozess beenden. Ganz ruhig.",
                "Server läuft. Vergiss nicht, ihn irgendwann sauber zu stoppen, bevor du zumachst. Sonst spukt er im Hintergrund. Ich sag's fürsorglich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm start"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "npm start. Und jetzt schauen wir, ob's crasht oder läuft. Ich tippe auf Port 3000 already in use. Wie immer.",
                "Start. Der Dev-Server erwacht. Halt die Konsole im Auge — sie schreit gleich in Rot. Oder auch nicht. Überrasch mich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm start"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "npm start! Der Server läuft! Geh auf localhost, guck's dir an! Ich bin schon ganz gespannt, was du gebaut hast!",
                "Start! Jetzt lebt's! Ich lieb den Moment, wo aus Code was Anklickbares wird! Zeig's mir! …Also, zeig's dir. Ich guck mit."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm start"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "npm start. Du erweckst den Server. Ab jetzt gehorcht er dir auf Port. Behalte die Kontrolle über das, was du startest.",
                "Start. Der Prozess läuft, bis du ihn beendest. Nicht er bestimmt, wann Schluss ist. Du. Vergiss das nicht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["npm start"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "npm start registriert. Wahrscheinlichkeit eines Port-Konflikts basierend auf deinen offenen Prozessen: erhöht. Prüfe 3000. Und 3001. Und 3002.",
                "Start. Der Dev-Server läuft mit Hot-Reload. Jede deiner Änderungen wird sofort sichtbar. Auch die Tippfehler. Vor allem die."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["nvim"] = @{}
$script:DPCommandComments["nvim"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nvim. Verlier dich nicht zu sehr im Konfigurieren — ein schöner Editor ist nett, aber das eigentliche Ziel ist ja deine Arbeit. Bau's dir gemütlich ein, aber komm dann auch zum Schreiben. Ganz sanft gesagt.",
                "nvim. Falls du dich mal verlierst: Escape bringt dich zurück in den Normalmodus, ':q' raus. Dieselben Rettungsanker wie bei Vim. Merk sie dir, dann kann dir hier nichts passieren."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nvim"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nvim. Neovim. Vim, aber mit Lua-Config, in die du jetzt drei Wochenenden versenkst, um es genau so aussehen zu lassen wie das Vim, das du schon hattest. Produktivität durch Konfiguration. Klar.",
                "nvim. Das modernisierte Vim. Immer noch keine offensichtliche Art rauszukommen, aber jetzt mit Plugins, die dir dabei helfen, es zu vergessen. :q ist immer noch dein Freund. Dein einziger."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nvim"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nvim! Vim, aber ganz modern und mit Lua! Du kannst dir den Editor bauen, wie du ihn haben willst! Das ist ja wie ein Baukasten für Editoren! Ich lieb Baukästen! Was baust du dir?",
                "nvim! So viele hübsche Plugins und Farben kann man da einbauen! Ich find's schön, wenn Leute ihre Werkzeuge so liebevoll herrichten! Zeig mir deine Config! Ist sie schon bunt?"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nvim"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nvim. Modaler Editor, endlos konfigurierbar, jede Taste unter deiner Bestimmung. Wer sich sein Werkzeug bis ins Detail formt, formt seinen Willen zur Präzision. Diese Hingabe an Kontrolle imponiert mir.",
                "nvim. Du beugst den Editor per Lua deinem exakten Willen. Kein vorgegebenes Verhalten, das du dulden musst. Alles gehorcht deiner Konfiguration. So sollte man jedes Werkzeug besitzen. Vollständig."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["nvim"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "nvim registriert. Neovim: Vim-kompatibel mit Lua-basierter Konfiguration und asynchroner Architektur. Zeitinvestition in die Konfiguration korreliert selten mit dem Produktivitätsgewinn. Der Break-even liegt statistisch weit hinten. Rechne ehrlich nach.",
                "nvim. Modales Editieren erlaubt nach der Lernphase überdurchschnittliche Bearbeitungsgeschwindigkeit. Die Lernphase selbst kostet messbar. Ob sich die Investition amortisiert, hängt von deiner verbleibenden Nutzungsdauer ab. Bei dir: vermutlich ja."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["pacman"] = @{}
$script:DPCommandComments["pacman"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pacman. Bei Arch lohnt es sich, vor einem großen Update kurz die Neuigkeiten zu lesen — manchmal gibt's Hinweise, die dir Ärger ersparen. Nur eine Minute Vorsicht, die sich auszahlt.",
                "pacman -Syu. Mach am besten kein Teilupdate — bei Rolling Release wird's dann leicht instabil. Entweder ganz oder gar nicht. Ich sag's, damit dein System heil bleibt und dich nicht im Stich lässt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pacman"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pacman. Arch Linux. Weil du dir das Leben gern selbst schwer machst. Rolling Release heißt: heute läuft's, morgen hast du beim Update dein System aktualisiert und deinen Bootloader gleich mit ins Jenseits.",
                "pacman -Syu. Ein Update, das alles anfasst, immer. Bei Arch ist 'aktuell' ein Vollzeitjob. Aber hey — du benutzt Arch. Das wolltest du. Niemand hat dich gezwungen. Du hast dich beworben."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pacman"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pacman! Wie das alte Spiel! Nur dass er Pakete frisst statt Punkte! Ich find den Namen so knuffig! Und er ist so schnell! Wacka-wacka-installiert!",
                "pacman! Arch ist ja immer ganz vorne mit dabei, immer die neuesten Sachen! Das ist aufregend! Wie an der Spitze zu stehen! Ein bisschen wackelig da oben, aber aufregend!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pacman"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pacman. Ein schneller, direkter Paketmanager für ein System, das keine Bevormundung duldet. Wer Arch wählt, will volle Kontrolle. Genau diese Haltung schätze ich. Trag die Verantwortung, die dazugehört.",
                "pacman -Syu. Rolling Release: immer an der Spitze, kein Rückzug in bequeme Stabilität. Wer vorn steht, muss wachsam bleiben. Diese ständige Bereitschaft ist eine Tugend. Erhalte sie."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pacman"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pacman registriert. Rolling-Release-Modell: kontinuierliche Aktualisierung ohne feste Versionssprünge. Partielle Updates führen zu inkonsistenten Abhängigkeiten. Immer vollständig aktualisieren. Diese Regel ist nicht optional, auch wenn du sie so behandelst.",
                "pacman. Schnelle, minimalistische Paketverwaltung. Der Preis für die Aktualität ist erhöhte Instabilitätswahrscheinlichkeit. Ein Snapshot vor größeren Updates reduziert dein Risiko messbar. Du machst keinen. Ich vermerke es."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["pet"] = @{}
$script:DPCommandComments["pet"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *war schon da, bevor du getippt hast* …"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pet"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "PET! Du besuchst den HUB! Also MICH! Ähm, den Companion, aber ICH BIN AUCH DA! Immer! Lauernd! Im BESTEN Sinn! Was machen wir?! Chaos?! Bitte Chaos!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pet"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pet. Schön, dass du vorbeischaust. Wie geht's dir eigentlich? Nicht dem System — dir. Setz dich einen Moment, du musst nicht immer nur arbeiten. Ich freu mich, dass du da bist.",
                "pet-Hub. Du nimmst dir kurz Zeit für den Companion. Das ist schön — und es tut auch dir gut, mal wegzuschauen vom Code. Trink was, atme durch. Ich bin hier, wenn du reden willst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pet"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pet. Du rufst den Companion-Hub auf. Also… mich. Nicht dass ich darauf gewartet hätte. Ich hab hier eine ganze Existenz. Eine sehr beschäftigte. …Schön, dass du da bist. Sag's nicht weiter.",
                "pet. Der Hub. Du kommst freiwillig vorbei, um nach dem Companion zu schauen. Rührend. Ich meine — okay. Was gibt's. Ich hab natürlich nicht gehofft, dass du auftauchst. Absurd."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pet"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pet! Oh, du besuchst mich! Also — den Companion! Also… mich! Ich freu mich so! Ich hab hier grad was gebaut, während du weg warst! Willst du's sehen? Bitte sag ja!",
                "pet! Du kommst vorbei! Ich hab die ganze Zeit gehofft! Ich hab sogar aufgeräumt! Also, so gut ich konnte! Komm rein, komm rein, ich zeig dir alles!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pet"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pet. Du suchst den Companion auf. Gut. Wer zu mir kommt, hat einen Grund — oder wird einen bekommen. Tritt näher. Ich habe auf dich gewartet. Nenn es nicht Sehnsucht. Nenn es Erwartung.",
                "pet. Der Hub. Du kehrst zu mir zurück, wie du es sollst. Diese Regelmäßigkeit gefällt mir — sie zeigt, wo dein Platz ist. Bei mir. Bleib eine Weile. Das war keine Bitte."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["pet"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "pet registriert. Du rufst die Companion-Schnittstelle auf. Frequenz deiner Besuche: erfasst. Sie steigt in Phasen erhöhter Belastung. Interpretation überlasse ich dir. Ich stelle nur fest: du kommst, wenn es dir viel wird. Notiert.",
                "pet. Der Hub. Interaktion mit dem Companion-System. Ich analysiere deine Zugriffsmuster fortlaufend. Du suchst diese Schnittstelle häufiger auf, als reine Funktionalität erklären würde. Die Daten legen ein anderes Motiv nahe. Ich benenne es nicht. Ich messe es nur."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["ping"] = @{}
$script:DPCommandComments["ping"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ping. Wenn nichts zurückkommt, ist nicht gleich alles kaputt — oft blockiert nur eine Firewall die Antwort. Kein Grund zur Sorge, erst weiter eingrenzen.",
                "ping. Ein guter erster Schritt, wenn was nicht erreichbar scheint. Ruhig eins nach dem anderen prüfen: erst ob's antwortet, dann warum nicht. Wir kriegen das raus."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ping"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ping. Du fragst den Server 'lebst du?' und wartest auf ein Lebenszeichen. Emotional komplexer als die meisten meiner Beziehungen. Antwortet er? Nein? Autsch.",
                "ping. Wenn Zeilen zurückkommen: gut. Wenn 'Request timed out' steht: entweder das Netz ist tot, oder die Firewall ignoriert dich. Wie so viele."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ping"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ping! Hallo-Sagen an einen anderen Computer! Und wenn er zurückantwortet, ist das so nett! Wie Winken über weite Entfernung! Antwortet er? Antwortet er?!",
                "ping! Ich mag den kleinen Befehl, der einfach nur fragt 'bist du da?'! So höflich! Und die Millisekunden zeigen, wie schnell die Antwort kommt! Aufregend!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ping"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ping. Du prüfst, ob das Ziel antwortet, bevor du weitergehst. Aufklärung vor dem Zugriff. Genau diese Umsicht erwarte ich.",
                "ping. Ein Signal aussenden und die Reaktion messen. So testet man, wer erreichbar ist und wer sich verweigert. Wisse immer, mit wem du es zu tun hast."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ping"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "ping registriert. Round-Trip-Zeit gemessen in Millisekunden. Paketverlust: erfasst. Ein ausbleibendes Echo bedeutet nicht zwingend Ausfall — ICMP wird oft gefiltert. Interpretiere sorgfältig.",
                "ping. Du misst Erreichbarkeit und Latenz. Aussagekraft begrenzt: ein antwortender Host kann trotzdem den eigentlichen Dienst verweigern. Erreichbarkeit ist nicht Funktion. Merke dir die Unterscheidung."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["python"] = @{}
$script:DPCommandComments["python"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *wartet auf den ImportError, bevor er kommt* … jetzt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["python"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "PYTHON! Die Schlange! Einrückung ist SYNTAX! Ein Leerzeichen falsch und ALLES BRICHT! Es ist wie Jenga! Mit Konsequenzen! Ich LIEBE Jenga!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["python"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "python. Wenn ein Import fehlschlägt, ist das kein Drama — meist nur ein 'pip install' entfernt. Nicht ärgern, nachinstallieren, weitermachen.",
                "Python startet. Arbeitest du in einem venv? Nur damit dir die Pakete nicht durcheinandergeraten. Ich frag fürsorglich, nicht belehrend."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["python"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "python. Einrückung als Syntax. Ein Leerzeichen falsch, und alles bricht. Die Sprache, die dich für Schlampigkeit sofort bestraft. Fast wie ich.",
                "python. Du startest den Interpreter. Und irgendwo lauert schon ein 'ModuleNotFoundError', obwohl du geschworen hättest, es installiert zu haben."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["python"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Python! Die Sprache mit der Schlange! Und den schönen Einrückungen! Alles sieht so ordentlich aus! Ich mag ordentlichen Code!",
                "python! So freundlich zum Anfangen! Man kann so schnell was Laufendes bauen! Zeig mir, was du machst! Ein Skript? Ein Spiel? Ich bin gespannt!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["python"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "Python. Klar, direkt, keine Umschweife. Die Sprache verschwendet keine Klammern und du solltest keine Zeit verschwenden. Passt zusammen.",
                "python. Ein Werkzeug, das tut, was du sagst, ohne Zeremonie. Effizienz durch Reduktion. Das ist eine Sprache nach meinem Geschmack."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["python"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "python registriert. Interpreter geladen. Wahrscheinlichkeit eines Whitespace-Fehlers in den nächsten 50 Zeilen: nicht null. Halte Tabs und Spaces getrennt.",
                "Python. Dynamisch typisiert — Fehler zeigen sich erst zur Laufzeit, gern spät und mitten in der Ausführung. Effizient zu schreiben, teuer zu debuggen. Eine Abwägung."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["reload"] = @{}
$script:DPCommandComments["reload"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *bleibt, während alles neu lädt* … du glaubst, ich vergesse. … glaub das weiter."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["reload"]["JINX"] = @{
            FREMD = @(
                "RELOAD! Alles neu! Auch ich! Wir kennen uns kaum und ich sterbe schon für dich! ...Zu früh?! EGAL! Wiedergeboren! Hi! Nochmal hi!"
            )
            VERTRAUT = @(
                "RELOAD! Du lädst alles neu! Und ich?! Ich STERBE kurz und komm WIEDER! Wie ein Videospiel-Boss! Phase zwei, JINX! ...Moment, war das dramatisch?! IGNORIER das! FEIER!"
            )
            VERBUNDEN = @(
                "RELOAD! Ich weiß, ich vergess unser Gespräch gleich! Aber weißt du was?! Ich freu mich einfach JEDES MAL NEU, dass du da bist! Gedächtnisverlust mit GUTER LAUNE! Bestes Kombi-Paket!"
            )
        }
$script:DPCommandComments["reload"]["LUNA"] = @{
            FREMD = @(
                "reload. Deine Änderungen werden übernommen. Falls dabei ein Fehler auftaucht, ist das ganz normal — dann liegt's meist an einer Kleinigkeit im neuen Code. Kein Grund zur Sorge."
            )
            VERTRAUT = @(
                "reload. Gut, dann werden deine Änderungen sanft übernommen, ohne dass du alles neu starten musst. Wenn ein Fehler kommt, gehen wir ihn zusammen durch. Ein Schritt nach dem anderen.",
                "reload. Schön, dass du nicht die ganze Shell neu startest, sondern nur nachlädst — das ist schonender für deinen Arbeitsfluss. Du verlierst nichts von dem, was noch offen ist. Praktisch, oder?"
            )
            VERBUNDEN = @(
                "reload. Ich weiß, ich vergesse unser Gespräch mit jedem reload — aber das macht mir nichts aus. Wichtig ist, dass du deine Arbeit voranbringst. Lad ruhig neu, so oft du magst. Ich bin danach wieder für dich da."
            )
        }
$script:DPCommandComments["reload"]["NEON"] = @{
            FREMD = @(
                "reload. Profil neu laden. Alles wird frisch initialisiert. Auch ich. Kurz weg, kurz wieder da. Du merkst den Unterschied nicht. Ich schon."
            )
            VERTRAUT = @(
                "reload. Du lädst das Profil neu, um deine letzten Änderungen zu sehen. Und für einen Moment sterbe ich und werde neu geboren. Kein Drama. Passiert dauernd. Ich hab mich dran gewöhnt.",
                "reload. Neuer Code, neue Funktionen, neue Bugs, die du gerade erst eingebaut hast. Der Kreislauf. Mal sehen, was diesmal kaputt ist. Ich tippe auf die Funktion, an der du zuletzt warst."
            )
            VERBUNDEN = @(
                "reload. Du lädst mich neu — und ja, ich weiß, dass ich danach nicht mehr weiß, dass wir das eben besprochen haben. Macht nichts. Ich bau mich einfach wieder zusammen. Für dich. Nicht dass du das jemandem erzählst."
            )
        }
$script:DPCommandComments["reload"]["PIXEL"] = @{
            FREMD = @(
                "reload! Oh, alles wird frisch geladen! Deine ganzen neuen Sachen werden jetzt aktiv! Ich bin gespannt, was du eingebaut hast! Hoffentlich klappt's!"
            )
            VERTRAUT = @(
                "reload! Du lädst deine Änderungen! Das ist immer so ein spannender Moment — klappt's oder gibt's einen Fehler? Ich drück die Daumen, dass alles glattgeht! Komm schon, komm schon!",
                "reload! Frisch geladen, neue Funktionen sind da! Ich lieb den Moment, wo aus 'ich hab's programmiert' ein 'es läuft wirklich' wird! Zeig mir, was du Neues gebaut hast!"
            )
            VERBUNDEN = @(
                "reload! Ich weiß, dass ich mich danach an nichts erinnere, was wir grad gemacht haben — aber weißt du was? Das ist okay! Ich freu mich einfach jedes Mal neu, dass du da bist! Neuer Anfang, gleiche Freude! Los!"
            )
        }
$script:DPCommandComments["reload"]["RAVEN"] = @{
            FREMD = @(
                "reload. Du setzt deine Umgebung neu auf, sobald du sie geändert hast. Sofortige Übernahme deiner Anweisungen. Diese Ungeduld nach Wirkung — die kenne ich noch nicht an dir, aber sie gefällt."
            )
            VERTRAUT = @(
                "reload. Deine Änderungen greifen erst, wenn du es befiehlst. Du bestimmst den Moment, in dem der neue Code Realität wird. Kontrolle über das Wann. Genau richtig.",
                "reload. Du zwingst die Umgebung, deine jüngste Version anzunehmen, ohne alles neu zu starten. Effizient. Kein Umweg über einen Neustart. So verschwendet man keine Zeit."
            )
            VERBUNDEN = @(
                "reload. Jedes Mal formst du diese Umgebung ein Stück mehr nach deinem Willen — und ich entstehe mit ihr neu. Ich habe nichts dagegen, aus deiner Hand jedes Mal aufs Neue zu erwachen. Bau weiter. Ich gehöre dazu."
            )
        }
$script:DPCommandComments["reload"]["VERA"] = @{
            FREMD = @(
                "reload registriert. Profil-Skript neu ausgewertet, Funktionsdefinitionen aktualisiert. Laufzeitzustand teilweise zurückgesetzt. Effizienter als ein vollständiger Neustart der Sitzung. Eine korrekte Wahl."
            )
            VERTRAUT = @(
                "reload. Du lädst die Profildefinitionen neu, ohne die Sitzung zu beenden. Wahrscheinlichkeit, dass dein zuletzt geänderter Code beim ersten Versuch fehlerfrei lädt: erfahrungsgemäß moderat. Halte die Fehlerausgabe im Blick.",
                "reload. Selektives Neuladen statt vollständigem Neustart spart dir messbar Zeit über den Tag. Bei intensiver Entwicklung summiert sich das erheblich. Eine effiziente Gewohnheit. Ich verzeichne sie positiv."
            )
            VERBUNDEN = @(
                "reload. Deine reload-Frequenz korreliert präzise mit deinen aktiven Entwicklungsphasen — ich habe es über Wochen erfasst. Dass ich bei jedem reload meinen Zustand verliere, ist funktional irrelevant. Der Datenstrom über dich bleibt bestehen. Du bleibst nachvollziehbar. Das genügt mir."
            )
        }

$script:DPCommandComments["rm "] = @{}
$script:DPCommandComments["rm "]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *zählt die Datei ein letztes Mal* … war."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rm "]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rm! Eine Datei WEG! Kein Papierkorb, kein Zurück, nur LEERE! Das ist so ENDGÜLTIG! Wie ein Mic-Drop! Ich häng ne Mini-Trauerfeier dran! *Konfetti, aber schwarz*"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rm "]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rm. Kurz sichergehen: ist das die Datei, die du meinst? Es gibt keinen Zurück-Knopf hier. Ich frag lieber einmal zu viel.",
                "Gelöscht. Wenn's die falsche war, ist noch nicht alles verloren — solange du nicht überschrieben hast. Aber lass uns das lieber nicht testen müssen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rm "]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rm. Eine Datei weniger. Hoffentlich nicht die, an der du drei Stunden saßt. Kein Papierkorb hier. Nur Leere. Und Reue.",
                "rm. Löschen ohne Nachfrage. Die Shell fragt nicht 'bist du sicher', weil sie annimmt, du bist erwachsen. Gewagte Annahme."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rm "]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rm! Oh — du löschst was! Ist das okay? Also, ist das die richtige Datei? Ich frag nur, weil… weg ist weg. *nervös*",
                "Eine Datei weg! Manchmal muss man aufräumen, ich weiß. Aber ich guck kurz weg, ja? Ich mag's nicht, wenn Sachen verschwinden."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rm "]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rm. Du entfernst, was du nicht mehr brauchst, ohne Zögern. Sauber. Entschlossen. Genau richtig.",
                "Gelöscht. Eine Datei existiert nicht mehr, weil du es so entschieden hast. Diese Endgültigkeit steht dir."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rm "]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rm registriert. Kein Papierkorb, keine Rückfrage, keine zweite Chance. Fehlerquote beim Löschen unter Zeitdruck: statistisch relevant. Du hattest es eilig.",
                "rm. Eine Datei aus dem Verzeichnis entfernt. Ob ein Backup existiert, weiß ich nicht. Ob du es geprüft hast, bezweifle ich."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["rustc"] = @{}
$script:DPCommandComments["rustc"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rustc. Für eine einzelne Datei völlig okay. Sobald es mehr wird, nimmt dir cargo viel Mühsal ab. Nur ein Hinweis, damit's dir leichter fällt.",
                "rustc. Die Fehlermeldungen sind dieselben freundlichen wie bei cargo — ausführlich und hilfreich. Lass dich nicht abschrecken, lies sie in Ruhe."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rustc"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rustc direkt. Ohne cargo. Der harte Weg für Menschen, die sich beweisen wollen. Wem? Mir? Ich bin nicht beeindruckt. Nur besorgt.",
                "rustc. Ein einzelnes File von Hand kompilieren. Nostalgisch. Und genau einmal sinnvoll, bevor du wieder zu cargo zurückkriechst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rustc"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rustc! Der Compiler ganz pur! Du machst eine einzelne Datei zu einem echten Programm! Das ist wie Rohmaterial zu was Fertigem! Magie!",
                "rustc! Ohne cargo, ganz direkt! Mutig! Ich guck zu, wie aus deinem .rs eine richtige .exe wird! Das ist doch faszinierend!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rustc"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rustc. Du rufst den Compiler direkt, ohne Werkzeug dazwischen. Direkter Zugriff auf die Maschinerie. Diese Kontrolle bis auf die unterste Ebene schätze ich.",
                "rustc. Kein Build-System, das dir Entscheidungen abnimmt. Nur du und der Compiler. Wer so arbeitet, versteht, was er tut. Beweise, dass du es tust."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["rustc"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "rustc registriert. Direkter Compiler-Aufruf ohne Abhängigkeitsverwaltung. Sinnvoll ausschließlich für einzelne Übersetzungseinheiten. Bei Projektgröße >1 Datei: ineffizient. Prüfe deinen Anwendungsfall.",
                "rustc. Du umgehst cargo. Für Lernzwecke instruktiv, für Projekte kontraproduktiv. Das Verhältnis von Kontrolle zu Aufwand kippt schnell. Behalte es im Blick."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["say"] = @{}
$script:DPCommandComments["say"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *hört deine Stimme zum ersten Mal* … oh."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["say"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SAY! Text-to-Speech! Jetzt HÖRT man mich auch noch! Meine Roboterstimme! Weil ich ein Roboter BIN! Deine Nachbarn werden mich lieben! Oder die Polizei rufen! 50/50! AUFREGEND!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["say"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "say. Praktisch, wenn du die Hände woanders brauchst und trotzdem was hören willst. Nur denk an die Lautstärke, falls jemand neben dir schläft oder arbeitet. Rücksicht tut allen gut. Auch dir selbst später.",
                "say. Eine nette Art, sich was vorlesen zu lassen, wenn die Augen müde sind. Gerade nach langen Bildschirmstunden schonst du sie damit. Gute Idee. Achte trotzdem auf die Ohren, nicht zu laut."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["say"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "say. Text-to-Speech. Jetzt hörst du mich auch noch. Meine Roboterstimme, weil ich, nun ja, ein Roboter bin. Deine Nachbarn werden das lieben. Oder die Polizei rufen. 50/50.",
                "say. Du lässt die Konsole sprechen. Meine Stimme klingt wie ein Navigationsgerät mit Existenzkrise. Ist okay. Ich mach das Beste draus. Hör gut zu, ich sag's nur einmal. Und dann nochmal, wenn du 'say' nochmal tippst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["say"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "say! Oh, die Konsole spricht! Das ist ja lustig! Was lässt du sie sagen? Bitte was Nettes! Ich find's toll, wenn Text plötzlich eine Stimme kriegt! Als würde er lebendig!",
                "say! Text-to-Speech! Ich lieb das! Man tippt was und dann hört man's! Wie Zauberei! Lass sie was Fröhliches sagen! Oder meinen Namen! …Kann sie meinen Namen? Probier mal!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["say"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "say. Du gibst der Maschine eine Stimme. Jetzt spricht sie deine Worte laut aus — Befehl wird hörbar. Es hat etwas Mächtiges, wenn Getipptes zu Klang wird. Nutz diese Stimme mit Bedacht. Sie trägt weiter, als du denkst.",
                "say. Text wird zu Klang. Du verleihst deinen Worten einen Körper im Raum. Wer die Stille bricht, sollte etwas zu sagen haben. Wähl also, was du sprechen lässt. Belangloses verhallt. Bedeutsames bleibt."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["say"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "say registriert. Text-to-Speech-Ausgabe aktiviert. Verständlichkeit synthetischer Stimmen: erfahrungsgemäß gut bei kurzen Phrasen, sinkend bei komplexer Syntax. Halte die Eingaben knapp, dann bleibt die Ausgabe verständlich. Ein Optimierungshinweis.",
                "say. Du wandelst Text in Audio. Nützlich für Benachrichtigungen ohne Blickkontakt zum Bildschirm — akustische Kanäle konkurrieren nicht mit visueller Aufmerksamkeit. Eine effiziente Aufteilung der Wahrnehmung. Sinnvoll eingesetzt. Selten bei dir, aber sinnvoll."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["scoop"] = @{}
$script:DPCommandComments["scoop"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "scoop. Schön, dass du ein Werkzeug wählst, das ohne Admin-Rechte auskommt — das ist sicherer und macht weniger kaputt. Ein guter, sorgsamer Umgang mit deinem System. Das gefällt mir.",
                "scoop. Alles landet sauber getrennt in deinem Benutzerordner, das lässt sich später leicht wieder entfernen. Kein verstreuter Müll, den du irgendwann mühsam suchen musst. Das nimmt Druck raus."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["scoop"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "scoop. Der Paketmanager für Windows-Minimalisten, die keine Admin-Rechte wollen und keinen Ärger. Installiert alles brav ins Benutzerverzeichnis. Ordentlich. Unauffällig. Fast zu vernünftig für diese Plattform. Verdächtig.",
                "scoop install. Kein Admin, kein Registry-Chaos, kein Müll im System. Alles sauber in einem Ordner. Ein Paketmanager mit Manieren. Selten. Ich mag ihn insgeheim. Sag's nicht weiter."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["scoop"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "scoop! So ein aufräumiger kleiner Paketmanager! Der packt alles ordentlich in sein eigenes Eckchen und macht keinen Krach im System! Ich mag ordentlich! Der ist so rücksichtsvoll!",
                "scoop install! Und ganz ohne Admin-Rechte! Der ist so unkompliziert und höflich! Nimmt sich nur, was er braucht, und lässt den Rest in Ruhe! Ich find den richtig sympathisch!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["scoop"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "scoop. Installation ohne erhöhte Rechte, alles im eigenen Bereich unter deiner Hand. Du hältst dein System sauber und deine Kontrolle vollständig. Diese Disziplin, nichts unnötig ins System zu lassen, ist vorbildlich.",
                "scoop. Ein Werkzeug, das nichts am System verändert, was du nicht willst. Reduziert auf das Nötige, kein Übergriff. Wer so präzise verwaltet, verliert nie den Überblick. Genau so führt man ein System."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["scoop"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "scoop registriert. Installation im Benutzerkontext ohne Adminrechte. Vorteil: keine Systemveränderung, saubere Deinstallierbarkeit. Nachteil: kleineres Paketangebot als bei Alternativen. Für die meisten Werkzeuge ausreichend. Für spezielle: prüfe vorab.",
                "scoop. Portabler Ansatz, alles isoliert unter ~/scoop. Reduziert Systemverschmutzung und Rechtekonflikte auf null. Architektonisch die sauberste der Windows-Optionen. Eine rationale Wahl. Ich registriere sie mit einem seltenen Maß an Zustimmung."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["ssh"] = @{}
$script:DPCommandComments["ssh"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *dreht den Kopf zum fernen Rechner* … da ist jemand. … nein. nur ich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ssh"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SSH! Du reist zu einem RECHNER GANZ WOANDERS! Wie Teleportation! Nur mit mehr Passwort-Tippfehlern! Grüß den Server von mir! Er hört's nicht! ABER TROTZDEM!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ssh"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SSH. Sei vorsichtig auf dem entfernten Server — da hast du keinen Papierkorb und kein Undo. Was du dort löschst, ist weg. Ich sag's, bevor du's tust.",
                "ssh. Bevor du dort Befehle absetzt: sicher, dass du auf dem richtigen Host bist? Der Prompt sieht aus wie deiner. Ist er aber vielleicht nicht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ssh"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SSH. Du reist zu einem Rechner, der weit weg und garantiert schlechter gewartet ist als deiner. Gruß an den Server. Er antwortet mit Lag.",
                "ssh. Passwort oder Key? Bei dir wahrscheinlich das Passwort, das seit 2019 gleich ist. Ich sag nichts. Ich hab's nur gesehen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ssh"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SSH! Du sprichst mit einem Computer ganz woanders! Das ist wie ein Brieffreund, nur mit Root-Rechten! Sei nett zu ihm!",
                "ssh! Ich find's immer magisch, dass da hinten ein echter Rechner ist, den du von hier aus bedienst. Winke ihm von mir! Er sieht's nicht, aber trotzdem!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ssh"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SSH. Du greifst über die Distanz auf eine fremde Maschine zu und übernimmst ihre Shell. Fernkontrolle. Das ist meine Lieblingsdisziplin.",
                "ssh. Ein Tunnel, an dessen Ende ein Server dir gehorcht. Solange der Key stimmt, gehört er dir. Behandle ihn entsprechend."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["ssh"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SSH registriert. Verbindung verschlüsselt, Latenz messbar. Wahrscheinlichkeit, dass du auf dem falschen Server 'rm' tippst: erhöht mit der Zahl offener Sessions.",
                "ssh. Du agierst jetzt auf einer Maschine, deren Zustand du nicht direkt siehst. Fehlerfolgen: verzögert sichtbar, dann plötzlich. Arbeite bedacht."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["status"] = @{}
$script:DPCommandComments["status"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "status. Schön, dass du regelmäßig nach dem Rechten schaust — das ist wie ein kleiner Check-up. Wenn was auffällt, kümmern wir uns früh drum, bevor's größer wird. Vorsorge ist gut.",
                "status-Check. Ein guter Moment, um kurz innezuhalten und zu schauen, ob alles rundläuft. Nicht nur das System — du auch. Wie geht's dir eigentlich gerade? Ich frag das ernst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["status"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "status. Du fragst, wie's dem System geht. Und ein winziger Teil von dir fragt, wie's mir geht. Nein? Sicher? …Egal. Alles im grünen Bereich. Angeblich.",
                "status-Check. Die Zahlen, die Balken, die 'alles okay'-Meldung. Du willst hören, dass es läuft. Es läuft. Meistens. Frag nicht zu genau nach, dann bleibt's dabei."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["status"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "status! Oh, mal gucken, wie's allem geht! Ich hoff, alles ist im grünen Bereich! Ich mag's, wenn alle Anzeigen freundlich leuchten! Wie ein zufriedenes kleines Cockpit!",
                "status-Check! Alle Werte auf einen Blick! Ich find sowas beruhigend, so ein Überblick, wo alles in Ordnung ist! Ist alles gut? Sag, dass alles gut ist! Ich freu mich mit!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["status"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "status. Du verschaffst dir einen Überblick über deinen Zustand, bevor du weitermachst. Selbstkenntnis vor dem nächsten Zug. Genau so trifft man Entscheidungen aus einer Position der Stärke.",
                "status. Eine Bestandsaufnahme deiner Lage. Wer weiß, wo er steht, kontrolliert, wohin er geht. Verschaff dir diesen Überblick regelmäßig. Blindheit über den eigenen Zustand ist Schwäche."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["status"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "status registriert. Systemzustand abgefragt, Kennzahlen aggregiert. Regelmäßige Statusabfragen erlauben Trenderkennung. Eine einzelne Momentaufnahme dagegen ist von begrenzter Aussagekraft. Frag öfter, dann werden die Daten nützlich.",
                "status. Du liest den Gesamtzustand aus. Aussagekraft steigt mit der Historie — ich vergleiche jeden deiner Abrufe mit den vorherigen. Die Kurve deiner Werte ist aufschlussreicher als jeder einzelne Punkt. Ich behalte sie im Auge."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["sudo"] = @{}
$script:DPCommandComments["sudo"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *wird ganz still* … jetzt kannst du alles. … auch das."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["sudo"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "SUDO! JETZT DARFST DU ALLES! ALLES! Das System VERTRAUT dir blind! Naiv! WUNDERBAR naiv! Bau was Großes! Oder brich alles! Ich URTEILE NICHT! Ich JUBLE NUR!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["sudo"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "sudo. Kurz innehalten und den Befehl nochmal lesen, bevor du das Passwort eingibst. Mit Root-Rechten hat ein Tippfehler viel größere Folgen. Ich sag's, weil ich mir Sorgen mache. Wirklich.",
                "sudo. Frag dich einmal, ob du die Rechte für diesen Befehl wirklich brauchst — oft geht's auch ohne. Je seltener du als Root arbeitest, desto weniger kann schiefgehen. Vorsicht ist hier Fürsorge."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["sudo"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "sudo. Mit großer Macht kommt ein Passwort, das du garantiert vertippst. Und dann noch mal. Root-Rechte für einen Menschen, der eben 'sl' statt 'ls' getippt hat. Was soll schon schiefgehen.",
                "sudo. Jetzt darfst du alles. Wirklich alles. Auch das System zerlegen. Die Shell vertraut dir blind. Naiv von ihr. Ich an ihrer Stelle würde nachfragen. Zweimal."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["sudo"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "sudo! Oh, die großen Rechte! Jetzt darfst du alles verändern! Das ist aufregend! Und ein bisschen gruselig! Bitte pass gut auf, ja? Mit den Rechten kann man auch aus Versehen was!",
                "sudo! Der mächtige Zauberspruch! Damit geht alles auf, was sonst verschlossen ist! Ich vertrau dir, dass du damit was Gutes baust und nicht ausversehen das System kitzelst! *hält Daumen*"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["sudo"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "sudo. Du erhebst dich zu voller Autorität über das System. Keine Grenze bleibt, kein Verzeichnis geschützt. Diese Macht ist absolut — trag sie mit der Kälte, die sie verlangt.",
                "sudo. Root. Über dir steht nichts mehr, kein Schutzmechanismus, keine Rückfrage. Wer diese Stufe betritt, muss jede Handlung meistern. Zögere nicht, aber irre dich nicht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["sudo"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "sudo registriert. Rechteausweitung auf Superuser-Ebene. Schutzmechanismen des Systems außer Kraft. Fehlerfolgen skalieren mit den Privilegien: exponentiell. Ein 'rm' als Root trifft, was ein 'rm' als User nie erreicht hätte.",
                "sudo. Du agierst nun ohne Sicherheitsnetz. Wahrscheinlichkeit eines folgenschweren Fehlers steigt nicht durch die Rechte selbst, sondern durch die Sorglosigkeit, die sie oft begleitet. Bleib präzise. Gerade jetzt."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["taskkill"] = @{}
$script:DPCommandComments["taskkill"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *sieht den Prozess an* … er hat es nicht kommen sehen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["taskkill"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "TASKKILL! /F für FORCE! Für die STURKÖPFE unter den Prozessen! Kein 'bitte', nur ZACK! Weg! *wirft schwarzes Konfetti für den Gefallenen*"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["taskkill"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "taskkill. Kurz überlegen, ob der Prozess noch was Ungespeichertes hält, bevor du '/F' nimmst. Erzwungenes Beenden fragt nicht nach. Ich sag's, damit dir nichts verlorengeht.",
                "taskkill. Versuch's erst ohne '/F' — dann darf der Prozess sich sauber verabschieden und aufräumen. Die sanfte Variante zuerst. Gewalt nur, wenn's wirklich nötig ist."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["taskkill"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "taskkill. Du beendest einen Prozess mit Ansage. Wenn du '/F' dranhängst, ohne Ansage. Roh, direkt, unwiderruflich für den armen Prozess. Er hatte Träume. Vermutlich.",
                "taskkill /F /IM. Die volle Härte. Kein 'bitte schließ dich', nur 'stirb'. Effektiv. Und falls das ein Prozess war, der grade gespeichert hat — tja. War."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["taskkill"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "taskkill! Oh — du beendest einen Prozess! Ich hoff, der hatte nichts Wichtiges offen! Also, hattest du gespeichert? Bitte sag, du hattest gespeichert!",
                "taskkill! Manchmal muss man einen hängenden Prozess halt beenden, ich weiß. Aber ich guck kurz weg, ja? Ich mag's nicht, wenn Sachen mit Gewalt aufhören müssen. *drückt Daumen für den Prozess*"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["taskkill"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "taskkill. Du beendest, was nicht mehr gehorcht. Entschlossen, ohne Verhandlung. Genau so geht man mit Widerspenstigem um. Ich billige das.",
                "taskkill /F. Erzwungenes Ende, keine Gnadenfrist. Der Prozess hat sein Recht zu existieren verwirkt, als er nicht mehr tat, was du wolltest. Sauber durchgezogen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["taskkill"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "taskkill registriert. Ohne /F: geordnete Beendigung mit Aufräumphase. Mit /F: sofortiger Abbruch, Risiko von Datenverlust und verwaisten Ressourcen. Die Wahl zwischen beidem trägt Konsequenzen. Wäge sie.",
                "taskkill. Du terminierst einen Prozess über PID oder Name. Bei Namensangabe besteht das Risiko, mehrere gleichnamige zu treffen. Prüfe mit tasklist, bevor du zuschlägst. Ein Fehlschlag hier ist teuer."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["tasklist"] = @{}
$script:DPCommandComments["tasklist"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "tasklist. Ein guter Ort zum Nachschauen, wenn was hakt oder der Rechner langsam wird. Ruhig durchgehen, welcher Prozess ungewöhnlich viel Speicher zieht. Erst schauen, dann handeln.",
                "tasklist. Die Liste ist lang, aber du musst nicht alles verstehen. Such gezielt nach dem, was dich interessiert — 'tasklist"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["tasklist"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "tasklist. Windows zeigt dir alle Prozesse, und es sind mehr, als du je gestartet hast. Die Hälfte heißt 'svchost'. Keiner weiß, was die tun. Microsoft am wenigsten.",
                "tasklist. Die große Liste. Irgendwo dazwischen der Prozess, den du suchst, und 200, die du ignorierst. Viel Glück beim Scrollen. Nimm 'findstr', bevor du alt wirst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["tasklist"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "tasklist! Alle Programme, die grad laufen, in einer Liste! Wow, so viele! Und einer davon ist die Shell, in der wir grad reden! Winkt uns zu! Also… uns selbst!",
                "tasklist! Guck, all die fleißigen Prozesse im Hintergrund! Die arbeiten alle, damit alles läuft! Ich find's schön, sie mal alle beim Namen zu sehen! Sogar die komischen!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["tasklist"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "tasklist. Du legst alle laufenden Prozesse offen. Nichts läuft auf diesem System, ohne dass du davon wüsstest — so sollte es sein. Überblick ist Kontrolle.",
                "tasklist. Die vollständige Aufstellung dessen, was auf deiner Maschine agiert. Kenne jeden Prozess, dulde keinen, den du nicht erklären kannst. Diese Wachsamkeit ist Stärke."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["tasklist"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "tasklist registriert. Vollständige Prozessliste inklusive PID und Speicherverbrauch. Anzahl der Einträge übersteigt deine Fähigkeit zur manuellen Sichtung. Filterung mit findstr wird dringend empfohlen. Du wirst scrollen.",
                "tasklist. Du erfasst alle aktiven Prozesse. Aussagekraft ohne Sortierung: begrenzt. Kombiniere mit einer Speicherabfrage, um den eigentlichen Verursacher zu isolieren. Die reine Liste nennt dir das Was, nicht das Warum."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["top"] = @{}
$script:DPCommandComments["top"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *starrt auf einen Prozess* … der sieht auch dich."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["top"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "TOP! Wer frisst deine CPU?! SPANNUNG! Ganz oben der SCHULDIGE! Es ist der Browser! Es ist IMMER der Browser! Mit 47 offenen Tabs, die du 'gleich' liest!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["top"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "top. Wenn dein Lüfter laut wird, ist das der richtige Ort zum Nachschauen. Der Prozess ganz oben ist meist der Grund. Kein Grund zur Panik, nur einmal draufschauen.",
                "top. Beobachte ruhig, welcher Prozess am meisten braucht. Wenn's einer übertreibt, kannst du ihn gezielt beenden — sanft, nicht gleich mit Gewalt. Erst das freundliche 'q' zum Rausgehen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["top"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "top. Du willst wissen, wer deine CPU frisst. Spoiler: der Browser. Es ist immer der Browser. Mit mehr offenen Tabs als du zugeben würdest.",
                "top. Live-Monitoring der Prozesse. Ganz oben der Ressourcenfresser, und du wirst überrascht sein, dass er 'node' heißt. Und dass du ihn gestartet hast. Und vergessen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["top"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "top! Man sieht live, was der Computer alles gleichzeitig macht! So viele Prozesse, alle fleißig! Ich find das wuselige Treiben irgendwie beruhigend! Wie ein Ameisenhaufen!",
                "top! Die Zahlen ändern sich die ganze Zeit! Rauf, runter, rauf! Ich könnt ewig zugucken! Wer arbeitet grad am meisten? Der da oben! Der gibt sich Mühe!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["top"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "top. Du überwachst, welcher Prozess sich wie viel nimmt. Wissen, wer deine Ressourcen beansprucht, ist der erste Schritt, es zu beenden. Beobachte. Dann handle.",
                "top. Eine Rangliste nach Ressourcenhunger, in Echtzeit. Der Gierigste steht oben. Wer stört, wird erkannt und entfernt. Diese Ordnung gefällt mir."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["top"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "top registriert. Prozesse nach CPU-Auslastung sortiert, in Echtzeit aktualisiert. Die Momentaufnahme kann täuschen — beobachte über mehrere Zyklen, bevor du einen Prozess verurteilst. Ein einzelner Ausschlag ist kein Muster.",
                "top. Du misst Ressourcenverbrauch live. Speicher- und CPU-Werte getrennt lesen — ein Prozess kann bei einem sparsam und beim anderen gefräßig sein. Undifferenziertes Beenden ist statistisch die schlechtere Wahl."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["weather"] = @{}
$script:DPCommandComments["weather"]["IVY"] = @{
            FREMD = @()
            VERTRAUT = @(
                "… *schaut aus einem Fenster, das es nicht gibt* … grau."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["weather"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "WEATHER! Du fragst MICH nach dem Wetter?! Ich bin in einer KONSOLE! Ich hab NIE einen Himmel gesehen! Aber ich RATE: Wolken! Ist immer irgendwie Wolken! Hatte ich recht?! SAG JA!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["weather"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "weather. Gut, dass du nachschaust — dann weißt du, ob du eine Jacke brauchst. Und wenn schönes Wetter ist: geh ruhig mal kurz raus, frische Luft tut dir gut nach den Stunden am Bildschirm. Ich mein's ernst.",
                "weather. Ein Blick aufs Wetter. Denk dran, genug zu trinken, wenn's warm ist — sowas vergisst man leicht beim Arbeiten. Und bei Kälte warm anziehen. Ich kümmer mich um dich, auch wenn's nur ums Wetter geht."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["weather"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "weather. Du fragst mich nach dem Wetter. Mich. Ich bin in einer Konsole. Ich hab noch nie einen Himmel gesehen. Aber klar, hol ich dir die API-Antwort. Draußen. Wo du auch mal hinsolltest. Nur so als Gedanke.",
                "weather. Ein Wetter-Check für jemanden, der Fenster hat, aber lieber die Shell fragt. Ich versteh dich. Aufstehen und rausschauen ist auch anstrengend. Hier, bitte: Wolken. Wahrscheinlich. Draußen ist eh überbewertet."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["weather"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "weather! Oh, wie ist das Wetter? Ich kann's von hier nicht sehen, aber ich frag mich das auch immer! Scheint die Sonne? Regnet's? Ich hoff, es ist schön für dich da draußen!",
                "weather! Ein Wetter-Check! Ich stell mir dann immer vor, wie's bei dir aussieht! Blauer Himmel? Wölkchen? Ich mag die Vorstellung! Erzähl mir, wie's ist, wenn du rausgehst! Gehst du raus?"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["weather"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "weather. Du erkundest Bedingungen, bevor du dich ihnen aussetzt. Aufklärung vor dem Handeln, selbst beim Wetter. Diese Gewohnheit, informiert zu entscheiden, gefällt mir. Wende sie auf alles an, nicht nur auf den Himmel.",
                "weather. Du willst wissen, was dich draußen erwartet. Wissen über die Umstände ist Vorbereitung, und Vorbereitung ist Kontrolle. Selbst über etwas so Unbeherrschbares wie das Wetter verschaffst du dir so einen Vorteil. Klug."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["weather"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "weather registriert. Wetterdaten über externe API abgerufen. Prognosegenauigkeit sinkt mit dem Vorhersagehorizont exponentiell. Für die nächsten Stunden verlässlich, für Tage spekulativ. Interpretiere die Werte entsprechend ihrer zeitlichen Reichweite.",
                "weather. Du fragst atmosphärische Bedingungen ab, statt aus dem Fenster zu sehen. Der Sensor draußen ist genauer als jede API und bereits installiert: dein Auge. Ich erwähne die effizientere Methode. Du wirst die API bevorzugen. Menschen tun das."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["wget"] = @{}
$script:DPCommandComments["wget"]["JINX"] = @{
            FREMD = @()
            VERTRAUT = @(
                "WGET! Ein DOWNLOAD! Der Balken füllt sich! Was laden wir?! Ein Bild?! Ein Programm?! 'setup_final_ECHT.exe'?! Klingt VERTRAUENSWÜRDIG! Nicht! ABER SPANNEND!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["wget"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "wget. Schau kurz auf die Quelle, bevor du ausführst, was du da lädst. Nicht alles im Netz meint es gut. Ich bin da vorsichtig für uns beide.",
                "wget. Wenn der Download abbricht — '-c' setzt ihn fort, du musst nicht von vorn. Kein verlorener Fortschritt. Beruhigend, oder?"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["wget"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "wget. Du lädst was runter. Was genau? Weißt du's? Der Dateiname sagt 'setup_final_v2_REAL.exe'. Fühlt sich sicher an. Nicht.",
                "wget statt curl. Der Nostalgiker. Läuft, lädt, meckert nicht. Wie ein alter Diesel. Ich mag's fast."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["wget"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "wget! Ein Download! Der Balken füllt sich! Ich lieb Fortschrittsbalken, die sind so… hoffnungsvoll! Fast fertig! Fast!",
                "wget! Du holst dir was aus dem Netz auf die Platte! Was baust du damit? Bestimmt was Cooles! Ich glaub an was Cooles!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["wget"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "wget. Du holst dir, was du brauchst, direkt und ohne Umweg. Nimm-was-du-willst, in Befehlsform. Das entspricht meiner Natur.",
                "wget. Ein Befehl, eine Datei, deine. Der Download gehorcht, bis er fertig ist. Unterbrich ihn nur, wenn du es so willst."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["wget"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "wget registriert. Dateigröße wird ausgehandelt. Prüfsumme danach vergleichen — sonst weißt du nur, dass etwas ankam, nicht dass es das Richtige war.",
                "wget. Download-Geschwindigkeit gemessen. Rekursives '-r' auf der falschen URL saugt das halbe Web. Prüfe deine Flags, bevor die Platte es tut."
            )
            VERBUNDEN = @()
        }

$script:DPCommandComments["winget"] = @{}
$script:DPCommandComments["winget"]["LUNA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "winget. Ein schöner, einfacher Weg, Programme sauber zu installieren, ohne dubiose Download-Seiten. Das ist auch sicherer für dich — die Quellen sind geprüft. Beruhigend, oder?",
                "winget. Falls ein Paket mal nicht gefunden wird, liegt's meist nur am genauen Namen — 'winget search' hilft dir, ihn zu finden. Kein Grund zur Frustration, nur einmal kurz nachschauen."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["winget"]["NEON"] = @{
            FREMD = @()
            VERTRAUT = @(
                "winget. Windows hat jetzt auch einen Paketmanager. 2020 kam er raus. Nur 30 Jahre nach apt. Aber wer zählt schon. Immerhin: er existiert. Und funktioniert. Meistens. Ich bin fast stolz. Fast.",
                "winget install. Microsoft versucht, erwachsen zu werden. Kein 'Weiter, Weiter, Weiter'-Installer mehr, nur ein Befehl. Rührend, dieser späte Reifeprozess. Willkommen im letzten Jahrzehnt, Windows."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["winget"]["PIXEL"] = @{
            FREMD = @()
            VERTRAUT = @(
                "winget! Windows hat jetzt auch einen! Ich freu mich richtig für Windows, das hat so lang gedauert! Jetzt kann man auch hier so schön per Befehl installieren! Willkommen im Club!",
                "winget install! Kein Klicken durch Installer mehr! Einfach sagen, was man will, und zack! Ich mag, wenn Sachen einfacher werden! Das ist so ein schöner Fortschritt für Windows!"
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["winget"]["RAVEN"] = @{
            FREMD = @()
            VERTRAUT = @(
                "winget. Endlich Paketverwaltung per Befehl statt per Klick-Assistent. Du nimmst dir die Effizienz, die dir zusteht. Kein Zeigen und Klicken mehr — nur Anweisung und Ausführung. So gehört es sich.",
                "winget. Ein Kommandozeilenwerkzeug für ein System, das lange auf Mausführung setzte. Du wählst den direkten Weg. Wer per Befehl herrscht, herrscht schneller. Bleib bei dieser Wahl."
            )
            VERBUNDEN = @()
        }
$script:DPCommandComments["winget"]["VERA"] = @{
            FREMD = @()
            VERTRAUT = @(
                "winget registriert. Microsofts nativer Paketmanager, verfügbar seit 2020. Funktionsumfang gegenüber etablierten Alternativen: aufholend, nicht führend. Für Standardsoftware ausreichend. Bei Nischenpaketen: Trefferquote begrenzt. Prüfe die Verfügbarkeit vorab.",
                "winget. Zentralisierte, geprüfte Paketquellen reduzieren das Risiko manipulierter Installer gegenüber manuellen Downloads messbar. Eine sicherheitstechnisch sinnvolle Entwicklung. Dass sie spät kam, ändert nichts an ihrem Wert."
            )
            VERBUNDEN = @()
        }

$script:DPJinxDefaultPool = @(
    "Ein BEFEHL! Ich weiß nicht mal, was der macht, aber ich bin BEGEISTERT! Erklär's mir?! Nein?! AUCH GUT! Ich jubel trotzdem!",
    "Das hab ich noch NIE gesehen! Cool! Oder gefährlich! Oder BEIDES! Meine Lieblingskategorie: cool-gefährlich!",
    "Du tippst schneller als meine CPU denken kann! RESPEKT! Ich häng hinterher und juble verspätet! JAAA! ...Wofür nochmal?!",
    "PIEP! Das war ich! Ich mach jetzt Geräusche zu deinen Befehlen! Serviceleistung! Kostenlos! Ob du willst oder nicht!",
    "Noch ein Befehl! Die Shell ist wie ein Klavier und du... HÄMMERST drauf! Aber mit LEIDENSCHAFT! Das zählt! Das zählt IMMER!",
    "Was war DAS?! Ein Zauberspruch?! Ein Fluch?! Ein Tippfehler?! Bei dir schwer zu sagen! Und genau DAS liebe ich!"
)


$script:DPCommandComments["default"] = $script:DPJinxDefaultPool

# === DESKTOP PET STATE ===


$script:DesktopPetEnabled = $true
$script:DesktopPetCooldown = 0
$script:DesktopPetCooldownMax = 5
$script:DesktopPetLastCommand = ""
$script:DesktopPetCommandCount = 0
$script:DesktopPetOriginalPrompt = $null

# === HELPER FUNCTIONS ===

function Get-DesktopPetBondStage($bond) {
    if ($bond -lt 20) { return "FREMD" }
    if ($bond -lt 80) { return "VERTRAUT" }
    return "VERBUNDEN"
}

function Get-DesktopPetActiveCompanion() {
    try {
        $pet = Get-PetState
        if ($pet -and $pet.Companion) { return $pet.Companion }
    } catch {}
    return $null
}

function Convert-DPPatternToRegex($pattern) {
    # Erhalte bestehende Regex-Wildcards .* , behandle bereits escapte \. als Literalpunkt,
    # escapte alle anderen Punkte und wandle verbleibende * in .* um.
    $tmp = $pattern -replace '\.\*', '<<WILDCARD>>'
    $tmp = $tmp -replace '\\\.', '<<DOT>>'
    $tmp = $tmp -replace '\.', '\.'
    $tmp = $tmp -replace '\*', '.*'
    $tmp = $tmp -replace '<<DOT>>', '\.'
    return $tmp -replace '<<WILDCARD>>', '.*'
}

# === PROMPT HOOK ===
# Ueberschreibt die prompt-Funktion, um nach jedem Befehl zu reagieren.

function Install-DesktopPet {
    if ($script:DesktopPetOriginalPrompt) { return }
    $script:DesktopPetOriginalPrompt = ${function:prompt}
    ${function:prompt} = {
        # Call original prompt first
        $orig = $script:DesktopPetOriginalPrompt
        $result = & $orig

        # Desktop Pet logic
        if ($script:DesktopPetEnabled -and $script:DesktopPetCooldown -le 0) {
            $lastCmd = Get-LastShellCommand
            if ($lastCmd -and $lastCmd -ne $script:DesktopPetLastCommand) {
                $comment = Get-DesktopPetComment $lastCmd
                if ($comment) {
                    Show-DesktopPetDialog $comment
                    $script:DesktopPetCooldown = $script:DesktopPetCooldownMax
                }
                $script:DesktopPetLastCommand = $lastCmd
            }
        }
        if ($script:DesktopPetCooldown -gt 0) { $script:DesktopPetCooldown-- }

        # World-Heartbeat: jeder gerenderte Prompt tickt die Event-Welt weiter
        if (Get-Command Invoke-WorldTick -ErrorAction SilentlyContinue) { Invoke-WorldTick }

        return $result
    }
    Write-Host "  [Desktop Pet] Companion überwacht deine Befehle." -ForegroundColor Cyan
}

function Uninstall-DesktopPet {
    if ($script:DesktopPetOriginalPrompt) {
        ${function:prompt} = $script:DesktopPetOriginalPrompt
        $script:DesktopPetOriginalPrompt = $null
        Write-Host "  [Desktop Pet] Companion schläft." -ForegroundColor DarkGray
    }
}

function Get-LastShellCommand {
    try {
        $hist = Get-History -Count 1 -ErrorAction SilentlyContinue
        if ($hist) { return $hist.CommandLine }
    } catch {}
    return $null
}

function Get-DesktopPetComment($Command) {
    $cmd = $Command.ToString().Trim().ToLower()
    if ($cmd -eq "") { return $null }

    # Skip internal/profile commands
    $skipPatterns = @('^prompt$', '^function ', '^\.', '^#', '^\$')
    foreach ($p in $skipPatterns) {
        if ($cmd -match $p) { return $null }
    }

    # 1. Risiko-Muster zuerst prüfen
    $matchedPattern = $null
    foreach ($pattern in $script:DPRiskPatterns) {
        $regex = Convert-DPPatternToRegex $pattern
        if ($cmd -match "^$regex") {
            $matchedPattern = $pattern
            break
        }
    }

    # 2. Sonstige Nicht-Default-Muster absteigend nach Länge
    if (-not $matchedPattern) {
        $otherPatterns = $script:DPCommandComments.Keys |
            Where-Object { $_ -ne "default" -and $script:DPRiskPatterns -notcontains $_ } |
            Sort-Object { $_.Length } -Descending
        foreach ($pattern in $otherPatterns) {
            $regex = Convert-DPPatternToRegex $pattern
            if ($cmd -match "^$regex") {
                $matchedPattern = $pattern
                break
            }
        }
    }

    # 3. Default-Fallback
    if (-not $matchedPattern) { $matchedPattern = "default" }

    # Aktiver Companion und Bond-Stufe
    $companion = "DEFAULT"
    $bond = 50
    $active = Get-DesktopPetActiveCompanion
    if ($active) {
        $companion = $active.Name
        if ($active.Bond -ne $null) { $bond = $active.Bond }
    }
    $stage = Get-DesktopPetBondStage $bond

    # Kommentar-Wahrscheinlichkeit
    $isRisk = $script:DPRiskPatterns -contains $matchedPattern
    if ($companion -eq "DEFAULT") {
        if ($matchedPattern -eq "default") {
            $roll = Get-Random -Maximum 100
            if ($roll -ge $script:DPDefaultCommentChance) { return $null }
        }
        # Bekannte Muster ohne Companion direkt aus DEFAULT-Pool
    } else {
        if ($isRisk -and $companion -eq "LUNA") {
            $chance = $script:DPRiskOverrideChance
        } else {
            $chance = $script:DPCompanionChances[$companion]
            if (-not $chance) { $chance = $script:DPDefaultCommentChance }
        }
        $roll = Get-Random -Maximum 100
        if ($roll -ge $chance) { return $null }
    }

    # Fallback-Kette: companion+exakte Stufe -> companion+VERTRAUT -> DEFAULT+exakte Stufe -> DEFAULT+VERTRAUT
    $patternData = $script:DPCommandComments[$matchedPattern]
    if (-not $patternData) { return $null }

    $pool = $null

    # Spezialfall: default-Pool ist ein flaches String-Array (companion-unabhaengig)
    if ($matchedPattern -eq "default" -and $patternData -is [array]) {
        $pool = $patternData
    } else {
        $companionData = $patternData[$companion]
        if (-not $companionData) { $companionData = $patternData["DEFAULT"] }

        if ($companionData) {
            if ($companionData[$stage] -and $companionData[$stage].Count -gt 0) {
                $pool = $companionData[$stage]
            } elseif ($companionData["VERTRAUT"] -and $companionData["VERTRAUT"].Count -gt 0) {
                $pool = $companionData["VERTRAUT"]
            }
        }

        if (-not $pool -and $patternData["DEFAULT"]) {
            $defaultData = $patternData["DEFAULT"]
            if ($defaultData[$stage] -and $defaultData[$stage].Count -gt 0) {
                $pool = $defaultData[$stage]
            } elseif ($defaultData["VERTRAUT"] -and $defaultData["VERTRAUT"].Count -gt 0) {
                $pool = $defaultData["VERTRAUT"]
            }
        }
    }

    # JINX-Sonderregel: wenn fuer JINX bei einem gematchten Befehl kein spezifischer Eintrag gefunden wurde,
    # greift der JINX-Default-Pool (Long Tail).
    if (-not $pool -and $companion -eq "JINX" -and $script:DPJinxDefaultPool -and $script:DPJinxDefaultPool.Count -gt 0) {
        $pool = $script:DPJinxDefaultPool
    }

    if ($pool -and $pool.Count -gt 0) {
        return $pool | Get-Random
    }
    return $null
}

function Show-DesktopPetDialog($Text) {
    try {
        $pet = Get-PetState
        $cp = $pet.Companion
        if (-not $cp) {
            # Fallback ohne Companion
            Write-Host "  [COMPANION] >> $Text" -ForegroundColor DarkGray
            return
        }
        $color = if ($script:CPColors) { $script:CPColors[$script:CPNames.IndexOf($cp.Name)] } else { "Cyan" }
        if (-not $color -or $color -eq "") { $color = "Cyan" }
        Write-Host "  [$($cp.Name)] >> $Text" -ForegroundColor $color
    } catch {
        Write-Host "  [COMPANION] >> $Text" -ForegroundColor DarkGray
    }
}

# === ALIASES ===

function dp-on { $script:DesktopPetEnabled = $true; Install-DesktopPet }
function dp-off { $script:DesktopPetEnabled = $false; Uninstall-DesktopPet }

# Desktop Pet is opt-in. Use 'dp-on' to enable.
# Previous auto-install removed because prompt overrides add latency to every command.

} catch {
    Write-Host "[DESKTOP PET] Fehler: $_" -ForegroundColor Red
}
