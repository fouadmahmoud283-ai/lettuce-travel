import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';

/// One student on one trip: the custody ledger row.
///
/// This is the record the whole product exists to produce. Two rules govern it:
///
///  * It is never deleted. A mistake is fixed by writing a correction that keeps
///    the original timestamps and records who corrected it and why.
///  * Device timestamps are captured at the moment of the tap and are never
///    re-stamped on sync. An offline check-in that uploads two hours later must
///    still say when it actually happened.
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.schoolId,
    required this.tripId,
    required this.studentId,
    required this.guardianIds,
    required this.status,
    required this.serviceDate,
    required this.recordedBy,
    this.boardedAtDevice,
    this.boardedAtServer,
    this.boardedLocation,
    this.droppedAtDevice,
    this.droppedAtServer,
    this.droppedLocation,
    this.correctedBy,
    this.correctionReason,
    this.syncedFromOfflineQueue = false,
  });

  final String id;
  final String schoolId;
  final String tripId;
  final String studentId;

  /// Denormalised from the student so a parent can query their own records
  /// without a join, and so security rules can authorise a read cheaply.
  final List<String> guardianIds;

  final AttendanceStatus status;
  final String serviceDate;

  /// The supervisor who performed the tap.
  final String recordedBy;

  /// Clock at the moment of the tap. The truth about when it happened.
  final DateTime? boardedAtDevice;

  /// Server clock at write time. Differs from [boardedAtDevice] for offline
  /// check-ins; the gap is expected, not an error.
  final DateTime? boardedAtServer;

  final GeoPosition? boardedLocation;

  final DateTime? droppedAtDevice;
  final DateTime? droppedAtServer;
  final GeoPosition? droppedLocation;

  final String? correctedBy;
  final String? correctionReason;

  final bool syncedFromOfflineQueue;

  bool get isOnBoard => status == AttendanceStatus.onBoard;

  bool get isCorrected => correctedBy != null;

  /// Guards invariant 3: a drop-off requires a recorded boarding.
  bool get canBeDroppedOff =>
      status == AttendanceStatus.onBoard && boardedAtDevice != null;

  AttendanceRecord copyWith({
    AttendanceStatus? status,
    DateTime? boardedAtDevice,
    DateTime? boardedAtServer,
    GeoPosition? boardedLocation,
    DateTime? droppedAtDevice,
    DateTime? droppedAtServer,
    GeoPosition? droppedLocation,
    String? correctedBy,
    String? correctionReason,
    bool? syncedFromOfflineQueue,
  }) =>
      AttendanceRecord(
        id: id,
        schoolId: schoolId,
        tripId: tripId,
        studentId: studentId,
        guardianIds: guardianIds,
        status: status ?? this.status,
        serviceDate: serviceDate,
        recordedBy: recordedBy,
        boardedAtDevice: boardedAtDevice ?? this.boardedAtDevice,
        boardedAtServer: boardedAtServer ?? this.boardedAtServer,
        boardedLocation: boardedLocation ?? this.boardedLocation,
        droppedAtDevice: droppedAtDevice ?? this.droppedAtDevice,
        droppedAtServer: droppedAtServer ?? this.droppedAtServer,
        droppedLocation: droppedLocation ?? this.droppedLocation,
        correctedBy: correctedBy ?? this.correctedBy,
        correctionReason: correctionReason ?? this.correctionReason,
        syncedFromOfflineQueue:
            syncedFromOfflineQueue ?? this.syncedFromOfflineQueue,
      );
}
