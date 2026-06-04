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
    skull = @{ Name = "Schädel"; Description = "Ein polierter Schädel mit einem Grinsen. Auf der Stirn steht: 'Manny Calavera war hier.'"; Takeable = $true; UseWith = $null }
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
    tree = @{ Name = "Kleiner Baum"; Description = "Ein kleiner Plastikbaum. Jemand hat ihn hier versteckt. Darauf steht: 'Ich bin ein Pirat, ich mag Baumkaetzchen.'"; Takeable = $true; UseWith = $null }
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
    rubber_chicken = @{ Name = "Gummihuhn"; Description = "Ein altes Gummihuhn mit einem Seil. Jemand hat damit an einer Schaltklinke gezogen. Wie absurd."; Takeable = $true; UseWith = $null }
    tentacle = @{ Name = "Lila Tentakel-Streifen"; Description = "Ein kleines Stueck lila Tentakel. Es zuckt noch. Jemand hat hier Experimente gemacht."; Takeable = $true; UseWith = $null }
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

# === NEW ROOMS v25.0 ===

# === ROOM 9: AIRLOCK ===
Register-Room "airlock" "LUFTSCHLEUSE" `
"Eine massive Luftschleuse mit dicken Stahltueren. Durch das Sichtfenster siehst du den schwarzen Weltraum und die verbeulte Aussenhuelle der Station. Ein Warnschild leuchtet rot: 'EVA ERfordert RAUMANZUG.' Eine Tuer fuehrt nach draussen." `
@{ up = "hangar"; west = "eva" } `
(@{
    suit = @{ Name = "Raumanzug"; Description = "Ein schwerer EVA-Raumanzug mit Sauerstofftank. Er riecht nach Schweiß und Weltraum."; Takeable = $true; UseWith = $null }
    warning = @{ Name = "Warnschild"; Description = "WARNUNG: EVA ohne Raumanzug = sofortiger Tod. Nicht metaphorisch."; Takeable = $false; UseWith = $null }
}) `
(@{}) `
@(
    "  [=======]",
    "  |  EVA  |",
    "  | VACUUM|",
    "  [=======]",
    "   [SUIT]"
) "adventure_airlock"

# Connect airlock to hangar
$script:AdvRooms["hangar"].Exits["down"] = "airlock"

# === ROOM 10: EVA ===
Register-Room "eva" "AUSSENBEREICH" `
"Du schwebst im Nichts. Die Polaris erstreckt sich ueber dir wie ein riesiges Metallgebirge. Sterne umgeben dich. In der Ferne siehst du ein seltsames Leuchten im Nebel. Ein Kabel fuehrt zurueck zur Luftschleuse." `
@{ east = "airlock" } `
(@{
    cable = @{ Name = "Sicherheitskabel"; Description = "Ein dickes Stahlseil, das dich mit der Station verbindet. Dein einziger Weg zurueck."; Takeable = $false; UseWith = $null }
    debris = @{ Name = "Truemmer"; Description = "Metallplatten und Kabel, die von der Station abgebrochen sind. Darunter... ein Datenkern?"; Takeable = $false; UseWith = "suit" }
}) `
(@{}) `
@(
    "    *  .  *",
    "  * STATION *",
    "    *  .  *",
    "  [CABLE]--->",
    "  ...VOID..."
) "adventure_eva"

# === ROOM 11: ENGINE ===
Register-Room "engine" "MASCHINENRAUM" `
"Der Maschinenraum droehnt. Ein riesiger Reaktor pulsiert in der Mitte des Raums, aber sein Licht flackert unregelmaessig. Konsole blinken rot. Der Boden ist heiss. Im Norden ist eine schwere Tuere mit dem Schild 'REAKTOR-KERN'." `
@{ up = "corridor"; north = "core" } `
(@{
    reactor = @{ Name = "Reaktor"; Description = "Der Hauptreaktor der Polaris. Er flackert. Die Stabilitaetsanzeige zeigt 47%."; Takeable = $false; UseWith = "battery" }
    console = @{ Name = "Kontrollkonsole"; Description = "Eine blinkende Konsole mit Warnmeldungen. 'STABILISIERUNG ERFORDERLICH.'"; Takeable = $false; UseWith = $null }
}) `
(@{
    engineer = @{ Name = "Hologramm-Ingenieur"; Description = "Ein flackerndes Hologramm eines Ingenieurs. Er wirkt gestresst."; Dialog = @("Der Reaktor... er braucht Energie.", "Die Batterie aus dem Lager. Die passt.", "Beeil dich. Wir haben nicht viel Zeit.") }
}) `
@(
    "    [###]",
    "    [#R#]",
    "  [=======]",
    "   ENGINE",
    "  ...HOT..."
) "adventure_engine"

# Connect engine to corridor
$script:AdvRooms["corridor"].Exits["down"] = "engine"

# === ROOM 12: MEDBAY ===
Register-Room "medbay" "KRANKENSTATION" `
"Die Krankenstation riecht nach Desinfektionsmittel. Betten mit Lederriemen stehen an den Waenden. Ein medizinisches Terminal ist eingeschaltet, aber gesperrt. Schraenke mit Medikamenten sind leer. Im Sueden geht es zurueck in den Korridor." `
@{ south = "corridor" } `
(@{
    terminal = @{ Name = "Med-Terminal"; Description = "Ein medizinisches Terminal mit Patientendaten. Es ist mit einem Code gesperrt."; Takeable = $false; UseWith = $null }
    bed = @{ Name = "Bett"; Description = "Ein Krankenbett mit Lederriemen. Jemand wurde hier festgehalten. Oder behandelt."; Takeable = $false; UseWith = $null }
    cabinet = @{ Name = "Medizinschrank"; Description = "Ein verschlossener Schrank mit einem roten Kreuz. Er braucht einen Schluessel."; Takeable = $false; UseWith = "medkey" }
}) `
(@{
    nurse = @{ Name = "Hologramm-Schwester"; Description = "Ein freundliches Hologramm einer Schwester. Sie laechelt zu fest."; Dialog = @("Patient 7 hat... Veraenderungen gezeigt.", "Die Injektionen waren notwendig. Sie sagten es.", "Ich habe nur meinen Job gemacht.") }
}) `
@(
    "  [BED] [BED]",
    "  [BED] [BED]",
    "   [MED+]",
    "  [SCREEN]",
    "   MEDBAY"
) "adventure_medbay"

# Connect medbay to corridor (locked by default, unlock via hacking or key)
$script:AdvRooms["corridor"].Exits["north"] = "medbay"

# === ROOM 13: ARMORY ===
Register-Room "armory" "WAFFENKAMMER" `
"Die Waffenkammer ist leer. Regale, die einmal Gewehre und Munition hielten, sind staubig und leer. An der Wand haengt ein Notiz mit einem Code. Eine verschlossene Tuer fuehrt zu einem Nebenraum. Im Westen geht es zurueck in den Korridor." `
@{ west = "corridor"; east = "quarters" } `
(@{
    note = @{ Name = "Code-Notiz"; Description = "Ein Zettel: 'SICHERHEITSCODE: 7-7-7. Wie originell.'"; Takeable = $true; UseWith = $null }
    rack = @{ Name = "Waffenregal"; Description = "Leere Regale. Jemand hat alles mitgenommen. Oder es wurde konfisziert."; Takeable = $false; UseWith = $null }
}) `
(@{}) `
@(
    "  [    ] [    ]",
    "  [    ] [    ]",
    "   [7777]",
    "  [====]",
    "   ARMORY"
) "adventure_armory"

# Connect armory to corridor
$script:AdvRooms["corridor"].Exits["east"] = "armory"

# === ROOM 14: QUARTERS ===
Register-Room "quarters" "CREW-UNTERKUNFTE" `
"Kleine Kabinen, eine neben der anderen. Jede hat ein Bett, einen Schreibtisch und ein Foto an der Wand. Jemand hat hier gelebt. Geliebt. Gefuerchtet. Ein Tagebuch liegt auf einem der Betten. Im Westen geht es zurueck in die Waffenkammer." `
@{ west = "armory"; down = "corridor" } `
(@{
    diary = @{ Name = "Tagebuch"; Description = "Kapitän Vance' Tagebuch: 'Tag 47. Das Signal wird staerker. Dr. Yarrow hat etwas im Nebel gesehen. Sie nennt es SIE.' Die letzten Seiten sind zerrissen."; Takeable = $true; UseWith = $null }
    photo = @{ Name = "Foto"; Description = "Ein Foto der Crew. Alle laecheln. Jemand hat rote Kreuze ueber die Gesichter gemalt. Alle ausser Vance."; Takeable = $true; UseWith = $null }
    medkey = @{ Name = "Medizin-Schluessel"; Description = "Ein kleiner roter Schluessel mit einem Kreuz. Er oeffnet den Medizinschrank."; Takeable = $true; UseWith = "cabinet" }
}) `
(@{}) `
@(
    "  [BED] [BED]",
    "  [BED] [BED]",
    "   [DIARY]",
    "  [PHOTO]",
    "   CREW"
) "adventure_quarters"

# Connect quarters to corridor
$script:AdvRooms["corridor"].Exits["up"] = "quarters"

# === ROOM 15: OBSERVATORY ===
Register-Room "observatory" "OBSERVATORIUM" `
"Ein kuppelfoermiger Raum mit einem riesigen Teleskop. Die Kuppel ist offen und zeigt den Nebel in all seiner Pracht. Ein Computer zeigt Koordinaten an. Auf einem Bildschirm: 'NEBELSEKTOR 7 — ANOMALIE DETEKTIERT.' Im Sueden geht es zurueck zur Bruecke." `
@{ south = "bridge" } `
(@{
    telescope = @{ Name = "Teleskop"; Description = "Ein riesiges Teleskop, das auf den Nebel gerichtet ist. Du siehst... etwas. Eine Gestalt? Nein. Ein Schatten."; Takeable = $false; UseWith = $null }
    computer = @{ Name = "Navigationscomputer"; Description = "Koordinaten: 7-7-7. Entfernung: unbekannt. Groesse: unbekannt. Absicht: ...SIE WARTET."; Takeable = $false; UseWith = $null }
}) `
(@{}) `
@(
    "     ***",
    "   * NEBEL *",
    "     ***",
    "  [TELESCOPE]",
    "  ...7-7-7..."
) "adventure_observatory"

# Connect observatory to bridge
$script:AdvRooms["bridge"].Exits["up"] = "observatory"

# === ROOM 16: CORE ===
Register-Room "core" "REAKTOR-KERN" `
"Das Herz der Station. Der Reaktor-Kern pulsiert in einem hypnotischen Blau. In der Mitte des Raums steht ein Podest. Auf dem Podest liegt ein Symbol — es passt perfekt zum Polaris-Artefakt. Die Waende vibrieren. Du hoerst ein Fluestern. 'Benutze mich.' Im Sueden geht es zurueck in den Maschinenraum." `
@{ south = "engine" } `
(@{
    pedestal = @{ Name = "Podest"; Description = "Ein Podest mit einem kreisfoermigen Ausschnitt. Es passt perfekt zum Artefakt."; Takeable = $false; UseWith = "artifact" }
    core = @{ Name = "Reaktor-Kern"; Description = "Der Kern pulsiert. Er ist lebendig. Oder er wird kontrolliert."; Takeable = $false; UseWith = $null }
}) `
(@{
    entity = @{ Name = "SIE"; Description = "Eine Gestalt aus Licht und Schatten. Sie hat keine Augen, aber sie SIEHT dich."; Dialog = @("Du hast mich gefunden.", "Das Artefakt. Der Kern. Die Wahrheit.", "Lege es auf das Podest. Und verstehe.") }
}) `
@(
    "    [###]",
    "    [#P#]",
    "  [=======]",
    "    CORE",
    "  ...SHE..."
) "adventure_core"

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

    # Artifact use (endgame - normal ending)
    if ($Item -eq "artifact" -and -not $Target) {
        if (Has-Item "artifact") {
            $script:AdvState.Flags["game_won"] = $true
            $script:AdvState.Score += 50
            Save-AdventureState
            return @{ Success = $true; Message = "Du beruehrst das Artefakt. Die Welt verschwimmt... und du verstehst. Die Station war nie verloren. Sie wartete. Auf DICH.`n`n=== DAS ENDE ===`nPunkte: $($script:AdvState.Score) / $($script:AdvState.MaxScore)`nZuege: $($script:AdvState.Moves)`nDanke fuers Spielen!"; CompanionContext = "adventure_victory" }
        }
    }

    # Battery on reactor in engine
    if ($Item -eq "battery" -and $Room.Id -eq "engine") {
        if (Has-Item "battery") {
            $script:AdvState.Flags["reactor_fixed"] = $true
            $script:AdvState.Score += 20
            Save-AdventureState
            return @{ Success = $true; Message = "Du steckst die Batterie in den Reaktor. Das Flackern hoert auf. Die Stabilitaet steigt auf 100%. Die Tuer zum Reaktor-Kern oeffnet sich."; CompanionContext = "adventure_unlock" }
        }
    }

    # Artifact on pedestal in core (TRUE ENDING)
    if ($Item -eq "artifact" -and $Target -eq "pedestal" -and $Room.Id -eq "core") {
        if (Has-Item "artifact") {
            $script:AdvState.Flags["true_ending"] = $true
            $script:AdvState.Flags["game_won"] = $true
            $script:AdvState.Score += 100
            Save-AdventureState
            return @{ Success = $true; Message = "Du legst das Artefakt auf das Podest. Der Kern pulsiert wild. Die Gestalt aus Licht tritt vor. 'Du hast verstanden. Die Station war ein Gefaengnis. Und ich war die Waerterin. Du hast mich befreit.'`n`nDas Licht verschlingt dich. Aber es tut nicht weh. Es fuehlt sich an wie... Zuhause.`n`n=== DAS WAHRE ENDE ===`nPunkte: $($script:AdvState.Score) / $($script:AdvState.MaxScore)`nZuege: $($script:AdvState.Moves)`nDu hast die Wahrheit gefunden."; CompanionContext = "adventure_victory" }
        }
    }

    # Medkey on cabinet in medbay
    if ($Item -eq "medkey" -and $Target -eq "cabinet" -and $Room.Id -eq "medbay") {
        if (Has-Item "medkey") {
            $script:AdvState.Flags["medbay_unlocked"] = $true
            $script:AdvState.Score += 10
            $script:AdvRooms["medbay"].Objects["serum"] = @{ Name = "Heil-Serum"; Description = "Ein gruen fluoreszierendes Serum. Es heilt alles. Auch Dinge, die nicht heilbar sein sollten."; Takeable = $true; UseWith = $null }
            Save-AdventureState
            return @{ Success = $true; Message = "Der Schrank oeffnet sich. Darin liegt ein gruen fluoreszierendes Serum."; CompanionContext = "adventure_unlock" }
        }
    }

    # Suit on debris in eva (find data core)
    if ($Item -eq "suit" -and -not $Target -and $Room.Id -eq "eva") {
        if (Has-Item "suit") {
            $script:AdvState.Flags["eva_explored"] = $true
            $script:AdvState.Score += 15
            $script:AdvRooms["eva"].Objects["datacore"] = @{ Name = "Datenkern"; Description = "Ein schwerer Datenkern aus der Kommunikationsantenne. Er enthaelt Aufzeichnungen aus dem Nebel-Sektor 7."; Takeable = $true; UseWith = $null }
            Save-AdventureState
            return @{ Success = $true; Message = "Du durchwuehlst die Truemmer in deinem Anzug und findest einen schweren Datenkern!"; CompanionContext = "adventure_unlock" }
        }
    }

    # Serum on captain in bridge
    if ($Item -eq "serum" -and $Target -eq "captain" -and $Room.Id -eq "bridge") {
        if (Has-Item "serum") {
            $script:AdvState.Flags["captain_healed"] = $true
            $script:AdvState.Score += 20
            Save-AdventureState
            return @{ Success = $true; Message = "Du gibst Kapitän Vance das Serum. Er blinzelt. 'Du... du hast es geschafft. Das Signal... es war SIE. Sie wollte befreit werden. Nicht bekaempft.' Er gibt dir einen letzten Hinweis: 'Der Kern. Das Podest. Das Artefakt.'"; CompanionContext = "adventure_bigwin" }
        }
    }

    return $null
}

# === COMPANION LINES FOR ADVENTURE ===
# Extended in pet/_ui.ps1 if desired; fallback handled by Show-GameCompanionComment

} catch {
    Write-Host "[ADVENTURE WORLD] Fehler: $_" -ForegroundColor Red
}

