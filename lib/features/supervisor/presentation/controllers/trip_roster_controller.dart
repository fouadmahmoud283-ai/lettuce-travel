import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/utils/combine_streams.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/attendance/data/repositories/fake_attendance_repository.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/absence_notice.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';
import 'package:lettuce_travel/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/schools/domain/entities/route_stop.dart';
import 'package:lettuce_travel/features/schools/domain/repositories/bus_route_repository.dart';
import 'package:lettuce_travel/features/students/data/repositories/fake_student_repository.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';
import 'package:lettuce_travel/features/students/domain/repositories/student_repository.dart';
import 'package:lettuce_travel/features/tracking/data/repositories/fake_tracking_repository.dart';
import 'package:lettuce_travel/features/trips/data/repositories/fake_trip_repository.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip_type.dart';
import 'package:lettuce_travel/features/trips/domain/repositories/trip_repository.dart';

/// One roster row: a student joined with their live attendance record, their
/// stop, and whether their parent reported them absent today.
class RosterRow {
  const RosterRow({
    required this.student,
    required this.record,
    required this.stop,
    required this.isAbsentToday,
  });

  final Student student;
  final AttendanceRecord record;
  final RouteStop? stop;
  final bool isAbsentToday;
}

/// Everything the roster screen needs, recomputed live as any of its sources
/// change.
class RosterData {
  const RosterData({required this.trip, required this.route, required this.rows});

  final Trip trip;
  final BusRoute route;
  final List<RosterRow> rows;

  int get waitingCount => rows
      .where((RosterRow r) => r.record.status == AttendanceStatus.pending && !r.isAbsentToday)
      .length;

  int get onBoardCount =>
      rows.where((RosterRow r) => r.record.status == AttendanceStatus.onBoard).length;

  int get droppedOffCount =>
      rows.where((RosterRow r) => r.record.status == AttendanceStatus.droppedOff).length;

  bool get canEndTrip => onBoardCount == 0;
}

/// Live roster for one trip, joining the trip, its route, the roster's
/// students and their attendance records, and today's absence notices.
///
/// There is no single Firestore query that returns this shape either — a real
/// screen also joins several collections client-side. This just does it
/// without `rxdart`'s `combineLatest`, since that package is not a project
/// dependency: each source stream updates one field of a running snapshot and
/// re-emits once every source has produced at least one value.
final StreamProviderFamily<RosterData?, String> rosterDataProvider =
    StreamProvider.family<RosterData?, String>((Ref ref, String tripId) {
  final TripRepository tripRepository = ref.watch(tripRepositoryProvider);
  final BusRouteRepository routeRepository = ref.watch(busRouteRepositoryProvider);
  final AttendanceRepository attendanceRepository = ref.watch(attendanceRepositoryProvider);
  final StudentRepository studentRepository = ref.watch(studentRepositoryProvider);

  final String routeId = MockIds.routeIdFromTripId(tripId);
  final String serviceDate = MockIds.serviceDateFromTripId(tripId);

  return combine5(
    tripRepository.watchTrip(tripId),
    routeRepository.watchRoute(routeId),
    attendanceRepository.watchTripAttendance(tripId),
    studentRepository.watchStudentsOnRoute(routeId),
    attendanceRepository.watchAbsencesForDate(
      schoolId: MockIds.schoolId,
      serviceDate: serviceDate,
    ),
    (
      Trip? trip,
      BusRoute? route,
      List<AttendanceRecord> records,
      List<Student> students,
      List<AbsenceNotice> absences,
    ) {
      if (trip == null || route == null) return null;

      final List<RouteStop> orderedStops = trip.type == TripType.morningPickup
          ? route.stopsInPickupOrder
          : route.stopsInDropOffOrder;
      final Map<String, int> stopOrder = <String, int>{
        for (final RouteStop stop in orderedStops) stop.id: stop.order,
      };

      final List<RosterRow> rows = <RosterRow>[];
      for (final AttendanceRecord record in records) {
        final Student? student =
            students.firstWhereOrNull((Student s) => s.id == record.studentId);
        if (student == null) continue;
        final bool isAbsentToday = absences.any((AbsenceNotice a) {
          if (a.studentId != student.id) return false;
          return switch (a.scope) {
            AbsenceScope.wholeDay => true,
            AbsenceScope.morningOnly => trip.type == TripType.morningPickup,
            AbsenceScope.afternoonOnly => trip.type == TripType.afternoonDropoff,
          };
        });
        rows.add(
          RosterRow(
            student: student,
            record: record,
            stop: route.stopById(student.stopId),
            isAbsentToday: isAbsentToday,
          ),
        );
      }

      rows.sort((RosterRow a, RosterRow b) {
        final int orderA = stopOrder[a.student.stopId] ?? 0;
        final int orderB = stopOrder[b.student.stopId] ?? 0;
        if (orderA != orderB) return orderA.compareTo(orderB);
        return a.student.fullName.compareTo(b.student.fullName);
      });

      return RosterData(trip: trip, route: route, rows: rows);
    },
  );
});

/// The last check-in/check-out/no-show action, kept for the 60-second undo
/// affordance on the roster screen.
class LastRosterAction {
  const LastRosterAction({
    required this.recordId,
    required this.studentName,
    required this.previousStatus,
    required this.newStatus,
    required this.at,
  });

  final String recordId;
  final String studentName;
  final AttendanceStatus previousStatus;
  final AttendanceStatus newStatus;
  final DateTime at;

  bool get isExpired => DateTime.now().difference(at) > const Duration(seconds: 60);
}

final StateProviderFamily<LastRosterAction?, String> lastRosterActionProvider =
    StateProvider.family<LastRosterAction?, String>((Ref ref, String tripId) => null);

/// Check-in / check-out / no-show / undo / end-trip actions for one trip.
///
/// Kept free of `BuildContext` (AGENTS.md section 6); the screen reads
/// [Result] failures and decides what to show.
class TripRosterActions {
  TripRosterActions(this._ref, this.tripId);

  final Ref _ref;
  final String tripId;

  AttendanceRepository get _attendanceRepository => _ref.read(attendanceRepositoryProvider);

  FakeAttendanceRepository get _fakeAttendance => _ref.read(fakeAttendanceRepositoryProvider);

  FakeTripRepository get _fakeTrip => _ref.read(fakeTripRepositoryProvider);

  TripRepository get _tripRepository => _ref.read(tripRepositoryProvider);

  Future<Result<AttendanceRecord>> checkIn(RosterRow row) async {
    final Result<AttendanceRecord> result = await _attendanceRepository.checkIn(
      recordId: row.record.id,
      tappedAt: DateTime.now(),
    );
    result.when(
      ok: (AttendanceRecord updated) => _afterMutation(row, updated),
      err: (_) {},
    );
    return result;
  }

  Future<Result<AttendanceRecord>> checkOut(RosterRow row) async {
    final Result<AttendanceRecord> result = await _attendanceRepository.checkOut(
      recordId: row.record.id,
      tappedAt: DateTime.now(),
    );
    result.when(
      ok: (AttendanceRecord updated) => _afterMutation(row, updated),
      err: (_) {},
    );
    return result;
  }

  Future<Result<AttendanceRecord>> markNoShow(RosterRow row) async {
    final Result<AttendanceRecord> result = await _attendanceRepository.markNoShow(
      recordId: row.record.id,
      tappedAt: DateTime.now(),
    );
    result.when(
      ok: (AttendanceRecord updated) => _afterMutation(row, updated),
      err: (_) {},
    );
    return result;
  }

  Future<void> undoLastAction() async {
    final LastRosterAction? last = _ref.read(lastRosterActionProvider(tripId));
    if (last == null) return;
    await _fakeAttendance.revertTo(recordId: last.recordId, status: last.previousStatus);
    _syncTripCounts();
    _ref.read(lastRosterActionProvider(tripId).notifier).state = null;
  }

  Future<Result<Trip>> endTrip() async {
    final Result<Trip> result = await _tripRepository.endTrip(tripId);
    if (result.isOk) {
      // Streaming must stop the instant the trip ends — invariant 4 in
      // AGENTS.md — never left running for "one more minute".
      await _ref.read(trackingRepositoryProvider).stopBroadcasting(tripId);
    }
    return result;
  }

  void _afterMutation(RosterRow row, AttendanceRecord updated) {
    final DateTime at = DateTime.now();
    _ref.read(lastRosterActionProvider(tripId).notifier).state = LastRosterAction(
      recordId: row.record.id,
      studentName: row.student.fullName,
      previousStatus: row.record.status,
      newStatus: updated.status,
      at: at,
    );
    _syncTripCounts();

    // The undo affordance is only offered for 60 seconds (AGENTS.md
    // roadmap.md "wrong child tapped" mitigation); clear it once the window
    // closes, but only if nothing more recent has replaced it.
    unawaited(
      Future<void>.delayed(const Duration(seconds: 60), () {
        final StateController<LastRosterAction?> controller =
            _ref.read(lastRosterActionProvider(tripId).notifier);
        if (controller.state?.at == at) {
          controller.state = null;
        }
      }),
    );
  }

  void _syncTripCounts() {
    final List<AttendanceRecord> records = _fakeAttendance.recordsForTrip(tripId);
    _fakeTrip.syncCounts(
      tripId: tripId,
      onBoardCount:
          records.where((AttendanceRecord r) => r.status == AttendanceStatus.onBoard).length,
      completedCount:
          records.where((AttendanceRecord r) => r.status == AttendanceStatus.droppedOff).length,
    );
  }
}

final ProviderFamily<TripRosterActions, String> tripRosterActionsProvider =
    Provider.family<TripRosterActions, String>(
  (Ref ref, String tripId) => TripRosterActions(ref, tripId),
);
