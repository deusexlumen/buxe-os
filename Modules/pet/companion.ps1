# BUXE_OS v24.2 — COMPANION CORE v2.0

try {

function New-Companion {
    try { Clear-Host } catch {}
    Show-PetFrame "COMPANION INITIALISIERUNG" -Double | Out-Null
    Write-Host ""
    for ($i = 0; $i -lt $script:CPNames.Count; $i++) {
        Write-Host "  [$($i+1)] $($script:CPNames[$i]) [$($script:CPRoles[$i])]" -ForegroundColor $script:CPColors[$i]
    }
    $c = Read-Choice "Waehle [1-7]" '^[1-7]$'
    $idx = [int]$c - 1
    $pet = Get-PetState
    $pet.Companion = @{
        Name = $script:CPNames[$idx]; Role = $script:CPRoles[$idx]
        Color = $script:CPColors[$idx]; Bond = 10; Mood = "Happy"
        Talks = 0; Gifts = 0; Dates = 0; WorkCount = 0; Trains = 0; Headpats = 0
        LastLogin = ""; LastWork = ""; Outfit = "Default"
        Skills = @{ CombatBoost = 0; CasinoLuck = 0; StrategyInsight = 0 }
        Sync = 0
        MarryDate = $null
    }
    Save-PetState $pet
    Write-Host "`n  $($pet.Companion.Name) ist online." -ForegroundColor $pet.Companion.Color
    Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "first_boot") -Fast
    Wait-Enter
}

function Invoke-CompanionAction($action) {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { New-Companion; return }
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($cp.LastLogin -ne $today) {
        $cp.LastLogin = $today
        $pet.Meta.TotalSessions++
        $bonus = Get-Random -Minimum 3 -Maximum 8
        $cp.Bond = [math]::Min(100, $cp.Bond + $bonus)
        Save-PetState $pet
        Check-EasterEgg "login"
    }
    switch ($action.ToLower()) {
        "talk" {
            $isFirstTalk = ($pet.Meta.Stats.TalkCount -eq 0)
            $pet.Meta.Stats.TalkCount++
            $gain = [math]::Min(100, $cp.Bond + 2); $cp.Bond = $gain; $cp.Talks++
            $line = Get-CompanionLine $cp "talk"
            Show-CompanionDialog $cp $line
            Check-EasterEgg "talk"
            $xpGain = if ($isFirstTalk) { 3 } else { 2 }
            Add-PetXP $xpGain "Talk"
            Check-QuestProgress "talk"
        }
        "gift" {
            $pet.Meta.Stats.GiftCount++
            $cp.Gifts++; $cp.Bond = [math]::Min(100, $cp.Bond + 5)
            $cp.Mood = if ((Get-Random -Maximum 2) -eq 0) { "Excited" } else { "Loving" }
            Show-CompanionDialog $cp (Get-CompanionLine $cp "gift")
            Add-PetXP 5 "Gift"
            Check-QuestProgress "gift"
        }
        "date" {
            if ($cp.Bond -lt 30) { Show-CompanionDialog $cp "Wir sind nicht nah genug..."; Wait-Enter; return }
            $cp.Dates++; $cp.Bond = [math]::Min(100, $cp.Bond + 4); $cp.Mood = "Loving"
            $dateText = @("Ihr schaut euch die digitale Aurora an.","Ihr teilt eine virtuelle Mahlzeit.","Ihr tanzt in Schwerelosigkeit.") | Get-Random
            Write-Host "`n  DATE: $dateText" -ForegroundColor Magenta
            Show-CompanionDialog $cp "*errötet* Das war... schön."
            if ($cp.Dates -eq 1) { Add-PetMemory "Erstes Date mit $($cp.Name)!" "DATE" }
            Add-PetXP 8 "Date"
        }
        "work" {
            if ($cp.LastWork -eq $today) { Show-CompanionDialog $cp "Ich habe heute schon gearbeitet."; Wait-Enter; return }
            Show-PetFrame "JOB MARKET" -Double | Out-Null
            Write-Host "`n  [1] Data Mining    (sicher, 10-20G)" -ForegroundColor White
            Write-Host "  [2] Security Patrol (mittel, 20-35G)" -ForegroundColor White
            Write-Host "  [3] Netrunner Mission (riskant, 0 oder 50-80G)" -ForegroundColor White
            Write-Host "  [Q] Abbrechen" -ForegroundColor DarkGray
            $jc = Read-Choice "Job" '^[123Q]$'
            if ($jc -eq 'Q') { return }
            $cp.LastWork = $today; $cp.WorkCount++; $cp.Mood = "Tired"
            $earn = 0; $bonusText = ""
            if ($jc -eq '1') { $earn = Get-Random -Minimum 10 -Maximum 21 }
            elseif ($jc -eq '2') { $earn = Get-Random -Minimum 20 -Maximum 36 }
            else {
                if ((Get-Random -Maximum 2) -eq 0) { $earn = Get-Random -Minimum 50 -Maximum 81 }
                else { $bonusText = " | Mission fehlgeschlagen..." }
            }
            if ($earn -gt 0) { $pet.Economy.Gold += $earn }
            if ($cp.WorkCount -eq 1) { Add-PetMemory "Erster Job mit $($cp.Name). Earned $earn G." "WORK" }
            # CasinoLuck skill progression
            if ($earn -gt 0) { Check-QuestProgress "work" }
            if ($earn -gt 0 -and $cp.Skills.CasinoLuck -lt 10 -and (Get-Random -Maximum 100) -lt 20) {
                $cp.Skills.CasinoLuck++
                Write-Host "  [SKILL UP] Casino Luck ist jetzt Level $($cp.Skills.CasinoLuck)!" -ForegroundColor Magenta
            }
            Save-PetState $pet
            Show-CompanionDialog $cp (Get-CompanionLine $cp "work")
            Write-Host "  Verdient: $earn G$bonusText" -ForegroundColor Yellow
            Add-PetXP ($earn / 5) "Work"
        }
        "train" {
            $pet.Meta.Stats.TrainCount++; $cp.Trains++; $cp.Mood = "Excited"
            $cp.Bond = [math]::Min(100, $cp.Bond + 3)
            if ($pet.Pet) { $pet.Pet.ATK += 1 }
            # StrategyInsight skill progression
            if ($cp.Skills.StrategyInsight -lt 10 -and (Get-Random -Maximum 100) -lt 25) {
                $cp.Skills.StrategyInsight++
                Write-Host "  [SKILL UP] Strategy Insight ist jetzt Level $($cp.Skills.StrategyInsight)!" -ForegroundColor Magenta
            }
            Save-PetState $pet
            Show-CompanionDialog $cp (Get-CompanionLine $cp "train")
            if ($pet.Pet) { Write-Host "  $($pet.Pet.Name) ATK +1!" -ForegroundColor Green }
            Add-PetXP 4 "Train"
        }
        "punish" {
            $pet.Meta.Stats.PunishCount++; $cp.Mood = "Angry"
            $pun = @("*packt dein Kinn* Schau mich an.","Auf die Knie. Entschuldige dich.","*schlägt leicht* Mitleidswürdig." ) | Get-Random
            Write-Host "`n  [$($cp.Name)] $pun" -ForegroundColor Red
            Check-EasterEgg "punish"
            Add-PetXP 2 "Punish"
        }
        "headpat" {
            $cp.Headpats++; $cp.Mood = if ($cp.Bond -ge 50) { "Loving" } else { "Happy" }
            $cp.Bond = [math]::Min(100, $cp.Bond + 1)
            Write-Host "`n  Du streichelst $($cp.Name)." -ForegroundColor Cyan
            Add-PetXP 1 "Headpat"
        }
    }
    Save-PetState $pet
    Wait-Enter
}

function Show-CompanionStatus($cp) {
    if (-not $cp) { return }
    $bar = Show-Bar $cp.Bond 100 20
    try { Clear-Host } catch {}
    Show-PetFrame "$($cp.Name) -- $($cp.Role)" -Double | Out-Null
    Write-Host ""
    Write-Host "  Bond: [$bar] $($cp.Bond)/100" -ForegroundColor White
    Write-Host "  Mood: $($cp.Mood) | Outfit: $($cp.Outfit) | Work: $($cp.WorkCount)x" -ForegroundColor DarkGray
    Write-Host "  Talks: $($cp.Talks) | Gifts: $($cp.Gifts) | Dates: $($cp.Dates) | Headpats: $($cp.Headpats)" -ForegroundColor DarkGray
    Write-Host ""
}

function Invoke-CompanionTalk {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp) { New-Companion; return }
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($cp.LastLogin -ne $today) {
        $cp.LastLogin = $today
        $pet.Meta.TotalSessions++
        $bonus = Get-Random -Minimum 3 -Maximum 8
        $cp.Bond = [math]::Min(100, $cp.Bond + $bonus)
        Save-PetState $pet
    }
    $pet.Meta.Stats.TalkCount++
    $cp.Talks++
    $tier = if ($cp.Bond -lt 30) { "Low" } elseif ($cp.Bond -lt 70) { "Med" } else { "High" }
    # Build dialog options
    $opts = @()
    foreach ($g in $script:CPDialogGeneric) {
        if ($g.BlockMood -and $g.BlockMood -contains $cp.Mood) { continue }
        $opts += $g
    }
    if ($script:CPDialogSpecial.ContainsKey($cp.Name)) {
        $opts += $script:CPDialogSpecial[$cp.Name]
    }
    # Greeting
    try { Clear-Host } catch {}
    Show-PetFrame "COMPANION TALK" -Double | Out-Null
    Write-Host ""
    $greeting = Get-CompanionLine $cp "talk"
    Show-CompanionDialog $cp $greeting
    Write-Host ""
    # Options
    for ($i = 0; $i -lt $opts.Count; $i++) {
        $label = if ($opts[$i].Exit) { "[Q]" } else { "[$($i+1)]" }
        Write-Host "  $label $($opts[$i].Text)" -ForegroundColor White
    }
    Write-Host ""
    $valid = ""
    for ($i = 1; $i -le $opts.Count; $i++) { if (-not $opts[$i-1].Exit) { $valid += "$i" } }
    $valid += "Q"
    $pattern = "^([$valid])$"
    $c = Read-Choice "Waehle" $pattern
    if ($c -eq 'Q') { Wait-Enter; return }
    $idx = [int]$c - 1
    $sel = $opts[$idx]
    # Apply effect
    if ($sel.Bond -gt 0) {
        $cp.Bond = [math]::Min(100, $cp.Bond + $sel.Bond)
    }
    if ($sel.SetMood) { $cp.Mood = $sel.SetMood }
    if ($sel.EasterEggChance -and (Get-Random -Maximum 100) -lt $sel.EasterEggChance) {
        Check-EasterEgg "talk"
    }
    Save-PetState $pet
    # Reaction from character-specific pool
    $pool = $script:CPReactionPools[$sel.ReactionPool][$cp.Name]
    if ($pool) { Show-CompanionDialog $cp ($pool | Get-Random) }
    Add-PetXP 1 "Talk"
    Wait-Enter
}

} catch {
    Write-Host "[pet/companion] CRITICAL ERROR: $_" -ForegroundColor Red
}
