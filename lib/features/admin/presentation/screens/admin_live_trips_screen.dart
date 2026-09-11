import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_repository.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/tracking/data/repositories/fake_tracking_repository.dart';
import 'package:lettuce_travel/features/tracking/domain/entities/location_ping.dart';
import 'package:lettuce_travel/features/tracking/presentation/widgets/route_map_view.dart';
import 'package:lettuce_travel/features/trips/data/repositories/fake_trip_repository.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip_type.dart';

class AdminLiveTripsScreen extends ConsumerWidget {
  const AdminLiveTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(_activeTripsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.liveTrips)),
      body: SafeArea(
        child: AsyncValueView<List<Trip>>(
          value: trips,
          data: (List<Trip> items) => items.isEmpty
              ? AppEmptyView(message: context.l10n.noActiveTrip, icon: Icons.map_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.navBarClearance,
                  ),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _LiveTripCard(trip: items[index]),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: (index * 60).clamp(0, 400)),
                        duration: 300.ms,
                      ).slideY(begin: 0.04, end: 0),
                ),
        ),
      ),
    );
  }
}

final StreamProvider<List<Trip>> _activeTripsProvider = StreamProvider<List<Trip>>(
  (Ref ref) => ref.watch(tripRepositoryProvider).watchActiveTrips(MockIds.schoolId),
);

class _LiveTripCard extends ConsumerWidget {
  const _LiveTripCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BusRoute? route = ref.watch(routeByIdProvider(trip.routeId)).asData?.value;
    final Bus? bus = ref.watch(busByIdProvider(trip.busId)).asData?.value;
    final LocationPing? ping = ref.watch(tripLocationProvider(trip.id)).asData?.value;

    return Material(
      color: context.colors.surface,
      elevation: 2,
      shadowColor: context.colors.shadow.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                trip.type == TripType.morningPickup ? Icons.wb_sunny_outlined : Icons.home_outlined,
                color: context.colors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  route?.name ?? trip.routeId,
                  style: context.text.titleMedium,
                ),
              ),
              Text(bus?.plateNumber ?? '', style: context.text.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${context.l10n.countOnBoard(trip.onBoardCount)} · '
            '${context.l10n.countDroppedOff(trip.completedCount)}',
            style: context.text.bodySmall,
          ),
          if (route != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            RouteMapView(
              stops: route.stopsInPickupOrder,
              busPosition: ping?.position,
              busHeading: ping?.heading ?? 0,
            ),
          ],
        ],
        ),
      ),
    );
  }
}
