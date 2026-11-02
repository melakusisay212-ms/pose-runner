# Pose Runner

A game you control with your body: lean left and right, jump, and slide, tracked by the phone's front camera. Plan: see the build plan doc.

## Status: Session 1 (project skeleton and build)

What exists: a Flutter app that opens the front camera and shows the preview with the camera's details (sensor orientation, preview size). Flame is installed but not used yet.

Pass check: the APK installs on the phone, asks for camera permission, and shows you on screen.

## First-time setup (once)

1. Create a GitHub repository with a `main` branch (add a README so it is not empty).
2. In the repo, choose Add file, Create new file. Name it `.github/workflows/build.yml` and paste in the contents of the `build.yml` file that came with this project. Commit.
3. Add file, Upload files. Upload `pose_runner_s1.zip` to the repo root and commit.

## Every time after

Upload a zip to the repo root. The workflow unpacks it over the repo, deletes the zip, and builds. A zip may hold the whole project or only the changed files; files not in the zip stay as they are. Keep the folder layout inside the zip (for example `lib/main.dart`). A zip whose only top-level folder contains `pubspec.yaml` is unwrapped automatically. The zip never changes `.github/`.

## Get the APK

Repo, Actions tab, open the latest run, scroll to Artifacts, download `pose-runner-apk`. It is a zip containing `app-release.apk`: unzip it in your Files app and open the APK. Allow "install unknown apps" for your browser or Files app if Android asks.

## Notes

- The Android folder is generated during the build; `tools/patch_android.py` adds the camera permission and sets minSdk 24.
- Release builds only. A debug build is too slow to judge pose speed on a low-memory phone.
- Target test phone: Android 13 (Go edition).
