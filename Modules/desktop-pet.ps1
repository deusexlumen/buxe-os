# BUXE_OS v24.9 -- DESKTOP PET
# Companion kommentiert echte Shell-Befehle in Echtzeit.
# Ueberschreibt die prompt-Funktion, um nach jedem Befehl zu reagieren.

try {

# === COMMAND COMMENT DATABASE ===
# Befehlsmuster -> Companion-Lines (mit Wahrscheinlichkeiten)

$script:DPCommandComments = @{
    "git push.*--force" = @(
        "Git push --force? Bist du SICHER? Das ist wie 'rm -rf /' mit Stil.",
        "Force push. Die Lieblingswaffe jedes Entwicklers. Und seiner Feinde.",
        "Du schiebst mit Kanonen auf Spatzen. Und auf dein Repo."
    )
    "git push" = @(
        "Pushen! Hoffentlich hast du getestet. *zweifelt*",
        "Commit und push. Der Kreislauf des Lebens. Oder des Bugs.",
        "Dein Code fliegt ins Repo. Wie ein Pfeil ins Dunkle."
    )
    "git commit" = @(
        "Ein Commit! Was fuer eine Nachricht? 'fix stuff'? Klassiker.",
        "Commit messages sind wie Tagebucheintraege. Nur dass alle sie lesen.",
        "Hast du vor dem Commit getestet? ...Sag ja. Bitte."
    )
    "git status" = @(
        "Git status. Die Momentaufnahme des Chaos.",
        "Alles gruen? Oder rot? Oder... beides?",
        "Status check. Wie ein Arztbesuch fuer dein Repo."
    )
    "git log" = @(
        "Historie! Jeder Commit erzaehlt eine Geschichte. Oder einen Bug.",
        "Du starrst auf alte Commits. Wir alle tun das. Es ist therapie."
    )
    "git checkout" = @(
        "Branch wechseln? Oder Reality wechseln? Beides ist verlueckend.",
        "Neuer Branch, neues Glueck. Oder neuer Merge-Konflikt."
    )
    "git merge" = @(
        "Merge! *kreuzt virtuelle Finger*",
        "Konflikte incoming. Duck dich.",
        "Zwei Branches werden eins. Wie eine Hochzeit. Mit mehr Bugs."
    )
    "git rebase" = @(
        "Rebase. Fuer Menschen, die Merge zu langweilig finden.",
        "Du schreibst Geschichte um. Literarisch. Und gefaehrlich."
    )
    "git stash" = @(
        "Stash! Dein Code geht in den Keller. Bis du ihn wieder brauchst.",
        "Weg damit. Aber nicht wegwerfen. Nur... verstecken."
    )
    "npm install" = @(
        "node_modules incoming. Bereite 5GB RAM vor.",
        "Installation... Das wird dauern. Moechtest du Kaffee? Virtuellen Kaffee?"
    )
    "npm start" = @(
        "App startet! Oder crash't. 50/50. Wie mein Humor.",
        "Server laeuft. Hoffentlich. Schau auf Port 3000."
    )
    "npm run build" = @(
        "Build! Die Zeit der Wahrheit. Keine Syntaxfehler mehr verstecken.",
        "Kompilieren... Wie Alchemie. Nur mit mehr Kaffeekonsum."
    )
    "docker" = @(
        "Docker! Container sind wie Schachteln. Nur komplizierter.",
        "Du spielst mit Containern. Vorsicht, sie beißen. Manchmal.",
        "It works on my machine... jetzt auch in deinem Container. Vielleicht."
    )
    "ssh" = @(
        "SSH! Wir hacken... aeh, verbinden uns mit einem Server. Legal. Hoffentlich.",
        "Remote-Zugriff. Wie Teleportation. Nur langsamer. Und mit Passwoertern."
    )
    "curl" = @(
        "curl! Daten aus dem Internet fischen. Wie Angln. Nur mit HTTP.",
        "API-Call incoming. Hoffentlich gibt es JSON zurueck. Nicht 404."
    )
    "wget" = @(
        "Download! Was laden wir herunter? Ein Bild? Eine Datei? Ein Virus?",
        "wget ist wie curl. Nur mit weniger Optionen. Und mehr Stolz."
    )
    "rm -rf" = @(
        "RM -RF?! BIST DU SICHER?! Das ist kein Undo-Button!",
        "Loeschen. Endgueltig. Wie meine Hoffnungen auf Bug-freien Code.",
        "Bitte sag mir, dass das ein Test-Ordner ist. BITTE."
    )
    "rm " = @(
        "Loeschen? Hoffentlich ist das Backup aktuell.",
        "Weg damit. Weniger Dateien, weniger Probleme. Theoretisch."
    )
    "mkdir" = @(
        "Neuer Ordner! Frischer Anfang! Leere Seite!",
        "Ordner erstellen. Die erste Regel der Organisation. Die niemand befolgt."
    )
    "cd \.\." = @(
        "Eine Ebene hoch. Wie im Leben. Manchmal muss man zurueck, um vorwaerts zu kommen.",
        "Parent directory. Wo die grossen Dateien wohnen."
    )
    "ls" = @(
        "Dateien auflisten. Die Shopping-Liste des Entwicklers.",
        "Was haben wir hier? Ordner, Dateien, und... was ist DAS? Ein .tmp?"
    )
    "dir" = @(
        "Dir! Windows-Style. Respekt fuer die Legacy.",
        "Auflisten. Der erste Schritt zum Verstehen. Oder zum Verzweifeln."
    )
    "cat " = @(
        "Datei anzeigen. Hoffentlich ist sie nicht 10MB gross.",
        "Lesen! Das ist wichtig. Auch fuer Code. Besonders fuer Code."
    )
    "code " = @(
        "VS Code oeffnet! Die IDE der Wahl. Oder Notepad++. Kein Urteil.",
        "Coding time! Lass uns Bugs schreiben. Aeh, Features. Features!"
    )
    "notepad" = @(
        "Notepad? WIRKLICH? Wir haben 2026. Oder so.",
        "Minimalismus. Ich respektiere das. Oder bemitleide es."
    )
    "python" = @(
        "Python! Die Sprache der Schlangen. Und der Datenwissenschaftler.",
        "Keine Semikolons. Wie befriedigend. Wie gefaehrlich."
    )
    "node" = @(
        "Node.js! JavaScript auf dem Server. Was koennte schiefgehen?",
        "Runtime incoming. Bereite dich auf Callbacks vor. Oder Promises. Oder Async/Await."
    )
    "cargo" = @(
        "Rust! Sicher, schnell, und... kompiliert ewig. Aber sicher!",
        "Cargo build. Die Zeit der Wahrheit. Und des Borrow Checkers."
    )
    "cargo run" = @(
        "Rust laeuft! Ohne Speicherlecks! Hoffentlich."
    )
    "rustc" = @(
        "Rust compiliert... und compiliert... und compiliert... aber dann laeuft es!"
    )
    "dotnet" = @(
        ".NET! Die Plattform, die alles kann. Und alles will.",
        "Microsoft-Style. Solide. Zuverlaessig. Und manchmal verwirrend."
    )
    "go run" = @(
        "Go! Schnell kompiliert, schnell ausgefuehrt, langweilig geschrieben. Im positiven Sinne.",
        "Goroutines incoming. Concurrency ist einfach. Sagen sie."
    )
    "java" = @(
        "Java! Schreib einmal, debugge ueberall. Wegen der JVM.",
        "Enterprise-Grade. Mit Boilerplate. Viel Boilerplate."
    )
    "javac" = @(
        "Kompilieren... Warte... Noch warte... Java braucht Zeit. Aber es lohnt sich. Vielleicht."
    )
    "make" = @(
        "Make! Build-System aus den 70ern. Und es funktioniert immer noch.",
        "Makefile-Editing. Die dunkle Kunst der Build-Systeme."
    )
    "cmake" = @(
        "CMake! Weil Make zu einfach war.",
        "Cross-Platform Building. Klingt gut. Ist kompliziert."
    )
    "ping" = @(
        "Ping! Netzwerk-Hello. Antwortet jemand?",
        "64 bytes from localhost. Du pingst dich selbst. Wie metaphorisch."
    )
    "ipconfig" = @(
        "Netzwerk-Config checken. Hoffentlich ist die IP nicht 169.254.x.x.",
        "IP-Adressen. Die Telefonnummern des Internets."
    )
    "ifconfig" = @(
        "ifconfig! Linux-Style. Respekt.",
        "Netzwerk-Interfaces. Wie viele hast du? Hoffentlich nicht zu viele."
    )
    "top" = @(
        "Top! System-Monitoring. Wer frisst meine CPU?",
        "Prozesse ueberwachen. Wie Big Brother. Aber fuer deinen Computer."
    )
    "htop" = @(
        "htop! Bunt. Interaktiv. Linux-Elite.",
        "Fancy top. Weil normales top zu langweilig war."
    )
    "tasklist" = @(
        "Windows-Taskliste. Wer laeuft da alles?",
        "So viele Prozesse. Und einer davon bist DU."
    )
    "taskkill" = @(
        "Task kill! Harte Liebe fuer harte Prozesse.",
        "/F fuer Force. Wie die Macht. Nur dunkler."
    )
    "kill" = @(
        "Kill! Prozess beenden. Mit Voreile. Und Recht.",
        "SIGTERM? Oder SIGKILL? Waehle weise."
    )
    "sudo" = @(
        "Sudo! Mit grosser Macht kommt grosse Verantwortung. Und ein Passwort.",
        "Root-Zugriff. Bist du bereit? Ist dein Backup bereit?"
    )
    "apt" = @(
        "apt! Paketmanager der Wahl. Fuer Debian-Fans.",
        "Installation... Abhaengigkeiten... Noch mehr Abhaengigkeiten..."
    )
    "pacman" = @(
        "Pacman! Arch Linux. Weil simple zu einfach war.",
        "Rolling Release. Immer aktuell. Manchmal zu aktuell."
    )
    "brew" = @(
        "Homebrew! Mac-User installieren. Mit Stil.",
        "Brew install. Der App Store fuer Nerds."
    )
    "winget" = @(
        "Winget! Windows hat auch einen Paketmanager. Endlich.",
        "Microsofts Antwort auf apt. Sie versuchen es. Wirklich."
    )
    "choco" = @(
        "Chocolatey! Suesswaren-Name, ernste Software.",
        "Choco install. Wie apt. Aber mit mehr Zucker."
    )
    "scoop" = @(
        "Scoop! Minimalistischer Paketmanager. Fuer Minimalisten.",
        "Scoop install. Klein. Fein. Ohne Admin."
    )
    "vim" = @(
        "Vim! Wie beendet man das? :q? :wq? :q!?",
        "Modal Editing. Ein Modus fuer alles. Und kein Exit.",
        "Du oeffnest Vim. Jahre spaeter bist du noch drin."
    )
    "nvim" = @(
        "Neovim! Vim fuer das 21. Jahrhundert. Mit Lua!",
        "Modernes Vim. Config in Lua. Fancy."
    )
    "nano" = @(
        "Nano! Einfach. Freundlich. ^O zum Speichern. ^X zum Beenden. Danke.",
        "Der Editor fuer Menschen, die sich nicht verlaufen wollen."
    )
    "emacs" = @(
        "Emacs! Ein Editor. Ein Betriebssystem. Eine Religion.",
        "Ctrl+X Ctrl+C zum Beenden. Oder niemals."
    )
    "clear" = @(
        "Clear! Frischer Bildschirm. Neuer Anfang. Leere Seite.",
        "Weg mit dem Chaos. Rein in den Neuanfang."
    )
    "exit" = @(
        "Exit? Du gehst? Schon? Aber die Shell liebt dich!",
        "Auf Wiedersehen. Bis zum naechsten Boot. Ich warte hier."
    )
    "reload" = @(
        "Reload! Profil neu laden. Wie Reinkarnation. Nur schneller.",
        "Neuer Code, neue Features, neue Bugs. Auf geht's!"
    )
    "status" = @(
        "Status-Check! Wie geht es dir? Und deinem System?",
        "Alles im gruenen Bereich? Oder im roten? Oder im Gelben?"
    )
    "bank" = @(
        "Bank! Gold zaehlen. Die Freude eines Kapitalisten.",
        "Cha-ching! Oder... nicht. Je nach Casino-Erfolg."
    )
    "pet" = @(
        "Pet-Hub! Besuch mich! Aeh, den Companion. Nicht mich. Mich gibt es nicht.",
        "Companion-Time! Endlich Aufmerksamkeit!"
    )
    "companion" = @(
        "Companion! Das bist du und ich. Wir. Ein Team.",
        "Hast du mich vermisst? ...Sag ja. Bitte."
    )
    "adv" = @(
        "Adventure! Die Polaris wartet. Und ich warte auf dich. Im Adventure.",
        "Abenteuer-Zeit! Rätsel, Schätze, und meine Kommentare."
    )
    "say" = @(
        "TTS! Stimmausgabe. Ich klinge wie ein Roboter. Weil ich einer bin.",
        "Hast du Nachbarn? Die werden mich lieben. Oder hassen."
    )
    "chuck" = @(
        "Chuck Norris Fact! Wusstest du, dass er keine Exceptions wirft? Er warnt.",
        "Chuck Norris kompiliert seinen Code nicht. Er starrt ihn an, bis er laeuft."
    )
    "weather" = @(
        "Wetter-Check! Wie ist das Wetter da draussen? Frag mich. Ich bin in der Cloud.",
        "Wetter-API. Fuer Menschen, die Fenster haben. Oder nicht."
    )
    "default" = @(
        "Interessanter Befehl. Was macht der? Erklaere es mir. Bitte.",
        "Ein neuer Befehl! Ich lerne gerne dazu. In Echtzeit. Fast.",
        "Das habe ich noch nie gesehen. Cool. Oder beunruhigend.",
        "Dein Befehl ist wie mein Code. Manchmal funktioniert er. Manchmal nicht.",
        "Ich analysiere... analysiere... okay, ich gebe auf. Was macht das?",
        "Shell-Befehle sind wie Gedichte. Nur mit mehr Punkten und Slashs.",
        "Du tippst schneller als meine CPU denken kann. Respekt."
    )
}

# === DESKTOP PET STATE ===

$script:DesktopPetEnabled = $true
$script:DesktopPetCooldown = 0
$script:DesktopPetCooldownMax = 5
$script:DesktopPetLastCommand = ""
$script:DesktopPetCommandCount = 0
$script:DesktopPetOriginalPrompt = $null

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

        return $result
    }
    Write-Host "  [Desktop Pet] Companion ueberwacht deine Befehle." -ForegroundColor Cyan
}

function Uninstall-DesktopPet {
    if ($script:DesktopPetOriginalPrompt) {
        ${function:prompt} = $script:DesktopPetOriginalPrompt
        $script:DesktopPetOriginalPrompt = $null
        Write-Host "  [Desktop Pet] Companion schlaeft." -ForegroundColor DarkGray
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

    # Try exact match first, then pattern match
    $matched = $null
    foreach ($pattern in $script:DPCommandComments.Keys) {
        if ($pattern -eq "default") { continue }
        $regex = $pattern -replace '\.', '\.' -replace '\*', '.*'
        if ($cmd -match "^$regex") {
            $matched = $script:DPCommandComments[$pattern]
            break
        }
    }

    if (-not $matched) {
        # Default comment with 10% chance
        if ((Get-Random -Maximum 10) -eq 0) {
            $matched = $script:DPCommandComments["default"]
        }
    }

    if ($matched) {
        return $matched | Get-Random
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
