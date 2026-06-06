# BUXE_OS v24.6 — COMPANION GAMES v1.0
# Mini-games with your companion

try {

function Invoke-CompanionGame {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { Write-Host "Kein Companion aktiv."; Wait-Enter; return }
    if ($pet.Meta.Level -lt 2) { Write-Host "Spiele freigeschaltet ab Meta-Level 2."; Wait-Enter; return }

    $games = @(
        @{ Key = "1"; Name = "Chaos-Chips"; Desc = "Wuerfel-Duell (3 Runden)" }
        @{ Key = "2"; Name = "42 oder 47"; Desc = "Zahlen-Raten (1-100)" }
        @{ Key = "3"; Name = "Memory"; Desc = "4x4 Karten-Memory" }
    )

    while ($true) {
        try { Clear-Host } catch {}
        Show-PetFrame "COMPANION GAMES" -Double | Out-Null
        Write-Host "`n  Waehle ein Spiel:" -ForegroundColor White
        foreach ($g in $games) {
            Write-Host "  [$($g.Key)] $($g.Name) — $($g.Desc)" -ForegroundColor Cyan
        }
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray

        $c = Read-Choice "Spiel" '^[123Q]$'
        if ($c -eq 'Q') { return }

        switch ($c) {
            "1" { Play-ChaosChips $pet $cp }
            "2" { Play-FortyTwoOr47 $pet $cp }
            "3" { Play-Memory $pet $cp }
        }
    }
}

function Play-ChaosChips($pet, $cp) {
    try { Clear-Host } catch {}
    Show-PetFrame "CHAOS-CHIPS" -Double | Out-Null
    Write-Host "`n  3 Runden. Wer die hoehere Summe wuerfelt, gewinnt." -ForegroundColor White
    Write-Host "  Dein Bond mit $($cp.Name): $($cp.Bond)/100" -ForegroundColor DarkGray
    Wait-Enter

    $playerTotal = 0; $companionTotal = 0

    for ($round = 1; $round -le 3; $round++) {
        try { Clear-Host } catch {}
        Show-PetFrame "CHAOS-CHIPS — Runde $round/3" -Double | Out-Null

        Write-Host "`n  [ENTER] zum Wuerfeln..." -ForegroundColor Yellow
        Wait-Enter

        $playerRoll = (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7)
        $playerTotal += $playerRoll

        $companionRoll = (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7)
        if ($cp.Bond -lt 30) { $companionRoll += (Get-Random -Minimum 0 -Maximum 3) }
        elseif ($cp.Bond -gt 70) { $companionRoll -= (Get-Random -Minimum 0 -Maximum 3) }
        $companionTotal += [math]::Max(3, $companionRoll)

        Write-Host "`n  Du: $playerRoll | $($cp.Name): $companionRoll" -ForegroundColor White

        $comment = if ($playerRoll -gt $companionRoll) {
            @("Nicht schlecht. Fuer einen Anfaenger.","Glueck? Oder Skill?","Ich habe schlecht gewuerfelt. Absichtlich.") | Get-Random
        } elseif ($playerRoll -lt $companionRoll) {
            @("Haha! Algorithmen schlagen Zufall.","Das nenne ich Probabilistik.","Willst du eine Rematch?")
        } else {
            @("Gleichstand? Statistisch unwahrscheinlich.","Wir sind zu aehnlich. Das ist beunruhigend.")
        }
        Show-CompanionDialog $cp $comment -Fast

        Start-Sleep -Milliseconds 500
    }

    try { Clear-Host } catch {}
    Show-PetFrame "CHAOS-CHIPS — ERGEBNIS" -Double | Out-Null
    Write-Host "`n  Deine Summe: $playerTotal" -ForegroundColor White
    Write-Host "  $($cp.Name): $companionTotal" -ForegroundColor White

    $won = $playerTotal -gt $companionTotal
    if ($won) {
        Write-Host "`n  DU GEWINNST!" -ForegroundColor Green
        $pet.CompanionGames.Wins++; $pet.CompanionGames.ChaosChipsHighscore = [math]::Max($pet.CompanionGames.ChaosChipsHighscore, $playerTotal)
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_win") -Fast
    } elseif ($playerTotal -lt $companionTotal) {
        Write-Host "`n  $($cp.Name) GEWINNT!" -ForegroundColor Red
        $pet.CompanionGames.Losses++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
    } else {
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        Show-CompanionDialog $cp "Ein Unentschieden? Wie langweilig." -Fast
    }

    Add-PetXP 5 "ChaosChips"
    Save-PetState $pet
    Wait-Enter
}

function Play-FortyTwoOr47($pet, $cp) {
    try { Clear-Host } catch {}
    Show-PetFrame "42 ODER 47" -Double | Out-Null
    Write-Host "`n  Ich denke mir eine Zahl zwischen 1 und 100." -ForegroundColor White
    Write-Host "  Du hast 7 Versuche." -ForegroundColor DarkGray
    Show-CompanionDialog $cp "Bereit? Die Zahl ist... nicht 47. Oder doch?" -Fast

    $target = Get-Random -Minimum 1 -Maximum 101
    $guesses = 0; $maxGuesses = 7; $guess = $null

    while ($guesses -lt $maxGuesses) {
        try { Clear-Host } catch {}
        Show-PetFrame "42 ODER 47 — Versuch $($guesses + 1)/$maxGuesses" -Double | Out-Null

        Write-Host "`n  Gib eine Zahl ein (1-100):" -ForegroundColor Cyan
        Write-Host "  [Q] Aufgeben" -ForegroundColor DarkGray
        $inputStr = Read-Host "  Zahl"
        if ($inputStr -eq "Q") {
            Write-Host "`n  Aufgegeben. Die Zahl war $target." -ForegroundColor Red
            $pet.CompanionGames.Losses++
            Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
            Add-PetXP 3 "42or47"
            Save-PetState $pet
            Wait-Enter
            return
        }
        $guessVal = 0
        if (-not [int]::TryParse($inputStr, [ref]$guessVal) -or $guessVal -lt 1 -or $guessVal -gt 100) {
            Write-Host "  Ungueltige Eingabe. Bitte 1-100 oder Q." -ForegroundColor Red
            Start-Sleep -Milliseconds 500
            continue
        }
        $guess = $guessVal

        $guesses++

        if ($guess -eq $target) {
            Write-Host "`n  RICHTIG! Die Zahl war $target!" -ForegroundColor Green
            $pet.CompanionGames.Wins++
            $pet.CompanionGames.FortyTwoBestGuesses = [math]::Min($pet.CompanionGames.FortyTwoBestGuesses, $guesses)
            Show-CompanionDialog $cp (Get-CompanionLine $cp "game_win") -Fast
            break
        }

        $diff = [math]::Abs($guess - $target)
        $hint = if ($cp.Bond -ge 70) {
            if ($diff -le 5) { "Sehr warm! Du bist EXTREM nah dran." }
            elseif ($diff -le 15) { "Warm. Du gehst in die richtige Richtung." }
            elseif ($diff -le 30) { "Lauwarm. Versuch es in die andere Richtung." }
            else { "Kalt. Eiskalt. Wie mein Serverraum." }
        } elseif ($cp.Bond -ge 30) {
            if ($diff -le 10) { "Warm!" }
            elseif ($diff -le 25) { "Lauwarm." }
            else { "Kalt." }
        } else {
            if ($diff -le 20) { "Nicht schlecht. Aber noch falsch." }
            else { "Haha. Weit daneben." }
        }

        if ($guess -lt $target) {
            Write-Host "`n  Zu niedrig! $hint" -ForegroundColor Yellow
        } else {
            Write-Host "`n  Zu hoch! $hint" -ForegroundColor Yellow
        }

        Show-CompanionDialog $cp $hint -Fast
        Start-Sleep -Milliseconds 400
    }

    if ($guess -ne $target -or $null -eq $guess) {
        Write-Host "`n  Die Zahl war $target. Du hast verloren." -ForegroundColor Red
        $pet.CompanionGames.Losses++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
    }

    Add-PetXP 5 "42or47"
    Save-PetState $pet
    Wait-Enter
}

function Play-Memory($pet, $cp) {
    $symbols = @('♥','♦','♠','♣','★','☆','●','○')
    $deck = $symbols + $symbols | Sort-Object { Get-Random }
    $revealed = @($false) * 16
    $companionMemory = @{}  # Companion "remembers" cards
    $playerScore = 0; $companionScore = 0
    $currentPlayer = "player"
    $turns = 0

    # Bond affects companion memory accuracy
    $companionMemoryChance = if ($cp.Bond -lt 30) { 0.3 } elseif ($cp.Bond -gt 70) { 0.8 } else { 0.5 }

    while ($playerScore + $companionScore -lt 8) {
        $turns++
        try { Clear-Host } catch {}
        Show-PetFrame "MEMORY — Du: $playerScore | $($cp.Name): $companionScore" -Double | Out-Null

        # Render grid
        Write-Host ""
        for ($row = 0; $row -lt 4; $row++) {
            $line = "  "
            for ($col = 0; $col -lt 4; $col++) {
                $idx = $row * 4 + $col
                if ($revealed[$idx]) {
                    $line += "[$($deck[$idx])] "
                } else {
                    $line += "[$(($idx + 1).ToString("D2"))] "
                }
            }
            Write-Host $line -ForegroundColor White
        }

        if ($currentPlayer -eq "player") {
            Write-Host "`n  Waehle zwei Karten (1-16, Q zum Beenden):" -ForegroundColor Cyan
            $first = Read-Choice "Erste Karte" '^([1-9]|1[0-6]|Q)$'
            if ($first -eq 'Q') { Save-PetState $pet; return }
            $idx1 = [int]$first - 1
            if ($revealed[$idx1]) { Show-CompanionDialog $cp "Die ist schon aufgedeckt. Sei aufmerksam!" -Fast; Start-Sleep -Milliseconds 500; continue }

            $revealed[$idx1] = $true
            try { Clear-Host } catch {}
            Show-PetFrame "MEMORY — Du: $playerScore | $($cp.Name): $companionScore" -Double | Out-Null
            Write-Host ""
            for ($row = 0; $row -lt 4; $row++) {
                $line = "  "
                for ($col = 0; $col -lt 4; $col++) {
                    $idx = $row * 4 + $col
                    if ($revealed[$idx]) {
                        $line += "[$($deck[$idx])] "
                    } else {
                        $line += "[$(($idx + 1).ToString("D2"))] "
                    }
                }
                Write-Host $line -ForegroundColor White
            }

            $second = Read-Choice "Zweite Karte" '^([1-9]|1[0-6]|Q)$'
            if ($second -eq 'Q') { $revealed[$idx1] = $false; Save-PetState $pet; return }
            $idx2 = [int]$second - 1
            if ($revealed[$idx2] -or $idx1 -eq $idx2) {
                Show-CompanionDialog $cp "Ungueltige Wahl. Versuch es nochmal." -Fast
                $revealed[$idx1] = $false
                Start-Sleep -Milliseconds 500
                continue
            }
            $revealed[$idx2] = $true

            if ($deck[$idx1] -eq $deck[$idx2]) {
                Write-Host "`n  MATCH! $($deck[$idx1])" -ForegroundColor Green
                $playerScore++
                Show-CompanionDialog $cp (@("Gut gemacht!","Du hast ein gutes Gedaechtnis.","Pah. Zufall.") | Get-Random) -Fast
            } else {
                Write-Host "`n  Kein Match. $($deck[$idx1]) vs $($deck[$idx2])" -ForegroundColor Red
                Show-CompanionDialog $cp (@("Falsch!","Neeein.","Beobachte genauer.") | Get-Random) -Fast
                Start-Sleep -Milliseconds 800
                $revealed[$idx1] = $false
                $revealed[$idx2] = $false
            }
            $currentPlayer = "companion"
        } else {
            # Companion turn
            Write-Host "`n  $($cp.Name) ist dran..." -ForegroundColor Magenta
            Start-Sleep -Milliseconds 800

            $available = 0..15 | Where-Object { -not $revealed[$_] }
            $pick1 = $available | Get-Random
            $companionMemory[$pick1] = $deck[$pick1]

            # Try to find match from memory
            $match = $null
            if ((Get-Random -Maximum 100) -lt ($companionMemoryChance * 100)) {
                $sym = $deck[$pick1]
                $match = $companionMemory.GetEnumerator() | Where-Object { $_.Value -eq $sym -and $_.Key -ne $pick1 -and ($available -contains $_.Key) } | Select-Object -First 1
            }

            if ($match) {
                $pick2 = $match.Key
            } else {
                $available2 = $available | Where-Object { $_ -ne $pick1 }
                $pick2 = $available2 | Get-Random
                $companionMemory[$pick2] = $deck[$pick2]
            }

            $revealed[$pick1] = $true; $revealed[$pick2] = $true
            Write-Host "  $($cp.Name) waehlt Karten $($pick1 + 1) und $($pick2 + 1)..." -ForegroundColor Magenta
            Start-Sleep -Milliseconds 600

            if ($deck[$pick1] -eq $deck[$pick2]) {
                Write-Host "  MATCH! $($deck[$pick1])" -ForegroundColor Magenta
                $companionScore++
                Show-CompanionDialog $cp "Haha! Algorithmen schlagen Menschen!" -Fast
            } else {
                Write-Host "  Kein Match." -ForegroundColor DarkGray
                Show-CompanionDialog $cp (@("Mist.","Nur ein Fehler.","Du hast das bestimmt genossen.") | Get-Random) -Fast
                Start-Sleep -Milliseconds 600
                $revealed[$pick1] = $false
                $revealed[$pick2] = $false
            }
            $currentPlayer = "player"
        }
    }

    try { Clear-Host } catch {}
    Show-PetFrame "MEMORY — ERGEBNIS" -Double | Out-Null
    Write-Host "`n  Du: $playerScore | $($cp.Name): $companionScore" -ForegroundColor White

    if ($playerScore -gt $companionScore) {
        Write-Host "`n  DU GEWINNST!" -ForegroundColor Green
        $pet.CompanionGames.Wins++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_win") -Fast
    } elseif ($playerScore -lt $companionScore) {
        Write-Host "`n  $($cp.Name) GEWINNT!" -ForegroundColor Red
        $pet.CompanionGames.Losses++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
    } else {
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        Show-CompanionDialog $cp "Ein Unentschieden? Wie langweilig." -Fast
    }

    if ($turns -lt $pet.CompanionGames.MemoryBestTime) {
        $pet.CompanionGames.MemoryBestTime = $turns
        Write-Host "  NEUER REKORD: $turns Runden!" -ForegroundColor Green
    }

    Add-PetXP 8 "Memory"
    Save-PetState $pet
    Wait-Enter
}

} catch {
    Write-Host "Fehler in companion-games.ps1: $_" -ForegroundColor Red
}
