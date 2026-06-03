# BUXE_OS v24.0 -- MONKEYTYPE

try {

function monkeytype {
    $words = @("algorithm","bandwidth","cybernetic","debugging","encryption","firewall","gigabyte","hardware","interface","javascript","kernel","latency","malware","network","operating","protocol","quantum","router","system","terminal","unix","virtual","wireless","xenon","yield","zipfile","powershell","repository","framework","container","kubernetes","blockchain","cryptography","datacenter","ethernet","filesystem","gateway","hyperlink","iteration","junction","keystore","localhost","middleware","namespace","overlay","pipeline","queryset","runtime","sandbox","timestamp","upstream","viewport","webhook","xmlhttp","yamlfile","zeroday")
    Clear-Screen "MONKEYTYPE"
    $target = ($words | Get-Random -Count 10) -join ' '
    Write-Host "`n  Tippe diesen Satz so schnell wie moeglich:" -ForegroundColor Cyan
    Write-Host "  $target" -ForegroundColor White
    Write-Host ""
    $start = Get-Date
    $input = Read-Host "  >"
    $elapsed = (Get-Date) - $start
    $seconds = $elapsed.TotalSeconds
    
    if ($input.Trim() -eq $target) {
        $wpm = [math]::Round(($target.Split(' ').Count / $seconds) * 60)
        Write-Host "`n  PERFECT! Zeit: $([math]::Round($seconds,1))s | WPM: $wpm" -ForegroundColor Green
        Load-State
        $stats = Get-ArcadeStats "MonkeyType"
        if ($wpm -gt $stats.BestWPM) { $stats.BestWPM = $wpm; Set-ArcadeStats "MonkeyType" $stats; Write-Host "  NEUER REKORD!" -ForegroundColor Yellow }
        if ($wpm -ge 60) { Unlock-Achievement "Speed Demon" }
    } else {
        Write-Host "`n  Fehler! Versuch es erneut." -ForegroundColor Red
    }
    Wait-Enter
}

} catch {
    Write-Host "[arcade-monkeytype] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
