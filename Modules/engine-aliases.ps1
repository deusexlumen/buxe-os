# BUXE_OS v24.0 -- TERMINAL ALIASES (Wrapper)
# Laedt alle Alias-Submodul via Dot-Sourcing.

$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$modDir\engine-aliases-nav.ps1"
. "$modDir\engine-aliases-git.ps1"
. "$modDir\engine-aliases-pnpm.ps1"
. "$modDir\engine-aliases-sys.ps1"
. "$modDir\engine-aliases-buxe.ps1"
