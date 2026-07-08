# BUXE_OS v25.0 -- EVENT BUS (KERNEL)
# In-Memory Pub/Sub. Entkoppelt Casino, Pet, ARG, Story, Quests.
# Kein Subsystem ruft ein anderes direkt auf. Alle reden nur mit dem Bus.
#
# DESIGN:
#   - Synchrone Dispatch-Phase (deterministisch, testbar)
#   - Deferred Queue fuer Events, die NACH der aktuellen Aktion feuern sollen
#     (verhindert Reentranz-Hoelle: Event-Handler, die Events feuern, die Handler feuern...)
#   - Wildcard-Topics: "casino.*" matcht "casino.jackpot", "casino.bust", ...
#   - Prioritaeten: niedrigere Zahl = frueher (Default 100)
#   - Handler-Fehler werden isoliert: ein kaputter Subscriber killt nie den Bus
#   - Dead-Letter-Log fuer Events ohne Subscriber (Debugging von Tippfehlern in Topics)

try {

$script:BuxeBus = @{
    Subscribers   = @{}   # Topic-Pattern -> @( @{ Id; Priority; Handler; Once } )
    DeferredQueue = [System.Collections.Generic.Queue[object]]::new()
    Dispatching   = $false
    DeadLetters   = [System.Collections.Generic.List[string]]::new()
    NextId        = 1
    TraceEnabled  = $false
}

function Subscribe-BuxeEvent {
    <#
    .SYNOPSIS
      Registriert einen Handler fuer ein Topic-Pattern.
    .EXAMPLE
      Subscribe-BuxeEvent -Topic "casino.jackpot" -Handler { param($e) ... }
      Subscribe-BuxeEvent -Topic "combat.*" -Priority 50 -Handler { param($e) ... }
    #>
    param(
        [Parameter(Mandatory)][string]$Topic,
        [Parameter(Mandatory)][scriptblock]$Handler,
        [int]$Priority = 100,
        [switch]$Once
    )
    if (-not $script:BuxeBus.Subscribers.ContainsKey($Topic)) {
        $script:BuxeBus.Subscribers[$Topic] = [System.Collections.Generic.List[object]]::new()
    }
    $sub = @{
        Id       = $script:BuxeBus.NextId++
        Priority = $Priority
        Handler  = $Handler
        Once     = [bool]$Once
    }
    $script:BuxeBus.Subscribers[$Topic].Add($sub)
    return $sub.Id
}

function Unsubscribe-BuxeEvent {
    param([Parameter(Mandatory)][int]$Id)
    foreach ($topic in @($script:BuxeBus.Subscribers.Keys)) {
        $list = $script:BuxeBus.Subscribers[$topic]
        for ($i = $list.Count - 1; $i -ge 0; $i--) {
            if ($list[$i].Id -eq $Id) { $list.RemoveAt($i) }
        }
    }
}

function Test-TopicMatch($Pattern, $Topic) {
    if ($Pattern -eq $Topic) { return $true }
    if ($Pattern.EndsWith(".*")) {
        $prefix = $Pattern.Substring(0, $Pattern.Length - 1) # "casino."
        return $Topic.StartsWith($prefix)
    }
    if ($Pattern -eq "*") { return $true }
    return $false
}

function Publish-BuxeEvent {
    <#
    .SYNOPSIS
      Feuert ein Event. Payload ist eine beliebige Hashtable.
    .PARAMETER Deferred
      Event landet in der Queue und wird erst via Invoke-BuxeBusFlush verarbeitet
      (typisch: am Ende einer Spielrunde / beim naechsten Prompt-Tick).
    .EXAMPLE
      Publish-BuxeEvent -Topic "casino.jackpot" -Data @{ Game = "SLOT"; Amount = 4700 }
    #>
    param(
        [Parameter(Mandatory)][string]$Topic,
        [hashtable]$Data = @{},
        [switch]$Deferred
    )
    $evt = @{
        Topic     = $Topic
        Data      = $Data
        Timestamp = Get-Date
    }

    if ($Deferred -or $script:BuxeBus.Dispatching) {
        # Reentranz-Schutz: Events aus Handlern heraus werden IMMER deferred.
        $script:BuxeBus.DeferredQueue.Enqueue($evt)
        return
    }
    Invoke-BuxeBusDispatch $evt
    Invoke-BuxeBusFlush
}

function Invoke-BuxeBusDispatch($evt) {
    $script:BuxeBus.Dispatching = $true
    try {
        $matched = [System.Collections.Generic.List[object]]::new()
        foreach ($pattern in @($script:BuxeBus.Subscribers.Keys)) {
            if (Test-TopicMatch $pattern $evt.Topic) {
                foreach ($sub in $script:BuxeBus.Subscribers[$pattern]) {
                    $matched.Add(@{ Sub = $sub; Pattern = $pattern })
                }
            }
        }
        if ($matched.Count -eq 0) {
            $script:BuxeBus.DeadLetters.Add("$($evt.Timestamp.ToString('HH:mm:ss')) $($evt.Topic)")
            if ($script:BuxeBus.DeadLetters.Count -gt 50) { $script:BuxeBus.DeadLetters.RemoveAt(0) }
            return
        }
        $ordered = $matched | Sort-Object { $_.Sub.Priority }
        $toRemove = @()
        foreach ($m in $ordered) {
            if ($script:BuxeBus.TraceEnabled) {
                Write-Host "  [BUS] $($evt.Topic) -> #$($m.Sub.Id)" -ForegroundColor DarkGray
            }
            try {
                & $m.Sub.Handler $evt
            } catch {
                Write-Warning "[Bus] Handler #$($m.Sub.Id) fuer '$($evt.Topic)' crashte: $_"
            }
            if ($m.Sub.Once) { $toRemove += $m.Sub.Id }
        }
        foreach ($id in $toRemove) { Unsubscribe-BuxeEvent -Id $id }
    } finally {
        $script:BuxeBus.Dispatching = $false
    }
}

function Invoke-BuxeBusFlush {
    <#
    .SYNOPSIS
      Verarbeitet die Deferred Queue. Wird automatisch nach Publish aufgerufen
      und sollte zusaetzlich im Prompt-Tick (World Heartbeat) laufen.
      Hard Cap gegen Endlosschleifen aus gegenseitig feuernden Handlern.
    #>
    $safety = 100
    while ($script:BuxeBus.DeferredQueue.Count -gt 0 -and $safety-- -gt 0) {
        $evt = $script:BuxeBus.DeferredQueue.Dequeue()
        Invoke-BuxeBusDispatch $evt
    }
    if ($safety -le 0) {
        Write-Warning "[Bus] Flush-Limit erreicht. Event-Sturm gekappt. Queue geleert: $($script:BuxeBus.DeferredQueue.Count) Events verworfen."
        $script:BuxeBus.DeferredQueue.Clear()
    }
}

function Show-BuxeBusDebug {
    Write-Host "`n  EVENT BUS STATUS" -ForegroundColor Cyan
    Write-Host "  Topics: $($script:BuxeBus.Subscribers.Keys.Count) | Queue: $($script:BuxeBus.DeferredQueue.Count)" -ForegroundColor Gray
    foreach ($t in $script:BuxeBus.Subscribers.Keys | Sort-Object) {
        Write-Host "    $t ($($script:BuxeBus.Subscribers[$t].Count) Handler)" -ForegroundColor DarkGray
    }
    if ($script:BuxeBus.DeadLetters.Count -gt 0) {
        Write-Host "  Dead Letters (Events ohne Subscriber):" -ForegroundColor Yellow
        $script:BuxeBus.DeadLetters | Select-Object -Last 10 | ForEach-Object {
            Write-Host "    $_" -ForegroundColor DarkYellow
        }
    }
}

} catch {
    Write-Host "[engine-bus] CRITICAL ERROR: $_" -ForegroundColor Red
}
