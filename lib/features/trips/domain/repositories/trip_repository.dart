import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip_type.dart';

/// Trip lifecycle.
///
/// Starting a trip is the event that turns on GPS streaming, and ending one is
/// what turns it off — see invariant 4 in AGENTS.md. Neither should ever happen
/// implicitly somewhere else.
abstract interface class TripRepository {
  /// The supervisor's trips for a service date, ordered morning then afternoon.
  Stream<List<Trip>> watchSupervisorTrips({
    required String supervisorId,
    required String serviceDate,
  });

  Stream<Trip?> watchTrip(String tripId);

  /// All in-progress trips for a school. Powers the admin live view.
  Stream<List<Trip>> watchActiveTrips(String schoolId);

  /// Creates the trip if it does not exist and marks it in progress.
  ///
  /// Snapshots the roster (students on the route, minus those with an absence
  /// notice covering this trip) into `Trip.studentIds`, and creates one pending
  /// attendance record per student.
  Future<Result<Trip>> startTrip({
    required String routeId,
    required TripType type,
    required String serviceDate,
  });

  /// Completes the trip and stops tracking.
  ///
  /// Rejected while any child is still marked on board: the supervisor must
  /// resolve every open record first.
  Future<Result<Trip>> endTrip(String tripId);

  Future<Result<void>> cancelTrip(String tripId, String reason);

  /// Marks a stop as already notified so the approaching-stop alert fires once
  /// per stop per trip.
  Future<Result<void>> markStopNotified({
    required String tripId,
    required String stopId,
  });
}
