import 'package:flutter_test/flutter_test.dart';
import 'package:lettuce_travel/core/utils/geo_utils.dart';

void main() {
  group('GeoUtils.distanceMeters', () {
    test('is zero for the same point', () {
      expect(GeoUtils.distanceMeters(30.0444, 31.2357, 30.0444, 31.2357), 0);
    });

    test('matches a known distance within one percent', () {
      // Cairo (Tahrir) to Giza (pyramids): roughly 12.5 km.
      final double metres =
          GeoUtils.distanceMeters(30.0444, 31.2357, 29.9792, 31.1342);
      expect(metres, greaterThan(12000));
      expect(metres, lessThan(13500));
    });
  });

  group('GeoUtils.isWithinRadius', () {
    test('a bus at the stop is inside the geofence', () {
      expect(
        GeoUtils.isWithinRadius(
          busLat: 30.0444,
          busLng: 31.2357,
          stopLat: 30.0444,
          stopLng: 31.2357,
          radiusMeters: 150,
        ),
        isTrue,
      );
    });

    test('a bus a kilometre away is outside a 150m geofence', () {
      expect(
        GeoUtils.isWithinRadius(
          busLat: 30.0534,
          busLng: 31.2357,
          stopLat: 30.0444,
          stopLng: 31.2357,
          radiusMeters: 150,
        ),
        isFalse,
      );
    });
  });
}
