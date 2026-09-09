import 'package:flutter/material.dart';

/// Small ergonomics helpers used across the UI.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;

  /// True when the active locale is right-to-left. Prefer directional widgets
  /// over branching on this, but it is occasionally needed for icons.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  Size get screenSize => MediaQuery.sizeOf(this);

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }

  // TODO(scaffold): add `AppL10n get l10n => AppL10n.of(this);` once
  // `flutter gen-l10n` has generated the localizations class.
}
