/// A physical vehicle belonging to a school.
class Bus {
  const Bus({
    required this.id,
    required this.schoolId,
    required this.plateNumber,
    required this.capacity,
    this.model = '',
    this.driverName = '',
    this.driverPhone,
    this.isActive = true,
  });

  final String id;
  final String schoolId;
  final String plateNumber;
  final int capacity;
  final String model;

  /// The driver is recorded for contact purposes only. Drivers are not users of
  /// the app and never perform check-ins — that is the supervisor's job.
  final String driverName;
  final String? driverPhone;

  final bool isActive;

  Bus copyWith({
    String? plateNumber,
    int? capacity,
    String? model,
    String? driverName,
    String? driverPhone,
    bool? isActive,
  }) =>
      Bus(
        id: id,
        schoolId: schoolId,
        plateNumber: plateNumber ?? this.plateNumber,
        capacity: capacity ?? this.capacity,
        model: model ?? this.model,
        driverName: driverName ?? this.driverName,
        driverPhone: driverPhone ?? this.driverPhone,
        isActive: isActive ?? this.isActive,
      );
}
