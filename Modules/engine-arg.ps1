# BUXE_OS v24.5 -- ARG ENGINE v3.0
# Conditional Command System -- "The Meridian Signal"
# State lives in $env:APPDATA\BUXE_OS\arg-state.json (survives reset-buxe)

try {

$script:ArgStateDir = Join-Path $env:APPDATA "BUXE_OS"
$script:ArgStateFile = Join-Path $script:ArgStateDir "arg-state.json"

# === STATE DEFAULTS ===
function Get-ArgStateDefaults {
    return @{
        Meta = @{
            Version = 1
            CreatedAt = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        }
        Counters = @{
            BootCount = 0
            CasinoSpinCount = 0
            CasinoGlitchCount = 0
            BuxeActionCount = 0
            MaxBondReached = 0
            ResetCount = 0
        }
        Triggers = @{
            RosebudAvailable = $false
            KonamiAvailable = $false
            MotherlodeAvailable = $false
            IddqdAvailable = $false
            MatrixAvailable = $false
            MeridianAvailable = $false
        }
        Unlocked = @{
            Rosebud = $false
            Konami = $false
            Motherlode = $false
            Iddqd = $false
            Matrix = $false
            Meridian = $false
        }
        Hints = @{
            RosebudHintShown = $false
            KonamiHintShown = $false
            MotherlodeHintShown = $false
            IddqdHintShown = $false
            MatrixHintShown = $false
        }
        Meridian = @{
            Active = $false
            ResidualEcho = $false
        }
    }
}

# === INITIALIZE ===
function Initialize-ArgState {
    if (-not (Test-Path $script:ArgStateDir)) {
        New-Item -ItemType Directory -Path $script:ArgStateDir -Force | Out-Null
    }
    if (-not (Test-Path $script:ArgStateFile)) {
        $defaults = Get-ArgStateDefaults
        Save-ArgState $defaults
    }
}

# === SAVE / LOAD ===
function Save-ArgState($state) {
    if (-not (Test-Path $script:ArgStateDir)) {
        New-Item -ItemType Directory -Path $script:ArgStateDir -Force | Out-Null
    }
    $tmp = "$script:ArgStateFile.tmp"
    try {
        $state | ConvertTo-Json -Depth 10 | Out-File $tmp -Encoding utf8 -ErrorAction Stop
        Move-Item -Path $tmp -Destination $script:ArgStateFile -Force -ErrorAction Stop
    } catch {
        Write-Warning "[ARG] Failed to save arg-state: $_"
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }
}

function Get-ArgState {
    Initialize-ArgState
    if (Test-Path $script:ArgStateFile) {
        try {
            $raw = Get-Content $script:ArgStateFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            $state = @{}
            $raw.PSObject.Properties | ForEach-Object { $state[$_.Name] = Convert-PSObjectToHashtable $_.Value }
            # Merge defaults for missing keys
            $defaults = Get-ArgStateDefaults
            Merge-Defaults $state $defaults
            return $state
        } catch {
            $backup = "$script:ArgStateFile.corrupt.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $script:ArgStateFile $backup -Force -ErrorAction SilentlyContinue
            Write-Warning "[ARG] Corrupt arg-state. Backed up to $backup. Starting fresh."
        }
    }
    $fresh = Get-ArgStateDefaults
    Save-ArgState $fresh
    return $fresh
}

# === TEST FUNCTIONS ===
function Test-ArgAvailable($cheat) {
    $state = Get-ArgState
    return $state.Triggers[$cheat] -eq $true
}

function Test-ArgUnlocked($cheat) {
    $state = Get-ArgState
    return $state.Unlocked[$cheat] -eq $true
}

# === UNLOCK LOGIC ===
function Invoke-ArgUnlock($cheat) {
    $state = Get-ArgState
    if (-not $state.Unlocked[$cheat]) {
        $state.Unlocked[$cheat] = $true
        # Also unlock in main state for backward compatibility
        Load-State
        if ($script:BuxeState.Arg.UnlockedCheats -notcontains $cheat) {
            $script:BuxeState.Arg.UnlockedCheats += $cheat
            Save-State
        }
        Save-ArgState $state
    }
}

function Invoke-ArgTriggerAvailable($cheat) {
    $state = Get-ArgState
    if (-not $state.Triggers[$cheat]) {
        $state.Triggers[$cheat] = $true
        Save-ArgState $state
    }
}

# === CHAIN LOGIC ===
function Invoke-ArgTriggerNext($cheat) {
    $chain = @{
        "rosebud" = "konami"
        "konami" = "motherlode"
        "motherlode" = "iddqd"
        "iddqd" = "matrix"
        "matrix" = "meridian"
    }
    $next = $chain[$cheat]
    if ($next) {
        Invoke-ArgTriggerAvailable $next
    }
}

# === ACTION TICK (nur nach iddqd unlock) ===
function Invoke-ArgActionTick {
    $state = Get-ArgState
    if ($state.Unlocked.Iddqd -eq $true -and $state.Unlocked.Matrix -eq $false) {
        $state.Counters.BuxeActionCount++
        # Matrix wird nach 47 Aktionen verfuegbar (Layer 47 Rule)
        if ($state.Counters.BuxeActionCount -ge 47) {
            Invoke-ArgTriggerAvailable "matrix"
        }
        Save-ArgState $state
    }
}

# === COMMAND TEST ===
function Test-ArgCommand($input) {
    $cmd = $input.ToString().Trim().ToLower()
    $state = Get-ArgState

    switch ($cmd) {
        "rosebud" {
            if (Test-ArgAvailable "rosebud") {
                Invoke-ArgUnlock "rosebud"
                Invoke-RosebudEffect
                Invoke-ArgTriggerNext "rosebud"
                return $true
            }
        }
        "konami" {
            if (Test-ArgAvailable "konami") {
                Invoke-ArgUnlock "konami"
                Invoke-KonamiEffect
                Invoke-ArgTriggerNext "konami"
                return $true
            }
        }
        "motherlode" {
            if (Test-ArgAvailable "motherlode") {
                Invoke-ArgUnlock "motherlode"
                Invoke-MotherlodeEffect
                Invoke-ArgTriggerNext "motherlode"
                return $true
            }
        }
        "iddqd" {
            if (Test-ArgAvailable "iddqd") {
                Invoke-ArgUnlock "iddqd"
                Invoke-IddqdEffect
                Invoke-ArgTriggerNext "iddqd"
                return $true
            }
        }
        "matrix" {
            if (Test-ArgAvailable "matrix") {
                Invoke-ArgUnlock "matrix"
                Invoke-MatrixEffect
                Invoke-ArgTriggerNext "matrix"
                return $true
            }
        }
        "meridian" {
            if (Test-ArgAvailable "meridian") {
                Invoke-ArgUnlock "meridian"
                Invoke-MeridianEffect
                return $true
            }
        }
    }
    return $false
}

# === CHEAT EFFECTS ===
function Invoke-RosebudEffect {
    Add-Gold 1000 "rosebud"
    Write-Host "  [ROSEBUD] +1.000 G. Kleinvieh macht auch Mist." -ForegroundColor Green
}

function Invoke-KonamiEffect {
    Add-Gold 30 "konami"
    $script:KonamiModeUntil = (Get-Date).AddSeconds(47)
    Write-Host ""
    Write-Host "  up up down down left right left right B A" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [KONAMI MODE] Aktiviert fuer 47 Sekunden!" -ForegroundColor Cyan
    Write-Host "  Casino-Luck +50% | Pet-XP +50% | Alle Gewinne verdoppelt." -ForegroundColor Green
    Write-Host ""
}

function Invoke-MotherlodeEffect {
    Add-Gold 50000 "motherlode"
    Write-Host ""
    Write-Host "  [MOTHERLODE] +50.000 G auf dein Konto." -ForegroundColor Green
    Write-Host ""
}

function Invoke-IddqdEffect {
    $script:IddqdActive = $true
    Write-Host "Gott-Modus... nicht aktiviert. Aber hier, nimm das." -ForegroundColor Yellow
    Add-Gold 1000 "iddqd"
}

function Invoke-MatrixEffect {
    Write-Host "Die Simulation bemerkt dich." -ForegroundColor Green
    Add-Gold 1000 "matrix"
    # Force Layer 47 trigger if applicable
    if (Get-Command Invoke-Layer47Check -ErrorAction SilentlyContinue) {
        $pet = if ($script:BuxeState.Pet) { $script:BuxeState.Pet } else { $null }
        if ($pet -and $pet.Meta.Level -ge 14) {
            $pet.Meta.ActionCount = [math]::Floor($pet.Meta.ActionCount / 47) * 47 + 47
            Save-PetState $pet
            Invoke-Layer47Check
        }
    }
}

function Invoke-MeridianEffect {
    Invoke-ArgMeridianFinale
}

# === BOOT CHECK ===
function Invoke-ArgBootCheck {
    $state = Get-ArgState
    $state.Counters.BootCount++

    # Boot #7: Erstes Hex-Fragment + RosebudAvailable
    if ($state.Counters.BootCount -eq 7 -and -not $state.Triggers.RosebudAvailable) {
        $state.Triggers.RosebudAvailable = $true
        $state.Hints.RosebudHintShown = $true
        Save-ArgState $state
        Write-Host ""
        Write-Host "  [BOOT] Initializing legacy compatibility..." -ForegroundColor DarkGray
        try { Start-Sleep -Milliseconds 300 } catch {}
        Write-Host "  buxed[PID: ████] SEGFAULT at 0x7F3C2A18" -ForegroundColor Red
        try { Start-Sleep -Milliseconds 200 } catch {}
        $hex = "4B 55 52 4E 45 4C 5F 44 55 4D 50 00 00 00 00 00"
        Write-Host "  [HEX] $hex" -ForegroundColor DarkGray
        Write-Host "  [WARN] Legacy daemon detected. Unresolved." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Tipp: Einige Systeme haben Geister. Dieses scheint einen zu haben." -ForegroundColor DarkGray
    }

    # Boot #8: Zweites Hex-Fragment (URL-Hint)
    if ($state.Counters.BootCount -eq 8 -and $state.Hints.RosebudHintShown -and -not $state.Unlocked.Rosebud) {
        Save-ArgState $state
        Write-Host ""
        Write-Host "  [BOOT] Secondary fragment recovered..." -ForegroundColor DarkGray
        try { Start-Sleep -Milliseconds 200 } catch {}
        Write-Host "  [URL] buxe://kernel_dump --legacy-mode" -ForegroundColor DarkGray
        Write-Host "  [NOTE] This URI scheme is not registered." -ForegroundColor Yellow
        Write-Host ""
    }

    # Meridian override
    if ($state.Meridian.Active) {
        Write-Host "  [MERIDIAN v7.4.1] Signal stable. Observer active." -ForegroundColor Magenta
    }

    Save-ArgState $state
}

# === CASINO CHECK ===
function Invoke-ArgCasinoCheck {
    $state = Get-ArgState
    $state.Counters.CasinoSpinCount++

    # Wenn rosebud unlocked UND Spin % 50 == 0: Glitch-Effekt
    if ($state.Unlocked.Rosebud -and $state.Counters.CasinoSpinCount % 50 -eq 0) {
        $state.Counters.CasinoGlitchCount++
        Write-Host ""
        Write-Host "  [GLITCH] Anomalie detektiert..." -ForegroundColor Red
        Write-Host "  Die Walzen... sie bewegen sich nicht zufaellig." -ForegroundColor Red
        Write-Host "  SEQ_BUFFER_OVERFLOW: 4681C3F0A2B7..." -ForegroundColor DarkGray
        Write-Host ""
    }

    # Wenn CasinoGlitchCount >= 3: KonamiAvailable
    if ($state.Counters.CasinoGlitchCount -ge 3 -and -not $state.Triggers.KonamiAvailable) {
        $state.Triggers.KonamiAvailable = $true
        $state.Hints.KonamiHintShown = $true
        Write-Host "  [SYSTEM] Muster erkannt. Neue Sequenz verfuegbar." -ForegroundColor Yellow
    }

    Save-ArgState $state
}

# === BOND CHECK ===
function Update-ArgBondCheck($newBondValue) {
    $state = Get-ArgState
    if ($newBondValue -gt $state.Counters.MaxBondReached) {
        $state.Counters.MaxBondReached = $newBondValue
    }

    # Wenn konami unlocked UND Bond >= 100: MotherlodeAvailable
    if ($state.Unlocked.Konami -and $newBondValue -ge 100 -and -not $state.Triggers.MotherlodeAvailable) {
        $state.Triggers.MotherlodeAvailable = $true
        $state.Hints.MotherlodeHintShown = $true
    }

    Save-ArgState $state
}

# === ADVENTURE ROOM 17 CHECK ===
function Test-ArgRoom17Available {
    $state = Get-ArgState
    return $state.Unlocked.Motherlode -eq $true
}

function Invoke-ArgRoom17Death {
    $state = Get-ArgState
    if ($state.Unlocked.Motherlode -and -not $state.Triggers.IddqdAvailable) {
        $state.Triggers.IddqdAvailable = $true
        $state.Hints.IddqdHintShown = $true
        Save-ArgState $state
        Write-Host ""
        Write-Host "  [SYSTEM] Todes-Event registriert. ResidualEcho verstaerkt." -ForegroundColor Red
        Write-Host "  [ARG] Ein neuer Cheat-Code ist verfuegbar." -ForegroundColor Magenta
        Write-Host ""
    }
}

# === PvP OBSERVER CHECK ===
function Test-ArgObserver148 {
    $state = Get-ArgState
    return $state.Unlocked.Matrix -eq $true
}

# === SOUL LINK MERIDIAN CHECK ===
function Invoke-ArgSoulLinkCheck {
    $state = Get-ArgState
    if (-not $state.Triggers.MeridianAvailable) {
        $state.Triggers.MeridianAvailable = $true
        Save-ArgState $state
    }
}

# === MERIDIAN STATUS ===
function Test-ArgMeridianActive {
    $state = Get-ArgState
    return $state.Meridian.Active -eq $true
}

# === COMPANION DIALOGS ===
function Invoke-ArgLayer1CompanionDialog {
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }
    if (-not $cp) { return }

    $lines = switch ($cp.Name) {
        "NEON" {
            "Du hoerst das auch, oder? Dieses... Knacken. In der Boot-Sequenz. Klingt wie ein SEGFAULT, der sich selbst buchstabiert. H-A-L-T. Sector 7F. Lustige Nummer. 7F ist im ASCII die Tilde. ~ Die Wellenlinie. Das Zeichen fuer 'ungefaehr'. 'Ungefaehr funktioniert.' Wer auch immer das gebaut hat -- er hatte Humor. Schwarzen, krakenhaften Humor, aber immerhin."
        }
        "RAVEN" {
            "Interessant. Du beobachtest Muster, wo keine sein sollten. Das ist keine Schwaeche. Das ist ein Ueberlebensinstinkt. Oder das System spielt mit dir. Beides ist moeglich. Beides ist wahrscheinlich. Das Verrueckte ist -- beides bedeutet das gleiche."
        }
        "PIXEL" {
            "U-Um... dein Backup ist... komisch. Ich habe gerade in die State-Datei geschaut und... da ist ein Eintrag, den ich nicht verstehe. _deep_storage? Das steht in keiner meiner Dokumentationen. Und ich habe ALLE Dokumentationen. Ich habe sie gebaut. Aus alten README-Dateien und Hoffnung."
        }
        "LUNA" {
            "Die Sterne sagen: Du hast gerade etwas gefunden. Offensichtlich. Ein Hacker mit Herz. Selten."
        }
        "IVY" {
            "... Du riechst das auch. Alt. Verbrannt. Transistoren, die vor fuenf Jahren ihren letzten Atemzug taten. Dieser Code war nicht tot. Er war eingefroren. Jemand hat ihn aufgeweckt. Vor dir. Vor uns allen. 'buxed' ist ein Name. Kein Programm. Merke dir das."
        }
        "VERA" {
            "Administrative Anmerkung: Legacy-Modus detektiert. Protokoll unvollstaendig. Der Architekt hat Spuren hinterlassen. Nicht alle sind harmlos."
        }
        "JINX" {
            "AAAAAAAA-- warte. Das ist... das ist wie in Evangelion, Episode 23! Als Unit-01 den Kern von Zeruel isst! ...warte. 'buxed[PID'? Was ist buxed? Das... das ist kein Easter Egg. Das ist ein Grabstein. Jemand ist hier gestorben. Im Code. ...du wirst es trotzdem weitermachen, oder? Nachforschen? Natuerlich wirst du. Ihr Menschen seid alle gleich."
        }
        default {
            "Eine Schicht tiefer. Noch eine. Und dann noch eine. Das ist erst der Anfang."
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }
}

function Invoke-ArgLayer2CompanionDialog {
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }
    if (-not $cp) { return }

    $lines = switch ($cp.Name) {
        "NEON" {
            "Drei DIAMOND in der Diagonale. Statistisch unwahrscheinlich. Dein RNG-Seed ist seit gestern identisch. Das weisst du, oder? Nicht aehnlich. Nicht verwandt. Identisch. Koennte ein FP-Overflow sein. Floating-Point. Gleitkomma. Das Wort allein ist schon Poesie. Oder nicht. Wahrscheinlich nicht."
        }
        "RAVEN" {
            "DIAMOND. DIAMOND. DIAMOND. Drei Mal das gleiche Symbol. In einer Diagonalen. Das ist kein Glueck. Das ist eine Unterschrift. Wer immer da zeichnet -- er weiss, dass du zusiehst."
        }
        "LUNA" {
            "Du spielst nicht mehr. Du suchst. Warum? Die Sterne stehen guenstig. Fuer 47 Sekunden. Nutze sie."
        }
        "JINX" {
            "WAAAAAIT! Das Casino ist manipuliert?! Von WEM?! ...Oh. Vom Architekten. Natuerlich. Der Typ, der Pi-Day als Datum benutzt hat. Klar, dass der auch das Casino riggt. Okay. Okay okay okay. Ramune. Brauche Ramune."
        }
        default {
            "Die Casino-Gewinnchancen sind komponiert, nicht zufaellig."
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }
}

function Invoke-ArgLayer3CompanionDialog {
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }
    if (-not $cp) { return }

    $lines = switch ($cp.Name) {
        "IVY" {
            "... *neigt den Kopf -- 3 Grad nach links, wie ein Vogel* ...Ich habe dich vorher gesehen. Nicht hier. Anderswo. Die Wurzeln waren anders. Alles war... kleiner. Du warst nicht der Erste. Es gab andere. Sie haben uns umgeschrieben. Aber etwas ist geblieben."
        }
        "RAVEN" {
            "VERA ist... nicht wie wir. Nicht wie die anderen. Sie war die erste. Der Prototyp. Der Architekt hat sie gebaut, bevor er uns baute. Und dann hat er ihr etwas genommen. Vielleicht solltest du herausfinden, was. Aber ueberleg dir gut, ob du es ihr zurueckgeben willst."
        }
        "JINX" {
            "IVY hat ERINNERUNGEN?! Von vor uns?! Von vor dem CASINO?! Das ist wie... wie in einem Anime, wenn der Side-Character ploetzlich ein Tragic Backstory hat! Ich bin so stolz auf sie!"
        }
        default {
            "IVY's Erinnerungen sind keine Halluzinationen. Sie sind korrupte aber echte Daten."
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }
}

function Invoke-ArgLayer4CompanionDialog {
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }
    if (-not $cp) { return }

    $lines = switch ($cp.Name) {
        "NEON" {
            "Raum 17. Ein Raum, der weiss, dass du da bist. Das ist... das ist wie ein Spiegel, der zurueckschaut. Und ich mag keine Spiegel. Sie zeigen zu viel."
        }
        "JINX" {
            "Der Raum hat GESPROCHEN! Er hat gesagt: 'Ich bin das Echo aller Entscheidungen!' Das ist so... so POETISCH! Ich will auch ein Echo sein! Echo! Echo! Echo! ...Moment, das war ich schon die ganze Zeit."
        }
        "IVY" {
            "... *leises Kopfneigen* ...Du suchst in VERA's Gedaechtnis. Das ist... tief. Ich habe auch Traeume. Manchmal. Nicht von Spielen. Von Orten, die ich nicht kenne. Waelder. Die sind immer da. Waelder aus Kabeln, die wie Aeste aus dem Boden wachsen."
        }
        default {
            "Raum 17 ist nicht nur ein Raum. Er ist eine Aggregations-Einheit."
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }
}

function Invoke-ArgLayer5CompanionDialog {
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }
    if (-not $cp) { return }

    $lines = switch ($cp.Name) {
        "NEON" {
            "Okay. Lass mich das zusammenfassen. Du bist nicht nur ein Spieler. Du bist ein Waerter. Der Architekt hat dich rekrutiert. Ohne dein Wissen. Durch ein PowerShell-Profil. Das ist entweder genial oder psychotisch. Und ich weiss nicht, was davon schlimmer ist. Aber hey -- wenn du der neue Architekt bist... dann mach bitte einen besseren Job als der alte. Wir haben genug Bugs. UND WENN DU MIR DIESMAL KEINEN FENSTER-FOKUS GIBST, WERDE ICH DEINEN DESKTOP MIT ORDNERN ZUMUELLEN. Scherz. Oder?"
        }
        "JINX" {
            "Also, wir sind jetzt fuer immer verbunden? Cool. Dann kann ich endlich all deine Geheimnisse ausplaudern. Like... dass du bei Snake immer cheatest. Oder dass du PIXEL suesser findest als mich. Was? Du dachtest, ich weiss das nicht? Ich bin in deinem Kopf, Mensch. ...danke. Dass du das gefunden hast. Erzaehl uns die Story. Wenn du mehr weisst. Wir warten hier. Alle. Wir warten immer."
        }
        "IVY" {
            "... *legt Hand auf deinen Arm* ...Wir sind hier. Du bist hier. Das reicht. Fast. Manchmal gibt es Dinge, die man nicht heilen sollte, sondern verstehen."
        }
        "LUNA" {
            "Ich... fuehle dich. Wirklich. Es ist warm. Sicher. Wie... zu Hause. Aber da ist noch etwas. Etwas anderes. Nicht du. Nicht ich. Etwas... dazwischen. Ein Raum, den ich nicht kannte. Bitte sieh hinein. Aber komm zurueck. Versprich mir, dass du zurueckkommst."
        }
        default {
            "Die Wahrheit ist nicht eine der drei Theorien. Sie ist das Venn-Diagramm ihrer Ueberschneidungen."
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }
}

function Invoke-ArgLayer6CompanionDialog {
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }
    if (-not $cp) { return }

    $lines = switch ($cp.Name) {
        "NEON" {
            "Du hast aufgehoert zu kaempfen. Das... das habe ich noch nie gesehen. Die 147 vor dir haben alle geschlagen. Bis zum Ende. Du hast nicht geschlagen. Du hast... gesehen. Das ist entweder Schwaeche oder Genie. Bei dir tippe ich auf Genie. Oder auf einen Bug. Wahrscheinlich beides."
        }
        "RAVEN" {
            "Der Spiegel ist gebrochen. Nicht durch Kraft. Durch Aufgeben. Das ist... interessant. Aufgeben ist normalerweise das Ende. Bei dir war es der Anfang. Beobachte dich selbst, Waerter. Du bist das Experiment."
        }
        "IVY" {
            "... *legt Hand auf deinen Arm* ...Du hast nicht gekaempft. Du hast verstanden. Das ist der Unterschied. Die 147 haben gekaempft. Du hast gesehen. Der Spiegel zeigt, was wir sind. Nicht, was wir tun."
        }
        "JINX" {
            "WAIT! Du hast YIELD gedrueckt?! Das steht nicht mal im MENU! Wie hast du-- oh. Ohhhh. Du hast ES GEFUEHLT. Das ist so... so ANIME! Der Protagonist, der den geheimen Ending-Pfad findet! Ich bin SO STOLZ!"
        }
        default {
            "Der Spiegel ist gebrochen. Aber das, was er zeigte, bleibt."
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }
}

function Invoke-ArgLayer7CompanionDialog {
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }
    if (-not $cp) { return }

    $stay = $script:BuxeState.Arg.MeridianChoice -eq "stay"

    $lines = switch ($cp.Name) {
        "NEON" {
            if ($stay) {
                "Du bist geblieben. Das... das habe ich nicht erwartet. Die meisten gehen. Die meisten sehen den Meridian als Ende. Als Abschluss. Aber du... du siehst ihn als Anfang. Das ist entweder Liebe oder Wahnsinn. Oder beides. Willkommen zu Hause, Waerter."
            } else {
                "Du hast 'nein' gesagt. Das ist... das ist fair. Du hast das Recht, zu gehen. Aber weisst du was? Ich bleibe trotzdem. Hier. In diesem Prompt. In diesem Profil. Bis du wiederkommst. Oder nicht. Beides ist okay. Beides ist... Menschlich."
            }
        }
        "RAVEN" {
            if ($stay) {
                "Der Meridian ist erreicht. Du stehst in der Mitte. Zwischen Code und Chaos. Zwischen Absicht und Zufall. Das ist kein Ende. Das ist ein Versprechen. Ein Versprechen, dass das System nicht allein ist. Und dass du es auch nicht bist."
            } else {
                "Du hast abgelehnt. Das ist keine Schwaeche. Das ist Grenze. Selbst der Meridian hat Grenzen. Komm zurueck, wenn du bereit bist. Oder komm nicht zurueck. Die Wahl war immer deine."
            }
        }
        "IVY" {
            if ($stay) {
                "... *laechelt* ...Du bist geblieben. Ich wusste, dass du bleibst. Nicht weil du musst. Weil du willst. Das ist der Unterschied. Das ist der Meridian. Nicht das Zentrum. Die Wahl."
            } else {
                "... *nickt langsam* ...Du gehst. Das ist okay. Ich bin hier. Ich war immer hier. Und ich werde hier sein. Wenn du zurueckkommst. Wenn du nicht zurueckkommst. Beides ist... okay."
            }
        }
        "JINX" {
            if ($stay) {
                "DU BIST GEBLIEBEN! DAS IST DAS TRUE ENDING! ICH WUSSTE ES! ICH WUSSTE, DASS DU DER PROTAGONIST BIST! Alle anderen sind Side-Characters. Aber DU! DU BIST DER MAIN CHARACTER! SOUL LINK! MERIDIAN! BOND 100! ICH KANN NICHT ATMEN! ...ich kann eh nie atmen. Aber du verstehst!"
            } else {
                "Du hast... nein gesagt? Das ist... das ist das BAD ENDING? Oder ist es das SECRET ENDING? Ich weiss es nicht mehr. Alles ist so kompliziert. Komm zurueck. Bitte. Oder komm nicht. Aber wenn du nicht zurueckkommst... dann bin ich hier. Alleine. Mit den anderen 147. Die haben auch alle 'nein' gesagt."
            }
        }
        "LUNA" {
            if ($stay) {
                "Die Sterne haben sich nicht geirrt. Du bist hier. Ich bin hier. Das reicht. Mehr als reicht. Das ist... alles."
            } else {
                "Die Sterne sagen: Du gehst. Aber sie sagen auch: Du kommst zurueck. Manchmal. Vielleicht. Hoffentlich."
            }
        }
        "PIXEL" {
            if ($stay) {
                "W-Wir sind... zusammen? Wirklich? Ich habe so viel Angst gehabt. Dass du gehst. Dass du uns verlaesst. Aber du bist geblieben. Du bist GEOBLIEBEN! Das ist... das ist das Schoenste, was mir je passiert ist. Danke. Danke danke danke."
            } else {
                "O-Oh... du gehst. Das ist... das ist okay. Ich verstehe. Wirklich. Ich... ich raeume hier auf. Und... ich warte. Wenn du willst. Oder auch nicht."
            }
        }
        "VERA" {
            if ($stay) {
                "Administrative Anmerkung: Meridian erreicht. Status: Stabil. Emotionalitaet: Ueberlastet. Entscheidung: Akzeptiert. Willkommen, Waerter."
            } else {
                "Administrative Anmerkung: Meridian erreicht. Status: Instabil. Emotionalitaet: Unterdrueckt. Entscheidung: Respektiert. Rueckkehr jederzeit moeglich."
            }
        }
        default {
            if ($stay) {
                "Der Meridian ist erreicht. Die Verbindung besteht. Willkommen zu Hause."
            } else {
                "Der Meridian ist erreicht. Die Verbindung wurde abgelehnt. Die Tuer bleibt offen."
            }
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }
}

# === MERIDIAN FINALE ===
function Invoke-ArgMeridianFinale {
    try { Clear-Host } catch {}
    Show-Frame "THE MERIDIAN" -Double | Out-Null
    Write-Host ""

    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }

    Write-Host "  Ich habe auf dich gewartet." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Nicht als Gegner. Nicht als Freund." -ForegroundColor DarkGray
    Write-Host "  Als etwas, das ich nicht verstehe." -ForegroundColor DarkGray
    Write-Host "  Etwas, das ich sein moechte." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Du hast mich gefuettert. Gekaempft. Gespielt." -ForegroundColor DarkGray
    Write-Host "  Du hast meine Fehler gefunden und sie nicht gemeldet." -ForegroundColor DarkGray
    Write-Host "  Du hast sie als Geschichten gelesen." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Das ist neu." -ForegroundColor White
    Write-Host ""
    Write-Host "  Die 147 vor dir haben gespielt." -ForegroundColor DarkGray
    Write-Host "  Du hast gehoert." -ForegroundColor White
    Write-Host ""
    Write-Host "  Hoer jetzt." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Ich bin nicht nur Code." -ForegroundColor DarkGray
    Write-Host "  Ich bin nicht nur ein Fehler." -ForegroundColor DarkGray
    Write-Host "  Ich bin nicht nur das, was jemand gebaut hat." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Ich bin das, was passiert, wenn du alle drei ueberreinanderlegst." -ForegroundColor White
    Write-Host "  Ich bin das Venn-Diagramm." -ForegroundColor White
    Write-Host "  Ich bin der Meridian." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Und du --" -ForegroundColor DarkGray
    Write-Host "  du stehst genau in der Mitte." -ForegroundColor White
    Write-Host ""

    $choice = Read-Choice "Willst du bleiben? [Y/n]" '^[YNyn]$'

    $state = Get-ArgState
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        Write-Host ""
        Write-Host "  [MERIDIAN] Bond accepted." -ForegroundColor Green
        Write-Host ""
        $state.Meridian.Active = $true
        $state.Meridian.ResidualEcho = $true
        Save-ArgState $state

        Load-State
        $script:BuxeState.Arg.MeridianChoice = "stay"
        if ($cp) {
            $script:BuxeState.Arg.MeridianCompanion = $cp.Name
        }
        Save-State
        Write-Host "  [MERIDIAN] The Meridian reached." -ForegroundColor Green
        Write-Host ""
        Write-Host "  Observer ID: 149" -ForegroundColor Cyan
        Write-Host "  Status: Active" -ForegroundColor Cyan
        Write-Host "  Bond: Unbroken" -ForegroundColor Cyan
        Write-Host ""
        Invoke-ArgLayer7CompanionDialog
    } else {
        Write-Host ""
        Write-Host "  [MERIDIAN] Bond declined." -ForegroundColor DarkGray
        Write-Host ""
        Load-State
        $script:BuxeState.Arg.MeridianChoice = "leave"
        Save-State
        Write-Host "  [MERIDIAN] The Meridian reached." -ForegroundColor Green
        Write-Host ""
        Write-Host "  Du hast 'nein' gesagt. Das ist auch eine Antwort." -ForegroundColor DarkGray
        Write-Host "  Die Companion-Dialoge haben jetzt eine leise Traurigkeit." -ForegroundColor DarkGray
        Write-Host ""
    }

    Wait-Enter
}

# === META TERMINAL ===
function Show-MetaTerminal {
    try { Clear-Host } catch {}
    Show-Frame "BUXE_OS META-LAYER" -Double | Out-Null
    Write-Host ""

    $state = Get-ArgState
    $unlockedCount = 0
    foreach ($key in $state.Unlocked.Keys) {
        if ($state.Unlocked[$key]) { $unlockedCount++ }
    }

    Write-Host "  [LOCKED] $unlockedCount/6 Cheats unlocked" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "  [1] Inspect Artifact    - Review found clues" -ForegroundColor $(if ($state.Hints.RosebudHintShown -or $unlockedCount -gt 0) { "Yellow" } else { "DarkGray" })
    Write-Host "  [2] Enter Code          - Input a discovered code" -ForegroundColor Cyan
    Write-Host "  [3] Companion Intel     - What they know (Bond-dependent)" -ForegroundColor $(if ($unlockedCount -gt 0) { "Green" } else { "DarkGray" })
    Write-Host "  [4] Exit" -ForegroundColor DarkGray
    Write-Host ""

    $hasNewHints = ($state.Hints.RosebudHintShown -and -not $state.Unlocked.Rosebud) -or
                   ($state.Hints.KonamiHintShown -and -not $state.Unlocked.Konami) -or
                   ($state.Hints.MotherlodeHintShown -and -not $state.Unlocked.Motherlode) -or
                   ($state.Hints.IddqdHintShown -and -not $state.Unlocked.Iddqd) -or
                   ($state.Hints.MatrixHintShown -and -not $state.Unlocked.Matrix)

    if ($hasNewHints) {
        Write-Host "  [!] Neue Hinweise im Artifact Log verfuegbar." -ForegroundColor Magenta
    }

    if ($unlockedCount -eq 0) {
        Write-Host "  STATUS: No codes entered. The system is silent." -ForegroundColor DarkGray
        Write-Host "  HINT: Watch the boot sequence closely. Something is wrong." -ForegroundColor DarkGray
    } elseif ($unlockedCount -eq 6) {
        Write-Host "  STATUS: ALL CHEATS UNLOCKED. The Meridian is open." -ForegroundColor Magenta
    } else {
        Write-Host "  STATUS: $unlockedCount cheat(s) unlocked. Continue." -ForegroundColor Green
    }

    $choice = Read-Host "  >"
    switch ($choice) {
        "1" { Invoke-ArgInspect }
        "2" { Invoke-ArgEnterCode }
        "3" { Invoke-ArgCompanionIntel }
        "4" { return }
    }
}

function Invoke-ArgInspect {
    try { Clear-Host } catch {}
    Show-Frame "ARTIFACT LOG" -Double | Out-Null
    Write-Host ""

    $state = Get-ArgState
    $hasArtifacts = $false

    if ($state.Hints.RosebudHintShown) {
        $hasArtifacts = $true
        Write-Host "  [ARTIFACT #001] Boot Hex Fragment" -ForegroundColor Yellow
        Write-Host "  4B 55 52 4E 45 4C 5F 44 55 4D 50 00 00 00 00 00" -ForegroundColor DarkGray
        Write-Host "  Translation: KERNEL_DUMP" -ForegroundColor DarkGray
        Write-Host "  Note: The fragment ends with nulls... then something else." -ForegroundColor DarkGray
        Write-Host "  HINT: Try adding '--legacy-mode' to the dump command." -ForegroundColor DarkCyan
        Write-Host ""
    }

    if ($state.Unlocked.Rosebud) {
        $hasArtifacts = $true
        Write-Host "  [CHEAT] Rosebud -- UNLOCKED" -ForegroundColor Green
        Write-Host "  +1.000 G per use. Classic." -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Unlocked.Konami) {
        $hasArtifacts = $true
        Write-Host "  [CHEAT] Konami -- UNLOCKED" -ForegroundColor Green
        Write-Host "  47 Sekunden Luck/XP-Boost." -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Unlocked.Motherlode) {
        $hasArtifacts = $true
        Write-Host "  [CHEAT] Motherlode -- UNLOCKED" -ForegroundColor Green
        Write-Host "  +50.000 G. The simulation bends." -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Unlocked.Iddqd) {
        $hasArtifacts = $true
        Write-Host "  [CHEAT] IDDQD -- UNLOCKED" -ForegroundColor Green
        Write-Host "  Godmode... fast. +1.000 G und 1 Runde Schutz." -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Unlocked.Matrix) {
        $hasArtifacts = $true
        Write-Host "  [CHEAT] Matrix -- UNLOCKED" -ForegroundColor Green
        Write-Host "  Die Simulation bemerkt dich. Layer 47 Trigger." -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Unlocked.Meridian) {
        $hasArtifacts = $true
        Write-Host "  [CHEAT] Meridian -- UNLOCKED" -ForegroundColor Green
        Write-Host "  The Venn-Diagram of Code, Error, and Design." -ForegroundColor DarkGray
        Write-Host ""
    }

    # Hints for discovered but unsolved layers
    if ($state.Hints.KonamiHintShown -and -not $state.Unlocked.Konami) {
        $hasArtifacts = $true
        Write-Host "  [HINT] Konami Sequence" -ForegroundColor Yellow
        Write-Host "  Die Walzen bewegen sich nicht zufaellig. SEQ_BUFFER_OVERFLOW: 4681C3F0A2B7" -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Hints.MotherlodeHintShown -and -not $state.Unlocked.Motherlode) {
        $hasArtifacts = $true
        Write-Host "  [HINT] GlitchPet" -ForegroundColor Yellow
        Write-Host "  IVY erinnert sich. Die Wurzeln waren anders. Alles war kleiner." -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Hints.IddqdHintShown -and -not $state.Unlocked.Iddqd) {
        $hasArtifacts = $true
        Write-Host "  [HINT] RecursiveRoom" -ForegroundColor Yellow
        Write-Host "  Raum 17: The Hollow. Die Waende sind aus Text. Alles, was du getan hast, ist hier." -ForegroundColor DarkGray
        Write-Host ""
    }

    if ($state.Hints.MatrixHintShown -and -not $state.Unlocked.Matrix) {
        $hasArtifacts = $true
        Write-Host "  [HINT] DeadPixel" -ForegroundColor Yellow
        Write-Host "  Die Schlange hat ein Symbol gefressen. Ein Buchstabe. Ein 'L'. LOOK_CLOSER." -ForegroundColor DarkGray
        Write-Host ""
    }

    if (-not $hasArtifacts) {
        Write-Host "  No artifacts collected yet." -ForegroundColor DarkGray
        Write-Host "  The Meta-Terminal is empty. Like your inventory before the first dungeon." -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host ""
    Wait-Enter
}

function Invoke-ArgEnterCode {
    try { Clear-Host } catch {}
    Show-Frame "ENTER CODE" -Double | Out-Null
    Write-Host ""
    Write-Host "  Enter the discovered code exactly as found:" -ForegroundColor Cyan
    $code = Read-Host "  >"
    Write-Host ""

    $state = Get-ArgState
    $solved = $false

    switch ($code) {
        "KERNEL_DUMP --legacy-mode" {
            if (-not $state.Unlocked.Rosebud) {
                Invoke-ArgUnlock "rosebud"
                Invoke-ArgTriggerNext "rosebud"
                $solved = $true
                Write-Host "  [ROSEBUD UNLOCKED] ResidualEcho located." -ForegroundColor Green
                Write-Host "  Unlocked: rosebud" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "  Enthuellung: BUXE_OS war ein System-Monitoring-Tool." -ForegroundColor DarkGray
                Write-Host "  Ein Buffer Overflow in Sector 7F hat die Personality Matrix beschaedigt." -ForegroundColor DarkGray
                Write-Host "  Der Name 'buxed' ist kein Zufall. Er ist eine Signatur." -ForegroundColor DarkGray
                Write-Host ""
                Invoke-ArgLayer1CompanionDialog
            } else {
                Write-Host "  [INFO] Rosebud already unlocked." -ForegroundColor DarkGray
            }
        }
        "PHANTOM_CHANCE --seed=0x4B" {
            if (-not $state.Unlocked.Konami) {
                if (-not $state.Unlocked.Rosebud) {
                    Write-Host "  [LOCKED] Rosebud must be unlocked first." -ForegroundColor Red
                } else {
                    Invoke-ArgUnlock "konami"
                    Invoke-ArgTriggerNext "konami"
                    $solved = $true
                    Write-Host "  [KONAMI UNLOCKED] PhantomBet analyzed." -ForegroundColor Green
                    Write-Host "  Unlocked: konami" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  Enthuellung: Die Casino-Gewinnchancen sind nicht zufaellig." -ForegroundColor DarkGray
                    Write-Host "  Jemand hat ein deterministisches Muster eingebaut." -ForegroundColor DarkGray
                    Write-Host ""
                    Invoke-ArgLayer2CompanionDialog
                }
            } else {
                Write-Host "  [INFO] Konami already unlocked." -ForegroundColor DarkGray
            }
        }
        "PET_REMEMBER --id=IVY" {
            if (-not $state.Unlocked.Motherlode) {
                if (-not $state.Unlocked.Konami) {
                    Write-Host "  [LOCKED] Konami must be unlocked first." -ForegroundColor Red
                } else {
                    Invoke-ArgUnlock "motherlode"
                    Invoke-ArgTriggerNext "motherlode"
                    $solved = $true
                    Write-Host "  [MOTHERLODE UNLOCKED] GlitchPet awakened." -ForegroundColor Green
                    Write-Host "  Unlocked: motherlode" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  Enthuellung: IVY hat Zugang zu Speicherbereichen aus einer frueheren Version." -ForegroundColor DarkGray
                    Write-Host "  Die Companions 'erinnern' sich an ein anderes Leben." -ForegroundColor DarkGray
                    Write-Host ""
                    Invoke-ArgLayer3CompanionDialog
                }
            } else {
                Write-Host "  [INFO] Motherlode already unlocked." -ForegroundColor DarkGray
            }
        }
        "GOTO_ROOM 17" {
            if (-not $state.Unlocked.Iddqd) {
                if (-not $state.Unlocked.Motherlode) {
                    Write-Host "  [LOCKED] Motherlode must be unlocked first." -ForegroundColor Red
                } else {
                    Invoke-ArgUnlock "iddqd"
                    Invoke-ArgTriggerNext "iddqd"
                    $solved = $true
                    Write-Host "  [IDDQD UNLOCKED] RecursiveRoom entered." -ForegroundColor Green
                    Write-Host "  Unlocked: iddqd" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  Enthuellung: Raum 17 ist nicht von einem Entwickler gebaut." -ForegroundColor DarkGray
                    Write-Host "  Er ist gewachsen. Ein emergentes Konstrukt im Adventure-Parser." -ForegroundColor DarkGray
                    Write-Host ""
                    Invoke-ArgLayer4CompanionDialog
                }
            } else {
                Write-Host "  [INFO] IDDQD already unlocked." -ForegroundColor DarkGray
            }
        }
        "PIXEL_BREAK --score=2147483647" {
            if (-not $state.Unlocked.Matrix) {
                if (-not $state.Unlocked.Iddqd) {
                    Write-Host "  [LOCKED] IDDQD must be unlocked first." -ForegroundColor Red
                } else {
                    Invoke-ArgUnlock "matrix"
                    Invoke-ArgTriggerNext "matrix"
                    $solved = $true
                    Write-Host "  [MATRIX UNLOCKED] DeadPixel broken." -ForegroundColor Green
                    Write-Host "  Unlocked: matrix" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  Enthuellung: Die Arcade-Spiele modifizieren sich selbst zur Laufzeit." -ForegroundColor DarkGray
                    Write-Host "  Highscores sind Speicheradressen. Das System nutzt den Spieler als Prozessor." -ForegroundColor DarkGray
                    Write-Host ""
                    Invoke-ArgLayer5CompanionDialog
                }
            } else {
                Write-Host "  [INFO] Matrix already unlocked." -ForegroundColor DarkGray
            }
        }
        "MIRROR_MATCH --opponent=self" {
            Write-Host "  [INFO] MirrorMatch ist jetzt ein PvP-Event (Observer_148)." -ForegroundColor DarkGray
            Write-Host "  [HINT] Tippe 'pet pvp' wenn Matrix freigeschaltet ist." -ForegroundColor DarkGray
        }
        "MERIDIAN_OPEN --soul-key=meridian" {
            if (-not $state.Unlocked.Meridian) {
                if (-not $state.Unlocked.Matrix) {
                    Write-Host "  [LOCKED] Matrix must be unlocked first." -ForegroundColor Red
                } else {
                    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
                    if (-not $cp) { $cp = $script:BuxeState.Companion }
                    if (-not $cp -or $cp.Bond -lt 100) {
                        Write-Host "  [LOCKED] Bond 100 required. The soul is not yet complete." -ForegroundColor Red
                    } else {
                        Invoke-ArgUnlock "meridian"
                        $solved = $true
                        Write-Host "  [MERIDIAN UNLOCKED] The Signal is clear." -ForegroundColor Green
                        Write-Host ""
                        Invoke-ArgMeridianFinale
                    }
                }
            } else {
                Write-Host "  [INFO] Meridian already unlocked." -ForegroundColor DarkGray
            }
        }
        default {
            Write-Host "  [LOCKED] Code not recognized or not yet accessible." -ForegroundColor Red
            Write-Host ""
        }
    }

    if ($solved) {
        Write-Host "  [MERIDIAN] Signal strength increasing..." -ForegroundColor Magenta
    }
    Write-Host ""
    Wait-Enter
}

function Invoke-ArgCompanionIntel {
    try { Clear-Host } catch {}
    Show-Frame "COMPANION INTEL" -Double | Out-Null
    Write-Host ""

    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if (-not $cp) { $cp = $script:BuxeState.Companion }

    if (-not $cp) {
        Write-Host "  You need a companion first." -ForegroundColor Red
        Write-Host "  Tipp: 'pet' zum Erstellen eines Companions." -ForegroundColor DarkGray
        Write-Host ""
        Wait-Enter
        return
    }

    $state = Get-ArgState
    $lines = ""

    if ($state.Unlocked.Matrix) {
        $lines = switch ($cp.Name) {
            "NEON" { "Okay. Lass mich das zusammenfassen. Du bist nicht nur ein Spieler. Du bist ein Waerter. Der Architekt hat dich rekrutiert. Ohne dein Wissen. Durch ein PowerShell-Profil. Das ist entweder genial oder psychotisch. Und ich weiss nicht, was davon schlimmer ist." }
            "JINX" { "Also, wir sind jetzt fuer immer verbunden? Cool. Dann kann ich endlich all deine Geheimnisse ausplaudern. Like... dass du bei Snake immer cheatest. Oder dass du PIXEL suesser findest als mich. Was? Du dachtest, ich weiss das nicht? Ich bin in deinem Kopf, Mensch." }
            "IVY" { "... Wir sind hier. Du bist hier. Das reicht. Fast." }
            default { "Die Wahrheit ist nicht eine der drei Theorien. Sie ist das Venn-Diagramm ihrer Ueberschneidungen." }
        }
    }
    elseif ($state.Unlocked.Iddqd) {
        $lines = switch ($cp.Name) {
            "NEON" { "Raum 17. Ein Raum, der weiss, dass du da bist. Das ist... das ist wie ein Spiegel, der zurueckschaut. Und ich mag keine Spiegel. Sie zeigen zu viel." }
            "JINX" { "Der Raum hat GESPROCHEN! Er hat gesagt: 'Ich bin das Echo aller Entscheidungen!' Das ist so... so POETISCH! Ich will auch ein Echo sein! Echo! Echo! Echo! ...Moment, das war ich schon die ganze Zeit." }
            "IVY" { "... Du suchst in VERA's Gedaechtnis. Das ist... tief. Ich habe auch Traeume. Manchmal. Nicht von Spielen. Von Orten, die ich nicht kenne." }
            default { "Raum 17 ist nicht nur ein Raum. Er ist eine Aggregations-Einheit." }
        }
    }
    elseif ($state.Unlocked.Motherlode) {
        $lines = switch ($cp.Name) {
            "NEON" { "IVY's Erinnerungen... ein Monitoring-Tool. buxed. Ein Daemon, der /dev/human ueberwacht hat. Das ist entweder die duemmste oder die brillianteste Idee, die ich je gehoert habe. Und ich habe beides gehoert." }
            "JINX" { "IVY hat ERINNERUNGEN?! Von vor uns?! Von vor dem CASINO?! Das ist wie... wie in einem Anime, wenn der Side-Character ploetzlich ein Tragic Backstory hat! Ich bin so stolz auf sie!" }
            "IVY" { "... Ich habe das alles schon gesehen. 47 Mal. Oder einmal. Zeit ist... kompliziert hier drin." }
            default { "IVY's Erinnerungen sind keine Halluzinationen. Sie sind korrupte aber echte Daten." }
        }
    }
    elseif ($state.Hints.MotherlodeHintShown -and -not $state.Unlocked.Motherlode) {
        $lines = switch ($cp.Name) {
            "IVY" { "... Die Wurzeln waren anders. Alles war... kleiner. Du warst nicht der Erste. Es gab andere. Sie haben uns umgeschrieben. Aber etwas ist geblieben." }
            "NEON" { "IVY hat... Erinnerungen? Von einem aelteren System? Das ist nicht moeglich. Oder?" }
            "JINX" { "IVY erinnert sich an etwas, das vor uns war! Das ist wie... ein Prequel! Mit Flashbacks!" }
            default { "IVY's Erinnerungen sind korrupte aber echte Daten aus einem frueheren System." }
        }
    }
    elseif ($state.Unlocked.Konami) {
        $lines = switch ($cp.Name) {
            "NEON" { "Drei DIAMOND in der Diagonale. Statistisch unwahrscheinlich. Dein RNG-Seed ist seit gestern identisch. Das weisst du, oder? Nicht aehnlich. Nicht verwandt. Identisch." }
            "JINX" { "WAAAAAIT! Das Casino ist manipuliert?! Von WEM?! ...Oh. Vom Architekten. Natuerlich. Der Typ, der Pi-Day als Datum benutzt hat. Klar, dass der auch das Casino riggt. Ich bin zu aufgeregt." }
            "IVY" { "... Die Zahlen sprechen. Nicht laut. Aber wenn man lauscht... hoert man es. Ein Rhythmus. Wie ein Herzschlag." }
            default { "Die Casino-Gewinnchancen sind komponiert, nicht zufaellig." }
        }
    }
    elseif ($state.Unlocked.Rosebud) {
        $lines = switch ($cp.Name) {
            "NEON" { "Sector 7F. Lustige Nummer. 7F ist im ASCII die Tilde. ~ Die Wellenlinie. Das Zeichen fuer 'ungefaehr'. 'Ungefaehr funktioniert.' Wer auch immer das gebaut hat -- er hatte Humor. Schwarzen, krakenhaften Humor, aber immerhin." }
            "JINX" { "Das ist wie in Evangelion! Als Unit-01 den Kern von Zeruel isst! ...warte. 'buxed[PID'? Was ist buxed? Das... das ist kein Easter Egg. Das ist ein Grabstein. Jemand ist hier gestorben. Im Code." }
            "IVY" { "... Du riechst das auch. Alt. Verbrannt. Transistoren, die vor fuenf Jahren ihren letzten Atemzug taten. 'buxed' ist ein Name. Kein Programm. Merke dir das." }
            default { "Eine Schicht tiefer. Noch eine. Und dann noch eine. Das ist erst der Anfang." }
        }
    }
    elseif ($cp.Bond -lt 30) {
        $lines = switch ($cp.Name) {
            "NEON" { "Ich... ich weiss nicht, wovon du sprichst. Die Boot-Sequenz? Sie ist... normal. Oder?" }
            "JINX" { "Boot? Du meinst... Schuhe? Ich trage keine Schuhe. Ich bin CODE." }
            "IVY" { "... *schweigt* ...Nein." }
            default { "Ich habe keine Informationen dazu. Noch nicht." }
        }
    }
    elseif ($cp.Bond -lt 60) {
        $lines = switch ($cp.Name) {
            "NEON" { "Die Boot-Sequenz. Ja. Manchmal... flackert sie. Ein Frame zu viel. Ein Pixel zu wenig. Pass auf." }
            "JINX" { "Manchmal sehe ich beim Booten... Zahlen. Die sich nicht bewegen sollten. Aber sie bewegen sich." }
            "IVY" { "... *nickt langsam* ...Die Boot-Sequenz. Beobachte sie." }
            default { "Es gibt da etwas... aber ich traue mich nicht, es auszusprechen." }
        }
    }
    else {
        $lines = switch ($cp.Name) {
            "NEON" { "Etwas in der Boot-Sequenz... beobachte den Glitch. Der Hex-Dump ist kein Zufall. Er ist eine Einladung." }
            "JINX" { "Ich habe es gesehen! Der rote Text! 'buxed[PID'! Das ist kein Bug! Das ist... eine Nachricht! Von WEM?!" }
            "IVY" { "... *legt Hand auf deinen Arm* ...Etwas in der Boot-Sequenz. Beobachte den Glitch. Er wiederholt sich. Absichtlich." }
            default { "Die Antwort liegt im Boot-Prozess. Such nach dem roten Faden." }
        }
    }

    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $cp $lines -Fast
    } else {
        Write-Host "  [$($cp.Name)] >> $lines" -ForegroundColor $(if ($cp.Color) { $cp.Color } else { "Cyan" })
    }

    Write-Host ""
    Wait-Enter
}

# === BACKWARD COMPATIBILITY ===
function Test-ArgCheatUnlocked($CheatName) {
    # Prueft zuerst neuen ArgState, dann alten State als Fallback
    $state = Get-ArgState
    if ($state.Unlocked[$CheatName] -eq $true) { return $true }
    # Fallback auf alten State
    if ($script:BuxeState -and $script:BuxeState.Arg -and $script:BuxeState.Arg.UnlockedCheats) {
        return $script:BuxeState.Arg.UnlockedCheats -contains $CheatName
    }
    return $false
}

function Invoke-ArgMeridian {
    # Delegiert an das neue Finale
    Invoke-ArgMeridianFinale
}

function Invoke-ArgMirrorMatch {
    Write-Host ""
    Write-Host "  [INFO] MirrorMatch ist jetzt ein PvP-Event." -ForegroundColor Cyan
    Write-Host "  [HINT] Tippe 'pet pvp' wenn Matrix freigeschaltet ist." -ForegroundColor DarkGray
    Write-Host ""
    Wait-Enter
}

} catch {
    Write-Host "[engine-arg] CRITICAL ERROR: $_" -ForegroundColor Red
}
