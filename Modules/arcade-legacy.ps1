# BUXE_OS v24.4 -- ZORK & HANGMAN (TUI)
# Zork erweitert auf 8 Raeume, Items, Boss, State-Tracking.

try {

function zork {
    $rooms = @{
        "Start" = @{ Desc = "Du stehst in einem Wald. Pfade fuehren nach Norden, Osten und Sueden. Du fuehlst dich beobachtet... von einer PowerShell-Session."; N = "Hoehle"; E = "See"; S = "Garden"; Items = @() }
        "Hoehle" = @{ Desc = "Eine dunkle Hoehle. Du siehst etwas glitzern. Der Echo deiner Schritte klingt wie ein Syntaxfehler."; S = "Start"; E = "Dungeon"; Items = @("Schluessel") }
        "See" = @{ Desc = "Ein ruhiger See. Ein Boot liegt am Ufer. Die Wellen fluestern: 'Das ist nur ein Text-Adventure in einem PowerShell-Profil...'"; W = "Start"; N = "Turm"; S = "Kitchen"; Items = @() }
        "Turm" = @{ Desc = "Ein alter Turm. Oben leuchtet ein Kristall. Eine Treppe fuehrt nach oben."; S = "See"; U = "TowerTop"; Items = @("Kristall") }
        "Garden" = @{ Desc = "Ein verwunschener Garten mit toten Pixeln. Die Blumen sehen aus wie ASCII-Art."; N = "Start"; E = "Kitchen"; Items = @("Trank") }
        "Kitchen" = @{ Desc = "Eine verlassene Kueche. Der Geruch von altem Ramen liegt in der Luft."; W = "Garden"; N = "See"; E = "Library"; Items = @() }
        "Library" = @{ Desc = "Ein staubiges Archiv voller vergessener Module. Jemand hat '47' in ein Buch gekritzelt."; W = "Kitchen"; Items = @("Schwert") }
        "Dungeon" = @{ Desc = "Ein feuchter Kerker. Die Waende sind aus rostigen Gittern."; W = "Hoehle"; Items = @() }
        "TowerTop" = @{ Desc = "Der Gipfel des Turms. Ein riesiger Troll blockiert den Weg! Er bruellt: 'Kein Exit ohne Kampf, PowerShell-User!'"; D = "Turm"; Boss = "Troll"; Items = @() }
        "SecretPassage" = @{ Desc = "Ein geheimer Gang! Die Waende sind mit Source Code tapeziert. Hier endet das Adventure... fuer jetzt."; Items = @() }
    }
    $inventory = @()
    $current = "Start"
    $roomsExplored = @("Start")
    $bossDefeated = $false
    $itemsFound = 0
    
    Reset-RenderBuffer
    $w = 55; $h = 18
    
    while ($true) {
        $room = $rooms[$current]
        $exits = ($room.GetEnumerator() | Where-Object { $_.Key -in @('N','S','E','W','U','D') } | ForEach-Object { $_.Key }) -join ', '
        
        $s = New-Scene $w $h
        Add-SceneFrame $s 0 0 $w $h "ZORK" 'Cyan' -Double
        Add-SceneText $s 4 2 $room.Desc 'White'
        
        $y = 4
        if ($room.Items.Count -gt 0) {
            Add-SceneText $s 4 $y "Items hier: $($room.Items -join ', ')" 'Yellow'
            $y++
        }
        if ($room.Boss -and -not $bossDefeated) {
            Add-SceneText $s 4 $y "BOSS: $($room.Boss)!" 'Red'
            $y++
        }
        
        Add-SceneText $s 4 ($y + 1) "Wege: $exits" 'DarkGray'
        Add-SceneText $s 4 ($y + 2) "Inventar: $($inventory -join ', ')" 'Green'
        Add-SceneText $s 4 ($y + 4) "[N]ord  [S]ued  [O]st  [W]est  [H]och  [R]unter" 'White'
        Add-SceneText $s 4 ($y + 5) "[T]ake  [I]nv   [Q]uit" 'White'
        Show-Scene $s -Force
        
        # Boss encounter
        if ($current -eq "TowerTop" -and -not $bossDefeated) {
            $bs = New-Scene $w $h
            Add-SceneFrame $bs 0 0 $w $h "ZORK - BOSS" 'Red' -Double
            Add-SceneText $bs 4 2 "Der Troll stemmt sich in den Weg!" 'Red'
            Add-SceneText $bs 4 3 "[K]aempfen  [S]chwert benutzen  [F]luechten" 'White'
            Show-Scene $bs -Force
            
            $bcmd = Read-GameChoice "" "^[KSFQ]$"
            switch ($bcmd) {
                'K' {
                    $err = New-Scene $w $h
                    Add-SceneFrame $err 0 0 $w $h "ZORK" 'Red' -Double
                    Add-SceneText $err 4 5 "Der Troll haut dich mit einem Exception-Stacktrace um!" 'Red'
                    Add-SceneText $err 4 6 "Du fliehst zurueck zum Turm..." 'Yellow'
                    Show-Scene $err -Force
                    Start-Sleep -Milliseconds 800
                    $current = "Turm"
                    continue
                }
                'S' {
                    if ($inventory -contains "Schwert") {
                        $ok = New-Scene $w $h
                        Add-SceneFrame $ok 0 0 $w $h "ZORK" 'Green' -Double
                        Add-SceneText $ok 4 5 "Du durchbohrst den Troll mit dem Schwert!" 'Green'
                        Add-SceneText $ok 4 6 "Er zerfaellt in 404-Seiten!" 'Green'
                        Show-Scene $ok -Force
                        Start-Sleep -Milliseconds 800
                        $bossDefeated = $true
                    } else {
                        $err = New-Scene $w $h
                        Add-SceneFrame $err 0 0 $w $h "ZORK" 'Red' -Double
                        Add-SceneText $err 4 5 "Du hast kein Schwert!" 'Red'
                        Add-SceneText $err 4 6 "Der Troll lacht: 'Nackt im Terminal, was?'" 'Yellow'
                        Show-Scene $err -Force
                        Start-Sleep -Milliseconds 800
                        $current = "Turm"
                        continue
                    }
                }
                'F' {
                    $current = "Turm"
                    continue
                }
                'Q' { Save-ZorkState $roomsExplored $itemsFound $bossDefeated; return }
            }
        }
        
        $cmd = Read-GameChoice "" "^[NSOEWHRUDTIQ]$"
        switch ($cmd) {
            'N' { if ($room.N) { $current = $room.N } else { Show-ZorkError $w $h "Geht nicht!" } }
            'S' { if ($room.S) { $current = $room.S } else { Show-ZorkError $w $h "Geht nicht!" } }
            'O' { if ($room.E) { $current = $room.E } else { Show-ZorkError $w $h "Geht nicht!" } }
            'E' { if ($room.E) { $current = $room.E } else { Show-ZorkError $w $h "Geht nicht!" } }
            'W' { if ($room.W) { $current = $room.W } else { Show-ZorkError $w $h "Geht nicht!" } }
            'H' { if ($room.U) { $current = $room.U } else { Show-ZorkError $w $h "Geht nicht!" } }
            'R' { if ($room.D) { $current = $room.D } else { Show-ZorkError $w $h "Geht nicht!" } }
            'U' { if ($room.U) { $current = $room.U } else { Show-ZorkError $w $h "Geht nicht!" } }
            'D' { if ($room.D) { $current = $room.D } else { Show-ZorkError $w $h "Geht nicht!" } }
            'T' { 
                if ($room.Items.Count -gt 0) { 
                    $inventory += $room.Items[0]
                    $itemsFound++
                    $room.Items = @()
                    Show-ZorkMessage $w $h "Aufgehoben!" "Green"
                } 
            }
            'I' { Show-ZorkMessage $w $h "Inventar: $($inventory -join ', ')" "Green" }
            'Q' { 
                Save-ZorkState $roomsExplored $itemsFound $bossDefeated
                return 
            }
        }
        
        if ($roomsExplored -notcontains $current) {
            $roomsExplored += $current
        }
        
        if ($bossDefeated) {
            $win = New-Scene $w $h
            Add-SceneFrame $win 0 0 $w $h "ZORK" 'Green' -Double
            Add-SceneText $win 4 5 "Du hast den Troll besiegt!" 'Green'
            Add-SceneText $win 4 6 "Das PowerShell-Profil ist gerettet!" 'Magenta'
            Show-Scene $win -Force
            Unlock-Achievement "Zork Survivor"
            Save-ZorkState $roomsExplored $itemsFound $true
            Wait-Enter
            return
        }
    }
}

function Show-ZorkError($w, $h, $msg) {
    $err = New-Scene $w $h
    Add-SceneFrame $err 0 0 $w $h "ZORK" 'Cyan' -Double
    Add-SceneText $err 4 5 $msg 'Red'
    Show-Scene $err -Force
    Start-Sleep -Milliseconds 400
}

function Show-ZorkMessage($w, $h, $msg, $color) {
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h "ZORK" 'Cyan' -Double
    Add-SceneText $s 4 5 $msg $color
    Show-Scene $s -Force
    Start-Sleep -Milliseconds 400
}

function Save-ZorkState($explored, $items, $boss) {
    Load-State
    $stats = Get-ArcadeStats "Zork"
    if (-not $stats.RoomsExplored) { $stats.RoomsExplored = 0 }
    if (-not $stats.ItemsFound) { $stats.ItemsFound = 0 }
    if (-not $stats.BossDefeated) { $stats.BossDefeated = $false }
    $stats.RoomsExplored = $explored.Count
    $stats.ItemsFound = $items
    if ($boss) { $stats.BossDefeated = $true }
    Set-ArcadeStats "Zork" $stats
    Save-State
}

function hangman {
    $categories = @{
        easy = @("cat","dog","sun","hat","pen","cup","box","red","fish","bird","tree")
        tech = @("powershell","javascript","algorithm","firewall","encryption","protocol","bandwidth","malware","debugging","repository")
        cyberpunk = @("netrunner","cyberdeck","implant","flatline","corporate","icebreaker","neurochip","ripperdoc")
    }
    $gallows = @(
        @("      ","      ","      ","      ","      ","======"),
        @("      ","      ","      ","      ","  |   ","======"),
        @("      ","      ","      ","  |   ","  |   ","======"),
        @("      ","      ","  O   ","  |   ","  |   ","======"),
        @("      ","      ","  O   "," /|   ","  |   ","======"),
        @("      ","      ","  O   "," /|\  ","  |   ","======"),
        @("      ","      ","  O   "," /|\  "," /    ","======"),
        @("      ","      ","  O   "," /|\  "," / \  ","======")
    )
    
    Reset-RenderBuffer
    $w = 50; $h = 18
    
    # Difficulty selection
    $sel = New-Scene $w $h
    Add-SceneFrame $sel 0 0 $w $h "HANGMAN" 'Cyan' -Double
    Add-SceneText $sel 4 2 "Schwierigkeit:" 'White'
    Add-SceneText $sel 4 4 "[1] Easy       (0G, 12 Fehler)" 'Green'
    Add-SceneText $sel 4 5 "[2] Normal     (10G, 7 Fehler)" 'Yellow'
    Add-SceneText $sel 4 6 "[3] Hard       (25G, 5 Fehler)" 'Red'
    Add-SceneText $sel 4 8 "[Q] Quit" 'DarkGray'
    Show-Scene $sel -Force
    
    $diff = Read-GameChoice "" "^[123Q]$"
    if ($diff -eq 'Q') { return }
    $diffMap = @{ "1" = @("easy",0,12); "2" = @("tech",10,7); "3" = @("cyberpunk",25,5) }
    $d = if ($diffMap[$diff]) { $diffMap[$diff] } else { @("tech",10,7) }
    $cat = $d[0]; $bet = $d[1]; $maxWrong = $d[2]
    
    Load-State
    $br = Confirm-Bust "Hangman"
    if ($bet -gt $br) { 
        $err = New-Scene $w $h
        Add-SceneFrame $err 0 0 $w $h "HANGMAN" 'Cyan' -Double
        Add-SceneText $err 4 5 "Nicht genug Gold!" 'Red'
        Show-Scene $err -Force
        Wait-Enter; return 
    }
    if ($bet -gt 0) { Set-Bankroll (-$bet) -TrackCasino }
    
    $word = ($categories[$cat] | Get-Random).ToUpper()
    $guessed = @(); $wrong = 0
    
    while ($wrong -lt $maxWrong) {
        $s = New-Scene $w $h
        Add-SceneFrame $s 0 0 $w $h "HANGMAN" 'Cyan' -Double
        Add-SceneText $s 4 1 "Kategorie: $cat | Einsatz: $bet | Fehler: $wrong/$maxWrong" 'Cyan'
        
        # Gallows
        $gy = 3
        foreach ($line in $gallows[[math]::Min($wrong,7)]) {
            Add-SceneText $s 4 $gy $line 'Red'
            $gy++
        }
        
        # Word display
        $display = ""
        foreach ($c in $word.ToCharArray()) { if ($c -eq ' ') { $display += "  " } elseif ($guessed -contains $c) { $display += "$c " } else { $display += "_ " } }
        Add-SceneText $s 4 12 $display 'White'
        Add-SceneText $s 4 14 "Geraten: $($guessed -join ', ')" 'DarkGray'
        
        Show-Scene $s -Force
        
        if ($display.Replace(' ','') -eq $word.Replace(' ','')) {
            $win = $bet * [math]::Floor(15 / $maxWrong)
            $rs = New-Scene $w $h
            Add-SceneFrame $rs 0 0 $w $h "HANGMAN" 'Cyan' -Double
            if ($win -gt 0) { Add-SceneText $rs 4 5 "GEWONNEN! $win G!" 'Green' }
            else { Add-SceneText $rs 4 5 "GEWONNEN!" 'Green' }
            Add-SceneText $rs 4 6 "Wort: $word" 'White'
            Show-Scene $rs -Force
            if ($win -gt 0) { Set-Bankroll $win -TrackCasino }
            Unlock-Achievement "Hangman Survivor"
            Wait-Enter; return
        }
        
        try { [Console]::CursorVisible = $true } catch {}
        $g = (Read-Host "  Buchstabe raten").ToUpper()
        try { [Console]::CursorVisible = $false } catch {}
        
        if ($g.Length -ne 1 -or $g -notmatch '[A-Z]') { 
            $err = New-Scene $w $h
            Add-SceneFrame $err 0 0 $w $h "HANGMAN" 'Cyan' -Double
            Add-SceneText $err 4 5 "Ungueltig." 'Red'
            Show-Scene $err -Force
            Start-Sleep -Milliseconds 500
            continue 
        }
        if ($guessed -contains $g) { 
            $err = New-Scene $w $h
            Add-SceneFrame $err 0 0 $w $h "HANGMAN" 'Cyan' -Double
            Add-SceneText $err 4 5 "Bereits geraten!" 'Yellow'
            Show-Scene $err -Force
            Start-Sleep -Milliseconds 500
            continue 
        }
        $guessed += $g
        if ($word.Contains($g)) { 
            $ok = New-Scene $w $h
            Add-SceneFrame $ok 0 0 $w $h "HANGMAN" 'Cyan' -Double
            Add-SceneText $ok 4 5 "Richtig!" 'Green'
            Show-Scene $ok -Force
            Start-Sleep -Milliseconds 400 
        } else { 
            $wrong++
            $bad = New-Scene $w $h
            Add-SceneFrame $bad 0 0 $w $h "HANGMAN" 'Cyan' -Double
            Add-SceneText $bad 4 5 "Falsch! $wrong/$maxWrong" 'Red'
            Show-Scene $bad -Force
            Start-Sleep -Milliseconds 400 
        }
    }
    
    # Game over
    $gs = New-Scene $w $h
    Add-SceneFrame $gs 0 0 $w $h "HANGMAN" 'Cyan' -Double
    $gy = 3
    foreach ($line in $gallows[[math]::Min($wrong,7)]) {
        Add-SceneText $gs 4 $gy $line 'Red'
        $gy++
    }
    Add-SceneText $gs 4 12 "GAME OVER!" 'Red'
    Add-SceneText $gs 4 13 "Das Wort war: $word" 'Yellow'
    Show-Scene $gs -Force
    Wait-Enter
}

} catch {
    Write-Host "[arcade-legacy] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
