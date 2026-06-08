# BUXE_OS v24.4 -- STATE MANAGER ADVANCED
# Transaktionen und erweiterte State-Operationen.

try {

$script:BuxeStateTransactionDepth = 0
$script:BuxeStateTransactionBackup = $null

function Start-StateTransaction {
    if ($script:BuxeStateTransactionDepth -ge 10) { throw "Maximum transaction depth (10) exceeded" }
    if ($script:BuxeStateTransactionDepth -eq 0) {
        Load-State
        if (-not (Get-Command Convert-PSObjectToHashtable -ErrorAction SilentlyContinue)) {
            throw "Convert-PSObjectToHashtable not available. Ensure engine-state-core.ps1 is loaded."
        }
        $script:BuxeStateTransactionBackup = Convert-PSObjectToHashtable ($script:BuxeState | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
    }
    $script:BuxeStateTransactionDepth++
}

function Complete-StateTransaction {
    if ($script:BuxeStateTransactionDepth -le 0) { throw "No active state transaction" }
    $script:BuxeStateTransactionDepth--
    if ($script:BuxeStateTransactionDepth -eq 0) {
        Save-State
        $script:BuxeStateTransactionBackup = $null
    }
}

function Rollback-StateTransaction {
    if ($script:BuxeStateTransactionDepth -le 0) { throw "No active state transaction" }
    $script:BuxeState = Convert-PSObjectToHashtable ($script:BuxeStateTransactionBackup | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
    $script:BuxeStateTransactionDepth = 0
    $script:BuxeStateTransactionBackup = $null
}

} catch {
    Write-Host "[engine-state-advanced] CRITICAL ERROR: $_" -ForegroundColor Red
}
