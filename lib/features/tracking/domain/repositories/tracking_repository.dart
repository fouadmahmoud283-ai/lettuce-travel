import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/tracking/domain/entities/location_ping.dart';

/// Live bus location.
///
/// The write side is the supervisor device; the read side is the parent map and
/// the admin live view. Streaming exists only while a trip is in progress, and
/// [stopBroadcasting] must be idempotent and safe to call from a lifecycle
/// handler, a sign-out, or an error path.
abstract interface class TrackingRepository {
  /// Begins a foreground-service location stream and writes throttled pings to
  /// the Realtime Database. Requires an in-progress trip owned by the caller.
  Future<Result<void>> startBroadcasting({
    required String tripId,
    required String schoolId,
    required String routeId,
  });

  /// Stops the stream and removes the live node for the trip. Safe to call when
  /// no broadcast is running.
  Future<Result<void>> stopBroadcasting(String tripId);

  /// True while this device is actively streaming.
  Stream<bool> watchBroadcastState();

  /// Live position of a bus, for parents and admins.
  Stream<LocationPing?> watchTripLocation(String tripId);
}
