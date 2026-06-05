# BUXE_OS v24.5 -- ARCADE HUB
# Unified entry point for all arcade games.

try {

function Show-ArcadeStats {
    Load-State
    $a = $script:BuxeState.Arcade
    try { Clear-Host } catch {}
    Show-Frame "ARCADE STATS" -Double | Out-Null
    Write-Host ""
    Write-Host "  Tetris:       Best Score: $($a.Tetris.BestScore) | Lines: $($a.Tetris.BestLines)" -ForegroundColor Cyan
    Write-Host "  Snake:        Best Score: $($a.Snake.BestScore) | Games: $($a.Snake.Games)" -ForegroundColor Green
    Write-Host "  Minesweeper:  Wins: $($a.Minesweeper.Wins) | Best Time: $($a.Minesweeper.BestTime)s" -ForegroundColor Yellow
    Write-Host "  Breakout:     Best Score: $($a.Breakout.BestScore) | Level: $($a.Breakout.BestLevel)" -ForegroundColor Magenta
    Write-Host "  Wordle:       Streak: $($a.Wordle.Streak) | Best: $($a.Wordle.BestStreak)" -ForegroundColor White
    Write-Host "  Monkeytype:   Best WPM: $($a.MonkeyType.BestWPM) | Accuracy: $($a.MonkeyType.BestAccuracy)%" -ForegroundColor Cyan
    Write-Host "  Zork:         Rooms: $($a.Zork.RoomsExplored) | Items: $($a.Zork.ItemsFound)" -ForegroundColor Green
    Write-Host "  Hangman:      Won: $($a.Hangman.Won) | Lost: $($a.Hangman.Lost)" -ForegroundColor Yellow
    if ($a.Game2048.GamesPlayed -gt 0) {
        Write-Host "  2048:         Best Score: $($a.Game2048.BestScore) | Best Tile: $($a.Game2048.BestTile)" -ForegroundColor Cyan
    }
    if ($a.DinoJump.GamesPlayed -gt 0) {
        Write-Host "  Dino Jump:    Best Score: $($a.DinoJump.BestScore)" -ForegroundColor Green
    }
    if ($a.MemoryMatch.GamesPlayed -gt 0) {
        Write-Host "  Memory Match: Best Time: $($a.MemoryMatch.BestTime)s | Moves: $($a.MemoryMatch.BestMoves)" -ForegroundColor Magenta
    }
    Write-Host ""
    Wait-Enter
}

function arcade {
    param([string]$Game)
    if ($Game) {
        switch ($Game.ToLower()) {
            "tetris" { Start-Tetris }
            "snake" { Start-Snake }
            "minesweeper" { Start-Minesweeper }
            "breakout" { Start-Breakout }
            "wordle" { Start-Wordle }
            "monkeytype" { Start-MonkeyType }
            "zork" { Start-Zork }
            "hangman" { Start-Hangman }
            "2048" { Start-Game2048 }
            "dino" { Start-DinoJump }
            "memory" { Start-MemoryMatch }
            default { Write-Host "Unbekanntes Game: $Game" -ForegroundColor Red }
        }
        return
    }
    while ($true) {
        Load-State
        $a = $script:BuxeState.Arcade
        try { Clear-Host } catch {}
        Show-Frame "BUXE_ARCADE v24.5" -Double | Out-Null
        Write-Host ""
        Write-Host "  [1] Tetris          Best: $($a.Tetris.BestScore)" -ForegroundColor Cyan
        Write-Host "  [2] Snake           Best: $($a.Snake.BestScore)" -ForegroundColor Green
        Write-Host "  [3] Minesweeper     Best: $($a.Minesweeper.BestTime)s" -ForegroundColor Yellow
        Write-Host "  [4] Breakout        Best: Lv.$($a.Breakout.BestLevel)" -ForegroundColor Magenta
        Write-Host "  [5] Wordle          Streak: $($a.Wordle.Streak)" -ForegroundColor White
        Write-Host "  [6] Monkeytype      WPM: $($a.MonkeyType.BestWPM)" -ForegroundColor Cyan
        Write-Host "  [7] Zork            Rooms: $($a.Zork.RoomsExplored)" -ForegroundColor Green
        Write-Host "  [8] Hangman         Won: $($a.Hangman.Won)" -ForegroundColor Yellow
        Write-Host "  [9] 2048            Best: $($a.Game2048.BestScore)" -ForegroundColor Cyan
        Write-Host "  [0] Dino Jump       Best: $($a.DinoJump.BestScore)" -ForegroundColor Green
        Write-Host "  [M] Memory Match    Best: $($a.MemoryMatch.BestTime)s" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  [S] Stats Overview  |  [Q] Exit" -ForegroundColor DarkGray
        $c = Read-Choice "Waehle" '^[1234567890MSQ]$'
        switch ($c) {
            '1' { Start-Tetris }
            '2' { Start-Snake }
            '3' { Start-Minesweeper }
            '4' { Start-Breakout }
            '5' { Start-Wordle }
            '6' { Start-MonkeyType }
            '7' { Start-Zork }
            '8' { Start-Hangman }
            '9' { Start-Game2048 }
            '0' { Start-DinoJump }
            'M' { Start-MemoryMatch }
            'S' { Show-ArcadeStats }
            'Q' { return }
        }
    }
}

} catch {
    Write-Host "[arcade] CRITICAL ERROR: $_" -ForegroundColor Red
}
