# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- TEMPLATE: `hemtt publish` looks up the entry whose heading exactly
matches the current project version (see .hemtt/project.toml's
[version] / addons/main/script_version.hpp) -- so before publishing,
rename "[Unreleased]" below to "[X.Y.Z] - YYYY-MM-DD" matching that
version, and start a fresh empty [Unreleased] section above it. -->

## [Unreleased]

## [1.0.3] - 2026-11-12

### Added

- New coins for players added to the squad rosters

### Changed

- Registered players now receive their coin even when "Enable Coin Check" is turned off; the setting still gates the actions and punishment
- Coin distribution delay raised from 3 to 5 seconds to give mission loadout scripts more time to finish

## [1.0.2] - 2026-11-06

### Added

- New coins for players added to the squad rosters

### Fixed

- Coin check punishment no longer applies to players who opted out, or are dead, unconscious or in a vehicle; the animation reset is broadcast to all clients
- Coin no longer lost when the coin pile is missing (not yet replicated or deleted after being emptied)
- Responses no longer fail after the coin pile was emptied; tossing is now handled by the server, which recreates the pile if needed
- Coin distribution now respects a mission or server forcing distribution off

## [1.0.1] - 2026-09-18

## [1.0.0] - 2026-09-15

### Added

- Initial release, split out of [ttt_a3](https://github.com/TacticalTrainingTeam/ttt_a3)'s `add-coin-check` branch into its own mod
