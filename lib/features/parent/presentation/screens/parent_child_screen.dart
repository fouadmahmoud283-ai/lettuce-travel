import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/child_avatar.dart';
import 'package:lettuce_travel/core/widgets/section_header.dart';
import 'package:lettuce_travel/features/parent/presentation/controllers/parent_child_controller.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/schools/domain/entities/route_stop.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';

class ParentChildScreen extends ConsumerWidget {
  const ParentChildScreen({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Student?> studentAsync = ref.watch(parentStudentProvider(studentId));
    final AsyncValue<BusRoute?> routeAsync = ref.watch(parentStudentRouteProvider(studentId));
    final Trip? activeTrip = ref.watch(parentStudentActiveTripProvider(studentId)).asData?.value;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myChildren)),
      body: SafeArea(
        child: AsyncValueView<Student?>(
          value: studentAsync,
          data: (Student? student) {
            if (student == null) return AppEmptyView(message: context.l10n.noData, icon: Icons.person_search_outlined);
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: <Widget>[
                        ChildAvatar(
                          initials: student.initials,
                          photoUrl: student.photoUrl,
                          size: 72,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                student.fullName,
                                style: context.text.headlineSmall?.copyWith(
                                  color: context.colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (student.gradeOrClass.isNotEmpty)
                                Text(
                                  student.gradeOrClass,
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.colors.onPrimaryContainer.withValues(alpha: 0.78),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: context.l10n.routeLabel),
                AsyncValueView<BusRoute?>(
                  value: routeAsync,
                  data: (BusRoute? route) {
                    if (route == null) return Text(context.l10n.notSet);
                    final RouteStop? stop = route.stopById(student.stopId);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: context.colors.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _InfoRow(icon: Icons.route_outlined, label: context.l10n.routeLabel, value: route.name),
                            _InfoRow(
                              icon: Icons.location_on_outlined,
                              label: context.l10n.childStop,
                              value: stop?.name ?? context.l10n.notSet,
                            ),
                            _InfoRow(
                              icon: Icons.badge_outlined,
                              label: context.l10n.childSupervisor,
                              value: MockIds.supervisorNames[route.supervisorId] ?? context.l10n.notSet,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _ActionTile(
                  icon: Icons.map_outlined,
                  label: context.l10n.liveMap,
                  enabled: activeTrip != null,
                  subtitle: activeTrip == null ? context.l10n.noActiveTrip : null,
                  onTap: activeTrip == null
                      ? null
                      : () => context.push(
                            RoutePaths.of(RoutePaths.parentLiveMap, <String, String>{
                              'studentId': studentId,
                            }),
                          ),
                ),
                _ActionTile(
                  icon: Icons.history_rounded,
                  label: context.l10n.rideHistory,
                  onTap: () => context.push(
                    RoutePaths.of(RoutePaths.parentHistory, <String, String>{'studentId': studentId}),
                  ),
                ),
                _ActionTile(
                  icon: Icons.event_busy_outlined,
                  label: context.l10n.reportAbsence,
                  onTap: () => context.push(
                    RoutePaths.of(RoutePaths.parentReportAbsence, <String, String>{
                      'studentId': studentId,
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: context.colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text('$label: ', style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Expanded(child: Text(value, style: context.text.bodyMedium)),
          ],
        ),
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Material(
            color: context.colors.surface,
            elevation: 1,
            shadowColor: context.colors.shadow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(icon, color: context.colors.onSecondaryContainer),
                ),
              ),
              title: Text(label, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              subtitle: subtitle == null ? null : Text(subtitle!),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: onTap,
            ),
          ),
        ),
      );
}
