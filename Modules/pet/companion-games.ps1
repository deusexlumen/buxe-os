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
    $guesses = 0; $maxGuesses = 7

    while ($guesses -lt $maxGuesses) {
        try { Clear-Host } catch {}
        Show-PetFrame "42 ODER 47 — Versuch $($guesses + 1)/$maxGuesses" -Double | Out-Null

        Write-Host "`n  Gib eine Zahl ein (1-100):" -ForegroundColor Cyan
        $input = Read-Host "  Zahl"
        if (-not [int]::TryParse($input, [ref]$null)) { continue }
        $guess = [int]$input
        if ($guess -lt 1 -or $guess -gt 100) { continue }

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

    if ($guess -ne $target) {
        Write-Host "`n  Die Zahl war $target. Du hast verloren." -ForegroundColor Red
        $pet.CompanionGames.Losses++
        Show-CompanionDialog $cp (Get-CompanionLine $cp "game_lose") -Fast
    }

    Add-PetXP 5 "42or47"
    Save-PetState $pet
    Wait-Enter
}

} catch {
    Write-Host "Fehler in companion-games.ps1: $_" -ForegroundColor Red
}
