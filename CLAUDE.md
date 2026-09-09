# CLAUDE.md

**Read [AGENTS.md](AGENTS.md) first and in full.** It is the single source of truth for this
repository: product scope, locked architectural decisions, folder map, domain glossary,
safety-critical invariants, coding conventions, and commands.

This file adds only the Claude Code specifics.

## Quick orientation

**Lettuce Travel** — a school and nursery bus transport safety app in Flutter. Three roles:
super admin, bus supervisor, parent. A supervisor checks children on and off the bus by
tapping their names on a route roster; parents get instant notifications and a live map of
the bus while the trip is running.

Stack: Flutter + Riverpod + go_router + freezed + Firebase (Firestore, Realtime Database for
GPS, Auth via phone OTP, FCM, Cloud Functions). Arabic-first with English, RTL.

## Before you start a task

1. Read `AGENTS.md` sections 2 (locked decisions) and 5 (invariants).
2. Read `docs/data-model.md` if the task touches data.
3. Check whether the file you are about to create already exists in the feature's layer.

## Environment note

The Flutter SDK is **not installed on this machine** and `android/` and `ios/` do not exist
yet. `flutter analyze` and `flutter test` cannot run here until someone installs Flutter and
runs `tool/bootstrap.ps1`. Do not report code as "verified" when you could not compile it —
say plainly that it is unverified.

## Verification, when the SDK is available

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

`flutter analyze` must be clean before you call a task done.

## Things that are easy to get wrong here

- **Codegen.** Editing a `@freezed` / `@riverpod` / `@JsonSerializable` file without running
  `build_runner` leaves the project uncompilable. The `.freezed.dart` and `.g.dart` files are
  gitignored and are *expected* to be missing in a fresh clone.
- **RTL.** Arabic is the default locale. `left` / `right` in padding or alignment is a bug.
- **Localization.** Any new user-facing string needs a key in both `lib/l10n/app_ar.arb` and
  `lib/l10n/app_en.arb`.
- **Layering.** `domain/` is pure Dart. A Firebase import there is a design error, not a
  detail.
- **Tracking lifecycle.** GPS must stop when a trip ends. Treat any change near
  `features/tracking` as safety-critical and re-check that path.

## Asking versus assuming

Make ordinary implementation calls yourself. Come back to the user before changing anything
in the locked-decisions table in `AGENTS.md` section 2, or before storing a new category of
personal data about a child.
