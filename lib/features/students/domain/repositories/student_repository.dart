import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';

/// Students and their guardian links.
///
/// A parent-facing implementation must only ever query by
/// guardianIds array-contains uid. Never fetch a whole school of students into
/// a parent build (invariant 5).
abstract interface class StudentRepository {
  Stream<List<Student>> watchStudentsForGuardian(String guardianId);

  Stream<List<Student>> watchStudentsOnRoute(String routeId);

  Stream<List<Student>> watchSchoolStudents(String schoolId);

  Future<Result<Student>> getStudent(String studentId);

  Future<Result<Student>> upsertStudent(Student student);

  Future<Result<void>> linkGuardian({
    required String studentId,
    required String guardianId,
  });

  Future<Result<void>> unlinkGuardian({
    required String studentId,
    required String guardianId,
  });

  /// Soft delete only. Historical attendance must keep resolving the name.
  Future<Result<void>> deactivateStudent(String studentId);
}
