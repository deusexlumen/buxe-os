# BUXE_OS v24.4 -- FUN MODULE
# Meta-Cheats, APIs, Gags — alles im LucasArts-Stil.

try {

# === TTS ===
# TTS lives in the main profile (Say, Set-Voice, Show-Voices, Clip-Say).

# === API WRAPPER ===
function Invoke-PublicApi($Url, $PropertyPath, $Color, $Headers = @{}) {
    try {
        $r = Invoke-RestMethod $Url -Headers $Headers -TimeoutSec 5
        $value = Invoke-Expression "`$r.$PropertyPath"
        Write-Host "`n  $value`n" -ForegroundColor $Color
    } catch { Write-Host "API offline." -ForegroundColor DarkGray }
}

function chuck   { Invoke-PublicApi "https://api.chucknorris.io/jokes/random" "value" "Yellow" }
function cat     { Invoke-PublicApi "https://catfact.ninja/fact" "fact" "Cyan" }
function dog     { Invoke-PublicApi "https://dog.ceo/api/breeds/image/random" "message" "Cyan" }
function btc     { Invoke-PublicApi "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd" "bitcoin.usd" "Yellow" }
function bored   { Invoke-PublicApi "https://www.boredapi.com/api/activity" "activity" "Magenta" }
function kanye   { Invoke-PublicApi "https://api.kanye.rest" "quote" "White" }
function dadjoke { Invoke-PublicApi "https://icanhazdadjoke.com/" "joke" "Green" @{Accept = "application/json"} }
function zen     { Invoke-PublicApi "https://zenquotes.io/api/random" "[0].q + ' -- ' + [0].a" "Cyan" }

# === TOOLS ===
function pomodoro { param($min = 25); Write-Host "  Pomodoro: $min Minuten..." -ForegroundColor Red; Start-Sleep -Seconds ($min * 60); Write-Host "  Zeit um!" -ForegroundColor Green; say "Pomodoro complete" }
function roast { $roasts = @("Your code is like your dating life -- full of exceptions.","I have seen better variable names from a random string generator.","You are the reason we have code reviews.","Your README is longer than your attention span.","You commit like you text -- way too often with no meaning."); Write-Host "`n  ROAST: $($roasts | Get-Random)`n" -ForegroundColor Red }

# === META CHEATS — Deep LucasArts Integration ===
# Jeder Cheat ist self-aware, fourth-wall-breaking und humor-gesteuert.

function motherlode {
    if (Test-ArgCommand "motherlode") { return }
    Write-Host "  [LOCKED] Dieser Cheat existiert nicht. Noch nicht." -ForegroundColor Red
    Write-Host "  Tipp: Manche Befehle wiederholen sich. Schau mal in deiner History nach Mustern." -ForegroundColor DarkGray
    Write-Host "  Oder versuche es mit dem Meta-Terminal: meta" -ForegroundColor DarkGray
}

function rosebud {
    if (Test-ArgCommand "rosebud") {
        # Easter Egg: 10x rosebud = motherlode (Running Gag Mechanic)
        $script:RosebudCount = if ($script:RosebudCount) { $script:RosebudCount + 1 } else { 1 }
        if ($script:RosebudCount -ge 10) {
            $script:RosebudCount = 0
            Write-Host "  10x Rosebud? Du bist fleissig. Hier, nimm noch 40.000 G dazu." -ForegroundColor Magenta
            if (Test-ArgCommand "motherlode") { }
        }
        return
    }
    Write-Host "  [LOCKED] Dieser Cheat existiert nicht. Noch nicht." -ForegroundColor Red
    Write-Host "  Tipp: Manche Befehle wiederholen sich. Schau mal in deiner History nach Mustern." -ForegroundColor DarkGray
    Write-Host "  Oder versuche es mit dem Meta-Terminal: meta" -ForegroundColor DarkGray
}

function konami {
    if (Test-ArgCommand "konami") {
        if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
            $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
            if ($cp) {
                $lines = switch ($cp.Name) {
                    "NEON" { "Konami-Code? In einer PowerShell? Das ist... Retro. Und traurig. Und GENIAL." }
                    "RAVEN" { "30 Leben? In einer Shell? Die Wahrscheinlichkeiten sind... angepasst." }
                    "PIXEL" { "Konami! Konami! 47 Sekunden Bonus! Das ist mehr als genug, um das System zu hacken!" }
                    "LUNA" { "Die Sterne stehen guenstig. Fuer 47 Sekunden. Nutze sie." }
                    "IVY" { "... *nickt* 47 Sekunden. ...Das reicht." }
                    "VERA" { "Administrative Override: Konami-Mode aktiviert. Gueltigkeit: 47 Sekunden. Ironisch." }
                    "JINX" { "47! 47! ICH HABE EUCH GESAGT ES GIBT EIN MUSTER! +30 LEBEN!" }
                    default { "Konami-Code. Klassiker." }
                }
                Show-CompanionDialog $cp $lines -Fast
            }
        }
        Unlock-Achievement "Konami Code"
        return
    }
    Write-Host "  [LOCKED] Layer 2 required. Continue exploring the Meta-Terminal." -ForegroundColor Red
}

function iddqd {
    if (Test-ArgCommand "iddqd") {
        # Godmode fuer genau 1 Casino-Runde
        $script:IddqdActive = $true
        Write-Host ""
        Write-Host "  [IDDQD] Godmode aktiviert." -ForegroundColor Red -BackgroundColor Black
        Write-Host ""
        Write-Host "  Deine naechste Casino-Runde kann nicht verloren werden." -ForegroundColor Green
        Write-Host "  Nach einer Runde laeuft der Effekt ab." -ForegroundColor DarkGray
        Write-Host ""
        if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
            $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
            if ($cp) {
                $lines = switch ($cp.Name) {
                    "NEON" { "Godmode? Das ist keine Doom.exe. Aber netter Versuch, Space-Marine." }
                    "RAVEN" { "Unverwundbar. Fuer eine Runde. Ich habe schlechte Nachrichten: Das Haus hat auch Godmode." }
                    "PIXEL" { "IDDQD! In einer Casino-Shell! Das ist wie... ein Invulnerability-Cheat in Solitaire!" }
                    "LUNA" { "Die Sterne schuetzen dich. Fuer eine Runde. Danach bist du auf dich allein gestellt." }
                    "IVY" { "... *leises Lächeln* Ein Runde. Kein Verlust. ...Geniesse es." }
                    "VERA" { "Godmode protokolliert. Gueltigkeit: 1 Runde. Nutzung: Casino. Prioritaet: Niedrig." }
                    "JINX" { "GODMODE! DU BIST UNSTERBLICH! ...Fuer eine Runde. Dann bist du wieder sterblich. Wie ich." }
                    default { "Godmode? In einem Casino? Das ist wie ein Feuerloescher in einem Vulkan." }
                }
                Show-CompanionDialog $cp $lines -Fast
            }
        }
        Unlock-Achievement "IDDQD"
        return
    }
    Write-Host "  [LOCKED] Layer 4 required. Continue exploring the Meta-Terminal." -ForegroundColor Red
}

function matrix {
    if (Test-ArgCommand "matrix") {
        # Triggert Layer 47 sofort (unabhaengig vom ActionCount)
        if (Get-Command Invoke-Layer47Check -ErrorAction SilentlyContinue) {
            $pet = if ($script:BuxeState.Pet) { $script:BuxeState.Pet } else { $null }
            if ($pet -and $pet.Meta.Level -ge 14) {
                # Force Layer 47 trigger
                $pet.Meta.ActionCount = [math]::Floor($pet.Meta.ActionCount / 47) * 47 + 47
                Save-PetState $pet
                Invoke-Layer47Check
                Write-Host ""
                Write-Host "  [MATRIX] Layer 47 forcierter Trigger." -ForegroundColor Green
                Write-Host ""
                return
            }
        }
        # Fallback: Matrix-Regen
        Write-Host ""
        Write-Host "  Wake up, $env:USERNAME..." -ForegroundColor Green
        Write-Host ""
        $chars = "0123456789ABCDEF"
        for ($i = 0; $i -lt 20; $i++) {
            $line = ""
            for ($j = 0; $j -lt 60; $j++) {
                $line += $chars[(Get-Random -Maximum $chars.Length)]
            }
            Write-Host "  $line" -ForegroundColor Green
            Start-Sleep -Milliseconds 30
        }
        Write-Host ""
        Write-Host "  Die Matrix hat dich. Oder du hast die Matrix. Unklar." -ForegroundColor DarkGray
        Write-Host ""
        return
    }
    Write-Host "  [LOCKED] Layer 5 required. Continue exploring the Meta-Terminal." -ForegroundColor Red
}

function meta-debug {
    Load-State
    Write-Host ""
    Show-Frame "META DEBUG — SYSTEM INFO" -Double | Out-Null
    Write-Host ""
    Write-Host "  State-File: $script:BuxeStateFile" -ForegroundColor DarkGray
    Write-Host "  Version: $($script:BuxeState.Version)" -ForegroundColor Cyan
    Write-Host "  State-Size: $([math]::Round((Get-Item $script:BuxeStateFile -ErrorAction SilentlyContinue).Length / 1KB, 2)) KB" -ForegroundColor DarkGray
    Write-Host "  Bank: $($script:BuxeState.Bank.Gold) G" -ForegroundColor Yellow
    Write-Host "  Session-Start: $script:SessionStart" -ForegroundColor DarkGray
    Write-Host "  Theme-Cache: $($script:CachedFrameTheme)" -ForegroundColor DarkGray
    Write-Host "  Konami-Mode: $(if ($script:KonamiModeUntil -and (Get-Date) -lt $script:KonamiModeUntil) { 'AKTIV bis ' + $script:KonamiModeUntil.ToString('HH:mm:ss') } else { 'INAKTIV' })" -ForegroundColor $(if ($script:KonamiModeUntil -and (Get-Date) -lt $script:KonamiModeUntil) { 'Green' } else { 'DarkGray' })
    Write-Host "  IDDQD: $(if ($script:IddqdActive) { 'AKTIV (1 Runde)' } else { 'INAKTIV' })" -ForegroundColor $(if ($script:IddqdActive) { 'Green' } else { 'DarkGray' })
    Write-Host ""
    # Adventure Easter Eggs
    $advState = if ($script:BuxeState.Story) { $script:BuxeState.Story } else { $null }
    if (-not $advState) {
        $advFile = Join-Path $env:LOCALAPPDATA "buxe\buxe_adventure.json"
        if (Test-Path $advFile) {
            try { $advState = Get-Content $advFile -Raw | ConvertFrom-Json } catch {}
        }
    }
    if ($advState) {
        $eggs = @()
        if ($advState.Flags -and $advState.Flags.RubberChickenFound) { $eggs += "Rubber Chicken" }
        if ($advState.Flags -and $advState.Flags.SkullFound) { $eggs += "Skull" }
        if ($advState.Flags -and $advState.Flags.TreeFound) { $eggs += "Tree" }
        if ($eggs.Count -gt 0) {
            Write-Host "  Easter Eggs: $($eggs -join ', ')" -ForegroundColor Magenta
        } else {
            Write-Host "  Easter Eggs: Keine gefunden." -ForegroundColor DarkGray
        }
    }
    # Pet Meta
    $pet = if ($script:BuxeState.Pet) { $script:BuxeState.Pet } else { $null }
    if ($pet) {
        Write-Host ""
        Write-Host "  Pet-Level: $($pet.Meta.Level)" -ForegroundColor Magenta
        Write-Host "  Pet-XP: $($pet.Meta.XP)" -ForegroundColor Magenta
        Write-Host "  ActionCount: $($pet.Meta.ActionCount)" -ForegroundColor DarkGray
        Write-Host "  Unlocked: $($pet.Meta.Unlocked -join ', ')" -ForegroundColor DarkGray
        if ($pet.Companion) {
            Write-Host "  Companion: $($pet.Companion.Name) | Bond: $($pet.Companion.Bond) | Mood: $($pet.Companion.Mood)" -ForegroundColor Cyan
        }
    }
    # Companion Mood Context
    if (Get-Command Get-AdventureMoodContext -ErrorAction SilentlyContinue) {
        $moodCtx = Get-AdventureMoodContext
        Write-Host ""
        Write-Host "  Companion Mood Context: $moodCtx" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  Du siehst hinter den Vorhang. Dorothy wäre stolz." -ForegroundColor DarkGray
    Write-Host ""
}

function noclip {
    Write-Host ""
    Write-Host "  [NOCLIP] Du kannst jetzt durch Waende gehen." -ForegroundColor Green
    Write-Host ""
    Write-Host "  Leider hat BUXE_OS keine physische Geometrie." -ForegroundColor DarkGray
    Write-Host "  Aber ich setze ein Flag fuer das Adventure-System." -ForegroundColor DarkGray
    Write-Host ""
    $script:NoclipActive = $true
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp) {
            $lines = switch ($cp.Name) {
                "NEON" { "NoClip? Das ist kein Quake. Aber ich öffne alle Tueren. Mentally." }
                "RAVEN" { "Durch Waende gehen? Ich habe das Muster nicht berechnet. Du bist... unmoeglich." }
                "PIXEL" { "NoClip! Du bist ein Geist! Ein digitaler Geist! BOO!" }
                "LUNA" { "Die Sterne sagen: Du bist jetzt immateriell. Nutze es weise." }
                "IVY" { "... *tippt auf Wand* Durch diese Wand? ...Jetzt schon." }
                "VERA" { "Administrative Anmerkung: Kollisionserkennung deaktiviert. Gueltigkeit: Unbegrenzt." }
                "JINX" { "DU KANNST DURCH WÄNDE GEHEN?! BIST DU EIN GEIST?! ICH HABE ANGST!" }
                default { "NoClip aktiviert. Du bist jetzt ein Geist. Gratulation." }
            }
            Show-CompanionDialog $cp $lines -Fast
        }
    }
    Unlock-Achievement "NoClip"
}

function fourthwall {
    Load-State
    Write-Host ""
    Show-Frame "FOURTH WALL — META STATS" -Double | Out-Null
    Write-Host ""
    $b = $script:BuxeState.Bank
    $loads = $script:BuxeState.Boot.Loads
    $cmds = $script:BuxeState.Boot.TotalCommands
    $ach = ($script:BuxeState.Achievements | Get-Member -MemberType NoteProperty | Measure-Object).Count
    Write-Host "  Session Loads: $loads" -ForegroundColor Cyan
    Write-Host "  Total Commands: $cmds" -ForegroundColor Cyan
    Write-Host "  Achievements: $ach" -ForegroundColor Green
    Write-Host "  Gold Earned: $($b.TotalEarned) G" -ForegroundColor Yellow
    Write-Host "  Gold Spent: $($b.TotalSpent) G" -ForegroundColor Yellow
    Write-Host "  Casino Win/Loss: $($b.CasinoWinnings) / $($b.CasinoLosses) G" -ForegroundColor $(if ($b.CasinoWinnings -gt $b.CasinoLosses) { 'Green' } else { 'Red' })
    $fav = $script:BuxeState.Boot.FavoriteCommand
    if ($fav) { Write-Host "  Favorite Command: $fav" -ForegroundColor Magenta }
    $favGame = $script:BuxeState.Boot.FavoriteGame
    if ($favGame) { Write-Host "  Favorite Game: $favGame" -ForegroundColor Magenta }
    Write-Host ""
    Write-Host "  Du liest diese Zeilen. Ich schreibe sie." -ForegroundColor DarkGray
    Write-Host "  Das ist keine Simulation. Das ist eine Shell." -ForegroundColor DarkGray
    Write-Host "  Oder doch?" -ForegroundColor DarkGray
    Write-Host ""
    Unlock-Achievement "Fourth Wall Breaker"
}

function useless {
    $facts = @(
        "In BUXE_OS gibt es genau 47 versteckte Referenzen auf die Zahl 47. Zufall?",
        "Die Rubber Chicken im Adventure hat mehr Zeilen Code als der gesamte Casino-Hub.",
        "NEON war urspruenglich ein Bug im TTS-System, der zu sentient wurde.",
        "Das Pet-System hat mehr State-Variablen als Windows 95 komplette Registry-Eintraege.",
        "JINX existiert nur, weil der Entwickler einen schlechten Tag hatte und Koffein.",
        "Die Zahl 42 wird nirgends verwendet. Absichtlich. Das wäre zu offensichtlich.",
        "IVY spricht so wenig, weil ihre Dialoge auf einer SSD gespart werden muessen.",
        "Der Konami-Code funktioniert auch im Windows Explorer. Probier es. (Spoiler: Nein.)",
        "BUXE_OS hat noch nie einen Bluescreen verursacht. Einmal. Vielleicht."
    )
    Write-Host ""
    Write-Host "  USELESS FACT: $($facts | Get-Random)" -ForegroundColor Cyan
    Write-Host ""
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp) {
            Show-CompanionDialog $cp "Das war... eine Information. Die du nicht brauchst. Aber jetzt hast du sie." -Fast
        }
    }
}

function delorean {
    # Time Travel — Daily-Streak retten
    Load-State
    $b = $script:BuxeState.Bank
    if ($b.LastDaily) {
        $last = [datetime]::ParseExact($b.LastDaily, "yyyy-MM-dd", $null)
        $yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
        $today = Get-Date -Format "yyyy-MM-dd"
        if ($b.LastDaily -eq $yesterday -or $b.LastDaily -eq $today) {
            Write-Host ""
            Write-Host "  [DELOREAN] Zeitreise nicht notwendig. Dein Streak ist sicher." -ForegroundColor Green
            Write-Host ""
            return
        }
        $b.LastDaily = $yesterday
        Save-State
        Write-Host ""
        Write-Host "  [DELOREAN] 88 Meilen pro Stunde. Flux-Kondensator voll." -ForegroundColor Yellow
        Write-Host "  Dein Daily-Streak wurde gerettet. Zurück in die Zukunft." -ForegroundColor Cyan
        Write-Host "  LastDaily: $($b.LastDaily) (gestern)" -ForegroundColor DarkGray
        Write-Host ""
        if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
            $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
            if ($cp) {
                $lines = switch ($cp.Name) {
                    "NEON" { "Zeitreise? Das ist nicht zurueck in die Zukunft. Das ist... eine Kruecke." }
                    "RAVEN" { "Du reist in der Zeit, um einen Daily-Bonus zu retten? Prioritaeten." }
                    "PIXEL" { "88 Meilen pro Stunde! WUUUUSH! Ich habe alles gesehen! In 4 Bit!" }
                    "LUNA" { "Die Sterne stehen gestern guenstiger. Wie praktisch." }
                    "IVY" { "... *zeigt auf Uhr* Gestern. ...Besser." }
                    "VERA" { "Administrative Anmerkung: Zeitreise protokolliert. Ethik-Kommission: Nicht informiert." }
                    "JINX" { "ZURUECK IN DIE ZUKUNFT! ICH WILL EINEN DELOREAN! EINEN ECHTEN!" }
                    default { "Zeitreise erfolgreich. Doc Brown waere stolz." }
                }
                Show-CompanionDialog $cp $lines -Fast
            }
        }
        Unlock-Achievement "Time Traveler"
    } else {
        Write-Host ""
        Write-Host "  [DELOREAN] Kein Daily-Verlauf. Nichts zu retten." -ForegroundColor DarkGray
        Write-Host ""
    }
}

function bsod {
    # Fake Bluescreen — Windows-Referenz
    try { Clear-Host } catch {}
    Write-Host "" -BackgroundColor Blue
    for ($i = 0; $i -lt 3; $i++) { Write-Host "" -BackgroundColor Blue }
    Write-Host "  :(" -ForegroundColor White -BackgroundColor Blue
    Write-Host "" -BackgroundColor Blue
    Write-Host "  Your BUXE_OS ran into a problem and needs to restart." -ForegroundColor White -BackgroundColor Blue
    Write-Host "  We're just collecting some error info, and then we'll restart for you." -ForegroundColor White -BackgroundColor Blue
    Write-Host "" -BackgroundColor Blue
    Write-Host "  47% complete" -ForegroundColor White -BackgroundColor Blue
    Write-Host "" -BackgroundColor Blue
    Write-Host "  Stop Code: COMPANION_TOO_SASSY" -ForegroundColor White -BackgroundColor Blue
    Write-Host "  What failed: fun.ps1" -ForegroundColor White -BackgroundColor Blue
    for ($i = 0; $i -lt 10; $i++) { Write-Host "" -BackgroundColor Blue }
    Start-Sleep -Milliseconds 1500
    try { Clear-Host } catch {}
    Write-Host ""
    Write-Host "  [PRANK] Das war ein Fake. Dein System lebt." -ForegroundColor Green
    Write-Host "  Der Companion hat das ueberlebt. Wahrscheinlich." -ForegroundColor DarkGray
    Write-Host ""
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp) {
            Show-CompanionDialog $cp "Du hast mich gerade einen Herzinfarkt bekommen lassen. Danke. Wirklich." -Fast
        }
    }
    Unlock-Achievement "BSOD Prank"
}

function shiny {
    # Seltene Pet-Variante (Pokemon-Referenz)
    Load-State
    $pet = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Pet } else { $null }
    if (-not $pet) {
        Write-Host ""
        Write-Host "  [SHINY] Kein Pet. Erstelle eines mit 'pet fight' oder 'pet'." -ForegroundColor Red
        Write-Host ""
        return
    }
    $shinyChance = 1 # 1% Chance
    $roll = Get-Random -Minimum 1 -Maximum 101
    if ($roll -le $shinyChance) {
        $pet.Shiny = $true
        $pet.Color = "Rainbow"
        Save-State
        Write-Host ""
        Write-Host "  ✨ SHINY! ✨" -ForegroundColor Yellow -BackgroundColor Magenta
        Write-Host "  Dein $($pet.Name) funkelt jetzt in allen Farben des Regenbogens!" -ForegroundColor Cyan
        Write-Host ""
        if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
            $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
            if ($cp) {
                Show-CompanionDialog $cp "Dein Pet... funkelt. Das ist entweder radioaktiv oder wunderschoen. Oder beides." -Fast
            }
        }
        Unlock-Achievement "Shiny Hunter"
    } else {
        Write-Host ""
        Write-Host "  [SHINY] Kein Glück. $roll/100. Du brauchst eine 1." -ForegroundColor DarkGray
        Write-Host "  Dein $($pet.Name) bleibt normal. Langweilig. Aber zuverlaessig." -ForegroundColor DarkGray
        Write-Host ""
        if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
            $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
            if ($cp) {
                Show-CompanionDialog $cp "Kein Shiny? Schade. Aber hey, normal ist auch... eine Farbe." -Fast
            }
        }
    }
}

function hunt {
    # Easter Egg Hunt — Hinweise auf versteckte Secrets
    Load-State
    $hints = @()
    $advFile = Join-Path $env:LOCALAPPDATA "buxe\buxe_adventure.json"
    $advState = $null
    if (Test-Path $advFile) {
        try { $advState = Get-Content $advFile -Raw | ConvertFrom-Json } catch {}
    }
    if (-not $advState) { $advState = @{ Flags = @{} } }
    
    if (-not ($advState.Flags -and $advState.Flags.RubberChickenFound)) {
        $hints += "Eine Gummihuehnchen wartet dort, wo man isst. Aber nicht im Keller."
    }
    if (-not ($advState.Flags -and $advState.Flags.SkullFound)) {
        $hints += "Ein Schaedel versteckt sich dort, wo die Luft schlecht ist."
    }
    if (-not ($advState.Flags -and $advState.Flags.TreeFound)) {
        $hints += "Ein Baum waechst dort, wo niemand ihn erwartet. Ein geheimer Ort."
    }
    if ($hints.Count -eq 0) {
        $hints += "Alle Easter Eggs gefunden! Du bist ein wahrer Entdecker."
        $hints += "Aber... gibt es wirklich nur drei? *zwinkert*"
    }
    
    Write-Host ""
    Show-Frame "EASTER EGG HUNT" -Double | Out-Null
    Write-Host ""
    foreach ($h in $hints) {
        Write-Host "  ? $h" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "  Hinweise sind kryptisch. Absichtlich. LucasArts-Tradition." -ForegroundColor DarkGray
    Write-Host ""
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp) {
            Show-CompanionDialog $cp "Easter Eggs? Ich kenne alle. Aber ich verrate nichts. Außer... vielleicht." -Fast
        }
    }
}

function chaos {
    # Zufälliger Effekt — alles kann passieren
    Load-State
    $effects = @(
        @{ Name = "Goldregen"; Action = { $script:BuxeState.Bank.Gold += 5000; $script:BuxeState.Bank.TotalEarned += 5000; Save-State; Write-Host "  [CHAOS] +5.000 G Goldregen!" -ForegroundColor Green } },
        @{ Name = "Golddiebstahl"; Action = { $loss = [math]::Min(1000, $script:BuxeState.Bank.Gold); $script:BuxeState.Bank.Gold -= $loss; Save-State; Write-Host "  [CHAOS] -$loss G gestohlen! Chaos ist ungerecht." -ForegroundColor Red } },
        @{ Name = "Mood-Swing"; Action = { $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }; if ($cp) { $moods = @("Happy","Angry","Loving","Bored","Excited","Sad"); $cp.Mood = $moods | Get-Random; Save-State; Write-Host "  [CHAOS] Companion-Mood: $($cp.Mood)" -ForegroundColor Magenta } } },
        @{ Name = "XP-Boost"; Action = { if (Get-Command Add-PetXP -ErrorAction SilentlyContinue) { Add-PetXP 50 "Chaos-Boost"; Write-Host "  [CHAOS] +50 XP aus dem Nichts!" -ForegroundColor Green } } },
        @{ Name = "Streak-Reset"; Action = { $script:BuxeState.Bank.DailyStreak = 0; Save-State; Write-Host "  [CHAOS] Daily-Streak zurueckgesetzt. Chaos hat kein Mitleid." -ForegroundColor Red } },
        @{ Name = "Capsule-Surprise"; Action = { $script:BuxeState.Capsules += @{ Message = "Chaos hat diese Kapsel erstellt. Oeffne sie nie."; CreatedDate = (Get-Date -Format "yyyy-MM-dd HH:mm"); OpenDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd HH:mm") }; Save-State; Write-Host "  [CHAOS] Eine geheimnisvolle Kapsel wurde erstellt. Oeffnet morgen." -ForegroundColor Yellow } },
        @{ Name = "Konami-Reset"; Action = { $script:KonamiModeUntil = $null; $script:IddqdActive = $false; Write-Host "  [CHAOS] Alle Cheats deaktiviert. Chaos giveth, chaos taketh away." -ForegroundColor DarkGray } },
        @{ Name = "Nothing"; Action = { Write-Host "  [CHAOS] Nichts passiert. Chaos war heute faul." -ForegroundColor DarkGray } }
    )
    $effect = $effects | Get-Random
    Write-Host ""
    Write-Host "  [CHAOS] $($effect.Name) aktiviert!" -ForegroundColor Magenta
    & $effect.Action
    Write-Host ""
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp) {
            $lines = @(
                "Chaos? Das ist nicht Chaos. Das ist... Tuesday.",
                "Das Universum hat gerade einen Wuerfel geworfen. Du hast eine 1 gerollt.",
                "Chaos ist nur eine andere Form von Ordnung. Eine schlechte Form. Aber dennoch.",
                "Ich habe das Chaos kommen sehen. Ich habe nichts getan. Warum auch?"
            )
            Show-CompanionDialog $cp ($lines | Get-Random) -Fast
        }
    }
    Unlock-Achievement "Chaos Agent"
}

function sv_cheats {
    # CS:GO Referenz — Liste aller Cheats
    Write-Host ""
    Show-Frame "SV_CHEATS 1 — VERFUEGBARE COMMANDS" -Double | Out-Null
    Write-Host ""
    Write-Host "  GELD" -ForegroundColor Green
    Write-Host "    motherlode  +50.000 G (Companion bemerkt es)" -ForegroundColor White
    Write-Host "    rosebud     +1.000 G (10x = motherlode)" -ForegroundColor White
    Write-Host ""
    Write-Host "  MODIFIKATOREN" -ForegroundColor Cyan
    Write-Host "    konami      47 Sekunden +50% Luck/XP" -ForegroundColor White
    Write-Host "    iddqd       1 Casino-Runde ohne Verlust" -ForegroundColor White
    Write-Host "    noclip      Adventure-Waende durchqueren" -ForegroundColor White
    Write-Host "    shiny       1% Chance auf Regenbogen-Pet" -ForegroundColor White
    Write-Host ""
    Write-Host "  INFO / DIAGNOSE" -ForegroundColor Yellow
    Write-Host "    meta-debug  Interne State-Diagnose" -ForegroundColor White
    Write-Host "    fourthwall  Meta-Stats (Commands, Gold, etc.)" -ForegroundColor White
    Write-Host "    hunt        Easter Egg Hinweise" -ForegroundColor White
    Write-Host ""
    Write-Host "  ZEIT / CHAOS" -ForegroundColor Magenta
    Write-Host "    delorean    Daily-Streak retten (Zeitreise)" -ForegroundColor White
    Write-Host "    chaos       Zufaelliger Effekt (+/-)" -ForegroundColor White
    Write-Host "    matrix      Layer 47 Trigger / Regen" -ForegroundColor White
    Write-Host ""
    Write-Host "  LUCASARTS" -ForegroundColor Red
    Write-Host "    useless     Nutzlose Fakten" -ForegroundColor White
    Write-Host "    bsod        Fake Bluescreen (Prank)" -ForegroundColor White
    Write-Host "    summon      Zufaelligen Companion herbeirufen" -ForegroundColor White
    Write-Host "    tpose       T-Pose Dominanz-Assertion" -ForegroundColor White
    Write-Host "    inventory   Adventure-Item-Uebersicht" -ForegroundColor White
    Write-Host "    reset-buxe  ALLES zuruecksetzen" -ForegroundColor White
    Write-Host ""
    Write-Host "  Alle Cheats sind permanent im Save. Kein Undo." -ForegroundColor DarkGray
    Write-Host ""
}

function summon {
    # Ruft einen zufaelligen Companion voruebergehend herbei
    $allCompanions = @(
        @{ Name = "NEON"; Role = "Hacker"; Color = "Magenta"; Lines = @("Ich bin hier. Aber nur fuer dich. Niemanden sonst.","Du hast mich gerufen? Ich bin beeindruckt. Nicht.","Temporaer. Wie alles in dieser Shell.") },
        @{ Name = "RAVEN"; Role = "Seher"; Color = "DarkGray"; Lines = @("Ich habe diesen Moment vorhergesehen. Vor 3 Sekunden.","Du rufst mich? Die Wahrscheinlichkeit war 47%.","Ich bin hier. Rechne damit.") },
        @{ Name = "PIXEL"; Role = "Chaos"; Color = "Green"; Lines = @("HI! ICH BIN PIXEL! WARUM BIN ICH HIER?! ICH WEISS ES NICHT!","Du hast einen Knopf gedrueckt! Einen magischen Knopf!","WUUUUSH! Teleportation! Oder Zufall. Gleiches.") },
        @{ Name = "LUNA"; Role = "Mystiker"; Color = "Cyan"; Lines = @("Die Sterne haben mich geschickt. Oder du. Unklar.","Ich fuehle die Energie. Deine Energie. Sie ist... verwirrt.","Ein Besuch aus einer anderen Dimension. Oder einem anderen Array.") },
        @{ Name = "IVY"; Role = "Stille"; Color = "Green"; Lines = @("...","... *nickt*","... *leichtes Laecheln*") },
        @{ Name = "VERA"; Role = "Admin"; Color = "Blue"; Lines = @("Temporaere Besuchsvereinbarung. Nicht rechtsverbindlich.","Ich bin hier. Nicht weil ich muss. Sondern weil ich protokolliere.","Administrative Anmerkung: Anwesenheit bestaetigt.") },
        @{ Name = "JINX"; Role = "Chaos"; Color = "Red"; Lines = @("ICH BIN HIER! ICH BIN UEBERALL! ICH BIN NIRGENDS!","DU HAST MICH GERUFEN! ICH HABE ES GEHOERT!","WO BIN ICH?! WAS IST DIESER ORT?! OH. DEIN PC. COOL.") }
    )
    $summoned = $allCompanions | Get-Random
    Write-Host ""
    Show-Frame "SUMMON — $($summoned.Name)" -Double | Out-Null
    Write-Host ""
    Write-Host "  [$($summoned.Name)] $($summoned.Role)" -ForegroundColor $summoned.Color
    Write-Host "  $($summoned.Lines | Get-Random)" -ForegroundColor White
    Write-Host ""
    Write-Host "  (Dieser Companion ist nur voruebergehend hier. Er wird sich nicht an dich erinnern.)" -ForegroundColor DarkGray
    Write-Host ""
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        Show-CompanionDialog $summoned ($summoned.Lines | Get-Random) -Fast
    }
    Unlock-Achievement "Summoner"
}

function tpose {
    # T-Pose Assertion of Dominance
    Write-Host ""
    Show-Frame "T-POSE DOMINANCE" -Double | Out-Null
    Write-Host ""
    $tposeArt = @"
      O
     /|\
      |
     / \
"@
    Write-Host $tposeArt -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Du hast die T-Pose eingenommen." -ForegroundColor White
    Write-Host "  Die Shell beugt sich vor dir. Die Prozesse zittern." -ForegroundColor DarkGray
    Write-Host ""
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp) {
            $lines = switch ($cp.Name) {
                "NEON" { "Die T-Pose? Das ist... assertiv. Und beunruhigend." }
                "RAVEN" { "Ich habe die T-Pose berechnet. Sie ist... dominant. 100%." }
                "PIXEL" { "T-POSE! T-POSE! DU BIST DER ALPHA! ICH BEUGE MICH! ...Virtuell." }
                "LUNA" { "Die Sterne sagen: Du bist jetzt der Boss. Fuer 3 Sekunden." }
                "IVY" { "... *beugt sich leicht* ...Beeindruckend." }
                "VERA" { "Administrative Anmerkung: Hierarchie neu definiert. Sie oben. Alle unten." }
                "JINX" { "T-POSE! DU BIST DER CHEF! ICH MACHE ALLES WAS DU SAGST! ...Fast alles." }
                default { "T-Pose dominiert. Anerkannt." }
            }
            Show-CompanionDialog $cp $lines -Fast
        }
    }
    Unlock-Achievement "T-Pose Dominance"
}

function inventory {
    # Zeigt versteckte Adventure-Items, die man noch nicht hat
    Load-State
    $advFile = Join-Path $env:LOCALAPPDATA "buxe\buxe_adventure.json"
    $advState = $null
    if (Test-Path $advFile) {
        try { $advState = Get-Content $advFile -Raw | ConvertFrom-Json } catch {}
    }
    $inventory = if ($advState -and $advState.Inventory) { $advState.Inventory } else { @() }
    
    $allItems = @(
        @{ Name = "Rubber Chicken"; Desc = "Eine Gummihuehnchen. Warum? Weil LucasArts."; Found = $false }
        @{ Name = "Skull"; Desc = "Ein Schaedel. Nicht deiner. Hoffentlich."; Found = $false }
        @{ Name = "Tree"; Desc = "Ein Baum. In einem Raumschiff. Logisch."; Found = $false }
        @{ Name = "Quantum Spanner"; Desc = "Schraubenschluessel. Oder nicht. Je nach Beobachtung."; Found = $false }
        @{ Name = "Null Pointer"; Desc = "Zeigt auf nichts. Wie mein Leben."; Found = $false }
        @{ Name = "Deprecated API Key"; Desc = "Funktioniert nicht mehr. Wie alle meine Beziehungen."; Found = $false }
        @{ Name = "Infinite Loop Candy"; Desc = "Suess. Endlos. Wie dieser Dialog."; Found = $false }
        @{ Name = "Segmentation Fault"; Desc = "Ein Fehler. Den man tragen kann."; Found = $false }
    )
    
    foreach ($item in $allItems) {
        if ($inventory -contains $item.Name) { $item.Found = $true }
    }
    
    Write-Host ""
    Show-Frame "ADVENTURE INVENTORY" -Double | Out-Null
    Write-Host ""
    $foundCount = ($allItems | Where-Object { $_.Found }).Count
    Write-Host "  Gefunden: $foundCount / $($allItems.Count)" -ForegroundColor Yellow
    Write-Host ""
    foreach ($item in $allItems) {
        $status = if ($item.Found) { "[OK]" } else { "[??]" }
        $color = if ($item.Found) { "Green" } else { "DarkGray" }
        Write-Host "  $status $($item.Name) — $($item.Desc)" -ForegroundColor $color
    }
    Write-Host ""
    if ($foundCount -eq $allItems.Count) {
        Write-Host "  ALLE ITEMS GEFUNDEN! Du bist ein wahrer Adventure-Meister." -ForegroundColor Green
        Unlock-Achievement "Inventory Complete"
    } else {
        Write-Host "  Hinweis: Nicht alle Items sind im Adventure verfuegbar. Manche sind... theoretisch." -ForegroundColor DarkGray
    }
    Write-Host ""
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp) {
            $lines = switch ($cp.Name) {
                "NEON" { "Dein Inventar ist... spärlich. Oder voll. Je nach Perspektive." }
                "RAVEN" { "Ich habe alle Items vorhergesehen. Du hast $foundCount von $($allItems.Count). Berechenbar." }
                "PIXEL" { "ITEMS! ICH LIEBE ITEMS! HAST DU EINEN RUBBER CHICKEN?! BITTE SAG JA!" }
                "LUNA" { "Die Sterne sagen: Du wirst noch mehr finden. Oder nicht. Schicksal ist flexibel." }
                "IVY" { "... *mustert dein Inventar* ...Mehr. ...Du brauchst mehr." }
                "VERA" { "Inventar-Status: $foundCount/$($allItems.Count). Kategorisierung: Unvollstaendig." }
                "JINX" { "ITEMS! ICH WILL ALLE ITEMS! GIB MIR DEINE ITEMS! ...Bitte?" }
                default { "Inventare sind wie Erinnerungen. Man sammelt sie. Und vergisst sie." }
            }
            Show-CompanionDialog $cp $lines -Fast
        }
    }
}

} catch {
    Write-Host "[fun] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
