# BUXE_OS v24.0 -- SYSTEM ALIASES

try {

function uptime { 
    $t = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "  System uptime: $($t.Days)d $($t.Hours)h $($t.Minutes)m" -ForegroundColor Cyan
}
function weather { 
    try { 
        $r = Invoke-RestMethod "wttr.in/?format=3" -TimeoutSec 8
        Write-Host "`n  Wetter: $r`n" -ForegroundColor Cyan
    } catch { 
        Write-Host "  Wetter-API nicht erreichbar." -ForegroundColor DarkGray 
    }
}
function ip {
    try {
        $r = Invoke-RestMethod "https://ipinfo.io/json" -TimeoutSec 5
        Write-Host "`n  Public IP: $($r.ip)" -ForegroundColor Cyan
        Write-Host "  $($r.city), $($r.region), $($r.country)" -ForegroundColor DarkGray
        Write-Host "  $($r.org)`n" -ForegroundColor DarkGray
    } catch { Write-Host "  IP-API nicht erreichbar." -ForegroundColor DarkGray }
}
function port { param($p); Test-NetConnection -ComputerName localhost -Port $p }
function mem {
    $m = Get-CimInstance Win32_OperatingSystem
    $t = [math]::Round($m.TotalVisibleMemorySize / 1MB, 2)
    $f = [math]::Round($m.FreePhysicalMemory / 1MB, 2)
    $u = $t - $f; $pct = [math]::Round(($u / $t) * 100)
    $col = if ($pct -gt 85) { "Red" } elseif ($pct -gt 60) { "Yellow" } else { "Green" }
    Write-Host ("`n  RAM: $u / $t GB (" + $pct + '%)') -ForegroundColor $col
}
function sysinfo {
    Write-Host "`n  $($env:COMPUTERNAME) | $env:USERNAME" -ForegroundColor Cyan
    Write-Host "  $((Get-CimInstance Win32_OperatingSystem).Caption)" -ForegroundColor Cyan
    Write-Host "  PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
    mem
}
function sudo { Start-Process pwsh -Verb runAs }
function reload { . $PROFILE }
function profile { notepad $PROFILE }

} catch {
    Write-Host "[engine-aliases-sys] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
