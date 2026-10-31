# Wada Horror – Android starter (Godot 4.7.2)

This repository is an **early playable prototype**, not the complete 2–3 hour game. It currently contains a simple Wada entrance scene, Laksha first-person controller, golden entrance key and locked entrance door. Android touch controls have been added.

## Android controls

- Left-side arrows: move.
- Drag on the right side: look around.
- JUMP: jump.
- INTERACT: collect the key / unlock the entrance.

Desktop controls remain available: WASD, mouse, Space and E.

## Build an APK automatically on GitHub

1. Create a new empty repository on GitHub (for example `wada-horror`).
2. Extract this ZIP on your PC.
3. Open the extracted `WadaHorror_Android` folder.
4. Upload **the contents of this folder** to the root of your GitHub repository. The `.github/workflows/android-apk.yml` file must be included.
5. Commit the files to the `main` branch.
6. Open your repository on GitHub and select **Actions**.
7. Open **Build Android APK**. Wait for the workflow to finish successfully.
8. Open the completed workflow run and scroll to **Artifacts**.
9. Download `WadaHorror-Android-APK`. Extract the downloaded artifact ZIP to get `WadaHorror-debug.apk`.
10. Transfer the APK to your Android phone and install it. You may need to allow installation from that file manager.

Every push to `main` or `master` also starts a new APK build. You can manually start one from Actions → Build Android APK → Run workflow.

## Build locally in Godot

Use Godot **4.7.2 Standard** (not .NET). Install OpenJDK 17 and Android SDK, install the matching Godot export templates, configure the Android SDK path in Editor Settings → Export → Android, then use Project → Export → Android.

## Important limitations

- This prototype does not yet contain the full two-floor Wada, 12+ rooms, map, room-key progression, Tatya 3D model/animations/AI, audio, puzzles, save system or multiple endings.
- No reference-sheet artwork or YouTube audio is embedded in this ZIP. Add only assets you own or have permission to use.
- The GitHub workflow creates a **debug APK** for testing. A Play Store release needs a separately generated private release keystore and a release-signing setup. Never commit signing keys or passwords to GitHub.
- The workflow has been authored but has not been executed in this environment. The first GitHub Actions run is the actual build test; inspect its logs if it fails.
- Android performance depends on the phone. Test on a real device before adding heavy assets.

## Project layout

- `project.godot` – Godot project settings.
- `main.tscn` – main scene.
- `scripts/` – player, environment, key and door scripts.
- `export_presets.cfg` – Android export preset.
- `.github/workflows/android-apk.yml` – automatic APK build workflow.
