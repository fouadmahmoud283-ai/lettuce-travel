import 'package:lettuce_travel/bootstrap.dart';

/// Entry point for the default (development) flavour.
///
/// Flavour-specific entry points (`main_dev.dart`, `main_prod.dart`) can be added
/// later; they should each call [bootstrap] with a different [AppConfig].
void main() => bootstrap();
