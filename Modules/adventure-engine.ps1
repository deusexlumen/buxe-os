# BUXE_OS v24.7 -- ADVENTURE ENGINE
# Parser-basierte Adventure-Engine im LucasArts-Stil.
# Room-System, Inventory, Kommandoparser, State-Management.

try {

# === ADVENTURE STATE ===
# Persistiert getrennt vom Haupt-State, damit Savegames unabhängig sind.

$script:AdvSaveFile = Join-Path $script:BuxeStateDir "buxe_adventure.json"

function Get-AdventureDefaults {
    return @{
        Version = 1
        CurrentRoom = "hangar"
        Inventory = @()
        Flags = @{}
        Visited = @()
        Moves = 0
        Score = 0
        MaxScore = 200
        Oxygen = 10
    }
}

function Load-AdventureState {
    if (Test-Path $script:AdvSaveFile) {
        try {
            $raw = Get-Content $script:AdvSaveFile -Raw -ErrorAction Stop
            $loaded = $raw | ConvertFrom-Json -ErrorAction Stop
            if ($loaded.Version -eq 1) {
                $script:AdvState = @{}
                $loaded.PSObject.Properties | ForEach-Object {
                    $script:AdvState[$_.Name] = $_.Value
                }
                # Ensure arrays are PS arrays
                if (-not $script:AdvState.Inventory) { $script:AdvState.Inventory = @() }
                if (-not $script:AdvState.Visited) { $script:AdvState.Visited = @() }
                if (-not $script:AdvState.Flags) { $script:AdvState.Flags = @{} }
                if (-not $script:AdvState.CompanionAI) {
                    $script:AdvState.CompanionAI = @{
                        Mood = "Curious"
                        Boredom = 0
                        Fear = 0
                        RunningGags = @{}
                        FoundSecrets = @()
                        LastRoom = ""
                        MovesWithoutProgress = 0
                        LastAdvice = ""
                    }
                }
                return
            }
        } catch {}
    }
    $script:AdvState = Get-AdventureDefaults
}

$script:AdvStateDirty = $false

function Save-AdventureState {
    param([switch]$Force)
    if (-not $Force -and -not $script:AdvStateDirty) { return }
    if (-not (Test-Path $script:BuxeStateDir)) {
        New-Item -ItemType Directory -Path $script:BuxeStateDir -Force | Out-Null
    }
    $tmp = "$script:AdvSaveFile.$([Guid]::NewGuid().ToString().Substring(0,8)).tmp"
    $maxRetries = 3
    for ($i = 0; $i -lt $maxRetries; $i++) {
        try {
            $script:AdvState | ConvertTo-Json -Depth 10 | Out-File $tmp -Force
            Move-Item $tmp $script:AdvSaveFile -Force
            $script:AdvStateDirty = $false
            break
        } catch {
            if ($i -eq $maxRetries - 1) { throw }
            Start-Sleep -Milliseconds 100
        }
    }
    # Cleanup temp files safely (CWE-22 fix)
    Get-ChildItem -Path $script:BuxeStateDir -Filter "buxe_adventure.*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

function Reset-AdventureState {
    $script:AdvState = Get-AdventureDefaults
    $script:AdvStateDirty = $true
}

# === ROOM SYSTEM ===
# Jeder Raum hat: Name, Description, Exits, Objects, NPCs, Art

$script:AdvRooms = @{}

function Register-Room($Id, $Name, $Description, $Exits, $Objects, $NPCs, $Art, $CompanionContext) {
    $script:AdvRooms[$Id] = @{
        Id = $Id
        Name = $Name
        Description = $Description
        Exits = $Exits       # @{ north = "roomId"; south = "roomId" }
        Objects = $Objects   # @{ key = @{ Name="..."; Description="..."; Takeable=$true; UseWith="..." } }
        NPCs = $NPCs         # @{ guard = @{ Name="..."; Dialog=@("...") } }
        Art = $Art           # Unicode-Art Array
        CompanionContext = $CompanionContext
    }
}

function Get-Room($Id) { return $script:AdvRooms[$Id] }

# === INVENTORY ===

function Add-ToInventory($ItemId, $ItemName) {
    if ($script:AdvState.Inventory -notcontains $ItemId) {
        $script:AdvState.Inventory += $ItemId
        $script:AdvStateDirty = $true
        return $true
    }
    return $false
}

function Remove-FromInventory($ItemId) {
    $script:AdvState.Inventory = @($script:AdvState.Inventory | Where-Object { $_ -ne $ItemId })
    $script:AdvStateDirty = $true
}

function Has-Item($ItemId) { return $script:AdvState.Inventory -contains $ItemId }

function Show-Inventory {
    $inv = $script:AdvState.Inventory
    if ($inv.Count -eq 0) { return "Dein Inventar ist leer." }
    $items = @()
    foreach ($id in $inv) {
        # Find item name across all rooms
        $name = $id
        foreach ($room in $script:AdvRooms.Values) {
            if ($room.Objects[$id]) { $name = $room.Objects[$id].Name; break }
        }
        $items += $name
    }
    return "Inventar: " + ($items -join ", ")
}

# === PARSER ===
# Normalisiert Eingabe zu (Verb, Noun, Target)

function Parse-AdventureCommand($InputLine) {
    if ($InputLine -eq $null) { return @{ Verb = "noop"; Noun = ""; Target = ""; Raw = "" } }
    $line = $InputLine.ToString().Trim().ToLower()
    if ($line -eq "") { return @{ Verb = "noop"; Noun = ""; Target = ""; Raw = $line } }

    # Direction shortcuts
    $directions = @{ n = "north"; s = "south"; e = "east"; w = "west"; u = "up"; d = "down" }
    if ($directions[$line]) { $line = "go " + $directions[$line] }
    if ($line -in @("north","south","east","west","up","down")) { $line = "go $line" }

    # Abbreviations
    $line = $line -replace '^l$', 'look'
    $line = $line -replace '^i$', 'inventory'
    $line = $line -replace '^h$', 'help'
    $line = $line -replace '^q$', 'quit'
    $line = $line -replace '^t ', 'take '
    $line = $line -replace '^g ', 'go '
    $line = $line -replace '^x ', 'examine '
    $line = $line -replace '^ex ', 'examine '
    $line = $line -replace '^tk ', 'talk '

    $parts = $line -split '\s+', 3
    $verb = $parts[0]
    $noun = if ($parts.Count -gt 1) { $parts[1] } else { "" }
    $target = if ($parts.Count -gt 2) { $parts[2] } else { "" }

    # Multi-word objects: "look at", "talk to", "use key with"
    if ($verb -eq "look" -and $noun -eq "at" -and $target) {
        $verb = "examine"; $noun = $target; $target = ""
    }
    if ($verb -eq "talk" -and $noun -eq "to" -and $target) {
        $verb = "talk"; $noun = $target; $target = ""
    }
    if ($verb -eq "use" -and $target -match '^with\s+(.+)$') {
        $target = $Matches[1]; $noun = $noun
    }
    if ($verb -eq "use" -and $noun -and -not $target) {
        # "use key on door" -> extract
        $m = [regex]::Match($line, '^use\s+(\w+)\s+(?:on|with)\s+(\w+)')
        if ($m.Success) { $noun = $m.Groups[1].Value; $target = $m.Groups[2].Value }
    }

    # Normalize verb aliases
    $verbMap = @{
        go = "go"; walk = "go"; move = "go"
        look = "look"; examine = "examine"; inspect = "examine"; read = "examine"; x = "examine"
        take = "take"; get = "take"; grab = "take"
        drop = "drop"; leave = "drop"
        use = "use"
        talk = "talk"; speak = "talk"; ask = "talk"
        inventory = "inventory"; inv = "inventory"
        help = "help"; "?" = "help"
        quit = "quit"; exit = "quit"; bye = "quit"
        save = "save"
        load = "load"
        score = "score"
        hack = "hack"
    }
    if ($verbMap[$verb]) { $verb = $verbMap[$verb] }

    return @{ Verb = $verb; Noun = $noun; Target = $target; Raw = $line }
}

# === COMMAND PROCESSOR ===

function Process-AdventureCommand($Cmd) {
    $room = Get-Room $script:AdvState.CurrentRoom
    if ($Cmd.Verb -ne "noop") { $script:AdvState.Moves++ }

    # Running Gag + Absurd Combo check (pre-action)
    $gag = $null
    $absurd = $null
    if (Get-Command Test-RunningGag -ErrorAction SilentlyContinue) {
        $gag = Test-RunningGag $Cmd.Verb $Cmd.Noun
        if ($gag.Triggered) {
            # Still process the command, but show gag after
        }
    }
    if ($Cmd.Verb -eq "use" -and $Cmd.Noun -and (Get-Command Test-AbsurdCombo -ErrorAction SilentlyContinue)) {
        $absurd = Test-AbsurdCombo $Cmd.Noun $Cmd.Target
        if ($absurd.IsAbsurd) {
            # Absurd combos bypass normal logic and return immediately
            if (Get-Command Invoke-AdventureCompanionHook -ErrorAction SilentlyContinue) {
                Invoke-AdventureCompanionHook $Cmd.Verb $Cmd.Noun $room $absurd
            }
            Save-AdventureState
            return @{ Success = $true; Message = $absurd.Line; CompanionContext = $absurd.Context }
        }
    }

    $result = $null
    switch ($Cmd.Verb) {
        "go" {
            # === ARG v3.0: Room 17 Secret Navigation ===
            if ($Cmd.Noun -eq "north" -and $room.Id -eq "secret" -and (Get-Command Test-ArgRoom17Available -ErrorAction SilentlyContinue) -and (Test-ArgRoom17Available)) {
                if ($script:AdvRooms.ContainsKey("hollow")) {
                    $script:AdvState.CurrentRoom = "hollow"
                    if ($script:AdvState.Visited -notcontains "hollow") {
                        $script:AdvState.Visited += "hollow"
                        $script:AdvState.Score += 5
                    }
                    $script:AdvStateDirty = $true
                    $newRoom = Get-Room "hollow"
                    $result = @{ Success = $true; Message = ""; RoomChanged = $true; CompanionContext = $newRoom.CompanionContext }
                    break
                }
            }

            if (-not $room.Exits[$Cmd.Noun]) {
                $result = @{ Success = $false; Message = "Du kannst nicht nach $($Cmd.Noun) gehen."; CompanionContext = "adventure_blocked" }
                break
            }
            $targetRoomId = $room.Exits[$Cmd.Noun]

            # EVA Suit Check
            if ($targetRoomId -eq "eva") {
                if (-not (Has-Item "suit")) {
                    $result = @{ Success = $false; Message = "Du oeffnest die Luftschleuse. Der Sog des Vakuums reisst dich hinaus. Ohne Raumanzug ueberlebst du 3 Sekunden.`n`n=== GAME OVER ===`nDu bist erfroren im Weltraum.`nTippe 'load' um fortzufahren."; CompanionContext = "adventure_scared" }
                    break
                }
                # Reset oxygen when entering EVA
                $script:AdvState.Oxygen = 10
            }

            # Oxygen countdown in EVA
            if ($room.Id -eq "eva" -and $targetRoomId -ne "airlock") {
                $script:AdvState.Oxygen--
                if ($script:AdvState.Oxygen -le 0) {
                    $result = @{ Success = $false; Message = "Dein Sauerstoff ist aufgebraucht. Die Dunkelheit umschlingt dich.`n`n=== GAME OVER ===`nDu bist erstickt im Weltraum.`nTippe 'load' um fortzufahren."; CompanionContext = "adventure_scared" }
                    break
                }
            }

            # Leaving EVA restores oxygen
            if ($room.Id -eq "eva" -and $targetRoomId -eq "airlock") {
                $script:AdvState.Oxygen = 10
            }

            $script:AdvState.CurrentRoom = $targetRoomId
            if ($script:AdvState.Visited -notcontains $script:AdvState.CurrentRoom) {
                $script:AdvState.Visited += $script:AdvState.CurrentRoom
                $script:AdvState.Score += 5
            }
            $script:AdvStateDirty = $true
            $newRoom = Get-Room $script:AdvState.CurrentRoom
            $oxMsg = ""
            if ($newRoom.Id -eq "eva") { $oxMsg = " Sauerstoff: $($script:AdvState.Oxygen)/10" }
            $result = @{ Success = $true; Message = $oxMsg; RoomChanged = $true; CompanionContext = $newRoom.CompanionContext }
            break
        }
        "look" {
            # ARG v3.0: Raum 17 (Hollow) wird frei, wenn Motherlode unlocked
            # und IDDQD noch nicht -- der Spiegel zeigt sich nur, wenn man
            # schon tief genug gegraben hat, aber noch nicht tief genug gefallen.
            if ($Cmd.Noun -eq "deeper" -and $room.Id -eq "cafeteria") {
                if (Get-Command Test-ArgUnlocked -ErrorAction SilentlyContinue) {
                    if ((Test-ArgUnlocked "motherlode") -and -not (Test-ArgUnlocked "iddqd")) {
                        if ($script:AdvRooms.ContainsKey("hollow")) {
                            $script:AdvState.CurrentRoom = "hollow"
                            if ($script:AdvState.Visited -notcontains "hollow") {
                                $script:AdvState.Visited += "hollow"
                                $script:AdvState.Score += 5
                            }
                            $script:AdvStateDirty = $true
                            $newRoom = Get-Room "hollow"
                            $result = @{ Success = $true; Message = ""; RoomChanged = $true; CompanionContext = "adventure_look" }
                            break
                        }
                    }
                }
            }
            $result = @{ Success = $true; Message = $room.Description; CompanionContext = "adventure_look" }
            break
        }
        "examine" {
            if ($room.Objects[$Cmd.Noun]) {
                $result = @{ Success = $true; Message = $room.Objects[$Cmd.Noun].Description; CompanionContext = "adventure_examine" }
            } elseif ($room.NPCs[$Cmd.Noun]) {
                $result = @{ Success = $true; Message = $room.NPCs[$Cmd.Noun].Description; CompanionContext = "adventure_examine" }
            } elseif (Has-Item $Cmd.Noun) {
                $foundDesc = $null
                foreach ($r in $script:AdvRooms.Values) {
                    if ($r.Objects[$Cmd.Noun]) { $foundDesc = $r.Objects[$Cmd.Noun].Description; break }
                }
                if ($foundDesc) {
                    $result = @{ Success = $true; Message = $foundDesc; CompanionContext = "adventure_examine" }
                } else {
                    $result = @{ Success = $false; Message = "Das siehst du hier nicht."; CompanionContext = "adventure_confused" }
                }
            } else {
                $result = @{ Success = $false; Message = "Das siehst du hier nicht."; CompanionContext = "adventure_confused" }
            }
            break
        }
        "take" {
            if (-not $room.Objects[$Cmd.Noun]) {
                $result = @{ Success = $false; Message = "Das gibt es hier nicht."; CompanionContext = "adventure_confused" }
            } else {
                $obj = $room.Objects[$Cmd.Noun]
                if (-not $obj.Takeable) {
                    $result = @{ Success = $false; Message = "Das kannst du nicht mitnehmen."; CompanionContext = "adventure_blocked" }
                } elseif (Add-ToInventory $Cmd.Noun $obj.Name) {
                    $room.Objects.Remove($Cmd.Noun)
                    $script:AdvStateDirty = $true
                    $result = @{ Success = $true; Message = "Du nimmst $($obj.Name)."; CompanionContext = "adventure_take" }
                } else {
                    $result = @{ Success = $false; Message = "Du hast das schon."; CompanionContext = "adventure_confused" }
                }
            }
            break
        }
        "drop" {
            if (-not (Has-Item $Cmd.Noun)) {
                $result = @{ Success = $false; Message = "Das hast du nicht."; CompanionContext = "adventure_confused" }
            } else {
                $objDef = $null
                foreach ($r in $script:AdvRooms.Values) {
                    if ($r.Objects[$Cmd.Noun]) { $objDef = $r.Objects[$Cmd.Noun]; break }
                }
                if (-not $objDef) {
                    $objDef = @{ Name = $Cmd.Noun; Description = "Ein $Cmd.Noun."; Takeable = $true }
                }
                $room.Objects[$Cmd.Noun] = $objDef
                Remove-FromInventory $Cmd.Noun
                $result = @{ Success = $true; Message = "Du legst $($objDef.Name) hin."; CompanionContext = "adventure_drop" }
            }
            break
        }
        "use" {
            $result = Invoke-UseHandler $Cmd.Noun $Cmd.Target $room
            break
        }
        "talk" {
            if (-not $room.NPCs[$Cmd.Noun]) {
                $result = @{ Success = $false; Message = "Mit wem willst du reden?"; CompanionContext = "adventure_confused" }
            } else {
                $npc = $room.NPCs[$Cmd.Noun]
                $dialog = $npc.Dialog | Get-Random
                $result = @{ Success = $true; Message = "$($npc.Name): `"$dialog`""; CompanionContext = "adventure_talk" }
            }
            break
        }
        "inventory" {
            $result = @{ Success = $true; Message = (Show-Inventory); CompanionContext = "adventure_inventory" }
            break
        }
        "help" {
            $result = @{ Success = $true; Message = (Get-AdventureHelp); CompanionContext = "adventure_help" }
            break
        }
        "save" {
            $script:AdvStateDirty = $true
            $result = @{ Success = $true; Message = "Spiel gespeichert."; CompanionContext = "adventure_save" }
            break
        }
        "load" {
            Load-AdventureState
            $result = @{ Success = $true; Message = "Spiel geladen."; CompanionContext = "adventure_load" }
            break
        }
        "score" {
            $ox = ""
            if ($script:AdvState.CurrentRoom -eq "eva") { $ox = " | Sauerstoff: $($script:AdvState.Oxygen)" }
            $result = @{ Success = $true; Message = "Punkte: $($script:AdvState.Score) / $($script:AdvState.MaxScore) | Züge: $($script:AdvState.Moves) | Entdeckt: $($script:AdvState.Visited.Count) / $($script:AdvRooms.Count) Räume$ox"; CompanionContext = "adventure_score" }
            break
        }
        "hack" {
            if (-not $room.Objects[$Cmd.Noun]) {
                $result = @{ Success = $false; Message = "Was willst du hacken?"; CompanionContext = "adventure_confused" }
            } elseif ($room.Objects[$Cmd.Noun].Name -notmatch "Terminal|Konsole|Computer|Bildschirm") {
                $result = @{ Success = $false; Message = "Das kannst du nicht hacken."; CompanionContext = "adventure_blocked" }
            } elseif ($Cmd.Noun -eq "terminal" -and $room.Id -eq "corridor" -and -not $script:AdvState.Flags["bridge_unlocked"]) {
                $result = @{ Success = $true; Message = "Du hackst das Terminal. Die Kartenleser-Sicherheit ist laecherlich. Die Bruecke ist jetzt zugaenglich."; CompanionContext = "adventure_unlock" }
                $script:AdvState.Flags["bridge_unlocked"] = $true
                $script:AdvRooms["corridor"].Exits["north"] = "bridge"
                $script:AdvState.Score += 15
                $script:AdvStateDirty = $true
            } elseif ($Cmd.Noun -eq "terminal" -and $room.Id -eq "medbay" -and -not $script:AdvState.Flags["medbay_unlocked"]) {
                $result = @{ Success = $true; Message = "Du hackst das Med-Terminal. Patientendaten entschluesselt. Jemand hat Experimente an der Crew durchgefuehrt. Und du hast den Schluessel gefunden: 7-7-7."; CompanionContext = "adventure_unlock" }
                $script:AdvState.Flags["medbay_unlocked"] = $true
                $script:AdvState.Score += 10
                $script:AdvStateDirty = $true
            } else {
                $result = @{ Success = $false; Message = "Das Terminal ist bereits entsperrt oder nicht hackbar."; CompanionContext = "adventure_blocked" }
            }
            break
        }
        "jump" {
            if ($room.Id -eq "hollow") {
                if (Get-Command Invoke-ArgRoom17Death -ErrorAction SilentlyContinue) {
                    Invoke-ArgRoom17Death
                }
                $result = @{ Success = $false; Message = "Du springst in die Leere. Der Fall ist endlos. Aber irgendwo im Sturz... hoerst du ein Lachen.`n`n=== GAME OVER ===`nDu bist im Nichts verschwunden.`nTippe 'load' um fortzufahren."; CompanionContext = "adventure_scared" }
            } else {
                $result = @{ Success = $false; Message = "Das bringt hier nichts."; CompanionContext = "adventure_confused" }
            }
            break
        }
        "die" {
            if ($room.Id -eq "hollow") {
                if (Get-Command Invoke-ArgRoom17Death -ErrorAction SilentlyContinue) {
                    Invoke-ArgRoom17Death
                }
                $result = @{ Success = $false; Message = "Du gibst auf. Die Dunkelheit umarmt dich. Aber sie ist warm. Fast wie... Zuhause.`n`n=== GAME OVER ===`nDu bist im Nichts verschwunden.`nTippe 'load' um fortzufahren."; CompanionContext = "adventure_scared" }
            } else {
                $result = @{ Success = $false; Message = "Nicht hier. Nicht jetzt."; CompanionContext = "adventure_confused" }
            }
            break
        }
        "void" {
            if ($room.Id -eq "hollow") {
                if (Get-Command Invoke-ArgRoom17Death -ErrorAction SilentlyContinue) {
                    Invoke-ArgRoom17Death
                }
                $result = @{ Success = $false; Message = "Du wirst eins mit der Leere. Kein Schmerz. Kein Licht. Nur... Code.`n`n=== GAME OVER ===`nDu bist im Nichts verschwunden.`nTippe 'load' um fortzufahren."; CompanionContext = "adventure_scared" }
            } else {
                $result = @{ Success = $false; Message = "Void ist kein Ort. Noch nicht."; CompanionContext = "adventure_confused" }
            }
            break
        }
        "quit" {
            $result = @{ Success = $true; Message = "QUIT"; CompanionContext = "adventure_quit" }
            break
        }
        default {
            $result = @{ Success = $false; Message = "Das verstehe ich nicht. Tippe 'help' für Hilfe."; CompanionContext = "adventure_confused" }
        }
    }

    # === COMPANION AI HOOK ===
    if (Get-Command Invoke-AdventureCompanionHook -ErrorAction SilentlyContinue) {
        Invoke-AdventureCompanionHook $Cmd.Verb $Cmd.Noun $room $result
    }

    # Running gag override (show gag line instead of default context)
    if ($gag -and $gag.Triggered -and $result) {
        $result.CompanionContext = $gag.Context
    }

    # Speichere Adventure-State hoechstens einmal pro Befehl
    Save-AdventureState

    return $result
}

# === USE HANDLER ===
# World-specific use logic. Adventure-world.ps1 kann dies überschreiben/erweitern.

$script:AdvUseHandlers = @()

function Register-UseHandler([scriptblock]$Handler) {
    $script:AdvUseHandlers += $Handler
}

function Invoke-UseHandler($Item, $Target, $Room) {
    foreach ($handler in $script:AdvUseHandlers) {
        $result = & $handler $Item $Target $Room
        if ($result) { return $result }
    }
    return @{ Success = $false; Message = "Das funktioniert nicht."; CompanionContext = "adventure_blocked" }
}

# === HELP TEXT ===

function Get-AdventureHelp {
return @"
KOMMANDOS:
  go [north|south|east|west|up|down]  -- Bewege dich (oder: n,s,e,w,u,d)
  look                                -- Raumbeschreibung anzeigen
  look at [objekt]                    -- Objekt genauer betrachten
  take [objekt]                       -- Objekt aufnehmen
  drop [objekt]                       -- Objekt ablegen
  use [objekt]                        -- Objekt benutzen
  use [objekt] on [objekt]            -- Objekt auf Objekt anwenden
  talk to [npc]                       -- Mit NPC reden
  inventory  (oder: i)                -- Inventar anzeigen
  save                                -- Spiel speichern
  load                                -- Spiel laden
  score                               -- Punktestand
  hack [terminal]                     -- Terminal hacken (nur bestimmte)
  help   (oder: h, ?)                 -- Diese Hilfe
  quit   (oder: q)                    -- Adventure beenden
"@
}

# === RENDERER ===

function Show-AdventureRoom($Room) {
    $windowWidth = 70
    try { $windowWidth = $Host.UI.RawUI.WindowSize.Width } catch { $windowWidth = 70 }
    $w = [math]::Min(70, [math]::Max(40, $windowWidth - 4))
    $bot = Show-Frame $Room.Name -Width $w -Double
    Write-Host ""

    # Art
    if ($Room.Art) {
        foreach ($line in $Room.Art) {
            Write-Host "  $line" -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    # Description
    $desc = $Room.Description -split "`n"
    foreach ($d in $desc) {
        Write-Host "  $d" -ForegroundColor White
    }
    Write-Host ""

    # Exits
    if ($Room.Exits.Count -gt 0) {
        $exitStr = ($Room.Exits.Keys | ForEach-Object { $_.ToUpper() }) -join ", "
        Write-Host "  Ausgänge: $exitStr" -ForegroundColor Yellow
    }

    # Objects
    if ($Room.Objects.Count -gt 0) {
        $objStr = ($Room.Objects.Values | ForEach-Object { $_.Name }) -join ", "
        Write-Host "  Objekte:  $objStr" -ForegroundColor Green
    }

    # NPCs
    if ($Room.NPCs.Count -gt 0) {
        $npcStr = ($Room.NPCs.Values | ForEach-Object { $_.Name }) -join ", "
        Write-Host "  Personen: $npcStr" -ForegroundColor Magenta
    }

    # Oxygen warning in EVA
    if ($Room.Id -eq "eva" -and $script:AdvState.Oxygen -le 5) {
        Write-Host "  WARNUNG: Sauerstoff niedrig! $($script:AdvState.Oxygen)/10" -ForegroundColor Red
    } elseif ($Room.Id -eq "eva") {
        Write-Host "  Sauerstoff: $($script:AdvState.Oxygen)/10" -ForegroundColor Yellow
    }

    Write-Host $bot -ForegroundColor Cyan
}

} catch {
    Write-Host "[ADVENTURE ENGINE] Fehler: $_" -ForegroundColor Red
}
