# Firebase setup

Run once per environment (`dev`, `prod`). Nothing in the app works until this is done.

## 1. Prerequisites

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

## 2. Create the project

In the Firebase console create `lettuce-travel-dev`, then enable:

- **Authentication** → Phone (add test numbers for development), and Email/Password for the
  super admin
- **Cloud Firestore** → production mode, region closest to the schools
- **Realtime Database** → same region, locked mode
- **Cloud Storage** → for student photos and school logos
- **Cloud Messaging**
- **Crashlytics** and **Analytics**

## 3. Wire the Flutter app

```bash
flutterfire configure --project=lettuce-travel-dev --platforms=android,ios --out=lib/core/config/firebase_options.dart
```

This writes `lib/core/config/firebase_options.dart` (gitignored),
`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.

## 4. Deploy rules and indexes

```bash
cd firebase
firebase deploy --only firestore:rules,firestore:indexes,database
```

## 5. Google Maps keys

**Android** — `android/app/src/main/AndroidManifest.xml`, inside `<application>`:

```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_ANDROID_KEY"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_IOS_KEY")
```

Restrict each key to its bundle id / package name in the Google Cloud console.

## 6. Permissions

**Android** (`AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

`minSdkVersion` must be 23 or higher (Firebase Auth), and a foreground service with type
`location` is required for trip tracking on Android 14+.

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to show parents where the bus is during a trip.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Used to keep sharing the bus location with parents while a trip is running.</string>
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

Both stores require a clear justification for background location. Say plainly that it runs
only while a supervisor has an active trip, and that it stops when the trip ends.

## 7. Cloud Functions

`firebase/functions/` holds the server-side pieces that must not live in the client:

| Function | Trigger | Purpose |
|---|---|---|
| `onAttendanceWrite` | Firestore `attendance/{id}` write | Send the picked-up / dropped-off notification to every guardian, write `notificationLogs` |
| `onTripLocationUpdate` | RTDB `/liveTrips/{tripId}/location` write | Geofence check against upcoming stops, fire "approaching your stop" once per stop |
| `onIncidentCreate` | Firestore `incidents/{id}` create | Alert admins and affected parents |
| `setUserRoleClaims` | Callable (admin only) | Set custom claims `role` and `schoolId` |
| `nightlyTripScheduler` | Scheduled, daily | Create the day's `scheduled` trips from active routes |
| `cleanupCompletedTrips` | Scheduled, hourly | Delete stale `/liveTrips` nodes |

Deploy with:

```bash
cd firebase/functions && npm install && cd .. && firebase deploy --only functions
```

## 8. Seeding a dev environment

Create one school, one bus, one route with three stops, four students, two parent accounts
and one supervisor account. Use Firebase Auth test phone numbers so OTP does not cost money
and always returns a fixed code.
