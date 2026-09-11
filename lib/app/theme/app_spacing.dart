/// Spacing and sizing tokens.
///
/// [minTouchTarget] is deliberately larger than the Material default: the
/// supervisor taps these controls one-handed on a moving bus.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  static const double minTouchTarget = 56;
  static const double rosterRowHeight = 88;
  static const double avatarSize = 48;

  /// Extra bottom padding every tab-root screen under [RoleShellScaffold]
  /// must add to its outermost scrollable, since that shell renders the body
  /// behind a floating translucent bottom nav (`extendBody: true`) rather
  /// than reserving solid space for it. Screens reached by a `push` (detail
  /// screens, sheets) do not need this — only the four/three/two tab roots.
  static const double navBarClearance = 104;
}
