import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/trips/data/repositories/fake_trip_repository.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';

/// The signed-in supervisor's assigned route. In v1 a supervisor has exactly
/// one, but the stream naturally supports more later.
final StreamProvider<BusRoute?> supervisorRouteProvider = StreamProvider<BusRoute?>((Ref ref) {
  final String? supervisorId = ref.watch(authControllerProvider).user?.id;
  if (supervisorId == null) return Stream<BusRoute?>.value(null);
  return ref
      .watch(busRouteRepositoryProvider)
      .watchSupervisorRoutes(supervisorId)
      .map((List<BusRoute> routes) => routes.isEmpty ? null : routes.first);
});

/// Today's trips for the signed-in supervisor — zero, one or two documents
/// depending on which have already been started.
final StreamProvider<List<Trip>> supervisorTodayTripsProvider =
    StreamProvider<List<Trip>>((Ref ref) {
  final String? supervisorId = ref.watch(authControllerProvider).user?.id;
  if (supervisorId == null) return Stream<List<Trip>>.value(const <Trip>[]);
  return ref.watch(tripRepositoryProvider).watchSupervisorTrips(
        supervisorId: supervisorId,
        serviceDate: DateTime.now().toServiceDate(),
      );
});
