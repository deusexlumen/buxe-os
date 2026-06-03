# BUXE_OS v24.0 -- END-TO-END TEST
$ErrorActionPreference = 'Stop'
$profilePath = Join-Path $PSScriptRoot "..\Microsoft.PowerShell_profile.ps1"

Write-Output "=== LOADING PROFILE ==="
try {
    . $profilePath
    Write-Output "PROFILE LOADED SUCCESSFULLY"
} catch {
    Write-Output "PROFILE FAILED: $_"
    exit 1
}

Write-Output ""
Write-Output "=== VERIFYING FUNCTIONS ==="
$required = @("status","bank","daily","achievements","ego","capsule","h","pet","companion","battlepet","snake","monkeytype","wordle","zork","hangman","blackjack","roulette","craps","hilo","baccarat","slot","poker","td","rogue","say","chuck","kimir","mem","sysinfo","uptime","weather","ip","port","reload","Invoke-BootSequence")
$missing = @()
foreach ($fn in $required) {
    if (-not (Get-Command $fn -ErrorAction SilentlyContinue)) { $missing += $fn }
}
if ($missing.Count -eq 0) {
    Write-Output "ALL $($required.Count) FUNCTIONS AVAILABLE"
} else {
    Write-Output "MISSING: $($missing -join ', ')"
    exit 1
}

Write-Output ""
Write-Output "=== VERIFYING STATE ==="
$statePath = Join-Path $env:LOCALAPPDATA "buxe\buxe_state_v24.json"
if (Test-Path $statePath) {
    Write-Output "State file exists: $statePath"
    $size = (Get-Item $statePath).Length
    Write-Output "Size: $size bytes"
} else {
    Write-Output "State file MISSING!"
    exit 1
}

Write-Output ""
Write-Output "=== VERIFYING SessionStart ==="
if ($script:SessionStart) {
    $elapsed = (Get-Date) - $script:SessionStart
    Write-Output "SessionStart set: $([math]::Round($elapsed.TotalSeconds, 2)) seconds ago"
} else {
    Write-Output "SessionStart NOT SET!"
    exit 1
}

Write-Output ""
Write-Output "=== ALL E2E CHECKS PASSED ==="
