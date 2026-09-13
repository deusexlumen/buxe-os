# BUXE_OS v25.0 -- A/V/S BASELINE MESSUNG
# Misst den Rundenschaden der HEUTIGEN Formeln in Pet-Kampf, PvP, Raid und Rival.
# Rein rechnend: laedt kein Profil, liest keinen Spielstand, schreibt nichts.
#
# Zweck: Referenzwerte fuer die Kalibrierung, wenn alle Modi auf Resolve-AvsRound
# umgestellt werden. Toleranz laut Design: +-15 % auf den Rundenschaden.
#
# Usage: pwsh -NoProfile -File .\Scripts\measure-avs-baseline.ps1 [-Json]

param([switch]$Json)

# === REFERENZ-PET ===
# GLITCH_WOLF ohne Ausruestung, ohne Companion, ohne Skilltree.
# Wachstum pro Level laut Invoke-PetLevelUpCheck: +10 MaxHP, +2 ATK, +1 DEF, +1 SPD.
function Get-ReferencePet($Level) {
    return @{
        Level = $Level
        MaxHP = 100 + 10 * ($Level - 1)
        ATK   = 14 + 2 * ($Level - 1)
        DEF   = 7 + 1 * ($Level - 1)
    }
}

# === GEGNER DER MODI (1:1 aus den Modulen uebernommen) ===
function Get-PvpEnemy($RankIdx, $Level) {
    $s = 1 + ($Level - 1) * 0.25
    return @{
        Label = "PvP $(@('Bronze','Silver','Gold','Platinum','Diamond','Master')[$RankIdx])"
        Level = $RankIdx + 1
        MaxHP = [math]::Round((80 + $RankIdx * 20) * $s)
        ATK   = [math]::Round((12 + $RankIdx * 4) * $s)
        DEF   = [math]::Round((7 + $RankIdx * 2) * $s)
    }
}

function Get-RaidEnemy($Phase, $Level) {
    $bosses = @(
        @{ Name = "CYBER_GOLEM"; HP = 300; ATK = 25; DEF = 20 }
        @{ Name = "NET_TITAN";   HP = 450; ATK = 35; DEF = 25 }
        @{ Name = "OMEGA_CORE";  HP = 600; ATK = 45; DEF = 30 }
    )
    $b = $bosses[$Phase - 1]
    $sc = 1 + ($Level - 1) * 0.15
    return @{
        Label = "Raid Phase $Phase ($($b.Name))"
        Level = $Phase * 3
        MaxHP = [math]::Round($b.HP * $sc)
        ATK   = [math]::Round($b.ATK * $sc)
        DEF   = [math]::Round($b.DEF * $sc)
    }
}

function Get-RivalEnemy($Level) {
    # rLvl schwankt um +-2; fuer die Baseline der Erwartungswert = Spielerlevel.
    $r = $Level
    $s = 1 + ($r - 1) * 0.2
    return @{
        Label = "Rival Lv.$r"
        Level = $r
        MaxHP = [math]::Round((80 + $r * 15) * $s)
        ATK   = [math]::Round((12 + $r * 3) * $s)
        DEF   = [math]::Round((7 + $r * 2) * $s)
    }
}

# === HEUTIGE FORMELN ===
# pvp.ps1:55-63, raid.ps1:117-125, rival.ps1:60-68
function Get-DamageFlat($ATK, $DEF, $Mult) {
    return [math]::Max(1, [math]::Round(($ATK * $Mult) * (100 / (100 + $DEF))))
}
# combat.ps1:217-229 (Tutorial und Pet-Kampf)
function Get-DamageSoftcap20($ATK, $DEF, $Mult) {
    return [math]::Max(1, [math]::Round(($ATK * $Mult) * (1 - ($DEF / ($DEF + 20)))))
}

# === MESSUNG ===
# Eine A/V/S-Runde hat drei gleich wahrscheinliche Ausgaenge:
#   Win  -> Spieler 2.0x, Gegner 0
#   Tie  -> Spieler 1.5x, Gegner 1.0x
#   Loss -> Spieler 0,    Gegner 1.0x
function Measure-Matchup($Pet, $Enemy, $Formula) {
    $f = if ($Formula -eq "Flat") { "Get-DamageFlat" } else { "Get-DamageSoftcap20" }
    $win  = & $f $Pet.ATK $Enemy.DEF 2.0
    $tie  = & $f $Pet.ATK $Enemy.DEF 1.5
    $eTie = & $f $Enemy.ATK $Pet.DEF 1.0
    $eLos = & $f $Enemy.ATK $Pet.DEF 1.0
    return [ordered]@{
        Matchup        = $Enemy.Label
        PetLevel       = $Pet.Level
        PetATK         = $Pet.ATK
        PetDEF         = $Pet.DEF
        EnemyATK       = $Enemy.ATK
        EnemyDEF       = $Enemy.DEF
        DmgWin         = $win
        DmgTie         = $tie
        EnemyDmg       = $eTie
        # Erwartungswert pro Runde ueber die drei gleich wahrscheinlichen Ausgaenge
        AvgPlayerDmg   = [math]::Round(($win + $tie + 0) / 3.0, 2)
        AvgEnemyDmg    = [math]::Round((0 + $eTie + $eLos) / 3.0, 2)
        # Wie viele Runden bis der Gegner faellt, bei durchschnittlichem Schaden
        RoundsToKill   = [math]::Round($Enemy.MaxHP / [math]::Max(1, ($win + $tie) / 3.0), 1)
    }
}

$rows = @()
foreach ($lvl in @(1, 5, 10)) {
    $pet = Get-ReferencePet $lvl
    $rows += Measure-Matchup $pet (Get-PvpEnemy 0 $lvl) "Flat"
    $rows += Measure-Matchup $pet (Get-PvpEnemy 5 $lvl) "Flat"
    $rows += Measure-Matchup $pet (Get-RaidEnemy 1 $lvl) "Flat"
    $rows += Measure-Matchup $pet (Get-RaidEnemy 3 $lvl) "Flat"
    $rows += Measure-Matchup $pet (Get-RivalEnemy $lvl) "Flat"
}

if ($Json) {
    $rows | ConvertTo-Json -Depth 5
    return
}

Write-Host ""
Write-Host "  A/V/S BASELINE -- Rundenschaden der heutigen Formeln" -ForegroundColor Cyan
Write-Host "  Referenz-Pet: GLITCH_WOLF, ohne Ausruestung/Companion/Skilltree" -ForegroundColor DarkGray
Write-Host ""
$rows | ForEach-Object { [PSCustomObject]$_ } | Format-Table `
    @{L='Lv';E={$_.PetLevel};W=3},
    @{L='Matchup';E={$_.Matchup};W=26},
    @{L='ATK/DEF';E={"$($_.PetATK)/$($_.PetDEF)"};W=8},
    @{L='Gegner A/D';E={"$($_.EnemyATK)/$($_.EnemyDEF)"};W=11},
    @{L='Win';E={$_.DmgWin};W=5},
    @{L='Tie';E={$_.DmgTie};W=5},
    @{L='Gegner';E={$_.EnemyDmg};W=7},
    @{L='OePlayer';E={$_.AvgPlayerDmg};W=9},
    @{L='OeGegner';E={$_.AvgEnemyDmg};W=9},
    @{L='Runden';E={$_.RoundsToKill};W=7} -AutoSize
Write-Host ""
