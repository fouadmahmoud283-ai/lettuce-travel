/// A parent telling the school their child is not riding on a given day.
///
/// The supervisor's roster greys out these children and does not count them as
/// a no-show, which is the point: it removes false alarms.
class AbsenceNotice {
  const AbsenceNotice({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.serviceDate,
    required this.scope,
    required this.reportedBy,
    this.reason = '',
    this.createdAt,
  });

  final String id;
  final String schoolId;
  final String studentId;

  /// School-local `yyyy-MM-dd` the absence applies to.
  final String serviceDate;

  final AbsenceScope scope;
  final String reason;

  /// Guardian uid.
  final String reportedBy;

  final DateTime? createdAt;
}

enum AbsenceScope {
  wholeDay('wholeDay'),
  morningOnly('morningOnly'),
  afternoonOnly('afternoonOnly');

  const AbsenceScope(this.wireName);

  final String wireName;

  static AbsenceScope fromWire(String? value) => switch (value) {
        'morningOnly' => AbsenceScope.morningOnly,
        'afternoonOnly' => AbsenceScope.afternoonOnly,
        _ => AbsenceScope.wholeDay,
      };
}
