import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/widgets/glass_surface.dart';

/// The gradient-mesh hero card used at the top of every role's home screen: a
/// title, an optional subtitle, a trailing icon, and a row of frosted-glass
/// metric tiles underneath.
///
/// Centralising this means the mesh gradient and glass treatment only have to
/// be tuned once, and any future "home" screen starts from the same premium
/// visual language for free.
class GradientHeroHeader extends StatelessWidget {
  const GradientHeroHeader({
    required this.title,
    this.subtitle,
    this.trailingIcon,
    this.metrics,
    this.backgroundImage,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? trailingIcon;

  /// An optional row of [HeroMetric]s shown under the title, each rendered as
  /// a frosted-glass tile floating over the gradient.
  final List<HeroMetric>? metrics;

  /// An optional asset path (e.g. `'assets/images/school_building.jpg'`)
  /// blended faintly under the mesh gradient — a touch of real photography
  /// without ever competing with the white text on top of it.
  final String? backgroundImage;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Stack(
        children: <Widget>[
          // Positioned.fill is required here: MeshGradientBackground's own
          // Stack has only Positioned children (the glow circles), so with no
          // non-positioned child of its own it would otherwise collapse to
          // zero size instead of filling behind the content below.
          if (backgroundImage != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  backgroundImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          Positioned.fill(
            child: MeshGradientBackground(
              // A touch more opaque when sitting over a photo, so the mesh
              // still reads as the dominant layer and the text stays legible.
              colors: backgroundImage == null
                  ? AppColors.heroMeshGradient
                  : <Color>[
                      AppColors.meshTeal.withValues(alpha: 0.92),
                      AppColors.meshViolet.withValues(alpha: 0.92),
                      AppColors.meshCoral.withValues(alpha: 0.92),
                    ],
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.meshTeal.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
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
                      GlassSurface(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        blurSigma: 12,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(trailingIcon, color: Colors.white, size: 26),
                      ),
                  ],
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
                if (metrics != null && metrics!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < metrics!.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(child: metrics![i]),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One glanceable metric inside a [GradientHeroHeader], rendered as a small
/// frosted-glass tile so it reads as a distinct floating element rather than
/// bare text over the gradient.
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
  Widget build(BuildContext context) => GlassSurface(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        blurSigma: 10,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 16),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
            ),
          ],
        ),
      );
}
