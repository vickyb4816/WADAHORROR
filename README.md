# Wada Horror — project status

This repository is the Godot 4 prototype for Wada Horror – Tatya Vinchu.

## Existing prototype
- First-person Laksha controller with keyboard and basic touch controls.
- Runtime-generated greybox Wada entrance.
- Golden entrance key and locked entrance door.
- Android export preset and GitHub Actions APK workflow.

## Added foundation scripts
- `scripts/wada_progress.gd`: inventory, objective, clue and progressive room-discovery state.
- `scripts/tatya_hunter.gd`: initial enemy state machine (patrol, chase, search, return). It is a reusable AI foundation and is not yet wired into the level.

## Build Android APK
1. Open the repository Actions tab.
2. Select Build Android APK.
3. Select Run workflow on `main`.
4. After a successful run, download the `WadaHorror-Android-APK` artifact.

The APK is a debug prototype build and has not been device-tested. Android export depends on the Godot version and export templates being available.

## Important limitations
The existing level is a greybox, not the complete 2–3 hour game. It does not yet include a finished Wada interior, final Tatya 3D model/animations, complete room/key progression, puzzles, final audio, endings, save/load, or full mobile UI.

The Stitch reference directory exists in the repository, but the connected GitHub file interface did not expose its child image files. Therefore no claim of pixel-accurate Stitch recreation is made. Keep those source images in the repository; when their contents are readable, implement each screen against them.

## Recommended next order
1. Inspect Stitch screen exports and map each to a Godot UI scene.
2. Build the Wada blockout with both floors, courtyard, staircase, rooms and roof access.
3. Add room-specific keys, doors, inventory and progressive map.
4. Wire Tatya AI into navigation, line-of-sight, sound investigation, hiding and chase.
5. Add clues, puzzles, missions, save/load and multiple endings.
6. Optimize and test on the target Windows PC and Android devices.
