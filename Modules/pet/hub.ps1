# BUXE_OS v24.2 — PET HUB v2.0
# Dynamic Menu, Companion as Entry Point

try {

function pet {
    param([string]$Action)
    $pet = Get-PetState
    if (-not $pet.Companion -and -not ($Action -eq "create" -or $Action -eq "")) {
        Write-Host "Kein Companion. Tippe 'pet' um zu starten." -ForegroundColor Red
        return
    }
    if ($Action) {
        switch ($Action.ToLower()) {
            "talk"    { if (Is-FeatureUnlocked "talk") { Invoke-CompanionAction "talk" } }
            "gift"    { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "gift" } }
            "date"    { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "date" } }
            "work"    { if (Is-FeatureUnlocked "work") { Invoke-CompanionAction "work" } }
            "train"   { if (Is-FeatureUnlocked "train") { Invoke-CompanionAction "train" } }
            "punish"  { if (Is-FeatureUnlocked "gift") { Invoke-CompanionAction "punish" } }
            "headpat" { if (Is-FeatureUnlocked "talk") { Invoke-CompanionAction "headpat" } }
            "fight"   { if (Is-FeatureUnlocked "combat") { Start-PetFight } }
            "pvp"     { if (Is-FeatureUnlocked "pvp") { Start-PetPvP } }
            "raid"    { if (Is-FeatureUnlocked "raid") { Start-PetRaid } }
            "shop"    { if (Is-FeatureUnlocked "shop") { Start-PetShop } }
            "cook"    { if (Is-FeatureUnlocked "cooking") { Start-PetCook } }
            "breed"   { if (Is-FeatureUnlocked "breed") { Start-PetBreed } }
            "rival"   { if (Is-FeatureUnlocked "rival" -and $pet.Meta.RivalActive) { Invoke-PetRivalBattle } }
            "soul"    { if (Is-FeatureUnlocked "soul_link") { Invoke-SoulLink } }
            "status"  { Show-PetHubStatus }
            default   { Write-Host "Unbekannte Aktion: $Action" -ForegroundColor Red }
        }
        return
    }
    # Interactive hub
    while ($true) {
        $pet = Get-PetState
        $cp = $pet.Companion
        Clear-Host
        Show-PetFrame "BUXE_PET OS v2.0 — HUB" -Double | Out-Null
        Write-Host ""
        if ($cp) {
            Write-Host "  [$($cp.Name)] Bond: $($cp.Bond) | Mood: $($cp.Mood) | Level: $($pet.Meta.Level)" -ForegroundColor Magenta
            Show-WhileAway
        } else {
            Write-Host "  [NO COMPANION DETECTED]" -ForegroundColor DarkGray
        }
        if ($pet.Pet) { Write-Host "  [$($pet.Pet.Name)] Lv.$($pet.Pet.Level) | HP:$($pet.Pet.HP)/$((Get-EffectiveStats $pet.Pet).MaxHP) | Wins:$($pet.Pet.Wins)" -ForegroundColor Green }
        Write-Host "  Gold: $($pet.Economy.Gold) G | XP: $($pet.Meta.XP)" -ForegroundColor Yellow
        Write-Host ""
        # Dynamic menu based on unlocked features
        $opts = @(); $keys = @()
        if (Is-FeatureUnlocked "talk") { $opts += "[1] Talk"; $keys += "1" }
        if (Is-FeatureUnlocked "gift") { $opts += "[2] Gift"; $keys += "2" }
        if (Is-FeatureUnlocked "combat") { $opts += "[3] Fight"; $keys += "3" }
        if (Is-FeatureUnlocked "work") { $opts += "[4] Work"; $keys += "4" }
        if (Is-FeatureUnlocked "train") { $opts += "[5] Train"; $keys += "5" }
        if (Is-FeatureUnlocked "shop") { $opts += "[6] Shop"; $keys += "6" }
        if (Is-FeatureUnlocked "cooking") { $opts += "[7] Cook"; $keys += "7" }
        if (Is-FeatureUnlocked "pvp") { $opts += "[8] PvP"; $keys += "8" }
        if (Is-FeatureUnlocked "raid") { $opts += "[9] Raid"; $keys += "9" }
        if (Is-FeatureUnlocked "breed") { $opts += "[B] Breed"; $keys += "B" }
        if (Is-FeatureUnlocked "rival" -and $pet.Meta.RivalActive) { $opts += "[R] Rival"; $keys += "R" }
        if (Is-FeatureUnlocked "soul_link") { $opts += "[L] Soul Link"; $keys += "L" }
        $opts += "[S] Status"; $keys += "S"
        $opts += "[Q] Exit"; $keys += "Q"
        # Display in rows of 3
        for ($i = 0; $i -lt $opts.Count; $i += 3) {
            $line = "  " + $opts[$i]
            if ($i + 1 -lt $opts.Count) { $line += "    " + $opts[$i + 1] }
            if ($i + 2 -lt $opts.Count) { $line += "    " + $opts[$i + 2] }
            Write-Host $line -ForegroundColor White
        }
        Write-Host ""
        $pattern = "^([" + ($keys -join "") + "])$"
        $c = $null
        while (-not $c) {
            $raw = Read-Host "  Waehle"
            if ($raw -eq 'Q' -or $raw -eq 'q') { $c = 'Q'; break }
            if ($raw -match $pattern) { $c = $raw; break }
            if ([string]::IsNullOrWhiteSpace($raw)) {
                Write-Host "  Bitte waehlen: $($keys -join ', ') oder Q" -ForegroundColor DarkGray
                Start-Sleep -Milliseconds 300
            } else {
                Write-Host "  Ungueltig. Gueltig: $($keys -join ', ') oder Q" -ForegroundColor Red
                Start-Sleep -Milliseconds 300
            }
        }
        if (-not $cp -and $c -eq '1') { New-Companion; continue }
        switch ($c) {
            '1' { Invoke-CompanionAction "talk" }
            '2' { Invoke-CompanionAction "gift" }
            '3' { Start-PetFight }
            '4' { Invoke-CompanionAction "work" }
            '5' { Invoke-CompanionAction "train" }
            '6' { Start-PetShop }
            '7' { Start-PetCook }
            '8' { Start-PetPvP }
            '9' { Start-PetRaid }
            'B' { Start-PetBreed }
            'R' { Invoke-PetRivalBattle }
            'L' { Invoke-SoulLink }
            'S' { Show-PetHubStatus }
            'Q' { return }
        }
        Check-PetRival | Out-Null
    }
}

function Show-PetHubStatus {
    $pet = Get-PetState
    Clear-Host
    Show-PetFrame "STATUS OVERVIEW" -Double | Out-Null
    Write-Host ""
    if ($pet.Companion) {
        $bar = Show-Bar $pet.Companion.Bond 100 20
        Write-Host "  COMPANION: $($pet.Companion.Name) [$($pet.Companion.Role)]" -ForegroundColor Magenta
        Write-Host "  Bond: [$bar] $($pet.Companion.Bond)/100 | Mood: $($pet.Companion.Mood)" -ForegroundColor White
    }
    if ($pet.Pet) {
        $s = Get-EffectiveStats $pet.Pet
        $hp = Show-Bar $pet.Pet.HP $s.MaxHP 20
        Write-Host "`n  PET: $($pet.Pet.Name) [$($pet.Pet.Type)] Lv.$($pet.Pet.Level)" -ForegroundColor Green
        Write-Host "  HP: [$hp] $($pet.Pet.HP)/$($s.MaxHP) | ATK:$($s.ATK) DEF:$($s.DEF) SPD:$($s.SPD)" -ForegroundColor White
        Write-Host "  Wins: $($pet.Pet.Wins) | Losses: $($pet.Pet.Losses) | Rank: $($pet.Pet.Rank)" -ForegroundColor DarkGray
    }
    Write-Host "`n  Gold: $($pet.Economy.Gold) G | Level: $($pet.Meta.Level) | XP: $($pet.Meta.XP)" -ForegroundColor Yellow
    Write-Host "  Unlocked: $($pet.Meta.Unlocked -join ', ')" -ForegroundColor DarkGray
    Write-Host ""
    Wait-Enter
}

} catch {
    Write-Host "[pet/hub] CRITICAL ERROR: $_" -ForegroundColor Red
}
