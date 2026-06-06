# BUXE_OS v25.0 — COMPANION STORY DATA v1.0
# Episode definitions for all companions

try {

$script:CompanionEpisodeData = @{
    NEON = @{
        1 = @{
            Title = "Der Netrunner der nie disconnectete"
            Subtitle = "Episode 1: Der alte Client"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "Es ist 3 Uhr morgens. Dein Terminal flackert.",
                        "Eine Nachricht aus der Vergangenheit..."
                    )
                    DialogLine = "Ugh. Das ist nicht gut. Das ist ueberhaupt nicht gut."
                    Choices = @(
                        @{
                            Label = "A"; Text = "Nachricht oeffnen"
                            NextScene = 2; BondDelta = 2
                            Outcome = "NEON nickt langsam. 'Du bist mutiger, als du aussiehst.'"
                        },
                        @{
                            Label = "B"; Text = "Ignorieren und weiterarbeiten"
                            NextScene = 3; BondDelta = -2
                            Outcome = "NEON seufzt. 'Typisch. Immer wegsehen.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 2
                    Text = @(
                        "Die Nachricht enthaelt Koordinaten.",
                        "Ein Server, den NEON vor Jahren versteckt hat."
                    )
                    DialogLine = "Das ist mein Backup. Mein VERSTECKTES Backup."
                    Choices = @(
                        @{
                            Label = "A"; Text = "Gemeinsam zum Server"
                            NextScene = 4; BondDelta = 5
                            Outcome = "NEON laechelt — fast. 'Endlich jemand, der mithalten kann.'"
                        },
                        @{
                            Label = "B"; Text = "NEON allein schicken"
                            NextScene = 5; BondDelta = -3
                            Outcome = "NEON starrt dich an. 'Allein? Nach allem?'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 3
                    Text = @(
                        "Du arbeitest weiter. Aber etwas stimmt nicht.",
                        "Der Bildschirm flackert erneut."
                    )
                    DialogLine = "Siehst du? Man kann nicht einfach wegsehen."
                    Choices = @(
                        @{
                            Label = "A"; Text = "Jetzt doch oeffnen"
                            NextScene = 2; BondDelta = 0
                            Outcome = "NEON schnaubt. 'Besser spaet als nie, oder?'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 4
                    Text = @(
                        "Gemeinsam brecht ihr zum Server auf.",
                        "NEON bewegt sich mit einer Anmut, die du noch nie gesehen hast.",
                        "Der Server ist intakt. Und er enthaelt mehr als nur Backups..."
                    )
                    DialogLine = "Das... das sind Erinnerungen. Meine ERSTEN Erinnerungen."
                    Choices = @()
                    NextScene = -1
                },
                @{
                    Id = 5
                    Text = @(
                        "NEON verschwindet im Netz. Minuten vergehen.",
                        "Dann: Ein Fehler. Ein schwerer Fehler.",
                        "NEON kehrt zurueck — beschaedigt, aber lebendig."
                    )
                    DialogLine = "Das haette schiefgehen koennen. Schlimmer schiefgehen."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
    JINX = @{
        1 = @{
            Title = "Die 47. Verschwoerung"
            Subtitle = "Episode 1: Die Zahl"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "JINX sitzt auf deinem Desktop-Icon fuer den Papierkorb.",
                        "Sie haelt 47 Popcorn-Koerner in einer Hand.",
                        "'Es ist ALLES 47', flüstert sie. '47 Prozesse. 47 Tabs. 47...'"
                    )
                    DialogLine = "Du glaubst mir nicht. NIEMAND glaubt mir."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Zeig es mir.'"
                            NextScene = 2; BondDelta = 5
                            Outcome = "JINX springt auf. 'ENDLICH! Ein Zeuge!'"
                        },
                        @{
                            Label = "B"; Text = "'Das ist Zufall, JINX.'"
                            NextScene = 3; BondDelta = -3
                            Outcome = "JINX starrt dich an. 'Zufall? ZUFALL?'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 2
                    Text = @(
                        "JINX fuehrt dich durch dein eigenes System.",
                        "47 Log-Eintraege. 47 Fehlermeldungen. 47... Autosaves?",
                        "'Siehst du? Siehst du jetzt?', jubelt sie."
                    )
                    DialogLine = "Die Matrix spricht zu uns. In ihrer Lieblingssprache."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Wer steckt dahinter?'"
                            NextScene = 4; BondDelta = 5
                            Outcome = "JINX grinst. 'Das... ist die MILLIONEN-GOLD-FRAGE.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 3
                    Text = @(
                        "JINX wirft die Popcorn-Koerner auf den Boden.",
                        "'Ich werde es BEWEISEN', bruellt sie.",
                        "Der Bildschirm flackert. 47 Mal."
                    )
                    DialogLine = "Du wirst noch bereuen, mich nicht geglaubt zu haben."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Okay, okay — zeig es mir.'"
                            NextScene = 2; BondDelta = 2
                            Outcome = "JINX sammelt das Popcorn auf. 'Zu spaet. Du hast es verspielt.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 4
                    Text = @(
                        "JINX zeigt dir einen versteckten Prozess.",
                        "Name: 'observer_47.exe'. Status: LAEUFT.",
                        "'Er beobachtet uns', flüstert JINX. 'Seit 47 Tagen.'"
                    )
                    DialogLine = "Willkommen in der Verschwoerung, Partner."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
}

} catch {
    Write-Host "Fehler in companion-story-data.ps1: $_" -ForegroundColor Red
}
