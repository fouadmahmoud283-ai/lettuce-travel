/// Build-time configuration.
///
/// Values that differ between dev and prod live here, not scattered through
/// feature code. Secrets never live here — API keys go in the native platform
/// config (see docs/firebase-setup.md).
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.defaultLocaleCode,
    this.enableCrashReporting = true,
  });

  static const AppConfig dev = AppConfig(
    environment: Environment.dev,
    defaultLocaleCode: 'ar',
    enableCrashReporting: false,
  );

  static const AppConfig prod = AppConfig(
    environment: Environment.prod,
    defaultLocaleCode: 'ar',
  );

  final Environment environment;

  /// Arabic-first product: this is 'ar' in every environment.
  final String defaultLocaleCode;

  final bool enableCrashReporting;

  bool get isDev => environment == Environment.dev;
}

enum Environment { dev, prod }
