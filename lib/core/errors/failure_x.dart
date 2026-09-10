import 'package:flutter/widgets.dart';

import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';

/// Resolves a [Failure] to the localized string a user should see.
///
/// The single place a raw `messageKey` is turned into UI text — screens must
/// never show [Failure.debugMessage] (AGENTS.md section 6).
extension FailureMessageX on Failure {
  String message(BuildContext context) => switch (messageKey) {
        'errorNoConnection' => context.l10n.errorNoConnection,
        'errorNotAllowed' => context.l10n.errorNotAllowed,
        'errorNotFound' => context.l10n.errorNotFound,
        'errorInvalidAttendanceTransition' =>
          context.l10n.errorInvalidAttendanceTransition,
        'errorLocationPermission' => context.l10n.errorLocationPermission,
        'errorTripNotEnded' => context.l10n.errorTripNotEnded,
        'otpInvalid' => context.l10n.otpInvalid,
        'invalidCredentials' => context.l10n.invalidCredentials,
        _ => context.l10n.errorUnexpected,
      };
}
