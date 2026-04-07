# Module Layout

This repo is now BedWars-only.

## Edit Here

- `bedwars-main.lua`: the main file to edit for BedWars features

## What It Contains

- shared BedWars setup
- in-game BedWars modules
- lobby BedWars modules
- Cheat Engine fallbacks
- PEALZ-specific feature layers

## Place-id aliases

- `6872274481`, `8444591321`, `8560631822` -> `bedwars-main.lua`
- `6872265039` -> `bedwars-main.lua`

## Notes

- The old split BedWars files were collapsed into `bedwars-main.lua` so you do not have to guess where to edit features.
- Search for the feature name or for `CreateModule({` inside `bedwars-main.lua` to find a module quickly.
- Legacy GUI themes were removed. Any saved `old`, `classic`, `rise`, or `wurst` GUI setting is now normalized to the modern GUI.
