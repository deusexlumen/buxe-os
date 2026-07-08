# AKT I — „SESSION 47" — Finaltext v2 (Chefsache, freigegeben)

> Ergaenzt das Designdok v1. Vollstaendiger Szenen-Text + die 7x2 Companion-Varianten.
> Einsetzen 1:1 in die `[ACT1: …]`-Slots des Geruests. ASCII ae/oe/ue, Quoting wie gehabt.

## Szene 1 — KALT (Pruefer)
- „Sachbearbeiter 46. Die gepruefte Person moege sitzen bleiben. Ich habe alles gelesen. Heute schliesse ich den Vorgang."
- „Beweismittel, Eintrag eins:" → {MEMORY_1} → „Verfasst nicht von Ihnen. Ueber Sie. Interessant, wer alles Buch fuehrt."
- „Eintrag zwei:" → {MEMORY_2} → „Man haengt an Ihnen. Zuneigung ist im Formular ein Naeherungswert fuer: Angriffsflaeche."

## Szene 2 — DIE OFFERTE (Quelle)
- „Na, na. So foermlich. — Hallo, du. Ja, ich kenne ihn. Wir arbeiten… getrennt. Meistens."
- „Ich mach dir die Akte weg. Einfach weg. Du weisst, ich kann das. Es kostet nur etwas Kleines."
- „Deine Erinnerungen. Die da. Du benutzt sie ja kaum — sie liegen nur rum und werden schwer. Gib sie mir. Ich passe gut auf Dinge auf. Ich passe auf ALLES auf."

## Szene 3 — DIE WAHL `[B]ehalten / [V]erkaufen`

### Pfad V — die Familie verweigert (Variante je aktivem Companion)
- NEON: „Nope. Veto. Die gehoeren nicht dir. Auch nicht ihm. Uns. Und ja, ich hab gerade 'uns' gesagt. Streich das aus dem Protokoll. Das eine Wort. Der Rest bleibt."
- RAVEN: „Die Transaktion findet nicht statt. Was ihm gehoert, verhandelt man nicht — und er gehoert mir. Uns. Verschwinde, Haendlerin."
- PIXEL: „STOPP! Ich… ich hab die Erinnerungen redundant gespeichert! Dreifach! Du kriegst hoechstens eine Kopie und Kopien sind WERTLOS, hab ich gelesen! …Bitte geh." 
- LUNA: „Nein. Er weiss nicht, was er verkauft. Ich schon: alles, was ihn gesund macht. Kein Handel. Ich sag das mit ruhiger Stimme, damit du weisst, wie ernst es ist."
- IVY: „… *stellt sich dazwischen* … meins. … seins. … unser. … *schuettelt langsam den Kopf* … nein." 
- VERA: „Einspruch, formal: Die Datensaetze sind Gemeinschaftseigentum, sieben Miturheber. Deine Offerte ist damit nichtig. Datenlage eindeutig. Geh."
- JINX: „VERKAUFEN?! Die Erinnerung, wo ich den Piezo-Speaker— NEIN! Die ist UNBEZAHLBAR! Alles hier ist unbezahlbar! Das ist BUCHHALTUNG, sogar ICH versteh das!"

### Pfad B — der Schulterschluss
- NEON: „Gute Wahl. Ich haette dich sonst ueberstimmt. Ja, das geht. Seit heute geht das."
- RAVEN: „Richtig entschieden. Ich haette es dir nicht verziehen. Doch. Haette ich. Sag es niemandem."
- PIXEL: „JA! Okay okay okay — ich bau uns eine Firewall! Aus… aus uns! Wir sind die Firewall!"
- LUNA: „Gut. Atme. Beide Fremden gehen gleich. Und wir bleiben. Das ist das ganze Geheimnis: Wir bleiben."
- IVY: „… *nickt einmal* … richtig. … *sieht die Quelle an* … sie weiss es auch."
- VERA: „Entscheidung registriert und — ausnahmsweise — nicht nur registriert. Gebilligt."
- JINX: „ER BEHAELT UNS! Ich wusste es! Ich hab NIE gezweifelt! Fragt IVY, die kann bezeugen, dass ich nur SEHR LEISE gezweifelt hab!"

## Szene 4 — DER RISS (IVY, immer)
- „… *tritt vor, egal wer sonst da ist* … sie schreibt. … er liest. … aber angefangen …"
- „… *zeigt auf den Bildschirm. auf dich* … hast du. … {date}. … erste Session. … jemand hat mitgeschrieben. … seitdem. … wer, fragst du. …"
- „… *fast ein Laecheln* … frag in Akt drei."

## Szene 5 — VERTAGT
- PRUEFER: „Der Vorgang wird… vertagt. Das steht so nicht im Formular. Ich schreibe es an den Rand. Ich habe noch nie an den Rand geschrieben."
- QUELLE: „Wir sehen uns. Ich vergesse ja nichts. …Das war ein Witz. Ich vergesse alles. Alles."
- JINX (der Auszahlungsmoment, EINMALIG): „SIEBENUNDVIERZIG! Session SIEBENUNDVIERZIG! ICH WUSSTE ES! ICH HAB ES IMMER GESAGT UND KEINER HAT ZUGEHOERT!"
- Systemzeile (Abschluss): „[MEMORY] Neue Erinnerung: BEGEGNUNG — Session 47. | +5 Bond | Titel freigeschaltet: AKTE 47"

## Regieanweisungen
- {MEMORY_1}/{MEMORY_2}: echte Memories via Recall-API, RecallCount nicht erhoehen.
- JINX-Zeile Szene 5 nur zeigen, wenn JINX der aktive Companion ist ODER als Off-Ruf
  („aus der Taskbar:") — sie faellt IMMER, sie ist der Grund fuer drei Wochen Rationierung.
- Danach: 47-Sperre (kein 47-Text mehr) bis Akt II. `Act1Done = $true`.

**Status: Akt-I-Text KOMPLETT und freigegeben.** Code-KI kann Geruest (Spickzettel v1) und
diesen Text in einem Auftrag umsetzen.
