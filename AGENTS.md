# AGENTS.md — Lettuce Travel

Operating guide for AI agents (Claude Code and others) working in this repository.
**Read this file fully before your first edit.** It encodes decisions that were made
deliberately in a requirements interview; do not silently re-litigate them.

---

## 1. What this product is

**Lettuce Travel** is a school & nursery bus transport safety app. It exists to answer one
question for a parent, reliably, every single school day:

> Where is my child right now, and who has them?

The core loop:

1. A **bus supervisor** starts a trip on their assigned route.
2. As each child boards, the supervisor taps that child's name on the roster, the child is
   marked **on board**, and the parent is notified instantly with a timestamp.
3. While the trip is active the supervisor's device streams GPS; **parents** on that route
   watch the bus move on a live map and get an alert when it approaches their stop.
4. At drop-off the supervisor taps the child again, marking **dropped off**; the parent is
   notified.
5. A **super admin** configures the whole world: schools, buses, routes, stops, students,
   guardians, supervisors, and reads attendance history and incident reports.

Every feature must serve that loop. If a proposed change does not make pickup/drop-off
safer, faster, or more transparent, it is out of scope for v1.

---

## 2. Locked decisions (do not change without the user saying so)

| Area | Decision |
|---|---|
| Backend | **Firebase** — Auth, Firestore, Realtime Database (GPS only), Storage, FCM, Cloud Functions, Crashlytics |
| Architecture | **Riverpod + feature-first clean architecture** (`data` / `domain` / `presentation`) |
| Routing | **go_router** with role-based redirect guards |
| Models | **Domain entities are plain immutable Dart** (no codegen, always compiles). **freezed + `json_serializable` are for data-layer models** that cross the Firestore boundary |
| Localization | **Arabic + English, RTL-first.** Arabic is the default locale |
| Check-in method | **Tap the child's name on the route roster.** No QR, no NFC in v1 |
| Auth | **Phone number + SMS OTP** for parents and supervisors; email + password for super admin |
| GPS | **Live only while a trip is in progress.** Streaming stops the moment the trip ends |
| Admin surface | **Same Flutter app**, admin role, structured so a web build can be added later |
| Trips | **Two per bus per school day**: `morningPickup`, `afternoonDropoff` |
| Guardians | A child has **many guardians**; all linked guardians receive notifications |
| Offline | Check-ins are **queued locally and synced on reconnect** with their original timestamps |
| Maps | **Google Maps** (`google_maps_flutter`) |
| Platforms | **Android + iOS** |
| Theme | **Material 3**, friendly school palette, large tap targets, light + dark |
| Package | Dart package `lettuce_travel`, bundle id `com.lettucetravel.app` |

**In scope for v1 extras:** parent-reported absence, emergency SOS / incident reporting,
attendance history + admin reports, in-app announcements and messaging.

**Notifications shipped in v1:** picked up, dropped off, bus approaching your stop, and
absence / no-show. Trip started and trip ended are deliberately *not* in v1.

---

## 3. Repository map

```
lib/
├── main.dart                  # entry point -> bootstrap()
├── bootstrap.dart             # Firebase init, error zone, Crashlytics, ProviderScope
├── app/
│   ├── app.dart               # MaterialApp.router, locale + theme wiring
│   ├── router/                # go_router config + role redirect guard + route paths
│   ├── theme/                 # Material 3 color scheme, typography, spacing tokens
│   └── localization/          # locale controller + l10n helpers
├── core/                      # cross-feature, NEVER imports from features/
│   ├── config/                # AppConfig, firebase_options.dart (gitignored)
│   ├── constants/             # Firestore collection & RTDB path names, single source of truth
│   ├── errors/                # Failure, AppException
│   ├── extensions/            # BuildContext / DateTime helpers
│   ├── providers/             # Firebase instance providers, connectivity provider
│   ├── services/              # location, notification, offline-queue services
│   ├── utils/                 # Result<T>, AppLogger, geo helpers
│   └── widgets/               # shared UI atoms (buttons, state views, avatars)
├── features/
│   ├── auth/                  # phone OTP, session, current-user + role resolution
│   ├── schools/               # School, Bus, BusRoute, RouteStop
│   ├── students/              # Student + guardian links
│   ├── trips/                 # Trip lifecycle (start / progress / end)
│   ├── attendance/            # AttendanceRecord, the check-in/check-out ledger
│   ├── tracking/              # GPS streaming (write) + live map (read)
│   ├── notifications/         # FCM tokens, handlers, local notifications
│   ├── incidents/             # SOS / incident reports
│   ├── messaging/             # announcements + chat
│   ├── admin/                 # super-admin presentation only
│   ├── supervisor/            # supervisor presentation only
│   └── parent/                # parent presentation only
└── l10n/                      # app_ar.arb, app_en.arb
```

### The three role features are presentation-only

`features/admin`, `features/supervisor` and `features/parent` contain **screens and widgets
only**. They consume domain entities and repositories from the domain features (`trips`,
`attendance`, `students`, `tracking`, ...). Never put a repository, an entity, or a Firestore
call inside a role feature.

### Dependency rule

```
presentation  ->  domain  <-  data
core  <-  everything        (core imports nothing from features/)
```

`domain/` is pure Dart: no `cloud_firestore`, no `flutter/material.dart`, no Firebase imports.
If you find yourself importing Firestore into `domain/`, the code is in the wrong layer.

---

## 4. Domain glossary

Use these exact terms in code, comments, commits and UI strings. Do not invent synonyms.

| Term | Meaning |
|---|---|
| **School** | A nursery or school tenant. Everything else hangs off a `schoolId` |
| **Bus** | A physical vehicle: plate number, capacity, driver name |
| **BusRoute** | An ordered list of `RouteStop`s served by one bus, with an assigned supervisor |
| **RouteStop** | A named pickup/drop-off point with lat/lng and a geofence radius |
| **Student** | A child. Has one home `stopId`, one `routeId`, and many `guardianIds` |
| **Guardian** | A parent-role `AppUser` linked to one or more students |
| **Supervisor** | The adult riding the bus who performs check-ins. Never called "driver" |
| **Trip** | One run of a route on one date: `morningPickup` or `afternoonDropoff` |
| **AttendanceRecord** | Per-student, per-trip ledger row. The record of custody |
| **Check-in** | Marking a child **on board** |
| **Check-out** | Marking a child **dropped off** |
| **LocationPing** | One GPS sample written to RTDB during an active trip |

`AttendanceStatus`: `pending -> onBoard -> droppedOff`, plus the terminal states `absent`
(parent reported in advance) and `noShow` (supervisor waited, child never appeared).

---

## 5. Invariants — safety-critical, never break these

1. **An attendance record is append-only in spirit.** Never delete one. Corrections write a
   new state with `correctedBy` / `correctionReason` and keep the original timestamps.
2. **Timestamps come from the device clock at the moment of the tap**, stored alongside the
   server timestamp. Offline check-ins must preserve the real tap time; never re-stamp on
   sync.
3. **Never mark a child `droppedOff` without a preceding `onBoard`** in the same trip. The UI
   must make the invalid transition impossible, and the repository must reject it.
4. **GPS streaming starts only on `TripStatus.inProgress` and must stop on trip end,** app
   termination, or logout. A bus that is not on a trip is not tracked. Re-verify this on every
   change to the tracking feature.
5. **A parent can only ever read data about their own linked students.** Enforce this in
   Firestore security rules *and* in queries. Never fetch a whole school's students into a
   parent-facing build.
6. **Every check-in and check-out sends a notification.** If notification dispatch fails, the
   attendance write still succeeds and dispatch is retried; never the reverse.
7. **Every Firestore document carries `schoolId`.** All queries filter on it. This is the
   tenant boundary.
8. **No location history is retained after a trip completes** beyond the aggregate trip
   summary, unless the user explicitly asks for trip replay (currently out of scope).

---

## 6. Conventions

**Files and naming**
- Files `snake_case.dart`; classes `PascalCase`; providers `camelCaseProvider`.
- One public class per file, named after the file.
- Screens end in `Screen`, reusable widgets in `Card` / `Tile` / `View`, controllers in
  `Controller`.

**State**
- The scaffold uses hand-written Riverpod providers so the tree compiles before any codegen
  has run. Once `build_runner` is wired up, prefer generated providers (`@riverpod`) for new
  work, and run `build_runner` afterwards.
- Async UI state is `AsyncValue`, rendered with `.when(data:, loading:, error:)`. Never
  hand-roll `isLoading` booleans.
- Controllers hold no `BuildContext`. Navigation happens in the widget layer.

**Errors**
- Repositories return `Result<T>` (`Ok` / `Err(Failure)`); they do not throw across layers.
- Every `Failure` has a `messageKey` resolving to a localized string. No raw exception text
  in the UI, ever.

**Strings**
- Zero hardcoded user-facing strings. Everything goes through `context.l10n.someKey`.
- Add each key to **both** `app_ar.arb` and `app_en.arb` in the same change.
- Arabic is the default locale. Check RTL layout on every screen you touch: use
  `EdgeInsetsDirectional` and `start` / `end`, never `left` / `right`.

**Accessibility and field usability**
- Supervisor tap targets 56dp or larger. Supervisors use this one-handed, standing, on a
  moving bus.
- Check-in actions need visible confirmation feedback: haptic, state change, and row colour.
- Never place a destructive action adjacent to a check-in control.

**Logging**
- Use `AppLogger`; `print` is a lint error.
- Never log a student's full name, a phone number, or a precise coordinate at info level.

---

## 7. Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
dart run custom_lint
dart format lib test
flutter test
flutter run -t lib/main.dart
```

**After changing any `@freezed`, `@JsonSerializable` or `@riverpod` annotated file you must
run `build_runner`, or the project will not compile.**

Platform folders (`android/`, `ios/`) are generated. See `tool/bootstrap.ps1`.

---

## 8. Working agreement for agents

- **Before adding a dependency**, check `pubspec.yaml`; the stack is already chosen. A new
  package needs a stated reason.
- **Before creating a file**, check whether the feature folder already has the layer you need.
  Do not create parallel structures.
- **Keep changes inside one feature** where possible. A change that touches all three role
  features usually belongs in a domain feature or in `core/`.
- **Do not write Firestore queries in widgets.** Widget -> controller -> repository ->
  datasource.
- **Do not mock away the safety path in tests.** Attendance transitions, offline queue replay,
  and the tracking start/stop lifecycle get real unit tests.
- **Update `docs/` when behaviour changes.** `docs/data-model.md` is the contract between the
  app and the security rules in `firebase/firestore.rules`.
- **Placeholders are marked `// TODO(scaffold):`.** These are intentional stubs. Replacing one
  is normal work; leaving a *new* one behind needs a comment explaining what is blocked.
- **Ask the user before**: changing the auth method, changing the check-in interaction, adding
  always-on tracking, adding a third-party analytics or ads SDK, or storing any new category
  of personal data about a child.

---

## 9. Current scaffold status

This repository has a **fully built UI for all three roles, backed by in-memory fake
repositories** — not yet a working app against a real backend.

Done:
- Full folder architecture, lint rules, dependency set
- Domain entities for every core concept, as plain Dart (compile without codegen)
- Repository interfaces for every feature, including `schools` (school / bus / route) and a new
  `features/messaging/` (announcements + chat), which the original scaffold had left as entities
  or folders without interfaces
- `Fake*Repository` implementations (`features/*/data/repositories/fake_*_repository.dart`) —
  in-memory, no Firebase, seeded from `lib/core/constants/mock_ids.dart` so the supervisor's
  trip, the parent's children and the admin's roster all resolve to the same consistent mock
  school. **Deliberately hand-written Riverpod providers, no `@riverpod` codegen** — the whole
  UI compiles without `build_runner`, only `flutter pub get`
- Full screens for all three roles: auth (phone OTP + admin email, both against the fake), the
  supervisor trip roster (check-in / check-out / no-show / undo / end trip / SOS — the core
  loop), the parent app (children, live status, a schematic live-map view, ride history, absence
  reporting, announcements + messages), and the admin app (dashboard, schools / buses / routes /
  students CRUD, staff, live trips, a date-range attendance report, incidents, announcements)
- Firestore + Realtime Database security rules, and the composite index definitions
- Unit tests for the custody state machine and the stop-geofence maths
- Theme, routing with role guard covering every new screen, l10n setup (ar / en) with the
  `AppL10n` delegate wired into `MaterialApp.router` and every string added to both arb files
- Documentation: PRD, data model, Firebase setup, roadmap

Not done / known gaps:
- Platform folders — run `tool/bootstrap.ps1` (needs the Flutter SDK, which is not installed
  on this machine yet). **None of this has been compiled or run** — see the environment note in
  CLAUDE.md
- No Firebase project: every repository is the in-memory fake, not `FirebaseAuthRepository` /
  `FirestoreXRepository` / etc. `lib/core/config/firebase_options.dart` — run `flutterfire
  configure`
- Real Google Maps (`google_maps_flutter`) — the live-tracking views use a custom-painted
  schematic route diagram instead (`features/tracking/presentation/widgets/route_map_view.dart`),
  clearly labelled as such, pending platform folders and an API key
- The offline check-in queue (`OfflineCheckInQueue`) has no implementation wired into the roster
  screen yet — check-ins go straight to the fake repository
- No route-stop CRUD in the admin app (stops are seeded, shown read-only); no guardian-account
  linking beyond typing a raw guardian id
- Push notifications, FCM token registration, and Crashlytics are still stubs

Read `docs/roadmap.md` for the intended build order.
