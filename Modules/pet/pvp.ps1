# BUXE_OS v24.2 — PET PvP v2.0

try {

$script:PetRanks = @("Bronze","Silver","Gold","Platinum","Diamond","Master")
$script:PetRankThresholds = @(0, 100, 250, 500, 800, 1200)

function Start-PetPvP {
    $pet = Get-PetState
    $p = $pet.Pet
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    $rankIdx = $script:PetRanks.IndexOf($pet.Pet.Rank)
    if ($rankIdx -lt 0) { $rankIdx = 0; $pet.Pet.Rank = "Bronze" }
    try { Clear-Host } catch {}
    Show-PetFrame "PVP ARENA [$($pet.Pet.Rank)]" -Double | Out-Null
    Write-Host "`n  Punkte: $($pet.Pet.PvPPoints) | Siege: $($pet.Pet.PvPWins)" -ForegroundColor Yellow
    Write-Host "  [1] Kaempfen | [Q] Zurueck" -ForegroundColor White
    $c = Read-Choice "Waehle" '^[1Q]$'
    if ($c -eq 'Q') { return }
    $stats = Get-EffectiveStats $p
    $p.HP = $stats.MaxHP

    # ARG v3.0: Matrix unlock -> Observer_148
    $enemyName = "SHADOW_" + (Get-Random -Maximum 9999)
    if (Get-Command Test-ArgObserver148 -ErrorAction SilentlyContinue) {
        if (Test-ArgObserver148) {
            $enemyName = "Observer_148"
        }
    }

    $enemy = @{
        Name = $enemyName
        HP = [math]::Round((80 + $rankIdx * 20) * (1 + ($p.Level - 1) * 0.25))
        ATK = [math]::Round((12 + $rankIdx * 4) * (1 + ($p.Level - 1) * 0.25))
        DEF = [math]::Round((7 + $rankIdx * 2) * (1 + ($p.Level - 1) * 0.25))
        SPD = [math]::Round((10 + $rankIdx * 3) * (1 + ($p.Level - 1) * 0.25))
    }
    $enemy.MaxHP = $enemy.HP
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $ps = 0; $es = 0
    for ($r = 1; $r -le 3; $r++) {
    try { Clear-Host } catch {}
        Show-PetFrame "PVP — Runde $r/3" -Double | Out-Null
        Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($stats.MaxHP) | [$($enemy.Name)] HP: $($enemy.HP)/$($enemy.MaxHP)" -ForegroundColor White
        if ($pet.Companion -and $pet.Companion.Bond -ge 30) {
            $cheer = if ($pet.Companion.Bond -ge 80) { "ZERSTÖRE SIE!" } else { "Du schaffst das... bestimmt..." }
            Write-Host "  [$($pet.Companion.Name)] >> $cheer" -ForegroundColor Magenta
        }
        Write-Host "`n  [A]ngriff [V]erteidigung [S]pecial" -ForegroundColor White
        $pm = Read-Choice "Zug" '^[AVS]$'
        $rm = @("A","V","S") | Get-Random
        Write-Host "`n  Du: $($moves[$pm]) | Gegner: $($moves[$rm])" -ForegroundColor DarkGray
        if ($pm -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 1.5) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $p.HP -= [math]::Max(1, [math]::Round($enemy.ATK * (100 / (100 + $stats.DEF))))
            Write-Host "  Gleichstand! Beide treffen!" -ForegroundColor Yellow
        } elseif ($beats[$pm] -eq $rm) {
            $dmg = [math]::Max(1, [math]::Round(($stats.ATK * 2) * (100 / (100 + $enemy.DEF))))
            $enemy.HP -= $dmg; $ps++
            Write-Host "  Treffer! -$dmg HP!" -ForegroundColor Green
        } else {
            $dmg = [math]::Max(1, [math]::Round($enemy.ATK * (100 / (100 + $stats.DEF))))
            $p.HP -= $dmg; $es++
            Write-Host "  Treffer erhalten! -$dmg HP!" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 500
    }
    try { Clear-Host } catch {}
    if ($ps -gt $es) {
        $gain = 20 + $rankIdx * 10; $pet.Pet.PvPPoints += $gain; $pet.Pet.PvPWins++
        $gold = Get-Random -Minimum (15 + $rankIdx * 5) -Maximum (31 + $rankIdx * 10)
        $pet.Economy.Gold += $gold
        # Loot drop chance increases with rank
        $lootChance = 15 + $rankIdx * 10
        $lootText = ""
        if ((Get-Random -Maximum 100) -lt $lootChance) {
            $lootItems = @("Scrap Metal","Data Shard","Energy Cell","Rare Chip","Boss Core")
            $loot = $lootItems[$rankIdx]
            $pet.Economy.Inventory += $loot
            $lootText = " | Loot: $loot"
        }
        # Companion sync bonus on win
        if ($pet.Companion) { $pet.Companion.Sync += 2 }
        Write-Host "`n  GEWONNEN! +$gain Pts | +$gold G$lootText" -ForegroundColor Green
        Add-PetXP (15 + $rankIdx * 2) "PvP Win"
        Check-QuestProgress "pvp"
        if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "pvp_win") -Fast }
    } elseif ($ps -lt $es) {
        $pet.Pet.PvPPoints = [math]::Max(0, $pet.Pet.PvPPoints - 10)
        Write-Host "`n  NIEDERLAGE..." -ForegroundColor Red
        Add-PetXP 5 "PvP Loss"
        if ($pet.Companion) { Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "pvp_loss") -Fast }
    } else {
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        Add-PetXP 8 "PvP Draw"
    }
    $newRank = $script:PetRanks[0]
    for ($i = $script:PetRankThresholds.Count - 1; $i -ge 0; $i--) {
        if ($pet.Pet.PvPPoints -ge $script:PetRankThresholds[$i]) { $newRank = $script:PetRanks[$i]; break }
    }
    if ($newRank -ne $pet.Pet.Rank) {
        Write-Host "  RANK UP! $($pet.Pet.Rank) -> $newRank!" -ForegroundColor Magenta
        $pet.Pet.Rank = $newRank
        if ($pet.Companion) { Show-CompanionDialog $pet.Companion "Du bist unglaublich! $newRank! Das ist... das ist ETWAS!" -Fast }
    }
    Save-PetState $pet
    Invoke-Layer47Check
    Wait-Enter
}

} catch {
    Write-Host "[pet/pvp] CRITICAL ERROR: $_" -ForegroundColor Red
}
