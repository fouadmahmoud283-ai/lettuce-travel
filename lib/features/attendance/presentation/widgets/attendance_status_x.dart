import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';

/// Maps the custody state machine onto colour, label and icon.
///
/// Lives in this feature's presentation layer, not in `core/widgets`, because
/// `core/` never imports a feature entity (AGENTS.md section 3).
extension AttendanceStatusUiX on AttendanceStatus {
  Color color() => switch (this) {
        AttendanceStatus.pending => AppColors.statusPending,
        AttendanceStatus.onBoard => AppColors.statusOnBoard,
        AttendanceStatus.droppedOff => AppColors.statusDroppedOff,
        AttendanceStatus.absent => AppColors.statusAbsent,
        AttendanceStatus.noShow => AppColors.statusNoShow,
      };

  IconData icon() => switch (this) {
        AttendanceStatus.pending => Icons.hourglass_empty_rounded,
        AttendanceStatus.onBoard => Icons.directions_bus_filled_rounded,
        AttendanceStatus.droppedOff => Icons.check_circle_rounded,
        AttendanceStatus.absent => Icons.event_busy_rounded,
        AttendanceStatus.noShow => Icons.person_off_rounded,
      };

  String label(BuildContext context) => switch (this) {
        AttendanceStatus.pending => context.l10n.statusPending,
        AttendanceStatus.onBoard => context.l10n.statusOnBoard,
        AttendanceStatus.droppedOff => context.l10n.statusDroppedOff,
        AttendanceStatus.absent => context.l10n.statusAbsent,
        AttendanceStatus.noShow => context.l10n.statusNoShow,
      };
}
