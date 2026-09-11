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
import 'package:lettuce_travel/core/widgets/gradient_hero_header.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
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

    // No settings action, no native AppBar: the hero header below carries the
    // title (matching the admin dashboard and parent home pattern), and the
    // supervisor shell's second tab is the profile/settings screen.
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView<BusRoute?>(
          value: routeAsync,
          data: (BusRoute? route) {
            if (route == null) {
              return AppEmptyView(message: context.l10n.noTripsToday, icon: Icons.event_busy_outlined);
            }
            return AsyncValueView<List<Trip>>(
              value: tripsAsync,
              data: (List<Trip> trips) => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.navBarClearance,
                ),
                children: <Widget>[
                  GradientHeroHeader(
                    title: context.l10n.myTrips,
                    subtitle: context.l10n.today,
                    trailingIcon: Icons.directions_bus_filled_rounded,
                    backgroundImage: 'assets/images/supervisor_hero.jpg',
                  ),
                  const SizedBox(height: AppSpacing.lg),
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

    return Material(
      color: scheme.surface,
      elevation: isLive ? 3 : 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(
              color: isLive ? AppColors.statusOnBoard : scheme.outlineVariant,
              width: isLive ? 4 : 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    type == TripType.morningPickup
                        ? Icons.wb_sunny_outlined
                        : Icons.home_outlined,
                    color: scheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    typeLabel,
                    style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (isLive)
                  StatusChip(
                    label: context.l10n.tripInProgress,
                    color: AppColors.statusOnBoard,
                    icon: Icons.podcasts_rounded,
                    dense: true,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('${context.l10n.routeLabel}: ${route.name}', style: context.text.bodyMedium),
            const SizedBox(height: 2),
            Text(
              context.l10n.stopsCount(route.stops.length),
              style: context.text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (isLive) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  StatusChip(
                    label: context.l10n.countOnBoard(trip!.onBoardCount),
                    color: AppColors.statusOnBoard,
                    icon: Icons.directions_bus_filled_rounded,
                    dense: true,
                  ),
                  StatusChip(
                    label: context.l10n.countDroppedOff(trip!.completedCount),
                    color: AppColors.statusDroppedOff,
                    icon: Icons.check_circle_rounded,
                    dense: true,
                  ),
                ],
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
