/// A child who rides the bus.
///
/// [guardianIds] is the authorisation key for parents: a parent may read this
/// document only if their uid appears in this list, and every guardian in it is
/// notified on every check-in and check-out.
class Student {
  const Student({
    required this.id,
    required this.schoolId,
    required this.fullName,
    required this.routeId,
    required this.stopId,
    required this.guardianIds,
    this.photoUrl,
    this.gradeOrClass = '',
    this.notes = '',
    this.isActive = true,
  });

  final String id;
  final String schoolId;
  final String fullName;

  /// Shown on every roster row. A photo is the main defence against a
  /// supervisor tapping the wrong child.
  final String? photoUrl;

  final String gradeOrClass;

  /// Assigned route and home stop, set by the admin.
  final String routeId;
  final String stopId;

  final List<String> guardianIds;

  /// Allergies, medical notes, handover instructions. Visible to the supervisor
  /// on the roster detail sheet.
  final String notes;

  final bool isActive;

  /// Initials used as an avatar fallback when there is no photo.
  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return _firstLetter(parts.first);
    return '${_firstLetter(parts.first)}${_firstLetter(parts.last)}';
  }

  static String _firstLetter(String value) =>
      value.isEmpty ? '' : value.substring(0, 1).toUpperCase();

  Student copyWith({
    String? fullName,
    String? photoUrl,
    String? gradeOrClass,
    String? routeId,
    String? stopId,
    List<String>? guardianIds,
    String? notes,
    bool? isActive,
  }) =>
      Student(
        id: id,
        schoolId: schoolId,
        fullName: fullName ?? this.fullName,
        routeId: routeId ?? this.routeId,
        stopId: stopId ?? this.stopId,
        guardianIds: guardianIds ?? this.guardianIds,
        photoUrl: photoUrl ?? this.photoUrl,
        gradeOrClass: gradeOrClass ?? this.gradeOrClass,
        notes: notes ?? this.notes,
        isActive: isActive ?? this.isActive,
      );
}
