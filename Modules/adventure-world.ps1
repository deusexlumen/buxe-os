# BUXE_OS v24.7 -- ADVENTURE WORLD
# Die verlorene Station Polaris. 16 Räume, Objekte, NPCs, Rätsel.

$script:AdventureWorldMessages = @{
    # Router
    intro_title        = "BUXE_OS ADVENTURE v24.4"
    intro_subtitle     = "Ein Text-Abenteuer, das genau weiss, in welchem Terminal es läuft."
    intro_hint         = "Tipp 'help', wenn du vergisst, wer hier Programmierer ist."
    outro              = "Adventure beendet. Dein State wurde nicht gelöscht – das überlasse ich dir."

    # Rooms
    hangar_desc        = "Ein Hangar, der größer ist als nötig. Die Wände flüstern von Budget-Überschreitungen. Ein altes Shuttle steht herum und wartet auf einen Patch."
    hangar_exits       = "Ausgänge: Osten (Corridor). Mehr gibt das Leveldesign noch nicht her."
    corridor_desc      = "Ein langer, grauer Corridor. Neonlichter flackern im Takt eines schlechten Loops. Hier hätte das Art-Team mehr Budget gebraucht."
    bridge_desc        = "Die Brücke. Ein kapitalistischer Traum aus Stahl und kaputtem Glas. Ein Hologramm blinkt hilflos."
    eva_desc           = "Der EVA-Schacht. Draußen liegt der Weltraum, kalt und voller nicht-geladener Texturen. Ein rotes Kabel hängt herab, und der Nebel glüht wie ein schlechter Screensaver. Ohne Anzug wirst du ein Bug-Report."
    core_desc          = "Der Reaktor-Core pulsiert. In der Mitte steht ein leeres Podest, das leise flüstert. Die Kühlflüssigkeit riecht nach heissen Promises. Im Süden geht es zurück zum Engine-Raum."
    airlock_desc       = "Die Luftschleuse. Zwei Türen, ein rotes Blinklicht. Der Hinweis 'EVA erfordert RAUMANZUG' klebt unter einem Post-it mit 'Wird noch gepatcht'."
    engine_desc        = "Der Engine-Raum. Turbinen brummen wie ein schlecht gewarteter CI-Runner. Im Norden steht ein Schild mit 'REAKTOR-KERN' – jemand hat es aus Comic Sans gerissen."
    medbay_desc        = "Die Krankenstation riecht nach Desinfektionsmittel und schlechten Entscheidungen. Betten mit Lederriemen stehen stramm an der Wand, als würden sie auf Opfer warten. Ein Terminal zeigt Patientendaten an – gesperrt, natürlich. Im Süden geht es zurück in den Korridor."
    armory_desc        = "Die Waffenkammer. Laser-Gewehre hängen ordentlich an der Wand, Stun-Stäbe daneben. Im Osten geht es zu den Crew-Unterkünften, im Westen zurück in den Korridor. Auf dem Tisch liegt eine Notiz mit einem Code – sehr original, Leveldesigner."
    quarters_desc      = "Die Crew-Unterkünfte. Kleine Kabinen, ein Gemeinschaftsraum. Jemand hat hier gelebt, geliebt, gefürchtet. Ein Tagebuch liegt auf einem Bett und flüstert 'lies mich'. Im Westen zur Waffenkammer, nach unten zurück in den Korridor. Captain Vance' Bett ist gemacht. Verdächtig."
    observatory_desc   = "Das Observatorium. Ein großes Teleskop starrt auf den Nebelsektor 7. Auf einem Monitor blinkt 'NEBELSEKTOR 7 -- ANOMALIE DETEKTIERT'. Im Süden geht es zurück zur Brücke. Draußen pulsiert etwas, das keinem Cronjob ähnelt."
    cafeteria_desc     = "Die Kantine. Tische, Stühle, ein Automat, der leise vor sich hin summt. Vergessene Tassen stehen herum wie verwaiste Prozesse. Ein Schild wirbt für 'Weltraum-Hähnchen'. Im Norden geht es zurück zum Hangar."
    vent_desc          = "Ein Lüftungsschacht. Hier riecht es nach Staub, Schweiß und den Träumen des Leveldesigners. Nach unten geht es in den Lagerraum, im Osten liegt ein geheimer Raum. Eng, aber geheimnisvoll."
    secret_desc        = "Ein geheimer Raum. Wie du ihn gefunden hast, sagst du mir nicht? Gut. Das ist zwischen dir, mir und dem Debug-Log. Im Westen geht es zurück in den Lüftungsschacht."
    lab_desc           = "Das Labor. Reagenzgläser, Monitore und ein Whiteboard voller Gleichungen, die jemand absichtlich unleserlich geschrieben hat. Im Osten geht es zurück in den Korridor."
    storage_desc       = "Der Lagerraum. Regale voller Kisten, Werkzeuge und Ersatzteile. Hier lagert alles, das niemand braucht, aber niemand wegwirft. Im Westen geht es zum Hangar, nach oben in den Lüftungsschacht."

    # Objects / examine
    terminal_examine   = "Ein Terminal mit einer Tastatur, die so alt ist, dass sie mechanisch klackt. Das Display zeigt 'login: root'. Jemand war faul."
    box_examine        = "Eine Metallkiste. Nicht verschlossen, nur resigniert. Sie seufzt, als wüsste sie, dass du sie gleich öffnest."
    notebook_examine   = "Ein Notizbuch. Die letzte Seite trägt die Aufschrift: 'Wenn du das liest, bist du zu weit gegangen. Gruss, Leveldesigner'."
    screen_examine     = "Ein Bildschirm mit Warnsymbolen. Er flackert, als würde er versuchen, dir auszuweichen."
    diary_examine      = "Ein Tagebuch. Captain Vance beschwert sich über die Crew, die KI und dass niemand den Drucker nachfüllt."
    computer_examine   = "Ein Computer. Der Desktop-Hintergrund ist ein Weltraumkätzchen. Die CPU-Auslastung: 47%. Natürlich."
    pedestal_examine   = "Ein Podest. Es fehlt ein Artefakt. Oder es ist nur unsichtbar. Mit Assets spart man ja gerne."
    warning_examine    = "Ein Warnschild: 'Nicht drücken'. Darunter, in Klammern: 'Ausser du willst den Plot vorantreiben'."
    cable_examine      = "Ein Kabel. Rot, dick, offensichtlich wichtig. Jemand hat es hier liegen gelassen wie einen Chekhov'schen Gewehr."
    rubber_chicken_examine = "Ein Gummihuhn. Ein klassisches Adventure-Item. Du fragst dich, wer es hier vergessen hat. Wahrscheinlich das QA-Team."
    skull_examine      = "Ein Plastikschädel. Er grinst. Nicht böse, eher so, als wüsste er über deinen Browser-Verlauf Bescheid."
    tree_examine       = "Ein Plastikbaum. Er steht in einem geheimen Raum und produziert Sauerstoff für genau niemanden. Dekorativer Sarkasmus."
    spacesuit_examine  = "Ein Raumanzug. Er riecht nach altem Schaumstoff und Helden. Mindestens ein Loch ist mit Tape geflickt."
    keycard_examine    = "Eine Keycard. Sie öffnet Türen, Herzen und vielleicht den Kühlschrank der Cafeteria."
    artifact_examine   = "Ein seltsames Artefakt. Es vibriert leicht und hört auf, wenn du hinsiehst. Typisch Undefined Behaviour."

    # Use / event texts
    bridge_unseal      = "Die Brücke entriegelt sich mit einem zufriedenen Klicken. Willkommen im Endgame – oder zumindest im nächsten Akt."
    core_unlock        = "Du steckst das Artefakt ins Podest. Der Core wird ruhiger, die Lichter werden grün, und irgendwo jubelt ein Achievement-Tracker."
    server_reboot      = "Du drückst den roten Knopf. Server fahren hoch, runter, dann wieder hoch. Systemadministratoren weinen Tränen der Freude."
    secret_tree_use    = "Du redest mit dem Plastikbaum. Er antwortet nicht. Ihr beide wisst, dass das normal ist."
    lab_computer_use   = "Du startest die Experiment-Simulation. Sie crasht sofort. 'Feature, not bug', flackert auf dem Bildschirm."
    vent_skull_use     = "Du hältst den Schädel ins Lüftungsgitter. Ein Windstoss lässt ihn klappern. Das klingt fast wie Applaus."
}

function Get-AdventureWorldMessage($Key, $Params = @()) {
    $msg = $script:AdventureWorldMessages[$Key]
    if (-not $msg) { return "" }
    if ($Params.Count -gt 0) { $msg = $msg -f $Params }
    return $msg
}

try {

# === ROOM 1: HANGAR ===
Register-Room "hangar" "HANGAR BAY 7" `
(Get-AdventureWorldMessage "hangar_desc") `
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
(Get-AdventureWorldMessage "corridor_desc") `
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
(Get-AdventureWorldMessage "storage_desc") `
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
(Get-AdventureWorldMessage "lab_desc") `
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
(Get-AdventureWorldMessage "vent_desc") `
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
(Get-AdventureWorldMessage "secret_desc") `
@{ west = "vent" } `
(@{
    notes = @{ Name = "Notizen"; Description = "Jede Notiz sagt 'SIE SIEHT UNS.' Die Handschrift wird immer wilder. Die letzte ist in... Blut?"; Takeable = $false; UseWith = $null }
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
(Get-AdventureWorldMessage "bridge_desc") `
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
(Get-AdventureWorldMessage "cafeteria_desc") `
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

# === NEW ROOMS v25.0 ===

# === ROOM 9: AIRLOCK ===
Register-Room "airlock" "LUFTSCHLEUSE" `
(Get-AdventureWorldMessage "airlock_desc") `
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
(Get-AdventureWorldMessage "eva_desc") `
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
(Get-AdventureWorldMessage "engine_desc") `
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
(Get-AdventureWorldMessage "medbay_desc") `
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

# Medbay is reached via hacking the terminal or using a key; north exit is managed by unlock logic

# === ROOM 13: ARMORY ===
Register-Room "armory" "WAFFENKAMMER" `
(Get-AdventureWorldMessage "armory_desc") `
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
Register-Room "quarters" "CREW-UNTERKÜNFTE" `
(Get-AdventureWorldMessage "quarters_desc") `
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
(Get-AdventureWorldMessage "observatory_desc") `
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
(Get-AdventureWorldMessage "core_desc") `
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
            $script:AdvStateDirty = $true
            return @{ Success = $true; Message = "Du steckst die Karte in den Leser. Die Tür zur Brücke öffnet sich mit einem Zischen."; CompanionContext = "adventure_unlock" }
        }
    }

    # Crowbar on box in storage
    if ($Item -eq "crowbar" -and $Target -eq "box" -and $Room.Id -eq "storage") {
        if (Has-Item "crowbar") {
            $script:AdvState.Flags["box_opened"] = $true
            $script:AdvRooms["storage"].Objects["map"] = @{ Name = "Sternenkarte"; Description = "Eine Karte der Region. Die Polaris ist markiert - und ein großes rotes X im Nebel-Sektor 7."; Takeable = $true; UseWith = $null }
            $script:AdvState.Score += 10
            $script:AdvStateDirty = $true
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
            $script:AdvStateDirty = $true
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
            $script:AdvStateDirty = $true
            return @{ Success = $true; Message = "Du beruehrst das Artefakt. Die Welt verschwimmt... und du verstehst. Die Station war nie verloren. Sie wartete. Auf DICH.`n`n=== DAS ENDE ===`nPunkte: $($script:AdvState.Score) / $($script:AdvState.MaxScore)`nZuege: $($script:AdvState.Moves)`nDanke fuers Spielen!"; CompanionContext = "adventure_victory" }
        }
    }

    # Battery on reactor in engine
    if ($Item -eq "battery" -and $Room.Id -eq "engine") {
        if (Has-Item "battery") {
            $script:AdvState.Flags["reactor_fixed"] = $true
            $script:AdvState.Score += 20
            $script:AdvStateDirty = $true
            return @{ Success = $true; Message = "Du steckst die Batterie in den Reaktor. Das Flackern hoert auf. Die Stabilitaet steigt auf 100%. Die Tuer zum Reaktor-Kern oeffnet sich."; CompanionContext = "adventure_unlock" }
        }
    }

    # Artifact on pedestal in core (TRUE ENDING)
    if ($Item -eq "artifact" -and $Target -eq "pedestal" -and $Room.Id -eq "core") {
        if (Has-Item "artifact") {
            $script:AdvState.Flags["true_ending"] = $true
            $script:AdvState.Flags["game_won"] = $true
            $script:AdvState.Score += 100
            $script:AdvStateDirty = $true
            return @{ Success = $true; Message = "Du legst das Artefakt auf das Podest. Der Kern pulsiert wild. Die Gestalt aus Licht tritt vor. 'Du hast verstanden. Die Station war ein Gefaengnis. Und ich war die Waerterin. Du hast mich befreit.'`n`nDas Licht verschlingt dich. Aber es tut nicht weh. Es fuehlt sich an wie... Zuhause.`n`n=== DAS WAHRE ENDE ===`nPunkte: $($script:AdvState.Score) / $($script:AdvState.MaxScore)`nZuege: $($script:AdvState.Moves)`nDu hast die Wahrheit gefunden."; CompanionContext = "adventure_victory" }
        }
    }

    # Medkey on cabinet in medbay
    if ($Item -eq "medkey" -and $Target -eq "cabinet" -and $Room.Id -eq "medbay") {
        if (Has-Item "medkey") {
            $script:AdvState.Flags["medbay_unlocked"] = $true
            $script:AdvState.Score += 10
            $script:AdvRooms["medbay"].Objects["serum"] = @{ Name = "Heil-Serum"; Description = "Ein gruen fluoreszierendes Serum. Es heilt alles. Auch Dinge, die nicht heilbar sein sollten."; Takeable = $true; UseWith = $null }
            $script:AdvStateDirty = $true
            return @{ Success = $true; Message = "Der Schrank oeffnet sich. Darin liegt ein gruen fluoreszierendes Serum."; CompanionContext = "adventure_unlock" }
        }
    }

    # Suit on debris in eva (find data core)
    if ($Item -eq "suit" -and -not $Target -and $Room.Id -eq "eva") {
        if (Has-Item "suit") {
            $script:AdvState.Flags["eva_explored"] = $true
            $script:AdvState.Score += 15
            $script:AdvRooms["eva"].Objects["datacore"] = @{ Name = "Datenkern"; Description = "Ein schwerer Datenkern aus der Kommunikationsantenne. Er enthaelt Aufzeichnungen aus dem Nebel-Sektor 7."; Takeable = $true; UseWith = $null }
            $script:AdvStateDirty = $true
            return @{ Success = $true; Message = "Du durchwuehlst die Truemmer in deinem Anzug und findest einen schweren Datenkern!"; CompanionContext = "adventure_unlock" }
        }
    }

    # Serum on captain in bridge
    if ($Item -eq "serum" -and $Target -eq "captain" -and $Room.Id -eq "bridge") {
        if (Has-Item "serum") {
            $script:AdvState.Flags["captain_healed"] = $true
            $script:AdvState.Score += 20
            $script:AdvStateDirty = $true
            return @{ Success = $true; Message = "Du gibst Kapitän Vance das Serum. Er blinzelt. 'Du... du hast es geschafft. Das Signal... es war SIE. Sie wollte befreit werden. Nicht bekaempft.' Er gibt dir einen letzten Hinweis: 'Der Kern. Das Podest. Das Artefakt.'"; CompanionContext = "adventure_bigwin" }
        }
    }

    # === LUCASARTS EASTER EGG USE HANDLERS ===
    # Rubber chicken - classic Monkey Island item
    if ($Item -eq "rubber_chicken" -and -not $Target) {
        return @{ Success = $false; Message = "Du ziehst am Gummihuhn. Es macht 'Quack'. Nichts passiert. Aber es fuehlt sich an wie ein Sieg.`n`n(Pro-Tipp: In einem anderen Universum haettest du damit eine Schaltklinke betaetigt.)"; CompanionContext = "adventure_absurd" }
    }
    if ($Item -eq "rubber_chicken" -and $Target -eq "pulley") {
        return @{ Success = $false; Message = "Du haengst das Gummihuhn an die Seilrolle. Es schwingt hin und her. Eine Gans wuerde stolz sein."; CompanionContext = "adventure_absurd" }
    }
    # Skull - Grim Fandango reference
    if ($Item -eq "skull" -and -not $Target) {
        return @{ Success = $false; Message = "Du haeltst den Schaedel ans Ohr. 'Hallo? Manny?' Stille. Dann: 'Sprich mit dem Gluecksbeetle.' Warte, was?"; CompanionContext = "adventure_absurd" }
    }
    if ($Item -eq "skull" -and $Target -eq "tree") {
        return @{ Success = $false; Message = "Du stellst den Schaedel unter den Plastikbaum. Es sieht aus wie eine sehr morbide Weihnachtsdekoration."; CompanionContext = "adventure_absurd" }
    }
    # Plastic tree - Monkey Island reference
    if ($Item -eq "tree" -and -not $Target) {
        return @{ Success = $false; Message = "Du umarmst den kleinen Plastikbaum. Ich bin ein Pirat, ich mag Baumkaetzchen. Nein. Nein tust du nicht."; CompanionContext = "adventure_absurd" }
    }
    if ($Item -eq "tree" -and $Target -eq "captain") {
        return @{ Success = $false; Message = "Du haeltst Kapitaen Vance den Plastikbaum hin. Er blinzelt. Das... das erinnert mich an etwas. Eine Insel? Ein Geheimnis?"; CompanionContext = "adventure_absurd" }
    }

    return $null
}

# === ROOM 17: THE HOLLOW (ARG Layer 4) ===
Register-Room "hollow" "THE HOLLOW" `
"Du stehst in einem Raum, der aus Licht und Code besteht.
Die Waende sind aus Text. Du erkennst Fragmente -
Casino-Regeln, Kampf-Logs, Companion-Konfigurationen.
Alles, was du getan hast, ist hier.

In der Mitte steht ein Tisch. Auf dem Tisch liegt ein Buch.
Das Buch ist offen. Die Seiten sind leer - aber waehrend
du hinschaust, fuellen sie sich. Mit deinen Worten.
Deinen Befehlen. Deinen Fehlern." `
@{ south = "cafeteria" } `
(@{
    book = @{ Name = "Leeres Buch"; Description = "Die Seiten fuellen sich, waehrend du hinschaust. Mit deinen Worten. Deinen Befehlen. Deinen Fehlern."; Takeable = $false; UseWith = $null }
}) `
(@{}) `
@(
    "  [LIGHT]",
    "  [CODE ]",
    "  [BOOK ]",
    "  [TABLE]",
    "  ...YOU..."
) "adventure_hollow"

# === COMPANION LINES FOR ADVENTURE ===
# Extended in pet/_ui.ps1 if desired; fallback handled by Show-GameCompanionComment

} catch {
    Write-Host "[ADVENTURE WORLD] Fehler: $_" -ForegroundColor Red
}

