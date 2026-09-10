import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// A small coloured pill used to show a status at a glance.
///
/// Deliberately generic (a label, a colour, an optional icon) so it stays in
/// `core/`: the mapping from a domain enum (e.g. `AttendanceStatus`) to a
/// colour and a localized label belongs in that feature's presentation layer,
/// never here — see the dependency rule in AGENTS.md section 3.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: dense ? AppSpacing.sm : AppSpacing.md,
          vertical: dense ? AppSpacing.xs / 2 : AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: dense ? 14 : 16, color: color),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: (dense
                      ? Theme.of(context).textTheme.labelSmall
                      : Theme.of(context).textTheme.labelMedium)
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
}
