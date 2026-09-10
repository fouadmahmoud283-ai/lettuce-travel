import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/child_avatar.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myChildren),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: context.l10n.announcements,
            onPressed: () => context.push(RoutePaths.parentMessages),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.settings,
            onPressed: () => context.push(RoutePaths.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncValueView<List<ParentChildSummary>>(
          value: children,
          data: (List<ParentChildSummary> summaries) => summaries.isEmpty
              ? Center(child: Text(context.l10n.noData))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: summaries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext context, int index) =>
                      _ChildCard(summary: summaries[index]),
                ),
        ),
      ),
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
      color: context.colors.surfaceContainerHighest,
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
              StatusChip(label: status.label(context), color: status.color(), icon: status.icon()),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
