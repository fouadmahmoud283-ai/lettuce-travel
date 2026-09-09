/// A domain-level error.
///
/// Repositories return `Result<T>` carrying a [Failure]; they do not throw
/// across layers. [messageKey] resolves to a localized string — the UI must
/// never show [debugMessage] to a user.
sealed class Failure {
  const Failure({required this.messageKey, this.debugMessage});

  final String messageKey;
  final String? debugMessage;

  @override
  String toString() => '$runtimeType($messageKey): ${debugMessage ?? ''}';
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.debugMessage})
      : super(messageKey: 'errorNoConnection');
}

class AuthFailure extends Failure {
  const AuthFailure({required super.messageKey, super.debugMessage});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.debugMessage})
      : super(messageKey: 'errorNotAllowed');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.debugMessage})
      : super(messageKey: 'errorNotFound');
}

/// Raised when an attendance transition would break the custody state machine,
/// e.g. dropping off a child who was never marked on board.
class InvalidTransitionFailure extends Failure {
  InvalidTransitionFailure({required this.from, required this.to})
      : super(
          messageKey: 'errorInvalidAttendanceTransition',
          debugMessage: 'Illegal attendance transition $from -> $to',
        );

  final String from;
  final String to;
}

class LocationFailure extends Failure {
  const LocationFailure({required super.messageKey, super.debugMessage});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.debugMessage})
      : super(messageKey: 'errorUnexpected');
}
