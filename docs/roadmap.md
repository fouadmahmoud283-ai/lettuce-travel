# Build order

Each milestone is shippable and testable on its own. Do not start a milestone before the one
above it is demonstrably working, because every later milestone depends on the custody record
being correct.

## M0 — Foundation (this scaffold)
- [x] Project structure, lints, dependencies
- [x] Domain entities and repository interfaces
- [x] Theme, router skeleton with role guard, l10n (ar / en)
- [x] Documentation
- [ ] `tool/bootstrap.ps1` run: platform folders generated
- [ ] Firebase project created, `firebase_options.dart` generated
- [ ] `build_runner` produces generated files, `flutter analyze` clean

## M1 — Auth and roles
Phone OTP sign-in, super admin email sign-in, user document creation, role resolution, custom
claims, router redirect into the correct role shell, sign-out. Three empty role home screens.

**Done when** each role signs in and lands on its own navigation tree, and a parent cannot
reach an admin route by any means.

- [x] UI built against a `FakeAuthRepository` (phone-number heuristic: a number containing
  "999" signs in as the demo supervisor, anything else as the demo parent; admin uses
  `admin@lettuce.app` / `admin123`) — see `features/auth/data/repositories/fake_auth_repository.dart`
- [ ] Real Firebase phone OTP, custom claims, and user-document creation

## M2 — Admin data management
CRUD for schools, buses, routes with ordered stops (map picker), students, guardians and
supervisors. Assignment of routes to buses and supervisors, and of students to routes and
stops.

**Done when** an admin can build a complete, valid school from an empty database.

- [x] UI built: schools / buses / routes / students CRUD screens, staff (read-only), against
  fake repositories seeded with one demo school
- [ ] Map picker for stops (stops are seeded, shown read-only); guardian linking is a raw
  guardian-id text field, not a real account lookup
- [ ] Real Firestore-backed repositories

## M3 — Trips and the check-in ledger *(the core of the product)*
Trip creation, supervisor's "today" list, start / end trip, roster ordered by stop, tap to
mark on board, tap to mark dropped off, no-show, the state-machine guard, and the offline
queue with replay preserving device timestamps.

**Done when** a supervisor can run a full morning trip in airplane mode and every record
arrives correctly on reconnect.

- [x] UI and state machine built and wired to a fake `TripRepository` / `AttendanceRepository`:
  start/resume/end trip, roster grouped and ordered by stop, tap-to-check-in/out, no-show with
  confirmation, 60-second undo, absence greying, SOS/incident sheet
- [ ] The real offline queue (`OfflineCheckInQueue`) is defined but not wired into the roster
  screen yet — check-ins currently go straight to the (in-memory) repository
- [ ] Real Firestore-backed repository, with the transactional roster-snapshot-on-start behaviour

## M4 — Live tracking
Foreground-service GPS streaming while a trip is `inProgress`, RTDB writes throttled to 5s /
20m, parent live map with bus marker and stop markers, and guaranteed stop of streaming on
trip end, logout, and app kill.

**Done when** a parent watches the bus move, and the RTDB node disappears the moment the trip
ends.

- [x] UI built: a `FakeTrackingRepository` animates a bus along each route, start/stop wired to
  trip start/end, and a custom-painted schematic map (not Google Maps — no platform folders or
  API key yet) shows it live on the parent and admin live-trips screens
- [ ] Real foreground-service GPS, `google_maps_flutter`, and RTDB writes

## M5 — Notifications
FCM token registration per device, `onAttendanceWrite` picked-up and dropped-off notices,
geofence-based "approaching your stop" fired once per stop, absence and no-show notices,
notification logs, and deep links from a notification into the relevant screen.

**Done when** a parent's phone buzzes within seconds of the tap, in the right language.

## M6 — v1 extras
Parent-reported absence and its effect on the roster; SOS and incident reporting with admin
alerting; attendance history per student; admin reports with CSV export; announcements and
parent-to-school messaging.

## M7 — Hardening and release
Firestore rules test suite, offline and edge-case tests, battery profiling on a real 90-minute
route, Crashlytics wiring, Arabic copy review by a native speaker, RTL sweep of every screen,
store listings with background-location justification, and a pilot with one real route.

---

## Known risks

| Risk | Mitigation |
|---|---|
| Android OEM battery managers kill the tracking foreground service | Foreground service with a persistent notification, plus an in-app prompt to disable battery optimisation for supervisors |
| iOS suspends background location on a personal device | `UIBackgroundModes: location` with `allowsBackgroundLocationUpdates`, and keep the app foregrounded during a trip |
| SMS OTP cost and deliverability in the target region | Evaluate volume early; consider admin-issued invite codes as a fallback path |
| A supervisor forgets to end a trip | `cleanupCompletedTrips` plus an auto-end after a route's expected duration, with an admin alert |
| Wrong child tapped | Photo on every roster row, undo window of 60 seconds, and a correction flow that preserves the original record |
