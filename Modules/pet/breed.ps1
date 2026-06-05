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
    Write-Host "`n  Aktiv: $($p.Name) [Lv.$($p.Level)] [$($p.Type)]" -ForegroundColor $p.Color
    Write-Host "  Stats: HP:$($p.MaxHP) ATK:$($p.ATK) DEF:$($p.DEF) SPD:$($p.SPD)" -ForegroundColor DarkGray
    Write-Host "`n  Waehle einen Genetik-Partner:" -ForegroundColor White
    $types = @("VIRUS","ELEC","DARK","FIRE","ICE","NORM","WATER")
    $partners = @()
    for ($i = 0; $i -lt 3; $i++) {
        $pt = $types | Get-Random
        $partners += @{ Name = "GENE_$(Get-Random -Maximum 999)"; Type = $pt; Bonus = (Get-Random -Minimum 2 -Maximum 6) }
        Write-Host "  [$($i+1)] $($partners[$i].Name) [$($partners[$i].Type)] | Gen-Bonus: +$($partners[$i].Bonus)" -ForegroundColor White
    }
    Write-Host "`n  [B] Eigenes Pet klonen (+3 Bonus) | [Q] Zurueck" -ForegroundColor White
    $c = Read-Choice "Waehle" '^[123BQ]$'
    if ($c -eq 'Q') { return }
    if ($c -eq 'B') {
        if ($pet.Economy.Gold -lt 80) { Write-Host "`n  Nicht genug Gold! (80G)" -ForegroundColor Red; Wait-Enter; return }
        $pet.Economy.Gold -= 80
        $partner = @{ Name = "CLONE"; Type = $p.Type; Bonus = 3 }
    } else {
        if ($pet.Economy.Gold -lt 60) { Write-Host "`n  Nicht genug Gold! (60G)" -ForegroundColor Red; Wait-Enter; return }
        $pet.Economy.Gold -= 60
        $partner = $partners[[int]$c - 1]
    }
    $stats = Get-EffectiveStats $p
    $bonus = $partner.Bonus
    $babyType = if ((Get-Random -Maximum 2) -eq 0) { $p.Type } else { $partner.Type }
    $baby = @{
        Name = "BABY_" + $p.Name; Type = $babyType
        Level = 1; XP = 0; NextXP = 50
        HP = [math]::Round([math]::Max($stats.MaxHP, 60) + $bonus)
        MaxHP = 0; ATK = [math]::Round([math]::Max($p.ATK, 10) + $bonus)
        DEF = [math]::Round([math]::Max($p.DEF, 6) + $bonus); SPD = [math]::Round([math]::Max($p.SPD, 8) + $bonus)
        Color = $p.Color; Attacks = @("Neural Overload","Bit Crusher")
        Wins = 0; Losses = 0; Evolved = $false; Personality = @("Aggressive","Balanced","Speedster") | Get-Random
        Equipment = @{ Chip = $null; Armor = $null; Accessory = $null }; FoodBuffs = @()
        ParentType = $p.Type; ParentName = $p.Name
    }
    $baby.MaxHP = $baby.HP
    $pet.Pet = $baby
    Save-PetState $pet
    Write-Host "`n  EGG HATCHED! $($baby.Name) | Type: $($baby.Type)" -ForegroundColor Green
    Write-Host "  Genetik: $($p.Type) + $($partner.Type) | Bonus: +$bonus" -ForegroundColor Magenta
    if ($cp) {
        if ($cp.Bond -ge 70) { Show-CompanionDialog $cp "Es ist... niedlich? Ja. Niedlich. Und es hat deine Augen. Virtuell." -Fast }
        elseif ($cp.Name -eq "NEON") { Show-CompanionDialog $cp "Ein Baby. Klasse. Noch mehr Prozesse, die meinen RAM fressen." -Fast }
        elseif ($cp.Name -eq "JINX") { Show-CompanionDialog $cp "Baby! Ein BABY! 47 Mal niedlicher als erwartet!" -Fast }
        else { Show-CompanionDialog $cp "Du willst mich durch BABIES ersetzen?! *grummel*" -Fast; $cp.Mood = "Angry" }
    }
    Add-PetXP 50 "Breed"
    Invoke-Layer47Check
    Wait-Enter
}

} catch {
    Write-Host "[pet/breed] CRITICAL ERROR: $_" -ForegroundColor Red
}
