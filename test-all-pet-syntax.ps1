$files = @(
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\_init.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\companion.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\_ui.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\hub.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\events.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\_unlock.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\combat.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\casino-engine.ps1'
)
$allOk = $true
foreach ($f in $files) {
    $err = @()
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $f -Raw), [ref]$err)
    $name = Split-Path $f -Leaf
    $realErrors = $err | Where-Object { $_.Message -notmatch 'Abschlusszeichen' -and $_.Message -notmatch 'Unicode' }
    if ($realErrors.Count -gt 0) {
        Write-Host ("FEHLER in $name :") -ForegroundColor Red
        foreach ($e in $realErrors | Select-Object -First 2) {
            Write-Host ("  Zeile " + $e.Token.StartLine + ": " + $e.Message) -ForegroundColor DarkGray
        }
        $allOk = $false
    } else {
        Write-Host ("OK: $name") -ForegroundColor Green
    }
}
if ($allOk) { Write-Host "`nALLE DATEIEN OK" -ForegroundColor Green }
