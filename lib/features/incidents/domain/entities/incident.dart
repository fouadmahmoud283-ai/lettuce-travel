import 'package:lettuce_travel/core/models/geo_position.dart';

/// An SOS or incident raised by a supervisor during a trip.
///
/// Creating one alerts the school admin immediately, and — for high and critical
/// severity — the guardians of every child currently on board.
class Incident {
  const Incident({
    required this.id,
    required this.schoolId,
    required this.tripId,
    required this.type,
    required this.severity,
    required this.createdBy,
    this.note = '',
    this.location,
    this.createdAt,
    this.acknowledgedBy,
    this.resolvedAt,
  });

  final String id;
  final String schoolId;
  final String tripId;
  final IncidentType type;
  final IncidentSeverity severity;
  final String note;
  final GeoPosition? location;

  /// Supervisor uid.
  final String createdBy;

  final DateTime? createdAt;
  final String? acknowledgedBy;
  final DateTime? resolvedAt;

  bool get isOpen => resolvedAt == null;

  bool get notifiesParents =>
      severity == IncidentSeverity.high ||
      severity == IncidentSeverity.critical;
}

enum IncidentType {
  breakdown('breakdown'),
  accident('accident'),
  medical('medical'),
  delay('delay'),
  other('other');

  const IncidentType(this.wireName);

  final String wireName;
}

enum IncidentSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const IncidentSeverity(this.wireName);

  final String wireName;
}
