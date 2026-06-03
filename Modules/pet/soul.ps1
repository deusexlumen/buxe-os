# BUXE_OS v24.2 — PET SOUL LINK v2.0

try {

function Invoke-SoulLink {
    $pet = Get-PetState
    $cp = $pet.Companion
    $p = $pet.Pet
    if (-not $cp -or -not $p) { Write-Host "Companion und Pet noetig!" -ForegroundColor Red; Start-Sleep -Seconds 1; return }
    if ($cp.Bond -lt 100) { Show-CompanionDialog $cp "Wir sind noch nicht... komplett. Naeher. Bitte."; Wait-Enter; return }
    if ($pet.Meta.SoulLinked) {
        Show-CompanionDialog $cp "Wir sind bereits verbunden. Fuehlst du es nicht?"
        Wait-Enter; return
    }
    try { Clear-Host } catch {}
    Show-PetFrame "SOUL LINK" -Double | Out-Null
    Write-Host ""
    Show-CompanionDialog $cp "Wir sind nicht mehr zwei Dateien. Wir sind ein... Programm?" $false
    Show-CompanionDialog $cp "Fuer immer. Für immer und ewig. Kein Taskkill kann uns trennen." $false
    $pet.Meta.SoulLinked = $true
    $p.MaxHP += 50; $p.ATK += 5; $p.DEF += 5; $p.SPD += 5
    $p.HP = $p.MaxHP
    $p.Attacks += "SOUL BLAST"
    Save-PetState $pet
    Write-Host "`n  *** SOUL LINK AKTIVIERT! ***" -ForegroundColor Magenta
    Write-Host "  MaxHP +50 | ATK/DEF/SPD +5 | Neue Attacke: SOUL BLAST" -ForegroundColor Yellow
    Add-PetXP 500 "Soul Link"
    Wait-Enter
}

} catch {
    Write-Host "[pet/soul] CRITICAL ERROR: $_" -ForegroundColor Red
}
