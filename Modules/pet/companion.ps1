# BUXE_OS v24.2 — COMPANION CORE v2.0

try {

function New-Companion {
    Clear-Host
    Show-PetFrame "COMPANION INITIALISIERUNG" -Double | Out-Null
    Write-Host ""
    for ($i = 0; $i -lt $script:CPNames.Count; $i++) {
        Write-Host "  [$($i+1)] $($script:CPNames[$i]) [$($script:CPRoles[$i])]" -ForegroundColor $script:CPColors[$i]
    }
    $c = Read-Choice "Waehle [1-5]" '^[1-5]$'
    $idx = [int]$c - 1
    $pet = Get-PetState
    $pet.Companion = @{
        Name = $script:CPNames[$idx]; Role = $script:CPRoles[$idx]
        Color = $script:CPColors[$idx]; Bond = 10; Mood = "Happy"
        Talks = 0; Gifts = 0; Dates = 0; WorkCount = 0; Trains = 0; Headpats = 0
        LastLogin = ""; LastWork = ""; Outfit = "Default"
        Skills = @{ CombatBoost = 0; CasinoLuck = 0; StrategyInsight = 0 }
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
            $pet.Meta.Stats.TalkCount++
            $gain = [math]::Min(100, $cp.Bond + 2); $cp.Bond = $gain; $cp.Talks++
            $line = Get-CompanionLine $cp "talk"
            Show-CompanionDialog $cp $line
            Check-EasterEgg "talk"
            Add-PetXP 1 "Talk"
        }
        "gift" {
            $pet.Meta.Stats.GiftCount++
            $cp.Gifts++; $cp.Bond = [math]::Min(100, $cp.Bond + 5)
            $cp.Mood = if ((Get-Random -Maximum 2) -eq 0) { "Excited" } else { "Loving" }
            Show-CompanionDialog $cp (Get-CompanionLine $cp "gift")
            Add-PetXP 5 "Gift"
        }
        "date" {
            if ($cp.Bond -lt 30) { Show-CompanionDialog $cp "Wir sind nicht nah genug..."; Wait-Enter; return }
            $cp.Dates++; $cp.Bond = [math]::Min(100, $cp.Bond + 4); $cp.Mood = "Loving"
            $dateText = @("Ihr schaut euch die digitale Aurora an.","Ihr teilt eine virtuelle Mahlzeit.","Ihr tanzt in Schwerelosigkeit.") | Get-Random
            Write-Host "`n  DATE: $dateText" -ForegroundColor Magenta
            Show-CompanionDialog $cp "*errötet* Das war... schön."
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
            # CasinoLuck skill progression
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
    Clear-Host
    Show-PetFrame "$($cp.Name) -- $($cp.Role)" -Double | Out-Null
    Write-Host ""
    Write-Host "  Bond: [$bar] $($cp.Bond)/100" -ForegroundColor White
    Write-Host "  Mood: $($cp.Mood) | Outfit: $($cp.Outfit) | Work: $($cp.WorkCount)x" -ForegroundColor DarkGray
    Write-Host "  Talks: $($cp.Talks) | Gifts: $($cp.Gifts) | Dates: $($cp.Dates) | Headpats: $($cp.Headpats)" -ForegroundColor DarkGray
    Write-Host ""
}

} catch {
    Write-Host "[pet/companion] CRITICAL ERROR: $_" -ForegroundColor Red
}
