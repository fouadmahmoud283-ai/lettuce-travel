import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/nav_card.dart';
import 'package:lettuce_travel/core/widgets/section_header.dart';

/// The admin shell's fourth tab: everything not already on the dashboard's
/// quick actions — staffing and operational tools, plus every setup section
/// again for anyone who forgets which four made the dashboard cut.
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.moreTabLabel),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.navBarClearance,
            ),
            children: <Widget>[
              SectionHeader(title: context.l10n.moreSectionOperations),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.3,
                children: <Widget>[
                  NavCard(
                    icon: Icons.badge_outlined,
                    label: context.l10n.staff,
                    onTap: () => context.push(RoutePaths.adminUsers),
                  ),
                  NavCard(
                    icon: Icons.report_gmailerrorred_rounded,
                    label: context.l10n.incidentsLabel,
                    onTap: () => context.push(RoutePaths.adminIncidents),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.moreSectionSetup),
              const SizedBox(height: AppSpacing.sm),
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
                    icon: Icons.campaign_outlined,
                    label: context.l10n.announcements,
                    onTap: () => context.push(RoutePaths.adminAnnouncements),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 320.ms),
        ),
      );
}
