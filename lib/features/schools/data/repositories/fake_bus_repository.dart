import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus.dart';
import 'package:lettuce_travel/features/schools/domain/repositories/bus_repository.dart';

/// In-memory stand-in for the Firestore `buses` collection.
class FakeBusRepository implements BusRepository {
  FakeBusRepository() {
    _buses.seed(<Bus>[
      const Bus(
        id: MockIds.busIdA,
        schoolId: MockIds.schoolId,
        plateNumber: 'أ ب ج 1234',
        capacity: 24,
        model: 'Toyota Hiace',
        driverName: 'Mahmoud Ali',
        driverPhone: '+201001234567',
      ),
      const Bus(
        id: MockIds.busIdB,
        schoolId: MockIds.schoolId,
        plateNumber: 'د هـ و 5678',
        capacity: 18,
        model: 'Hyundai H1',
        driverName: 'Ahmed Samir',
        driverPhone: '+201009876543',
      ),
    ]);
  }

  final MockCollection<Bus> _buses = MockCollection<Bus>();

  @override
  Stream<List<Bus>> watchSchoolBuses(String schoolId) =>
      _buses.watch((Bus b) => b.schoolId == schoolId);

  @override
  Future<Result<Bus>> getBus(String busId) async {
    final Bus? bus = _buses.items.where((Bus b) => b.id == busId).firstOrNull;
    return bus == null
        ? const Result<Bus>.err(NotFoundFailure())
        : Result<Bus>.ok(bus);
  }

  @override
  Future<Result<Bus>> upsertBus(Bus bus) async {
    _buses.upsert(bus, (Bus b) => b.id == bus.id);
    return Result<Bus>.ok(bus);
  }

  @override
  Future<Result<void>> deactivateBus(String busId) async {
    final Result<Bus> current = await getBus(busId);
    return current.when(
      ok: (Bus bus) {
        _buses.upsert(bus.copyWith(isActive: false), (Bus b) => b.id == busId);
        return const Result<void>.ok(null);
      },
      err: Result<void>.err,
    );
  }
}

final Provider<BusRepository> busRepositoryProvider =
    Provider<BusRepository>((Ref ref) => FakeBusRepository());

/// Convenience one-shot lookup, used by screens that only need one bus's
/// plate number or driver — the parent child screen, the admin route editor.
final FutureProviderFamily<Bus?, String> busByIdProvider =
    FutureProvider.family<Bus?, String>((Ref ref, String busId) async {
  final Result<Bus> result = await ref.watch(busRepositoryProvider).getBus(busId);
  return result.valueOrNull;
});
