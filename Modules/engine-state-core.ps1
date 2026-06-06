# BUXE_OS v24.4 -- STATE MANAGER CORE
# Zentraler State-Store. Alle Daten in einer JSON-Datei.

try {

$script:BuxeStateDir = Join-Path $env:LOCALAPPDATA "buxe"
$script:BuxeStateFile = Join-Path $script:BuxeStateDir "buxe_state_v24.json"
$script:BuxeAuditFile = Join-Path $script:BuxeStateDir "buxe_audit.log"
$script:BuxeStateVersion = 24

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
            Slot      = @{ Spins = 0; JackpotWins = 0; TotalWon = 0; TotalSpent = 0; ProgressiveJackpot = 500 }
            Keno      = @{ Played = 0; BestWin = 0; TotalWon = 0; TotalSpent = 0 }
            Wheel     = @{ Spins = 0; BestWin = 0; Bankrupts = 0; Jackpots = 0 }
        }
        Strategy = @{
            Poker = @{ HandsPlayed = 0; HandsWon = 0; BiggestPot = 0 }
            TowerDefense = @{ GamesPlayed = 0; BestWave = 0 }
            Rogue = @{ Runs = 0; BestFloor = 0; TotalKills = 0 }
        }
        Arcade = @{
            MonkeyType = @{ BestWPM = 0; BestAccuracy = 0; Races = 0 }
            Snake = @{ BestScore = 0; Games = 0 }
            Wordle = @{ Played = 0; Streak = 0; BestStreak = 0; HardModeWins = 0 }
            Zork = @{ RoomsExplored = 0; ItemsFound = 0; BossDefeated = $false }
            Hangman = @{ Won = 0; Lost = 0 }
            Minesweeper = @{ Wins = 0; Losses = 0; BestTime = 0 }
            Tetris = @{ BestScore = 0; BestLines = 0; GamesPlayed = 0 }
            Breakout = @{ BestScore = 0; BestLevel = 0; GamesPlayed = 0 }
            Game2048 = @{ BestScore = 0; BestTile = 0; GamesPlayed = 0 }
            DinoJump = @{ BestScore = 0; GamesPlayed = 0 }
            MemoryMatch = @{ BestTime = 0; BestMoves = 0; GamesPlayed = 0 }
        }
        Achievements = @{}
        Story = @{}
        Boot = @{
            Loads = 0
            TotalCommands = 0
            FavoriteCommand = ""
            LastBoot = ""
            FavoriteGame = ""
        }
        Capsules = @()
    }
}

# === ATOMIC SAVE / LOAD ===
function Save-State {
    if ($script:BuxeStateTransactionDepth -gt 0) { return }
    # Throttle: max 1 Save pro 500ms (vermeidet I/O-Overhead bei schnellen Aktionen)
    $now = Get-Date
    if ($script:BuxeStateLastSave -and ($now - $script:BuxeStateLastSave).TotalMilliseconds -lt 500) {
        $script:BuxeStatePendingSave = $true
        return
    }
    if (-not (Test-Path $script:BuxeStateDir)) {
        New-Item -ItemType Directory -Path $script:BuxeStateDir -Force | Out-Null
    }
    # Rotate backups (keep last 5)
    $bak1 = "$script:BuxeStateFile.bak1"
    $bak2 = "$script:BuxeStateFile.bak2"
    $bak3 = "$script:BuxeStateFile.bak3"
    $bak4 = "$script:BuxeStateFile.bak4"
    $bak5 = "$script:BuxeStateFile.bak5"
    try {
        if (Test-Path $bak4) { Move-Item $bak4 $bak5 -Force -ErrorAction SilentlyContinue }
        if (Test-Path $bak3) { Move-Item $bak3 $bak4 -Force -ErrorAction SilentlyContinue }
        if (Test-Path $bak2) { Move-Item $bak2 $bak3 -Force -ErrorAction SilentlyContinue }
        if (Test-Path $bak1) { Move-Item $bak1 $bak2 -Force -ErrorAction SilentlyContinue }
        if (Test-Path $script:BuxeStateFile) { Copy-Item $script:BuxeStateFile $bak1 -Force -ErrorAction SilentlyContinue }
    } catch {
        Write-Warning "[StateManager] Backup rotation warning: $_"
    }
    
    $tempFile = "$script:BuxeStateFile.tmp"
    try {
        $script:BuxeState | ConvertTo-Json -Depth 20 | Out-File $tempFile -Encoding utf8 -ErrorAction Stop
        Move-Item -Path $tempFile -Destination $script:BuxeStateFile -Force -ErrorAction Stop
        $script:BuxeStateLastSave = Get-Date
        $script:BuxeStatePendingSave = $false
        try { $script:BuxeStateLoadedAt = (Get-Item $script:BuxeStateFile).LastWriteTime } catch {}
    } catch {
        Write-Warning "[StateManager] Failed to save state: $_"
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
    }
}

function Flush-State {
    # Speichert sofort, auch wenn Throttle aktiv ist (fuer interaktive Endpunkte)
    if ($script:BuxeStatePendingSave) {
        $script:BuxeStateLastSave = $null
        $script:BuxeStatePendingSave = $false
        Save-State
    }
}

function Load-State {
    if ($script:BuxeStateTransactionDepth -gt 0) { return }
    # Throttle: only check file system every 1 second
    if ($script:BuxeStateLoadedAt -and $script:BuxeState -and $script:BuxeStateLastCheck -and
        ((Get-Date) - $script:BuxeStateLastCheck).TotalSeconds -lt 1) {
        return
    }
    $script:BuxeStateLastCheck = Get-Date
    if (Test-Path $script:BuxeStateFile) {
        try {
            $currentWriteTime = (Get-Item $script:BuxeStateFile -ErrorAction SilentlyContinue).LastWriteTime
            if ($script:BuxeStateLoadedAt -and $script:BuxeStateLoadedAt -eq $currentWriteTime -and $script:BuxeState) {
                return
            }
            $raw = Get-Content $script:BuxeStateFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            $script:BuxeState = Convert-PSObjectToHashtable $raw
            $script:BuxeStateLoadedAt = $currentWriteTime
            $defaults = Get-StateDefaults
            Merge-Defaults $script:BuxeState $defaults
            if (-not $script:BuxeState.Version -or $script:BuxeState.Version -lt $script:BuxeStateVersion) {
                Migrate-State $script:BuxeState.Version
            }
            # Cache Frame-Theme fuer Show-Frame (vermeidet wiederholte Hashtable-Lookups)
            $script:CachedFrameTheme = "Default"
            if ($script:BuxeState.Pet -and $script:BuxeState.Pet.Companion -and $script:BuxeState.Pet.Meta.Level -ge 15) {
                $script:CachedFrameTheme = if ($script:BuxeState.Pet.Companion.Theme) { $script:BuxeState.Pet.Companion.Theme } else { "Default" }
            }
            # Pet-System Migration (einmalig beim State-Load)
            if ($script:BuxeState.Pet) {
                $petMigrated = $false
                if (-not $script:BuxeState.Pet.ContainsKey("Tutorial")) {
                    $script:BuxeState.Pet.Tutorial = @{ Completed = $true; Step = 0; Skipped = $false }
                    $petMigrated = $true
                }
                if (-not $script:BuxeState.Pet.Meta.ContainsKey("GlitchUsed")) {
                    $script:BuxeState.Pet.Meta.GlitchUsed = ""
                    $petMigrated = $true
                }
                if (-not $script:BuxeState.Pet.Meta.ContainsKey("ActionCount")) {
                    $script:BuxeState.Pet.Meta.ActionCount = 0
                    $petMigrated = $true
                }
                if ($petMigrated) { Save-State }
            }
            return
        } catch {
            $backup = "$script:BuxeStateFile.corrupt.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $script:BuxeStateFile $backup -Force -ErrorAction SilentlyContinue
            Write-Warning "[StateManager] Corrupt state file. Backed up to $backup. Starting fresh."
        }
    }
    $script:BuxeState = Get-StateDefaults
    $script:BuxeStateLoadedAt = $null
    if (Get-Command Migrate-v23Tov24 -ErrorAction SilentlyContinue) {
        Migrate-v23Tov24
    }
    Save-State
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

function Migrate-State($fromVersion) {
    $script:BuxeState.Version = $script:BuxeStateVersion
}

# === AUDIT LOG ===
function Write-AuditLog($Action, $Amount, $BalanceBefore, $BalanceAfter, $Reason) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = @{
        ts = $ts
        action = $Action
        amount = $Amount
        before = $BalanceBefore
        after = $BalanceAfter
        reason = $Reason
    } | ConvertTo-Json -Compress
    Add-Content -Path $script:BuxeAuditFile -Value $entry -Encoding utf8 -ErrorAction SilentlyContinue
}

# === CONVENIENCE ACCESSORS ===
function Get-Bankroll {
    Load-State
    return $script:BuxeState.Bank.Gold
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

} catch {
    Write-Host "[engine-state-core] CRITICAL ERROR: $_" -ForegroundColor Red
}
