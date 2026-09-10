import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/absence_notice.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';
import 'package:lettuce_travel/features/attendance/domain/repositories/attendance_repository.dart';

/// In-memory stand-in for the Firestore `attendance` collection.
///
/// [watchTripAttendance] lazily creates one `pending` record per student the
/// first time a trip id is observed, mirroring what `TripRepository.startTrip`
/// does in the real system (see docs/data-model.md) without the two fakes
/// needing to import each other — the trip id alone is enough to recover the
/// route (there are only two in the whole mock world) and its roster.
class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository() {
    _seedHistory();
  }

  final MockCollection<AttendanceRecord> _records =
      MockCollection<AttendanceRecord>();
  final MockCollection<AbsenceNotice> _absences = MockCollection<AbsenceNotice>();
  final Set<String> _seededTrips = <String>{};
  int _historySeq = 0;
  int _absenceSeq = 0;

  void _seedHistory() {
    final DateTime now = DateTime.now();
    for (int daysAgo = 1; daysAgo <= 3; daysAgo++) {
      final DateTime day = now.subtract(Duration(days: daysAgo));
      final String serviceDate = _formatDate(day);
      for (final String studentId in <String>[
        MockIds.studentId1,
        MockIds.studentId2,
        MockIds.studentId3,
      ]) {
        _historySeq++;
        final DateTime boarded = DateTime(day.year, day.month, day.day, 7, 20);
        final DateTime dropped = DateTime(day.year, day.month, day.day, 7, 55);
        _records.add(
          AttendanceRecord(
            id: 'att_hist_$_historySeq',
            schoolId: MockIds.schoolId,
            tripId: '${serviceDate}_${MockIds.routeIdA}_morningPickup',
            studentId: studentId,
            guardianIds: MockIds.guardianIdsByStudent[studentId] ?? const <String>[],
            status: AttendanceStatus.droppedOff,
            serviceDate: serviceDate,
            recordedBy: MockIds.supervisorUidA,
            boardedAtDevice: boarded,
            boardedAtServer: boarded,
            boardedLocation: const GeoPosition(lat: 29.960, lng: 31.250),
            droppedAtDevice: dropped,
            droppedAtServer: dropped,
            droppedLocation: const GeoPosition(lat: 29.970, lng: 31.260),
          ),
        );
      }
    }
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _ensureRosterSeeded(String tripId) {
    if (_seededTrips.contains(tripId)) return;
    _seededTrips.add(tripId);
    final String routeId = MockIds.routeIdFromTripId(tripId);
    final List<String> studentIds = MockIds.studentIdsByRoute[routeId] ?? const <String>[];
    final String serviceDate = MockIds.serviceDateFromTripId(tripId);
    final String supervisorId = MockIds.supervisorIdByRoute[routeId] ?? MockIds.supervisorUidA;
    for (final String studentId in studentIds) {
      final bool alreadyHasRecord =
          _records.items.any((AttendanceRecord r) => r.tripId == tripId && r.studentId == studentId);
      if (alreadyHasRecord) continue;
      _records.add(
        AttendanceRecord(
          id: 'att_${tripId}_$studentId',
          schoolId: MockIds.schoolId,
          tripId: tripId,
          studentId: studentId,
          guardianIds: MockIds.guardianIdsByStudent[studentId] ?? const <String>[],
          status: AttendanceStatus.pending,
          serviceDate: serviceDate,
          recordedBy: supervisorId,
        ),
      );
    }
  }

  @override
  Stream<List<AttendanceRecord>> watchTripAttendance(String tripId) {
    _ensureRosterSeeded(tripId);
    return _records.watch((AttendanceRecord r) => r.tripId == tripId);
  }

  @override
  Stream<List<AttendanceRecord>> watchGuardianAttendance({
    required String guardianId,
    int limit = 50,
  }) =>
      _records.watch((AttendanceRecord r) => r.guardianIds.contains(guardianId));

  @override
  Stream<List<AttendanceRecord>> watchStudentHistory({
    required String studentId,
    required String fromServiceDate,
    required String toServiceDate,
  }) =>
      _records.watch(
        (AttendanceRecord r) =>
            r.studentId == studentId &&
            r.serviceDate.compareTo(fromServiceDate) >= 0 &&
            r.serviceDate.compareTo(toServiceDate) <= 0,
      );

  @override
  Stream<List<AttendanceRecord>> watchSchoolAttendance({
    required String schoolId,
    required String fromServiceDate,
    required String toServiceDate,
  }) =>
      _records.watch(
        (AttendanceRecord r) =>
            r.schoolId == schoolId &&
            r.serviceDate.compareTo(fromServiceDate) >= 0 &&
            r.serviceDate.compareTo(toServiceDate) <= 0,
      );

  Future<Result<AttendanceRecord>> _transition({
    required String recordId,
    required AttendanceStatus target,
    required DateTime tappedAt,
    GeoPosition? location,
  }) async {
    final AttendanceRecord? record =
        _records.items.firstWhereOrNull((AttendanceRecord r) => r.id == recordId);
    if (record == null) {
      return const Result<AttendanceRecord>.err(NotFoundFailure());
    }
    if (!record.status.canTransitionTo(target)) {
      return Result<AttendanceRecord>.err(
        InvalidTransitionFailure(
          from: record.status.wireName,
          to: target.wireName,
        ),
      );
    }
    final AttendanceRecord updated = switch (target) {
      AttendanceStatus.onBoard => record.copyWith(
          status: target,
          boardedAtDevice: tappedAt,
          boardedAtServer: DateTime.now(),
          boardedLocation: location,
        ),
      AttendanceStatus.droppedOff => record.copyWith(
          status: target,
          droppedAtDevice: tappedAt,
          droppedAtServer: DateTime.now(),
          droppedLocation: location,
        ),
      AttendanceStatus.noShow => record.copyWith(status: target),
      AttendanceStatus.pending || AttendanceStatus.absent => record.copyWith(status: target),
    };
    _records.upsert(updated, (AttendanceRecord r) => r.id == recordId);
    return Result<AttendanceRecord>.ok(updated);
  }

  @override
  Future<Result<AttendanceRecord>> checkIn({
    required String recordId,
    required DateTime tappedAt,
    GeoPosition? location,
  }) =>
      _transition(
        recordId: recordId,
        target: AttendanceStatus.onBoard,
        tappedAt: tappedAt,
        location: location,
      );

  @override
  Future<Result<AttendanceRecord>> checkOut({
    required String recordId,
    required DateTime tappedAt,
    GeoPosition? location,
  }) =>
      _transition(
        recordId: recordId,
        target: AttendanceStatus.droppedOff,
        tappedAt: tappedAt,
        location: location,
      );

  @override
  Future<Result<AttendanceRecord>> markNoShow({
    required String recordId,
    required DateTime tappedAt,
  }) =>
      _transition(
        recordId: recordId,
        target: AttendanceStatus.noShow,
        tappedAt: tappedAt,
      );

  /// Reverts a record to an earlier status. Not part of the production
  /// contract (a real correction always keeps a trail — see [correctRecord])
  /// but this fake backs the roster's 60-second undo affordance, which is
  /// purely a local take-back of the supervisor's last tap before it would
  /// ever reach a server.
  Future<Result<AttendanceRecord>> revertTo({
    required String recordId,
    required AttendanceStatus status,
  }) async {
    final AttendanceRecord? record =
        _records.items.firstWhereOrNull((AttendanceRecord r) => r.id == recordId);
    if (record == null) {
      return const Result<AttendanceRecord>.err(NotFoundFailure());
    }
    final AttendanceRecord reverted = AttendanceRecord(
      id: record.id,
      schoolId: record.schoolId,
      tripId: record.tripId,
      studentId: record.studentId,
      guardianIds: record.guardianIds,
      status: status,
      serviceDate: record.serviceDate,
      recordedBy: record.recordedBy,
      boardedAtDevice: status == AttendanceStatus.onBoard ? record.boardedAtDevice : null,
      boardedAtServer: status == AttendanceStatus.onBoard ? record.boardedAtServer : null,
      boardedLocation: status == AttendanceStatus.onBoard ? record.boardedLocation : null,
    );
    _records.upsert(reverted, (AttendanceRecord r) => r.id == recordId);
    return Result<AttendanceRecord>.ok(reverted);
  }

  /// Synchronous snapshot used by presentation-layer orchestration (e.g. to
  /// recompute `Trip.onBoardCount` after a tap) without adding a repository
  /// method that the production interface has no equivalent for.
  List<AttendanceRecord> recordsForTrip(String tripId) =>
      _records.items.where((AttendanceRecord r) => r.tripId == tripId).toList();

  @override
  Future<Result<AttendanceRecord>> correctRecord({
    required String recordId,
    required String newStatusWireName,
    required String reason,
  }) async {
    final AttendanceRecord? record =
        _records.items.firstWhereOrNull((AttendanceRecord r) => r.id == recordId);
    if (record == null) {
      return const Result<AttendanceRecord>.err(NotFoundFailure());
    }
    final AttendanceRecord corrected = record.copyWith(
      status: AttendanceStatus.fromWire(newStatusWireName),
      correctedBy: record.recordedBy,
      correctionReason: reason,
    );
    _records.upsert(corrected, (AttendanceRecord r) => r.id == recordId);
    return Result<AttendanceRecord>.ok(corrected);
  }

  @override
  Future<Result<AbsenceNotice>> reportAbsence(AbsenceNotice notice) async {
    _absenceSeq++;
    final AbsenceNotice stored = AbsenceNotice(
      id: 'abs_$_absenceSeq',
      schoolId: notice.schoolId,
      studentId: notice.studentId,
      serviceDate: notice.serviceDate,
      scope: notice.scope,
      reportedBy: notice.reportedBy,
      reason: notice.reason,
      createdAt: DateTime.now(),
    );
    _absences.add(stored);
    return Result<AbsenceNotice>.ok(stored);
  }

  @override
  Future<Result<void>> cancelAbsence(String absenceId) async {
    _absences.removeWhere((AbsenceNotice a) => a.id == absenceId);
    return const Result<void>.ok(null);
  }

  @override
  Stream<List<AbsenceNotice>> watchAbsencesForDate({
    required String schoolId,
    required String serviceDate,
  }) =>
      _absences.watch(
        (AbsenceNotice a) => a.schoolId == schoolId && a.serviceDate == serviceDate,
      );
}

final Provider<FakeAttendanceRepository> fakeAttendanceRepositoryProvider =
    Provider<FakeAttendanceRepository>((Ref ref) => FakeAttendanceRepository());

final Provider<AttendanceRepository> attendanceRepositoryProvider =
    Provider<AttendanceRepository>(
  (Ref ref) => ref.watch(fakeAttendanceRepositoryProvider),
);
