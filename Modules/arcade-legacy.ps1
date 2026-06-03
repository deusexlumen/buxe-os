# BUXE_OS v24.0 -- ZORK & HANGMAN

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
    
    while ($true) {
        $room = $rooms[$current]
        Clear-Screen "ZORK"
        Write-Host "`n  $($room.Desc)" -ForegroundColor Cyan
        if ($room.Items.Count -gt 0) {
            Write-Host "  Items hier: $($room.Items -join ', ')" -ForegroundColor Yellow
        }
        Write-Host "  Wege: $(($room.GetEnumerator() | Where-Object { $_.Key -in @('N','S','E','W') } | ForEach-Object { $_.Key }) -join ', ')" -ForegroundColor DarkGray
        Write-Host "  Inventar: $($inventory -join ', ')" -ForegroundColor Green
        $cmd = Read-Host "`n  Befehl [N/S/E/W/Take/Inv/Quit]"
        switch ($cmd.ToUpper()) {
            'N' { if ($room.N) { $current = $room.N } else { Write-Host "  Geht nicht!" -ForegroundColor Red } }
            'S' { if ($room.S) { $current = $room.S } else { Write-Host "  Geht nicht!" -ForegroundColor Red } }
            'E' { if ($room.E) { $current = $room.E } else { Write-Host "  Geht nicht!" -ForegroundColor Red } }
            'W' { if ($room.W) { $current = $room.W } else { Write-Host "  Geht nicht!" -ForegroundColor Red } }
            'TAKE' { if ($room.Items.Count -gt 0) { $inventory += $room.Items[0]; $room.Items = @(); Write-Host "  Aufgehoben!" -ForegroundColor Green } }
            'INV' { Write-Host "  Inventar: $($inventory -join ', ')" -ForegroundColor Green }
            'QUIT' { return }
            default { Write-Host "  Unbekannter Befehl." -ForegroundColor Red }
        }
        if ($inventory -contains "Kristall") {
            Write-Host "`n  Du hast den Kristall gefunden! Du gewinnst!" -ForegroundColor Magenta
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
    
    Clear-Screen "HANGMAN"
    Write-Host "`n  Schwierigkeit: [1] Easy [2] Normal [3] Hard" -ForegroundColor White
    $diff = Read-Host "  Waehle"
    $diffMap = @{ "1" = @("easy",0,12); "2" = @("tech",10,7); "3" = @("cyberpunk",25,5) }
    $d = if ($diffMap[$diff]) { $diffMap[$diff] } else { @("tech",10,7) }
    $cat = $d[0]; $bet = $d[1]; $maxWrong = $d[2]
    
    Load-State
    $br = Confirm-Bust "Hangman"
    if ($bet -gt $br) { Write-Host "  Nicht genug Gold!" -ForegroundColor Red; Wait-Enter; return }
    if ($bet -gt 0) { Set-Bankroll (-$bet) -TrackCasino }
    
    $word = ($categories[$cat] | Get-Random).ToUpper()
    $guessed = @(); $wrong = 0
    while ($wrong -lt $maxWrong) {
        Clear-Screen "HANGMAN"
        Write-Host "`n  Hangman -- Kategorie: $cat | Einsatz: $bet | Fehler: $wrong/$maxWrong" -ForegroundColor Cyan
        foreach ($line in $gallows[[math]::Min($wrong,7)]) { Write-Host "  $line" -ForegroundColor Red }
        $display = ""
        foreach ($c in $word.ToCharArray()) { if ($c -eq ' ') { $display += "  " } elseif ($guessed -contains $c) { $display += "$c " } else { $display += "_ " } }
        Write-Host "`n  $display`n" -ForegroundColor White
        Write-Host "  Geraten: $($guessed -join ', ')" -ForegroundColor DarkGray
        if ($display.Replace(' ','') -eq $word.Replace(' ','')) {
            $win = $bet * [math]::Floor(15 / $maxWrong)
            if ($win -gt 0) { Set-Bankroll $win -TrackCasino; Write-Host "`n  GEWONNEN! $win G! Wort: $word" -ForegroundColor Green }
            else { Write-Host "`n  GEWONNEN! Wort: $word" -ForegroundColor Green }
            Unlock-Achievement "Hangman Survivor"
            Wait-Enter; return
        }
        $g = (Read-Host "  Buchstabe raten").ToUpper()
        if ($g.Length -ne 1 -or $g -notmatch '[A-Z]') { Write-Host "  Ungueltig." -ForegroundColor Red; Start-Sleep -Milliseconds 500; continue }
        if ($guessed -contains $g) { Write-Host "  Bereits geraten!" -ForegroundColor Yellow; Start-Sleep -Milliseconds 500; continue }
        $guessed += $g
        if ($word.Contains($g)) { Write-Host "  Richtig!" -ForegroundColor Green; Start-Sleep -Milliseconds 400 }
        else { $wrong++; Write-Host "  Falsch! $wrong/$maxWrong" -ForegroundColor Red; Start-Sleep -Milliseconds 400 }
    }
    Clear-Screen "HANGMAN"
    foreach ($line in $gallows[[math]::Min($wrong,7)]) { Write-Host "  $line" -ForegroundColor Red }
    Write-Host "`n  GAME OVER! Das Wort war: $word`n" -ForegroundColor Red
    Wait-Enter
}

} catch {
    Write-Host "[arcade-legacy] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
