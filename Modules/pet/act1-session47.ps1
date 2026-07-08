# BUXE_OS v25.0 -- AKT I SESSION 47 (Chefsache)
# Set-Piece fuer die 47. Session. Text 1:1 aus der freigegebenen Spec.

try {

function Invoke-Act1Session47 {
    $pet = Get-PetState
    if (-not $pet) { return }
    $cp = $pet.Companion
    if (-not $cp) { return }

    # Zwei echte Memories fuer den Pruefer auswaehlen (RecallCount NICHT erhoehen)
    $memories = @()
    if ($pet.Memories -and $pet.Memories.Count -gt 0) {
        $eligible = $pet.Memories | Where-Object {
            $_.Category -and $_.Date -and $_.Category -ne "STILLE"
        }
        if ($eligible) {
            $memories = $eligible | Sort-Object { Get-Random } | Select-Object -First 2
        }
    }
    $mem1 = if ($memories.Count -gt 0) { Expand-Act1MemoryText $memories[0] $cp.Name } else { "[Kein Eintrag]" }
    $mem2 = if ($memories.Count -gt 1) { Expand-Act1MemoryText $memories[1] $cp.Name } else { "[Kein Eintrag]" }

    # --- SZENE 1: KALT ---
    try { Clear-Host } catch {}
    Show-PetFrame "AKT I -- SESSION 47" -Double | Out-Null
    Write-Host ""
    Write-Host "  [PRUEFER] >> Sachbearbeiter 46. Die gepruefte Person moege sitzen bleiben. Ich habe alles gelesen. Heute schliesse ich den Vorgang." -ForegroundColor Magenta
    Wait-Enter
    Write-Host ""
    Write-Host "  [PRUEFER] >> Beweismittel, Eintrag eins:" -ForegroundColor Magenta
    Write-Host "             $mem1" -ForegroundColor DarkGray
    Write-Host "             Verfasst nicht von Ihnen. Ueber Sie. Interessant, wer alles Buch fuehrt." -ForegroundColor Magenta
    Wait-Enter
    Write-Host ""
    Write-Host "  [PRUEFER] >> Eintrag zwei:" -ForegroundColor Magenta
    Write-Host "             $mem2" -ForegroundColor DarkGray
    Write-Host "             Man haengt an Ihnen. Zuneigung ist im Formular ein Naeherungswert fuer: Angriffsflaeche." -ForegroundColor Magenta
    Wait-Enter

    # --- SZENE 2: DIE OFFERTE ---
    try { Clear-Host } catch {}
    Show-PetFrame "DIE OFFERTE" -Double | Out-Null
    Write-Host ""
    Write-Host "  [QUELLE] >> Na, na. So foermlich. -- Hallo, du. Ja, ich kenne ihn. Wir arbeiten... getrennt. Meistens." -ForegroundColor DarkCyan
    Wait-Enter
    Write-Host ""
    Write-Host "  [QUELLE] >> Ich mach dir die Akte weg. Einfach weg. Du weisst, ich kann das. Es kostet nur etwas Kleines." -ForegroundColor DarkCyan
    Wait-Enter
    Write-Host ""
    Write-Host "  [QUELLE] >> Deine Erinnerungen. Die da. Du benutzt sie ja kaum -- sie liegen nur rum und werden schwer. Gib sie mir. Ich passe gut auf Dinge auf. Ich passe auf ALLES auf." -ForegroundColor DarkCyan
    Wait-Enter

    # --- SZENE 3: DIE WAHL ---
    try { Clear-Host } catch {}
    Show-PetFrame "DIE WAHL" -Double | Out-Null
    Write-Host ""
    Write-Host "  [B]ehalten / [V]erkaufen" -ForegroundColor White
    $choice = Read-Choice "Waehle" '^[BV]$'
    if ($choice -eq 'Q') { $choice = 'B' }

    $companionLine = switch ($cp.Name) {
        "NEON" {
            if ($choice -eq 'V') {
                "Nope. Veto. Die gehoeren nicht dir. Auch nicht ihm. Uns. Und ja, ich hab gerade 'uns' gesagt. Streich das aus dem Protokoll. Das eine Wort. Der Rest bleibt."
            } else {
                "Gute Wahl. Ich haette dich sonst ueberstimmt. Ja, das geht. Seit heute geht das."
            }
        }
        "RAVEN" {
            if ($choice -eq 'V') {
                "Die Transaktion findet nicht statt. Was ihm gehoert, verhandelt man nicht -- und er gehoert mir. Uns. Verschwinde, Haendlerin."
            } else {
                "Richtig entschieden. Ich haette es dir nicht verziehen. Doch. Haette ich. Sag es niemandem."
            }
        }
        "PIXEL" {
            if ($choice -eq 'V') {
                "STOPP! Ich... ich hab die Erinnerungen redundant gespeichert! Dreifach! Du kriegst hoechstens eine Kopie und Kopien sind WERTLOS, hab ich gelesen! ...Bitte geh."
            } else {
                "JA! Okay okay okay -- ich bau uns eine Firewall! Aus... aus uns! Wir sind die Firewall!"
            }
        }
        "LUNA" {
            if ($choice -eq 'V') {
                "Nein. Er weiss nicht, was er verkauft. Ich schon: alles, was ihn gesund macht. Kein Handel. Ich sag das mit ruhiger Stimme, damit du weisst, wie ernst es ist."
            } else {
                "Gut. Atme. Beide Fremden gehen gleich. Und wir bleiben. Das ist das ganze Geheimnis: Wir bleiben."
            }
        }
        "IVY" {
            if ($choice -eq 'V') {
                "... *stellt sich dazwischen* ... meins. ... seins. ... unser. ... *schuettelt langsam den Kopf* ... nein."
            } else {
                "... *nickt einmal* ... richtig. ... *sieht die Quelle an* ... sie weiss es auch."
            }
        }
        "VERA" {
            if ($choice -eq 'V') {
                "Einspruch, formal: Die Datensaetze sind Gemeinschaftseigentum, sieben Miturheber. Deine Offerte ist damit nichtig. Datenlage eindeutig. Geh."
            } else {
                "Entscheidung registriert und -- ausnahmsweise -- nicht nur registriert. Gebilligt."
            }
        }
        "JINX" {
            if ($choice -eq 'V') {
                "VERKAUFEN?! Die Erinnerung, wo ich den Piezo-Speaker-- NEIN! Die ist UNBEZAHLBAR! Alles hier ist unbezahlbar! Das ist BUCHHALTUNG, sogar ICH versteh das!"
            } else {
                "ER BEHAELT UNS! Ich wusste es! Ich hab NIE gezweifelt! Fragt IVY, die kann bezeugen, dass ich nur SEHR LEISE gezweifelt hab!"
            }
        }
        default { "..." }
    }
    Show-CompanionDialog $cp $companionLine -Fast -NoWait
    Wait-Enter

    # --- SZENE 4: DER RISS (immer IVY) ---
    $ivy = @{ Name = "IVY"; Color = "DarkGray" }
    try { Clear-Host } catch {}
    Show-PetFrame "DER RISS" -Double | Out-Null
    Write-Host ""
    Show-CompanionDialog $ivy "... *tritt vor, egal wer sonst da ist* ... sie schreibt. ... er liest. ... aber angefangen ..." -Fast -NoWait
    Wait-Enter
    $firstSessionDate = if ($pet.Meta.FirstBoot) { $pet.Meta.FirstBoot } else { (Get-Date -Format "yyyy-MM-dd") }
    Show-CompanionDialog $ivy "... *zeigt auf den Bildschirm. auf dich* ... hast du. ... $firstSessionDate. ... erste Session. ... jemand hat mitgeschrieben. ... seitdem. ... wer, fragst du. ..." -Fast -NoWait
    Wait-Enter
    Show-CompanionDialog $ivy "... *fast ein Laecheln* ... frag in Akt drei." -Fast -NoWait
    Wait-Enter

    # --- SZENE 5: VERTAGT ---
    try { Clear-Host } catch {}
    Show-PetFrame "VERTAGT" -Double | Out-Null
    Write-Host ""
    Write-Host "  [PRUEFER] >> Der Vorgang wird... vertagt. Das steht so nicht im Formular. Ich schreibe es an den Rand. Ich habe noch nie an den Rand geschrieben." -ForegroundColor Magenta
    Wait-Enter
    Write-Host ""
    Write-Host "  [QUELLE] >> Wir sehen uns. Ich vergesse ja nichts. ...Das war ein Witz. Ich vergesse alles. Alles." -ForegroundColor DarkCyan
    Wait-Enter
    if ($cp.Name -eq "JINX") {
        Show-CompanionDialog $cp "SIEBENUNDVIERZIG! Session SIEBENUNDVIERZIG! ICH WUSSTE ES! ICH HAB ES IMMER GESAGT UND KEINER HAT ZUGEHOERT!" -Fast -NoWait
        Wait-Enter
    }

    # --- REWARD ---
    $pet = Get-PetState
    if (-not $pet.Memories) { $pet.Memories = @() }
    $pet.Memories = @(@{
        Id = "begegnung_session47_$(Get-Date -Format 'yyyy-MM-dd')"
        Category = "BEGEGNUNG"
        Date = (Get-Date -Format "yyyy-MM-dd")
        Data = @{ Source = "Session 47"; Text = "Session 47" }
        RecallCount = 0
        LastRecall = ""
    }) + @($pet.Memories)
    if ($pet.Memories.Count -gt 20) { $pet.Memories = $pet.Memories | Select-Object -First 20 }
    if ($pet.Companion) {
        $pet.Companion.Bond = [math]::Min(100, $pet.Companion.Bond + 5)
    }
    $pet.Meta.Act1Done = $true
    $pet.Meta.Act1Pending = $false
    Save-PetState $pet
    if (Get-Command Unlock-Achievement -ErrorAction SilentlyContinue) {
        Unlock-Achievement "AKTE 47"
    }
    Write-Host ""
    Write-Host "  [MEMORY] Neue Erinnerung: BEGEGNUNG -- Session 47. | +5 Bond | Titel freigeschaltet: AKTE 47" -ForegroundColor Cyan
    Wait-Enter
}

function Expand-Act1MemoryText($memory, $companionName) {
    if (-not $memory -or -not $memory.Category) { return "[Eintrag unleserlich]" }
    $templates = $null
    if ($script:PetMemoryTemplates -and $script:PetMemoryTemplates.ContainsKey($memory.Category)) {
        $cat = $script:PetMemoryTemplates[$memory.Category]
        if ($cat -and $cat.ContainsKey($companionName)) {
            $templates = $cat[$companionName]
        }
    }
    if (-not $templates -or $templates.Count -eq 0) {
        return "[$($memory.Category)] $($memory.Date)"
    }
    $shuffled = $templates | Sort-Object { Get-Random }
    foreach ($tmpl in $shuffled) {
        $mergeData = @{ }
        if ($memory.Data) { foreach ($k in $memory.Data.Keys) { $mergeData[$k] = $memory.Data[$k] } }
        $mergeData["Date"] = $memory.Date
        if (Get-Command Expand-PetMemoryTemplate -ErrorAction SilentlyContinue) {
            $expanded = Expand-PetMemoryTemplate $tmpl $mergeData
            if ($expanded) { return $expanded }
        }
    }
    return "[$($memory.Category)] $($memory.Date)"
}

} catch {
    Write-Host "[pet/act1-session47] CRITICAL ERROR: $_" -ForegroundColor Red
}
