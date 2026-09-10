import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip_type.dart';
import 'package:lettuce_travel/features/trips/domain/repositories/trip_repository.dart';

/// In-memory stand-in for the Firestore `trips` collection.
///
/// Trips are created lazily by [startTrip], exactly like the real
/// implementation would: nothing exists for "today" until a supervisor starts
/// it, which is why `SupervisorHomeScreen` never assumes a `Trip` document
/// exists before offering the start action.
class FakeTripRepository implements TripRepository {
  final MockCollection<Trip> _trips = MockCollection<Trip>();

  @override
  Stream<List<Trip>> watchSupervisorTrips({
    required String supervisorId,
    required String serviceDate,
  }) =>
      _trips.watch(
        (Trip t) =>
            t.supervisorId == supervisorId && t.serviceDate == serviceDate,
      );

  @override
  Stream<Trip?> watchTrip(String tripId) =>
      _trips.watchOne((Trip t) => t.id == tripId);

  @override
  Stream<List<Trip>> watchActiveTrips(String schoolId) => _trips.watch(
        (Trip t) => t.schoolId == schoolId && t.status == TripStatus.inProgress,
      );

  @override
  Stream<Trip?> watchActiveTripForRoute(String routeId) => _trips.watchOne(
        (Trip t) => t.routeId == routeId && t.status == TripStatus.inProgress,
      );

  @override
  Future<Result<Trip>> startTrip({
    required String routeId,
    required TripType type,
    required String serviceDate,
  }) async {
    final String id = Trip.buildId(
      serviceDate: serviceDate,
      routeId: routeId,
      type: type,
    );
    final Trip? existing = _trips.items.firstWhereOrNull((Trip t) => t.id == id);
    if (existing != null && existing.status == TripStatus.inProgress) {
      return Result<Trip>.ok(existing);
    }
    final Trip trip = Trip(
      id: id,
      schoolId: MockIds.schoolId,
      routeId: routeId,
      busId: MockIds.busIdByRoute[routeId] ?? MockIds.busIdA,
      supervisorId: MockIds.supervisorIdByRoute[routeId] ?? MockIds.supervisorUidA,
      type: type,
      status: TripStatus.inProgress,
      serviceDate: serviceDate,
      studentIds: MockIds.studentIdsByRoute[routeId] ?? const <String>[],
      startedAt: existing?.startedAt ?? DateTime.now(),
    );
    _trips.upsert(trip, (Trip t) => t.id == id);
    return Result<Trip>.ok(trip);
  }

  @override
  Future<Result<Trip>> endTrip(String tripId) async {
    final Trip? trip = _trips.items.firstWhereOrNull((Trip t) => t.id == tripId);
    if (trip == null) return const Result<Trip>.err(NotFoundFailure());
    if (trip.remainingOnBoard > 0) {
      return Result<Trip>.err(
        TripNotReadyToEndFailure(remainingOnBoard: trip.remainingOnBoard),
      );
    }
    final Trip ended = trip.copyWith(
      status: TripStatus.completed,
      endedAt: DateTime.now(),
    );
    _trips.upsert(ended, (Trip t) => t.id == tripId);
    return Result<Trip>.ok(ended);
  }

  @override
  Future<Result<void>> cancelTrip(String tripId, String reason) async {
    final Trip? trip = _trips.items.firstWhereOrNull((Trip t) => t.id == tripId);
    if (trip == null) return const Result<void>.err(NotFoundFailure());
    _trips.upsert(
      trip.copyWith(status: TripStatus.cancelled, endedAt: DateTime.now()),
      (Trip t) => t.id == tripId,
    );
    return const Result<void>.ok(null);
  }

  @override
  Future<Result<void>> markStopNotified({
    required String tripId,
    required String stopId,
  }) async {
    final Trip? trip = _trips.items.firstWhereOrNull((Trip t) => t.id == tripId);
    if (trip == null) return const Result<void>.err(NotFoundFailure());
    if (trip.notifiedStopIds.contains(stopId)) return const Result<void>.ok(null);
    _trips.upsert(
      trip.copyWith(
        notifiedStopIds: <String>[...trip.notifiedStopIds, stopId],
      ),
      (Trip t) => t.id == tripId,
    );
    return const Result<void>.ok(null);
  }

  /// Directly updates the on-board / completed counters. Called by the
  /// attendance controller after a check-in or check-out so trip cards and the
  /// admin live view reflect the roster without a real backend trigger.
  void syncCounts({
    required String tripId,
    required int onBoardCount,
    required int completedCount,
  }) {
    final Trip? trip = _trips.items.firstWhereOrNull((Trip t) => t.id == tripId);
    if (trip == null) return;
    _trips.upsert(
      trip.copyWith(onBoardCount: onBoardCount, completedCount: completedCount),
      (Trip t) => t.id == tripId,
    );
  }
}

final Provider<FakeTripRepository> fakeTripRepositoryProvider =
    Provider<FakeTripRepository>((Ref ref) => FakeTripRepository());

final Provider<TripRepository> tripRepositoryProvider =
    Provider<TripRepository>((Ref ref) => ref.watch(fakeTripRepositoryProvider));
