import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/child_avatar.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';
import 'package:lettuce_travel/features/attendance/presentation/widgets/attendance_status_x.dart';
import 'package:lettuce_travel/features/supervisor/presentation/controllers/trip_roster_controller.dart';

/// One child on the roster.
///
/// The whole row is the primary control: tapping it advances the child to the
/// next legal state (pending -> on board -> dropped off), a single motion that
/// works one-handed on a moving bus (AGENTS.md section 6). No-show is a
/// deliberately separate, smaller control so it can never be hit by accident.
class RosterRowTile extends StatelessWidget {
  const RosterRowTile({
    required this.row,
    required this.onPrimaryTap,
    required this.onMarkNoShow,
    super.key,
  });

  final RosterRow row;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onMarkNoShow;

  @override
  Widget build(BuildContext context) {
    final AttendanceStatus status = row.record.status;
    final bool isPending = status == AttendanceStatus.pending && !row.isAbsentToday;
    final bool isActionable = onPrimaryTap != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: row.isAbsentToday ? 0.5 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        color: status == AttendanceStatus.pending
            ? Theme.of(context).colorScheme.surface
            : status.color().withValues(alpha: 0.08),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isActionable
                ? () {
                    unawaited(HapticFeedback.mediumImpact());
                    onPrimaryTap!();
                  }
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSpacing.rosterRowHeight),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    ChildAvatar(
                      initials: row.student.initials,
                      photoUrl: row.student.photoUrl,
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
                            row.student.fullName,
                            style:
                                context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (row.stop != null)
                            Text(
                              row.stop!.name,
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.colors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (row.isAbsentToday)
                      StatusChip(
                        label: context.l10n.absentTag,
                        color: status.color(),
                        icon: status.icon(),
                        dense: true,
                      )
                    else ...<Widget>[
                      StatusChip(
                        label: status.label(context),
                        color: status.color(),
                        icon: status.icon(),
                        dense: true,
                      ),
                      if (isPending && onMarkNoShow != null)
                        IconButton(
                          icon: const Icon(Icons.person_off_outlined),
                          tooltip: context.l10n.markNoShow,
                          onPressed: onMarkNoShow,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
