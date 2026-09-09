# Lettuce Travel — Product Requirements (v1)

Captured from the requirements interview. Anything not listed here is out of scope for v1.

## 1. Problem

Parents of nursery and school children have no reliable visibility into the daily bus
journey. They do not know whether their child boarded, where the bus is, when it will reach
their stop, or who received the child at drop-off. Schools handle this with phone calls and
paper lists, which fail exactly when they matter.

## 2. Users

### Super admin (school operator)
Sets up and runs the system. Not a daily user of the bus flow.

- Create and edit schools, buses, routes, and stops
- Register students; link each student to guardians, a route and a home stop
- Create supervisor accounts and assign them to routes
- View live status of all active trips
- Read attendance history, export reports
- Receive incident and SOS alerts
- Broadcast announcements to parents

### Bus supervisor (rides the bus)
The only user who creates the custody record. Uses the app while standing on a moving bus.

- See today's assigned trips
- Start a trip; the roster for that route loads, ordered by stop
- Tap a child to mark **on board**; tap again at their stop to mark **dropped off**
- Mark a child **no-show** when they do not appear
- See which children are already reported **absent** by their parent (greyed out, not counted)
- Raise an SOS / incident (breakdown, accident, medical, other)
- End the trip

### Parent (guardian)
The audience for everything the supervisor does.

- See their children and each child's route, stop and supervisor
- Live map of the bus while a trip that carries their child is in progress
- Push notification when their child is picked up and when dropped off
- Push notification when the bus approaches their stop
- Report an absence for a given day ("not riding today")
- View their child's ride history
- Receive school announcements; message the school

## 3. The daily flow

**Morning pickup** — supervisor starts the trip at the depot or first stop. GPS streaming
begins. The bus travels stop to stop; at each stop the supervisor taps the children boarding.
Each tap notifies that child's guardians. Parents ahead on the route get an "approaching your
stop" alert. At school arrival the supervisor marks all on-board children as dropped off, and
ends the trip. GPS streaming stops.

**Afternoon drop-off** — the reverse. Children are checked in at school, then checked out at
each home stop, with the guardian receiving the notification at the moment of handover.

## 4. Functional requirements

| ID | Requirement |
|---|---|
| FR-1 | Phone + SMS OTP sign-in for parents and supervisors; email + password for super admin |
| FR-2 | Role is resolved from the user record and determines the entire navigation tree |
| FR-3 | A supervisor can only start trips for routes assigned to them |
| FR-4 | A check-in records: student, trip, status, device timestamp, server timestamp, GPS coordinate, and the acting supervisor |
| FR-5 | `droppedOff` is rejected unless the student is currently `onBoard` in the same trip |
| FR-6 | Check-ins performed offline are queued locally and synced on reconnect, preserving the original device timestamp |
| FR-7 | GPS is streamed to Realtime Database only while a trip is `inProgress`, at most every 5 seconds or 20 metres |
| FR-8 | Parents of students on an active trip can read that trip's live location; nobody else can |
| FR-9 | Notifications fire for: picked up, dropped off, bus approaching your stop, absence / no-show |
| FR-10 | "Approaching your stop" is triggered by a geofence around the stop or by an ETA threshold, and fires once per stop per trip |
| FR-11 | A parent can report an absence for a future or current date; the supervisor's roster reflects it |
| FR-12 | A supervisor can raise an incident with type, severity, note and location; admin and affected parents are alerted |
| FR-13 | Attendance history is queryable per student and per trip, and exportable by the admin for a date range |
| FR-14 | Admin can publish announcements to all parents in a school, or to one route |
| FR-15 | All screens work in Arabic (RTL) and English (LTR); Arabic is the default |

## 5. Non-functional requirements

- **Reliability over richness.** A missed check-in notification is a product failure.
- Check-in tap to local state change: under 100ms. Tap to parent notification: under 10s on
  a normal connection.
- The supervisor screen must remain fully usable with no network, degrading only in that
  notifications are delayed.
- Battery: a 90-minute route must not consume more than roughly 15% of a mid-range phone's
  battery.
- Tenant isolation is enforced server-side in Firestore rules, not only in the client.
- Crash-free session rate target: 99.5%.

## 6. Out of scope for v1

QR or NFC check-in; trip path replay and history maps; always-on bus tracking; a separate web
admin dashboard (the architecture allows it later); driver as a distinct role; route
optimisation and automatic ETA from a routing engine; payments and fee collection; parent
handover confirmation codes.

## 7. Open questions

- Does the school issue a device to the supervisor, or does the supervisor use a personal
  phone? (Affects background location permission strategy and battery expectations.)
- Which SMS provider region and volume — Firebase phone auth pricing depends on it.
- Is there an existing student information system to import from (CSV, API)?
- Retention period for attendance records, and any local data-protection requirements for
  children's data.
