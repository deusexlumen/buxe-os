# BUXE_OS v24.5 -- ARCADE HUB
# Unified entry point for all arcade games.

try {

# Load sub-modules if not already loaded (for direct arcade.ps1 sourcing)
$modulesDir = if ($PSScriptRoot) { $PSScriptRoot } else { Join-Path (Get-Location) "Modules" }
$subModules = @(
    "arcade-legacy.ps1", "arcade-minesweeper.ps1", "arcade-tetris.ps1",
    "arcade-monkeytype.ps1", "arcade-snake.ps1", "arcade-wordle.ps1",
    "arcade-breakout.ps1", "arcade-2048.ps1", "arcade-dino.ps1", "arcade-memory.ps1",
    "arcade-reflex.ps1"
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
    if ($a.Reflex.GamesPlayed -gt 0) {
        Write-Host "  Reflex Test:  Best Avg: $($a.Reflex.BestAvg)ms | Games: $($a.Reflex.GamesPlayed)" -ForegroundColor Cyan
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
            "reflex" { Start-ReflexTest }
            default { Write-Host "Unbekanntes Game: $Game" -ForegroundColor Red }
        }
        return
    }
    while ($true) {
        $items = @(
            @{ Key = '1'; Label = 'Tetris'; Color = 'Cyan' },
            @{ Key = '2'; Label = 'Snake'; Color = 'Green' },
            @{ Key = '3'; Label = 'Minesweeper'; Color = 'Yellow' },
            @{ Key = '4'; Label = 'Breakout'; Color = 'Magenta' },
            @{ Key = '5'; Label = 'Wordle'; Color = 'White' },
            @{ Key = '6'; Label = 'Monkeytype'; Color = 'Cyan' },
            @{ Key = '7'; Label = 'Zork'; Color = 'Green' },
            @{ Key = '8'; Label = 'Hangman'; Color = 'Yellow' },
            @{ Key = '9'; Label = '2048'; Color = 'Cyan' },
            @{ Key = '0'; Label = 'Dino Jump'; Color = 'Green' },
            @{ Key = 'M'; Label = 'Memory Match'; Color = 'Magenta' },
            @{ Key = 'R'; Label = 'Reflex Test'; Color = 'Cyan' },
            @{ Key = 'S'; Label = 'Stats'; Color = 'DarkGray' }
        )
        $c = Show-MenuEx -Title "BUXE_ARCADE v24.5" -Items $items -Clear
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
            'R' { Start-ReflexTest }
            'S' { Show-ArcadeStats }
            'Q' { return }
        }
    }
}

} catch {
    Write-Host "[arcade] CRITICAL ERROR: $_" -ForegroundColor Red
}
