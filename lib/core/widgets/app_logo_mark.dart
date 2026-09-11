import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// The Lettuce Travel brand mark: the company's actual logo
/// (`assets/images/logo.jpg` — a circular badge, bus + lettuce leaves, with
/// the wordmark baked into the artwork) on a soft white disc with a drop
/// shadow for depth.
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

  /// Shared [Hero] tag for screens that want the logo to travel smoothly
  /// between them on push/pop (the phone, OTP and admin sign-in screens) —
  /// deliberately not used on the splash screen, which only ever *redirects*
  /// away (no Hero transition happens on a redirect) into a screen that
  /// doesn't show the mark at all.
  static const String heroTag = 'appLogoMark';

  /// Overall tile size; the artwork scales with it.
  final double size;

  /// True when painted on a light/neutral surface (sign-in screens). False
  /// (default) draws a slightly stronger shadow, for use on top of an
  /// already-colourful surface such as the gradient splash background.
  final bool onLight;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: onLight ? 0.22 : 0.4),
              blurRadius: size * 0.28,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        // A hairline padding keeps the artwork's own white margin from
        // touching the disc's shadowed edge, so the circle crop reads as
        // deliberate framing rather than a tight crop of the source image.
        padding: EdgeInsets.all(size * 0.04),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _FallbackGlyph(size: size),
          ),
        ),
      );
}

/// Drawn only if `assets/images/logo.jpg` is ever missing or fails to
/// decode — the bus-glyph-on-gradient look this screen used before the real
/// logo existed.
class _FallbackGlyph extends StatelessWidget {
  const _FallbackGlyph({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          Icons.directions_bus_filled_rounded,
          size: size * 0.54,
          color: Colors.white,
        ),
      );
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
