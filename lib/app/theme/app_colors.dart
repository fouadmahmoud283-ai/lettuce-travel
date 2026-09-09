import 'package:flutter/material.dart';

/// Brand palette for Lettuce Travel.
///
/// Warm and friendly, but with unambiguous status colours: a supervisor glancing
/// at the roster must tell "on board" from "waiting" from "absent" in one look,
/// including in bright sunlight through a bus window.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF2E7D32);      // lettuce green
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color secondary = Color(0xFFF9A825);    // school-bus amber
  static const Color tertiary = Color(0xFF00838F);

  // Attendance status
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusOnBoard = Color(0xFF2E7D32);
  static const Color statusDroppedOff = Color(0xFF1565C0);
  static const Color statusAbsent = Color(0xFF6A1B9A);
  static const Color statusNoShow = Color(0xFFC62828);

  // Feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  // Neutrals
  static const Color surfaceLight = Color(0xFFFDFDF7);
  static const Color surfaceDark = Color(0xFF121411);
}
