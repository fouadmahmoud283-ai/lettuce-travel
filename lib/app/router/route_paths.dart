/// Every route path in the app. Never type a path as a string literal elsewhere.
abstract final class RoutePaths {
  // --- Shared ---
  static const String splash = '/';
  static const String phoneSignIn = '/sign-in';
  static const String otpVerify = '/sign-in/otp';
  static const String adminSignIn = '/sign-in/admin';
  static const String settings = '/settings';

  // --- Super admin ---
  static const String adminHome = '/admin';
  static const String adminSchools = '/admin/schools';
  static const String adminBuses = '/admin/buses';
  static const String adminRoutes = '/admin/routes';
  static const String adminStudents = '/admin/students';
  static const String adminUsers = '/admin/users';
  static const String adminLiveTrips = '/admin/live';
  static const String adminReports = '/admin/reports';
  static const String adminIncidents = '/admin/incidents';
  static const String adminAnnouncements = '/admin/announcements';

  // --- Bus supervisor ---
  static const String supervisorHome = '/supervisor';
  static const String supervisorTrip = '/supervisor/trip/:tripId';
  static const String supervisorRoster = '/supervisor/trip/:tripId/roster';
  static const String supervisorIncident = '/supervisor/trip/:tripId/incident';

  // --- Parent ---
  static const String parentHome = '/parent';
  static const String parentChild = '/parent/child/:studentId';
  static const String parentLiveMap = '/parent/child/:studentId/live';
  static const String parentHistory = '/parent/child/:studentId/history';
  static const String parentReportAbsence = '/parent/child/:studentId/absence';
  static const String parentMessages = '/parent/messages';

  /// Builds a concrete path from a template, e.g.
  /// `RoutePaths.of(RoutePaths.parentChild, {'studentId': 'stu_01'})`.
  static String of(String template, Map<String, String> params) {
    var path = template;
    params.forEach((String key, String value) {
      path = path.replaceAll(':$key', value);
    });
    return path;
  }
}
