import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus.dart';

/// The physical vehicles belonging to a school.
abstract interface class BusRepository {
  Stream<List<Bus>> watchSchoolBuses(String schoolId);

  Future<Result<Bus>> getBus(String busId);

  Future<Result<Bus>> upsertBus(Bus bus);

  Future<Result<void>> deactivateBus(String busId);
}
