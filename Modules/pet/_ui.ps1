# BUXE_OS v24.2 — PET UI & DIALOG ENGINE v2.0
# LucasArts-Style Frames, Companion Dialogs, Easter Eggs

try {

$script:CPNames = @("NEON","RAVEN","PIXEL","LUNA","IVY")
$script:CPRoles = @("NETRUNNER","ENFORCER","ENGINEER","MEDIC","STEALTH")
$script:CPColors = @("Cyan","Red","Magenta","Green","DarkGray")
$script:CPQuotes = @{
    NEON  = @{ Low = @("Ugh, du schon wieder?","Versuch, nichts kaputt zu machen."); Med = @("Nicht schlecht, User.","Du wirst besser."); High = @("Ich bin stolz auf dich!","Du bist unglaublich!") }
    RAVEN = @{ Low = @("Schwächling.","Verschwende nicht meine Zeit."); Med = @("Stärker.","Akzeptable Leistung."); High = @("Du bist jetzt mein Equal.","Zusammen sind wir unaufhaltsam!") }
    PIXEL = @{ Low = @("Oh... hallo.","Sei vorsichtig."); Med = @("Du machst das toll!","Ich glaube an dich."); High = @("Du bist der Beste!","Wir sind ein super Team!") }
    LUNA  = @{ Low = @("Bitte sei vorsichtig.","Ich will dich nicht wieder flicken."); Med = @("Du bleibst gesund. Gut.","Schöner Ausweichschritt."); High = @("Ich lasse nichts dir passieren.","Für immer zusammen, okay?") }
    IVY   = @{ Low = @("...","Ich sehe dich."); Med = @("Du bist leise. Ich mag das.","Gute Reflexe."); High = @("Ich habe deinen Rücken. Immer.","Du und ich gegen die Welt.") }
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
        default {
            $lines = $script:CPMoodLines[$mood]
            if (-not $lines) { $lines = $script:CPMoodLines.Happy }
        }
    }
    return $lines | Get-Random
}

function Check-EasterEgg($Context) {
    $pet = Get-PetState
    $hour = (Get-Date).Hour
    $found = @()
    if ($Context -eq "login" -and $hour -ge 2 -and $hour -le 4) {
        $found += "3am_login"
        Show-CompanionDialog $pet.Companion "Es ist 3 Uhr morgens. Warum bist du wach? Warte. Frag nicht. Ich bin auch wach." -Fast
    }
    if ($Context -eq "login" -and $pet.Meta.TotalSessions -eq 42) {
        $found += "answer_to_everything"
        Show-CompanionDialog $pet.Companion "Die Antwort auf alles. Aber was war die Frage?" -Fast
    }
    if ($Context -eq "punish" -and $pet.Companion -and $pet.Companion.Mood -eq "Loving") {
        $found += "toxic_relationship"
        Show-CompanionDialog $pet.Companion "Wir sind VERHEIRATET. Was ist FALSCH mit dir?!" -Fast
    }
    if ($Context -eq "talk" -and $pet.Meta.Stats.TalkCount -gt 50) {
        $found += "talk_grind"
        Show-CompanionDialog $pet.Companion "Du drückst schon wieder 'Talk'? Wir müssen reden. Über deine Lebensentscheidungen." -Fast
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
