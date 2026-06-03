# BUXE_OS v24.3 -- ZORK & HANGMAN (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-GameChoice / Read-Host.

try {

function zork {
    $rooms = @{
        "Start" = @{ Desc = "Du stehst in einem Wald. Pfade fuehren nach Norden und Osten."; N = "Hoehle"; E = "See"; Items = @() }
        "Hoehle" = @{ Desc = "Eine dunkle Hoehle. Du siehst etwas glitzern."; S = "Start"; Items = @("Schluessel") }
        "See" = @{ Desc = "Ein ruhiger See. Ein Boot liegt am Ufer."; W = "Start"; N = "Turm"; Items = @() }
        "Turm" = @{ Desc = "Ein alter Turm. Oben leuchtet ein Kristall."; S = "See"; Items = @("Kristall") }
    }
    $inventory = @()
    $current = "Start"
    
    Reset-RenderBuffer
    $w = 50; $h = 16
    
    while ($true) {
        $room = $rooms[$current]
        $exits = ($room.GetEnumerator() | Where-Object { $_.Key -in @('N','S','E','W') } | ForEach-Object { $_.Key }) -join ', '
        
        $s = New-Scene $w $h
        Add-SceneFrame $s 0 0 $w $h "ZORK" 'Cyan' -Double
        Add-SceneText $s 4 2 $room.Desc 'White'
        if ($room.Items.Count -gt 0) {
            Add-SceneText $s 4 4 "Items hier: $($room.Items -join ', ')" 'Yellow'
        }
        Add-SceneText $s 4 6 "Wege: $exits" 'DarkGray'
        Add-SceneText $s 4 7 "Inventar: $($inventory -join ', ')" 'Green'
        Add-SceneText $s 4 9 "[N]ord  [S]ued  [O]st  [W]est" 'White'
        Add-SceneText $s 4 10 "[T]ake  [I]nv   [Q]uit" 'White'
        Show-Scene $s -Force
        
        $cmd = Read-GameChoice "" "^[NSOEWTIQ]$"
        switch ($cmd) {
            'N' { if ($room.N) { $current = $room.N } else { 
                $err = New-Scene $w $h
                Add-SceneFrame $err 0 0 $w $h "ZORK" 'Cyan' -Double
                Add-SceneText $err 4 5 "Geht nicht!" 'Red'
                Show-Scene $err -Force
                Start-Sleep -Milliseconds 400
            } }
            'S' { if ($room.S) { $current = $room.S } else {
                $err = New-Scene $w $h
                Add-SceneFrame $err 0 0 $w $h "ZORK" 'Cyan' -Double
                Add-SceneText $err 4 5 "Geht nicht!" 'Red'
                Show-Scene $err -Force
                Start-Sleep -Milliseconds 400
            } }
            'E' { if ($room.E) { $current = $room.E } else {
                $err = New-Scene $w $h
                Add-SceneFrame $err 0 0 $w $h "ZORK" 'Cyan' -Double
                Add-SceneText $err 4 5 "Geht nicht!" 'Red'
                Show-Scene $err -Force
                Start-Sleep -Milliseconds 400
            } }
            'W' { if ($room.W) { $current = $room.W } else {
                $err = New-Scene $w $h
                Add-SceneFrame $err 0 0 $w $h "ZORK" 'Cyan' -Double
                Add-SceneText $err 4 5 "Geht nicht!" 'Red'
                Show-Scene $err -Force
                Start-Sleep -Milliseconds 400
            } }
            'T' { if ($room.Items.Count -gt 0) { 
                $inventory += $room.Items[0]; $room.Items = @()
                $ok = New-Scene $w $h
                Add-SceneFrame $ok 0 0 $w $h "ZORK" 'Cyan' -Double
                Add-SceneText $ok 4 5 "Aufgehoben!" 'Green'
                Show-Scene $ok -Force
                Start-Sleep -Milliseconds 400
            } }
            'I' {
                $inv = New-Scene $w $h
                Add-SceneFrame $inv 0 0 $w $h "ZORK" 'Cyan' -Double
                Add-SceneText $inv 4 5 "Inventar: $($inventory -join ', ')" 'Green'
                Show-Scene $inv -Force
                Wait-Enter
            }
            'Q' { return }
        }
        if ($inventory -contains "Kristall") {
            $win = New-Scene $w $h
            Add-SceneFrame $win 0 0 $w $h "ZORK" 'Cyan' -Double
            Add-SceneText $win 4 5 "Du hast den Kristall gefunden!" 'Magenta'
            Add-SceneText $win 4 6 "Du gewinnst!" 'Magenta'
            Show-Scene $win -Force
            Unlock-Achievement "Zork Survivor"
            Wait-Enter; return
        }
    }
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
