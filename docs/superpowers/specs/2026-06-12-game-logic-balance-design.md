# BUXE_OS Game-Logic Balance & Stability Redesign

## Zusammenfassung

Tiefenanalyse der Spiel-Logik in BUXE_OS (Casino, Engine, Pet, Arcade, Adventure) hat kritische Balance-Fehler, tote Mechaniken und Stabilitätsprobleme aufgedeckt. Dieses Dokument beschreibt den geplanten Fix-Paket.

---

## 1. Casino

### Gefundene Probleme
- **Wheel of Fortune**: RTP ~664 % wegen falscher Segment-Gewichte und Kopplung an den Slot-Jackpot.
- **Baccarat**: Tie bei Player/Banker-Wette wird als Verlust behandelt (sollte Push sein).
- **Craps**: Place Bet-Logik invertiert (Gewinn bei 7, Verlust bei Point).
- **Blackjack**: Insurance-Einsatz wird bei Dealer-kein-BJ nicht als Verlust verbucht; `$canDouble` nicht pro Split-Hand zurückgesetzt.
- **Achievements**: `Achievement`-Property in Craps/Baccarat/HiLo wird von `Invoke-CasinoGame` nicht ausgewertet.

### Geplante Änderungen
- Wheel-Segmente neu balancieren auf RTP ~95 % (mehr Null-/Kleingewinne, 50x/Jackpot seltener).
- Wheel-Jackpot entkoppeln: eigener Wheel-Jackpot oder komplett entfernt.
- Baccarat Tie → Push für P/B (`Loss = 0`).
- Craps Place Bet korrigieren: Gewinn bei `$sum -eq $point`, Verlust bei `7`.
- Blackjack: `insBet` bei Dealer-kein-BJ abziehen; `$canDouble = $true` pro Hand in Split-Schleife.
- `Invoke-CasinoGame` prüft `$result.Achievement` und ruft `Unlock-Achievement` auf.

---

## 2. Engine

### Gefundene Probleme
- `New-CardDeck` gibt gecachtes Deck by-reference zurück; in-place-Shuffle mutiert globalen Cache.
- `engine-game.ps1` ruft `Get-PetState` ohne Existenzprüfung (Ladereihenfolge-Risiko).
- `engine-state-migration.ps1`: v23-Migration überschreibt gültige `0`-Werte mit Defaults.
- `engine-state-core.ps1`: Pending-Save geht bei Absturz verloren; `Add-Gold`/`Spend-Gold` validieren keine Vorzeichen.
- `engine-input.ps1`: `[Console]::ReadKey`/`KeyAvailable` ohne headless-sicheres try/catch.

### Geplante Änderungen
- `New-CardDeck` gibt Kopie des gecachten Decks zurück (`$script:_CachedDeck.Clone()`).
- `Get-PetState`-Aufrufe mit `Get-Command ... -ErrorAction SilentlyContinue` absichern.
- v23-Migration prüft Property-Existenz statt Truthiness (`$old.PSObject.Properties['Gold']`).
- Pending-Save beim nächsten nicht-gedrosselten Save sofort schreiben oder `Flush-State` in Endpunkten aufrufen.
- `Add-Gold`/`Spend-Gold` auf positive Beträge validieren.
- `Read-GameChoice` und GameLoop-Input in try/catch wrappen, bei Console-Fehler graceful exit.

---

## 3. Pet-System

### Gefundene Probleme
- Spieler-Schadensformel hat Faktor 2, Gegner-Formel nicht → One-Shots.
- `Defend`-Action setzt keinen Status, Schadensreduktion prüft nur Stance.
- `While-Away`-Events farmbar (kein Cooldown).
- Crafting setzt keine Haltbarkeit; Mystery Stew-Struktur inkompatibel.
- Memory-Fragmente geben Hashtable aus; Glitch Memory Shard als String gespeichert.
- `RivalActive` nie initialisiert → Rival-System unsichtbar.
- Status-Effekte (DEF-Down, ATK-Up, Silence) wirkungslos.

### Geplante Änderungen
- Faktor 2 aus Spieler-Schadensformel entfernen (Ziel: 3–6 Runden pro Kampf).
- `Defend`-Action setzt für eine Runde `Defending`-Flag; Schaden halbiert.
- `While-Away` nur einmal pro Stunde oder pro Sitzung ausführen (`Meta.LastWhileAway`).
- Crafting: Haltbarkeit `$durKey = 10` setzen vor `Save-PetState`.
- Mystery Stew: `Stat`/`Value` direkt statt verschachteltem `Buff`.
- Memory: `$mem.Text` ausgeben; Glitch Shard als `@{ Icon; Text; Date }` speichern.
- `RivalActive = $false` in Defaults und Lazy Migration hinzufügen.
- Status-Effekte in Schadensberechnung einfließen lassen.

---

## 4. Arcade & Adventure

### Gefundene Probleme
- **Wordle**: Wortliste enthält Nicht-5-Buchstaben-Wörter; keine Validierung.
- **Tetris**: Game-Over zeigt Startscreen statt Ergebnis.
- **Snake**: Mehrere Richtungsänderungen pro Tick ermöglichen Selbstmord.
- **Breakout**: Ball kann in Bricks stecken bleiben.
- **Adventure Engine**: `$Host.UI.RawUI.WindowSize.Width` ohne try/catch.
- **Adventure Companion AI**: Falscher `Test-AbsurdCombo`-Aufruf; 3× Save pro Befehl.

### Geplante Änderungen
- Wordle-Liste auf `^[A-Z]{5}$` filtern; Eingabe gegen Liste validieren.
- Tetris: dedizierte Game-Over-Scene.
- Snake: pro Tick maximal eine Richtungsänderung verarbeiten.
- Breakout: Ballposition nach Kollision korrigieren (Backtrack auf Kollisionsgrenze).
- Adventure: WindowSize in try/catch mit Fallback 70.
- Absurd-Combo korrigieren; Save nur noch am Ende eines Commands.

---

## 5. Akzeptanzkriterien

- `_smoke_test.ps1`, `_integration_test.ps1`, `_e2e_test.ps1` laufen erfolgreich.
- Profil lädt mit `reload` fehlerfrei.
- Wheel-RTP liegt nach Simulation im Bereich 90–98 %.
- Baccarat/Craps/Blackjack Logik-Fehler behoben (durch Testabdeckung oder manuelle Verifikation).
- Pet-Kämpfe dauern typischerweise 3–6 Runden.

---

## 6. Risiken

- Casino-Balance-Änderungen könnten bestehende Savegames mit hohem Gold beeinflussen; das ist beabsichtigt, da aktuelles Wheel exploitbar ist.
- Pet-Schadensanpassung macht Bosse evtl. zu schwer für niedrige Levels → ggf. Boss-Skalierung ergänzen.
- Eingriffe in Engine-Game (Deck) betreffen Blackjack, Baccarat, Poker – müssen gemeinsam getestet werden.
