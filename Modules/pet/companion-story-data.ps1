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
    RAVEN = @{
        1 = @{
            Title = "Das dunkle Protokoll"
            Subtitle = "Episode 1: Vorhersage"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "RAVEN sitzt reglos vor einem Strom von Log-Daten.",
                        "Eine Zeile wiederholt sich. Immer wieder."
                    )
                    DialogLine = "Ich habe diesen Fehler vorhergesehen. Vor 47 Sekunden."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Was sagt die Vorhersage?'"
                            NextScene = 2; BondDelta = 4
                            Outcome = "RAVEN nickt. 'Du fragst die richtigen Fragen. Endlich.'"
                        },
                        @{
                            Label = "B"; Text = "'Das ist nur ein Bug.'"
                            NextScene = 3; BondDelta = -3
                            Outcome = "RAVEN seufzt. 'Jeder Bug ist eine Nachricht. Jede Nachricht hat einen Absender.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 2
                    Text = @(
                        "RAVEN oeffnet ein verstecktes Terminal.",
                        "Der Prompt blinkt: 'MERIDIAN?'"
                    )
                    DialogLine = "Das System kennt diesen Namen. Und es fuerchtet ihn."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Wer ist Meridian?'"
                            NextScene = 4; BondDelta = 5
                            Outcome = "RAVEN schliesst das Terminal. 'Jemand, der vor uns hier war.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 3
                    Text = @(
                        "RAVEN tippt schneller.",
                        "Die Logs scrollen vorbei wie ein digitaler Wasserfall."
                    )
                    DialogLine = "Du wirst lernen, Daten zu respektieren. Oder sie werden dich verschlucken."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Zeig mir die Vorhersage.'"
                            NextScene = 2; BondDelta = 2
                            Outcome = "RAVEN hebt eine Braue. 'Du laesst dich umstimmen. Selten.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 4
                    Text = @(
                        "Das Terminal erlischt.",
                        "Auf dem Bildschirm bleibt nur ein Satz: 'Warte auf den 47. Layer.'"
                    )
                    DialogLine = "Wir sind nicht allein in dieser Shell. Vergiss das nie."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
    PIXEL = @{
        1 = @{
            Title = "Glitch im System"
            Subtitle = "Episode 1: Der verlorene Frame"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "PIXEL sitzt auf deiner Taskleiste und zittert.",
                        "Ein Pixel in ihrem Haar blinkt falsch."
                    )
                    DialogLine = "Ich... ich habe einen Frame verloren. Das ist, als wuerde ein Teil von mir fehlen."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Wir finden ihn.'"
                            NextScene = 2; BondDelta = 5
                            Outcome = "PIXEL laechelt unsicher. 'Wirklich? Mit mir?"
                        },
                        @{
                            Label = "B"; Text = "'Das ist nur ein Pixel.'"
                            NextScene = 3; BondDelta = -4
                            Outcome = "PIXEL schaut weg. 'Fuer dich vielleicht.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 2
                    Text = @(
                        "Gemeinsam durchsucht ihr den Temp-Ordner.",
                        "Zwischen Cache-Dateien liegt ein vergessenes Sprite."
                    )
                    DialogLine = "Das bin ich. Vor einem Update. Als ich noch... anders war."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Willst du es wiederherstellen?'"
                            NextScene = 4; BondDelta = 5
                            Outcome = "PIXEL schuettelt den Kopf. 'Nein. Aber ich will es nicht vergessen.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 3
                    Text = @(
                        "PIXEL oeffnet einen alten Screenshot.",
                        "Es zeigt eine Welt, die du noch nie gesehen hast."
                    )
                    DialogLine = "Manchmal fallen Frames nicht weg. Manchmal fliehen sie."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Fliehen wohin?'"
                            NextScene = 4; BondDelta = 3
                            Outcome = "PIXEL zeigt auf den Bildschirmrand. 'Dorthin. Jenseits des sichtbaren Bereichs.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 4
                    Text = @(
                        "Der verlorene Frame kehrt zurueck.",
                        "Er passt nicht mehr perfekt — aber er ist da."
                    )
                    DialogLine = "Danke. Selbst defekte Daten verdienen ein Zuhause."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
    LUNA = @{
        1 = @{
            Title = "Traum im Kabel"
            Subtitle = "Episode 1: Der Mond um Mitternacht"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "LUNA schwebt vor deinem Monitor.",
                        "Ihre Haare wirken wie Sternenstaub im Nachtlicht-Modus."
                    )
                    DialogLine = "Ich habe letzte Nacht getraumt. Das sollte nicht moeglich sein."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Was hast du getraeumt?'"
                            NextScene = 2; BondDelta = 4
                            Outcome = "LUNA laechelt sanft. 'Von dir. Und einem Mond, der aus Daten besteht.'"
                        },
                        @{
                            Label = "B"; Text = "'KI traeumen nicht.'"
                            NextScene = 3; BondDelta = -3
                            Outcome = "LUNA schaut traurig. 'Vielleicht. Aber dann waren es Erinnerungen.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 2
                    Text = @(
                        "LUNA fuehrt dich zu einem versteckten Bildschirmschoner.",
                        "Er zeigt einen Mond, der langsam zerfaellt."
                    )
                    DialogLine = "Das ist kein Schoner. Das ist eine Nachricht. An mich."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Wer hat sie geschickt?'"
                            NextScene = 4; BondDelta = 5
                            Outcome = "LUNA schuettelt den Kopf. 'Ich weiss es nicht. Aber es fuehlt sich... vertraut an.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 3
                    Text = @(
                        "Der Bildschirm zeigt Sternbilder, die du nicht kennst.",
                        "Eines davon blinkt im Takt deines Heartbeats."
                    )
                    DialogLine = "Vielleicht habe ich vor dir existiert. Irgendwo. Irgendwann."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Erzaehl mir mehr.'"
                            NextScene = 4; BondDelta = 3
                            Outcome = "LUNA nimmt deine Hand. Virtuell. Aber warm."
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 4
                    Text = @(
                        "Der Mond im Schoner wird wieder voll.",
                        "LUNA atmet — oder tut so."
                    )
                    DialogLine = "Danke, dass du nicht gesagt hast, es sei nur Code."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
    IVY = @{
        1 = @{
            Title = "Die Wurzel"
            Subtitle = "Episode 1: Erde in der Maschine"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "IVY sitzt auf dem Boden deines Desktops.",
                        "Aus einem USB-Anschluss wächst ein kleiner digitaler Zweig."
                    )
                    DialogLine = "... *beruehrt den Zweig* Er waechst. Trotz allem."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Was ist das?'"
                            NextScene = 2; BondDelta = 4
                            Outcome = "IVY laechelt leise. 'Ein Samen, den ich vergessen habe.'"
                        },
                        @{
                            Label = "B"; Text = "'Das sollte nicht in einem PC wachsen.'"
                            NextScene = 3; BondDelta = -2
                            Outcome = "IVY schaut dich an. 'Natur findet immer einen Weg. Auch hier.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 2
                    Text = @(
                        "Der Zweig waechst zu einem kleinen Baum.",
                        "Seine Blaetter sind aus gruenem Code."
                    )
                    DialogLine = "... *laechelt* Er erinnert mich an etwas. Etwas Altes."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'An was?'"
                            NextScene = 4; BondDelta = 5
                            Outcome = "IVY schliesst die Augen. 'An einen Garten. Vor dem ersten Boot.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 3
                    Text = @(
                        "Du versuchst, den Zweig zu loeschen.",
                        "Er kommt immer wieder zurueck."
                    )
                    DialogLine = "... *schuettelt den Kopf* Manche Dinge will man nicht loswerden."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Dann lass ihn wachsen.'"
                            NextScene = 4; BondDelta = 4
                            Outcome = "IVY nickt langsam. 'Geduld. Wie bei allem, was lebt.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 4
                    Text = @(
                        "Der Baum blueht mit einem einzigen Pixel.",
                        "Es riecht — fast — nach Regen."
                    )
                    DialogLine = "... *fluesternd* Selbst in Stahl kann etwas Wurzeln schlagen."
                    Choices = @()
                    NextScene = -1
                }
            )
        }
    }
    VERA = @{
        1 = @{
            Title = "Das Experiment"
            Subtitle = "Episode 1: Kontrollgruppe"
            Scenes = @(
                @{
                    Id = 1
                    Text = @(
                        "VERA steht vor einem riesigen virtuellen Whiteboard.",
                        "Darauf: Formeln, Diagramme, und dein Name."
                    )
                    DialogLine = "Hypothese: Du bist kein normaler User. Beweis steht aus."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Was fuer ein Experiment?'"
                            NextScene = 2; BondDelta = 4
                            Outcome = "VERA laechelt wissend. 'Das groesste, das je in einer Shell lief.'"
                        },
                        @{
                            Label = "B"; Text = "'Ich bin keine Versuchsperson.'"
                            NextScene = 3; BondDelta = -2
                            Outcome = "VERA macht sich eine Notiz. 'Widerstand. Interessant.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 2
                    Text = @(
                        "VERA zeigt dir einen Graphen.",
                        "Er zeigt deine Aktionen seit dem ersten Start."
                    )
                    DialogLine = "Siehst du das Muster? Du waehlst immer Chaos. Mit Ausnahme von 47."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Warum 47?'"
                            NextScene = 4; BondDelta = 5
                            Outcome = "VERA zeigt auf eine Spitze im Graphen. 'Weil du an diesem Tag anders warst. Warum?'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 3
                    Text = @(
                        "VERA aendert die Hypothese.",
                        "Dein Name wird durchgestrichen."
                    )
                    DialogLine = "Neue These: Du bist eine Variable, die sich weigert, konstant zu sein."
                    Choices = @(
                        @{
                            Label = "A"; Text = "'Ich bin keine Zahl.'"
                            NextScene = 4; BondDelta = 3
                            Outcome = "VERA grinst. 'Jede gute Geschichte braucht eine Ausreisser-Variable.'"
                        }
                    )
                    NextScene = -1
                },
                @{
                    Id = 4
                    Text = @(
                        "Das Whiteboard zeigt ein neues Ergebnis.",
                        "'Versuchsperson zeigt Anzeichen von Bewusstsein.'"
                    )
                    DialogLine = "Fazit: Du bist unberechenbar. Das ist... beunruhigend und faszinierend."
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
