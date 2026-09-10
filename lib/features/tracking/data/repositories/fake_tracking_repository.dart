import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/tracking/domain/entities/location_ping.dart';
import 'package:lettuce_travel/features/tracking/domain/repositories/tracking_repository.dart';

/// In-memory stand-in for the Realtime Database live-location node.
///
/// There is no device GPS or foreground service wired up yet, so this fake
/// animates a bus smoothly back and forth along a hand-picked path per route,
/// purely so the parent live map and the admin live-trips view have something
/// true-to-life to show while a trip is `inProgress`.
class FakeTrackingRepository implements TrackingRepository {
  final Map<String, StreamController<LocationPing?>> _controllers =
      <String, StreamController<LocationPing?>>{};
  final Map<String, Timer> _timers = <String, Timer>{};
  final Set<String> _broadcastingTrips = <String>{};
  final StreamController<bool> _broadcastState = StreamController<bool>.broadcast();

  static const Map<String, List<GeoPosition>> _routePaths = <String, List<GeoPosition>>{
    MockIds.routeIdA: <GeoPosition>[
      GeoPosition(lat: 29.960, lng: 31.250),
      GeoPosition(lat: 29.965, lng: 31.255),
      GeoPosition(lat: 29.970, lng: 31.260),
    ],
    MockIds.routeIdB: <GeoPosition>[
      GeoPosition(lat: 29.950, lng: 31.280),
      GeoPosition(lat: 29.955, lng: 31.285),
    ],
  };

  StreamController<LocationPing?> _controllerFor(String tripId) =>
      _controllers.putIfAbsent(tripId, () => StreamController<LocationPing?>.broadcast());

  @override
  Future<Result<void>> startBroadcasting({
    required String tripId,
    required String schoolId,
    required String routeId,
  }) async {
    _broadcastingTrips.add(tripId);
    _broadcastState.add(true);

    final List<GeoPosition> path = _routePaths[routeId] ?? _routePaths[MockIds.routeIdA]!;
    final StreamController<LocationPing?> controller = _controllerFor(tripId);

    int segment = 0;
    double progress = 0;
    const double stepPerTick = 1 / 14;

    _timers[tripId]?.cancel();
    // Emit immediately so a listener never waits for the first tick.
    controller.add(_pingAt(tripId, path, segment, progress));
    _timers[tripId] = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      progress += stepPerTick;
      if (progress >= 1) {
        progress = 0;
        segment = (segment + 1) % path.length;
      }
      controller.add(_pingAt(tripId, path, segment, progress));
    });
    return const Result<void>.ok(null);
  }

  LocationPing _pingAt(
    String tripId,
    List<GeoPosition> path,
    int segment,
    double progress,
  ) {
    final GeoPosition from = path[segment];
    final GeoPosition to = path[(segment + 1) % path.length];
    final double lat = from.lat + (to.lat - from.lat) * progress;
    final double lng = from.lng + (to.lng - from.lng) * progress;
    final double heading = math.atan2(to.lng - from.lng, to.lat - from.lat) * 180 / math.pi;
    return LocationPing(
      tripId: tripId,
      position: GeoPosition(lat: lat, lng: lng),
      recordedAt: DateTime.now(),
      speedKmh: 28,
      heading: (heading + 360) % 360,
    );
  }

  @override
  Future<Result<void>> stopBroadcasting(String tripId) async {
    _timers.remove(tripId)?.cancel();
    _broadcastingTrips.remove(tripId);
    _broadcastState.add(_broadcastingTrips.isNotEmpty);
    _controllers[tripId]?.add(null);
    return const Result<void>.ok(null);
  }

  @override
  Stream<bool> watchBroadcastState() async* {
    yield _broadcastingTrips.isNotEmpty;
    yield* _broadcastState.stream;
  }

  @override
  Stream<LocationPing?> watchTripLocation(String tripId) => _controllerFor(tripId).stream;
}

final Provider<TrackingRepository> trackingRepositoryProvider =
    Provider<TrackingRepository>((Ref ref) => FakeTrackingRepository());

final StreamProviderFamily<LocationPing?, String> tripLocationProvider =
    StreamProvider.family<LocationPing?, String>(
  (Ref ref, String tripId) => ref.watch(trackingRepositoryProvider).watchTripLocation(tripId),
);
