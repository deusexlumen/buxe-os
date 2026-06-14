# BUXE_OS v24.2 — PET ECONOMY v2.0
# Work, Shop, Cooking

try {

$script:PetShopItems = @(
    @{ Type = "Chip"; Name = "Neural Chip"; Cost = 60; Desc = "+3 ATK"; ATK = 3 }
    @{ Type = "Armor"; Name = "Plasma Armor"; Cost = 60; Desc = "+3 DEF, +10 HP"; DEF = 3; HP = 10 }
    @{ Type = "Accessory"; Name = "Speed Collar"; Cost = 60; Desc = "+3 SPD"; SPD = 3 }
    @{ Type = "Chip"; Name = "Quantum Chip"; Cost = 150; Desc = "+6 ATK"; ATK = 6 }
    @{ Type = "Armor"; Name = "Aegis Plate"; Cost = 150; Desc = "+6 DEF, +20 HP"; DEF = 6; HP = 20 }
    @{ Type = "Accessory"; Name = "Hyper Loop"; Cost = 150; Desc = "+6 SPD"; SPD = 6 }
)

function Get-PetShopPrice {
    param(
        [Parameter(Mandatory=$true)][string]$ItemName,
        [Parameter(Mandatory=$false)][double]$LevelMultiplier = 1.0
    )
    $item = $script:PetShopItems | Where-Object { $_.Name -eq $ItemName } | Select-Object -First 1
    if (-not $item) { return $null }
    $discount = Get-PetSkillBonus -Branch 'Economy' -Tier 3
    $base = [math]::Floor($item.Cost * $LevelMultiplier)
    return [math]::Max(1, [math]::Floor($base * (1 - $discount)))
}
$script:PetRecipes = @(
    @{ Name = "Ramen"; Cost = 15; Desc = "+10% MaxHP (1 Kampf)"; Buff = @{ Stat = "MaxHP"; Value = 0.10 } }
    @{ Name = "Energy Drink"; Cost = 20; Desc = "+20% SPD (1 Kampf)"; Buff = @{ Stat = "SPD"; Value = 0.20 } }
    @{ Name = "Sushi Platter"; Cost = 30; Desc = "+15% ATK (1 Kampf)"; Buff = @{ Stat = "ATK"; Value = 0.15 } }
    @{ Name = "Golden Curry"; Cost = 50; Desc = "+10% All Stats (1 Kampf)"; Buff = @{ Stat = "ALL"; Value = 0.10 } }
)
$script:CraftedItems = @(
    @{ Type = "Chip"; Name = "Custom Chip"; Materials = @{ "Scrap Metal" = 3 }; Desc = "+4 ATK"; ATK = 4 }
    @{ Type = "Armor"; Name = "Plasma Injector"; Materials = @{ "Data Shard" = 2; "Energy Cell" = 1 }; Desc = "+10 HP, +2 ATK"; HP = 10; ATK = 2 }
    @{ Type = "Accessory"; Name = "Speed Module"; Materials = @{ "Energy Cell" = 2; "Data Shard" = 1 }; Desc = "+5 SPD"; SPD = 5 }
    @{ Type = "Chip"; Name = "Omega Weapon"; Materials = @{ "Rare Chip" = 1; "Boss Core" = 2 }; Desc = "+12 ATK"; ATK = 12 }
    @{ Type = "Armor"; Name = "Titan Shield"; Materials = @{ "Boss Core" = 1; "Scrap Metal" = 2 }; Desc = "+8 DEF, +20 HP"; DEF = 8; HP = 20 }
    @{ Type = "Accessory"; Name = "Hyper Drive"; Materials = @{ "Rare Chip" = 1; "Boss Core" = 1; "Energy Cell" = 1 }; Desc = "+8 SPD"; SPD = 8 }
)

function Start-PetShop {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    while ($true) {
    try { Clear-Host } catch {}
        Show-PetFrame "SCHWARZMARKT" -Double | Out-Null
        Write-Host "`n  Gold: $($pet.Economy.Gold) G" -ForegroundColor Yellow
        Write-Host "  Aktiv: $($p.Name) [Lv.$($p.Level)]" -ForegroundColor $p.Color
        Write-Host ""
        $levelMult = 1.0 + ($p.Level - 1) * 0.1
        for ($i = 0; $i -lt $script:PetShopItems.Count; $i++) {
            $it = $script:PetShopItems[$i]
            $displayCost = Get-PetShopPrice -ItemName $it.Name -LevelMultiplier $levelMult
            Write-Host "  [$($i+1)] $($it.Name) [$($it.Type)] — $displayCost G | $($it.Desc)" -ForegroundColor White
        }
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
        $c = Read-Choice "Waehle" "^([1-$($script:PetShopItems.Count)]|Q)$"
        if ($c -eq 'Q') { return }
        $item = $script:PetShopItems[[int]$c - 1]
        $actualCost = Get-PetShopPrice -ItemName $item.Name -LevelMultiplier $levelMult
        if ($pet.Economy.Gold -lt $actualCost) { Write-Host "`n  Nicht genug Gold!" -ForegroundColor Red; Wait-Enter; continue }
        $slot = $item.Type.ToLower()
        $p.Equipment.$slot = $item.Name
        $durKey = "Dur_$slot"
        $p.$durKey = 10
        $pet.Economy.Gold -= $actualCost
        if (-not $pet.Tutorial.Flags.firstShop) {
            $pet.Tutorial.Flags.firstShop = $true
        }
        Save-PetState $pet
        Check-QuestProgress "shop"
        if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "shop_buy") -Fast }
        Write-Host "`n  $($item.Name) ausgeruestet!" -ForegroundColor Green
        Invoke-Layer47Check
        Wait-Enter
    }
}

function Start-PetCook {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if (-not $cp) { Write-Host "Kein Companion!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    try { Clear-Host } catch {}
    Show-PetFrame "COMPANION KUECHE" -Double | Out-Null
    Write-Host "`n  Waehle ein Gericht fuer $($p.Name):" -ForegroundColor White
    Write-Host ""
    $levelMult = 1.0 + ($p.Level - 1) * 0.1
    $cookingDiscount = Get-PetSkillBonus -Branch 'Economy' -Tier 3
    for ($i = 0; $i -lt $script:PetRecipes.Count; $i++) {
        $r = $script:PetRecipes[$i]
        $displayCost = [math]::Max(1, [math]::Floor($r.Cost * $levelMult * (1 - $cookingDiscount)))
        Write-Host "  [$($i+1)] $($r.Name) — $displayCost G | $($r.Desc)" -ForegroundColor White
    }
    Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
    $c = Read-Choice "Waehle" "^([1-$($script:PetRecipes.Count)]|Q)$"
    if ($c -eq 'Q') { return }
    $recipe = $script:PetRecipes[[int]$c - 1]
    $actualCost = [math]::Max(1, [math]::Floor($recipe.Cost * $levelMult * (1 - $cookingDiscount)))
    if ($pet.Economy.Gold -lt $actualCost) {
        Write-Host "`n  Nicht genug Gold! ($actualCost G benoetigt)" -ForegroundColor Red
        Wait-Enter
        return
    }
    $pet.Economy.Gold -= $actualCost
    $p.FoodBuffs = @($recipe.Buff)
    if ($cp.Bond -ge 50 -and (Get-Random -Maximum 3) -eq 0) {
        $p.FoodBuffs += @{ Name = "Mystery Stew"; Desc = "+5% All"; Stat = "ALL"; Value = 0.05 }
        Write-Host "`n  BONUS DISH! Mystery Stew gezaubert!" -ForegroundColor Magenta
    }
    Save-PetState $pet
    Check-QuestProgress "cook"
    Show-CompanionDialog $cp (Get-CompanionLine $cp "cook") -Fast
    Write-Host "  $($recipe.Name) fuer $($p.Name)! Naechster Kampf: $($recipe.Desc)" -ForegroundColor Green
    Invoke-Layer47Check
    Wait-Enter
}

function Start-PetCrafting {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    while ($true) {
        try { Clear-Host } catch {}
        Show-PetFrame "CRAFTING WERKSTATT" -Double | Out-Null
        $invDisplay = if ($pet.Economy.Inventory.Count -gt 0) { $pet.Economy.Inventory -join ', ' } else { 'keine' }
        Write-Host "`n  Materialien: $invDisplay" -ForegroundColor Yellow
        Write-Host ""
        for ($i = 0; $i -lt $script:CraftedItems.Count; $i++) {
            $it = $script:CraftedItems[$i]
            $matText = ($it.Materials.GetEnumerator() | ForEach-Object { "$($_.Value)x $($_.Key)" }) -join ', '
            Write-Host "  [$($i+1)] $($it.Name) [$($it.Type)] | $matText | $($it.Desc)" -ForegroundColor White
        }
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
        $c = Read-Choice "Waehle" "^([1-$($script:CraftedItems.Count)]|Q)$"
        if ($c -eq 'Q') { return }
        $item = $script:CraftedItems[[int]$c - 1]
        # Check materials
        $canCraft = $true
        $missing = @()
        foreach ($mat in $item.Materials.GetEnumerator()) {
            $have = ($pet.Economy.Inventory | Where-Object { $_ -eq $mat.Key } | Measure-Object).Count
            if ($have -lt $mat.Value) {
                $canCraft = $false
                $missing += "$($mat.Value - $have)x $($mat.Key)"
            }
        }
        if (-not $canCraft) {
            Write-Host "`n  Nicht genug Materialien! Fehlt: $($missing -join ', ')" -ForegroundColor Red
            Wait-Enter
            continue
        }
        # Consume materials using ArrayList
        $invList = [System.Collections.ArrayList]::new(@($pet.Economy.Inventory))
        foreach ($mat in $item.Materials.GetEnumerator()) {
            for ($j = 0; $j -lt $mat.Value; $j++) {
                $invList.Remove($mat.Key) | Out-Null
            }
        }
        $pet.Economy.Inventory = @($invList)
        $slot = $item.Type.ToLower()
        $p.Equipment.$slot = $item.Name
        $durKey = "Dur_$slot"
        $p.$durKey = 10
        Save-PetState $pet
        if ($cp) { Show-CompanionDialog $cp (Get-CompanionLine $cp "craft") -Fast }
        Write-Host "`n  $($item.Name) hergestellt und ausgeruestet!" -ForegroundColor Green
        Invoke-Layer47Check
        Wait-Enter
    }
}

} catch {
    Write-Host "[pet/economy] CRITICAL ERROR: $_" -ForegroundColor Red
}
