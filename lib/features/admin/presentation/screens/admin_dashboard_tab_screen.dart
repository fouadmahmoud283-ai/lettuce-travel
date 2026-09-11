import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/gradient_hero_header.dart';
import 'package:lettuce_travel/core/widgets/nav_card.dart';
import 'package:lettuce_travel/features/admin/presentation/controllers/admin_dashboard_controller.dart';

/// Admin dashboard — the first tab of the admin shell.
///
/// A bento-style layout: one large "live now" tile, two half tiles beside it,
/// and a full-width bar underneath, followed by quick-action shortcuts to the
/// four most frequently used management sections. Everything else lives one
/// tap away on the "More" tab (see [RoutePaths.adminMore]).
class AdminDashboardTabScreen extends ConsumerWidget {
  const AdminDashboardTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AdminDashboardStats> stats = ref.watch(adminDashboardProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.navBarClearance,
          ),
          children: <Widget>[
            GradientHeroHeader(
              title: context.l10n.administration,
              subtitle: context.l10n.adminHeroSubtitle,
              trailingIcon: Icons.insights_rounded,
            ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: AppSpacing.lg),
            AsyncValueView<AdminDashboardStats>(
              value: stats,
              data: (AdminDashboardStats s) => StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                children: <Widget>[
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: _BentoTile(
                      value: '${s.busesOnRoad}',
                      label: context.l10n.dashboardBusesOnRoad,
                      icon: Icons.directions_bus_filled_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[AppColors.meshTeal, AppColors.primary],
                      ),
                      big: true,
                      onTap: () => context.push(RoutePaths.adminLiveTrips),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: _BentoTile(
                      value: '${s.childrenOnBoard}',
                      label: context.l10n.dashboardChildrenOnBoard,
                      icon: Icons.groups_rounded,
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: _BentoTile(
                      value: '${s.openIncidents}',
                      label: context.l10n.dashboardOpenIncidents,
                      icon: Icons.warning_amber_rounded,
                      accent: s.openIncidents > 0 ? context.colors.error : null,
                      onTap: () => context.push(RoutePaths.adminIncidents),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 1,
                    child: _BentoTile(
                      value: '${s.schoolsCount}',
                      label: context.l10n.dashboardSchools,
                      icon: Icons.school_rounded,
                      wide: true,
                      onTap: () => context.push(RoutePaths.adminSchools),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 420.ms),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.quickActions,
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.5,
              children: <Widget>[
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
                  icon: Icons.campaign_outlined,
                  label: context.l10n.announcements,
                  onTap: () => context.push(RoutePaths.adminAnnouncements),
                ),
              ],
            ).animate().fadeIn(delay: 180.ms, duration: 420.ms),
          ],
        ),
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.value,
    required this.label,
    required this.icon,
    this.gradient,
    this.accent,
    this.big = false,
    this.wide = false,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Gradient? gradient;
  final Color? accent;
  final bool big;
  final bool wide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colors;
    final bool isDark = gradient != null;
    final Color fg = isDark ? Colors.white : (accent ?? scheme.onSurface);

    return Material(
      color: isDark ? null : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: isDark ? BorderSide.none : BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient),
          padding: big || wide
              ? const EdgeInsets.all(AppSpacing.md)
              : const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: wide
              ? Row(
                  children: <Widget>[
                    Icon(icon, color: fg, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      value,
                      style: context.text.titleLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        label,
                        style: context.text.bodyMedium?.copyWith(
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: fg.withValues(alpha: 0.7)),
                  ],
                )
              : Column(
                  mainAxisSize: big ? MainAxisSize.max : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: big ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, color: fg, size: big ? 30 : 20),
                    SizedBox(height: big ? AppSpacing.lg : AppSpacing.xs),
                    Text(
                      value,
                      style: (big ? context.text.headlineMedium : context.text.titleLarge)
                          ?.copyWith(color: fg, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: isDark ? Colors.white.withValues(alpha: 0.8) : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
