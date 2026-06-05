# BUXE_OS v24.5 -- ARCADE HUB
# Unified entry point for all arcade games.

try {

# Load sub-modules if not already loaded (for direct arcade.ps1 sourcing)
$modulesDir = if ($PSScriptRoot) { $PSScriptRoot } else { Join-Path (Get-Location) "Modules" }
$subModules = @(
    "arcade-legacy.ps1", "arcade-minesweeper.ps1", "arcade-tetris.ps1",
    "arcade-monkeytype.ps1", "arcade-snake.ps1", "arcade-wordle.ps1",
    "arcade-breakout.ps1", "arcade-2048.ps1", "arcade-dino.ps1", "arcade-memory.ps1"
)
foreach ($sm in $subModules) {
    $smPath = Join-Path $modulesDir $sm
    if (Test-Path $smPath) { . $smPath }
}

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
            "tetris" { tetris }
            "snake" { snake }
            "minesweeper" { minesweeper }
            "breakout" { breakout }
            "wordle" { wordle }
            "monkeytype" { monkeytype }
            "zork" { zork }
            "hangman" { hangman }
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
            '1' { tetris }
            '2' { snake }
            '3' { minesweeper }
            '4' { breakout }
            '5' { wordle }
            '6' { monkeytype }
            '7' { zork }
            '8' { hangman }
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
