import 'package:lettuce_travel/core/models/geo_position.dart';

/// A pickup / drop-off point on a route.
///
/// Stops are embedded in their route rather than stored separately: they
/// are few, always read together with the route, and edited as a unit.
class RouteStop {
  const RouteStop({
    required this.id,
    required this.name,
    required this.order,
    required this.location,
    this.geofenceRadiusMeters = 150,
    this.expectedMorningTime,
    this.expectedAfternoonTime,
  });

  final String id;
  final String name;

  /// 1-based position along the route. Determines roster ordering and which
  /// stops are still "upcoming" for the approaching-stop notification.
  final int order;

  final GeoPosition location;

  /// Radius that triggers the "bus approaching your stop" alert. Wider in
  /// low-density areas, tighter in dense streets.
  final double geofenceRadiusMeters;

  /// School-local `HH:mm` expectations, used for ETA hints and late detection.
  final String? expectedMorningTime;
  final String? expectedAfternoonTime;
}
