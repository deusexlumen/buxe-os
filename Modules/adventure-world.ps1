# BUXE_OS v24.7 -- ADVENTURE WORLD
# Die verlorene Station Polaris. 8 Räume, Objekte, NPCs, Rätsel.

try {

# === ROOM 1: HANGAR ===
Register-Room "hangar" "HANGAR BAY 7" `
"Du stehst in einem riesigen Hangar. Die Luke zur Station ist offen, aber das Shuttle hinter dir ist nicht mehr startklar. Rostige Gerüste und defekte Droiden liegen herum. Ein rotes Notlicht blinkt an der Decke." `
@{ north = "corridor"; east = "storage" } `
(@{
    card = @{ Name = "Zugangskarte"; Description = "Eine magnetische ID-Karte mit dem Logo der Polaris-Station. Sie sieht wichtig aus."; Takeable = $true; UseWith = "lock" }
    scrap = @{ Name = "Metallschrott"; Description = "Rostige Metallteile von einem alten Droiden. Nutzlos. Oder doch nicht?"; Takeable = $true; UseWith = $null }
}) `
(@{
    drone = @{ Name = "Wächter-Droide"; Description = "Ein kaputter Wächter-Droide. Seine Optik flackert schwach."; Dialog = @("Fehler... System... 47%...", "Warnung: Atmosphäre instabil.", "Bitte... öl mich...") }
}) `
@(
    "    __|__",
    "  /       \",
    " |  () ()  |",
    " |    <>   |",
    "  \\_______/"
) "adventure_hangar"

# === ROOM 2: CORRIDOR ===
Register-Room "corridor" "HAUPTKORRIDOR" `
"Ein langer, schwach beleuchteter Korridor. An den Wänden hängen zerrissene Poster der Polaris-Crew. Ein Terminal an der Wand zeigt einen Fehlercode. Im Norden ist eine verschlossene Tür mit einem Kartenleser. Im Westen hört man leises Summen." `
@{ south = "hangar"; west = "lab" } `
(@{
    poster = @{ Name = "Crew-Poster"; Description = "Das Poster zeigt die Crew der Polaris. Alle haben ein 'X' über dem Gesicht. Gruselig."; Takeable = $false; UseWith = $null }
    terminal = @{ Name = "Terminal"; Description = "Ein altes Terminal mit einem blinkenden Cursor. Es zeigt: 'ZUGANG VERWEIGERT. KARTE ERFORDERLICH.'"; Takeable = $false; UseWith = "card" }
}) `
(@{}) `
@(
    "  |=======|",
    "  |  ...  |",
    "  |  ...  |",
    "  |_______|",
    "  [LOCKED]"
) "adventure_corridor"

# === ROOM 3: STORAGE ===
Register-Room "storage" "LAGERRAUM" `
"Ein chaotischer Lagerraum voller Kisten und Vorräte. Die meisten Behälter sind geöffnet und leer. Auf einem Tisch liegt ein komischer Gegenstand, der aussieht wie eine Batterie. Eine Leiter führt nach oben in einen Schacht." `
@{ west = "hangar"; up = "vent" } `
(@{
    battery = @{ Name = "Plasma-Batterie"; Description = "Eine hochenergetische Plasma-Batterie. Sie summt leise in deiner Hand."; Takeable = $true; UseWith = "generator" }
    box = @{ Name = "Kiste"; Description = "Eine verschlossene Kiste. Du brauchst etwas, um sie zu öffnen."; Takeable = $false; UseWith = "crowbar" }
}) `
(@{}) `
@(
    "  [####] [####]",
    "  [####] [####]",
    "     [TABLE]",
    "       [==]",
    "        ||"
) "adventure_storage"

# === ROOM 4: LAB ===
Register-Room "lab" "FORSCHUNGSLABOR" `
"Das Labor riecht nach Chemikalien. Zerbrochene Reagenzgläser liegen auf dem Boden. An der Wand ein Whiteboard mit einer halb gelöschten Formel. In der Ecke steht ein Notizbuch. Im Osten geht es zurück in den Korridor." `
@{ east = "corridor" } `
(@{
    notebook = @{ Name = "Notizbuch"; Description = "Dr. Vance' Notizbuch: 'Das Signal kommt aus dem Nebel. Es... spricht. Wir sollten nicht zuhören.' Die letzte Seite ist mit Blut befleckt."; Takeable = $true; UseWith = $null }
    formula = @{ Name = "Formel"; Description = "E = mc²... und darunter etwas Unleserliches in einer Sprache, die du nicht kennst."; Takeable = $false; UseWith = $null }
    crowbar = @{ Name = "Brecheisen"; Description = "Ein schweres Brecheisen. Gut für Kisten und Köpfe."; Takeable = $true; UseWith = "box" }
}) `
(@{
    scientist = @{ Name = "Hologramm"; Description = "Ein flackerndes Hologramm eines Wissenschaftlers."; Dialog = @("Das Signal... es ändert die Realität...", "Wir waren so naiv. So verdammt naiv.", "Lauf. Lauf, solange du noch kannst.") }
}) `
@(
    "    [∞]  [∞]",
    "    [∞]  [∞]",
    "  [===========]",
    "      LAB",
    "   ...DANGER..."
) "adventure_lab"

# === ROOM 5: VENT ===
Register-Room "vent" "LÜFTUNGSSCHACHT" `
"Ein enger, staubiger Lüftungsschacht. Du hörst seltsame Geräusche aus der Tiefe. Das Metall gibt unter deinem Gewicht nach. Unten siehst du den Lagerraum. Im Osten wird der Schacht heller." `
@{ down = "storage"; east = "secret" } `
(@{
    dust = @{ Name = "Staub"; Description = "Nur Staub. Warum schaust du dir Staub an?"; Takeable = $false; UseWith = $null }
}) `
(@{}) `
@(
    "  /     \\",
    " /       \\",
    " |   o    |",
    " |        |",
    "  \\______/"
) "adventure_vent"

# === ROOM 6: SECRET ===
Register-Room "secret" "GEHEIMER RAUM" `
"Ein kleiner, versteckter Raum hinter einem lockereren Gitter. Hier hat jemand gelebt. Eine Schlafmatte, leere Dosen, und an der Wand... Hunderte von Notizen. Alle sagen dasselbe: 'SIE SIEHT UNS.' Im Westen geht es zurück in den Schacht." `
@{ west = "vent" } `
(@{
    notes = @{ Name = "Notizen"; Description = "Jede Notize sagt 'SIE SIEHT UNS.' Die Handschrift wird immer wilder. Die letzte ist in... Blut?"; Takeable = $false; UseWith = $null }
    key = @{ Name = "Goldener Schlüssel"; Description = "Ein schwerer goldener Schlüssel mit seltsamen Symbolen. Er fühlt sich warm an."; Takeable = $true; UseWith = "chest" }
}) `
(@{}) `
@(
    "  SEE",
    " SHE",
    "  SEES",
    "   US",
    "  ...."
) "adventure_secret"

# === ROOM 7: BRIDGE (LOCKED) ===
Register-Room "bridge" "KOMMANDOBRÜCKE" `
"Die Kommandobrücke der Polaris. Große Fenster zeigen den ewigen Nebel des Alls. Die Kapitänsliege ist leer, aber noch warm. Auf dem Hauptbildschirm blinkt ein Signal: 'HILFE. KOORDINATEN: 7-7-7.' Ein Schrank steht an der Wand." `
@{ south = "corridor" } `
(@{
    screen = @{ Name = "Bildschirm"; Description = "Das Signal wiederholt sich: 'HILFE. KOORDINATEN: 7-7-7. WIR WARTEN.' Wer wartet?"; Takeable = $false; UseWith = $null }
    chest = @{ Name = "Schrank"; Description = "Ein verschlossener Metallschrank. Er braucht einen speziellen Schlüssel."; Takeable = $false; UseWith = "key" }
    uniform = @{ Name = "Kapitäns-Uniform"; Description = "Die Uniform von Kapitän Vance. Sie riecht nach Weltraum und Verrat."; Takeable = $true; UseWith = $null }
}) `
(@{
    captain = @{ Name = "Kapitän Vance"; Description = "Kapitän Vance sitzt reglos in der Kapitänsliege. Er atmet nicht. Aber seine Augen... folgen dir."; Dialog = @("Du bist gekommen... wie im Traum.", "Die Station wartet auf dich. Sie wartet seit Jahren.", "Nimm den Schlüssel. Öffne das Tor. Finde sie.") }
}) `
@(
    "    *  .  *",
    "  *  NEBEL  *",
    "    *  .  *",
    "  [BRIDGE]",
    "  ...HILFE..."
) "adventure_bridge"

# === ROOM 8: CAFETERIA ===
Register-Room "cafeteria" "KANTINE" `
"Die Kantine ist verlassen. Tassen stehen noch auf den Tischen, als hätte jeder einfach aufgehört zu existieren. Ein Kaffeeautomat summt noch. An der Tür ein Schild: 'Heute: Weltraum-Hähnchen.'" `
@{ north = "hangar" } `
(@{
    cup = @{ Name = "Tasse"; Description = "Eine halbvolle Tasse kalten Kaffees. Wer auch immer das war, er ist nie zurückgekommen."; Takeable = $true; UseWith = $null }
    sign = @{ Name = "Speiseplan"; Description = "Montag: Nudeln. Dienstag: Nudeln. Mittwoch: Weltraum-Hähnchen. Donnerstag: Nudeln. Die Routine war realer als das Monster."; Takeable = $false; UseWith = $null }
}) `
(@{}) `
@(
    "  [CUP]  [CUP]",
    "  [CUP]  [CUP]",
    "   [COFFEE]",
    "    [====]",
    "   CAFETERIA"
) "adventure_cafeteria"

# Add cafeteria to hangar exits
$script:AdvRooms["hangar"].Exits["west"] = "cafeteria"
$script:AdvRooms["cafeteria"].Exits["north"] = "hangar"

# === USE HANDLERS (World-specific logic) ===

Register-UseHandler {
    param($Item, $Target, $Room)

    # Card on terminal in corridor -> unlock bridge
    if ($Item -eq "card" -and $Room.Id -eq "corridor") {
        if (Has-Item "card") {
            $script:AdvState.Flags["bridge_unlocked"] = $true
            $script:AdvRooms["corridor"].Exits["north"] = "bridge"
            $script:AdvState.Score += 15
            Save-AdventureState
            return @{ Success = $true; Message = "Du steckst die Karte in den Leser. Die Tür zur Brücke öffnet sich mit einem Zischen."; CompanionContext = "adventure_unlock" }
        }
    }

    # Crowbar on box in storage
    if ($Item -eq "crowbar" -and $Target -eq "box" -and $Room.Id -eq "storage") {
        if (Has-Item "crowbar") {
            $script:AdvState.Flags["box_opened"] = $true
            $script:AdvRooms["storage"].Objects["map"] = @{ Name = "Sternenkarte"; Description = "Eine Karte der Region. Die Polaris ist markiert - und ein großes rotes X im Nebel-Sektor 7."; Takeable = $true; UseWith = $null }
            $script:AdvState.Score += 10
            Save-AdventureState
            return @{ Success = $true; Message = "Du hebelst die Kiste auf. Darin liegt eine Sternenkarte!"; CompanionContext = "adventure_unlock" }
        }
    }

    # Battery on generator (hidden in bridge)
    if ($Item -eq "battery" -and $Target -eq "generator") {
        return @{ Success = $false; Message = "Hier gibt es keinen Generator."; CompanionContext = "adventure_blocked" }
    }

    # Key on chest in bridge
    if ($Item -eq "key" -and $Target -eq "chest" -and $Room.Id -eq "bridge") {
        if (Has-Item "key") {
            $script:AdvState.Flags["chest_opened"] = $true
            $script:AdvState.Score += 25
            $script:AdvRooms["bridge"].Objects["artifact"] = @{ Name = "Polaris-Artefakt"; Description = "Ein schwebender Kristall, der ein sanftes blaues Licht ausstrahlt. Das Signal... kommt von HIER."; Takeable = $true; UseWith = $null }
            Save-AdventureState
            return @{ Success = $true; Message = "Der Schlüssel dreht sich mit einem Klicken. Der Schrank öffnet sich. Ein Artefakt schwebt darin!"; CompanionContext = "adventure_bigwin" }
        }
    }

    # Notebook read
    if ($Item -eq "notebook" -and -not $Target) {
        if (Has-Item "notebook") {
            return @{ Success = $true; Message = "Du blätterst im Notizbuch: 'Das Signal kommt aus dem Nebel. Es... spricht. Wir sollten nicht zuhören.' Die letzte Seite ist mit Blut befleckt."; CompanionContext = "adventure_examine" }
        }
    }

    # Artifact use (endgame)
    if ($Item -eq "artifact" -and -not $Target) {
        if (Has-Item "artifact") {
            $script:AdvState.Flags["game_won"] = $true
            $script:AdvState.Score += 50
            Save-AdventureState
            return @{ Success = $true; Message = "Du berührst das Artefakt. Die Welt verschwimmt... und du verstehst. Die Station war nie verloren. Sie wartete. Auf DICH.`n`n=== DAS ENDE ===`nPunkte: $($script:AdvState.Score) / $($script:AdvState.MaxScore)`nZüge: $($script:AdvState.Moves)`nDanke fürs Spielen!"; CompanionContext = "adventure_victory" }
        }
    }

    return $null
}

# === COMPANION LINES FOR ADVENTURE ===
# Extended in pet/_ui.ps1 if desired; fallback handled by Show-GameCompanionComment

} catch {
    Write-Host "[ADVENTURE WORLD] Fehler: $_" -ForegroundColor Red
}
