# BUXE_OS v24.0 -- BOOT SEQUENCE

try {

$script:SessionStart = Get-Date

$script:BuxTips = @(
    "Tipp: 'daily' gibt dir jeden Tag Gold + Streak-Bonus.",
    "Tipp: 'bank' zeigt deine komplette Finanzhistorie.",
    "Tipp: 'status' fuer Uebersicht. 'h' fuer Commands.",
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
        Write-Host "  $greeting, $env:USERNAME." -ForegroundColor White
        
        $loads = $b.Loads
        if ($loads -eq 1) { Write-Host "  Willkommen bei BUXE_OS v24. Tippe 'h' fuer Hilfe." -ForegroundColor DarkGray }
        elseif ($loads -lt 10) { Write-Host "  Session #$loads. Aufwaermen." -ForegroundColor DarkGray }
        elseif ($loads -lt 30) { Write-Host "  Session #$loads. Du lebst hier fast." -ForegroundColor DarkGray }
        elseif ($loads -lt 50) { Write-Host "  Session #$loads. Wir sind altbekannte." -ForegroundColor Yellow }
        else { Write-Host "  Session #$loads. Wir sind im Endgame now." -ForegroundColor Magenta }
        
        $tip = $script:BuxTips | Get-Random
        Write-Host "  $tip" -ForegroundColor DarkGray
        Write-Host "  Desktop Pet: 'dp-on' zum Aktivieren." -ForegroundColor DarkGray
        
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
        
        $m = Get-CimInstance Win32_OperatingSystem
        $t = [math]::Round($m.TotalVisibleMemorySize / 1MB, 2)
        $f = [math]::Round($m.FreePhysicalMemory / 1MB, 2)
        $u = $t - $f; $pct = [math]::Round(($u / $t) * 100)
        if ($pct -gt 75) {
            $col = if ($pct -gt 85) { "Red" } else { "Yellow" }
            Write-Host "  RAM: $u / $t GB ($pct%)" -ForegroundColor $col
        }
        $ach = ($script:BuxeState.Achievements | Get-Member -MemberType NoteProperty | Measure-Object).Count
        if ($ach -gt 0) { Write-Host "  Achievements: $ach freigeschaltet." -ForegroundColor DarkCyan }
        Write-Host ""
    } catch { Write-Host "[boot] Fehler: $_" -ForegroundColor Red }
}

} catch {
    Write-Host "[boot] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
