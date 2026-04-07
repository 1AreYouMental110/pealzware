# pealzware

Primary entrypoint: `loader.lua`

Repo layout:
- `core/`: shared runtime helpers and resolver metadata
- `gui/`: active GUI implementation
- `games/`: human-readable wrapper entrypoints for game-specific loads
- `modules/`: universal and place-specific modules
- `extra/`: changelog, installer, and other auxiliary payloads
- `assets/`: bundled UI assets for the active GUI
- `profiles/`: bundled profile presets and runtime seed files

Notes:
- `MainScript.lua`, `NewMainScript.lua`, and `loadstring` are kept as bootstrap shims.
- Legacy GUI values such as `old`, `classic`, `rise`, and `wurst` are normalized to the modern GUI automatically.
- BedWars and lobby place IDs are resolved through `core/manifest.lua` so renamed module files still load cleanly.
- `games/` now exposes canonical wrapper names instead of numeric place-id aliases.
- `profiles/` now uses descriptive preset names; legacy numeric profile filenames still resolve through `core/profile_manifest.lua`.
