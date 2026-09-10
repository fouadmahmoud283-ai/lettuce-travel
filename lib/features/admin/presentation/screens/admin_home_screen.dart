import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/gradient_hero_header.dart';
import 'package:lettuce_travel/core/widgets/nav_card.dart';
import 'package:lettuce_travel/core/widgets/stat_tile.dart';
import 'package:lettuce_travel/features/admin/presentation/controllers/admin_dashboard_controller.dart';

/// Super admin landing screen.
///
/// Presentation only. Data comes from the schools / students / trips features —
/// never define a repository or an entity inside a role feature.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AdminDashboardStats> stats = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.administration),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.settings,
            onPressed: () => context.push(RoutePaths.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            GradientHeroHeader(
              title: context.l10n.administration,
              subtitle: context.l10n.adminHeroSubtitle,
              trailingIcon: Icons.insights_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            AsyncValueView<AdminDashboardStats>(
              value: stats,
              data: (AdminDashboardStats s) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.6,
                children: <Widget>[
                  StatTile(
                    value: '${s.busesOnRoad}',
                    label: context.l10n.dashboardBusesOnRoad,
                    icon: Icons.directions_bus_filled_rounded,
                  ),
                  StatTile(
                    value: '${s.childrenOnBoard}',
                    label: context.l10n.dashboardChildrenOnBoard,
                    icon: Icons.groups_rounded,
                  ),
                  StatTile(
                    value: '${s.openIncidents}',
                    label: context.l10n.dashboardOpenIncidents,
                    icon: Icons.warning_amber_rounded,
                    color: s.openIncidents > 0 ? Theme.of(context).colorScheme.error : null,
                  ),
                  StatTile(
                    value: '${s.schoolsCount}',
                    label: context.l10n.dashboardSchools,
                    icon: Icons.school_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.3,
              children: <Widget>[
                NavCard(
                  icon: Icons.school_outlined,
                  label: context.l10n.schools,
                  onTap: () => context.push(RoutePaths.adminSchools),
                ),
                NavCard(
                  icon: Icons.directions_bus_outlined,
                  label: context.l10n.buses,
                  onTap: () => context.push(RoutePaths.adminBuses),
                ),
                NavCard(
                  icon: Icons.alt_route_rounded,
                  label: context.l10n.routesLabel,
                  onTap: () => context.push(RoutePaths.adminRoutes),
                ),
                NavCard(
                  icon: Icons.groups_outlined,
                  label: context.l10n.students,
                  onTap: () => context.push(RoutePaths.adminStudents),
                ),
                NavCard(
                  icon: Icons.badge_outlined,
                  label: context.l10n.staff,
                  onTap: () => context.push(RoutePaths.adminUsers),
                ),
                NavCard(
                  icon: Icons.map_outlined,
                  label: context.l10n.liveTrips,
                  badgeCount: stats.asData?.value.busesOnRoad,
                  onTap: () => context.push(RoutePaths.adminLiveTrips),
                ),
                NavCard(
                  icon: Icons.bar_chart_rounded,
                  label: context.l10n.reports,
                  onTap: () => context.push(RoutePaths.adminReports),
                ),
                NavCard(
                  icon: Icons.report_gmailerrorred_rounded,
                  label: context.l10n.incidentsLabel,
                  badgeCount: stats.asData?.value.openIncidents,
                  onTap: () => context.push(RoutePaths.adminIncidents),
                ),
                NavCard(
                  icon: Icons.campaign_outlined,
                  label: context.l10n.announcements,
                  onTap: () => context.push(RoutePaths.adminAnnouncements),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
