# Pose Runner

A game you control with your body: lean left and right, jump, and slide, tracked by the phone's front camera. Plan: see the build plan doc.

## Status: Session 2 (pose go / no-go)

What exists: the front camera with a live skeleton drawn on top (ML Kit pose detection), live FPS and model time, a Fast / Accurate model switch, a Low / Medium camera resolution switch, and a 60 second speed test that ends with PASS or FAIL.

Pass check (see the plan doc):
- Skeleton follows you correctly. Raise your LEFT hand and the dots on the LEFT side of the screen must move (the screen acts like a mirror).
- The 60 second test passes: average at least 15 FPS and no second below 10 FPS. These numbers are our starting choice.

Session 1 (camera opens) passed on the Android 13 Go test phone.

## Files

- `lib/main.dart`: the test screen.
- `lib/pose/`: pose models, camera-frame maths, ML Kit source, skeleton drawing, speed test logic.
- `lib/camera_status.dart`: camera start-up helpers from Session 1.
- `test/`: unit tests for the pure logic (maths, FPS counting, speed test rules).

## Build and install

Upload the session zip to the repo root without unzipping it. The workflow unpacks it over the repo, deletes the zip, and builds. A zip may hold only the changed files. Then: Actions tab, latest run, Artifacts, download `pose-runner-apk`, unzip it, install `app-release.apk` over the old app.

## Notes

- The Android folder is generated during the build; `tools/patch_android.py` adds the camera permission and sets minSdk 24.
- Release builds only. A debug build is too slow to judge pose speed on a low-memory phone.
- Target test phone: Android 13 (Go edition).
