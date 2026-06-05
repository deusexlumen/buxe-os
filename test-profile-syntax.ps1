$err = @()
$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content 'C:\Users\Buxe\Documents\PowerShell\Microsoft.PowerShell_profile.ps1' -Raw), [ref]$err)
if ($err.Count -gt 0) {
    foreach ($e in $err) {
        Write-Host ("FEHLER Zeile " + $e.Token.StartLine + ": " + $e.Message) -ForegroundColor Red
    }
} else {
    Write-Host "Syntax OK" -ForegroundColor Green
}
