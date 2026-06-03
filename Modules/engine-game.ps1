# BUXE_OS v24.0 -- GAME ENGINE
# Wiederverwendbare Game-Logik: Karten, Wuerfel, Kampf.

try {

# === CARD DECK ===
$script:CardSuits = @("S","H","D","C")
$script:CardRanks = @("2","3","4","5","6","7","8","9","10","J","Q","K","A")

function New-CardDeck {
    $deck = [System.Collections.ArrayList]::new()
    foreach ($s in $script:CardSuits) {
        foreach ($r in $script:CardRanks) {
            [void]$deck.Add(@{ Suit = $s; Rank = $r })
        }
    }
    for ($i = $deck.Count - 1; $i -gt 0; $i--) {
        $j = Get-Random -Minimum 0 -Maximum ($i + 1)
        $temp = $deck[$i]; $deck[$i] = $deck[$j]; $deck[$j] = $temp
    }
    return $deck
}

function Draw-Card($deck, [ref]$pos) {
    if ($pos.Value -ge $deck.Count) {
        $deck = New-CardDeck
        $pos.Value = 0
    }
    $card = $deck[$pos.Value]
    $pos.Value++
    return $card
}

function Get-CardValue($rank, [switch]$AcesHigh = $true) {
    switch ($rank) {
        "A" { if ($AcesHigh) { return 11 } else { return 1 } }
        "K" { return 10 }
        "Q" { return 10 }
        "J" { return 10 }
        default { return [int]$_ }
    }
}

function Get-HandValue($hand, [switch]$AcesHigh = $true) {
    $total = 0; $aces = 0
    foreach ($c in $hand) {
        $v = Get-CardValue $c.Rank -AcesHigh:$AcesHigh
        $total += $v
        if ($c.Rank -eq "A") { $aces++ }
    }
    while ($total -gt 21 -and $aces -gt 0) { $total -= 10; $aces-- }
    return $total
}

function Get-BaccaratValue($hand) {
    $total = 0
    foreach ($c in $hand) {
        $v = if ($c.Rank -in @("J","Q","K")) { 0 } elseif ($c.Rank -eq "A") { 1 } else { [int]$c.Rank }
        $total += $v
    }
    return $total % 10
}

# === DICE ===
function New-DiceRoll($count = 2, $sides = 6) {
    $results = @()
    for ($i = 0; $i -lt $count; $i++) {
        $results += (Get-Random -Minimum 1 -Maximum ($sides + 1))
    }
    return $results
}

function Get-DiceSum($dice) {
    $sum = 0
    foreach ($d in $dice) { $sum += $d }
    return $sum
}

# === ELEMENT SYSTEM ===
$script:ElementMatrix = @{
    FIRE  = @{ Strong = "ICE";   Weak = "WATER" }
    ICE   = @{ Strong = "ELEC";  Weak = "FIRE" }
    ELEC  = @{ Strong = "WATER"; Weak = "ICE" }
    WATER = @{ Strong = "FIRE";  Weak = "ELEC" }
    VIRUS = @{ Strong = "ELEC";  Weak = "FIRE" }
    DARK  = @{ Strong = "NORM";  Weak = "ELEC" }
    NORM  = @{ Strong = "";      Weak = "" }
    HACK  = @{ Strong = "VIRUS"; Weak = "DARK" }
}

function Get-ElementModifier($atkType, $defType) {
    $em = $script:ElementMatrix[$atkType]
    if (-not $em) { return 1.0 }
    if ($em.Strong -eq $defType) { return 1.5 }
    if ($em.Weak -eq $defType) { return 0.5 }
    return 1.0
}

function Get-ElementEffectivenessText($modifier) {
    if ($modifier -gt 1) { return "SUPER EFFECTIVE!" }
    elseif ($modifier -lt 1) { return "Not very effective..." }
    else { return "" }
}

# === COMPANION SKILL MODIFIERS ===
function Get-CasinoLuckModifier {
    $pet = Get-PetState
    $cp = if ($pet) { $pet.Companion } else { $null }
    if (-not $cp) { $cp = Load-CompanionState }
    if (-not $cp -or -not $cp.Skills) { return 1.0 }
    $lvl = $cp.Skills.CasinoLuck
    if (-not $lvl -or $lvl -le 0) { return 1.0 }
    return 1.0 + ($lvl * 0.03)
}

function Get-StrategyInsightModifier {
    $pet = Get-PetState
    $cp = if ($pet) { $pet.Companion } else { $null }
    if (-not $cp) { $cp = Load-CompanionState }
    if (-not $cp -or -not $cp.Skills) { return 1.0 }
    $lvl = $cp.Skills.StrategyInsight
    if (-not $lvl -or $lvl -le 0) { return 1.0 }
    return 1.0 + ($lvl * 0.03)
}

# === LEVEL UP ENGINE (DEPRECATED — pet/combat.ps1 hat eigene Logik) ===
function Invoke-LevelUp($entity, $xpGain, $attacksTable, $skillsTable) {
    $entity.XP += $xpGain
    $leveled = $false
    while ($entity.XP -ge $entity.NextXP) {
        $entity.XP -= $entity.NextXP
        $entity.Level++
        $entity.NextXP = $entity.Level * 50
        $entity.MaxHP += (Get-Random -Minimum 5 -Maximum 15)
        $entity.ATK += (Get-Random -Minimum 2 -Maximum 5)
        $entity.DEF += (Get-Random -Minimum 1 -Maximum 4)
        $entity.SPD += (Get-Random -Minimum 1 -Maximum 3)
        $entity.HP = $entity.MaxHP
        $leveled = $true
        Write-Host "`n  LEVEL UP! $($entity.Name) is now Level $($entity.Level)!" -ForegroundColor Magenta
        Write-Host "  HP:$($entity.MaxHP) ATK:$($entity.ATK) DEF:$($entity.DEF) SPD:$($entity.SPD)" -ForegroundColor Cyan
        if ($attacksTable -and $attacksTable.ContainsKey($entity.Level)) {
            $newAtk = $attacksTable[$entity.Level]
            if ($entity.Attacks -notcontains $newAtk) {
                $entity.Attacks += $newAtk
                Write-Host "  New attack learned: $newAtk!" -ForegroundColor Yellow
            }
        }
        if ($skillsTable -and $entity.Skills.Count -lt 4) {
            $maxSkills = [math]::Min(4, [math]::Floor($entity.Level / 5) + 1)
            if ($entity.Skills.Count -lt $maxSkills -and (Get-Random -Minimum 1 -Maximum 101) -le 25) {
                $available = @($skillsTable.Keys) | Where-Object { $entity.Skills -notcontains $_ }
                if ($available.Count -gt 0) {
                    $newSkill = $available | Get-Random
                    $entity.Skills += $newSkill
                    Write-Host "  New skill learned: $newSkill!" -ForegroundColor Green
                }
            }
        }
    }
    return $leveled
}

} catch {
    Write-Host "[engine-game] CRITICAL ERROR: $_" -ForegroundColor Red
}
