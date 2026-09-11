import 'package:flutter/material.dart';

/// Brand palette for Lettuce Travel.
///
/// Warm and friendly, but with unambiguous status colours: a supervisor glancing
/// at the roster must tell "on board" from "waiting" from "absent" in one look,
/// including in bright sunlight through a bus window.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF146B68);      // trusted teal
  static const Color primaryDark = Color(0xFF0B4543);
  static const Color secondary = Color(0xFFF2A65A);    // warm school-bus amber
  static const Color tertiary = Color(0xFFE76F51);     // friendly coral

  // Attendance status
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusOnBoard = Color(0xFF167C72);
  static const Color statusDroppedOff = Color(0xFF1565C0);
  static const Color statusAbsent = Color(0xFF6A1B9A);
  static const Color statusNoShow = Color(0xFFC62828);

  // Feedback
  static const Color success = Color(0xFF167C72);
  static const Color warning = Color(0xFFEF6C00);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  // Neutrals
  static const Color surfaceLight = Color(0xFFF7FAF5);
  static const Color surfaceDark = Color(0xFF101918);

  // --- Glassmorphism / gradient-mesh accents ---
  // Used by GradientHeroHeader, GlassCard and the floating bottom nav shell.
  // A three-stop mesh reads as "premium" rather than a flat two-colour blend.
  static const Color meshTeal = Color(0xFF0E5652);
  static const Color meshViolet = Color(0xFF3A3170);
  static const Color meshCoral = Color(0xFFE76F51);

  static const List<Color> heroMeshGradient = <Color>[meshTeal, meshViolet, meshCoral];

  /// Glass tint over a dark backdrop (hero headers, dark bottom nav).
  static Color glassTintDark(double opacity) => Colors.white.withValues(alpha: opacity);

  /// Glass tint over a light backdrop (cards on a plain scaffold background).
  static Color glassTintLight(double opacity) => Colors.white.withValues(alpha: opacity);

  static const Color glowTeal = Color(0xFF20C7BB);
  static const Color glowCoral = Color(0xFFFF8A65);
}
