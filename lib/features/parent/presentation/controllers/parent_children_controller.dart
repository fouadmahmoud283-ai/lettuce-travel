import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/utils/combine_streams.dart';
import 'package:lettuce_travel/features/attendance/data/repositories/fake_attendance_repository.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/students/data/repositories/fake_student_repository.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';

/// A child plus today's most recent attendance record, if any trip has
/// touched them yet.
class ParentChildSummary {
  const ParentChildSummary({required this.student, this.todayRecord});

  final Student student;
  final AttendanceRecord? todayRecord;
}

/// The signed-in guardian's children with today's status, updating live as
/// the supervisor checks each one in and out.
final StreamProvider<List<ParentChildSummary>> parentChildrenProvider =
    StreamProvider<List<ParentChildSummary>>((Ref ref) {
  final String? guardianId = ref.watch(authControllerProvider).user?.id;
  if (guardianId == null) return Stream<List<ParentChildSummary>>.value(const <ParentChildSummary>[]);

  final String today = DateTime.now().toServiceDate();

  return combine2(
    ref.watch(studentRepositoryProvider).watchStudentsForGuardian(guardianId),
    ref.watch(attendanceRepositoryProvider).watchGuardianAttendance(guardianId: guardianId),
    (List<Student> students, List<AttendanceRecord> records) {
      final List<AttendanceRecord> todayRecords =
          records.where((AttendanceRecord r) => r.serviceDate == today).toList();
      return <ParentChildSummary>[
        for (final Student student in students)
          ParentChildSummary(
            student: student,
            todayRecord: todayRecords
                .where((AttendanceRecord r) => r.studentId == student.id)
                .sorted(
                  (AttendanceRecord a, AttendanceRecord b) =>
                      (b.boardedAtDevice ?? DateTime(0)).compareTo(a.boardedAtDevice ?? DateTime(0)),
                )
                .firstOrNull,
          ),
      ];
    },
  );
});
