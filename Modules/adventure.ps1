# BUXE_OS v24.7 -- ADVENTURE MAIN
# LucasArts-Style Point-and-Click Text Adventure.
# Befehl: 'adventure' oder 'adv'

try {

function Invoke-Adventure {
    Load-AdventureState
    if (-not $script:AdvState) { $script:AdvState = Get-AdventureDefaults }

    try { Clear-Host } catch {}
    Show-Frame "DIE VERLORENE STATION POLARIS" -Width 50 -Double
    Write-Host ""
    Write-Host "  Ein Text-Adventure im LucasArts-Stil." -ForegroundColor White
    Write-Host "  Tippe 'help' oder 'h' für eine Befehlsübersicht." -ForegroundColor DarkGray
    Write-Host "  Tippe 'quit' oder 'q' um zu beenden." -ForegroundColor DarkGray
    Write-Host ""
    Wait-Enter

    $running = $true
    $firstRoom = $true

    while ($running) {
        try { Clear-Host } catch {}
        $room = Get-Room $script:AdvState.CurrentRoom

        # Show room
        Show-AdventureRoom $room
        Write-Host ""

        # Companion comment (LucasArts style)
        $cpCtx = if ($firstRoom) { "adventure_start" } else { $room.CompanionContext }
        if (Get-Command Show-GameCompanionComment -ErrorAction SilentlyContinue) {
            Show-GameCompanionComment $cpCtx
        }
        $firstRoom = $false

        Write-Host ""
        $prompt = "[$($script:AdvState.CurrentRoom)] > "

        # Input (mock-aware for tests)
        $inputLine = ""
        if ($script:MockInputEnabled -and $script:MockStringQueue.Count -gt 0) {
            $inputLine = $script:MockStringQueue[0]
            $script:MockStringQueue = $script:MockStringQueue | Select-Object -Skip 1
            Write-Host "$prompt$inputLine" -ForegroundColor DarkGray
        } else {
            $inputLine = Read-Host "  $prompt"
        }

        if (-not $inputLine) { continue }
        if ($inputLine -eq "Q" -or $inputLine -eq "q") { $running = $false; continue }

        $cmd = Parse-AdventureCommand $inputLine
        $result = Process-AdventureCommand $cmd

        if ($result.Message -eq "QUIT") {
            $running = $false
            continue
        }

        if ($result.Message) {
            Write-Host ""
            $msgLines = $result.Message -split "`n"
            foreach ($ml in $msgLines) {
                Write-Host "  $ml" -ForegroundColor $(if ($result.Success) { "White" } else { "Red" })
            }
        }

        # Companion reaction to action
        if ($result.CompanionContext -and (Get-Command Show-GameCompanionComment -ErrorAction SilentlyContinue)) {
            Show-GameCompanionComment $result.CompanionContext
        }

        # Check win
        if ($script:AdvState.Flags["game_won"]) {
            Wait-Enter
            $running = $false
            continue
        }

        Write-Host ""
        Wait-Enter
    }

    try { Clear-Host } catch {}
    Write-Host "  Adventure beendet. Bis zum nächsten Abenteuer!" -ForegroundColor Cyan
    Start-Sleep -Milliseconds 500
}

# === ALIASES ===
Set-Alias -Name adv -Value Invoke-Adventure -Scope Global -ErrorAction SilentlyContinue

} catch {
    Write-Host "[ADVENTURE] Fehler: $_" -ForegroundColor Red
}
