# BUXE_OS v24.4 -- STATE MANAGER MIGRATION
# v23 -> v24 Migration, Export/Import.

try {

function Migrate-v23Tov24 {
    Write-Host "  [StateManager] Migrating v23 data to v24..." -ForegroundColor Yellow
    $migrated = 0

    $bankFile = Join-Path $script:BuxeStateDir "buxe_bank.json"
    if (Test-Path $bankFile) {
        try {
            $old = Get-Content $bankFile | ConvertFrom-Json
            # Property-Existenz pruefen, damit gueltige 0-Werte nicht durch Defaults ueberschrieben werden.
            $script:BuxeState.Bank.Gold = if ($old.PSObject.Properties['Gold']) { $old.Gold } else { 500 }
            $script:BuxeState.Bank.CasinoWinnings = if ($old.PSObject.Properties['CasinoWinnings']) { $old.CasinoWinnings } else { 0 }
            $script:BuxeState.Bank.CasinoLosses = if ($old.PSObject.Properties['CasinoLosses']) { $old.CasinoLosses } else { 0 }
            $script:BuxeState.Bank.TotalEarned = if ($old.PSObject.Properties['TotalEarned']) { $old.TotalEarned } else { 0 }
            $script:BuxeState.Bank.TotalSpent = if ($old.PSObject.Properties['TotalSpent']) { $old.TotalSpent } else { 0 }
            $script:BuxeState.Bank.PokerIncome = if ($old.PSObject.Properties['PokerIncome']) { $old.PokerIncome } else { 0 }
            $script:BuxeState.Bank.DailyStreak = if ($old.PSObject.Properties['DailyStreak']) { $old.DailyStreak } else { 0 }
            $script:BuxeState.Bank.LastDaily = if ($old.PSObject.Properties['LastDaily']) { $old.LastDaily } else { "" }
            $migrated++
        } catch {}
    }

    $cpFile = Join-Path $script:BuxeStateDir "buxe_companion.json"
    if (Test-Path $cpFile) {
        try {
            $old = Get-Content $cpFile | ConvertFrom-Json
            $script:BuxeState.Companion = Convert-PSObjectToHashtable $old
            $migrated++
        } catch {}
    }

    $bpFile = Join-Path $script:BuxeStateDir "buxe_battlepet.json"
    if (Test-Path $bpFile) {
        try {
            $old = Get-Content $bpFile | ConvertFrom-Json
            $script:BuxeState.Battlepet = Convert-PSObjectToHashtable $old
            $migrated++
        } catch {}
    }

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

    $bootFile = Join-Path $script:BuxeStateDir "buxe_bootdata.json"
    if (Test-Path $bootFile) {
        try {
            $old = Get-Content $bootFile | ConvertFrom-Json
            $script:BuxeState.Boot.Loads = if ($old.PSObject.Properties['Loads']) { $old.Loads } else { 0 }
            $script:BuxeState.Boot.TotalCommands = if ($old.PSObject.Properties['TotalCommands']) { $old.TotalCommands } else { 0 }
            $script:BuxeState.Boot.FavoriteCommand = if ($old.PSObject.Properties['FavoriteCommand']) { $old.FavoriteCommand } else { "" }
            $script:BuxeState.Boot.LastBoot = if ($old.PSObject.Properties['LastBoot']) { $old.LastBoot } else { "" }
            $migrated++
        } catch {}
    }

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

} catch {
    Write-Host "[engine-state-migration] CRITICAL ERROR: $_" -ForegroundColor Red
}
