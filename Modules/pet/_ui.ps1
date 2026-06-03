# BUXE_OS v24.2 — PET UI & DIALOG ENGINE v2.0
# LucasArts-Style Frames, Companion Dialogs, Easter Eggs

try {

$script:CPNames = @("NEON","RAVEN","PIXEL","LUNA","IVY","VERA")
$script:CPRoles = @("NETRUNNER","ENFORCER","ENGINEER","MEDIC","STEALTH","HACKER")
$script:CPColors = @("Cyan","Red","Magenta","Green","DarkGray","Yellow")
$script:CPQuotes = @{
    NEON  = @{ Low = @("Ugh, du schon wieder?","Versuch, nichts kaputt zu machen."); Med = @("Nicht schlecht, User.","Du wirst besser."); High = @("Ich bin stolz auf dich!","Du bist unglaublich!") }
    RAVEN = @{ Low = @("Schwächling.","Verschwende nicht meine Zeit."); Med = @("Stärker.","Akzeptable Leistung."); High = @("Du bist jetzt mein Equal.","Zusammen sind wir unaufhaltsam!") }
    PIXEL = @{ Low = @("Oh... hallo.","Sei vorsichtig."); Med = @("Du machst das toll!","Ich glaube an dich."); High = @("Du bist der Beste!","Wir sind ein super Team!") }
    LUNA  = @{ Low = @("Bitte sei vorsichtig.","Ich will dich nicht wieder flicken."); Med = @("Du bleibst gesund. Gut.","Schöner Ausweichschritt."); High = @("Ich lasse nichts dir passieren.","Für immer zusammen, okay?") }
    IVY   = @{ Low = @("...","Ich sehe dich."); Med = @("Du bist leise. Ich mag das.","Gute Reflexe."); High = @("Ich habe deinen Rücken. Immer.","Du und ich gegen die Welt.") }
    VERA  = @{ Low = @("Syntaxfehler im ersten Blick.","Dein Code riecht."); Med = @("Nicht schlecht. Für einen Menschen.","Ich hätte das in 3 Zeilen gelöst."); High = @("Wir sind ein Dreamteam. Binary + Brain.","Du debuggst wie ein Profi.") }
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
