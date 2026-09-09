import 'dart:math' as math;

/// Great-circle helpers for stop geofencing.
///
/// Used by the "bus approaching your stop" check. Kept dependency-free so it can
/// be unit tested without Flutter or Firebase.
abstract final class GeoUtils {
  static const double _earthRadiusMeters = 6371000;

  static double distanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);
    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.pow(math.sin(dLng / 2), 2);
    return _earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// True when the bus is inside the geofence of a stop.
  static bool isWithinRadius({
    required double busLat,
    required double busLng,
    required double stopLat,
    required double stopLng,
    required double radiusMeters,
  }) =>
      distanceMeters(busLat, busLng, stopLat, stopLng) <= radiusMeters;

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
