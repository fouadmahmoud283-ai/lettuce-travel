import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';
import 'package:lettuce_travel/features/students/domain/repositories/student_repository.dart';

/// In-memory stand-in for the Firestore `students` collection.
///
/// See `MockIds` for the shared demo-world ids this seed is built from.
class FakeStudentRepository implements StudentRepository {
  FakeStudentRepository() {
    _students.seed(<Student>[
      const Student(
        id: MockIds.studentId1,
        schoolId: MockIds.schoolId,
        fullName: 'Yousef Hassan',
        routeId: MockIds.routeIdA,
        stopId: MockIds.stopId1,
        guardianIds: <String>[MockIds.parentUidA],
        gradeOrClass: 'KG2-B',
        notes: 'Allergic to peanuts',
      ),
      const Student(
        id: MockIds.studentId2,
        schoolId: MockIds.schoolId,
        fullName: 'Laila Hassan',
        routeId: MockIds.routeIdA,
        stopId: MockIds.stopId1,
        guardianIds: <String>[MockIds.parentUidA],
        gradeOrClass: 'KG1-A',
      ),
      const Student(
        id: MockIds.studentId3,
        schoolId: MockIds.schoolId,
        fullName: 'Omar Adel',
        routeId: MockIds.routeIdA,
        stopId: MockIds.stopId2,
        guardianIds: <String>[MockIds.parentUidA, MockIds.parentUidB],
        gradeOrClass: 'KG2-A',
      ),
      const Student(
        id: MockIds.studentId4,
        schoolId: MockIds.schoolId,
        fullName: 'Sara Tarek',
        routeId: MockIds.routeIdB,
        stopId: MockIds.stopId4,
        guardianIds: <String>[MockIds.parentUidB],
        gradeOrClass: 'Grade 1-C',
      ),
      const Student(
        id: MockIds.studentId5,
        schoolId: MockIds.schoolId,
        fullName: 'Nour Khaled',
        routeId: MockIds.routeIdB,
        stopId: MockIds.stopId4,
        guardianIds: <String>[MockIds.parentUidC],
        gradeOrClass: 'KG1-B',
      ),
      const Student(
        id: MockIds.studentId6,
        schoolId: MockIds.schoolId,
        fullName: 'Adam Mostafa',
        routeId: MockIds.routeIdB,
        stopId: MockIds.stopId5,
        guardianIds: <String>[MockIds.parentUidC],
        gradeOrClass: 'Grade 1-A',
        notes: 'Needs help with the seatbelt',
      ),
    ]);
  }

  final MockCollection<Student> _students = MockCollection<Student>();

  @override
  Stream<List<Student>> watchStudentsForGuardian(String guardianId) =>
      _students.watch((Student s) => s.guardianIds.contains(guardianId));

  @override
  Stream<List<Student>> watchStudentsOnRoute(String routeId) =>
      _students.watch((Student s) => s.routeId == routeId && s.isActive);

  @override
  Stream<List<Student>> watchSchoolStudents(String schoolId) =>
      _students.watch((Student s) => s.schoolId == schoolId);

  @override
  Future<Result<Student>> getStudent(String studentId) async {
    for (final Student s in _students.items) {
      if (s.id == studentId) return Result<Student>.ok(s);
    }
    return const Result<Student>.err(NotFoundFailure());
  }

  @override
  Future<Result<Student>> upsertStudent(Student student) async {
    _students.upsert(student, (Student s) => s.id == student.id);
    return Result<Student>.ok(student);
  }

  @override
  Future<Result<void>> linkGuardian({
    required String studentId,
    required String guardianId,
  }) async {
    final Result<Student> current = await getStudent(studentId);
    return current.when(
      ok: (Student student) {
        if (student.guardianIds.contains(guardianId)) {
          return const Result<void>.ok(null);
        }
        _students.upsert(
          student.copyWith(
            guardianIds: <String>[...student.guardianIds, guardianId],
          ),
          (Student s) => s.id == studentId,
        );
        return const Result<void>.ok(null);
      },
      err: Result<void>.err,
    );
  }

  @override
  Future<Result<void>> unlinkGuardian({
    required String studentId,
    required String guardianId,
  }) async {
    final Result<Student> current = await getStudent(studentId);
    return current.when(
      ok: (Student student) {
        _students.upsert(
          student.copyWith(
            guardianIds: student.guardianIds
                .where((String id) => id != guardianId)
                .toList(),
          ),
          (Student s) => s.id == studentId,
        );
        return const Result<void>.ok(null);
      },
      err: Result<void>.err,
    );
  }

  @override
  Future<Result<void>> deactivateStudent(String studentId) async {
    final Result<Student> current = await getStudent(studentId);
    return current.when(
      ok: (Student student) {
        _students.upsert(
          student.copyWith(isActive: false),
          (Student s) => s.id == studentId,
        );
        return const Result<void>.ok(null);
      },
      err: Result<void>.err,
    );
  }
}

final Provider<StudentRepository> studentRepositoryProvider =
    Provider<StudentRepository>((Ref ref) => FakeStudentRepository());
