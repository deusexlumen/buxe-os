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

} catch {
    Write-Host "Fehler in companion-games.ps1: $_" -ForegroundColor Red
}
