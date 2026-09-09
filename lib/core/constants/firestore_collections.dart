/// Single source of truth for every backend path.
///
/// Never write a collection name as a string literal anywhere else in the app;
/// these names are also referenced by firebase/firestore.rules and by the Cloud
/// Functions, and they must move together.
abstract final class FsCollections {
  static const String users = 'users';
  static const String schools = 'schools';
  static const String buses = 'buses';
  static const String routes = 'routes';
  static const String students = 'students';
  static const String trips = 'trips';
  static const String attendance = 'attendance';
  static const String absences = 'absences';
  static const String incidents = 'incidents';
  static const String announcements = 'announcements';
  static const String threads = 'threads';
  static const String messages = 'messages';
  static const String notificationLogs = 'notificationLogs';
}

/// Realtime Database paths. Live GPS only — see docs/data-model.md.
abstract final class RtdbPaths {
  static const String liveTrips = 'liveTrips';

  static String trip(String tripId) => '$liveTrips/$tripId';

  static String tripMeta(String tripId) => '${trip(tripId)}/meta';

  static String tripLocation(String tripId) => '${trip(tripId)}/location';
}

/// Cloud Storage paths.
abstract final class StoragePaths {
  static String studentPhoto(String schoolId, String studentId) =>
      'schools/$schoolId/students/$studentId.jpg';

  static String schoolLogo(String schoolId) => 'schools/$schoolId/logo.png';

  static String incidentAttachment(String incidentId, String fileName) =>
      'incidents/$incidentId/$fileName';
}
