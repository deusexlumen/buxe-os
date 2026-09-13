# BUXE_OS v25.0 -- BALANCE TEST
# Prueft, ob die auf Resolve-AvsRound umgestellten Modi im Korridor der Baseline
# bleiben (+-15 % Rundenschaden, siehe docs/superpowers/specs/2026-09-13-avs-baseline.md)
# und ob simulierte Kaempfe plausibel ausgehen.
#
# Laeuft NICHT im Watch-Loop: 10.000 simulierte Runden pro Modus kosten Sekunden.
# Usage: pwsh -NoProfile -File .\Modules\_balance_test.ps1

$modDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$modDir\pet\combat-core.ps1"

$errors = 0; $tests = 0
function Test-Assert($name, $condition) {
    $script:tests++
    if ($condition) { Write-Host "  [PASS] $name" -ForegroundColor Green }
    else { Write-Host "  [FAIL] $name" -ForegroundColor Red; $script:errors++ }
}

$TOLERANCE = 0.15

# === REFERENZ-PET UND GEGNER (identisch zu Scripts\measure-avs-baseline.ps1) ===
function Get-RefPet($Level) {
    @{ Level = $Level; MaxHP = 100 + 10 * ($Level - 1); ATK = 14 + 2 * ($Level - 1); DEF = 7 + 1 * ($Level - 1) }
}
function Get-RefPvpEnemy($RankIdx, $Level) {
    $s = 1 + ($Level - 1) * 0.25
    @{ Label = "PvP Rang $RankIdx"; Level = $RankIdx + 1; MaxHP = [math]::Round((80 + $RankIdx * 20) * $s)
       ATK = [math]::Round((12 + $RankIdx * 4) * $s); DEF = [math]::Round((7 + $RankIdx * 2) * $s) }
}
function Get-RefRaidEnemy($Phase, $Level) {
    $b = @(@{HP=300;ATK=25;DEF=20}, @{HP=450;ATK=35;DEF=25}, @{HP=600;ATK=45;DEF=30})[$Phase - 1]
    $sc = 1 + ($Level - 1) * 0.15
    @{ Label = "Raid Phase $Phase"; Level = $Phase * 3; MaxHP = [math]::Round($b.HP * $sc)
       ATK = [math]::Round($b.ATK * $sc); DEF = [math]::Round($b.DEF * $sc) }
}
function Get-RefRivalEnemy($Level) {
    $s = 1 + ($Level - 1) * 0.2
    @{ Label = "Rival Lv.$Level"; Level = $Level; MaxHP = [math]::Round((80 + $Level * 15) * $s)
       ATK = [math]::Round((12 + $Level * 3) * $s); DEF = [math]::Round((7 + $Level * 2) * $s) }
}

# Alte Formel = Baseline-Referenz (pvp.ps1/raid.ps1/rival.ps1 vor der Umstellung)
function Get-BaselineAvg($Pet, $Foe) {
    $w = [math]::Max(1, [math]::Round(($Pet.ATK * 2.0) * (100 / (100 + $Foe.DEF))))
    $t = [math]::Max(1, [math]::Round(($Pet.ATK * 1.5) * (100 / (100 + $Foe.DEF))))
    ($w + $t) / 3.0
}
# Neue Formel ueber den seam
function Get-CurrentAvg($Pet, $Foe, $MovePower) {
    $w = (Resolve-AvsRound -PlayerMove A -EnemyMove V -PlayerStats $Pet -EnemyStats $Foe `
            -PlayerLevel $Pet.Level -EnemyLevel $Foe.Level -MovePower $MovePower).PlayerDamage
    $t = (Resolve-AvsRound -PlayerMove A -EnemyMove A -PlayerStats $Pet -EnemyStats $Foe `
            -PlayerLevel $Pet.Level -EnemyLevel $Foe.Level -MovePower $MovePower).PlayerDamage
    ($w + $t) / 3.0
}

Write-Host "`n  BUXE_OS BALANCE TEST -- Korridor +-$([int]($TOLERANCE*100)) % gegen Baseline`n" -ForegroundColor Cyan

# === KORRIDOR-PRUEFUNG ===
# Nur Modi, die bereits auf Resolve-AvsRound laufen. Beim Umstellen hier ergaenzen.
$matchups = @(
    @{ Mode = "Rival"; MovePower = $script:AvsMovePower.Rival; Gen = { param($lvl) Get-RefRivalEnemy $lvl } }
    @{ Mode = "PvP Bronze"; MovePower = $script:AvsMovePower.PvPBase
       Gen = { param($lvl) Get-RefPvpEnemy 0 $lvl } }
    @{ Mode = "PvP Master"; MovePower = ($script:AvsMovePower.PvPBase + $script:AvsMovePower.PvPPerRank * 5)
       Gen = { param($lvl) Get-RefPvpEnemy 5 $lvl } }
)

foreach ($m in $matchups) {
    foreach ($lvl in @(1, 5, 10)) {
        $pet = Get-RefPet $lvl
        $foe = & $m.Gen $lvl
        $base = Get-BaselineAvg $pet $foe
        $cur  = Get-CurrentAvg $pet $foe $m.MovePower
        $dev  = ($cur - $base) / $base
        $tol  = if ($m.Tolerance) { $m.Tolerance } else { $TOLERANCE }
        $ok   = [math]::Abs($dev) -le $tol
        $note = if ($tol -ne $TOLERANCE) { " [Ausnahme +-$([int]($tol*100)) %]" } else { "" }
        Test-Assert ("{0} Lv{1}: {2:N2} -> {3:N2} ({4:P1}){5}" -f $m.Mode, $lvl, $base, $cur, $dev, $note) $ok
    }
}

# === RAID: SIEGQUOTE STATT RUNDENSCHADEN ===
# Der Raid wird nicht am alten Rundenschaden gemessen. Grund: mit den v24-Werten
# lag die simulierte Siegquote bei 0 % -- ueber jedes Level und jede Ausruestung.
# Ein Korridor um eine unspielbare Referenz waere wertlos. Geprueft wird stattdessen
# die Progressionskurve: ohne Ausruestung chancenlos, mit voller Ausruestung machbar.
Write-Host ""
. "$modDir\pet\raid.ps1"

function Invoke-SimRaid($Pet, $Heals) {
    $hp = $Pet.MaxHP; $used = 0; $rounds = 0
    $moveSet = @("A","V","S")
    for ($phase = 1; $phase -le 3; $phase++) {
        $b = $script:PetRaidBosses[$phase - 1]
        $enemy = @{ HP = $b.HP; MaxHP = $b.HP; ATK = $b.ATK; DEF = $b.DEF }
        while ($hp -gt 0 -and $enemy.HP -gt 0) {
            $rounds++
            if ($rounds -gt 500) { return $false }
            if ($used -lt $Heals -and $hp -lt ($Pet.MaxHP * 0.5)) {
                $hp += [math]::Min([math]::Round($Pet.MaxHP * 0.2), $Pet.MaxHP - $hp); $used++
            }
            $r = Resolve-AvsRound -PlayerMove ($moveSet | Get-Random) -EnemyMove ($moveSet | Get-Random) `
                    -PlayerStats $Pet -EnemyStats $enemy -PlayerLevel $Pet.Level -EnemyLevel ($phase * 3) `
                    -MovePower $script:AvsMovePower.Raid[$phase - 1]
            $enemy.HP -= $r.PlayerDamage
            $hp -= $r.EnemyDamage
        }
        if ($hp -le 0) { return $false }
    }
    return $true
}
function Get-SimWinRate($Level, $GearAtk, $GearDef, $GearHp, $Heals, $Runs = 150) {
    $pet = @{ Level = $Level; MaxHP = 100 + 10 * ($Level - 1) + $GearHp
              ATK = 14 + 2 * ($Level - 1) + $GearAtk; DEF = 7 + 1 * ($Level - 1) + $GearDef }
    $w = 0
    for ($i = 0; $i -lt $Runs; $i++) { if (Invoke-SimRaid $pet $Heals) { $w++ } }
    return $w / [double]$Runs
}

$rNoGear  = Get-SimWinRate -Level 10 -GearAtk 0  -GearDef 0 -GearHp 0  -Heals 0
$rMidLv10 = Get-SimWinRate -Level 10 -GearAtk 10 -GearDef 5 -GearHp 30 -Heals 1
$rMidLv15 = Get-SimWinRate -Level 15 -GearAtk 10 -GearDef 5 -GearHp 30 -Heals 1
$rFullLv15= Get-SimWinRate -Level 15 -GearAtk 23 -GearDef 9 -GearHp 50 -Heals 2
Test-Assert ("Raid ohne Ausruestung Lv10 chancenlos: {0:P0} (<= 10 %)" -f $rNoGear) ($rNoGear -le 0.10)
Test-Assert ("Raid mittlere Ausruestung Lv10: {0:P0} (0-40 %)" -f $rMidLv10) ($rMidLv10 -le 0.40)
Test-Assert ("Raid mittlere Ausruestung Lv15: {0:P0} (30-95 %)" -f $rMidLv15) ($rMidLv15 -ge 0.30 -and $rMidLv15 -le 0.95)
Test-Assert ("Raid volle Ausruestung Lv15: {0:P0} (>= 75 %)" -f $rFullLv15) ($rFullLv15 -ge 0.75)
Test-Assert "Raid-Bosse skalieren nicht mit dem Spielerlevel" (
    (Get-SimWinRate -Level 15 -GearAtk 23 -GearDef 9 -GearHp 50 -Heals 2 -Runs 60) -ge
    (Get-SimWinRate -Level 5  -GearAtk 23 -GearDef 9 -GearHp 50 -Heals 2 -Runs 60)
)

# === SIMULATION ===
# 10.000 zufaellige A/V/S-Runden: die drei Ausgaenge muessen gleichverteilt sein,
# und der Rundenschaden darf nicht in Extreme kippen.
Write-Host ""
$moves = @("A","V","S")
$counts = @{ Win = 0; Tie = 0; Loss = 0 }
$pet = Get-RefPet 5
$foe = Get-RefRivalEnemy 5
$totalPlayerDmg = 0
for ($i = 0; $i -lt 10000; $i++) {
    $r = Resolve-AvsRound -PlayerMove ($moves | Get-Random) -EnemyMove ($moves | Get-Random) `
            -PlayerStats $pet -EnemyStats $foe -PlayerLevel 5 -EnemyLevel 5 -MovePower $script:AvsMovePower.Rival
    $counts[$r.Outcome]++
    $totalPlayerDmg += $r.PlayerDamage
}
foreach ($o in @("Win","Tie","Loss")) {
    $share = $counts[$o] / 10000.0
    Test-Assert ("Simulation: Anteil $o bei {0:P1} (erwartet ~33 %)" -f $share) ($share -gt 0.28 -and $share -lt 0.39)
}
$avgDmg = $totalPlayerDmg / 10000.0
Test-Assert ("Simulation: Durchschnittsschaden {0:N2} liegt zwischen 1 und MaxHP/3" -f $avgDmg) ($avgDmg -gt 1 -and $avgDmg -lt ($foe.MaxHP / 3))

# === INVARIANTEN DES SEAMS ===
Write-Host ""
$pet = Get-RefPet 5; $foe = Get-RefRivalEnemy 5
$win  = Resolve-AvsRound -PlayerMove A -EnemyMove V -PlayerStats $pet -EnemyStats $foe -PlayerLevel 5
$tie  = Resolve-AvsRound -PlayerMove A -EnemyMove A -PlayerStats $pet -EnemyStats $foe -PlayerLevel 5
$loss = Resolve-AvsRound -PlayerMove A -EnemyMove S -PlayerStats $pet -EnemyStats $foe -PlayerLevel 5
Test-Assert "Win: nur der Spieler trifft" ($win.PlayerDamage -gt 0 -and $win.EnemyDamage -eq 0)
Test-Assert "Tie: beide treffen" ($tie.PlayerDamage -gt 0 -and $tie.EnemyDamage -gt 0)
Test-Assert "Loss: nur der Gegner trifft" ($loss.PlayerDamage -eq 0 -and $loss.EnemyDamage -gt 0)
Test-Assert "Win schlaegt haerter als Tie" ($win.PlayerDamage -gt $tie.PlayerDamage)
$forced = Resolve-AvsRound -PlayerMove A -EnemyMove S -PlayerStats $pet -EnemyStats $foe -PlayerLevel 5 -ForceOutcome "Win"
Test-Assert "ForceOutcome uebersteuert die Zuege" ($forced.Outcome -eq "Win" -and $forced.EnemyDamage -eq 0)
$hiLvl = Resolve-AvsRound -PlayerMove A -EnemyMove V -PlayerStats $pet -EnemyStats $foe -PlayerLevel 20
Test-Assert "Hoeheres Angreifer-Level durchdringt DEF besser" ($hiLvl.PlayerDamage -gt $win.PlayerDamage)

# === SUMMARY ===
Write-Host "`n  ========================================" -ForegroundColor Cyan
Write-Host "  Tests: $tests | Passed: $($tests - $errors) | Failed: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "  ========================================" -ForegroundColor Cyan
if ($errors -eq 0) { Write-Host "`n  ALL BALANCE TESTS PASSED!`n" -ForegroundColor Green; exit 0 }
else { Write-Host "`n  $errors BALANCE TEST(S) FAILED.`n" -ForegroundColor Red; exit 1 }
