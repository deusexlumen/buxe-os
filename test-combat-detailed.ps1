$err = @()
$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content 'C:\Users\Buxe\Documents\PowerShell\Modules\pet\combat.ps1' -Raw), [ref]$err)
foreach ($e in $err) {
    Write-Host ('Zeile ' + $e.Token.StartLine + ' Char ' + $e.Token.StartColumn + ': ' + $e.Message)
    Write-Host ('  Token: ' + $e.Token.Content)
}
