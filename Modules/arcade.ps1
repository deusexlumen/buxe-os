# BUXE_OS v24.0 -- ARCADE (Wrapper)
# Laedt alle Arcade-Submodul via Dot-Sourcing.

$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$modDir\arcade-monkeytype.ps1"
. "$modDir\arcade-snake.ps1"
. "$modDir\arcade-wordle.ps1"
. "$modDir\arcade-legacy.ps1"
. "$modDir\arcade-minesweeper.ps1"
. "$modDir\arcade-tetris.ps1"
