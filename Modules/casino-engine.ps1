# BUXE_OS v24.0 -- CASINO ENGINE
# Framework fuer alle Casino-Spiele.

try {

$script:CasinoLossLines = @{
    "SLOT MACHINE"     = @("Die Walzen lachen. Dein Gold nicht.", "Das Haus gewinnt. Das ist kein Bug, das ist ein Feature.", "Kein Match. Selbst die Symbole sind introvertiert.")
    "BLACKJACK"        = @("Dealer gewinnt. Wie ueberraschend.", "Bust. Nicht das erste Mal, oder?", "Die Bank hat gesprochen. Lautlos.")
    "EUROPEAN ROULETTE"= @("Die Kugel rollt woandershin. Wie deine Karriere.", "Rot? Schwarz? Egal. Du verlierst trotzdem.", "Null. Das Rad hat einen Sinn fuer Dramatik.")
    "CRAPS"            = @("Seven out. Die Wuerfel sind keine Freunde.", "Snake eyes. Zwei Augen, die dich anstarren.", "Craps. Der Name ist Programm.")
    "HIGHER OR LOWER"  = @("Falsch geraten. Die Karten luegen nie.", "Lower? Higher? Auf jeden Fall weniger Gold.", "Gleicher Wert haette gereicht. Tut er aber nicht.")
    "BACCARAT"         = @("Banker gewinnt. Wie ueberraschend.", "Tie? Nein. Nur du verlierst.", "Kommission faellig. Auch fuer dich.")
    "KENO"             = @("0 Treffer. Die Zahlen haben sich verschworen.", "Keine Uebereinstimmung. Nicht mal mit deinem Glueck.", "Keno: Die Illusion haelt laenger als das Geld.")
    "WHEEL OF FORTUNE" = @("BANKRUPT. Das Rad ist ein Poet.", "0x. Null Komma Null.", "Das Rad dreht sich. Dein Kontostand auch. Nach unten.")
}
function Get-CasinoLossLine($GameName) {
    $pool = $script:CasinoLossLines[$GameName]
    if (-not $pool) { return "Das Casino gewinnt. Wie immer." }
    return $pool | Get-Random
}

function Invoke-CasinoGame {
    param(
        [Parameter(Mandatory)] [string]$GameName,
        [Parameter(Mandatory)] [scriptblock]$PlayRound,
        [string]$StatsKey = $GameName
    )
    
    Load-State
    $stats = Get-CasinoStats $StatsKey
    if (-not $stats) { $stats = @{} }
    
    while ($true) {
        $br = Confirm-Bust $GameName
        Clear-Screen $GameName
        Show-Bankroll
        Write-Host ""
        Show-Frame "$GameName" -Double | Out-Null
        Write-Host ""
        
        $bet = Read-Bet $br "Einsatz"
        if ($bet -eq 0) { return }
        
        # Meta 13: Glitch — once per day casino hack
        $glitchActive = $false
        $petMeta = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Meta } else { $null }
        if ($petMeta -and $petMeta.Level -ge 13) {
            $today = Get-Date -Format "yyyy-MM-dd"
            if ($petMeta.GlitchUsed -ne $today) {
                $glitchActive = $true
                $petMeta.GlitchUsed = $today
                # GlitchUsed wird spaeter via Set-Bankroll -> Save-State persistiert
                if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
                    $pet = if (Get-Command Get-PetState -ErrorAction SilentlyContinue) { Get-PetState } else { $null }
                    $cp = if ($pet) { $pet.Companion } else { $null }
                    if ($cp) {
                        $glitchLine = switch ($cp.Name) {
                            "NEON" { "Reality-Glitch aktiv. Die Wahrscheinlichkeiten sind... angepasst." }
                            "RAVEN" { "Ich habe einen Bug im Casino-Code gefunden. Nutzen wir ihn." }
                            "PIXEL" { "Glitches sind keine Bugs — sie sind Features. Casino-Feature." }
                            "LUNA" { "Die Sterne sprechen zu mir... sie sagen: heute ist der Tag." }
                            "IVY" { "Ein kleiner Schubs am Rand des Quellcodes. Niemand wird es merken." }
                            "VERA" { "Administrative Override. Casino-Modus: suboptimal fuer den Hausvorteil." }
                            "JINX" { "Hihi! Ich habe die Wuerfel manipuliert! ...Nein, wirklich." }
                            default { "Reality-Glitch aktiv. Die Wahrscheinlichkeiten sind... angepasst." }
                        }
                        Show-CompanionDialog $cp $glitchLine -Fast
                    }
                }
                Write-Host "`n  [GLITCH] Meta-Hack aktiviert! Heute noch einmal verfuegbar." -ForegroundColor Magenta
            }
        }

        # Execute game logic
        $result = & $PlayRound $bet $stats
        
        # Apply glitch bonus
        if ($glitchActive) {
            if ($result.Win -gt 0) {
                $glitchBonus = [math]::Floor($result.Win * 0.2)
                $result.Win += $glitchBonus
                Write-Host "`n  [GLITCH BONUS] +$glitchBonus G durch Reality-Hack!" -ForegroundColor Magenta
            } elseif ($result.Loss -gt 0) {
                if ((Get-Random -Maximum 2) -eq 0) {
                    Write-Host "`n  [GLITCH SAVE] Verlust wurde durch Reality-Hack verhindert!" -ForegroundColor Magenta
                    $result.Loss = 0
                }
            }
        }

        # Apply Pet System Glitch Luck Infusion (+20% on next win)
        $petMeta = if ($script:BuxeState.Pet) { $script:BuxeState.Pet.Meta } else { $null }
        if ($petMeta -and $petMeta.GlitchLuckActive) {
            if ($result.Win -gt 0) {
                $infusionBonus = [math]::Floor($result.Win * 0.2)
                $result.Win += $infusionBonus
                Write-Host "`n  [GLITCH LUCK INFUSION] +$infusionBonus G! Der Bug war ein Feature!" -ForegroundColor Magenta
            }
            $petMeta.GlitchLuckActive = $false
            Save-State
        }
        
        # Apply casino luck bonus
        $luckMod = Get-CasinoLuckModifier
        # Konami-Mode: +50% Casino Luck fuer 47 Sekunden
        if ($script:KonamiModeUntil -and (Get-Date) -lt $script:KonamiModeUntil) {
            $luckMod = $luckMod * 1.5
            Write-Host "  [KONAMI MODE] Casino-Luck verdoppelt!" -ForegroundColor Cyan
        }
        $winAmount = $result.Win
        $bonus = 0
        if ($winAmount -gt 0 -and $luckMod -gt 1.0) {
            $bonus = [math]::Floor($winAmount * ($luckMod - 1.0))
            $winAmount += $bonus
            if ($bonus -gt 0) { $result.Win = $winAmount }
        }
        # IDDQD: Godmode — keine Verluste moeglich
        if ($script:IddqdActive -and $result.Loss -gt 0) {
            Write-Host "  [IDDQD] Verlust verhindert! Gottmodus ist OP." -ForegroundColor Red -BackgroundColor Black
            $result.Loss = 0
            $script:IddqdActive = $false
        }
        # Cap suspicious wins
        $maxWin = $bet * 200
        if ($winAmount -gt $maxWin) {
            Write-Warning "[Casino] Ungewoehnlich hoher Gewinn: $winAmount (cap: $maxWin)"
            $winAmount = $maxWin
            $result.Win = $winAmount
        }
        
        # Skill progression: CasinoLuck increases on wins with luck bonus active
        $cp = if ($script:BuxeState.Pet -and $script:BuxeState.Pet.Companion) { $script:BuxeState.Pet.Companion } else { $null }
        if ($cp -and $winAmount -gt 0 -and $luckMod -gt 1.0) {
            $cp.Skills.CasinoLuckWins = if ($cp.Skills.CasinoLuckWins) { $cp.Skills.CasinoLuckWins + 1 } else { 1 }
            if ($cp.Skills.CasinoLuckWins -ge 10 -and $cp.Skills.CasinoLuck -lt 10) {
                $cp.Skills.CasinoLuck++
                $cp.Skills.CasinoLuckWins = 0
                Write-Host "`n  [SKILL UP] Casino Luck ist jetzt Level $($cp.Skills.CasinoLuck)!" -ForegroundColor Magenta
            }
        }
        
        # Update bank
        if ($winAmount -gt 0) {
            Set-Bankroll $winAmount -TrackCasino
            if ($bonus -gt 0) {
                Write-Host "`n  +$winAmount G gewonnen! (+$bonus Casino Luck)" -ForegroundColor Green
            } else {
                Write-Host "`n  +$winAmount G gewonnen!" -ForegroundColor Green
            }
        } elseif ($result.Loss -gt 0) {
            Set-Bankroll (-$result.Loss) -TrackCasino
            Write-Host "`n  -$($result.Loss) G verloren." -ForegroundColor Red
            Write-Host "  $(Get-CasinoLossLine $GameName)" -ForegroundColor DarkGray
        }
        
        # Update stats
        if ($result.Stats) {
            foreach ($key in @($result.Stats.Keys)) {
                $stats[$key] = $result.Stats[$key]
            }
            Set-CasinoStats $StatsKey $stats
        }

        # === EVENT BUS: Subsysteme entkoppeln ===
        # Alle Cross-Cutting-Concerns (Companion, ARG, Quests, Easter Eggs) reagieren via world-events.ps1.
        # casino-engine kennt keine anderen Subsysteme mehr.
        Publish-BuxeEvent -Topic "casino.round.end" -Data @{ Game = $GameName; Bet = $bet }
        if ($result.Win -gt ($bet * 50)) {
            Publish-BuxeEvent -Topic "casino.jackpot" -Data @{ Game = $GameName; Amount = $result.Win }
        } elseif ($result.Win -gt 500) {
            Publish-BuxeEvent -Topic "casino.bigwin" -Data @{ Game = $GameName; Amount = $result.Win }
        } elseif ($result.Win -gt 0) {
            Publish-BuxeEvent -Topic "casino.win" -Data @{ Game = $GameName; Amount = $result.Win }
        } elseif ($result.Loss -gt 0) {
            Publish-BuxeEvent -Topic "casino.loss" -Data @{ Game = $GameName; Amount = $result.Loss }
        }
        if ($script:BuxeState.Bank.Gold -le 0) {
            Publish-BuxeEvent -Topic "casino.bust" -Data @{ Game = $GameName }
        }
        
        # Achievements werden vom Engine-Callback ausgewertet.
        if ($result.Achievement -and (Get-Command Unlock-Achievement -ErrorAction SilentlyContinue)) {
            Unlock-Achievement $result.Achievement
        }
        
        Wait-Enter
    }
}

} catch {
    Write-Host "[casino-engine] CRITICAL ERROR: $_" -ForegroundColor Red
}
