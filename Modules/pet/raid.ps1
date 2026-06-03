# BUXE_OS v24.2 — PET RAID v2.0

try {

$script:PetRaidBosses = @(
    @{ Name = "CYBER_GOLEM"; Type = "NORM"; HP = 300; ATK = 25; DEF = 20; SPD = 8 }
    @{ Name = "NET_TITAN"; Type = "ELEC"; HP = 450; ATK = 35; DEF = 25; SPD = 12 }
    @{ Name = "OMEGA_CORE"; Type = "HACK"; HP = 600; ATK = 45; DEF = 30; SPD = 15 }
)

function Start-PetRaid {
    $pet = Get-PetState
    $p = $pet.Pet
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    $today = Get-Date -Format "yyyy-MM-dd"
    if (-not $pet.Pet.RaidCleared) { $pet.Pet.RaidCleared = "" }
    if (-not $pet.Pet.RaidTokens) { $pet.Pet.RaidTokens = 0 }
    if (-not $pet.Pet.RaidBest) { $pet.Pet.RaidBest = 0 }
    while ($true) {
        Clear-Host
        Show-PetFrame "RAID DUNGEON" -Double | Out-Null
        Write-Host "`n  Tokens: $($pet.Pet.RaidTokens) | Beste Phase: $($pet.Pet.RaidBest)" -ForegroundColor Yellow
        if ($pet.Pet.RaidCleared -eq $today) { Write-Host "  [Heute bereits versucht]" -ForegroundColor Red }
        else { Write-Host "  [Verfuegbar]" -ForegroundColor Green }
        Write-Host "`n  [1] Raid starten | [Q] Zurueck" -ForegroundColor White
        $c = Read-Choice "Waehle" '^[1Q]$'
        if ($c -eq 'Q') { return }
        if ($pet.Pet.RaidCleared -eq $today) { Write-Host "`n  Heute schon versucht!" -ForegroundColor Red; Wait-Enter; continue }
        Invoke-PetRaidBattle $pet $p
    }
}

function Invoke-PetRaidBattle($pet, $p) {
    $cp = $pet.Companion
    $healCount = if ($cp -and $cp.Bond -ge 100) { 2 } elseif ($cp -and $cp.Bond -ge 50) { 1 } else { 0 }
    $healsUsed = 0
    $phase = 1; $tokens = 0
    while ($phase -le 3) {
        $boss = $script:PetRaidBosses[$phase - 1]
        $sc = 1 + ($p.Level - 1) * 0.15
        $enemy = @{ Name = $boss.Name; HP = [math]::Round($boss.HP * $sc); MaxHP = [math]::Round($boss.HP * $sc); ATK = [math]::Round($boss.ATK * $sc); DEF = [math]::Round($boss.DEF * $sc); SPD = [math]::Round($boss.SPD * $sc) }
        Clear-Host
        Show-PetFrame "RAID PHASE $phase" -Double | Out-Null
        Write-Host "`n  $($enemy.Name) erscheint!" -ForegroundColor Red
        Start-Sleep -Milliseconds 500
        $round = 0
        while ($p.HP -gt 0 -and $enemy.HP -gt 0) {
            $round++; $stats = Get-EffectiveStats $p
            Clear-Host
            Show-PetFrame "RAID $phase — Runde $round" -Double | Out-Null
            Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($stats.MaxHP) | [$($enemy.Name)] HP: $($enemy.HP)/$($enemy.MaxHP)" -ForegroundColor White
            if ($cp -and $healsUsed -lt $healCount -and $p.HP -lt ($stats.MaxHP * 0.5)) {
                $healAmt = [math]::Min([math]::Round($stats.MaxHP * 0.2), $stats.MaxHP - $p.HP)
                $p.HP += $healAmt; $healsUsed++
                Show-CompanionDialog $cp "Ich heile dich! +$healAmt HP!" -Fast
            }
            Write-Host "`n  [A]ngriff [V]erteidigung [S]pecial" -ForegroundColor White
            $pm = Read-Choice "Zug" '^[AVS]$'
            $rm = @("A","V","S") | Get-Random
            $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
            $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
            Write-Host "`n  Du: $($moves[$pm]) | Boss: $($moves[$rm])" -ForegroundColor DarkGray
            if ($pm -eq $rm) {
                $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 1.5) * (100 / (100 + $enemy.DEF))))
                $enemy.HP -= $dmg; $p.HP -= [math]::Max(1, [math]::Round($enemy.ATK * (100 / (100 + $stats.DEF))))
                Write-Host "  Gleichstand! Beide treffen!" -ForegroundColor Yellow
            } elseif ($beats[$pm] -eq $rm) {
                $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 2) * (100 / (100 + $enemy.DEF))))
                $enemy.HP -= $dmg
                Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Green
            } else {
                $dmg = [math]::Max(1, [math]::Round($enemy.ATK * (100 / (100 + $stats.DEF))))
                $p.HP -= $dmg
                Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Red
            }
            Start-Sleep -Milliseconds 500
        }
        if ($p.HP -le 0) {
            Write-Host "`n  RAID GESCHEITERT bei Phase $phase!" -ForegroundColor Red
            $p.HP = [math]::Round((Get-EffectiveStats $p).MaxHP * 0.3)
            break
        } else {
            $tokens += switch ($phase) { 1 { 1 } 2 { 3 } 3 { 10 } }
            Write-Host "`n  PHASE $phase GESCHAFFT!" -ForegroundColor Green
            if ($phase -eq 3) {
                Write-Host "  *** RAID COMPLETE! ***" -ForegroundColor Magenta
                Add-PetXP 100 "Raid Complete"
            } else { Start-Sleep -Seconds 1 }
        }
        $phase++
    }
    $pet.Pet.RaidCleared = (Get-Date -Format "yyyy-MM-dd")
    $pet.Pet.RaidTokens += $tokens
    if ($phase -gt $pet.Pet.RaidBest) { $pet.Pet.RaidBest = $phase - 1 }
    Save-PetState $pet
    Write-Host "`n  Tokens: $tokens | Gesamt: $($pet.Pet.RaidTokens)" -ForegroundColor Yellow
    Wait-Enter
}

} catch {
    Write-Host "[pet/raid] CRITICAL ERROR: $_" -ForegroundColor Red
}
