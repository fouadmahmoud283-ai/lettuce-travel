/// The three user types. A user has exactly one role, and the role decides the
/// entire navigation tree (see lib/app/router/app_router.dart).
enum UserRole {
  /// School operator. Configures schools, buses, routes, students and staff,
  /// and reads reports. Not a daily user of the bus flow.
  superAdmin('superAdmin'),

  /// Rides the bus and performs every check-in and check-out. The only role
  /// that creates a custody record. Never call this role "driver".
  busSupervisor('busSupervisor'),

  /// Guardian of one or more students. Read-only on attendance, can report an
  /// absence and message the school.
  parent('parent');

  const UserRole(this.wireName);

  /// The value stored in Firestore and in the auth custom claim.
  final String wireName;

  static UserRole fromWire(String? value) => switch (value) {
        'superAdmin' => UserRole.superAdmin,
        'busSupervisor' => UserRole.busSupervisor,
        _ => UserRole.parent,
      };
}
