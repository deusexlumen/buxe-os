# BUXE_OS v24.0 -- CASINO ENGINE
# Framework f??r alle Casino-Spiele.

try {

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
                Save-State
                if (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue) {
                    $cp = $script:BuxeState.Pet.Companion
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
        
        # Apply casino luck bonus
        $luckMod = Get-CasinoLuckModifier
        $winAmount = $result.Win
        $bonus = 0
        if ($winAmount -gt 0 -and $luckMod -gt 1.0) {
            $bonus = [math]::Floor($winAmount * ($luckMod - 1.0))
            $winAmount += $bonus
            if ($bonus -gt 0) { $result.Win = $winAmount }
        }
        # Cap suspicious wins
        $maxWin = $bet * 100
        if ($winAmount -gt $maxWin) {
            Write-Warning "[Casino] Ungewoehnlich hoher Gewinn: $winAmount (cap: $maxWin)"
            $winAmount = $maxWin
            $result.Win = $winAmount
        }
        
        # Skill progression: CasinoLuck increases on wins with luck bonus active
        if ($winAmount -gt 0 -and $luckMod -gt 1.0) {
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
        }
        
        # Update stats
        if ($result.Stats) {
            foreach ($key in @($result.Stats.Keys)) {
                $stats[$key] = $result.Stats[$key]
            }
            Set-CasinoStats $StatsKey $stats
        }
        
        # Companion reactions (LucasArts-Style)
        Load-State
        $cp = $script:BuxeState.Companion
        if ($cp -and (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) {
            if ($bank -le 0) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_bust") -Fast
            } elseif ($result.Win -gt 500) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_bigwin") -Fast
                Add-PetMemory "Casino Big Win! +$($result.Win) G" "GOLD"
            } elseif ($result.Win -gt 0) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_win") -Fast
            } elseif ($result.Loss -gt 0) {
                Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_loss") -Fast
            }
        }
        
        # Quest Progress
        if (Get-Command Check-QuestProgress -ErrorAction SilentlyContinue) {
            Check-QuestProgress "casino"
        }
        
        # Easter Eggs
        if (Get-Command Check-EasterEgg -ErrorAction SilentlyContinue) {
            Check-EasterEgg "casino"
        }
        
        # Achievements
        if ($result.Achievement) { Unlock-Achievement $result.Achievement }
        
        Wait-Enter
    }
}

} catch {
    Write-Host "[casino-engine] CRITICAL ERROR: $_" -ForegroundColor Red
}
