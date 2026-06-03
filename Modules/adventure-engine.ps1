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
        MaxScore = 100
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
                return
            }
        } catch {}
    }
    $script:AdvState = Get-AdventureDefaults
}

function Save-AdventureState {
    if (-not (Test-Path $script:BuxeStateDir)) {
        New-Item -ItemType Directory -Path $script:BuxeStateDir -Force | Out-Null
    }
    $tmp = "$script:AdvSaveFile.tmp"
    $script:AdvState | ConvertTo-Json -Depth 10 | Set-Content $tmp -Force
    Move-Item $tmp $script:AdvSaveFile -Force
}

function Reset-AdventureState {
    $script:AdvState = Get-AdventureDefaults
    Save-AdventureState
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
        Save-AdventureState
        return $true
    }
    return $false
}

function Remove-FromInventory($ItemId) {
    $script:AdvState.Inventory = @($script:AdvState.Inventory | Where-Object { $_ -ne $ItemId })
    Save-AdventureState
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
    }
    if ($verbMap[$verb]) { $verb = $verbMap[$verb] }

    return @{ Verb = $verb; Noun = $noun; Target = $target; Raw = $line }
}

# === COMMAND PROCESSOR ===

function Process-AdventureCommand($Cmd) {
    $room = Get-Room $script:AdvState.CurrentRoom
    $script:AdvState.Moves++

    switch ($Cmd.Verb) {
        "go" {
            if (-not $room.Exits[$Cmd.Noun]) {
                return @{ Success = $false; Message = "Du kannst nicht nach $($Cmd.Noun) gehen."; CompanionContext = "adventure_blocked" }
            }
            $script:AdvState.CurrentRoom = $room.Exits[$Cmd.Noun]
            if ($script:AdvState.Visited -notcontains $script:AdvState.CurrentRoom) {
                $script:AdvState.Visited += $script:AdvState.CurrentRoom
                $script:AdvState.Score += 5
            }
            Save-AdventureState
            $newRoom = Get-Room $script:AdvState.CurrentRoom
            return @{ Success = $true; Message = $null; RoomChanged = $true; CompanionContext = $newRoom.CompanionContext }
        }
        "look" {
            return @{ Success = $true; Message = $room.Description; CompanionContext = "adventure_look" }
        }
        "examine" {
            # Check objects
            if ($room.Objects[$Cmd.Noun]) {
                return @{ Success = $true; Message = $room.Objects[$Cmd.Noun].Description; CompanionContext = "adventure_examine" }
            }
            # Check NPCs
            if ($room.NPCs[$Cmd.Noun]) {
                return @{ Success = $true; Message = $room.NPCs[$Cmd.Noun].Description; CompanionContext = "adventure_examine" }
            }
            # Check inventory
            if (Has-Item $Cmd.Noun) {
                foreach ($r in $script:AdvRooms.Values) {
                    if ($r.Objects[$Cmd.Noun]) { return @{ Success = $true; Message = $r.Objects[$Cmd.Noun].Description; CompanionContext = "adventure_examine" } }
                }
            }
            return @{ Success = $false; Message = "Das siehst du hier nicht."; CompanionContext = "adventure_confused" }
        }
        "take" {
            if (-not $room.Objects[$Cmd.Noun]) {
                return @{ Success = $false; Message = "Das gibt es hier nicht."; CompanionContext = "adventure_confused" }
            }
            $obj = $room.Objects[$Cmd.Noun]
            if (-not $obj.Takeable) {
                return @{ Success = $false; Message = "Das kannst du nicht mitnehmen."; CompanionContext = "adventure_blocked" }
            }
            if (Add-ToInventory $Cmd.Noun $obj.Name) {
                $room.Objects.Remove($Cmd.Noun)
                Save-AdventureState
                return @{ Success = $true; Message = "Du nimmst $($obj.Name)."; CompanionContext = "adventure_take" }
            }
            return @{ Success = $false; Message = "Du hast das schon."; CompanionContext = "adventure_confused" }
        }
        "drop" {
            if (-not (Has-Item $Cmd.Noun)) {
                return @{ Success = $false; Message = "Das hast du nicht."; CompanionContext = "adventure_confused" }
            }
            # Find object definition
            $objDef = $null
            foreach ($r in $script:AdvRooms.Values) {
                if ($r.Objects[$Cmd.Noun]) { $objDef = $r.Objects[$Cmd.Noun]; break }
            }
            if (-not $objDef) {
                # Reconstruct from backup in world definition
                $objDef = @{ Name = $Cmd.Noun; Description = "Ein $Cmd.Noun."; Takeable = $true }
            }
            $room.Objects[$Cmd.Noun] = $objDef
            Remove-FromInventory $Cmd.Noun
            return @{ Success = $true; Message = "Du legst $($objDef.Name) hin."; CompanionContext = "adventure_drop" }
        }
        "use" {
            return Invoke-UseHandler $Cmd.Noun $Cmd.Target $room
        }
        "talk" {
            if (-not $room.NPCs[$Cmd.Noun]) {
                return @{ Success = $false; Message = "Mit wem willst du reden?"; CompanionContext = "adventure_confused" }
            }
            $npc = $room.NPCs[$Cmd.Noun]
            $dialog = $npc.Dialog | Get-Random
            return @{ Success = $true; Message = "$($npc.Name): `"$dialog`""; CompanionContext = "adventure_talk" }
        }
        "inventory" {
            return @{ Success = $true; Message = (Show-Inventory); CompanionContext = "adventure_inventory" }
        }
        "help" {
            return @{ Success = $true; Message = (Get-AdventureHelp); CompanionContext = "adventure_help" }
        }
        "save" {
            Save-AdventureState
            return @{ Success = $true; Message = "Spiel gespeichert."; CompanionContext = "adventure_save" }
        }
        "load" {
            Load-AdventureState
            return @{ Success = $true; Message = "Spiel geladen."; CompanionContext = "adventure_load" }
        }
        "score" {
            return @{ Success = $true; Message = "Punkte: $($script:AdvState.Score) / $($script:AdvState.MaxScore) | Züge: $($script:AdvState.Moves) | Entdeckt: $($script:AdvState.Visited.Count) / $($script:AdvRooms.Count) Räume"; CompanionContext = "adventure_score" }
        }
        "quit" {
            return @{ Success = $true; Message = "QUIT"; CompanionContext = "adventure_quit" }
        }
        default {
            return @{ Success = $false; Message = "Das verstehe ich nicht. Tippe 'help' für Hilfe."; CompanionContext = "adventure_confused" }
        }
    }
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
  help   (oder: h, ?)                 -- Diese Hilfe
  quit   (oder: q)                    -- Adventure beenden
"@
}

# === RENDERER ===

function Show-AdventureRoom($Room) {
    $w = [math]::Min(70, $Host.UI.RawUI.WindowSize.Width - 4)
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

    Write-Host $bot -ForegroundColor Cyan
}

} catch {
    Write-Host "[ADVENTURE ENGINE] Fehler: $_" -ForegroundColor Red
}
