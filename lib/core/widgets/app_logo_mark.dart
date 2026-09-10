import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// The Lettuce Travel brand mark: a bus glyph on a rounded gradient tile.
///
/// Used wherever the product needs to introduce itself — the splash screen,
/// the sign-in screens — so the app has one consistent visual signature
/// instead of each screen composing its own icon-in-a-box.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    this.size = 72,
    this.onLight = false,
    super.key,
  });

  /// Overall tile size; the icon scales with it.
  final double size;

  /// True when painted on a light/neutral surface (sign-in screens). False
  /// (default) draws the tile on a plain container tint, for use on top of an
  /// already-colourful surface such as the gradient splash background.
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.32;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: onLight ? 0.28 : 0.4),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(
        Icons.directions_bus_filled_rounded,
        size: size * 0.54,
        color: Colors.white,
      ),
    );
  }
}

/// The brand mark plus wordmark, stacked, with a gentle entrance animation.
///
/// Used by the splash screen and reused by any full-bleed brand moment.
class AppBrandSplash extends StatelessWidget {
  const AppBrandSplash({
    required this.title,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double t, Widget? child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: child,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppLogoMark(size: 88),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
              ),
            ],
          ],
        ),
      );
}
