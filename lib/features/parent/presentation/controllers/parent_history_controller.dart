import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/features/attendance/data/repositories/fake_attendance_repository.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';

/// A student's last 30 days of attendance records, most recent first.
final StreamProviderFamily<List<AttendanceRecord>, String> parentHistoryProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((Ref ref, String studentId) {
  final DateTime now = DateTime.now();
  final String from = now.subtract(const Duration(days: 30)).toServiceDate();
  final String to = now.toServiceDate();
  return ref
      .watch(attendanceRepositoryProvider)
      .watchStudentHistory(studentId: studentId, fromServiceDate: from, toServiceDate: to)
      .map(
        (List<AttendanceRecord> records) => List<AttendanceRecord>.of(records)
          ..sort(
            (AttendanceRecord a, AttendanceRecord b) => b.serviceDate.compareTo(a.serviceDate),
          ),
      );
});
