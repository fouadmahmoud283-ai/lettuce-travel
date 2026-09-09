/// The two runs a bus makes on a school day.
enum TripType {
  /// Home stops -> school. Children are checked in at their stop and checked
  /// out on arrival at school.
  morningPickup('morningPickup'),

  /// School -> home stops. Children are checked in at school and checked out to
  /// their guardian at their stop.
  afternoonDropoff('afternoonDropoff');

  const TripType(this.wireName);

  final String wireName;

  static TripType fromWire(String value) => value == 'afternoonDropoff'
      ? TripType.afternoonDropoff
      : TripType.morningPickup;
}

/// Lifecycle of a single trip.
enum TripStatus {
  scheduled('scheduled'),

  /// The only status during which GPS is streamed. See invariant 4 in AGENTS.md.
  inProgress('inProgress'),

  completed('completed'),
  cancelled('cancelled');

  const TripStatus(this.wireName);

  final String wireName;

  bool get isLive => this == TripStatus.inProgress;

  static TripStatus fromWire(String? value) => switch (value) {
        'inProgress' => TripStatus.inProgress,
        'completed' => TripStatus.completed,
        'cancelled' => TripStatus.cancelled,
        _ => TripStatus.scheduled,
      };
}
