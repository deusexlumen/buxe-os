# BUXE_OS v24.0 -- STATE MANAGER
# Zentraler State-Store. Alle Daten in einer JSON-Datei.

try {

$script:BuxeStateDir = Join-Path $env:LOCALAPPDATA "buxe"
$script:BuxeStateFile = Join-Path $script:BuxeStateDir "buxe_state_v24.json"
$script:BuxeAuditFile = Join-Path $script:BuxeStateDir "buxe_audit.log"
$script:BuxeStateVersion = 24
$script:BuxeStateTransactionDepth = 0
$script:BuxeStateTransactionBackup = $null

# === SCHEMA DEFAULTS ===
function Get-StateDefaults {
    return @{
        Version = $script:BuxeStateVersion
        Bank = @{
            Gold = 500
            CasinoWinnings = 0
            CasinoLosses = 0
            TotalEarned = 0
            TotalSpent = 0
            PokerIncome = 0
            DailyStreak = 0
            LastDaily = ""
        }
        Companion = $null
        Battlepet = $null
        Pet = $null
        Casino = @{
            Blackjack = @{ HandsPlayed = 0; HandsWon = 0; BiggestWin = 0 }
            Roulette  = @{ Spins = 0; BiggestWin = 0; History = @() }
            Craps     = @{ Rolls = 0; Wins = 0; BestStreak = 0; CurrentStreak = 0 }
            HiLo      = @{ BestStreak = 0; Rounds = 0 }
            Baccarat  = @{ Hands = 0; BankerWins = 0; PlayerWins = 0; Ties = 0 }
            Slot      = @{ Spins = 0; JackpotWins = 0; TotalWon = 0; TotalSpent = 0 }
        }
        Strategy = @{
            Poker = @{ HandsPlayed = 0; HandsWon = 0; BiggestPot = 0 }
            TowerDefense = @{ GamesPlayed = 0; BestWave = 0 }
            Rogue = @{ Runs = 0; BestFloor = 0; TotalKills = 0 }
        }
        Arcade = @{
            MonkeyType = @{ BestWPM = 0; Races = 0 }
            Snake = @{ BestScore = 0; Games = 0 }
            Wordle = @{ Played = 0; Streak = 0; BestStreak = 0 }
            Zork = @{ RoomsExplored = 0; ItemsFound = 0 }
            Hangman = @{ Won = 0; Lost = 0 }
        }
        Achievements = @{}
        Story = @{}
        Boot = @{
            Loads = 0
            TotalCommands = 0
            FavoriteCommand = ""
            LastBoot = ""
        }
        Capsules = @()
    }
}

# === ATOMIC SAVE / LOAD ===
function Save-State {
    if ($script:BuxeStateTransactionDepth -gt 0) { return }
    if (-not (Test-Path $script:BuxeStateDir)) {
        New-Item -ItemType Directory -Path $script:BuxeStateDir -Force | Out-Null
    }
    $tempFile = "$script:BuxeStateFile.tmp"
    try {
        $script:BuxeState | ConvertTo-Json -Depth 20 | Out-File $tempFile -Encoding utf8 -ErrorAction Stop
        Move-Item -Path $tempFile -Destination $script:BuxeStateFile -Force -ErrorAction Stop
        $script:BuxeStateLoadedAt = (Get-Item $script:BuxeStateFile).LastWriteTime
    } catch {
        Write-Warning "[StateManager] Failed to save state: $_"
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
    }
}

function Load-State {
    if ($script:BuxeStateTransactionDepth -gt 0) { return }
    # Optimization: skip reload if state file hasn't changed since last load
    if (Test-Path $script:BuxeStateFile) {
        $currentWriteTime = (Get-Item $script:BuxeStateFile).LastWriteTime
        if ($script:BuxeStateLoadedAt -and $script:BuxeStateLoadedAt -eq $currentWriteTime -and $script:BuxeState) {
            return
        }
        try {
            $raw = Get-Content $script:BuxeStateFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            $script:BuxeState = Convert-PSObjectToHashtable $raw
            $script:BuxeStateLoadedAt = $currentWriteTime
            # Validate + patch missing fields
            $defaults = Get-StateDefaults
            Merge-Defaults $script:BuxeState $defaults
            # Version migration if needed
            if (-not $script:BuxeState.Version -or $script:BuxeState.Version -lt $script:BuxeStateVersion) {
                Migrate-State $script:BuxeState.Version
            }
            return
        } catch {
            $backup = "$script:BuxeStateFile.corrupt.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $script:BuxeStateFile $backup -Force -ErrorAction SilentlyContinue
            Write-Warning "[StateManager] Corrupt state file. Backed up to $backup. Starting fresh."
        }
    }
    # Fresh start or migration from v23
    $script:BuxeState = Get-StateDefaults
    $script:BuxeStateLoadedAt = $null
    Migrate-v23Tov24
    Save-State
}

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

# === EXPORT / IMPORT ===
function Export-State {
    $exportDir = $script:BuxeStateDir
    if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $exportFile = Join-Path $exportDir "buxe_export_$timestamp.json"
    try {
        $script:BuxeState | ConvertTo-Json -Depth 20 | Out-File $exportFile -Encoding utf8 -ErrorAction Stop
        Write-Host "  State exported to: $exportFile" -ForegroundColor Green
    } catch {
        Write-Warning "[StateManager] Export failed: $_"
    }
}

function Import-State {
    param([string]$Path)
    if (-not $Path) {
        $importDir = $script:BuxeStateDir
        $files = Get-ChildItem -Path $importDir -Filter "buxe_export_*.json" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        if (-not $files -or $files.Count -eq 0) { Write-Host "  No export files found in $importDir" -ForegroundColor Red; return }
        Write-Host "  Available exports:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $files.Count; $i++) {
            Write-Host "    [$($i+1)] $($files[$i].Name) ($($files[$i].LastWriteTime))" -ForegroundColor White
        }
        $choice = Read-Host "  Select export to import (number, or Q to cancel)"
        if ($choice -eq 'Q' -or $choice -eq 'q') { return }
        $idx = [int]$choice - 1
        if ($idx -lt 0 -or $idx -ge $files.Count) { Write-Host "  Invalid selection." -ForegroundColor Red; return }
        $Path = $files[$idx].FullName
    }
    if (-not (Test-Path $Path)) { Write-Host "  File not found: $Path" -ForegroundColor Red; return }
    try {
        $raw = Get-Content $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        $imported = Convert-PSObjectToHashtable $raw
        if (-not $imported.Version) { Write-Host "  Invalid export file (no version)." -ForegroundColor Red; return }
        $confirm = Read-Host "  This will OVERWRITE current state. Type 'YES' to confirm"
        if ($confirm -ne 'YES') { Write-Host "  Import cancelled." -ForegroundColor Yellow; return }
        $defaults = Get-StateDefaults
        Merge-Defaults $imported $defaults
        $script:BuxeState = $imported
        Save-State
        Write-Host "  State imported successfully from: $Path" -ForegroundColor Green
        Write-Host "  Please restart BUXE_OS for full effect." -ForegroundColor Yellow
    } catch {
        Write-Warning "[StateManager] Import failed: $_"
    }
}

# === HELPER: PSObject -> Hashtable ===
function Convert-PSObjectToHashtable {
    param($InputObject)
    if ($InputObject -eq $null) { return $null }
    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
        $collection = @()
        foreach ($item in $InputObject) { $collection += (Convert-PSObjectToHashtable $item) }
        return $collection
    }
    if ($InputObject -is [System.Management.Automation.PSCustomObject]) {
        $hash = @{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $hash[$prop.Name] = Convert-PSObjectToHashtable $prop.Value
        }
        return $hash
    }
    return $InputObject
}

# === HELPER: Merge Defaults ===
function Merge-Defaults {
    param([hashtable]$Target, [hashtable]$Defaults)
    foreach ($key in $Defaults.Keys) {
        if (-not $Target.ContainsKey($key)) {
            $Target[$key] = $Defaults[$key]
        } elseif ($Target[$key] -is [hashtable] -and $Defaults[$key] -is [hashtable]) {
            Merge-Defaults $Target[$key] $Defaults[$key]
        }
    }
}

# === MIGRATION: v23 -> v24 ===
function Migrate-v23Tov24 {
    Write-Host "  [StateManager] Migrating v23 data to v24..." -ForegroundColor Yellow
    $migrated = 0

    # Bank
    $bankFile = Join-Path $script:BuxeStateDir "buxe_bank.json"
    if (Test-Path $bankFile) {
        try {
            $old = Get-Content $bankFile | ConvertFrom-Json
            $script:BuxeState.Bank.Gold = if ($old.Gold) { $old.Gold } else { 500 }
            $script:BuxeState.Bank.CasinoWinnings = if ($old.CasinoWinnings) { $old.CasinoWinnings } else { 0 }
            $script:BuxeState.Bank.CasinoLosses = if ($old.CasinoLosses) { $old.CasinoLosses } else { 0 }
            $script:BuxeState.Bank.TotalEarned = if ($old.TotalEarned) { $old.TotalEarned } else { 0 }
            $script:BuxeState.Bank.TotalSpent = if ($old.TotalSpent) { $old.TotalSpent } else { 0 }
            $script:BuxeState.Bank.PokerIncome = if ($old.PokerIncome) { $old.PokerIncome } else { 0 }
            $script:BuxeState.Bank.DailyStreak = if ($old.DailyStreak) { $old.DailyStreak } else { 0 }
            $script:BuxeState.Bank.LastDaily = if ($old.LastDaily) { $old.LastDaily } else { "" }
            $migrated++
        } catch {}
    }

    # Companion
    $cpFile = Join-Path $script:BuxeStateDir "buxe_companion.json"
    if (Test-Path $cpFile) {
        try {
            $old = Get-Content $cpFile | ConvertFrom-Json
            $script:BuxeState.Companion = Convert-PSObjectToHashtable $old
            $migrated++
        } catch {}
    }

    # Battlepet
    $bpFile = Join-Path $script:BuxeStateDir "buxe_battlepet.json"
    if (Test-Path $bpFile) {
        try {
            $old = Get-Content $bpFile | ConvertFrom-Json
            $script:BuxeState.Battlepet = Convert-PSObjectToHashtable $old
            $migrated++
        } catch {}
    }

    # Casino stats
    $casinoMap = @{
        "buxe_blackjack.json" = "Blackjack"
        "buxe_roulette.json"  = "Roulette"
        "buxe_craps.json"     = "Craps"
        "buxe_hilo.json"      = "HiLo"
        "buxe_baccarat.json"  = "Baccarat"
        "buxe_slot.json"      = "Slot"
    }
    foreach ($file in $casinoMap.Keys) {
        $path = Join-Path $script:BuxeStateDir $file
        if (Test-Path $path) {
            try {
                $old = Get-Content $path | ConvertFrom-Json
                $section = $casinoMap[$file]
                foreach ($prop in $old.PSObject.Properties) {
                    if ($script:BuxeState.Casino[$section].ContainsKey($prop.Name)) {
                        $script:BuxeState.Casino[$section][$prop.Name] = $prop.Value
                    }
                }
                $migrated++
            } catch {}
        }
    }

    # Strategy stats
    $stratMap = @{
        "buxe_poker.json" = "Poker"
        "buxe_td.json"    = "TowerDefense"
        "buxe_rogue.json" = "Rogue"
    }
    foreach ($file in $stratMap.Keys) {
        $path = Join-Path $script:BuxeStateDir $file
        if (Test-Path $path) {
            try {
                $old = Get-Content $path | ConvertFrom-Json
                $section = $stratMap[$file]
                foreach ($prop in $old.PSObject.Properties) {
                    if ($script:BuxeState.Strategy[$section].ContainsKey($prop.Name)) {
                        $script:BuxeState.Strategy[$section][$prop.Name] = $prop.Value
                    }
                }
                $migrated++
            } catch {}
        }
    }

    # Achievements
    $achFile = Join-Path $script:BuxeStateDir "buxe_achievements.json"
    if (Test-Path $achFile) {
        try {
            $old = Get-Content $achFile | ConvertFrom-Json
            if ($old -is [System.Collections.Hashtable]) {
                $script:BuxeState.Achievements = $old
            } else {
                $script:BuxeState.Achievements = @{}
                $old.PSObject.Properties | ForEach-Object { $script:BuxeState.Achievements[$_.Name] = $_.Value }
            }
            $migrated++
        } catch {}
    }

    # Boot data
    $bootFile = Join-Path $script:BuxeStateDir "buxe_bootdata.json"
    if (Test-Path $bootFile) {
        try {
            $old = Get-Content $bootFile | ConvertFrom-Json
            $script:BuxeState.Boot.Loads = if ($old.Loads) { $old.Loads } else { 0 }
            $script:BuxeState.Boot.TotalCommands = if ($old.TotalCommands) { $old.TotalCommands } else { 0 }
            $script:BuxeState.Boot.FavoriteCommand = if ($old.FavoriteCommand) { $old.FavoriteCommand } else { "" }
            $script:BuxeState.Boot.LastBoot = if ($old.LastBoot) { $old.LastBoot } else { "" }
            $migrated++
        } catch {}
    }

    # Capsules
    $capFile = Join-Path $script:BuxeStateDir "buxe_capsules.json"
    if (Test-Path $capFile) {
        try {
            $old = Get-Content $capFile | ConvertFrom-Json
            $script:BuxeState.Capsules = Convert-PSObjectToHashtable $old
            $migrated++
        } catch {}
    }

    if ($migrated -gt 0) {
        Write-Host "  [StateManager] Migrated $migrated data files to v24 unified state." -ForegroundColor Green
        # Archive old files
        $archiveDir = Join-Path $script:BuxeStateDir "v23_archive"
        if (-not (Test-Path $archiveDir)) { New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null }
        $oldFiles = @("buxe_bank.json","buxe_companion.json","buxe_battlepet.json","buxe_blackjack.json","buxe_roulette.json","buxe_craps.json","buxe_hilo.json","buxe_baccarat.json","buxe_slot.json","buxe_poker.json","buxe_td.json","buxe_rogue.json","buxe_achievements.json","buxe_bootdata.json","buxe_capsules.json")
        foreach ($f in $oldFiles) {
            $src = Join-Path $script:BuxeStateDir $f
            if (Test-Path $src) { Move-Item $src $archiveDir -Force -ErrorAction SilentlyContinue }
        }
        Write-Host "  [StateManager] Old files archived to v23_archive/" -ForegroundColor DarkGray
    }
}

function Migrate-State($fromVersion) {
    # Placeholder for future migrations v24 -> v25 etc.
    $script:BuxeState.Version = $script:BuxeStateVersion
}

# === CONVENIENCE ACCESSORS ===
function Get-Bankroll {
    Load-State
    return $script:BuxeState.Bank.Gold
}

function Write-AuditLog($Action, $Amount, $BalanceBefore, $BalanceAfter, $Reason) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts | $Action | $Amount | $BalanceBefore | $BalanceAfter | $Reason"
    Add-Content -Path $script:BuxeAuditFile -Value $line -Encoding utf8 -ErrorAction SilentlyContinue
}

function Set-Bankroll($delta, [switch]$TrackCasino, $Reason = "Bankroll") {
    Load-State
    $before = $script:BuxeState.Bank.Gold
    $script:BuxeState.Bank.Gold += $delta
    $after = $script:BuxeState.Bank.Gold
    if ($TrackCasino) {
        if ($delta -gt 0) { $script:BuxeState.Bank.CasinoWinnings += $delta }
        elseif ($delta -lt 0) { $script:BuxeState.Bank.CasinoLosses += [math]::Abs($delta) }
    }
    if ($delta -gt 0) { $script:BuxeState.Bank.TotalEarned += $delta }
    if ($delta -lt 0) { $script:BuxeState.Bank.TotalSpent += [math]::Abs($delta) }
    Write-AuditLog -Action "BANKROLL" -Amount $delta -BalanceBefore $before -BalanceAfter $after -Reason $Reason
    Save-State
}

function Add-Gold($amount, $source) {
    Load-State
    $before = $script:BuxeState.Bank.Gold
    $script:BuxeState.Bank.Gold += $amount
    $script:BuxeState.Bank.TotalEarned += $amount
    $after = $script:BuxeState.Bank.Gold
    Write-AuditLog -Action "EARN" -Amount $amount -BalanceBefore $before -BalanceAfter $after -Reason $source
    Save-State
    # Update companion quest progress for gold earned
    if (Get-Command Update-CPQuestProgress -ErrorAction SilentlyContinue) {
        Update-CPQuestProgress "gold" $amount
    }
}

function Spend-Gold($amount, $reason) {
    Load-State
    $before = $script:BuxeState.Bank.Gold
    $script:BuxeState.Bank.Gold -= $amount
    $script:BuxeState.Bank.TotalSpent += $amount
    $after = $script:BuxeState.Bank.Gold
    Write-AuditLog -Action "SPEND" -Amount (-$amount) -BalanceBefore $before -BalanceAfter $after -Reason $reason
    Save-State
}

function Unlock-Achievement($name) {
    Load-State
    if (-not $script:BuxeState.Achievements.$name) {
        $script:BuxeState.Achievements[$name] = (Get-Date -Format "yyyy-MM-dd")
        Save-State
        Write-Host "  [ACHIEVEMENT UNLOCKED] $name" -ForegroundColor Yellow -BackgroundColor DarkRed
    }
}

function Load-CompanionState {
    Load-State
    return $script:BuxeState.Companion
}

function Save-CompanionState($state) {
    Load-State
    $script:BuxeState.Companion = $state
    Save-State
}

function Load-BattlepetState {
    Load-State
    return $script:BuxeState.Battlepet
}

function Save-BattlepetState($state) {
    Load-State
    $script:BuxeState.Battlepet = $state
    Save-State
}

function Get-CasinoStats($game) {
    Load-State
    return $script:BuxeState.Casino[$game]
}

function Set-CasinoStats($game, $stats) {
    Load-State
    $script:BuxeState.Casino[$game] = $stats
    Save-State
}

function Get-StrategyStats($game) {
    Load-State
    return $script:BuxeState.Strategy[$game]
}

function Set-StrategyStats($game, $stats) {
    Load-State
    $script:BuxeState.Strategy[$game] = $stats
    Save-State
}

function Get-ArcadeStats($game) {
    Load-State
    return $script:BuxeState.Arcade[$game]
}

function Set-ArcadeStats($game, $stats) {
    Load-State
    $script:BuxeState.Arcade[$game] = $stats
    Save-State
}

# === INIT ===
Load-State

} catch {
    Write-Host "[engine-state] CRITICAL ERROR: $_" -ForegroundColor Red
}
