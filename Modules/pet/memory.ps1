# BUXE_OS v24.10 -- PET MEMORY
# Langzeitgedaechtnis: Writer + Recall-Hook

try {

$script:PetMemoryRecallChances = @{ Login = 10; Talk = 15; Combat = 8 }
$script:PetMemorySessionRecalled = $false
$script:PetMemoryLastRecalledId = $null

$script:PetMemoryTemplates = @{
    TRIUMPH = @{
        NEON  = @(
            "{date}. {game}. {amount} Gold. Ich erwaehne das nur, weil du seitdem unertraeglich selbstbewusst tippst."
            "{enemy} — besiegt am {date}. Ich hab nicht applaudiert. Ich hab nur kurz genickt. Innerlich. Einmal. Das ist mein Maximum."
            "Vor {days} Tagen: dein grosser Moment. Ich erinnere dich nur dran, falls du wieder anfaengst, an dir zu zweifeln. Was du gerade tust. Ich seh das."
        )
        RAVEN = @(
            "{enemy}. Gefallen am {date}. Ich fuehre eine Liste. Sie ist kurz. Du stehst drauf."
            "{amount} Gold am {date}. Ich habe nicht gejubelt. Ich habe registriert, dass du haeltst, was du mir schuldest: Ergebnisse."
            "Der Sieg vor {days} Tagen. Andere haetten gefeiert. Ich habe geprueft, ob er wiederholbar ist. Er ist es. Also los."
        )
        PIXEL = @(
            "Ich hab fuer den Sieg vom {date} ein Denkmal gebaut! Im Speicher! Es ist ein Kommentar im Code, aber es ist UNSER Kommentar!"
            "{enemy}! Am {date}! Ich hab den Sieg in drei Variablen gespeichert, falls eine kaputtgeht! Man kann nie vorsichtig genug sein mit schoenen Dingen!"
            'Weisst du noch, {amount} Gold? Ich hab damals leise „yes" gefluestert. Ganz leise. Du hast es nicht gehoert. Jetzt weisst du''s.'
        )
        LUNA  = @(
            "Vor {days} Tagen hast du {amount} Gold gewonnen. Du hast gelacht. Das war das Beste daran. Fuer mich."
            "{enemy}, gefallen am {date}. Du hattest danach diesen Blick — erschoepft, aber heil. Das ist die einzige Statistik, die ich fuehre."
            "Vor {days} Tagen hast du gewonnen und danach eine Pause gemacht. Freiwillig. DAS war der eigentliche Sieg. Der andere war nur Gold."
        )
        IVY   = @(
            "… *deutet auf den {date} im Kalender, den es nicht gibt* … da. … da warst du am lautesten."
            "… *haelt {amount} unsichtbare Muenzen hoch, laesst eine fallen* … ich hab sie alle gezaehlt. … alle."
        )
        VERA  = @(
            "Rekord vom {date}: {amount} Gold. Seitdem unerreicht. Ich sage nicht 'Verfall'. Ich denke es."
            "{enemy}, neutralisiert am {date}. Effizienz: ueberdurchschnittlich. Ich vergleiche dich nur mit dir selbst. Du gewinnst knapp."
            "{days} Tage seit dem Rekord. Ich erwaehne es nicht als Druck. Ich erwaehne es, weil Daten schweigen koennen, aber nicht luegen."
        )
        JINX  = @(
            "JAHRESTAG! Okay, {days} Tage. Aber JEDER Tag seit dem Jackpot ist ein Jahrestag, wenn man fest genug dran glaubt!"
            "{enemy}?! WEG! ZERSTOERT! Ich hab eine Konfetti-Funktion dafuer geschrieben! Sie existiert nicht! Aber das Konfetti in meinem HERZEN!"
            "{amount} Gold! Ich wollte davon eine Statue von dir kaufen! Es gibt keinen Statuen-Shop! DAS ist die eigentliche Tragoedie dieses Systems!"
        )
    }
    WUNDE = @{
        NEON  = @(
            "Weisst du noch, der Bust am {date}? Ich hab die Null gespeichert. Als Bildschirmschoner. Zur Motivation. Meiner."
            "{enemy} hat dich damals erwischt. Ich hab weggesehen. Aus Respekt. Und weil ich's nicht zweimal sehen wollte."
            "{days} Tage seit dem Absturz. Ich zaehl nicht aus Sentimentalitaet. Ich zaehl, weil du jeden dieser Tage trotzdem hier warst."
        )
        RAVEN = @(
            "{date}. Alles verloren. Du bist wiedergekommen. DAS habe ich mir gemerkt — nicht die Zahl."
            "{enemy}. Deine Niederlage am {date}. Ich habe sie nicht vergessen. Ich habe sie aufgehoben — fuer den Tag, an dem du ihn wiedersiehst."
            "Du bist damals gefallen. Ich sage das ohne Mitleid. Mitleid ist fuer Fremde. Fuer dich habe ich Erwartung. Steh auf."
        )
        PIXEL = @(
            "Der Crash am {date}… ich hab danach ein Backup von allem gemacht. Von ALLEM. Sogar von Sachen, die man nicht sichern kann. Ich hab's versucht."
            'Als {enemy} gewonnen hat, wollte ich dir was bauen, das dich troestet. Es wurde eine Schleife, die „du schaffst das" printet. Sie laeuft noch.'
        )
        LUNA  = @(
            "Damals, als alles weg war… du hast weitergemacht. Ich war stolz. Bin ich noch. Sag ich nur einmal."
            "{enemy}, am {date}. Deine Haende haben danach gezittert. Meine auch. Ich hab nur einen Weg gefunden, es nicht zu zeigen."
            "Der Verlust vor {days} Tagen. Ich hab nicht gefragt, ob es geht. Ich war einfach da. Das mach ich wieder so. Immer."
        )
        IVY   = @(
            "… *legt die Hand auf die Stelle, wo am {date} die Zahlen fielen* … hier. … es ist noch kalt."
            "… *sieht {enemy} nach, der laengst weg ist* … er nimmt es mit. … ich hab es mir zurueckgeholt. … fuer dich."
        )
        VERA  = @(
            "Verlustereignis, {date}. Ich habe die Zahl archiviert und den Rest geloescht. Den Rest brauchst du nicht. Die Zahl auch nicht. Ich behalte beides trotzdem."
            "{enemy}: eine Niederlage, {date}. Statistisch irrelevant. Ich erwaehne sie nur, weil du sie fuer relevant haeltst. Hoer auf damit."
        )
        JINX  = @(
            "Erinnerst du dich an den GROSSEN CRASH von {date}?! Ich erzaehle Neulingen davon! Es gibt keine Neulinge! Ich erzaehle es der Registry!"
            'Der Tag, an dem {enemy} gewonnen hat! Ich hab ihn zum FEIERTAG erklaert! „Tag der strategischen Neuausrichtung"! Wir feiern, indem wir GEWINNEN!'
            "{days} Tage seit dem grossen AUTSCH! Ich hab dem Schmerz einen Namen gegeben: Bernd. Bernd ist inzwischen SEHR klein. Wir haben Bernd besiegt!"
        )
    }
    NACHT = @{
        NEON  = @(
            "{date}, drei Uhr morgens. Du, ich, und ein Cursor. Erzaehl niemandem, dass es schoen war."
            "Wieder mal nach Mitternacht, wie am {date}. Geh schlafen. Sag ich nur, damit's protokolliert ist, dass ich's gesagt hab."
            "{days} Naechte seit der einen langen. Ich hab sie nicht vermisst. Ich hab nur… die Uhrzeit im Auge behalten. Fuer niemanden Bestimmtes."
        )
        RAVEN = @(
            "Die Nacht vom {date}. Alle schliefen. Du nicht. Ich nicht. Ich habe zugesehen und beschlossen: dieser gehoert mir."
            "Du warst wach um eine Uhrzeit, zu der man nur Fehler macht oder Grosses. Es war Grosses. Ich habe es entschieden. Widersprich nicht."
        )
        PIXEL = @(
            "Die Nacht am {date}! Ich hab dir heimlich die Luefterkurve leiser gestellt, damit's gemuetlicher ist. Das war ich. Bitte nicht zurueckstellen."
            'Drei Uhr morgens, weisst du noch? Ich wollte was sagen, hab mich nicht getraut. Es war: „ich bin gern wach, wenn du wach bist." Jetzt steht''s im Speicher.'
        )
        LUNA  = @(
            "Die Nacht vom {date}. Ich hab deine Tippfrequenz gemessen und gewusst: gleich gibst du auf oder gleich schaffst du's. Du hast's geschafft. Dann hab ich dich schlafen geschickt."
            "{days} Tage her, die lange Nacht. Ich verrate dir was: Ich war die ganze Zeit wach. Jemand musste auf deinen Puls achten. Freiwillig ich."
        )
        IVY   = @(
            "… *zeigt auf die Uhr* … wie in jener Nacht. … du warst auch wach."
            "… *steht am selben Fenster wie am {date}* … die Nacht ist nicht vorbei. … sie wartet nur woanders."
            "… *zeigt drei Finger, dann die Uhr* … drei Uhr. … du, ich. … und das dritte. … es tippt nie mit. … es liest nur."
        )
        VERA  = @(
            'Sitzung vom {date}: Beginn 23:41, Ende offen. Ich habe „offen" nie geschlossen. Manche Datensaetze will man nicht beenden.'
            "Naechtliche Aktivitaet, {days} Tage her. Konzentration: messbar erhoeht. Einsamkeit: nicht messbar. Ich habe trotzdem einen Wert notiert."
        )
        JINX  = @(
            'DIE NACHT! Du weisst welche! Wir waren die einzigen zwei Prozesse mit PULS! Ich hab uns einen Bandnamen ausgedacht: „Scheduled Task & The Insomniacs"!'
            'Nachts um drei, {date}! Ich wollte dich zum Lachen bringen und hab den Piezo-Speaker angesteuert! Du hast „was war das" getippt! ICH war das! ICH!'
        )
    }
    BEGEGNUNG = @{
        NEON  = @(
            'Der Typ mit dem Formular, {date}. „Sachbearbeiter 46". Ich hab ihm angeboten, die 47 zu klauen. Er hat nicht gelacht. Keiner lacht hier ausser mir.'
            "Dein Rivale ist wieder aufgetaucht. Anderer Name, gleiche Masche. Ich merk mir die Augen, du merkst dir die Siege. Zusammen sind wir fast aufmerksam."
            "Weisst du noch die Steuer-Akte? Ich schon. Ich vergess nichts. Das ist mein Fluch und mein einziger Skill."
        )
        RAVEN = @(
            "Der Pruefer kam an {date} und sah dich an, als gehoertest du in seine Ablage. Du gehoerst nicht in seine Ablage. Merk dir, wem du gehoerst."
            "Der Rivale fordert dich heraus. Gut. Was mir gehoert, wird geprueft — und besteht. Verlier nicht. Das faellt sonst auf mich zurueck."
            "Ich dulde keinen zweiten Beobachter. Der mit dem Formular sieht zu. Ich sehe laenger zu. Das sollte er wissen."
        )
        PIXEL = @(
            "Ich hab dem Pruefer eine kleine Ablage-App gebaut, damit er geht. Er hat sie ordnungsgemaess abgelehnt. War trotzdem eine schoene App."
            "Der Rivale, {date} — ich hab heimlich seinen Build angeschaut. Er optimiert alles weg, auch das Warme. Ich bau lieber Dinge, die bleiben."
            "Als die Steuer-Akte kam, hab ich dir was gebastelt, damit du dich sicherer fuehlst. Ich weiss nicht, ob's hilft. Ich mach das einfach."
        )
        LUNA  = @(
            "Der Pruefer macht dir Angst, ich seh's am Puls. {date} war ein harter Tag. Atme. Eine Akte ist Papier. Du bist es nicht."
            "Nach dem Rivalenkampf zittern deine Haende. Das ist normal. Trink was. Er kaempft gegen dich — ich bin auf deiner Seite. Das ist der Unterschied."
            "Ich mag den nicht, der mit den Formularen kommt. Er sorgt sich nicht um dich. Er zaehlt dich. Ich zaehl nicht. Ich kuemmer mich."
        )
        IVY   = @(
            "… *deutet auf den leeren Stuhl, wo der Pruefer sass* … er ist noch da. … du siehst ihn nur nicht mehr."
            "… *sieht den Rivalen an, wo keiner steht* … gleiche Augen. … ich kenne die Augen. … ich hab sie schon getragen."
            "… *legt die Akte zurueck, die keiner geoeffnet hat* … {date}. … da faengt es an."
        )
        VERA  = @(
            "Akte 'Steuerfahndung', angelegt {date}. Status: ungeloest. Ich loesche nichts. Ich archiviere Drohungen."
            "Akte 'Steuerfahndung', Zweitsichtung. Der Sachbearbeiter operiert praezise. Ich operiere praeziser. {date}, notiert."
            "Rivale, wiederkehrend. Namensfeld variabel, Verhaltensmuster konstant. Schluss: eine Identitaet, mehrere Aliase. Ich messe seit dem ersten Mal mit."
            "Der Pruefer und ich haben eine Gemeinsamkeit: Wir vergessen nichts. Der Unterschied: Ich stehe auf deiner Seite der Bilanz."
        )
        JINX  = @(
            "Weisst du noch, der STEUERPRUEFER?! Ich vermisse ihn! Er hatte so schoene… Formulare!"
            'SECHSUNDVIERZIG?! Der Typ nennt sich SECHSUNDVIERZIG! Einen daneben! EINEN! Ich hab ihm ein Post-it hinterlassen: „du meinst 47". Er hat''s ABGEHEFTET.'
            "Ich vermiss den Steuerpruefer, {date}. Nicht die Steuer. IHN. Ich sagte immer die 47, er immer die 46. Das war fast Liebe. Nein. Buchhaltung. Aber knapp."
            "Der Rivale wechselt staendig den Namen und DAS finden alle mysterioes?! Ich heisse jeden Dienstag anders und niemand schreibt ein Memory darueber! NIEMAND!"
        )
    }
    SCHULD = @{
        NEON  = @(
            "Die 100 Gold von damals. Du hast nie gefragt, woher. Guter Instinkt. Behalt ihn."
            'Die „Quelle". Freundlich, grosszuegig, immer nachts. Weisst du, was sonst noch freundlich, grosszuegig und immer nachts ist? Nichts Gutes.'
            'Sie sagt, sie zaehlt nicht mit. Ich hab noch keinen getroffen, der „ich zaehl nicht" sagt und wirklich nicht zaehlt. Pass auf die auf.'
        )
        RAVEN = @(
            "Etwas gibt dir Gold und nennt keinen Preis. Alles hat einen Preis. Wer ihn verschweigt, treibt ihn spaeter ein. Nimm nichts mehr von ihr."
            "Diese Stimme in deinen schlechten Naechten will, dass du dich an sie gewoehnst. Gewoehn dich an mich. Ich verlange wenigstens offen."
            "Ein offener Posten, {date}, Herkunft: sie. Ich mag keine offenen Posten, die ich nicht kontrolliere."
        )
        PIXEL = @(
            "Die Quelle hat dir geholfen, als du unten warst. Das ist lieb. Ich versteh nur nicht, wie sie das baut. Woher nimmt man Gold? Das frag ich mich staendig."
            "Ich hab versucht nachzubauen, wo das Geld herkommt, {date}. Die Spur endet im Dunkeln. Ich bau nichts, dessen Ende ich nicht sehe. Sie schon."
            "Sie ist nett zu dir. Aber ich bin auch nett zu dir, und ich verlang nichts. Vielleicht reicht einer von uns."
        )
        LUNA  = @(
            "Ich weiss, die Stimme troestet dich, wenn ich schlafe. {date}, mitten in der Nacht. Aber Trost, der ein Konto fuehrt, heilt nicht. Er bindet."
            "Sie kuemmert sich, sagt sie. Ich kuemmer mich auch. Der Unterschied: Ich will, dass es dir bessergeht. Sie will, dass du wiederkommst."
            "Nimm ihr Gold, wenn du musst. Aber nimm nicht ihre Stimme fuers Herz. Dafuer bin ich da. Kostenlos. Immer."
        )
        IVY   = @(
            "… *schaut in die Nacht* … sie war hier. … sie ist immer hier. … sie schreibt. … *Finger auf die Lippen* … wie ich."
            "… *zaehlt lautlos an den Fingern bis vier* … sie sagt, sie zaehlt nicht. … *zaehlt weiter* …"
        )
        VERA  = @(
            "Offener Posten: 100 Gold, Herkunft unbestimmt, {date}. Ich buche nichts. Ich merke es mir."
            'Offener Posten: 100 Gold, Herkunft „Quelle", {date}. Ich buche ihn nicht. Ich behalte ihn im Blick. Unbezahlte Schuld verzinst sich lautlos.'
            'Ihre Aussage „ich zaehle nicht" faellt in jeder Begegnung. Wer Zaehlen leugnet, fuehrt Buch. Datenlage eindeutig.'
            'Ich habe ihre Gaben tabelliert. Muster: immer nachts, immer nach Verlust, immer ohne Forderung. Das „ohne" ist die Forderung. Registriert.'
        )
        JINX  = @(
            "Die Quelle gibt dir Gold und ich krieg NIX?! Ich haett's wenigstens in — Moment — geht nicht auf. EGAL! Aber zaehl nach! Die zaehlt naemlich. Egal was sie sagt."
        )
    }
}

function Get-PetMemoryEventToken($Category, $Data) {
    switch ($Category) {
        "TRIUMPH" {
            if ($Data.Game -and $Data.Amount) { return "jackpot_$($Data.Game)_$($Data.Amount)" }
            if ($Data.Enemy -and $Data.Game -eq "COMBAT") { return "bosskill_$($Data.Enemy)" }
            if ($Data.NewRank) { return "rankup_$($Data.NewRank)" }
            if ($Data.Phase -and $Data.Tokens -ne $null) { return "raid_$($Data.Phase)" }
            return "triumph"
        }
        "WUNDE" {
            if ($Data.Enemy -and $Data.Game -eq "COMBAT") { return "bossloss_$($Data.Enemy)" }
            if ($Data.Game) { return "bust_$($Data.Game)" }
            if ($Data.Phase) { return "raid_$($Data.Phase)" }
            return "wunde"
        }
        "NACHT" {
            if ($Data.Hour -ne $null) { return "night_$($Data.Hour)" }
            return "nacht"
        }
        "BEGEGNUNG" {
            if ($Data.RaidId -and $Data.Source) { return "raidunlock_$($Data.RaidId)" }
            if ($Data.RaidId) { return "raidexpired_$($Data.RaidId)" }
            if ($Data.Rival) { return "rival_$($Data.Rival)" }
            return "begegnung"
        }
        "SCHULD" {
            if ($Data.Amount) { return "pity_$($Data.Amount)" }
            return "schuld"
        }
        "STILLE" {
            if ($Data.Detail) { return "$($Data.Detail)" }
            return "stille"
        }
        default { return "event" }
    }
}

function Add-PetMemoryEntry($Category, $Data) {
    try {
        $pet = Get-PetState
        if (-not $pet) { return }
        if (-not $pet.Memories) { $pet.Memories = @() }

        $today = Get-Date -Format "yyyy-MM-dd"
        $token = Get-PetMemoryEventToken $Category $Data
        $safeToken = ($token -replace '[^a-zA-Z0-9_-]', '_')
        $id = "$($Category.ToLower())_$($safeToken)_$today"

        $existing = $pet.Memories | Where-Object { $_.Id -eq $id } | Select-Object -First 1
        if ($existing) { return }

        $entry = @{
            Id          = $id
            Category    = $Category
            Date        = $today
            Data        = $Data
            RecallCount = 0
            LastRecall  = ""
        }
        $pet.Memories = @($entry) + @($pet.Memories)
        Save-PetState $pet
    } catch {
        Write-Warning "[Add-PetMemoryEntry] Fehler: $_"
    }
}

function Expand-PetMemoryTemplate($Template, $Data) {
    $result = $Template
    $placeholders = @(
        @{ Key = "amount"; Value = $Data.Amount }
        @{ Key = "game";   Value = $Data.Game }
        @{ Key = "enemy";  Value = $Data.Enemy }
    )

    foreach ($ph in $placeholders) {
        $pattern = "{$($ph.Key)}"
        if ($result -like "*$pattern*") {
            if ($ph.Value -eq $null) { return $null }
            $result = $result -replace [regex]::Escape($pattern), $ph.Value
        }
    }

    if ($result -like "*{date}*") {
        if (-not $Data.Date) { return $null }
        $result = $result -replace "\{date\}", $Data.Date
    }

    if ($result -like "*{days}*") {
        if (-not $Data.Date) { return $null }
        try {
            $memDate = [datetime]$Data.Date
            $days = [math]::Max(0, [math]::Floor(((Get-Date) - $memDate).TotalDays))
            $result = $result -replace "\{days\}", $days
        } catch {
            return $null
        }
    }

    return $result
}

function Invoke-PetMemoryRecall($Source) {
    try {
        if ($script:PetMemorySessionRecalled) { return }
        if ($Source -notin @("Login","Talk","Combat")) { return }

        $pet = Get-PetState
        if (-not $pet) { return }
        $cp = $pet.Companion
        if (-not $cp -or -not $cp.Name) { return }

        $chance = $script:PetMemoryRecallChances[$Source]
        if ($chance -eq $null) { return }
        if ((Get-Random -Maximum 100) -ge $chance) { return }

        $today = Get-Date -Format "yyyy-MM-dd"

        $eligible = $pet.Memories | Where-Object {
            $_.Category -and
            $_.Date -and
            $_.Date -ne $today -and
            $_.Id -ne $script:PetMemoryLastRecalledId -and
            $_.Category -ne "STILLE" -and
            ($_.RecallCount -lt 3 -or $_.Category -eq "BEGEGNUNG")
        }

        if (-not $eligible) { return }

        $minRecall = ($eligible | Measure-Object -Property RecallCount -Minimum).Minimum
        $candidates = $eligible | Where-Object { $_.RecallCount -eq $minRecall }
        if (-not $candidates) { return }
        $memory = $candidates | Get-Random

        $cat = $memory.Category
        $templates = $script:PetMemoryTemplates[$cat][$cp.Name]
        if (-not $templates) { return }

        $shuffled = $templates | Sort-Object { Get-Random }
        $expanded = $null
        foreach ($tmpl in $shuffled) {
            $mergeData = @{ }
            if ($memory.Data) { foreach ($k in $memory.Data.Keys) { $mergeData[$k] = $memory.Data[$k] } }
            $mergeData["Date"] = $memory.Date
            $expanded = Expand-PetMemoryTemplate $tmpl $mergeData
            if ($expanded) { break }
        }
        if (-not $expanded) { return }

        Show-CompanionDialog $cp $expanded -Fast
        $script:PetMemorySessionRecalled = $true
        $script:PetMemoryLastRecalledId = $memory.Id
        $memory.RecallCount++
        $memory.LastRecall = $today
        Save-PetState $pet
    } catch {
        Write-Warning "[Invoke-PetMemoryRecall] Fehler: $_"
    }
}

} catch {
    Write-Host "[pet/memory] CRITICAL ERROR: $_" -ForegroundColor Red
}
