import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the active locale.
///
/// Arabic is the default: this product ships Arabic-first and English second.
/// The chosen locale is persisted per user (`users/{uid}.locale`) so a parent
/// gets notifications in the language they read.
class LocaleController extends Notifier<Locale> {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  @override
  Locale build() => arabic;

  void setLocale(Locale locale) => state = locale;

  void toggle() => state = state.languageCode == 'ar' ? english : arabic;

  bool get isRtl => state.languageCode == 'ar';
}

final NotifierProvider<LocaleController, Locale> localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
