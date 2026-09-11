import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/child_avatar.dart';
import 'package:lettuce_travel/core/widgets/gradient_hero_header.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';
import 'package:lettuce_travel/features/attendance/presentation/widgets/attendance_status_x.dart';
import 'package:lettuce_travel/features/parent/presentation/controllers/parent_children_controller.dart';

/// Parent landing screen: one card per child, showing today at a glance.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ParentChildSummary>> children = ref.watch(parentChildrenProvider);

    // No AppBar: the gradient hero header below already carries the title,
    // and Messages / Settings are now tabs on the parent shell's bottom nav
    // rather than actions buried in an app bar.
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView<List<ParentChildSummary>>(
          value: children,
          data: (List<ParentChildSummary> summaries) => summaries.isEmpty
              ? AppEmptyView(message: context.l10n.noData, icon: Icons.family_restroom_rounded)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.navBarClearance,
                  ),
                  itemCount: summaries.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) return _OverviewHeader(summaries: summaries);
                    return _ChildCard(summary: summaries[index - 1]);
                  },
                ),
        ),
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.summaries});

  final List<ParentChildSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final int onBoard = summaries
        .where((ParentChildSummary summary) =>
            summary.todayRecord?.status == AttendanceStatus.onBoard)
        .length;
    final int droppedOff = summaries
        .where((ParentChildSummary summary) =>
            summary.todayRecord?.status == AttendanceStatus.droppedOff)
        .length;
    final int waiting = summaries
      .where((ParentChildSummary summary) =>
        (summary.todayRecord?.status ?? AttendanceStatus.pending) ==
        AttendanceStatus.pending)
      .length;
    return GradientHeroHeader(
      title: context.l10n.today,
      subtitle: context.l10n.myChildren,
      trailingIcon: Icons.wb_sunny_rounded,
      metrics: <HeroMetric>[
        HeroMetric(
          value: '$waiting',
          label: context.l10n.statusPending,
          icon: Icons.schedule_rounded,
        ),
        HeroMetric(
          value: '$onBoard',
          label: context.l10n.statusOnBoard,
          icon: Icons.directions_bus_filled_rounded,
        ),
        HeroMetric(
          value: '$droppedOff',
          label: context.l10n.statusDroppedOff,
          icon: Icons.check_circle_rounded,
        ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.summary});

  final ParentChildSummary summary;

  @override
  Widget build(BuildContext context) {
    final AttendanceStatus status = summary.todayRecord?.status ?? AttendanceStatus.pending;
    return Material(
      color: context.colors.surface,
      elevation: 1,
      shadowColor: context.colors.shadow.withValues(alpha: 0.14),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push(
          RoutePaths.of(RoutePaths.parentChild, <String, String>{'studentId': summary.student.id}),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              ChildAvatar(
                initials: summary.student.initials,
                photoUrl: summary.student.photoUrl,
                size: AppSpacing.avatarSize,
                ringColor: status.color(),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      summary.student.fullName,
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (summary.student.gradeOrClass.isNotEmpty)
                      Text(
                        summary.student.gradeOrClass,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.colors.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  StatusChip(label: status.label(context), color: status.color(), icon: status.icon()),
                  const SizedBox(height: AppSpacing.xs),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: context.colors.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
