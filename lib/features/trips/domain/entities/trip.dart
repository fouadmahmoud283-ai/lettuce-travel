import 'package:lettuce_travel/features/trips/domain/entities/trip_type.dart';

/// One run of one route on one service date.
///
/// The document id is deterministic — `{serviceDate}_{routeId}_{type}` — so the
/// same trip can never be started twice, even from two devices.
class Trip {
  const Trip({
    required this.id,
    required this.schoolId,
    required this.routeId,
    required this.busId,
    required this.supervisorId,
    required this.type,
    required this.status,
    required this.serviceDate,
    required this.studentIds,
    this.startedAt,
    this.endedAt,
    this.onBoardCount = 0,
    this.completedCount = 0,
    this.notifiedStopIds = const <String>[],
  });

  static String buildId({
    required String serviceDate,
    required String routeId,
    required TripType type,
  }) =>
      '${serviceDate}_${routeId}_${type.wireName}';

  final String id;
  final String schoolId;
  final String routeId;
  final String busId;
  final String supervisorId;
  final TripType type;
  final TripStatus status;

  /// School-local `yyyy-MM-dd`.
  final String serviceDate;

  /// Roster snapshot taken when the trip started. Frozen on purpose: a student
  /// moved to another route mid-trip must not vanish from the ledger.
  final List<String> studentIds;

  final DateTime? startedAt;
  final DateTime? endedAt;

  final int onBoardCount;
  final int completedCount;

  /// Stops that have already fired the "bus approaching your stop" alert.
  /// Guards the once-per-stop-per-trip rule.
  final List<String> notifiedStopIds;

  bool get isLive => status.isLive;

  bool get hasEnded =>
      status == TripStatus.completed || status == TripStatus.cancelled;

  /// Children still on the bus. Must be zero before a trip can be completed.
  int get remainingOnBoard => onBoardCount - completedCount;

  Trip copyWith({
    TripStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? onBoardCount,
    int? completedCount,
    List<String>? notifiedStopIds,
  }) =>
      Trip(
        id: id,
        schoolId: schoolId,
        routeId: routeId,
        busId: busId,
        supervisorId: supervisorId,
        type: type,
        status: status ?? this.status,
        serviceDate: serviceDate,
        studentIds: studentIds,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        onBoardCount: onBoardCount ?? this.onBoardCount,
        completedCount: completedCount ?? this.completedCount,
        notifiedStopIds: notifiedStopIds ?? this.notifiedStopIds,
      );
}
