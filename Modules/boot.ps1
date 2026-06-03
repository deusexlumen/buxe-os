# BUXE_OS v24.0 -- BOOT SEQUENCE

try {

$script:SessionStart = Get-Date

$script:BuxTips = @(
    "Tipp: 'daily' gibt dir jeden Tag Gold + Streak-Bonus.",
    "Tipp: 'pet status' zeigt Companion + Battlepet auf einen Blick.",
    "Tipp: CasinoLuck und StrategyInsight leveln sich durch spielen.",
    "Tipp: 'capsule <text>' erstellt eine Zeitkapsel fuer spaeter.",
    "Tipp: Jede 5. Runde im Kampf ist ein Boss.",
    "Tipp: 'bank' zeigt deine komplette Finanzhistorie.",
    "Tipp: TUI-Spiele laufen ohne Clear-Host-Flicker.",
    "Tipp: Die Companion reagiert auf Uhrzeit, Mood und Easter Eggs.",
    "Tipp: 'h' listet ALLE verfuegbaren Commands.",
    "Tipp: Achievements persistieren ueber Sessions hinweg."
)

function Invoke-BootSequence {
    try {
        try { Clear-Host } catch {}
        Load-State
        $b = $script:BuxeState.Boot
        $b.Loads++
        $b.LastBoot = Get-Date -Format "yyyy-MM-dd HH:mm"
        Save-State
        
        $hour = (Get-Date).Hour
        $greeting = if ($hour -ge 5 -and $hour -lt 12) { "Guten Morgen" } elseif ($hour -ge 12 -and $hour -lt 18) { "Guten Tag" } elseif ($hour -ge 18 -and $hour -lt 22) { "Guten Abend" } else { "Noch wach" }
        
        Write-Host ""
        Write-Host "   BUXE_OS v24.0" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [INIT] Module laden..." -ForegroundColor Green
        Start-Sleep -Milliseconds 200
        Write-Host "  [OK]   State Manager v24" -ForegroundColor Green
        Write-Host "  [OK]   UI Framework v24" -ForegroundColor Green
        Write-Host "  [OK]   Game Engine v24" -ForegroundColor Green
        Write-Host "  [OK]   OhMyPosh renderer online" -ForegroundColor Green
        Write-Host "  [OK]   Zoxide memory banks mounted" -ForegroundColor Green
        Write-Host "  [OK]   User $env:USERNAME authenticated`n" -ForegroundColor Green
        Write-Host "  $greeting, $env:USERNAME." -ForegroundColor White
        
        $loads = $b.Loads
        if ($loads -eq 1) { Write-Host "  Willkommen bei BUXE_OS v24. Tippe 'h' fuer Hilfe." -ForegroundColor DarkGray }
        elseif ($loads -lt 10) { Write-Host "  Session #$loads. Aufwaermen." -ForegroundColor DarkGray }
        elseif ($loads -lt 30) { Write-Host "  Session #$loads. Du lebst hier fast." -ForegroundColor DarkGray }
        elseif ($loads -lt 50) { Write-Host "  Session #$loads. Wir sind altbekannte." -ForegroundColor Yellow }
        else { Write-Host "  Session #$loads. Wir sind im Endgame now." -ForegroundColor Magenta }
        
        $tip = $script:BuxTips | Get-Random
        Write-Host "  $tip" -ForegroundColor DarkGray
        
        $petData = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
        if (-not $petData) { $petData = $script:BuxeState.Companion }
        if ($petData -and $petData.Bond -ge 60) {
            $cp = $petData
            Write-Host "  [$($cp.Name)] >> $(if ($hour -lt 6) { 'Geh schlafen. Ich bin morgen noch da.' } else { 'Ready when you are, operator.' })" -ForegroundColor $cp.Color
        }
        
        $caps = $script:BuxeState.Capsules
        if ($caps) {
            $today = Get-Date; $opened = 0
            foreach ($cap in $caps) {
                try {
                    if ($today -ge [datetime]::Parse($cap.OpenDate)) {
                        $days = [math]::Floor(($today - [datetime]::Parse($cap.CreatedDate)).TotalDays)
                        Write-Host "`n  TIME CAPSULE from $days days ago:" -ForegroundColor Yellow
                        Write-Host "  `"$($cap.Message)`"" -ForegroundColor White
                        $opened++
                    }
                } catch {}
            }
            if ($opened -gt 0) {
                $script:BuxeState.Capsules = @($caps | Where-Object { try { $today -lt [datetime]::Parse($_.OpenDate) } catch { $false } })
                Save-State
            }
        }
        
        mem
        $ach = ($script:BuxeState.Achievements | Get-Member -MemberType NoteProperty | Measure-Object).Count
        Write-Host "  Achievements: $ach freigeschaltet." -ForegroundColor DarkCyan
        Write-Host ""
    } catch { Write-Host "[boot] Fehler: $_" -ForegroundColor Red }
}

} catch {
    Write-Host "[boot] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
