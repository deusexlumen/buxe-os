# BUXE_OS v24.3 -- MONKEYTYPE (TUI)
# Migriert auf TUI-Framework: Show-Scene + Read-Host (Text-Input).

try {

function monkeytype {
    $words = @("algorithm","bandwidth","cybernetic","debugging","encryption","firewall","gigabyte","hardware","interface","javascript","kernel","latency","malware","network","operating","protocol","quantum","router","system","terminal","unix","virtual","wireless","xenon","yield","zipfile","powershell","repository","framework","container","kubernetes","blockchain","cryptography","datacenter","ethernet","filesystem","gateway","hyperlink","iteration","junction","keystore","localhost","middleware","namespace","overlay","pipeline","queryset","runtime","sandbox","timestamp","upstream","viewport","webhook","xmlhttp","yamlfile","zeroday")
    $target = ($words | Get-Random -Count 10) -join ' '
    
    Reset-RenderBuffer
    $w = 70; $h = 12
    
    # Pre-game scene
    $s = New-Scene $w $h
    Add-SceneFrame $s 0 0 $w $h "MONKEYTYPE" 'Cyan' -Double
    Add-SceneText $s 4 2 "Tippe diesen Satz so schnell wie moeglich:" 'White'
    Add-SceneText $s 4 4 $target 'Yellow'
    Add-SceneText $s 4 7 "[ENTER] Start" 'Green'
    Add-SceneText $s 4 8 "[Q] Quit" 'DarkGray'
    Show-Scene $s -Force
    
    $act = Read-GameChoice "" "^[Q]$"
    if ($act -eq 'Q') { return }
    
    # Input phase
    [Console]::CursorVisible = $true
    $start = Get-Date
    $input = Read-Host "  >"
    $elapsed = (Get-Date) - $start
    [Console]::CursorVisible = $false
    $seconds = $elapsed.TotalSeconds
    
    # Result scene
    $rs = New-Scene $w $h
    Add-SceneFrame $rs 0 0 $w $h "MONKEYTYPE" 'Cyan' -Double
    
    if ($input.Trim() -eq $target) {
        $wpm = [math]::Round(($target.Split(' ').Count / $seconds) * 60)
        Add-SceneText $rs 4 2 "PERFECT!" 'Green'
        Add-SceneText $rs 4 3 "Zeit: $([math]::Round($seconds,1))s | WPM: $wpm" 'Cyan'
        
        Load-State
        $stats = Get-ArcadeStats "MonkeyType"
        $isRecord = $false
        if ($wpm -gt $stats.BestWPM) { 
            $stats.BestWPM = $wpm; 
            Set-ArcadeStats "MonkeyType" $stats
            $isRecord = $true
        }
        if ($isRecord) { Add-SceneText $rs 4 5 "NEUER REKORD!" 'Yellow' }
        if ($wpm -ge 60) { 
            Unlock-Achievement "Speed Demon"
            Add-SceneText $rs 4 6 "Achievement: Speed Demon!" 'Magenta'
        }
    } else {
        Add-SceneText $rs 4 2 "Fehler!" 'Red'
        Add-SceneText $rs 4 3 "Deine Eingabe war nicht korrekt." 'DarkGray'
        Add-SceneText $rs 4 5 "Erwartet: $target" 'Yellow'
        Add-SceneText $rs 4 6 "Deine:    $($input.Trim())" 'DarkGray'
    }
    
    Show-Scene $rs -Force
    Wait-Enter
}

} catch {
    Write-Host "[arcade-monkeytype] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
