import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/schools/domain/entities/school.dart';
import 'package:lettuce_travel/features/schools/domain/repositories/school_repository.dart';

/// In-memory stand-in for the Firestore `schools` collection.
class FakeSchoolRepository implements SchoolRepository {
  FakeSchoolRepository() {
    _schools.seed(<School>[
      const School(
        id: MockIds.schoolId,
        name: 'Little Stars Nursery',
        nameAr: 'حضانة النجوم الصغيرة',
        address: '12 Road 9, Maadi, Cairo',
        location: GeoPosition(lat: 29.9603, lng: 31.2568),
        contactPhone: '+20221234567',
      ),
    ]);
  }

  final MockCollection<School> _schools = MockCollection<School>();

  @override
  Stream<List<School>> watchSchools() => _schools.watch();

  @override
  Stream<School?> watchSchool(String schoolId) =>
      _schools.watchOne((School s) => s.id == schoolId);

  @override
  Future<Result<School>> upsertSchool(School school) async {
    _schools.upsert(school, (School s) => s.id == school.id);
    return Result<School>.ok(school);
  }

  @override
  Future<Result<void>> deactivateSchool(String schoolId) async {
    final School? existing =
        _schools.items.where((School s) => s.id == schoolId).firstOrNull;
    if (existing == null) return const Result<void>.err(NotFoundFailure());
    _schools.upsert(
      existing.copyWith(isActive: false),
      (School s) => s.id == schoolId,
    );
    return const Result<void>.ok(null);
  }
}

final Provider<SchoolRepository> schoolRepositoryProvider =
    Provider<SchoolRepository>((Ref ref) => FakeSchoolRepository());
