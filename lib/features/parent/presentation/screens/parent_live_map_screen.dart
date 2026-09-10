import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/utils/geo_utils.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/parent/presentation/controllers/parent_child_controller.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/schools/domain/entities/route_stop.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';
import 'package:lettuce_travel/features/tracking/data/repositories/fake_tracking_repository.dart';
import 'package:lettuce_travel/features/tracking/domain/entities/location_ping.dart';
import 'package:lettuce_travel/features/tracking/presentation/widgets/route_map_view.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';

class ParentLiveMapScreen extends ConsumerWidget {
  const ParentLiveMapScreen({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Trip? trip = ref.watch(parentStudentActiveTripProvider(studentId)).asData?.value;
    final AsyncValue<BusRoute?> routeAsync = ref.watch(parentStudentRouteProvider(studentId));
    final Student? student = ref.watch(parentStudentProvider(studentId)).asData?.value;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.liveMap)),
      body: SafeArea(
        child: trip == null
            ? Center(child: Text(context.l10n.noActiveTrip))
            : AsyncValueView<BusRoute?>(
                value: routeAsync,
                data: (BusRoute? route) {
                  if (route == null || student == null) {
                    return Center(child: Text(context.l10n.noData));
                  }
                  final AsyncValue<LocationPing?> pingAsync =
                      ref.watch(tripLocationProvider(trip.id));
                  final LocationPing? ping = pingAsync.asData?.value;
                  final List<RouteStop> orderedStops =
                      route.stopsInPickupOrder; // display order is stable either way

                  RouteStop? nearestStop;
                  double nearestDistance = double.infinity;
                  if (ping != null) {
                    for (final RouteStop stop in orderedStops) {
                      final double d = GeoUtils.distanceMeters(
                        ping.position.lat,
                        ping.position.lng,
                        stop.location.lat,
                        stop.location.lng,
                      );
                      if (d < nearestDistance) {
                        nearestDistance = d;
                        nearestStop = stop;
                      }
                    }
                  }
                  final Set<String> passedStopIds = nearestStop == null
                      ? <String>{}
                      : orderedStops
                          .where((RouteStop s) => s.order < nearestStop!.order)
                          .map((RouteStop s) => s.id)
                          .toSet();

                  final RouteStop? myStop = route.stopById(student.stopId);
                  final int? etaMinutes = (ping == null || myStop == null)
                      ? null
                      : _estimateEtaMinutes(ping, myStop);

                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: <Widget>[
                      RouteMapView(
                        stops: orderedStops,
                        busPosition: ping?.position,
                        busHeading: ping?.heading ?? 0,
                        passedStopIds: passedStopIds,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (ping == null)
                        Text(context.l10n.locationStale)
                      else ...<Widget>[
                        if (etaMinutes != null)
                          Text(
                            context.l10n.busEtaLabel(etaMinutes),
                            style: context.text.titleMedium,
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.l10n.lastUpdated(ping.recordedAt.toClockTime(context.l10n.localeName)),
                          style: context.text.bodySmall
                              ?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }

  int _estimateEtaMinutes(LocationPing ping, RouteStop stop) {
    final double meters = GeoUtils.distanceMeters(
      ping.position.lat,
      ping.position.lng,
      stop.location.lat,
      stop.location.lng,
    );
    final double speedKmh = ping.speedKmh > 5 ? ping.speedKmh : 25;
    final double minutes = (meters / 1000) / speedKmh * 60;
    return minutes.clamp(1, 45).round();
  }
}
