import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// The dark-teal gradient card used at the top of the admin and parent home
/// screens: a title, an optional subtitle, a trailing icon, and a slot for a
/// row of metrics underneath.
///
/// Both screens used to hand-build this gradient independently; centralising
/// it here means a change to the brand gradient only has to happen once, and
/// any future "home" screen (e.g. a school-level admin dashboard) starts from
/// the same visual language for free.
class GradientHeroHeader extends StatelessWidget {
  const GradientHeroHeader({
    required this.title,
    this.subtitle,
    this.trailingIcon,
    this.metrics,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? trailingIcon;

  /// An optional row of [HeroMetric]s shown under the title.
  final List<HeroMetric>? metrics;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[AppColors.primaryDark, scheme.primary],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: text.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (trailingIcon != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(trailingIcon, color: AppColors.secondary, size: 26),
                  ),
              ],
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: text.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
            if (metrics != null && metrics!.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  for (final HeroMetric metric in metrics!)
                    Expanded(child: metric),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One glanceable number inside a [GradientHeroHeader]'s metric row.
class HeroMetric extends StatelessWidget {
  const HeroMetric({
    required this.value,
    required this.label,
    required this.icon,
    super.key,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Colors.white.withValues(alpha: 0.82), size: 18),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
        ],
      );
}
