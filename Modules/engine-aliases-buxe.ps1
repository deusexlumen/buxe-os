# BUXE_OS v24.0 -- BUXE CORE ALIASES

try {

function bank {
    Load-State
    $b = $script:BuxeState.Bank
    try { Clear-Host } catch {}
    Show-Frame "GLOBAL BANK" -Double | Out-Null
    Write-Host "`n  Kontostand: $($b.Gold) G" -ForegroundColor Yellow
    Write-Host "  Verdient: $($b.TotalEarned) G | Ausgegeben: $($b.TotalSpent) G" -ForegroundColor DarkGray
    Write-Host "  Casino Gewinn: $($b.CasinoWinnings) G | Verlust: $($b.CasinoLosses) G" -ForegroundColor DarkGray
    Write-Host "  Poker Einkommen: $($b.PokerIncome) G" -ForegroundColor DarkGray
    if ($b.DailyStreak -gt 0) { Write-Host "  Daily Streak: $($b.DailyStreak) Tage" -ForegroundColor Green }
}

function daily {
    Load-State
    $b = $script:BuxeState.Bank
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($b.LastDaily -eq $today) { Write-Host "`n  Bereits abgeholt! Komm morgen wieder." -ForegroundColor Red; return }
    $yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    if ($b.LastDaily -eq $yesterday) { $b.DailyStreak++ } else { $b.DailyStreak = 1 }
    $b.LastDaily = $today
    $base = 100; $bonus = $b.DailyStreak * 10; $total = $base + $bonus
    $b.Gold += $total; $b.TotalEarned += $total
    Save-State
    Write-Host "`n  DAILY BONUS!" -ForegroundColor Green
    Write-Host "  Basis: $base G | Streak-Bonus: $bonus G | Total: $total G" -ForegroundColor Yellow
    Write-Host "  Streak: $($b.DailyStreak) Tage" -ForegroundColor Cyan
    if ($b.DailyStreak -ge 7) { Unlock-Achievement "Week Streak" }
    if ($b.DailyStreak -ge 30) { Unlock-Achievement "Month Streak" }
}

function achievements {
    Load-State
    $ach = $script:BuxeState.Achievements
    $props = $ach | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    Write-Host "`n  ACHIEVEMENTS ($($props.Count) freigeschaltet):" -ForegroundColor Yellow
    foreach ($p in $props) {
        Write-Host "    [OK] $p -- $($ach.$p)" -ForegroundColor Green
    }
}

function ego {
    Load-State
    $b = $script:BuxeState.Bank
    $ach = ($script:BuxeState.Achievements | Get-Member -MemberType NoteProperty | Measure-Object).Count
    Write-Host "`n  EGO REPORT" -ForegroundColor Magenta
    Write-Host "  Sessions: $($script:BuxeState.Boot.Loads)" -ForegroundColor Cyan
    Write-Host "  Letzter Boot: $($script:BuxeState.Boot.LastBoot)" -ForegroundColor Cyan
    Write-Host "  Bank: $($b.Gold) G" -ForegroundColor Yellow
    Write-Host "  Achievements: $ach" -ForegroundColor Green
    Write-Host "  Status: Digital deity in training.`n" -ForegroundColor White
}

function status {
    Load-State
    try { Clear-Host } catch {}
    $bot = Show-Frame "BUXE_OS STATUS  v24.0" -Double
    $elapsed = (Get-Date) - $script:SessionStart
    Write-Host "  Session: $([math]::Floor($elapsed.TotalHours))h $([math]::Floor($elapsed.TotalMinutes % 60))m" -ForegroundColor DarkGray
    Write-Host $bot -ForegroundColor Cyan; Write-Host ""
    
    $b = $script:BuxeState.Bank
    $goldBar = Show-Bar $b.Gold ([math]::Max($b.Gold + 1000, 5000)) 20
    Write-Host "  BANK" -ForegroundColor Yellow
    Write-Host "     Balance: [$goldBar] $($b.Gold) G" -ForegroundColor White
    Write-Host "     Earned: $($b.TotalEarned) G | Spent: $($b.TotalSpent) G" -ForegroundColor DarkGray
    if ($b.DailyStreak -gt 0) { Write-Host "     Streak: $($b.DailyStreak) days" -ForegroundColor Green }
    $casinoTotal = $b.CasinoWinnings + $b.CasinoLosses
    if ($casinoTotal -gt 0) {
        $rate = [math]::Round(($b.CasinoWinnings / $casinoTotal) * 100)
        $rateBar = Show-Bar $rate 100 15
        Write-Host "     Casino W/L: [$rateBar] $rate%" -ForegroundColor $(if ($rate -ge 50) { "Green" } else { "Red" })
    }
    
    $cp = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Companion } else { $null }
    if ($cp -and $cp.Bond -gt 0) {
        $bondBar = Show-Bar $cp.Bond 100 20
        Write-Host "`n  COMPANION: $($cp.Name) [$($cp.Role)]" -ForegroundColor Magenta
        Write-Host "     Bond: [$bondBar] $($cp.Bond)/100" -ForegroundColor White
        Write-Host "     Mood: $($cp.Mood)" -ForegroundColor DarkGray
    }
    
    $p = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Pet } else { $null }
    if ($p -and $p.Wins + $p.Losses -gt 0) {
        $hpBar = Show-Bar $p.HP $p.MaxHP 20
        Write-Host "`n  BATTLEPET: $($p.Name) [Lv.$($p.Level)] ($($p.Type))" -ForegroundColor Green
        Write-Host "     HP: [$hpBar] $($p.HP)/$($p.MaxHP)" -ForegroundColor White
        Write-Host "     Wins: $($p.Wins) | Losses: $($p.Losses)" -ForegroundColor DarkGray
    }
    
    $ach = ($script:BuxeState.Achievements | Get-Member -MemberType NoteProperty | Measure-Object).Count
    if ($ach -gt 0) {
        Write-Host "`n  Achievements: $ach" -ForegroundColor Yellow
    }
    # Meta 12+ Fourth Wall: System Stats
    $petMeta = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Meta } else { $null }
    if ($petMeta -and $petMeta.Level -ge 12) {
        Write-Host "`n  [FOURTH WALL ACCESS GRANTED]" -ForegroundColor Magenta
        $sessionTime = if ($script:SessionStart) { "$([math]::Floor(((Get-Date) - $script:SessionStart).TotalMinutes))m" } else { "?" }
        $cmdCount = if ($script:BuxeState.Boot) { $script:BuxeState.Boot.TotalCommands } else { 0 }
        Write-Host "     Session: $sessionTime | Commands: $cmdCount | Meta: Lv.$($petMeta.Level)" -ForegroundColor DarkGray
        if ($petMeta.Level -ge 13) {
            $glitchStatus = if ($petMeta.GlitchUsedToday -eq (Get-Date -Format "yyyy-MM-dd")) { "USED" } else { "READY" }
            Write-Host "     Glitch: $glitchStatus" -ForegroundColor $(if($glitchStatus -eq "READY"){"Green"}else{"Red"})
        }
    }
    Write-Host $bot -ForegroundColor Cyan
    Write-Host ""
}

function capsule {
    param([string]$Message)
    Load-State
    $capsules = $script:BuxeState.Capsules
    if (-not $capsules) { $capsules = @() }
    if (-not $Message) {
        $opened = 0; $remaining = @(); $today = Get-Date
        foreach ($cap in $capsules) {
            $openDate = [datetime]::Parse($cap.OpenDate)
            if ($today -ge $openDate) {
                $days = [math]::Floor(($today - [datetime]::Parse($cap.CreatedDate)).TotalDays)
                Write-Host "`n  TIME CAPSULE from $days days ago:" -ForegroundColor Yellow
                Write-Host "  $($cap.Message)" -ForegroundColor White
                $opened++
            } else { $remaining += $cap }
        }
        if ($opened -eq 0) { Write-Host "`n  No capsules ready yet. Create one with: capsule your message" -ForegroundColor DarkGray }
        $script:BuxeState.Capsules = $remaining
        Save-State
        return
    }
    $openDays = Get-Random -Minimum 1 -Maximum 15
    $newCap = @{
        Message = $Message
        CreatedDate = (Get-Date -Format "yyyy-MM-dd HH:mm")
        OpenDate = (Get-Date).AddDays($openDays).ToString("yyyy-MM-dd HH:mm")
    }
    $capsules += $newCap
    $script:BuxeState.Capsules = $capsules
    Save-State
    Write-Host "`n  Capsule sealed! Opens in $openDays days." -ForegroundColor Green
}

# === BACKWARD COMPATIBILITY ===
function companion { pet @args }
function battlepet { pet @args }

} catch {
    Write-Host "[engine-aliases-buxe] CRITICAL ERROR: $_" -ForegroundColor Red
}
