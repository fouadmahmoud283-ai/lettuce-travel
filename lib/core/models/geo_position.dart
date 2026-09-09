/// A plain lat/lng pair.
///
/// The domain layer stays pure Dart, so this is deliberately not `GeoPoint` from
/// cloud_firestore or `LatLng` from google_maps_flutter. Data-layer models
/// convert at the boundary.
class GeoPosition {
  const GeoPosition({required this.lat, required this.lng});

  factory GeoPosition.fromJson(Map<String, dynamic> json) => GeoPosition(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => <String, dynamic>{'lat': lat, 'lng': lng};

  @override
  bool operator ==(Object other) =>
      other is GeoPosition && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'GeoPosition($lat, $lng)';
}
