# Coin Check

Bildet den militärischen Brauch des "Coin Check" ab: Ein Spieler mit eigener Münze kann per ACE-Selbstinteraktion einen Coin Check starten. Alle Spieler, die beim Start innerhalb der Reichweite (`RESPONSE_RADIUS`) stehen und ihre Münze dabei haben, müssen danach innerhalb einer festen Zeit (`RESPONSE_TIME`, beide in `script_component.hpp`) ebenfalls ihre Münze per Selbstinteraktion vorzeigen. Beim Vorzeigen wird eine Ablege-Animation gespielt und die Münze aus dem Inventar in einen gemeinsamen Bodenwaffenhalter am Ort des Checks gelegt.

Der Ablauf ist vollständig serverautoritativ, der Zustand des aktiven Checks (`GVAR(activeCheck)`: Halter, Position, teilnahmeberechtigte Spieler, Spieler mit abgelegter Münze) existiert nur auf dem Server. Die Selbstinteraktion schickt lediglich ein CBA-Event an den Server (`fnc_activate.sqf`), der entscheidet (`fnc_serverActivate.sqf`):

- **Kein Check aktiv:** Der Server startet einen neuen (`fnc_serverStart.sqf`) – er erzeugt den Bodenwaffenhalter, legt fest, wer teilnahmeberechtigt ist (lebend, in Reichweite, mit eigener Münze), legt die Münze des Initiators ab und benachrichtigt nur die Berechtigten.
- **Check aktiv, Spieler berechtigt, noch in Reichweite und hat noch nicht abgelegt:** Der Server legt die Münze in den Halter (`fnc_serverToss.sqf`) und weist den Client an, Animation zu spielen und die Münze aus dem Inventar zu entfernen (`fnc_respond.sqf`). Wurde der Halter inzwischen geleert (und damit von der Engine gelöscht), erzeugt der Server am Ort des Checks einen neuen – eine abgelegte Münze geht so nie verloren.
- **Sonst:** Der Spieler erhält die Meldung, dass er schon abgelegt hat bzw. bereits ein Check läuft.

Es kann immer nur ein Coin Check gleichzeitig laufen. Wer erst nach dem Start in Reichweite kommt, ist nicht teilnahmeberechtigt.

Sobald die Reaktionszeit abläuft, schließt der Server den Check (`fnc_evaluateCheck.sqf`): Alle Berechtigten, die ihre Münze nicht abgelegt haben, haben verloren (auch mehrere gleichzeitig möglich) – unabhängig davon, wo sie sich zu diesem Zeitpunkt befinden. Jeder von ihnen bekommt daraufhin auf seiner eigenen Maschine die in der Einstellung **Punishment** gewählte Übungsanimation (Kniebeugen, Liegestütze oder zufällig) für `PUNISHMENT_DURATION` Sekunden abgespielt.

Die persönlichen Einstellungen **Enable Coin Check** und **Punishment** kennt der Server nicht. Er behandelt daher alle Spieler gleich; Meldungen (`GVAR(notify)`) und Bestrafung werden auf dem Client verworfen, wenn der Spieler nicht teilnimmt.

## Konfiguration

- **Münz-Datenbank (`db.hpp`)**: Ein Eintrag pro Spieler, fortlaufend nummeriert ohne Lücken: `class GVAR(coin_1): GVAR(coin_base) { uid = "76561198000000000"; displayName = "..."; };`. Die `uid` bestimmt die Zuordnung zum Spieler, der `displayName` sollte den Besitzer erkennbar machen (z.B. `"Coin (Andx)"`) - so lässt sich die eigene Münze auch nach einem Check wieder aus dem Haufen im Bodenwaffenhalter heraussuchen. Die Zuordnung UID → Item wird einmalig beim Laden des Addons in eine HashMap eingelesen.
  **Wichtig:** Jede neue Münzklasse aus `db.hpp` muss zusätzlich in `weapons[]` in `config.cpp` (CfgPatches) eingetragen werden. Ohne diesen Eintrag existiert die Klasse zwar im Config (sichtbar per `isClass`/Config Viewer), wird von der Engine aber nicht als echter Inhalt erkannt - `addItem` schlägt dann mit "not found" fehl.
  Zusätzlich muss jede Münze in `crate.hpp` stehen, dem Inhalt der Münzkiste (siehe unten).
  Alle drei Dateien werden von [`tools/sync_coin_db.py`](../../tools/sync_coin_db.py) automatisch gegen die aktuelle Squad-Mitgliederliste abgeglichen (neue Mitglieder werden ergänzt, bestehende Einträge bleiben unangetastet); das Skript läuft wöchentlich (oder manuell per "Run workflow") über `.github/workflows/sync-coin-db.yml` und öffnet bei neuen Mitgliedern einen Pull Request. Releases bauen ausschließlich aus dem eingecheckten Stand, damit die Zuordnung Klassenname → UID über Releases hinweg stabil bleibt. Das Skript kann auch lokal ausgeführt werden.
- **Münzkiste (`GVAR(coinCrate)`, "Challenge Coin Crate")**: Eine Kiste im Eden-Editor und in Zeus, die genau eine Münze jedes Spielers enthält, z.B. um verlorene Münzen nachzuverteilen. Der Inhalt steht in `crate.hpp`; `tools/coin_db_validator.py` prüft, dass er mit `db.hpp` übereinstimmt.
- **Enable Coin Check**: Persönliche (Client-)Einstellung. Jeder Spieler entscheidet selbst, ob er an Coin Checks teilnimmt.
- **Enable Coin Distribution**: Globale (Mission-)Einstellung für Missionsbauer. Deaktiviert die automatische Münzausgabe komplett - da niemand mehr eine Münze erhält, ist damit auch das gesamte Feature für die Mission abgeschaltet.
- **Punishment**: Persönliche (Client-)Einstellung. Legt fest, welche Übung ein Spieler nach einem verlorenen Coin Check machen muss (Kniebeugen, Liegestütze oder zufällig, Standard: zufällig).
- **Response Radius / Response Time / Punishment Duration**: Feste Werte, keine Einstellungen - `RESPONSE_RADIUS`, `RESPONSE_TIME` und `PUNISHMENT_DURATION` in `script_component.hpp`.

Die Münzen werden einmalig pro Mission automatisch verteilt, sobald ein in der Datenbank gelisteter Spieler einsatzbereit ist (kein erneutes Verteilen nach dem Verlieren der Münze bei einem Check).

## Maintainer

- Andx
