import 'package:lettuce_travel/core/models/geo_position.dart';

/// One check-in or check-out that was performed while the device had no usable
/// connection.
///
/// The whole point of this queue is [tappedAt]: it is the device clock at the
/// instant the supervisor touched the row, and it must survive to the server
/// unchanged. A record that arrives two hours late but says the child boarded
/// at 07:14 is correct; one re-stamped at upload time is a false record.
class QueuedCheckIn {
  const QueuedCheckIn({
    required this.localId,
    required this.recordId,
    required this.tripId,
    required this.studentId,
    required this.targetStatusWireName,
    required this.tappedAt,
    this.location,
    this.attempts = 0,
  });

  factory QueuedCheckIn.fromJson(Map<String, dynamic> json) => QueuedCheckIn(
        localId: json['localId'] as String,
        recordId: json['recordId'] as String,
        tripId: json['tripId'] as String,
        studentId: json['studentId'] as String,
        targetStatusWireName: json['targetStatus'] as String,
        tappedAt: DateTime.fromMillisecondsSinceEpoch(json['tappedAt'] as int),
        location: json['location'] == null
            ? null
            : GeoPosition.fromJson(
                (json['location'] as Map<Object?, Object?>)
                    .cast<String, dynamic>(),
              ),
        attempts: json['attempts'] as int? ?? 0,
      );

  final String localId;
  final String recordId;
  final String tripId;
  final String studentId;
  final String targetStatusWireName;
  final DateTime tappedAt;
  final GeoPosition? location;
  final int attempts;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'localId': localId,
        'recordId': recordId,
        'tripId': tripId,
        'studentId': studentId,
        'targetStatus': targetStatusWireName,
        'tappedAt': tappedAt.millisecondsSinceEpoch,
        'location': location?.toJson(),
        'attempts': attempts,
      };

  QueuedCheckIn withAttempt() => QueuedCheckIn(
        localId: localId,
        recordId: recordId,
        tripId: tripId,
        studentId: studentId,
        targetStatusWireName: targetStatusWireName,
        tappedAt: tappedAt,
        location: location,
        attempts: attempts + 1,
      );
}

/// Durable queue of pending check-ins.
///
/// Contract for the implementation:
///  * [enqueue] must complete before the UI shows a confirmed state, so a crash
///    immediately after a tap cannot lose the record.
///  * [flush] replays in tap order — a boarding must reach the server before the
///    matching drop-off, or the transition guard will reject it.
///  * an entry is removed only after the server confirms the write.
abstract interface class OfflineCheckInQueue {
  Future<void> enqueue(QueuedCheckIn item);

  Future<List<QueuedCheckIn>> pending();

  /// Replays every pending entry, oldest tap first. Returns how many synced.
  Future<int> flush();

  Future<void> remove(String localId);

  Stream<int> watchPendingCount();
}
