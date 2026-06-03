# BUXE_OS v24.2 — PET BREEDING v2.0

try {

function Start-PetBreed {
    $pet = Get-PetState
    $p = $pet.Pet
    $cp = $pet.Companion
    if (-not $p) { Write-Host "Kein Pet!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if (-not $cp -or $cp.Bond -lt 50) { Write-Host "Bond 50+ noetig!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    try { Clear-Host } catch {}
    Show-PetFrame "GENETIK-LABOR" -Double | Out-Null
    Write-Host "`n  Aktiv: $($p.Name) [Lv.$($p.Level)]" -ForegroundColor $p.Color
    Write-Host "`n  [B] Partner kaufen (100G) | [Q] Zurueck" -ForegroundColor White
    $c = Read-Choice "Waehle" '^[BQ]$'
    if ($c -eq 'Q') { return }
    if ($pet.Economy.Gold -lt 100) { Write-Host "`n  Nicht genug Gold!" -ForegroundColor Red; Wait-Enter; return }
    $pet.Economy.Gold -= 100
    $types = @("VIRUS","ELEC","DARK","FIRE","ICE","NORM","WATER")
    $t = $types | Get-Random
    $stats = Get-EffectiveStats $p
    $bonus = Get-Random -Minimum 1 -Maximum 4
    $baby = @{
        Name = "BABY_" + $p.Name; Type = if ((Get-Random -Maximum 2) -eq 0) { $p.Type } else { $t }
        Level = 1; XP = 0; NextXP = 50
        HP = [math]::Round([math]::Max($stats.MaxHP, 60) + $bonus)
        MaxHP = 0; ATK = [math]::Round([math]::Max($p.ATK, 10) + $bonus)
        DEF = [math]::Round([math]::Max($p.DEF, 6) + $bonus); SPD = [math]::Round([math]::Max($p.SPD, 8) + $bonus)
        Color = $p.Color; Attacks = @("Neural Overload","Bit Crusher")
        Wins = 0; Losses = 0; Evolved = $false; Personality = @("Aggressive","Balanced","Speedster") | Get-Random
        Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }; FoodBuffs = @()
    }
    $baby.MaxHP = $baby.HP
    $pet.Pet = $baby
    Save-PetState $pet
    Write-Host "`n  EGG HATCHED! $($baby.Name) | Type: $($baby.Type)" -ForegroundColor Green
    Write-Host "  Genetik: Beste Stats +$bonus Bonus!" -ForegroundColor Magenta
    if ($cp) {
        if ($cp.Bond -ge 70) { Show-CompanionDialog $cp "Es ist... niedlich? Ja. Niedlich. *lächelt*" -Fast }
        else { Show-CompanionDialog $cp "Du willst mich durch BABIES ersetzen?! *grummel*" -Fast; $cp.Mood = "Angry" }
    }
    Add-PetXP 50 "Breed"
    Wait-Enter
}

} catch {
    Write-Host "[pet/breed] CRITICAL ERROR: $_" -ForegroundColor Red
}
