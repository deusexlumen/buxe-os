# BUXE_OS v24.2 — PET UNLOCK SYSTEM v2.0
# Progressive Feature Installation mit LucasArts-Vibe

try {

function Invoke-PetLevelUp($oldLevel, $newLevel) {
    $pet = Get-PetState
    $cp = $pet.Companion
    $newFeatures = @()
    for ($lvl = $oldLevel + 1; $lvl -le $newLevel; $lvl++) {
        if ($script:PetFeatureUnlocks.ContainsKey($lvl)) {
            foreach ($feat in $script:PetFeatureUnlocks[$lvl]) {
                if (-not ($pet.Meta.Unlocked -contains $feat)) {
                    $newFeatures += $feat
                }
            }
        }
    }
    if ($newFeatures.Count -eq 0) { return }
    try { Clear-Host } catch {}
    Show-PetFrame "SYSTEM NOTIFICATION" -Double | Out-Null
    Write-Host ""
    Write-Host "  LEVEL UP! $oldLevel -> $newLevel" -ForegroundColor Yellow
    Write-Host ""
    if ($cp) {
        $line = Get-CompanionLine $cp "level_up"
        Show-CompanionDialog $cp $line -Fast
    }
    Write-Host ""
    Write-Host "  NEUE MODULE DETEKTIERT:" -ForegroundColor Cyan
    foreach ($feat in $newFeatures) {
        $featName = switch ($feat) {
            "gift" { "Geschenke-System" }
            "mood" { "Stimmungs-Engine" }
            "pet_create" { "Battlepet-Initialisierung" }
            "combat" { "Kampf-Modul COMBAT.EXE" }
            "train" { "Trainings-Protocol" }
            "work" { "Job-Market-Connector" }
            "gold" { "Währungs-Manager" }
            "shop" { "Schwarzmarkt-Zugriff" }
            "cooking" { "Küchen-Subroutine" }
            "equipment" { "Ausrüstungs-Datenbank" }
            "pvp" { "PvP-Arena-Netzwerk" }
            "raid" { "Raid-Dungeon-Loader" }
            "breed" { "Genetik-Labor" }
            "rival" { "Rival-Tracking-System" }
            "soul_link" { "Soul-Link-Kernel" }
            "architect" { "ARCHITECT.SYS (CLASSIFIED)" }
            default { $feat }
        }
        Write-Host "    [NEW] $featName" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "  [J] Alle installieren | [N] Später" -ForegroundColor White
    $choice = Read-Choice "Waehle" '^[JN]$'
    if ($choice -eq 'J') {
        foreach ($feat in $newFeatures) {
            Unlock-PetFeature $feat
        }
        Save-PetState $pet
        Write-Host ""
        Write-Host "  Installation abgeschlossen. Willkommen in der nächsten Phase." -ForegroundColor Green
        if ($cp) {
            $react = @("Endlich!","Ich hatte schon Angst, wir müssten für immer nur reden.","Neue Buttons! Yay!") | Get-Random
            Show-CompanionDialog $cp $react -Fast
        }
    } else {
        Write-Host ""
        Write-Host "  Installation verschoben. Module warten... geduldig..." -ForegroundColor DarkGray
        if ($cp) {
            Show-CompanionDialog $cp "Du lässt mich hier hängen? Mit all den unentdeckten Features? Grausam." -Fast
        }
    }
    Wait-Enter
}

} catch {
    Write-Host "[pet/_unlock] CRITICAL ERROR: $_" -ForegroundColor Red
}
