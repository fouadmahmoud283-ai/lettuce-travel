import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';

/// Routes and their embedded stops.
///
/// Stops are always read and written as part of the route document — see
/// docs/data-model.md — so there is no separate `RouteStopRepository`.
abstract interface class BusRouteRepository {
  Stream<List<BusRoute>> watchSchoolRoutes(String schoolId);

  Stream<BusRoute?> watchRoute(String routeId);

  /// Routes a supervisor is allowed to start a trip on.
  Stream<List<BusRoute>> watchSupervisorRoutes(String supervisorId);

  Future<Result<BusRoute>> upsertRoute(BusRoute route);

  Future<Result<void>> deactivateRoute(String routeId);
}
