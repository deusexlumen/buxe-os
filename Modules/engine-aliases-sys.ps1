# BUXE_OS v24.0 -- SYSTEM ALIASES

try {

function uptime { 
    $t = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "  System uptime: $($t.Days)d $($t.Hours)h $($t.Minutes)m" -ForegroundColor Cyan
}
function weather { 
    try { 
        $r = Invoke-RestMethod "https://wttr.in/?format=3" -TimeoutSec 8
        Write-Host "`n  Wetter: $r`n" -ForegroundColor Cyan
    } catch { 
        Write-Host "  Wetter-API nicht erreichbar." -ForegroundColor DarkGray 
    }
}
function ip {
    $local = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } | Select-Object -First 1
    if ($local) {
        Write-Host "`n  Local IP: $($local.IPAddress)" -ForegroundColor Cyan
        Write-Host "  Interface: $($local.InterfaceAlias)`n" -ForegroundColor DarkGray
    } else {
        Write-Host "`n  Keine lokale IPv4 gefunden.`n" -ForegroundColor DarkGray
    }
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
function guide { notepad (Join-Path (Split-Path $PROFILE) "GUIDE.md") }

# === DEV WORKFLOW ALIASES ===
function kill-node {
    $procs = Get-Process -Name "node" -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force
        Write-Host "  $(($procs | Measure-Object).Count) Node.js Prozess(e) beendet." -ForegroundColor Green
    } else {
        Write-Host "  Keine Node.js Prozesse laufen." -ForegroundColor DarkGray
    }
}
function kill-port {
    param([int]$Port)
    $conn = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $conn) { Write-Host "  Port $Port ist frei." -ForegroundColor DarkGray; return }
    $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
    if ($proc) {
        $proc | Stop-Process -Force
        Write-Host "  Prozess $($proc.ProcessName) (PID $($proc.Id)) auf Port $Port beendet." -ForegroundColor Green
    }
}
function npmo { npm outdated }
function size {
    param([string]$Path = ".")
    $items = Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue
    $bytes = ($items | Measure-Object -Property Length -Sum).Sum
    $size = if ($bytes -gt 1GB) { "{0:N2} GB" -f ($bytes / 1GB) } elseif ($bytes -gt 1MB) { "{0:N2} MB" -f ($bytes / 1MB) } else { "{0:N2} KB" -f ($bytes / 1KB) }
    Write-Host "`n  $Path = $size ($($items.Count) Dateien)`n" -ForegroundColor Cyan
}
function tmp-clean {
    $before = (Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    $after = (Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "`n  Temp bereinigt: $before -> $after Dateien/Ordner uebrig.`n" -ForegroundColor Green
}
function flush-dns { ipconfig /flushdns | Out-Null; Write-Host "`n  DNS-Cache geleert.`n" -ForegroundColor Green }
function empty-bin {
    $isWindowsOS = ($env:OS -eq 'Windows_NT') -or ($IsWindows -eq $true)
    if (-not $isWindowsOS) {
        Write-Host "`n  empty-bin ist nur unter Windows verfuegbar.`n" -ForegroundColor Yellow
        return
    }

    try {
        $shell = New-Object -ComObject Shell.Application
        $bin = $shell.Namespace(0xA)
        $beforeCount = $bin.Items().Count

        try {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        } catch { }

        $items = $bin.Items()
        $count = $items.Count
        if ($count -eq 0) {
            if ($beforeCount -eq 0) {
                Write-Host "`n  Papierkorb bereits leer.`n" -ForegroundColor DarkGray
            } else {
                Write-Host "`n  Papierkorb geleert.`n" -ForegroundColor Green
            }
        } else {
            foreach ($item in $items) {
                try { Remove-Item $item.Path -Recurse -Force -ErrorAction SilentlyContinue } catch { }
            }
            $remaining = $bin.Items().Count
            if ($remaining -eq 0) {
                Write-Host "`n  Papierkorb geleert.`n" -ForegroundColor Green
            } else {
                Write-Host "`n  Papierkorb konnte nicht vollstaendig geleert werden (noch $remaining Eintraege)." -ForegroundColor Yellow
            }
        }
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
    } catch {
        Write-Host "`n  Papierkorb konnte nicht geleert werden." -ForegroundColor Red
    }
}

} catch {
    Write-Host "[engine-aliases-sys] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
