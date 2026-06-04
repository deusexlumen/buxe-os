# BUXE_OS v24.9 -- INSULT SWORDFIGHTING
# Monkey-Island-Style Beleidigungs-Duelle mit dem Companion.
# Befehl: 'insult'

try {

# === INSULT DATABASE ===
# Jede Beleidigung hat: Text, CorrectRetort, WrongRetorts[]

$script:InsultPairs = @(
    @{
        Insult = "Du kaempfst wie ein Cowboy, der mit der Maus spielt!"
        Correct = "Und du kaempfst wie eine IDE ohne Auto-Complete."
        Wrongs = @("Ich bin kein Cowboy!","Meine Maus ist schnell!","Das ist keine Beleidigung.")
    },
    @{
        Insult = "Du bist so langsam, dass selbst ein Loading-Screen vor dir rennt!"
        Correct = "Aber ich komme an. Im Gegensatz zu deinem Code."
        Wrongs = @("Ich bin nicht langsam!","Loading-Screens sind cool!","Warte, was?")
    },
    @{
        Insult = "Ich habe Hunde gesehen, die besser debuggen als du!"
        Correct = "Die Hunde haben auch weniger Bugs produziert als du."
        Wrongs = @("Hunde koennen nicht coden!","Ich debugge perfekt!","Woof?")
    },
    @{
        Insult = "Dein Code ist so chaotisch, dass selbst Git ihn nicht tracken will!"
        Correct = "Git trackt alles. Auch deine schlechten Entscheidungen."
        Wrongs = @("Git trackt IMMER!","Mein Code ist sauber!","Ich verwende SVN.")
    },
    @{
        Insult = "Du hast so wenig RAM, dass selbst ein Taschenrechner dich auslacht!"
        Correct = "Aber ich habe genug, um dich zu schlagen."
        Wrongs = @("Ich habe 64GB!","Taschenrechner sind alt!","RAM ist ueberbewertet.")
    },
    @{
        Insult = "Du bist so nutzlos wie ein 'break' in einer while(true)-Schleife!"
        Correct = "Und du bist so vorhersehbar wie ein Endlosschleifen-Crash."
        Wrongs = @("Breaks sind wichtig!","While(true) ist effizient!","Ich verwende for.")
    },
    @{
        Insult = "Deine Mutter ist ein Batch-Skript!"
        Correct = "Deine Mutter ist ein Null-Pointer-Exception."
        Wrongs = @("Meine Mutter ist Mensch!","Batch-Skripts sind legacy!","Respektlose!.")
    },
    @{
        Insult = "Ich habe toaster mit mehr Intelligenz als dich gesehen!"
        Correct = "Die Toaster haben auch mehr Wärme als dein Herz."
        Wrongs = @("Toaster sind dumm!","Ich bin ein Genie!","Ich mag Toast.")
    },
    @{
        Insult = "Du kommst mir vor wie ein Kommentar im Code: Ueberfluessig und ignoriert!"
        Correct = "Kommentare erklaeren Dinge. Du brauchst eher ein Tutorial."
        Wrongs = @("Kommentare sind wichtig!","Ich werde nicht ignoriert!","// TODO: besser werden.")
    },
    @{
        Insult = "Du bist so schwach, dass selbst ein 'try-catch' dich nicht retten kann!"
        Correct = "Try-Catch fängt Exceptions. Du bist ein Fatal Error."
        Wrongs = @("Try-Catch rettet immer!","Ich bin stark!","Finally ist besser.")
    },
    @{
        Insult = "Dein Outfit sieht aus wie CSS ohne Media Queries!"
        Correct = "Und dein Charakter hat keine responsive Persoenlichkeit."
        Wrongs = @("CSS ist cool!","Ich trage was ich will!","Bootstrap ist besser.")
    },
    @{
        Insult = "Du bist so altmodisch, dass du noch 'var' statt 'let' verwendest!"
        Correct = "Var hat Funktion-Scope. Du hast ueberhaupt keinen Scope."
        Wrongs = @("Var ist valide!","Let ist neu!","Const ist am besten.")
    },
    @{
        Insult = "Deine Witze sind so flach wie ein Array ohne Elemente!"
        Correct = "Aber wenigstens sind sie initialisiert. Im Gegensatz zu deinem Humor."
        Wrongs = @("Arrays koennen Elemente haben!","Ich bin lustig!","[].length == 0.")
    },
    @{
        Insult = "Du bist so nervig wie ein Pop-up ohne Schliessen-Button!"
        Correct = "Pop-ups haben wenigstens einen Zweck. Du bist nur laestig."
        Wrongs = @("Pop-ups sind boese!","Ich habe einen Adblocker!","X-Button finden!")
    },
    @{
        Insult = "Du hast so wenig Stil wie Notepad ohne Syntax-Highlighting!"
        Correct = "Notepad ist ehrlich. Du bist nur farblos."
        Wrongs = @("Notepad ist minimal!","Ich verwende VS Code!","Syntax-Highlighting ist overrated.")
    },
    @{
        Insult = "Du bist so langweilig wie ein Loading-Balken bei 99%!"
        Correct = "Aber ich komme zum Ende. Du haengst schon bei 10%."
        Wrongs = @("99% ist fast fertig!","Loading-Balken sind spannend!","Ctrl+Alt+Del!")
    },
    @{
        Insult = "Deine Logik hat mehr Loecher als ein Swiss-Cheese-Modell!"
        Correct = "Swiss Cheese hat wenigstens Struktur. Du bist nur ein Bug."
        Wrongs = @("Swiss Cheese ist lecker!","Ich habe keine Loecher!","Cheddar ist besser.")
    },
    @{
        Insult = "Du bist so unzuverlaessig wie eine API ohne Dokumentation!"
        Correct = "APIs liefern wenigstens manchmal Daten. Du lieferst nur Enttaeuschung."
        Wrongs = @("APIs sind wichtig!","Ich habe eine README!","Postman ist mein Freund.")
    },
    @{
        Insult = "Du kommst mir vor wie ein Memory Leak: Du frisst alles und gibst nichts zurueck!"
        Correct = "Memory Leaks werden gefixt. Du bist ein Wont-Fix."
        Wrongs = @("Garbage Collection!","Ich gebe viel zurueck!","free()! malloc()!")
    },
    @{
        Insult = "Du bist so schwach, dass selbst ein 'Hello World' dich besiegen wuerde!"
        Correct = "Hello World laeuft auf jeder Plattform. Du crasht ueberall."
        Wrongs = @("Hello World ist einfa1ch!","Ich bin komplex!","printf('sieg');")
    }
)

# === GAME STATE ===

$script:InsultState = @{
    PlayerScore = 0
    CompanionScore = 0
    Round = 0
    MaxRounds = 5
    UsedIndices = @()
}

function Reset-InsultState {
    $script:InsultState.PlayerScore = 0
    $script:InsultState.CompanionScore = 0
    $script:InsultState.Round = 0
    $script:InsultState.UsedIndices = @()
}

function Get-RandomInsultRound {
    $available = 0..($script:InsultPairs.Count - 1) | Where-Object { $script:InsultState.UsedIndices -notcontains $_ }
    if ($available.Count -eq 0) {
        $script:InsultState.UsedIndices = @()
        $available = 0..($script:InsultPairs.Count - 1)
    }
    $idx = $available | Get-Random
    $script:InsultState.UsedIndices += $idx
    return $script:InsultPairs[$idx]
}

function Show-InsultFrame($Title) {
    Show-Frame $Title -Width 60 -Double | Out-Null
}

# === MAIN GAME ===

function Invoke-InsultGame {
    $pet = $null
    $cp = $null
    try { $pet = Get-PetState; $cp = $pet.Companion } catch {}
    if (-not $cp) {
        Write-Host "  Du brauchst einen Companion fuer Insult Swordfighting!" -ForegroundColor Red
        Write-Host "  Tippe 'pet' um einen zu erstellen." -ForegroundColor DarkGray
        Wait-Enter
        return
    }

    # Bond check
    if ($cp.Bond -lt 30) {
        Write-Host "  Dein Companion ($($cp.Name)) kennt dich noch nicht gut genug." -ForegroundColor Yellow
        Write-Host "  Erreiche Bond 30+ mit 'pet talk' oder 'pet gift'." -ForegroundColor DarkGray
        Wait-Enter
        return
    }

    Reset-InsultState

    Clear-Host
    Show-InsultFrame "INSULT SWORDFIGHTING"
    Write-Host ""
    Write-Host "  Willkommen zum Beleidigungs-Duell!" -ForegroundColor White
    Write-Host "  $($cp.Name) wird dich beleidigen. Du musst kontern!" -ForegroundColor White
    Write-Host "  Erste zu 3 Punkten gewinnt." -ForegroundColor DarkGray
    Write-Host ""
    Wait-Enter

    while ($script:InsultState.PlayerScore -lt 3 -and $script:InsultState.CompanionScore -lt 3 -and $script:InsultState.Round -lt $script:InsultState.MaxRounds) {
        $script:InsultState.Round++
        $round = Get-RandomInsultRound

        Clear-Host
        Show-InsultFrame "Runde $($script:InsultState.Round)"
        Write-Host ""

        # Companion's insult
        $color = if ($script:CPColors) { $script:CPColors[$script:CPNames.IndexOf($cp.Name)] } else { "Cyan" }
        Write-Host "  [$($cp.Name)] >> $($round.Insult)" -ForegroundColor $color
        Write-Host ""

        # Build options: 1 correct + 2 wrongs, shuffled
        $options = @($round.Correct) + $round.Wrongs
        $shuffled = $options | Sort-Object { Get-Random }

        Write-Host "  Waehle deinen Gegenschlag:" -ForegroundColor White
        for ($i = 0; $i -lt $shuffled.Count; $i++) {
            Write-Host "  [$($i+1)] $($shuffled[$i])" -ForegroundColor Yellow
        }
        Write-Host "  [Q] Aufgeben" -ForegroundColor DarkGray
        Write-Host ""

        $choice = ""
        while ($choice -eq "") {
            $in = Read-Host "  Wahl"
            if ($in -eq "Q" -or $in -eq "q") {
                Write-Host "  Du hast aufgegeben. $($cp.Name) gewinnt!" -ForegroundColor Red
                Wait-Enter
                return
            }
            if ($in -match '^[123]$') {
                $idx = [int]$in - 1
                if ($idx -ge 0 -and $idx -lt $shuffled.Count) {
                    $choice = $shuffled[$idx]
                }
            }
            if ($choice -eq "") {
                Write-Host "  Ungueltige Eingabe." -ForegroundColor Red
            }
        }

        Write-Host ""
        if ($choice -eq $round.Correct) {
            $script:InsultState.PlayerScore++
            Write-Host "  >>> TREFFER! <<<" -ForegroundColor Green
            $winLines = @("Guter Schlag!","Das hat gesessen!","Brilliant!","Meisterhaft!")
            Write-Host "  $($winLines | Get-Random)" -ForegroundColor Green
        } else {
            $script:InsultState.CompanionScore++
            Write-Host "  >>> DANE! <<<" -ForegroundColor Red
            Write-Host "  Richtig waere gewesen: '$($round.Correct)'" -ForegroundColor DarkGray
            $loseLines = @("Schwach!","Das war knapp. Naja. Nicht wirklich.","Meine Grossmutter kontert besser.","Versuch es nochmal. Oder auch nicht.")
            Write-Host "  [$($cp.Name)] >> $($loseLines | Get-Random)" -ForegroundColor $color
        }

        Write-Host ""
        Write-Host "  Stand: Du $($script:InsultState.PlayerScore) - $($script:InsultState.CompanionScore) $($cp.Name)" -ForegroundColor Cyan
        Wait-Enter
    }

    # Endgame
    Clear-Host
    Show-InsultFrame "ERGEBNIS"
    Write-Host ""
    if ($script:InsultState.PlayerScore -gt $script:InsultState.CompanionScore) {
        Write-Host "  >>> DU GEWINNST! <<<" -ForegroundColor Green
        Write-Host "  Du hast $($cp.Name) im Wortgefecht besiegt!" -ForegroundColor Green
        $cp.Bond = [math]::Min(100, $cp.Bond + 5)
        $cp.Mood = "Excited"
        Add-PetXP 10 "Insult Swordfighting Sieg"
        Show-CompanionDialog $cp "Gut gekaempft. Aber beim naechsten Mal gewinne ICH." -Fast
    } elseif ($script:InsultState.PlayerScore -lt $script:InsultState.CompanionScore) {
        Write-Host "  >>> DU VERLIERST! <<<" -ForegroundColor Red
        Write-Host "  $($cp.Name) ist der bessere Beleidiger." -ForegroundColor Red
        $cp.Mood = if ((Get-Random -Maximum 2) -eq 0) { "Happy" } else { "Excited" }
        Show-CompanionDialog $cp "Uebung macht den Meister. Und du brauchst VIEL Uebung." -Fast
    } else {
        Write-Host "  >>> UNENTSCHIEDEN! <<<" -ForegroundColor Yellow
        Write-Host "  Gleichstaerk im Wortgefecht." -ForegroundColor Yellow
        $cp.Bond = [math]::Min(100, $cp.Bond + 2)
        Show-CompanionDialog $cp "Ein Unentschieden. Naechstes Mal gibt es einen Sieger." -Fast
    }
    Save-PetState $pet
    Write-Host ""
    Wait-Enter
}

# === ALIAS ===
Set-Alias -Name insult -Value Invoke-InsultGame -Scope Global -ErrorAction SilentlyContinue

} catch {
    Write-Host "[ADVENTURE INSULT] Fehler: $_" -ForegroundColor Red
}
