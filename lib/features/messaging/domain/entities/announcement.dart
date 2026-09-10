/// A message from the school to parents: either the whole school or one
/// route's guardians.
class Announcement {
  const Announcement({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.body,
    required this.scope,
    required this.createdBy,
    this.routeId,
    this.createdAt,
  });

  final String id;
  final String schoolId;
  final String title;
  final String body;
  final AnnouncementScope scope;

  /// Set only when [scope] is [AnnouncementScope.route].
  final String? routeId;

  final String createdBy;
  final DateTime? createdAt;
}

enum AnnouncementScope {
  school('school'),
  route('route');

  const AnnouncementScope(this.wireName);

  final String wireName;
}
