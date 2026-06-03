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
    if ($cp) {
        $bondBar = Show-Bar $cp.Bond 100 20
        Write-Host "`n  COMPANION: $($cp.Name) [$($cp.Role)]" -ForegroundColor Magenta
        Write-Host "     Bond: [$bondBar] $($cp.Bond)/100" -ForegroundColor White
        Write-Host "     Mood: $($cp.Mood)" -ForegroundColor DarkGray
        if ($cp.Skills) {
            Write-Host "     Skills: CasinoLuck Lv.$($cp.Skills.CasinoLuck) | StrategyInsight Lv.$($cp.Skills.StrategyInsight)" -ForegroundColor Cyan
        }
    } else { Write-Host "`n  COMPANION: None" -ForegroundColor DarkGray }
    
    $p = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Pet } else { $null }
    if ($p) {
        $hpBar = Show-Bar $p.HP $p.MaxHP 20
        Write-Host "`n  BATTLEPET: $($p.Name) [Lv.$($p.Level)] ($($p.Type))" -ForegroundColor Green
        Write-Host "     HP: [$hpBar] $($p.HP)/$($p.MaxHP)" -ForegroundColor White
        Write-Host "     ATK: $($p.ATK) | DEF: $($p.DEF) | SPD: $($p.SPD)" -ForegroundColor DarkGray
        Write-Host "     Wins: $($p.Wins) | Losses: $($p.Losses)" -ForegroundColor DarkGray
    } else { Write-Host "`n  BATTLEPET: None" -ForegroundColor DarkGray }
    
    $ach = ($script:BuxeState.Achievements | Get-Member -MemberType NoteProperty | Measure-Object).Count
    if ($ach -gt 0) {
        Write-Host "`n  Achievements: $ach" -ForegroundColor Yellow
    }
    Write-Host $bot -ForegroundColor Cyan
    Wait-Enter
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
                Write-Host "  `"$($cap.Message)`"" -ForegroundColor White
                $opened++
            } else { $remaining += $cap }
        }
        if ($opened -eq 0) { Write-Host "`n  No capsules ready yet. Create one with: capsule `"your message`"" -ForegroundColor DarkGray }
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

function h {
    try { Clear-Host } catch {}
    Show-Frame "BUXE_OS v24.0 COMMANDS" -Double | Out-Null
    Write-Host ""
    
    Load-State
    $b = $script:BuxeState.Bank
    if ($b.Gold) { Write-Host "  |  Bank: $($b.Gold) G | Streak: $($b.DailyStreak)" -ForegroundColor Yellow }
    if ($script:BuxeState.Pet -and $script:BuxeState.Pet.Companion) { 
        $cp = $script:BuxeState.Pet.Companion
        Write-Host "  |  Companion: $($cp.Name) [Bond: $($cp.Bond)]" -ForegroundColor Magenta 
    }
    if ($script:BuxeState.Pet -and $script:BuxeState.Pet.Pet) { 
        $ap = $script:BuxeState.Pet.Pet
        Write-Host "  |  Active Pet: $($ap.Name) [Lv.$($ap.Level)]" -ForegroundColor Green 
    }
    Write-Host "  +======================================+" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [NAV]      .. ... .... tmp dl docs mkcd" -ForegroundColor DarkGray
    Write-Host "  [FILES]    ll la touch rmrf c which grep" -ForegroundColor DarkGray
    Write-Host "  [GIT]      g gs ga gc gp gl gco gb gd glog gcm" -ForegroundColor DarkGray
    Write-Host "  [SYSTEM]   uptime weather ip port mem sudo reload profile sysinfo" -ForegroundColor DarkGray
    Write-Host "  [ARCADE]   snake monkeytype wordle zork hangman" -ForegroundColor DarkGray
    Write-Host "  [CASINO]   blackjack roulette craps hilo baccarat slot" -ForegroundColor DarkGray
    Write-Host "  [STRATEGY] poker td rogue" -ForegroundColor DarkGray
    Write-Host "  [PET]      pet (Companion + Battlepet Hub)" -ForegroundColor Magenta
    Write-Host "  [BANK]     bank daily" -ForegroundColor DarkGray
    Write-Host "  [STATS]    status achievements ego" -ForegroundColor DarkGray
    Write-Host "  [FUN]      genact parrot pomodoro roast sneakers uwu rig bs sudo-insult" -ForegroundColor DarkGray
    Write-Host "  [API]      chuck cat dog btc bored kanye dadjoke zen" -ForegroundColor DarkGray
    Write-Host "  [VOICE]    voices | svoice EN|ML # | Say 'text' [-Wait] | clip-say" -ForegroundColor DarkGray
    Write-Host "  [RALPH]    kimir kimia kimix kimis" -ForegroundColor DarkGray
    Write-Host "  [MISC]     capsule h" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Tip: Type 'status' for a full overview. 'pet' for the unified hub." -ForegroundColor DarkGray
    Write-Host ""
}

# === BACKWARD COMPATIBILITY ===
function companion { pet @args }
function battlepet { pet @args }

} catch {
    Write-Host "[engine-aliases-buxe] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
