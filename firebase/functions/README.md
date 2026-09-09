# Cloud Functions

Server-side logic that must not live in the client. See
[../../docs/firebase-setup.md](../../docs/firebase-setup.md) section 7 for the full table.

Not yet implemented. When starting, scaffold with:

```bash
firebase init functions   # TypeScript, in this directory
```

The first two to build, in order:

1. **`onAttendanceWrite`** — Firestore trigger on `attendance/{id}`. On a transition to
   `onBoard` or `droppedOff`, send an FCM message to every uid in the record's `guardianIds`,
   in each recipient's own locale, and write a `notificationLogs` entry. Notification failure
   must never roll back the attendance write.
2. **`onTripLocationUpdate`** — Realtime Database trigger on `/liveTrips/{tripId}/location`.
   Compare the position against the geofence of each stop still ahead on the route; when the
   bus enters one, notify the guardians of the children at that stop and add the stop id to
   the trip's `notifiedStopIds` so it fires only once per trip.

Both need the Admin SDK, which bypasses security rules — be explicit about the tenant
(`schoolId`) in every query you write there.
