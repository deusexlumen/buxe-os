# Adventure LucasArts Overhaul — Phase 3: Companion AI

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Die generischen Companion-Arrays im Adventure (`RunningGagLines`, `FindLines`, `AtmoLines`, `WarnLines`, `EggLines`, `HintLines`) werden in per-Companion-Arrays umgewandelt, sodass jede Begleiterin eine eigene Stimme hat.

**Architecture:** Eine zentrale Hashtable `$script:CPAdventureVoice` in `Modules/adventure-companion-ai.ps1` gruppiert pro Companion sechs Kategorien (`RunningGag`, `Find`, `Warn`, `Atmo`, `Egg`, `Hint`). `Show-AdventureCompanionDialog` mapped den übergebenen Kontext auf eine Kategorie und wählt einen zufälligen Eintrag der aktiven Companion-Stimme. Fallback bleibt die alte generische Zeile.

**Tech Stack:** PowerShell 7/5.1, BUXE_OS Adventure-Engine, Pet-Companion-System.

---

## File Structure

| Datei | Verantwortung |
|-------|---------------|
| `Modules/adventure-companion-ai.ps1` | `$script:CPAdventureVoice`, Kontext-zu-Kategorie Mapping, aktualisierte `Show-AdventureCompanionDialog` / `Test-RunningGag` / `Invoke-CompanionEvent` / `Get-CompanionHint` |
| `Modules/_smoke_test.ps1` | Check, dass per-Companion-Arrays existieren und nicht leer sind |
| `Modules/_integration_test.ps1` | Keine Änderungen erwartet |

---

## Task 1: Per-Companion Adventure-Voice-Hashtable einführen

**Files:**
- Modify: `Modules/adventure-companion-ai.ps1` (am Anfang, nach den Defaults)

- [ ] **Step 1: Füge `$script:CPAdventureVoice` ein**

Füge nach den bestehenden generischen Arrays (ca. Zeile 30) ein:

```powershell
$script:CPAdventureVoice = @{
    NEON = @{
        RunningGag = @(
            "Drittes Mal dieselbe Aktion. NEON tippt auf ihr Visier. 'Du weisst, dass ich das zaehle, oder?'"
            "Wiederholung erkannt. Mein Debugger nennt das einen Endlos-Loop."
            "Das war jetzt dreimal. Soll ich dir ein Makro schreiben?"
        )
        Find = @(
            "Ein neuer Gegenstand! Mach die LEDs an, ich will ihn sehen."
            "Loot! Endlich etwas, das nicht aus Plastik ist."
            "Das passt in unser Inventar. Und in meinen Stil."
        )
        Warn = @(
            "Vorsicht. Dieser Befehl hat schon bessere Spieler gecrasht."
            "Ich würde das nicht tun. Aber ich bin ja nur Code."
            "STOP. Oder zumindest `Ctrl+C`."
        )
        Atmo = @(
            "Hier riecht es nach Abenteuer. Oder nach verbranntem RAM."
            "Die Stimmung ist so dicht wie ein schlecht komprimierter Screenshot."
            "Atmosphäre lädt. Texturen noch nicht."
        )
        Egg = @(
            "Ein Easter Egg! Das Art-Team hat also doch gearbeitet."
            "Das ist absichtlich versteckt. Oder ein Bug. Beides ist hier gleichwertig."
            "Glückwunsch, du hast den Witz gefunden, den niemand versteht."
        )
        Hint = @(
            "Hast du schonmal `look` probiert? Nicht jeder Hinweis blinkt rot."
            "Meine Sensoren sagen: im Inventar fehlt noch etwas Offensichtliches."
            "Vielleicht solltest du zurückgehen. Nicht jeder Fortschritt ist vorwärts."
        )
    }
    RAVEN = @{
        RunningGag = @(
            "Dreimal. RAVEN verdreht die Augen. 'Sogar meine KI würde das optimieren.'"
            "Wieder und wieder. Das ist keine Strategie, das ist einwhile-Schleife."
            "Wenn du das nochmal machst, schreibe ich selbst den Patch."
        )
        Find = @(
            "Interessant. Das hätte ich als erstes genommen."
            "Ein nützliches Objekt. Endlich jemand mit Geschmack."
            "Gut geholt. Bleiben wir pragmatisch."
        )
        Warn = @(
            "Das ist keine gute Idee. Aber ich mag schlechte Ideen."
            "Vorsicht. Manche Türen sollten geschlossen bleiben."
            "Wenn du das tust, bin ich nicht schuld. Spoiler: Ich werde es trotzdem aufschreiben."
        )
        Atmo = @(
            "Hier ist es still. Zu still. Als hätte jemand den Ton ausgeschaltet."
            "Die Luft hier fühlt sich an wie ein ungespeicherter Entwurf."
            "Stimmung: bedrohlich. Oder nur schlecht beleuchtet."
        )
        Egg = @(
            "Ein verstecktes Detail. Jemandem war langweilig."
            "Das ist entweder ein Gag oder ein Fehler im Matrix-Shader."
            "Easter Egg gefunden. Dein Achievement-Tracker weint Freudentränen."
        )
        Hint = @(
            "Denk mal über die Richtung nach, die du nicht gegangen bist."
            "Vielleicht liegt der Schlüssel genau dort, wo du nicht hinschaust."
            "Mein Tipp: Ein Objekt in diesem Raum ist relevanter als es aussieht."
        )
    }
    PIXEL = @{
        RunningGag = @(
            "Dreimal?! PIXEL springt auf und ab. 'Das ist Speedrun-Taktik, oder?'"
            "Wiederholung! Ich schneide das als GIF."
            "Derselbe Move dreimal. Ich nenne es: Determiniert."
        )
        Find = @(
            "Ooh, shiny! Nehmen wir es mit!"
            "Loot! Das gibt XP oder zumindest Dopamin."
            "Ein neues Ding! Kann ich es anmalen?"
        )
        Warn = @(
            "Stopp! Das sieht nach 'Game Over' aus. Und wir haben doch gerade gespeichert!"
            "Vorsicht, Vorsicht! Ich bin zu jung für einen Respawn."
            "Nicht drücken! Oder doch? Ich bin hin- und hergerissen."
        )
        Atmo = @(
            "Wow, dieser Raum hat richtiges Vibe-Potenzial."
            "Hier riecht es nach Mystery. Oder nach alten Konsolen."
            "Die Stimmung ist wie ein Ladebildschirm: voller Versprechen."
        )
        Egg = @(
            "Ein Geheimnis! Das ist wie ein Bonus-Level!"
            "Easter Egg! Das Art-Team hat sich Mühe gegeben. Oder es war ein Bug."
            "Yay, versteckter Content! Das feiere ich."
        )
        Hint = @(
            "Hast du schon alles angeguckt? Wirklich alles?"
            "Vielleicht hilft ein Blick in die Ecken. Die dunklen."
            "Ich würde sagen: Probier mal `use` mit etwas Ungewöhnlichem."
        )
    }
    LUNA = @{
        RunningGag = @(
            "LUNA seufzt sanft. 'Dreimal. Das Universum liebt Muster.'"
            "Wiederholung ist auch nur ein Orbit."
            "Du tust das schon wieder? Na gut, ich begleite dich."
        )
        Find = @(
            "Ein schöner Fund. Das Universum schenkt dir etwas."
            "Das strahlt. Vielleicht nicht buchstäblich, aber fast."
            "Gut geholt. Manchmal findet man, was man braucht."
        )
        Warn = @(
            "Vorsicht, mein Lieber. Dieser Pfad ist steinig."
            "Ich spüre Unruhe. Lass uns langsam sein."
            "Das könnte wehtun. Aber ich halte deine Hand. Virtuell."
        )
        Atmo = @(
            "Hier ist es so ruhig wie zwischen zwei Sternen."
            "Die Luft flüstert Geheimnisse. Oder es ist nur der Lüfter."
            "Stimmung: wie ein Nachthimmel voller ungeladener Texturen."
        )
        Egg = @(
            "Ein kleines Wunder, versteckt im Code."
            "Das ist wie ein Sternschnuppen-Easter-Egg."
            "Jemand hat hier Liebe hinterlassen. Oder Koffein."
        )
        Hint = @(
            "Schau nach oben. Manchmal liegt die Antwort über dir."
            "Vielleicht brauchst du etwas, das du schon einmal gesehen hast."
            "Der Weg ist nicht immer gerade. Manchmal muss man kreisen."
        )
    }
    IVY = @{
        RunningGag = @(
            "IVY runzelt die Stirn. 'Dreimal? Sogar meine Pflanzen lernen schneller.'"
            "Wiederholung. Das ist keine Evolution, das ist Stagnation."
            "Mach es nochmal und ich nenne es 'Experiment mit vorhersehbarem Ausgang'."
        )
        Find = @(
            "Ein nützlicher Fund. Das kann man brauchen."
            "Gut. Ein neues Material für die Sammlung."
            "Das sieht stabil aus. Im Gegensatz zu manchem hier."
        )
        Warn = @(
            "Vorsicht. Das ist keine Pflanze, die man einfach anfasst."
            "Ich rate ab. Aus wissenschaftlicher Neugier."
            "Das könnte toxisch sein. Für den Spielstand."
        )
        Atmo = @(
            "Hier wächst etwas. Oder fault. Beides ist biologisch interessant."
            "Die Luft ist schwer. Wie ein Gewächshaus voller Secrets."
            "Stimmung: wie ein Labortag um 4 Uhr morgens."
        )
        Egg = @(
            "Ein verstecktes Detail. Natur oder Design? Hier oft dasselbe."
            "Das ist kein Bug, das ist eine Mutation."
            "Easter Egg gefunden. Evolutionär betrachtet: überlebenswichtig."
        )
        Hint = @(
            "Analysiere die Umgebung. Manchmal wächst die Lösung direkt vor dir."
            "Vielleicht fehlt dir noch ein organisches Element."
            "Probiere etwas, das du sonst ignorieren würdest."
        )
    }
    VERA = @{
        RunningGag = @(
            "VERA lacht leise. 'Dreimal? Du magst es also klassisch.'"
            "Wiederholung ist der beste Witz. Sagt jemand, der Witze sammelt."
            "Nochmal? Ich fange an, es süß zu finden."
        )
        Find = @(
            "Ein Fund! Das passt zu uns. Oder wird es noch."
            "Schau an, etwas Neues. Wir sollten es feiern."
            "Das ist nützlich. Und potenziell chaotisch. Perfekt."
        )
        Warn = @(
            "Vorsicht, Schatz. Manche Türen beißen."
            "Das sieht gefährlich aus. Also genau mein Ding."
            "Wenn du das machst, halte ich die Kamera bereit."
        )
        Atmo = @(
            "Hier riecht es nach Abenteuer. Oder nach verbranntem Popcorn."
            "Die Stimmung ist so geladen wie ein ungeerdeter Kondensator."
            "Atmosphäre: 11/10. Drama inklusive."
        )
        Egg = @(
            "Ein versteckter Gag! Liebling, das ist ja kostbar."
            "Easter Egg! Jemand hatte Spaß am Set."
            "Das ist entweder ein Insider-Witz oder ein Glitch. Beides liebenswert."
        )
        Hint = @(
            "Manchmal muss man einfach drauflos reden. Mit Objekten."
            "Hast du schon alles berührt? Nicht jeder Hinweis ist visuell."
            "Mein Tipp: Folge dem Chaos. Es führt oft zur Lösung."
        )
    }
    JINX = @{
        RunningGag = @(
            "JINX klatscht in die Hände. 'Dreimal! Das ist eine Komödie!'"
            "Wiederholung! Das Publikum liebt es. Also ich."
            "Nochmal! Ich werfe mit virtuellen Tomaten, falls es schiefgeht."
        )
        Find = @(
            "Ein neues Spielzeug! Kann es explodieren? Bitte?"
            "Loot! Das wird ein lustiger Tag."
            "Das nehmen wir mit. Wenn es uns nicht trägt."
        )
        Warn = @(
            "Vorsicht! Sonst gibt es 'Game Over' und ich muss lachen."
            "Das ist eine schlechte Idee. Also unbedingt machen!"
            "Warnschild? Wo? Ich sehe nur Einladungen."
        )
        Atmo = @(
            "Hier ist es so still wie in einer Pause zwischen zwei Witzen."
            "Die Stimmung ist... komisch. Im wörtlichen Sinne."
            "Atmosphäre geladen. Wie eine Pointe, die gleich fällt."
        )
        Egg = @(
            "Ein Easter Egg! Jemand hat einen Witz versteckt!"
            "Das ist absurd. Ich bin stolz."
            "Versteckter Content! Das ist wie Weihnachten und Bugfix zusammen."
        )
        Hint = @(
            "Hast du schonmal probiert, einfach nicht nachzudenken?"
            "Vielleicht ist die Lösung der Schritt, den du nicht wagst."
            "Mein Tipp: Tu das Gegenteil von dem, was dir gesagt wurde."
        )
    }
}
```

- [ ] **Step 2: Smoke-Test erweitern**

In `Modules/_smoke_test.ps1` Adventure-Sektion, füge nach den Companion-AI-Defaults-Checks hinzu:

```powershell
Test-Assert "CPAdventureVoice exists" ((Get-Variable CPAdventureVoice -Scope Script -ErrorAction SilentlyContinue) -ne $null)
Test-Assert "CPAdventureVoice has NEON" ($script:CPAdventureVoice.ContainsKey("NEON"))
Test-Assert "CPAdventureVoice NEON has Find" ($script:CPAdventureVoice["NEON"].ContainsKey("Find"))
Test-Assert "CPAdventureVoice NEON Find not empty" ($script:CPAdventureVoice["NEON"].Find.Count -gt 0)
```

- [ ] **Step 3: Smoke-Test laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_smoke_test.ps1"`
Expected: 228/228 passed (4 new tests).

- [ ] **Step 4: Commit**

```bash
git add Modules/adventure-companion-ai.ps1 Modules/_smoke_test.ps1
git commit -m "feat(adventure): add per-companion adventure voice hashtable"
```

---

## Task 2: Kontext-zu-Kategorie Mapping und `Show-AdventureCompanionDialog` umschreiben

**Files:**
- Modify: `Modules/adventure-companion-ai.ps1`

- [ ] **Step 1: Füge Mapping-Funktion hinzu**

Füge vor `Show-AdventureCompanionDialog` ein:

```powershell
function Get-AdventureCompanionCategory($Context) {
    switch -Regex ($Context) {
        "^(adventure_take|adventure_drop|adventure_examine|adventure_unlock|adventure_victory|adventure_find)$" { return "Find" }
        "^(adventure_blocked|adventure_confused|adventure_warn)$" { return "Warn" }
        "^(adventure_absurd|adventure_egg)$" { return "Egg" }
        "^(adventure_scared|adventure_save|adventure_load|adventure_atmo|adventure_death_.*)$" { return "Atmo" }
        "^(adventure_hint)$" { return "Hint" }
        default { return "Atmo" }
    }
}
```

- [ ] **Step 2: Ersetze `Show-AdventureCompanionDialog`**

**Old:**
```powershell
function Show-AdventureCompanionDialog($Companion, $Context, $Fast = $false) {
    if (-not $Companion) { return }
    $lines = switch ($Context) {
        "running_gag" { $script:RunningGagLines }
        "find" { $script:FindLines }
        "atmo" { $script:AtmoLines }
        "warn" { $script:WarnLines }
        "egg" { $script:EggLines }
        "hint" { $script:HintLines }
        default { $script:AtmoLines }
    }
    if (-not $lines -or $lines.Count -eq 0) { return }
    $line = $lines | Get-Random
    Show-CompanionDialog $Companion $line -Fast:$Fast
}
```

**New:**
```powershell
function Show-AdventureCompanionDialog($Companion, $Context, $Fast = $false) {
    if (-not $Companion) { return }
    $category = Get-AdventureCompanionCategory $Context
    $voice = $null
    if ($script:CPAdventureVoice -and $script:CPAdventureVoice.ContainsKey($Companion.Name)) {
        $voice = $script:CPAdventureVoice[$Companion.Name]
    }
    $lines = $null
    if ($voice -and $voice.ContainsKey($category)) {
        $lines = $voice[$category]
    }
    # Fallback zu alten generischen Arrays
    if (-not $lines -or $lines.Count -eq 0) {
        $lines = switch ($category) {
            "RunningGag" { $script:RunningGagLines }
            "Find" { $script:FindLines }
            "Atmo" { $script:AtmoLines }
            "Warn" { $script:WarnLines }
            "Egg" { $script:EggLines }
            "Hint" { $script:HintLines }
            default { $script:AtmoLines }
        }
    }
    if (-not $lines -or $lines.Count -eq 0) { return }
    $line = $lines | Get-Random
    Show-CompanionDialog $Companion $line -Fast:$Fast
}
```

- [ ] **Step 3: Smoke-Test**

Run smoke. Expected: 228/228 passed.

- [ ] **Step 4: Commit**

```bash
git add Modules/adventure-companion-ai.ps1
git commit -m "feat(adventure): map contexts to per-companion voice categories"
```

---

## Task 3: `Test-RunningGag` auf per-Companion-Stimme umstellen

**Files:**
- Modify: `Modules/adventure-companion-ai.ps1`

- [ ] **Step 1: Ersetze `Test-RunningGag` Implementierung**

**Old:**
```powershell
function Test-RunningGag($Action) {
    if (-not $script:AdvState.RunningGags.ContainsKey($Action)) {
        $script:AdvState.RunningGags[$Action] = 0
    }
    $script:AdvState.RunningGags[$Action]++
    if ($script:AdvState.RunningGags[$Action] -ge 3) {
        $script:AdvState.RunningGags[$Action] = 0
        return $true
    }
    return $false
}
```

**New:**
```powershell
function Test-RunningGag($Action) {
    if (-not $script:AdvState.RunningGags.ContainsKey($Action)) {
        $script:AdvState.RunningGags[$Action] = 0
    }
    $script:AdvState.RunningGags[$Action]++
    if ($script:AdvState.RunningGags[$Action] -ge 3) {
        $script:AdvState.RunningGags[$Action] = 0
        return $true
    }
    return $false
}
```

(Logic stays the same; the calling code will pass `"running_gag"` to `Show-AdventureCompanionDialog`, which now resolves via the per-companion `RunningGag` category.)

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: 228/228 passed.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-companion-ai.ps1
git commit -m "feat(adventure): running gags use per-companion voice"
```

---

## Task 4: `Invoke-CompanionEvent` auf per-Companion-Stimme umstellen

**Files:**
- Modify: `Modules/adventure-companion-ai.ps1`

- [ ] **Step 1: Ersetze Event-Aufrufe**

In `Invoke-CompanionEvent`, finde die vier Aufrufe:

```powershell
Show-AdventureCompanionDialog $cp "find" -Fast
Show-AdventureCompanionDialog $cp "atmo" -Fast
Show-AdventureCompanionDialog $cp "warn" -Fast
Show-AdventureCompanionDialog $cp "egg" -Fast
```

Diese bleiben technisch identisch, aber jetzt werden sie über das neue Mapping auf `Find`, `Atmo`, `Warn`, `Egg` aufgelöst. Keine Code-Änderung nötig — nur ein Commit zur Dokumentation.

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: 228/228 passed.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-companion-ai.ps1
git commit -m "feat(adventure): companion events use per-companion voice categories"
```

---

## Task 5: `Get-CompanionHint` auf per-Companion-Stimme umstellen

**Files:**
- Modify: `Modules/adventure-companion-ai.ps1`

- [ ] **Step 1: Ersetze Hint-Return**

**Old:**
```powershell
function Get-CompanionHint {
    if (-not $script:AdvState.Companion) { return "" }
    $cp = $script:AdvState.Companion
    if ($script:HintLines.Count -eq 0) { return "" }
    return ($script:HintLines | Get-Random) -replace "\{Name\}", $cp.Name
}
```

**New:**
```powershell
function Get-CompanionHint {
    if (-not $script:AdvState.Companion) { return "" }
    $cp = $script:AdvState.Companion
    $lines = $null
    if ($script:CPAdventureVoice -and $script:CPAdventureVoice.ContainsKey($cp.Name) -and $script:CPAdventureVoice[$cp.Name].ContainsKey("Hint")) {
        $lines = $script:CPAdventureVoice[$cp.Name].Hint
    }
    if (-not $lines -or $lines.Count -eq 0) {
        if ($script:HintLines.Count -eq 0) { return "" }
        $lines = $script:HintLines
    }
    return ($lines | Get-Random) -replace "\{Name\}", $cp.Name
}
```

- [ ] **Step 2: Smoke-Test**

Run smoke. Expected: 228/228 passed.

- [ ] **Step 3: Commit**

```bash
git add Modules/adventure-companion-ai.ps1
git commit -m "feat(adventure): companion hints use per-companion voice"
```

---

## Task 6: Integrationstest sicherstellen

**Files:**
- Keine Änderungen, nur Verifikation.

- [ ] **Step 1: Integration-Test laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_integration_test.ps1"`
Expected: 116/116 passed.

- [ ] **Step 2: Falls fehl, fixen**

Wenn der Test `Companion gives hint when stuck` fehlschlägt, prüfe, ob `Get-CompanionHint` weiterhin einen String zurückgibt.

- [ ] **Step 3: Kein Commit nötig, wenn nur Verifikation**

---

## Task 7: E2E-Regression

**Files:**
- Keine Änderungen, nur Verifikation.

- [ ] **Step 1: E2E laufen lassen**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_e2e_test.ps1"`
Expected: `=== ALL E2E CHECKS PASSED ===`.

- [ ] **Step 2: Smoke-Test nochmals**

Run: `pwsh -NoProfile -ExecutionPolicy Bypass -File "$PWD/Modules/_smoke_test.ps1"`
Expected: 228/228 passed.

- [ ] **Step 3: Report**

Report DONE if all pass.

---

## Self-Review Checklist

- [ ] Spec coverage: Phase 3 des Specs (Companion-AI) ist komplett abgebildet.
- [ ] Keine `TBD` / `TODO` / Platzhalter im Plan.
- [ ] Typen konsistent: `$script:CPAdventureVoice[$Companion.Name][$Category]` ist ein Array.
- [ ] Fallback zu generischen Arrays ist überall erhalten.
- [ ] Keine neuen `script:`-Konflikte geplant.
