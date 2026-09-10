import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/errors/failure_x.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/supervisor/presentation/controllers/supervisor_home_controller.dart';
import 'package:lettuce_travel/features/tracking/data/repositories/fake_tracking_repository.dart';
import 'package:lettuce_travel/features/trips/data/repositories/fake_trip_repository.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip_type.dart';

/// Supervisor landing screen: today's two trips, and a big start button.
class SupervisorHomeScreen extends ConsumerWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BusRoute?> routeAsync = ref.watch(supervisorRouteProvider);
    final AsyncValue<List<Trip>> tripsAsync = ref.watch(supervisorTodayTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myTrips),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.settings,
            onPressed: () => context.push(RoutePaths.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncValueView<BusRoute?>(
          value: routeAsync,
          data: (BusRoute? route) {
            if (route == null) {
              return Center(child: Text(context.l10n.noTripsToday));
            }
            return AsyncValueView<List<Trip>>(
              value: tripsAsync,
              data: (List<Trip> trips) => ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: <Widget>[
                  Text(context.l10n.today, style: context.text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _TripCard(
                    route: route,
                    type: TripType.morningPickup,
                    trip: _tripOfType(trips, TripType.morningPickup),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TripCard(
                    route: route,
                    type: TripType.afternoonDropoff,
                    trip: _tripOfType(trips, TripType.afternoonDropoff),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Trip? _tripOfType(List<Trip> trips, TripType type) {
    for (final Trip trip in trips) {
      if (trip.type == type) return trip;
    }
    return null;
  }
}

class _TripCard extends ConsumerWidget {
  const _TripCard({required this.route, required this.type, this.trip});

  final BusRoute route;
  final TripType type;
  final Trip? trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = context.colors;
    final String typeLabel = type == TripType.morningPickup
        ? context.l10n.morningPickup
        : context.l10n.afternoonDropoff;

    final bool isLive = trip?.isLive ?? false;
    final bool hasEnded = trip?.hasEnded ?? false;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: isLive ? Border.all(color: AppColors.statusOnBoard, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                type == TripType.morningPickup
                    ? Icons.wb_sunny_outlined
                    : Icons.home_outlined,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(typeLabel, style: context.text.titleMedium),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusOnBoard.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Text(
                    context.l10n.tripInProgress,
                    style: context.text.labelSmall
                        ?.copyWith(color: AppColors.statusOnBoard, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${context.l10n.routeLabel}: ${route.name}', style: context.text.bodyMedium),
          Text(
            context.l10n.stopsCount(route.stops.length),
            style: context.text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (isLive) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${context.l10n.countOnBoard(trip!.onBoardCount)} · '
              '${context.l10n.countDroppedOff(trip!.completedCount)}',
              style: context.text.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: hasEnded
                ? OutlinedButton(
                    onPressed: () => context.push(
                      RoutePaths.of(RoutePaths.supervisorRoster, <String, String>{
                        'tripId': trip!.id,
                      }),
                    ),
                    child: Text(context.l10n.tripEnded),
                  )
                : FilledButton.icon(
                    icon: Icon(isLive ? Icons.list_alt_rounded : Icons.play_arrow_rounded),
                    label: Text(isLive ? context.l10n.resumeTrip : context.l10n.startTrip),
                    onPressed: () => unawaited(_startOrResume(context, ref)),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _startOrResume(BuildContext context, WidgetRef ref) async {
    if (trip != null) {
      unawaited(
        context.push(
          RoutePaths.of(RoutePaths.supervisorRoster, <String, String>{'tripId': trip!.id}),
        ),
      );
      return;
    }
    final Result<Trip> result = await ref.read(tripRepositoryProvider).startTrip(
          routeId: route.id,
          type: type,
          serviceDate: DateTime.now().toServiceDate(),
        );
    if (!context.mounted) return;
    result.when(
      ok: (Trip startedTrip) {
        // GPS streaming starts the moment a trip goes live and must stop the
        // moment it ends — invariant 4 in AGENTS.md.
        unawaited(
          ref.read(trackingRepositoryProvider).startBroadcasting(
                tripId: startedTrip.id,
                schoolId: startedTrip.schoolId,
                routeId: startedTrip.routeId,
              ),
        );
        context.push(
          RoutePaths.of(RoutePaths.supervisorRoster, <String, String>{'tripId': startedTrip.id}),
        );
      },
      err: (Failure failure) => context.showSnack(failure.message(context), isError: true),
    );
  }
}
