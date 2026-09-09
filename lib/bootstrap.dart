import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/app.dart';
import 'package:lettuce_travel/core/utils/app_logger.dart';

/// Boots the application.
///
/// Responsibilities, in order:
///  1. bind the widgets layer
///  2. lock orientation (supervisors use the app one-handed, portrait only)
///  3. initialise Firebase
///  4. install global error handlers that report to Crashlytics
///  5. mount the widget tree inside a [ProviderScope]
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // TODO(scaffold): uncomment once `flutterfire configure` has generated
  // lib/core/config/firebase_options.dart (see docs/firebase-setup.md).
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Uncaught Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  runApp(
    const ProviderScope(
      child: LettuceTravelApp(),
    ),
  );
}
