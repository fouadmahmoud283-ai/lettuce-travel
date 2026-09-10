import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/localization/locale_controller.dart';
import 'package:lettuce_travel/app/router/app_router.dart';
import 'package:lettuce_travel/app/theme/app_theme.dart';
import 'package:lettuce_travel/l10n/app_localizations.dart';

/// Root widget. Owns routing, theming and locale.
class LettuceTravelApp extends ConsumerWidget {
  const LettuceTravelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final Locale locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'Lettuce Travel',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,

      // Arabic first: it is the default locale for this product.
      locale: locale,
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,

      // Keep text scale sane: supervisors and parents both use this in a hurry,
      // and an unbounded scale factor breaks the roster row layout.
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
