# Coin Check

Bildet den militärischen Brauch des "Coin Check" ab: Ein Spieler mit eigener Münze kann per ACE-Selbstinteraktion einen Coin Check starten. Alle anderen Spieler mit Münze und aktivierter Einstellung haben danach eine feste Zeit (`RESPONSE_TIME`) und Reichweite (`RESPONSE_RADIUS`), beide in `script_component.hpp`, um ebenfalls ihre Münze per Selbstinteraktion vorzuzeigen. Beim Vorzeigen wird eine Ablege-Animation gespielt und die Münze aus dem Inventar in einen gemeinsamen Bodenwaffenhalter am Ort des Checks gelegt.

Der Bodenwaffenhalter wird ausschließlich vom Server erzeugt: Ein Client sendet per CBA-Event lediglich eine Startanfrage, der Server legt das Objekt an und verteilt dessen NetID an alle Clients. Das vermeidet Races durch client-seitig erzeugte Objekte und macht den Server zur alleinigen Quelle für den aktiven Check. Auch das Ablegen läuft über den Server (`fnc_serverToss.sqf`): Der Client entfernt nur die Münze aus dem Inventar, der Server legt sie in den Halter. Wurde der Halter inzwischen geleert (und damit von der Engine gelöscht), erzeugt der Server am Ort des Checks einen neuen - eine abgelegte Münze geht so nie verloren.

Es kann immer nur ein Coin Check gleichzeitig laufen - solange einer aktiv ist, lehnt der Server weitere Startanfragen ab (`GVAR(activeCheck)`, serverseitig verwaltet in `fnc_serverStart.sqf`).

Sobald die Reaktionszeit abläuft, prüft der Server (`fnc_evaluateCheck.sqf`), wer noch innerhalb der Reichweite steht und dabei immer noch seine eigene Münze bei sich trägt - diese Spieler haben nicht vorgezeigt und somit verloren (auch mehrere gleichzeitig möglich). Jeder von ihnen bekommt daraufhin auf seiner eigenen Maschine die in der Einstellung **Punishment** gewählte Übungsanimation (Kniebeugen, Liegestütze oder zufällig) für `PUNISHMENT_DURATION` Sekunden abgespielt.

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
