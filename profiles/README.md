# Profiles

This folder contains bundled runtime seed files and shipped preset profiles.

## Canonical files

- `bedwars.gui.txt`: bundled GUI layout and profile list seed for the BedWars universe
- `default-bedwars-lobby.txt`: default BedWars lobby preset
- `default-bedwars-game.txt`: default BedWars gameplay preset
- `closet-cheat-bedwars-lobby.txt`: closet-cheat BedWars lobby preset
- `closet-cheat-bedwars-game.txt`: closet-cheat BedWars gameplay preset
- `gui.txt`: default GUI mode seed
- `commit.txt`: default repo ref used by runtime file fetchers

## Notes

- Old numeric profile filenames are no longer shipped in this repo.
- Runtime compatibility for old local numeric filenames is handled by `core/profile_manifest.lua`.
- Broken placeholder files that only contained `404: Not Found` were removed.
