import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/schools/domain/entities/route_stop.dart';
import 'package:lettuce_travel/features/schools/domain/repositories/bus_route_repository.dart';

/// In-memory stand-in for the Firestore `routes` collection.
class FakeBusRouteRepository implements BusRouteRepository {
  FakeBusRouteRepository() {
    _routes.seed(<BusRoute>[
      const BusRoute(
        id: MockIds.routeIdA,
        schoolId: MockIds.schoolId,
        name: 'Route A — Maadi',
        busId: MockIds.busIdA,
        supervisorId: MockIds.supervisorUidA,
        stops: <RouteStop>[
          RouteStop(
            id: MockIds.stopId1,
            name: 'Road 9 corner',
            order: 1,
            location: GeoPosition(lat: 29.960, lng: 31.250),
            expectedMorningTime: '07:15',
            expectedAfternoonTime: '14:40',
          ),
          RouteStop(
            id: MockIds.stopId2,
            name: 'Victoria Square',
            order: 2,
            location: GeoPosition(lat: 29.965, lng: 31.255),
            expectedMorningTime: '07:25',
            expectedAfternoonTime: '14:30',
          ),
          RouteStop(
            id: MockIds.stopId3,
            name: 'Degla Club gate',
            order: 3,
            location: GeoPosition(lat: 29.970, lng: 31.260),
            expectedMorningTime: '07:35',
            expectedAfternoonTime: '14:20',
          ),
        ],
      ),
      const BusRoute(
        id: MockIds.routeIdB,
        schoolId: MockIds.schoolId,
        name: 'Route B — Zahraa',
        busId: MockIds.busIdB,
        supervisorId: MockIds.supervisorUidB,
        stops: <RouteStop>[
          RouteStop(
            id: MockIds.stopId4,
            name: 'Zahraa Maadi entrance',
            order: 1,
            location: GeoPosition(lat: 29.950, lng: 31.280),
            expectedMorningTime: '07:10',
            expectedAfternoonTime: '14:45',
          ),
          RouteStop(
            id: MockIds.stopId5,
            name: 'Corniche crossing',
            order: 2,
            location: GeoPosition(lat: 29.955, lng: 31.285),
            expectedMorningTime: '07:20',
            expectedAfternoonTime: '14:35',
          ),
        ],
      ),
    ]);
  }

  final MockCollection<BusRoute> _routes = MockCollection<BusRoute>();

  @override
  Stream<List<BusRoute>> watchSchoolRoutes(String schoolId) =>
      _routes.watch((BusRoute r) => r.schoolId == schoolId);

  @override
  Stream<BusRoute?> watchRoute(String routeId) =>
      _routes.watchOne((BusRoute r) => r.id == routeId);

  @override
  Stream<List<BusRoute>> watchSupervisorRoutes(String supervisorId) =>
      _routes.watch(
        (BusRoute r) => r.supervisorId == supervisorId && r.isActive,
      );

  @override
  Future<Result<BusRoute>> upsertRoute(BusRoute route) async {
    _routes.upsert(route, (BusRoute r) => r.id == route.id);
    return Result<BusRoute>.ok(route);
  }

  @override
  Future<Result<void>> deactivateRoute(String routeId) async {
    final BusRoute? existing =
        _routes.items.where((BusRoute r) => r.id == routeId).firstOrNull;
    if (existing == null) return const Result<void>.err(NotFoundFailure());
    _routes.upsert(
      existing.copyWith(isActive: false),
      (BusRoute r) => r.id == routeId,
    );
    return const Result<void>.ok(null);
  }
}

final Provider<BusRouteRepository> busRouteRepositoryProvider =
    Provider<BusRouteRepository>((Ref ref) => FakeBusRouteRepository());

final StreamProviderFamily<BusRoute?, String> routeByIdProvider =
    StreamProvider.family<BusRoute?, String>(
  (Ref ref, String routeId) => ref.watch(busRouteRepositoryProvider).watchRoute(routeId),
);
