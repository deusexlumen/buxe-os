# BUXE_OS v24.2 — PET RIVAL v2.0

try {

$script:PetRivalNames = @("GLITCH","VORTEX","SHADE","REAPER","PHANTOM")

function Check-PetRival {
    $pet = Get-PetState
    $cp = $pet.Companion
    if (-not $cp -or $cp.Mood -in @("Sad","Angry")) { return $false }
    if (-not $pet.Meta.RivalActive) { $pet.Meta.RivalActive = $false }
    if ($pet.Meta.RivalActive) { return $true }
    if ((Get-Random -Maximum 5) -eq 0) {
        $pet.Meta.RivalName = ($script:PetRivalNames | Get-Random) + "_" + (Get-Random -Maximum 999)
        $pet.Meta.RivalActive = $true
        Save-PetState $pet
        return $true
    }
    return $false
}

function Invoke-PetRivalBattle {
    $pet = Get-PetState
    $cp = $pet.Companion
    $rn = $pet.Meta.RivalName
    Clear-Host
    Show-PetFrame "RIVAL ENCOUNTER" -Double | Out-Null
    Write-Host "`n  Ein Rivale namens $rn fordert dich heraus!" -ForegroundColor Red
    Write-Host "  3 Runden. A > V > S > A" -ForegroundColor DarkGray
    $moves = @{ "A" = "Angriff"; "V" = "Verteidigung"; "S" = "Special" }
    $beats = @{ "A" = "V"; "V" = "S"; "S" = "A" }
    $ps = 0; $rs = 0
    for ($r = 1; $r -le 3; $r++) {
        Write-Host "`n  Runde $r/3" -ForegroundColor Cyan
        $pm = Read-Choice "Zug [A/V/S]" '^[AVS]$'
        $rm = @("A","V","S") | Get-Random
        Write-Host "  Du: $($moves[$pm]) | Rival: $($moves[$rm])" -ForegroundColor DarkGray
        if ($pm -eq $rm) { Write-Host "  Unentschieden!" -ForegroundColor Yellow }
        elseif ($beats[$pm] -eq $rm) { Write-Host "  Punkt für dich!" -ForegroundColor Green; $ps++ }
        else { Write-Host "  Punkt für $rn!" -ForegroundColor Red; $rs++ }
    }
    if ($ps -gt $rs) {
        Write-Host "`n  SIEG!" -ForegroundColor Green
        $pet.Meta.RivalActive = $false; $cp.Bond = [math]::Min(100, $cp.Bond + 5); $cp.Mood = "Excited"
        Add-PetXP 20 "Rival Win"
    } elseif ($ps -lt $rs) {
        Write-Host "`n  NIEDERLAGE..." -ForegroundColor Red
        $pet.Meta.RivalActive = $false; $cp.Mood = "Sad"
        Add-PetXP 5 "Rival Loss"
    } else {
        Write-Host "`n  UNENTSCHIEDEN!" -ForegroundColor Yellow
        $pet.Meta.RivalActive = $false
        Add-PetXP 10 "Rival Draw"
    }
    Save-PetState $pet
    Wait-Enter
}

} catch {
    Write-Host "[pet/rival] CRITICAL ERROR: $_" -ForegroundColor Red
}
