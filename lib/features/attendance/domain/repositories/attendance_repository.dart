import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/absence_notice.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';

/// The custody ledger.
///
/// Implementations must:
///  * reject any transition that `AttendanceStatus.canTransitionTo` disallows;
///  * write the device timestamp supplied by the caller, unchanged, even when
///    the write is replayed from the offline queue hours later;
///  * never delete a record.
abstract interface class AttendanceRepository {
  /// Live roster for a trip, ordered by stop then by name.
  Stream<List<AttendanceRecord>> watchTripAttendance(String tripId);

  /// A guardian's own children's records, most recent first.
  Stream<List<AttendanceRecord>> watchGuardianAttendance({
    required String guardianId,
    int limit = 50,
  });

  Stream<List<AttendanceRecord>> watchStudentHistory({
    required String studentId,
    required String fromServiceDate,
    required String toServiceDate,
  });

  /// Every record for a school in a date range. Powers the admin attendance
  /// report and its CSV export (FR-13 in docs/prd.md).
  Stream<List<AttendanceRecord>> watchSchoolAttendance({
    required String schoolId,
    required String fromServiceDate,
    required String toServiceDate,
  });

  /// Marks a child on board. [tappedAt] is the device clock at the moment of
  /// the tap and must be preserved verbatim.
  Future<Result<AttendanceRecord>> checkIn({
    required String recordId,
    required DateTime tappedAt,
    GeoPosition? location,
  });

  /// Marks a child dropped off. Fails with `InvalidTransitionFailure` if the
  /// child was never marked on board.
  Future<Result<AttendanceRecord>> checkOut({
    required String recordId,
    required DateTime tappedAt,
    GeoPosition? location,
  });

  Future<Result<AttendanceRecord>> markNoShow({
    required String recordId,
    required DateTime tappedAt,
  });

  /// Fixes a mistaken tap. Keeps the original timestamps and records who
  /// corrected it and why; never deletes the record.
  Future<Result<AttendanceRecord>> correctRecord({
    required String recordId,
    required String newStatusWireName,
    required String reason,
  });

  Future<Result<AbsenceNotice>> reportAbsence(AbsenceNotice notice);

  Future<Result<void>> cancelAbsence(String absenceId);

  Stream<List<AbsenceNotice>> watchAbsencesForDate({
    required String schoolId,
    required String serviceDate,
  });
}
