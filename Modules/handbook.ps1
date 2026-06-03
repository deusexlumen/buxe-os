# BUXE_OS v24.0 -- HANDBOOK (Wrapper)
# Laedt alle Handbook-Submodul via Dot-Sourcing.

$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$modDir\handbook-core.ps1"
. "$modDir\handbook-combat.ps1"
. "$modDir\handbook-elements.ps1"
. "$modDir\handbook-status.ps1"
. "$modDir\handbook-skills.ps1"
. "$modDir\handbook-equipment.ps1"
. "$modDir\handbook-casino.ps1"
. "$modDir\handbook-companion.ps1"
. "$modDir\handbook-commands.ps1"
