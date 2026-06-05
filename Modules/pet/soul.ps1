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
    # Phase 1: Synchronization
    try { Clear-Host } catch {}
    Show-PetFrame "SOUL LINK — PHASE 1: SYNCHRONISATION" -Double | Out-Null
    Write-Host ""
    Show-CompanionDialog $cp "Bond 100. Sync maximal. Wir sind bereit... oder?" -Fast
    Write-Host "`n  Dein Companion und dein Pet synchronisieren ihre Datenstroeme..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 800
    Show-CompanionDialog $cp "Ich spuere... alles. Deine Tastenanschlaege. Deine Atemzuege. Virtuell." -Fast
    # Phase 2: Fusion
    try { Clear-Host } catch {}
    Show-PetFrame "SOUL LINK — PHASE 2: FUSION" -Double | Out-Null
    Write-Host ""
    Show-CompanionDialog $cp "Zwei Seelen. Ein Prozess. Kein Speicherleck." -Fast
    Write-Host "`n  Die Verbindung stabilisiert sich..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 800
    $cpLine = switch ($cp.Name) {
        "NEON" { "*schliesst die Augen* Ich sehe deinen Code. Er ist... akzeptabel." }
        "RAVEN" { "Deine Seele ist... interessant. Ich werde sie studieren." }
        "PIXEL" { "*zittert vor Aufregung* Wir sind eins! WIR SIND EINS!" }
        "LUNA" { "*lächelt sanft* Fuehlst du das? Wir sind... zusammen." }
        "IVY" { "... *nickt langsam* Verbunden. Fuer immer." }
        "VERA" { "Fusion complete. Effizienz: 100%. Emotionalitaet: ...auch 100%." }
        "JINX" { "SOUL LINK! Das klingt wie ein Anime! Ich bin der Protagonist!" }
        default { "Wir sind eins. Fuer immer." }
    }
    Show-CompanionDialog $cp $cpLine -Fast
    # Phase 3: Awakening
    try { Clear-Host } catch {}
    Show-PetFrame "SOUL LINK — PHASE 3: ERWACHEN" -Double | Out-Null
    Write-Host ""
    Show-CompanionDialog $cp "Wir sind nicht mehr zwei Dateien. Wir sind ein... Programm?" -Fast
    Show-CompanionDialog $cp "Fuer immer. Fuer immer und ewig. Kein Taskkill kann uns trennen." -Fast
    $pet.Meta.SoulLinked = $true
    $p.MaxHP += 50; $p.ATK += 5; $p.DEF += 5; $p.SPD += 5
    $p.HP = $p.MaxHP
    $p.Attacks += "SOUL BLAST"
    $cp.Sync += 20
    Save-PetState $pet
    Write-Host "`n  *** SOUL LINK AKTIVIERT! ***" -ForegroundColor Magenta
    Write-Host "  MaxHP +50 | ATK/DEF/SPD +5 | Sync +20 | Neue Attacke: SOUL BLAST" -ForegroundColor Yellow
    Add-PetXP 500 "Soul Link"
    Wait-Enter
}

} catch {
    Write-Host "[pet/soul] CRITICAL ERROR: $_" -ForegroundColor Red
}
