# BUXE_OS v24.2 — PET ECONOMY v2.0
# Work, Shop, Cooking

try {

$script:PetShopItems = @(
    @{ Type = "Chip"; Name = "Neural Chip"; Cost = 100; Desc = "+3 ATK"; ATK = 3 }
    @{ Type = "Armor"; Name = "Plasma Armor"; Cost = 100; Desc = "+3 DEF, +10 HP"; DEF = 3; HP = 10 }
    @{ Type = "Accessory"; Name = "Speed Collar"; Cost = 100; Desc = "+3 SPD"; SPD = 3 }
    @{ Type = "Chip"; Name = "Quantum Chip"; Cost = 250; Desc = "+6 ATK"; ATK = 6 }
    @{ Type = "Armor"; Name = "Aegis Plate"; Cost = 250; Desc = "+6 DEF, +20 HP"; DEF = 6; HP = 20 }
)
$script:PetRecipes = @(
    @{ Name = "Ramen"; Desc = "+10% MaxHP"; Buff = @{ Stat = "MaxHP"; Value = 0.10 } }
    @{ Name = "Energy Drink"; Desc = "+20% SPD"; Buff = @{ Stat = "SPD"; Value = 0.20 } }
    @{ Name = "Sushi Platter"; Desc = "+15% ATK"; Buff = @{ Stat = "ATK"; Value = 0.15 } }
    @{ Name = "Golden Curry"; Desc = "+10% All Stats"; Buff = @{ Stat = "ALL"; Value = 0.10 } }
)

function Start-PetShop {
    $pet = Get-PetState
    $p = $pet.Pet
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    while ($true) {
    try { Clear-Host } catch {}
        Show-PetFrame "SCHWARZMARKT" -Double | Out-Null
        Write-Host "`n  Gold: $($pet.Economy.Gold) G" -ForegroundColor Yellow
        Write-Host "  Aktiv: $($p.Name) [Lv.$($p.Level)]" -ForegroundColor $p.Color
        Write-Host ""
        for ($i = 0; $i -lt $script:PetShopItems.Count; $i++) {
            $it = $script:PetShopItems[$i]
            Write-Host "  [$($i+1)] $($it.Name) [$($it.Type)] — $($it.Cost) G | $($it.Desc)" -ForegroundColor White
        }
        Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
        $c = Read-Choice "Waehle" "^([1-$($script:PetShopItems.Count)]|Q)$"
        if ($c -eq 'Q') { return }
        $item = $script:PetShopItems[[int]$c - 1]
        if ($pet.Economy.Gold -lt $item.Cost) { Write-Host "`n  Nicht genug Gold!" -ForegroundColor Red; Wait-Enter; continue }
        $slot = $item.Type.ToLower()
        $p.Equipment.$slot = $item.Name
        $pet.Economy.Gold -= $item.Cost
        Save-PetState $pet
        Write-Host "`n  $($item.Name) ausgeruestet!" -ForegroundColor Green
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
    for ($i = 0; $i -lt $script:PetRecipes.Count; $i++) {
        $r = $script:PetRecipes[$i]
        Write-Host "  [$($i+1)] $($r.Name) — $($r.Desc)" -ForegroundColor White
    }
    Write-Host "  [Q] Zurueck" -ForegroundColor DarkGray
    $c = Read-Choice "Waehle" "^([1-$($script:PetRecipes.Count)]|Q)$"
    if ($c -eq 'Q') { return }
    $recipe = $script:PetRecipes[[int]$c - 1]
    $p.FoodBuffs = @($recipe.Buff)
    if ($cp.Bond -ge 50 -and (Get-Random -Maximum 3) -eq 0) {
        $p.FoodBuffs += @{ Name = "Mystery Stew"; Desc = "+5% All"; Buff = @{ Stat = "ALL"; Value = 0.05 } }
        Write-Host "`n  BONUS DISH! Mystery Stew gezaubert!" -ForegroundColor Magenta
    }
    Save-PetState $pet
    Show-CompanionDialog $cp "Mmm, das riecht gut! Ich habe mein Bestes gegeben!" -Fast
    Write-Host "  $($recipe.Name) fuer $($p.Name)! Naechster Kampf: $($recipe.Desc)" -ForegroundColor Green
    Wait-Enter
}

} catch {
    Write-Host "[pet/economy] CRITICAL ERROR: $_" -ForegroundColor Red
}
