# BUXE_OS v24.4 -- STATE MANAGER ADVANCED
# Transaktionen und erweiterte State-Operationen.

try {

$script:BuxeStateTransactionDepth = 0
$script:BuxeStateTransactionBackup = $null

function Start-StateTransaction {
    if ($script:BuxeStateTransactionDepth -eq 0) {
        Load-State
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
    $script:BuxeState = $script:BuxeStateTransactionBackup
    $script:BuxeStateTransactionDepth = 0
    $script:BuxeStateTransactionBackup = $null
}

} catch {
    Write-Host "[engine-state-advanced] CRITICAL ERROR: $_" -ForegroundColor Red
}
