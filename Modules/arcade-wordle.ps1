# BUXE_OS v24.0 -- WORDLE

try {

function wordle {
    $words = @("POWER","SHELL","LINUX","CODER","AGENT","TERMINAL","SCRIPT","MODULE","KERNEL","DOCKER","KUBERNETES")
    $target = ($words | Get-Random).ToUpper()
    Clear-Screen "WORDLE"
    Write-Host "`n  Errate das Wort in 6 Versuchen!" -ForegroundColor Cyan
    $attempts = 0; $maxAttempts = 6
    while ($attempts -lt $maxAttempts) {
        $guess = (Read-Host "  Versuch $($attempts+1)/$maxAttempts").ToUpper()
        if ($guess.Length -ne $target.Length) { Write-Host "  Ungueltige Laenge! ($($target.Length) Buchstaben)" -ForegroundColor Red; continue }
        $attempts++
        $result = ""
        for ($i = 0; $i -lt $target.Length; $i++) {
            if ($i -lt $guess.Length -and $guess[$i] -eq $target[$i]) {
                Write-Host $guess[$i] -ForegroundColor Green -NoNewline
            } elseif ($target.Contains($guess[$i])) {
                Write-Host $guess[$i] -ForegroundColor Yellow -NoNewline
            } else {
                Write-Host $guess[$i] -ForegroundColor DarkGray -NoNewline
            }
        }
        Write-Host ""
        if ($guess -eq $target) {
            Write-Host "`n  RICHTIG! '$target' in $attempts Versuchen!" -ForegroundColor Green
            Load-State
            $stats = Get-ArcadeStats "Wordle"
            $stats.Played++; $stats.Streak++
            if ($stats.Streak -gt $stats.BestStreak) { $stats.BestStreak = $stats.Streak }
            Set-ArcadeStats "Wordle" $stats
            if ($attempts -le 3) { Unlock-Achievement "Wordle Master" }
            Wait-Enter; return
        }
    }
    Write-Host "`n  Game Over! Das Wort war: $target" -ForegroundColor Red
    Load-State
    $stats = Get-ArcadeStats "Wordle"
    $stats.Played++; $stats.Streak = 0
    Set-ArcadeStats "Wordle" $stats
    Wait-Enter
}

} catch {
    Write-Host "[arcade-wordle] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
