# BUXE_OS v24.5 -- REFLEX TEST
# Wie schnell bist du wirklich? 3 Runden, zufaellige Verzoegerung.

try {

function Start-ReflexTest {
    try { Clear-Host } catch {}
    Show-Frame "REFLEX TEST" -Double | Out-Null
    Write-Host ""
    Write-Host "  Teste deine Reaktionszeit. 3 Runden." -ForegroundColor DarkGray
    Write-Host "  Druecke ENTER sobald 'GO!' erscheint." -ForegroundColor DarkGray
    Write-Host "  Vorzeitiges Druecken = Fehlstart (5s Strafe)." -ForegroundColor DarkGray
    Write-Host ""
    Wait-Enter

    $times = @()
    for ($round = 1; $round -le 3; $round++) {
        try { Clear-Host } catch {}
        Show-Frame "REFLEX TEST — Runde $round/3" -Double | Out-Null
        Write-Host ""
        Write-Host "  Bereit..." -ForegroundColor Yellow

        # Anti-Cheat: pruefe ob Enter schon gedrueckt wird
        $waitMs = Get-Random -Minimum 1000 -Maximum 4000
        $startWait = Get-Date
        $falseStart = $false
        while (((Get-Date) - $startWait).TotalMilliseconds -lt $waitMs) {
            if ([Console]::KeyAvailable) {
                $k = [Console]::ReadKey($true)
                if ($k.Key -eq "Enter") {
                    $falseStart = $true
                    break
                }
            }
            Start-Sleep -Milliseconds 50
        }

        if ($falseStart) {
            Write-Host "  FEHLSTART! +5000ms Strafe." -ForegroundColor Red
            $times += 5000
            Start-Sleep -Seconds 1
            continue
        }

        Write-Host "  GO! DRUECKE ENTER!" -ForegroundColor Green
        $goTime = Get-Date

        # Warte auf Enter
        $reacted = $false
        while (-not $reacted) {
            if ([Console]::KeyAvailable) {
                $k = [Console]::ReadKey($true)
                if ($k.Key -eq "Enter") {
                    $reacted = $true
                }
            }
            Start-Sleep -Milliseconds 10
        }

        $elapsed = [math]::Round(((Get-Date) - $goTime).TotalMilliseconds)
        $times += $elapsed
        $color = if ($elapsed -lt 200) { "Magenta" } elseif ($elapsed -lt 300) { "Green" } elseif ($elapsed -lt 400) { "Yellow" } else { "Red" }
        Write-Host "  Zeit: ${elapsed}ms" -ForegroundColor $color
        Start-Sleep -Seconds 1
    }

    # Ergebnis
    try { Clear-Host } catch {}
    Show-Frame "REFLEX TEST — ERGEBNIS" -Double | Out-Null
    Write-Host ""
    $avg = [math]::Round(($times | Measure-Object -Average).Average)
    foreach ($t in $times) {
        $tc = if ($t -lt 200) { "Magenta" } elseif ($t -lt 300) { "Green" } elseif ($t -lt 400) { "Yellow" } else { "Red" }
        Write-Host "  Runde: ${t}ms" -ForegroundColor $tc
    }
    Write-Host ""
    $avgColor = if ($avg -lt 250) { "Magenta" } elseif ($avg -lt 350) { "Green" } elseif ($avg -lt 450) { "Yellow" } else { "Red" }
    Write-Host "  Durchschnitt: ${avg}ms" -ForegroundColor $avgColor

    # Rating
    $rating = switch ($avg) {
        { $_ -lt 200 } { "TRANSHUMAN" }
        { $_ -lt 250 } { "LEGENDARY" }
        { $_ -lt 300 } { "ELITE" }
        { $_ -lt 350 } { "FAST" }
        { $_ -lt 400 } { "AVERAGE" }
        { $_ -lt 500 } { "SLOW" }
        default { "GLACIAL" }
    }
    Write-Host "  Rating: $rating" -ForegroundColor $avgColor

    # High Score
    Load-State
    $a = $script:BuxeState.Arcade
    if (-not $a.Reflex) { $a.Reflex = @{ BestAvg = 9999; GamesPlayed = 0; LastAvg = 0 } }
    $a.Reflex.GamesPlayed++
    $a.Reflex.LastAvg = $avg
    $isNewBest = $false
    if ($avg -lt $a.Reflex.BestAvg) {
        $a.Reflex.BestAvg = $avg
        $isNewBest = $true
        Write-Host "  *** NEUER REKORD! ***" -ForegroundColor Magenta
        if ($avg -lt 200) { Unlock-Achievement "Transhuman Reflexes" }
        elseif ($avg -lt 250) { Unlock-Achievement "Lightning Reflexes" }
    }
    Save-State

    # Companion Kommentar
    if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
        $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if (-not $cp) { $cp = $script:BuxeState.Companion }
        if ($cp) {
            $line = if ($isNewBest) { "${avg}ms? Das ist schneller als meine CPU-Taktrate! ...fast." }
                    elseif ($avg -lt 300) { "Schnell. Aber ich habe dich beim Ueberlegen gesehen." }
                    elseif ($avg -lt 400) { "Menschliche Reflexe. Suess." }
                    else { "Hast du auf 'Send' oder 'Enter' gewartet?" }
            Show-CompanionDialog $cp $line -Fast
        }
    }

    Write-Host ""
    Wait-Enter
}

function reflex { Start-ReflexTest }

} catch {
    Write-Host "[arcade-reflex] CRITICAL ERROR: $_" -ForegroundColor Red
}
