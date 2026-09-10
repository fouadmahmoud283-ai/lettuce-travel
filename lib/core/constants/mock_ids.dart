/// Fixed identifiers shared by every fake in-memory repository.
///
/// The scaffold has no backend yet (see AGENTS.md section 9), so each
/// `features/*/data/repositories/fake_*_repository.dart` seeds its own
/// in-memory data. These ids — and the small relationship maps below — are the
/// glue that keeps the seeds consistent with each other: the supervisor's mock
/// trip, the parent's mock children and the admin's mock roster all resolve to
/// the same school, routes and stops.
///
/// Delete this file once real Firestore-backed repositories replace the fakes.
abstract final class MockIds {
  static const String schoolId = 'sch_01';

  static const String busIdA = 'bus_01';
  static const String busIdB = 'bus_02';

  static const String routeIdA = 'rt_01';
  static const String routeIdB = 'rt_02';

  static const String stopId1 = 'stp_01';
  static const String stopId2 = 'stp_02';
  static const String stopId3 = 'stp_03';
  static const String stopId4 = 'stp_04';
  static const String stopId5 = 'stp_05';

  static const String adminUid = 'uid_admin_01';
  static const String supervisorUidA = 'uid_sup_01';
  static const String supervisorUidB = 'uid_sup_02';
  static const String parentUidA = 'uid_par_01';
  static const String parentUidB = 'uid_par_02';
  static const String parentUidC = 'uid_par_03';

  static const String studentId1 = 'stu_01';
  static const String studentId2 = 'stu_02';
  static const String studentId3 = 'stu_03';
  static const String studentId4 = 'stu_04';
  static const String studentId5 = 'stu_05';
  static const String studentId6 = 'stu_06';

  /// Roster snapshot a trip on this route takes when it starts.
  static const Map<String, List<String>> studentIdsByRoute =
      <String, List<String>>{
    routeIdA: <String>[studentId1, studentId2, studentId3],
    routeIdB: <String>[studentId4, studentId5, studentId6],
  };

  /// Guardians notified for each student's check-ins.
  static const Map<String, List<String>> guardianIdsByStudent =
      <String, List<String>>{
    studentId1: <String>[parentUidA],
    studentId2: <String>[parentUidA],
    studentId3: <String>[parentUidA, parentUidB],
    studentId4: <String>[parentUidB],
    studentId5: <String>[parentUidC],
    studentId6: <String>[parentUidC],
  };

  static const Map<String, String> busIdByRoute = <String, String>{
    routeIdA: busIdA,
    routeIdB: busIdB,
  };

  static const Map<String, String> supervisorIdByRoute = <String, String>{
    routeIdA: supervisorUidA,
    routeIdB: supervisorUidB,
  };

  static const Map<String, String> routeIdBySupervisor = <String, String>{
    supervisorUidA: routeIdA,
    supervisorUidB: routeIdB,
  };

  /// Display names, since there is no `UserRepository` yet to look staff up
  /// by id — only `AppUser` documents for the signed-in user themselves.
  static const Map<String, String> supervisorNames = <String, String>{
    supervisorUidA: 'Mona Youssef',
    supervisorUidB: 'Khaled Reda',
  };

  /// Recovers a route id from a `Trip.buildId` string. Safe only because this
  /// mock world has exactly two routes — a real implementation reads
  /// `Trip.routeId` from the document instead of parsing its id.
  static String routeIdFromTripId(String tripId) =>
      tripId.contains(routeIdA) ? routeIdA : routeIdB;

  /// The `yyyy-MM-dd` prefix of a `Trip.buildId` string. Safe because
  /// `serviceDate` is the only segment before the first underscore.
  static String serviceDateFromTripId(String tripId) => tripId.split('_').first;
}
