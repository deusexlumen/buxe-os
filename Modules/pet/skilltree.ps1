# BUXE_OS v24.12 -- PET SKILL TREE ENGINE
# Meta-Progression: Skill Points, Branches, Bonuses

try {

function Add-PetSkillPoint {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Combat','Economy','Social')]
        [string]$Branch
    )
    $state = Get-PetState
    if ($state.SkillPoints -le 0) { return $false }
    $tree = $state.SkillTree[$Branch]
    if (-not $tree) { return $false }
    if ($tree.Level -ge $tree.MaxLevel) { return $false }

    $tree.Level++
    $state.SkillPoints--
    Save-PetState $state

    # Flag fuer adaptives Tutorial
    if (-not $state.Tutorial.Flags.firstSkillPoint) {
        $state.Tutorial.Flags.firstSkillPoint = $true
        Save-PetState $state
    }

    return $true
}

function Get-PetSkillBonus {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Combat','Economy','Social')]
        [string]$Branch,

        [Parameter(Mandatory=$true)]
        [ValidateRange(1,5)]
        [int]$Tier
    )
    $state = Get-PetState
    $level = $state.SkillTree[$Branch].Level
    if ($Tier -gt $level) { return 0.0 }

    switch ($Branch) {
        'Combat' {
            if ($Tier -in 1,2) { return 0.05 }
            if ($Tier -in 3,4) { return 0.10 }
            if ($Tier -eq 5) { return 0.20 }
        }
        'Economy' {
            if ($Tier -eq 1) { return 0.05 }
            if ($Tier -eq 2) { return 0.10 }
            if ($Tier -eq 3) { return 0.05 }
            if ($Tier -in 4,5) { return 0.10 }
        }
        'Social' {
            if ($Tier -in 1,2) { return 0.05 }
            if ($Tier -in 3,4) { return 0.10 }
            if ($Tier -eq 5) { return 0.15 }
        }
    }
    return 0.0
}

function Get-TotalPetSkillBonus {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Combat','Economy','Social')]
        [string]$Branch
    )
    $total = 0.0
    for ($t = 1; $t -le 5; $t++) {
        $total += Get-PetSkillBonus -Branch $Branch -Tier $t
    }
    return $total
}

function Show-SkillTree {
    $state = Get-PetState
    if ($state.Companion) { Show-CompanionDialog $state.Companion (Get-CompanionLine $state.Companion "skilltree_open") -NoWait -Fast }
    Show-PetFrame 'SKILL TREE'
    Write-Host "Verfuegbare Punkte: $($state.SkillPoints)" -ForegroundColor Yellow
    Write-Host "Investiere in Combat, Economy oder Social." -ForegroundColor Gray

    foreach ($branch in @('Combat','Economy','Social')) {
        $t = $state.SkillTree[$branch]
        Write-Host "`n[$branch] Level $($t.Level)/$($t.MaxLevel)" -ForegroundColor Cyan
        for ($i = 0; $i -lt $t.Perks.Count; $i++) {
            $marker = if ($i -lt $t.Level) { '[x]' } else { '[ ]' }
            $color = if ($i -lt $t.Level) { 'Green' } else { 'DarkGray' }
            Write-Host "  $marker Tier $($i+1): $($t.Perks[$i])" -ForegroundColor $color
        }
    }
    Write-Host "`n[c] Combat  [e] Economy  [s] Social  [q] Zurueck" -ForegroundColor DarkGray
}

function Invoke-SkillTreeMenu {
    while ($true) {
        Show-SkillTree
        $choice = Read-Host "Waehle"
        switch ($choice.ToLower()) {
            'c' {
                if (Add-PetSkillPoint -Branch 'Combat') {
                    $state = Get-PetState
                    if ($state.Companion) { Show-CompanionDialog $state.Companion (Get-CompanionLine $state.Companion "skilltree_upgrade") -Fast }
                    Write-Host "Combat verbessert!" -ForegroundColor Green
                } else {
                    Write-Host "Kein Punkt verfuegbar oder Maximum erreicht." -ForegroundColor Red
                }
                Wait-Enter
            }
            'e' {
                if (Add-PetSkillPoint -Branch 'Economy') {
                    $state = Get-PetState
                    if ($state.Companion) { Show-CompanionDialog $state.Companion (Get-CompanionLine $state.Companion "skilltree_upgrade") -Fast }
                    Write-Host "Economy verbessert!" -ForegroundColor Green
                } else {
                    Write-Host "Kein Punkt verfuegbar oder Maximum erreicht." -ForegroundColor Red
                }
                Wait-Enter
            }
            's' {
                if (Add-PetSkillPoint -Branch 'Social') {
                    $state = Get-PetState
                    if ($state.Companion) { Show-CompanionDialog $state.Companion (Get-CompanionLine $state.Companion "skilltree_upgrade") -Fast }
                    Write-Host "Social verbessert!" -ForegroundColor Green
                } else {
                    Write-Host "Kein Punkt verfuegbar oder Maximum erreicht." -ForegroundColor Red
                }
                Wait-Enter
            }
            'q' { return }
            default { Write-Host "Ungueltige Eingabe." -ForegroundColor Red; Wait-Enter }
        }
    }
}

} catch {
    Write-Warning "Fehler in pet/skilltree.ps1: $_"
}
