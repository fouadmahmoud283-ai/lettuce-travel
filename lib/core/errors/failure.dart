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

/// Raised when `endTrip` is called while a child is still marked on board.
/// The UI should prevent this before it ever reaches the repository — see
/// invariant 3 in AGENTS.md — this is the defence-in-depth backstop.
class TripNotReadyToEndFailure extends Failure {
  const TripNotReadyToEndFailure({required this.remainingOnBoard})
      : super(
          messageKey: 'errorTripNotEnded',
          debugMessage: '$remainingOnBoard student(s) still on board',
        );

  final int remainingOnBoard;
}

class LocationFailure extends Failure {
  const LocationFailure({required super.messageKey, super.debugMessage});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.debugMessage})
      : super(messageKey: 'errorUnexpected');
}
