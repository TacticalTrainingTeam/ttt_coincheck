# TTT Coin Check

<p align="center">
    <img src="https://github.com/TacticalTrainingTeam/ttt_coincheck/blob/main/img/icon.png" alt="TTT Coin Check Logo">
</p>

<p align="center">
    <a href="https://github.com/TacticalTrainingTeam/ttt_coincheck/issues">
        <img src="https://img.shields.io/github/issues-raw/TacticalTrainingTeam/ttt_coincheck.svg?style=flat-square&label=Issues" alt="TTT Coin Check Issues">
    </a>
    <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=0">
        <img src="https://img.shields.io/steam/downloads/0.svg?style=flat-square&label=Downloads" alt="TTT Coin Check Downloads">
    </a>
    <a href="https://github.com/TacticalTrainingTeam/ttt_coincheck/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-APL SA-red?style=flat-square" alt="TTT Coin Check License">
    </a>
    <br>
    <img src="https://img.shields.io/github/actions/workflow/status/TacticalTrainingTeam/ttt_coincheck/check.yml?style=flat-square&label=Check" alt="Check">
    <img src="https://img.shields.io/github/actions/workflow/status/TacticalTrainingTeam/ttt_coincheck/validate.yml?style=flat-square&label=Validate" alt="Validate">
</p>

__Requires__ [CBA_A3](https://github.com/CBATeam/CBA_A3) and [ACE3](https://github.com/acemod/ACE3).

__TTT Coin Check__ (TCC) recreates the military challenge-coin check: a player carrying their coin can start a check via an ACE self-action, and everyone else nearby has a limited time and range to present their own coin or pay a physical punishment.

The project is entirely __open-source__ and any contributions are welcome.

Steam Workshop: <https://steamcommunity.com/sharedfiles/filedetails/?id=0>
Discord: <https://discord.tacticalteam.de/>

## Features

- Start a coin check via an ACE self-action; everyone else with a coin and the setting enabled has a set time and range to present theirs
- Server-authoritative: the server alone creates the shared ground weapon holder and decides who's late
- Configurable per-player punishment (knee bends, push-ups, or random) for anyone who fails to present in time
- Coins are distributed automatically to registered players and kept in a database (`addons/coin_check/db.hpp`) synced against the TTT squad roster by [`tools/sync_coin_db.py`](tools/sync_coin_db.py)

See [addons/coin_check/readme.md](addons/coin_check/readme.md) for full configuration details.

## Contributing

For new contributors, see the [Contributing Setup & Guidelines](./.github/CONTRIBUTING.md).

## License

TTT Coin Check is licensed under the [Arma Public License – Share Alike](./LICENSE).
