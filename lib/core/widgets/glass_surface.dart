import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// A frosted-glass panel: blurred backdrop, translucent tint, a hairline
/// highlight border that catches light along the top edge.
///
/// This is the building block of the app's glassmorphic direction — the
/// floating bottom nav, hero header overlays, and any card that needs to feel
/// like it is floating above the content behind it rather than sitting flat
/// on the page.
///
/// Built on `BackdropFilter` rather than a third-party "glass" package: the
/// effect is a handful of well-understood Flutter primitives, so it has no
/// extra dependency-resolution risk on a machine that cannot run
/// `flutter pub get` to verify it.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
    this.blurSigma = 18,
    this.tintColor,
    this.tintOpacity = 0.14,
    this.borderOpacity = 0.28,
    this.padding,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;

  /// Defaults to white, which reads correctly over both the dark hero
  /// gradients and, at a lower opacity, over a plain light scaffold.
  final Color? tintColor;
  final double tintOpacity;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Color tint = tintColor ?? Colors.white;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: tintOpacity),
            borderRadius: borderRadius,
            border: Border.all(color: tint.withValues(alpha: borderOpacity)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                tint.withValues(alpha: tintOpacity + 0.06),
                tint.withValues(alpha: tintOpacity),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A [GlassSurface] shaped like a card, for content that sits over a
/// gradient-mesh background (e.g. a stat tile inside a hero header).
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onLight = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// True when the card sits on a light/plain background rather than a dark
  /// gradient — lowers the tint and border opacity so it doesn't muddy a
  /// white page.
  final bool onLight;

  @override
  Widget build(BuildContext context) => GlassSurface(
        padding: padding,
        tintOpacity: onLight ? 0.55 : 0.14,
        borderOpacity: onLight ? 0.5 : 0.28,
        tintColor: onLight ? Theme.of(context).colorScheme.surface : Colors.white,
        child: child,
      );
}

/// A decorative three-stop gradient mesh, used behind glass content on hero
/// headers and the bottom nav shell. Cheap to paint (a single `Container`
/// gradient plus two soft radial glows), no image assets required.
class MeshGradientBackground extends StatelessWidget {
  const MeshGradientBackground({
    required this.colors,
    this.borderRadius,
    super.key,
  });

  final List<Color> colors;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        // SizedBox.expand as the first child gives this inner Stack a
        // non-positioned child to size itself against; without one, a Stack
        // containing only Positioned children collapses to zero size instead
        // of filling whatever space the caller gives this widget.
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Stack(
            children: <Widget>[
              const SizedBox.expand(),
              Positioned(
                top: -40,
                right: -30,
                child: _glow(colors.last, 140),
              ),
              Positioned(
                bottom: -50,
                left: -20,
                child: _glow(colors.first, 160),
              ),
            ],
          ),
        ),
      );

  Widget _glow(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
          ),
        ),
      );
}
