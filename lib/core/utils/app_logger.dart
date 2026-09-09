import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application logger.
///
/// Privacy rule (AGENTS.md section 6): never log a student's full name, a phone
/// number, or a precise coordinate at info level. Use ids.
abstract final class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  static void debug(String message) => _logger.d(message);

  static void info(String message) => _logger.i(message);

  static void warn(String message, {Object? error}) =>
      _logger.w(message, error: error);

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
