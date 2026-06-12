# BUXE_OS v24.3 -- GAME ENGINE
# Wiederverwendbare Game-Logik: Karten, Wuerfel, Kampf.

try {

# === CARD DECK ===
$script:CardSuits = @("S","H","D","C")
$script:CardRanks = @("2","3","4","5","6","7","8","9","10","J","Q","K","A")

# Pre-allocate cached deck to avoid repeated allocations
$script:_CachedDeck = $null

function New-CardDeck {
    if ($script:_CachedDeck) {
        # Kopie des gecachten Decks zurueckgeben, damit In-Place-Shuffle
        # nicht den globalen Shared-State mutiert.
        $deck = $script:_CachedDeck.Clone()
        for ($i = $deck.Count - 1; $i -gt 0; $i--) {
            $j = Get-Random -Minimum 0 -Maximum ($i + 1)
            $temp = $deck[$i]; $deck[$i] = $deck[$j]; $deck[$j] = $temp
        }
        return $deck
    }
    # First time: create and cache
    $deck = [System.Collections.ArrayList]::new(52)
    foreach ($s in $script:CardSuits) {
        foreach ($r in $script:CardRanks) {
            [void]$deck.Add(@{ Suit = $s; Rank = $r })
        }
    }
    $script:_CachedDeck = $deck
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

# Card value lookup cache (avoids switch overhead)
$script:_CardValueCache = @{
    "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6; "7" = 7
    "8" = 8; "9" = 9; "10" = 10; "J" = 10; "Q" = 10; "K" = 10
}

function Get-CardValue($rank, [switch]$AcesHigh = $true) {
    if ($rank -eq "A") { return $(if ($AcesHigh) { 11 } else { 1 }) }
    return $script:_CardValueCache[$rank]
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

# Baccarat value lookup cache
$script:_BaccaratValueCache = @{
    "J" = 0; "Q" = 0; "K" = 0; "A" = 1
    "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6
    "7" = 7; "8" = 8; "9" = 9; "10" = 10
}

function Get-BaccaratValue($hand) {
    $total = 0
    foreach ($c in $hand) {
        $total += $script:_BaccaratValueCache[$c.Rank]
    }
    return $total % 10
}

# === DICE ===
function New-DiceRoll($count = 2, $sides = 6) {
    $results = [int[]]::new($count)
    for ($i = 0; $i -lt $count; $i++) {
        $results[$i] = Get-Random -Minimum 1 -Maximum ($sides + 1)
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
# Cached with TTL to avoid repeated JSON parsing
$script:_ModifierCache = @{
    CasinoLuck = @{ Value = $null; TS = 0 }
    StrategyInsight = @{ Value = $null; TS = 0 }
}
$script:_ModifierCacheTTL = 5

function Get-CasinoLuckModifier {
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $cache = $script:_ModifierCache.CasinoLuck
    if ($cache.Value -ne $null -and ($now - $cache.TS) -lt $script:_ModifierCacheTTL) {
        return $cache.Value
    }
    $pet = if (Get-Command Get-PetState -ErrorAction SilentlyContinue) { Get-PetState } else { $null }
    $cp = if ($pet) { $pet.Companion } else { $null }
    if (-not $cp) { $cp = Load-CompanionState }
    if (-not $cp -or -not $cp.Skills) { $cache.Value = 1.0; $cache.TS = $now; return 1.0 }
    $lvl = $cp.Skills.CasinoLuck
    $result = if (-not $lvl -or $lvl -le 0) { 1.0 } else { 1.0 + ($lvl * 0.03) }
    $cache.Value = $result; $cache.TS = $now
    return $result
}

function Get-StrategyInsightModifier {
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $cache = $script:_ModifierCache.StrategyInsight
    if ($cache.Value -ne $null -and ($now - $cache.TS) -lt $script:_ModifierCacheTTL) {
        return $cache.Value
    }
    $pet = if (Get-Command Get-PetState -ErrorAction SilentlyContinue) { Get-PetState } else { $null }
    $cp = if ($pet) { $pet.Companion } else { $null }
    if (-not $cp) { $cp = Load-CompanionState }
    if (-not $cp -or -not $cp.Skills) { $cache.Value = 1.0; $cache.TS = $now; return 1.0 }
    $lvl = $cp.Skills.StrategyInsight
    $result = if (-not $lvl -or $lvl -le 0) { 1.0 } else { 1.0 + ($lvl * 0.03) }
    $cache.Value = $result; $cache.TS = $now
    return $result
}

} catch {
    Write-Host "[engine-game] CRITICAL ERROR: $_" -ForegroundColor Red
}
