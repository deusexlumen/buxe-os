# BUXE_OS v24.0 - PowerShell 7/5.1 Compatible Profile
# DEBUG MODE: $env:BUXE_DEBUG=1 deaktiviert globales try/catch fuer Stacktraces

$script:BuxeTryCatch = if ($env:BUXE_DEBUG) { $false } else { $true }

$BuxeProfileScript = {

# === PSSCRIPTROOT VALIDATION ===
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

# === MODULES & TOOLS ===
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSFzf -ErrorAction SilentlyContinue
try { oh-my-posh init pwsh --config "$PSScriptRoot\buxe.omp.json" | Invoke-Expression } catch { Write-Host "  [WARN] OhMyPosh not available" -ForegroundColor DarkGray }
try { Invoke-Expression (& { (zoxide init powershell | Out-String) }) } catch { Write-Host "  [WARN] Zoxide not available" -ForegroundColor DarkGray }

Remove-Item alias:h -Force -ErrorAction SilentlyContinue
Remove-Item alias:sl -Force -ErrorAction SilentlyContinue

# === LOAD v24 ENGINE ===
$modulesDir = Join-Path $PSScriptRoot "modules"

# Critical engine modules must exist
$criticalModules = @("engine-state-core","engine-state-migration","engine-state-advanced")
foreach ($cm in $criticalModules) {
    $cmPath = "$modulesDir\$cm.ps1"
    if (-not (Test-Path $cmPath)) {
        throw "CRITICAL MODULE MISSING: $cmPath"
    }
}

. "$modulesDir\engine-state-core.ps1"
. "$modulesDir\engine-state-migration.ps1"
. "$modulesDir\engine-state-advanced.ps1"
Load-State
. "$modulesDir\engine-arg.ps1"
. "$modulesDir\engine-ui.ps1"
. "$modulesDir\engine-game.ps1"
. "$modulesDir\engine-render.ps1"
. "$modulesDir\engine-input.ps1"
. "$modulesDir\engine-scene.ps1"
. "$modulesDir\engine-aliases.ps1"
. "$modulesDir\boot.ps1"
. "$modulesDir\casino-engine.ps1"
. "$modulesDir\casino-blackjack.ps1"
. "$modulesDir\casino-roulette.ps1"
. "$modulesDir\casino-craps.ps1"
. "$modulesDir\casino-hilo.ps1"
. "$modulesDir\casino-baccarat.ps1"
. "$modulesDir\casino-slot.ps1"
. "$modulesDir\casino-keno.ps1"
. "$modulesDir\casino-wheel.ps1"
. "$modulesDir\casino.ps1"
. "$modulesDir\arcade.ps1"
. "$modulesDir\strategy-poker.ps1"
. "$modulesDir\strategy-td.ps1"
. "$modulesDir\strategy-rogue.ps1"
# === LOAD ADVENTURE MODULES ===
. "$modulesDir\adventure-engine.ps1"
. "$modulesDir\adventure-world.ps1"
. "$modulesDir\adventure-companion-ai.ps1"
. "$modulesDir\adventure.ps1"
. "$modulesDir\adventure-insult.ps1"
. "$modulesDir\desktop-pet.ps1"
# === LOAD PET SYSTEM v2.0 ===
# _init.ps1 must load first for deterministic order
$petInit = "$modulesDir\pet\_init.ps1"
if (Test-Path $petInit) { . $petInit }
$petModules = Get-ChildItem "$modulesDir\pet\*.ps1" | Where-Object { $_.Name -ne "_init.ps1" } | Sort-Object Name
foreach ($pm in $petModules) {
    try { . $pm.FullName } catch { Write-Host "  [WARN] Pet module $($pm.Name) failed: $_" -ForegroundColor DarkGray }
}
. "$modulesDir\fun.ps1"
. "$modulesDir\handbook.ps1"
. "$modulesDir\tts-engine.ps1"

# === BOOT SEQUENCE ===
Invoke-BootSequence

}

if ($script:BuxeTryCatch) {
    try {
        . $BuxeProfileScript
    } catch {
        Write-Host "Fehler beim Laden des Profils: $_" -ForegroundColor Red
        # Fallback mode: minimal state so basic commands still work
        $script:BuxeState = @{
            Bank = @{ Gold = 500; CasinoWinnings = 0; CasinoLosses = 0; TotalEarned = 0; TotalSpent = 0; PokerIncome = 0; DailyStreak = 0; LastDaily = "" }
            Achievements = @{}
            Boot = @{ Loads = 0; TotalCommands = 0; FavoriteCommand = ""; LastBoot = "" }
            Version = 24
        }
    }
} else {
    . $BuxeProfileScript
}

# Override h help from module to ensure latest version is always active
function h {
    try { Clear-Host } catch {}
    Show-Frame "BUXE_OS v24.0 COMMANDS" -Double | Out-Null
    Write-Host ""
    $b = $script:BuxeState.Bank
    if ($b.Gold) { Write-Host "  |  Bank: $($b.Gold) G | Streak: $($b.DailyStreak)" -ForegroundColor Yellow }
    Write-Host "  +======================================+" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [NAV]      .. ... .... tmp dl docs mkcd" -ForegroundColor DarkGray
    Write-Host "  [FILES]    ll la touch rmrf c which grep" -ForegroundColor DarkGray
    Write-Host "  [GIT]      g gs ga gc gp gl gco gb gd glog gcm gundo gunstage" -ForegroundColor DarkGray
    Write-Host "  [SYSTEM]   uptime weather ip port mem sudo reload profile sysinfo" -ForegroundColor DarkGray
    Write-Host "  [DEV]      kill-node kill-port size tmp-clean flush-dns empty-bin" -ForegroundColor DarkGray
    Write-Host "  [PNPM]     p pi pib ps pb pd pt pl po pr px pclean" -ForegroundColor DarkGray
    Write-Host "  [BANK]     bank daily" -ForegroundColor DarkGray
    Write-Host "  [STATS]    status achievements ego" -ForegroundColor DarkGray
    Write-Host "  [VOICE]    voices | svoice EN|ML # | Say text [-Wait] | clip-say" -ForegroundColor DarkGray
    Write-Host "  [MISC]     capsule dp-on guide h" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Tip: status for overview. Games/Pet hidden -- type the name directly." -ForegroundColor DarkGray
    Write-Host ""
}
