# Lettuce Travel

School and nursery bus transport safety, in one Flutter app.

A **bus supervisor** checks each child on and off the bus by tapping their name on the route
roster. Every tap notifies the child's **guardians** instantly, and while the trip is running
those guardians watch the bus move on a live map. A **super admin** configures schools, buses,
routes, students and staff, and reads the attendance record.

> **Status: scaffold.** Architecture, domain model, documentation and configuration are in
> place. Screens and data sources are stubs marked `// TODO(scaffold):`. The Flutter SDK is
> not yet installed on the development machine, so nothing here has been compiled.

## Getting started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24 or newer).
2. Generate the native platform folders and run codegen:

```bash
pwsh tool/bootstrap.ps1
```

3. Set up Firebase and the Google Maps keys — follow [docs/firebase-setup.md](docs/firebase-setup.md).
4. Uncomment the Firebase initialisation block in [lib/bootstrap.dart](lib/bootstrap.dart).
5. Run it:

```bash
flutter run
```

## Documentation

| File | What it covers |
|---|---|
| [AGENTS.md](AGENTS.md) | **Start here.** Architecture, locked decisions, conventions, invariants |
| [CLAUDE.md](CLAUDE.md) | Claude Code specifics; points at AGENTS.md |
| [docs/prd.md](docs/prd.md) | Requirements per role, the daily flow, scope boundaries |
| [docs/data-model.md](docs/data-model.md) | Firestore and Realtime Database schema, indexes |
| [docs/firebase-setup.md](docs/firebase-setup.md) | Project creation, keys, permissions, Cloud Functions |
| [docs/roadmap.md](docs/roadmap.md) | Build order, milestone exit criteria, known risks |

## Stack

Flutter · Riverpod · go_router · Material 3 · Firebase (Auth, Firestore, Realtime Database,
Storage, FCM, Cloud Functions, Crashlytics) · Google Maps · Arabic-first with English, RTL.

## Layout

```
lib/app        routing, theme, localization
lib/core       cross-feature building blocks (imports nothing from features/)
lib/features   auth, schools, students, trips, attendance, tracking,
               notifications, incidents, messaging, and the three role UIs
docs           product and technical documentation
firebase       security rules, indexes, Cloud Functions
tool           bootstrap scripts
```

## Tests

```bash
flutter test
```

The custody state machine (`test/unit/attendance_status_test.dart`) and the stop-geofence
maths (`test/unit/geo_utils_test.dart`) are covered from the start; they are the two places
where a bug reaches a child.
