$files = @(
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\_init.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\companion.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\_ui.ps1',
    'C:\Users\Buxe\Documents\PowerShell\Modules\pet\hub.ps1'
)
foreach ($f in $files) {
    $err = @()
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $f -Raw), [ref]$err)
    $name = Split-Path $f -Leaf
    if ($err.Count -gt 0) {
        Write-Host ("FEHLER in $name :") -ForegroundColor Red
        foreach ($e in $err | Select-Object -First 3) {
            Write-Host ("  Zeile " + $e.Token.StartLine + ": " + $e.Message) -ForegroundColor DarkGray
        }
    } else {
        Write-Host ("OK: $name") -ForegroundColor Green
    }
}
