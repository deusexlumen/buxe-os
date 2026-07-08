# BUXE_OS v25.0 -- WORLD EVENTS (BUS-VERDRAHTUNG)
# Hier -- und NUR hier -- lernen Subsysteme voneinander.
# casino-engine.ps1 kennt nach dem Refactor weder Pets noch ARG noch Quests.
# Es feuert Events. Dieses Modul entscheidet, was die Welt daraus macht.
#
# LOAD ORDER: nach engine-bus.ps1 und allen Feature-Modulen laden.

try {

# ============================================================
# 1. CASINO -> WELT
# ============================================================

# --- JACKPOT: Weltweite Konsequenzen ---
Subscribe-BuxeEvent -Topic "casino.jackpot" -Priority 10 -Handler {
    param($e)
    $amount = $e.Data.Amount
    $pet = Get-PetState
    if (-not $pet) { return }

    # a) Pet-Stimmung: Euphorie-Kaskade
    if ($pet.Companion) {
        $pet.Companion.Mood = "Happy"
        $pet.Companion.Bond = [math]::Min(100, $pet.Companion.Bond + 3)
        Show-CompanionDialog $pet.Companion "JACKPOT?! $amount Gold?! Okay. OKAY. Ich bin voellig ruhig. *vibriert auf Prozessorebene*" -Fast
    }

    # b) Raid-Unlock: Der Jackpot hat "Aufmerksamkeit" erzeugt
    if (-not $pet.Meta.JackpotRaidPending) {
        $pet.Meta.JackpotRaidPending = $true
        $pet.Meta.JackpotRaidExpires = (Get-Date).AddHours(24).ToString("yyyy-MM-dd HH:mm")
        Write-Host "`n  [WELT-EVENT] Dein Jackpot hat Aufmerksamkeit erregt..." -ForegroundColor Magenta
        Write-Host "  [WELT-EVENT] RAID freigeschaltet: 'DIE STEUERFAHNDUNG' (24h verfuegbar)" -ForegroundColor Magenta
        Publish-BuxeEvent -Topic "raid.unlocked" -Data @{ RaidId = "TAX_AUDIT"; Source = "casino.jackpot" } -Deferred
    } else {
        # Audit bereits offen -> Verdacht erhoehen
        if ($null -eq $pet.Meta.AuditSuspicion) { $pet.Meta.AuditSuspicion = 0 }
        $pet.Meta.AuditSuspicion++
    }

    # c) Progressive-Jackpot-Reset + Welt-Inflation (Shop-Preise +5% fuer 1 Tag)
    $pet.Meta.InflationUntil = (Get-Date).AddHours(24).ToString("yyyy-MM-dd HH:mm")
    $pet.Meta.InflationRate = 1.05
    Save-PetState $pet
}

# --- BUST: Die Welt tritt nach ---
Subscribe-BuxeEvent -Topic "casino.bust" -Priority 10 -Handler {
    param($e)
    $pet = Get-PetState
    if (-not $pet -or -not $pet.Companion) { return }
    # Mitleid oder Spott, abhaengig vom Bond -- aber ein Trost-Quest spawnt
    if (-not $pet.Meta.PityQuestActive) {
        $pet.Meta.PityQuestActive = $true
        Show-CompanionDialog $pet.Companion "Pleite. Komplett pleite. ...Ich kenne da einen Weg. Gewinn 3 Kaempfe und ich 'finde' 100 Gold. Frag nicht woher." -Fast
        $pet.Meta.PityQuestProgress = 0
        Save-PetState $pet

        # Quelle erscheint nur bei Nacht (separater Anzeige-Pfad)
        $hour = (Get-Date).Hour
        $isNight = if ($pet.Meta.LoginNight -eq $true) { $true } else { $hour -ge 22 -or $hour -lt 5 }
        if ($isNight) {
            if ($null -eq $pet.Meta.SourceDebt) { $pet.Meta.SourceDebt = 0 }
            $line = Get-EnsembleLine "QUELLE" (Get-QuelleBeat $pet.Meta.SourceDebt)
            if ($line -and $line -notmatch '^\[PLACEHOLDER:') {
                Write-Host "`n  [QUELLE] >> $line" -ForegroundColor DarkCyan
            }
        }
    }
}

# --- BIG WIN: Rival wird neidisch ---
Subscribe-BuxeEvent -Topic "casino.bigwin" -Handler {
    param($e)
    if ($e.Data.Amount -lt 500) { return }
    $pet = Get-PetState
    if (-not $pet) { return }
    if ($pet.Companion -and (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) {
        Show-CompanionDialog $pet.Companion (Get-CompanionLine $pet.Companion "casino_bigwin") -Fast
    }
    if (Get-Command Add-PetMemory -ErrorAction SilentlyContinue) {
        Add-PetMemory "Casino Big Win! +$($e.Data.Amount) G" "GOLD"
    }
    # 30% Chance: Rival-Ambush beim naechsten Kampf (staerkerer Gegner, doppelte Belohnung)
    if ((Get-Random -Maximum 100) -lt 30) {
        $pet.Meta.RivalAmbushPending = $true
        Save-PetState $pet
        Write-Host "  [?] Irgendwo beobachtet dich jemand..." -ForegroundColor DarkMagenta
    }
}

# --- NORMAL WIN/LOSS: Companion-Dialoge, Quests, Easter Eggs ---
Subscribe-BuxeEvent -Topic "casino.win" -Handler {
    param($e)
    $pet = Get-PetState
    $cp = if ($pet) { $pet.Companion } else { $null }
    if ($cp -and (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) {
        Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_win") -Fast
    }
    if (Get-Command Check-QuestProgress -ErrorAction SilentlyContinue) { Check-QuestProgress "casino" }
    if (Get-Command Check-EasterEgg -ErrorAction SilentlyContinue) { Check-EasterEgg "casino" }
}

Subscribe-BuxeEvent -Topic "casino.loss" -Handler {
    param($e)
    $pet = Get-PetState
    $cp = if ($pet) { $pet.Companion } else { $null }
    if ($cp -and (Get-Command Show-CompanionDialog -ErrorAction SilentlyContinue)) {
        Show-CompanionDialog $cp (Get-CompanionLine $cp "casino_loss") -Fast
    }
    if (Get-Command Check-QuestProgress -ErrorAction SilentlyContinue) { Check-QuestProgress "casino" }
    if (Get-Command Check-EasterEgg -ErrorAction SilentlyContinue) { Check-EasterEgg "casino" }
}

# --- JEDE RUNDE: ARG-Progression ---
Subscribe-BuxeEvent -Topic "casino.round.end" -Handler {
    param($e)
    if (Get-Command Invoke-ArgCasinoCheck -ErrorAction SilentlyContinue) { Invoke-ArgCasinoCheck }
    if (Get-Command Invoke-ArgActionTick -ErrorAction SilentlyContinue) { Invoke-ArgActionTick }
}

# ============================================================
# 2. COMBAT -> WELT
# ============================================================

# HINWEIS: Kampfende-Belohnungen werden direkt von Invoke-TacticalCombat aufgerufen,
# nachdem der Reducer das Ergebnis geliefert hat. So bleibt das Pet-Objekt konsistent
# (by-reference HP-Mutationen im Reducer muessen vor der Reward-Logik synchronisiert sein).
# combat.won/lost/fled Events dienen weiterhin Simulator, Pity-Quest und ARG.

# --- Pity-Quest-Fortschritt ---
Subscribe-BuxeEvent -Topic "combat.won" -Handler {
    param($e)
    $pet = Get-PetState
    if (-not $pet -or -not $pet.Meta.PityQuestActive) { return }
    $pet.Meta.PityQuestProgress++
    if ($pet.Meta.PityQuestProgress -ge 3) {
        $pet.Economy.Gold += 100
        $pet.Meta.PityQuestActive = $false
        if ($pet.Companion) {
            Show-CompanionDialog $pet.Companion "Drei Siege. Hier: 100 Gold. Sie sind... vom Boden gefallen. Aus einer Wolke. Vertrau mir." -Fast
        }
        Publish-BuxeEvent -Topic "pet.pityquest.completed" -Data @{ Amount = 100 }
    }
    Save-PetState $pet
}

# --- Boss-Kill fuettert das ARG ---
Subscribe-BuxeEvent -Topic "combat.won" -Handler {
    param($e)
    if (-not $e.Data.IsBoss) { return }
    if (Get-Command Invoke-ArgActionTick -ErrorAction SilentlyContinue) {
        Invoke-ArgActionTick
    }
    Publish-BuxeEvent -Topic "world.notoriety.increase" -Data @{ Amount = 5 } -Deferred
}

# ============================================================
# 3. ECONOMY: INFLATION ALS QUERSCHNITT
# ============================================================
function Get-WorldPriceModifier {
    # Von allen Shops aufzurufen statt hardcoded Preise:
    #   $price = [math]::Round($basePrice * (Get-WorldPriceModifier))
    $pet = Get-PetState
    if (-not $pet -or -not $pet.Meta.InflationUntil) { return 1.0 }
    if ((Get-Date) -lt [datetime]$pet.Meta.InflationUntil) {
        return [double]$pet.Meta.InflationRate
    }
    return 1.0
}

# ============================================================
# 4. HEARTBEAT: Der Prompt als World-Tick
# ============================================================
# In der prompt-Funktion des Profils EINE Zeile ergaenzen:
#   Invoke-WorldTick
# Jeder gerenderte Prompt = ein Herzschlag der Welt. Kein Thread noetig.
function Invoke-WorldTick {
    try {
        # 1. Deferred Events abarbeiten
        Invoke-BuxeBusFlush
        # 2. Zeitbasierte Systeme pruefen (billig: nur Timestamps vergleichen)
        $pet = if (Get-Command Get-PetState -ErrorAction SilentlyContinue) { Get-PetState } else { $null }
        if ($pet -and $pet.Meta.JackpotRaidPending -and $pet.Meta.JackpotRaidExpires) {
            if ((Get-Date) -gt [datetime]$pet.Meta.JackpotRaidExpires) {
                $pet.Meta.JackpotRaidPending = $false
                Publish-BuxeEvent -Topic "raid.expired" -Data @{ RaidId = "TAX_AUDIT" } -Deferred
                Save-PetState $pet
            }
        }
        # 3. Akt I Session 47 -- billiger Flag-Vergleich im ersten Tick
        if ($pet -and $pet.Meta.Act1Pending -and -not $pet.Meta.Act1Done) {
            if (Get-Command Invoke-Act1Session47 -ErrorAction SilentlyContinue) {
                Invoke-Act1Session47
            }
        }
    } catch { }
}

# --- Pruefer-Auftritt wenn Steuer-Raid freigeschaltet wird ---
Subscribe-BuxeEvent -Topic "raid.unlocked" -Priority 10 -Handler {
    param($e)
    if ($e.Data.RaidId -eq "TAX_AUDIT") {
        $pet = Get-PetState
        if ($pet) {
            if ($null -eq $pet.Meta.AuditSuspicion) { $pet.Meta.AuditSuspicion = 0 }
            $line = Get-EnsembleLine "PRUEFER" (Get-PrueferBeat $pet.Meta.AuditSuspicion)
            if ($line -and $line -notmatch '^\[PLACEHOLDER:') {
                Write-Host "`n  [PRUEFER] >> $line" -ForegroundColor Magenta
            }
        }
    }
}

# --- Raid-Expiry Ankuendigung ---
Subscribe-BuxeEvent -Topic "raid.expired" -Handler {
    param($e)
    Write-Host "  [WELT-EVENT] RAID 'DIE STEUERFAHNDUNG' ist abgelaufen. Die Steuerfahndung hat den Vorgang vertagt." -ForegroundColor DarkGray
}

# ============================================================
# 5. MEMORY-WRITER (Pet Langzeitgedaechtnis)
# ============================================================

Subscribe-BuxeEvent -Topic "casino.jackpot" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "TRIUMPH" @{ Amount = $e.Data.Amount; Game = $e.Data.Game }
    }
}

Subscribe-BuxeEvent -Topic "casino.bust" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "WUNDE" @{ Game = $e.Data.Game }
    }
}

Subscribe-BuxeEvent -Topic "combat.won" -Priority 20 -Handler {
    param($e)
    if ($e.Data.IsBoss -and (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue)) {
        Add-PetMemoryEntry "TRIUMPH" @{ Enemy = $e.Data.Enemy; Game = "COMBAT" }
    }
}

Subscribe-BuxeEvent -Topic "combat.lost" -Priority 20 -Handler {
    param($e)
    if ($e.Data.IsBoss -and (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue)) {
        Add-PetMemoryEntry "WUNDE" @{ Enemy = $e.Data.Enemy; Game = "COMBAT" }
    }
}

Subscribe-BuxeEvent -Topic "pvp.rankup" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "TRIUMPH" @{ OldRank = $e.Data.OldRank; NewRank = $e.Data.NewRank; Points = $e.Data.Points }
    }
}

Subscribe-BuxeEvent -Topic "raid.won" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "TRIUMPH" @{ Phase = $e.Data.Phase; Tokens = $e.Data.Tokens }
    }
}

Subscribe-BuxeEvent -Topic "raid.lost" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "WUNDE" @{ Phase = $e.Data.Phase }
    }
}

Subscribe-BuxeEvent -Topic "raid.unlocked" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "BEGEGNUNG" @{ RaidId = $e.Data.RaidId; Source = $e.Data.Source }
    }
}

Subscribe-BuxeEvent -Topic "raid.expired" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "BEGEGNUNG" @{ RaidId = $e.Data.RaidId }
    }
}

Subscribe-BuxeEvent -Topic "rival.ambush" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "BEGEGNUNG" @{ Rival = $e.Data.RivalName }
    }
}

Subscribe-BuxeEvent -Topic "pet.pityquest.completed" -Priority 20 -Handler {
    param($e)
    $pet = Get-PetState
    if ($pet) {
        if ($null -eq $pet.Meta.SourceDebt) { $pet.Meta.SourceDebt = 0 }
        $pet.Meta.SourceDebt++
        Save-PetState $pet
    }
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "SCHULD" @{ Amount = 100 }
    }
}

Subscribe-BuxeEvent -Topic "login.night" -Priority 20 -Handler {
    param($e)
    if (Get-Command Add-PetMemoryEntry -ErrorAction SilentlyContinue) {
        Add-PetMemoryEntry "NACHT" @{ Hour = $e.Data.Hour }
    }
}

} catch {
    Write-Host "[world-events] CRITICAL ERROR: $_" -ForegroundColor Red
}
