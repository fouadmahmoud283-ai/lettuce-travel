import 'package:lettuce_travel/core/models/geo_position.dart';

/// A nursery or school. The tenant root: every other document carries this id.
class School {
  const School({
    required this.id,
    required this.name,
    required this.location,
    this.nameAr = '',
    this.address = '',
    this.timezone = 'Africa/Cairo',
    this.contactPhone,
    this.logoUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String nameAr;
  final String address;
  final GeoPosition location;

  /// IANA zone. Trip service dates and expected stop times are school-local,
  /// never device-local — a parent travelling abroad must still see the right
  /// school day.
  final String timezone;

  final String? contactPhone;
  final String? logoUrl;
  final bool isActive;
}
