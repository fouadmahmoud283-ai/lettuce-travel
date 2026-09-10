import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/schools/domain/entities/school.dart';

/// The tenant root. A super admin manages one or more schools; every other
/// document in the system hangs off a `schoolId` (invariant 7 in AGENTS.md).
abstract interface class SchoolRepository {
  Stream<List<School>> watchSchools();

  Stream<School?> watchSchool(String schoolId);

  Future<Result<School>> upsertSchool(School school);

  /// Soft delete only, like every deactivation in this app: history must keep
  /// resolving the name.
  Future<Result<void>> deactivateSchool(String schoolId);
}
