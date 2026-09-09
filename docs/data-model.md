# Data model

This document is the contract between the app and `firebase/firestore.rules`. Change both
together.

Two stores are used deliberately:

- **Cloud Firestore** — everything durable and queryable.
- **Realtime Database** — live GPS pings only. High write frequency, low cost, low latency,
  ephemeral.

Collection and path names live in `lib/core/constants/firestore_collections.dart`. Never type
a collection name as a string literal anywhere else.

---

## Firestore

### `users/{userId}`

```jsonc
{
  "id": "uid",
  "phone": "+201234567890",       // null for super admin
  "email": "admin@school.com",    // null for parent / supervisor
  "displayName": "Sara Ahmed",
  "role": "parent",               // superAdmin | busSupervisor | parent
  "schoolId": "sch_01",           // null only for a platform-level super admin
  "studentIds": ["stu_01"],       // parents only; denormalised for fast lookup
  "assignedRouteIds": ["rt_01"],  // supervisors only
  "fcmTokens": ["..."],
  "locale": "ar",
  "isActive": true,
  "createdAt": "<serverTimestamp>",
  "updatedAt": "<serverTimestamp>"
}
```

`role` is set only by a super admin or a Cloud Function, never by the client. Custom claims
mirror `role` and `schoolId` so security rules can check them without a document read.

### `schools/{schoolId}`

```jsonc
{
  "id": "sch_01",
  "name": "Little Stars Nursery",
  "nameAr": "حضانة النجوم الصغيرة",
  "address": "...",
  "location": { "lat": 30.04, "lng": 31.23 },
  "timezone": "Africa/Cairo",
  "contactPhone": "+20...",
  "logoUrl": null,
  "isActive": true
}
```

### `buses/{busId}`

```jsonc
{
  "id": "bus_01",
  "schoolId": "sch_01",
  "plateNumber": "أ ب ج 1234",
  "capacity": 24,
  "model": "Toyota Hiace",
  "driverName": "Mahmoud Ali",
  "driverPhone": "+20...",
  "isActive": true
}
```

### `routes/{routeId}`

```jsonc
{
  "id": "rt_01",
  "schoolId": "sch_01",
  "name": "Route A — Maadi",
  "busId": "bus_01",
  "supervisorId": "uid_sup_01",
  "stops": [
    {
      "id": "stp_01",
      "name": "Road 9 corner",
      "order": 1,
      "location": { "lat": 29.96, "lng": 31.25 },
      "geofenceRadiusMeters": 150,
      "expectedMorningTime": "07:15",
      "expectedAfternoonTime": "14:40"
    }
  ],
  "isActive": true
}
```

Stops are embedded, not a subcollection: they are always read with the route, are few, and are
edited as a unit.

### `students/{studentId}`

```jsonc
{
  "id": "stu_01",
  "schoolId": "sch_01",
  "fullName": "Yousef Hassan",
  "photoUrl": null,
  "gradeOrClass": "KG2-B",
  "routeId": "rt_01",
  "stopId": "stp_01",
  "guardianIds": ["uid_par_01", "uid_par_02"],
  "notes": "Allergic to peanuts",
  "isActive": true,
  "createdAt": "<serverTimestamp>"
}
```

`guardianIds` is the authorisation key for parents: a parent may read a student document only
if their uid is in this array.

### `trips/{tripId}`

```jsonc
{
  "id": "trp_2026_09_10_rt_01_am",
  "schoolId": "sch_01",
  "routeId": "rt_01",
  "busId": "bus_01",
  "supervisorId": "uid_sup_01",
  "type": "morningPickup",         // morningPickup | afternoonDropoff
  "status": "inProgress",          // scheduled | inProgress | completed | cancelled
  "serviceDate": "2026-09-10",     // yyyy-MM-dd, school-local
  "startedAt": "<ts>",
  "endedAt": null,
  "studentIds": ["stu_01"],        // roster snapshot at trip start
  "onBoardCount": 12,
  "completedCount": 0,
  "notifiedStopIds": ["stp_01"],   // guards the once-per-stop "approaching" alert
  "createdAt": "<ts>"
}
```

The document id is deterministic (`date + route + type`) so a trip cannot be started twice.

### `attendance/{recordId}`

The custody ledger. One document per student per trip.

```jsonc
{
  "id": "att_...",
  "schoolId": "sch_01",
  "tripId": "trp_...",
  "studentId": "stu_01",
  "guardianIds": ["uid_par_01"],   // denormalised so a parent can query without a join
  "status": "onBoard",             // pending | onBoard | droppedOff | absent | noShow
  "boardedAtDevice": "<ts>",       // clock at the moment of the tap
  "boardedAtServer": "<ts>",
  "boardedLocation": { "lat": 29.96, "lng": 31.25 },
  "droppedAtDevice": null,
  "droppedAtServer": null,
  "droppedLocation": null,
  "recordedBy": "uid_sup_01",
  "correctedBy": null,
  "correctionReason": null,
  "syncedFromOfflineQueue": false,
  "serviceDate": "2026-09-10"
}
```

Invariants enforced in rules and in the repository:
`droppedOff` requires a non-null `boardedAtDevice`; a record is never deleted; `status` may
not move backwards out of a terminal state without `correctionReason`.

### `absences/{absenceId}`

```jsonc
{
  "id": "abs_...",
  "schoolId": "sch_01",
  "studentId": "stu_01",
  "serviceDate": "2026-09-10",
  "scope": "wholeDay",             // wholeDay | morningOnly | afternoonOnly
  "reason": "Doctor appointment",
  "reportedBy": "uid_par_01",
  "createdAt": "<ts>"
}
```

### `incidents/{incidentId}`

```jsonc
{
  "id": "inc_...",
  "schoolId": "sch_01",
  "tripId": "trp_...",
  "type": "breakdown",             // breakdown | accident | medical | delay | other
  "severity": "high",              // low | medium | high | critical
  "note": "...",
  "location": { "lat": 29.96, "lng": 31.25 },
  "createdBy": "uid_sup_01",
  "createdAt": "<ts>",
  "acknowledgedBy": null,
  "resolvedAt": null
}
```

### `announcements/{announcementId}` and `threads/{threadId}/messages/{messageId}`

Announcements are school-wide or route-scoped, written by admin, read by parents. Threads are
one-to-one conversations between a parent and the school, with an unread counter per
participant.

### `notificationLogs/{logId}`

Audit trail of every dispatched notification: type, studentId, recipient uids, payload,
`sentAt`, delivery result. Needed when a parent says "I was never told".

---

## Realtime Database

```
/liveTrips/{tripId}
  ├── meta
  │   ├── schoolId, routeId, busId, supervisorId
  │   └── status, startedAt
  └── location
      ├── lat, lng
      ├── speedKmh, heading, accuracy
      └── updatedAt        (epoch millis)
```

Only the current position is stored, overwritten in place. The node is deleted when the trip
completes. No path history is retained (see invariant 8 in `AGENTS.md`).

Write rule: only the trip's assigned supervisor. Read rule: the supervisor, a school admin,
and any uid present in the trip's `guardianIds` index.

---

## Indexes required

| Collection | Fields |
|---|---|
| `students` | `schoolId` asc, `routeId` asc, `isActive` asc |
| `students` | `guardianIds` array-contains, `isActive` asc |
| `trips` | `schoolId` asc, `serviceDate` desc, `status` asc |
| `trips` | `supervisorId` asc, `serviceDate` desc |
| `attendance` | `tripId` asc, `status` asc |
| `attendance` | `guardianIds` array-contains, `serviceDate` desc |
| `attendance` | `studentId` asc, `serviceDate` desc |
| `absences` | `studentId` asc, `serviceDate` asc |

Keep this table in sync with `firebase/firestore.indexes.json`.
