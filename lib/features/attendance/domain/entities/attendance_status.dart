/// Custody state of one child on one trip.
///
/// The legal transition graph is:
///
///   pending  -> onBoard    (supervisor taps: child boarded)
///   pending  -> absent     (parent reported in advance)
///   pending  -> noShow     (supervisor waited, child never appeared)
///   onBoard  -> droppedOff (supervisor taps: child handed over)
///
/// Anything else is illegal. In particular `pending -> droppedOff` must be
/// impossible: a child cannot be dropped off if they were never picked up.
/// See invariant 3 in AGENTS.md.
enum AttendanceStatus {
  pending('pending'),
  onBoard('onBoard'),
  droppedOff('droppedOff'),
  absent('absent'),
  noShow('noShow');

  const AttendanceStatus(this.wireName);

  final String wireName;

  bool get isTerminal =>
      this == AttendanceStatus.droppedOff ||
      this == AttendanceStatus.absent ||
      this == AttendanceStatus.noShow;

  /// The single place that decides whether a transition is allowed. Both the UI
  /// and the repository consult this; the UI to disable the control, the
  /// repository to reject the write.
  bool canTransitionTo(AttendanceStatus next) => switch (this) {
        AttendanceStatus.pending => next == AttendanceStatus.onBoard ||
            next == AttendanceStatus.absent ||
            next == AttendanceStatus.noShow,
        AttendanceStatus.onBoard => next == AttendanceStatus.droppedOff,
        AttendanceStatus.droppedOff => false,
        AttendanceStatus.absent => false,
        AttendanceStatus.noShow => false,
      };

  static AttendanceStatus fromWire(String? value) => switch (value) {
        'onBoard' => AttendanceStatus.onBoard,
        'droppedOff' => AttendanceStatus.droppedOff,
        'absent' => AttendanceStatus.absent,
        'noShow' => AttendanceStatus.noShow,
        _ => AttendanceStatus.pending,
      };
}
