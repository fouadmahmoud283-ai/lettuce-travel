import 'package:lettuce_travel/core/models/geo_position.dart';

/// One GPS sample from the supervisor's device during an active trip.
///
/// Pings go to the Realtime Database, not Firestore: they are written every few
/// seconds, read live by parents, and thrown away when the trip ends. Only the
/// latest ping is retained — there is no path history (invariant 8).
class LocationPing {
  const LocationPing({
    required this.tripId,
    required this.position,
    required this.recordedAt,
    this.speedKmh = 0,
    this.heading = 0,
    this.accuracyMeters = 0,
  });

  factory LocationPing.fromJson(String tripId, Map<String, dynamic> json) =>
      LocationPing(
        tripId: tripId,
        position: GeoPosition.fromJson(json.cast<String, dynamic>()),
        recordedAt: DateTime.fromMillisecondsSinceEpoch(
          (json['updatedAt'] as num?)?.toInt() ?? 0,
        ),
        speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 0,
        heading: (json['heading'] as num?)?.toDouble() ?? 0,
        accuracyMeters: (json['accuracy'] as num?)?.toDouble() ?? 0,
      );

  final String tripId;
  final GeoPosition position;
  final DateTime recordedAt;
  final double speedKmh;

  /// Degrees clockwise from north. Rotates the bus marker on the parent's map.
  final double heading;

  final double accuracyMeters;

  /// A ping older than this is shown as stale rather than as the live position,
  /// so a parent is never misled by a frozen marker.
  bool isStale({Duration threshold = const Duration(seconds: 45)}) =>
      DateTime.now().difference(recordedAt) > threshold;

  Map<String, dynamic> toJson() => <String, dynamic>{
        ...position.toJson(),
        'speedKmh': speedKmh,
        'heading': heading,
        'accuracy': accuracyMeters,
        'updatedAt': recordedAt.millisecondsSinceEpoch,
      };
}

/// Throttling policy for GPS writes.
///
/// Tuned for a 90-minute route on a mid-range phone: frequent enough that the
/// bus marker moves smoothly, sparse enough not to drain the battery or the
/// Realtime Database quota.
abstract final class TrackingPolicy {
  static const Duration minInterval = Duration(seconds: 5);
  static const double minDistanceMeters = 20;

  /// Safety net: if a supervisor forgets to end a trip, tracking stops itself.
  static const Duration maxTripDuration = Duration(hours: 3);
}
