# BUXE_OS v24.2 — PET RAID v2.0

try {

# Feste Begegnung: Boss-Werte skalieren NICHT mit dem Spielerlevel.
# Vorher taten sie das mit 15 % pro Level und wuchsen damit schneller als das Pet --
# die Siegquote lag in der Simulation bei 0 %, ueber alle Level und Ausruestungsstufen.
# Werte gegenueber v24 gestutzt: HP x0,7, ATK x0,85. DEF unveraendert.
# Belege und Zielkorridor: docs/superpowers/specs/2026-09-13-avs-baseline.md
$script:PetRaidBosses = @(
    @{ Name = "CYBER_GOLEM"; Type = "NORM"; HP = 210; ATK = 21; DEF = 20; SPD = 8 }
    @{ Name = "NET_TITAN"; Type = "ELEC"; HP = 315; ATK = 30; DEF = 25; SPD = 12 }
    @{ Name = "OMEGA_CORE"; Type = "HACK"; HP = 420; ATK = 38; DEF = 30; SPD = 15 }
)
$script:RaidShopItems = @(
    @{ Name = "Omega Chip"; Type = "Chip"; Cost = 15; Desc = "+10 ATK"; ATK = 10 }
    @{ Name = "Titan Plate"; Type = "Armor"; Cost = 15; Desc = "+10 DEF, +30 HP"; DEF = 10; HP = 30 }
    @{ Name = "Core Collar"; Type = "Accessory"; Cost = 15; Desc = "+10 SPD"; SPD = 10 }
    @{ Name = "Golem Heart"; Type = "Consumable"; Cost = 30; Desc = "+15% ALL Stats permanent"; Buff = @{ Stat = "ALL"; Value = 0.15 } }
    @{ Name = "Reboot Key"; Type = "Consumable"; Cost = 20; Desc = "Reset Raid-Cooldown" }
)

function Start-RaidShop {
    $pet = Get-PetState
    $p = $pet.Pet
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    while ($true) {
        try { Clear-Host } catch {}
        Show-PetFrame "RAID TOKEN SHOP" -Double | Out-Null
        Write-Host "`n  Tokens: $($pet.Pet.RaidTokens)" -ForegroundColor Yellow
        Write-Host "  Aktiv: $($p.Name) [Lv.$($p.Level)]" -ForegroundColor $p.Color
        Write-Host ""
        for ($i = 0; $i -lt $script:RaidShopItems.Count; $i++) {
            $it = $script:RaidShopItems[$i]
            Write-Host "  [$($i+1)] $($it.Name) [$($it.Type)] — $($it.Cost) Tokens | $($it.Desc)" -ForegroundColor White
        }
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
        $c = Read-Choice "Waehle" "^([1-$($script:RaidShopItems.Count)]|Q)$"
        if ($c -eq 'Q') { return }
        $item = $script:RaidShopItems[[int]$c - 1]
        if ($pet.Pet.RaidTokens -lt $item.Cost) {
            Write-Host "`n  Nicht genug Tokens!" -ForegroundColor Red
            Wait-Enter
            continue
        }
        $pet.Pet.RaidTokens -= $item.Cost
        if ($item.Type -eq "Consumable" -and $item.Name -eq "Reboot Key") {
            $pet.Pet.RaidCleared = ""
            Write-Host "`n  Raid-Cooldown zurueckgesetzt!" -ForegroundColor Magenta
        } elseif ($item.Type -eq "Consumable" -and $item.Name -eq "Golem Heart") {
            $p.MaxHP += [math]::Round($p.MaxHP * $item.Buff.Value)
            $p.ATK += [math]::Round($p.ATK * $item.Buff.Value)
            $p.DEF += [math]::Round($p.DEF * $item.Buff.Value)
            $p.SPD += [math]::Round($p.SPD * $item.Buff.Value)
            Write-Host "`n  Golem Heart konsumiert! Permanente +15% ALL Stats!" -ForegroundColor Magenta
        } else {
            $slot = $item.Type.ToLower()
            $p.Equipment.$slot = $item.Name
            Write-Host "`n  $($item.Name) ausgeruestet!" -ForegroundColor Green
        }
        Save-PetState $pet
        Wait-Enter
    }
}

function Start-PetRaid {
    $pet = Get-PetState
    $p = $pet.Pet
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    $today = Get-Date -Format "yyyy-MM-dd"
    if (-not $pet.Pet.RaidCleared) { $pet.Pet.RaidCleared = "" }
    if (-not $pet.Pet.RaidTokens) { $pet.Pet.RaidTokens = 0 }
    if (-not $pet.Pet.RaidBest) { $pet.Pet.RaidBest = 0 }
    while ($true) {
    try { Clear-Host } catch {}
        Show-PetFrame "RAID DUNGEON" -Double | Out-Null
        Write-Host "`n  Tokens: $($pet.Pet.RaidTokens) | Beste Phase: $($pet.Pet.RaidBest)" -ForegroundColor Yellow
        if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "raid_start") -Fast }
        if ($pet.Pet.RaidCleared -eq $today) { Write-Host "  [Heute bereits versucht]" -ForegroundColor Red }
        else { Write-Host "  [Verfuegbar]" -ForegroundColor Green }
        Write-Host "`n  [1] Raid starten | [2] Token-Shop | [Q] Zurueck" -ForegroundColor White
        $c = Read-Choice "Waehle" '^[12Q]$'
        if ($c -eq 'Q') { return }
        if ($c -eq '2') { Start-RaidShop; continue }
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
        $enemy = @{ Name = $boss.Name; HP = $boss.HP; MaxHP = $boss.HP; ATK = $boss.ATK; DEF = $boss.DEF; SPD = $boss.SPD }
    try { Clear-Host } catch {}
        Show-PetFrame "RAID PHASE $phase" -Double | Out-Null
        Write-Host "`n  $($enemy.Name) erscheint!" -ForegroundColor Red
        Start-Sleep -Milliseconds 500
        $round = 0
        while ($p.HP -gt 0 -and $enemy.HP -gt 0) {
            $round++; $stats = Get-EffectiveStats $p
    try { Clear-Host } catch {}
            Show-PetFrame "RAID $phase — Runde $round" -Double | Out-Null
            Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($stats.MaxHP) | [$($enemy.Name)] HP: $($enemy.HP)/$($enemy.MaxHP)" -ForegroundColor White
            if ($cp -and $healsUsed -lt $healCount -and $p.HP -lt ($stats.MaxHP * 0.5)) {
                $healAmt = [math]::Min([math]::Round($stats.MaxHP * 0.2), $stats.MaxHP - $p.HP)
                $p.HP += $healAmt; $healsUsed++
                $healLine = (Get-CompanionLine $cp "raid_heal") -replace '\{HEAL\}', $healAmt
                Show-CompanionDialog $cp $healLine -Fast
            }
            Write-Host "`n  [A]ngriff [V]erteidigung [S]pecial" -ForegroundColor White
            $pm = Read-Choice "Zug" '^[AVS]$'
            $rm = @("A","V","S") | Get-Random
            $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
            Write-Host "`n  Du: $($moves[$pm]) | Boss: $($moves[$rm])" -ForegroundColor DarkGray
            $avs = Resolve-AvsRound -PlayerMove $pm -EnemyMove $rm -PlayerStats $stats -EnemyStats $enemy `
                        -PlayerLevel $p.Level -EnemyLevel ($phase * 3) `
                        -MovePower $script:AvsMovePower.Raid[$phase - 1]
            $enemy.HP -= $avs.PlayerDamage
            $p.HP -= $avs.EnemyDamage
            switch ($avs.Outcome) {
                "Tie"  { Write-Host "  Gleichstand! Beide treffen!" -ForegroundColor Yellow }
                "Win"  { Write-Host "  Treffer! -$($avs.PlayerDamage) HP!" -ForegroundColor Green }
                "Loss" { Write-Host "  Treffer! -$($avs.EnemyDamage) HP!" -ForegroundColor Red }
            }
            Start-Sleep -Milliseconds 500
        }
        if ($p.HP -le 0) {
            Write-Host "`n  RAID GESCHEITERT bei Phase $phase!" -ForegroundColor Red
            if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "raid_fail") -Fast }
            Publish-BuxeEvent -Topic "raid.lost" -Data @{ Phase = $phase }
            $p.HP = [math]::Round((Get-EffectiveStats $p).MaxHP * 0.3)
            break
        } else {
            $tokens += switch ($phase) { 1 { 1 } 2 { 3 } 3 { 10 } }
            Write-Host "`n  PHASE $phase GESCHAFFT!" -ForegroundColor Green
            if ($phase -ge 2) { Check-QuestProgress "raid" }
            if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "raid_phase") -Fast }
            if ($phase -eq 3) {
                Write-Host "  *** RAID COMPLETE! ***" -ForegroundColor Magenta
                Add-PetXP 100 "Raid Complete"
                Publish-BuxeEvent -Topic "raid.won" -Data @{ Phase = $phase; Tokens = $tokens }
                if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "raid_complete") -Fast }
            } else { Start-Sleep -Seconds 1 }
        }
        $phase++
    }
    $pet.Pet.RaidCleared = (Get-Date -Format "yyyy-MM-dd")
    $pet.Pet.RaidTokens += $tokens
    if ($phase -gt $pet.Pet.RaidBest) { $pet.Pet.RaidBest = $phase - 1 }
    Save-PetState $pet
    Write-Host "`n  Tokens: $tokens | Gesamt: $($pet.Pet.RaidTokens)" -ForegroundColor Yellow
    Invoke-Layer47Check
    Wait-Enter
}

} catch {
    Write-Host "[pet/raid] CRITICAL ERROR: $_" -ForegroundColor Red
}
