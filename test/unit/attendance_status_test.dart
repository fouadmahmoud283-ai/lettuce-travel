import 'package:flutter_test/flutter_test.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';

/// The custody state machine is the safety-critical core of the product, so it
/// is tested directly rather than only through the UI. See invariant 3 in
/// AGENTS.md.
void main() {
  group('AttendanceStatus.canTransitionTo', () {
    test('a waiting child can board', () {
      expect(
        AttendanceStatus.pending.canTransitionTo(AttendanceStatus.onBoard),
        isTrue,
      );
    });

    test('a waiting child can be marked absent or a no-show', () {
      expect(
        AttendanceStatus.pending.canTransitionTo(AttendanceStatus.absent),
        isTrue,
      );
      expect(
        AttendanceStatus.pending.canTransitionTo(AttendanceStatus.noShow),
        isTrue,
      );
    });

    test('a child who never boarded can never be dropped off', () {
      expect(
        AttendanceStatus.pending.canTransitionTo(AttendanceStatus.droppedOff),
        isFalse,
      );
    });

    test('a child on board can be dropped off', () {
      expect(
        AttendanceStatus.onBoard.canTransitionTo(AttendanceStatus.droppedOff),
        isTrue,
      );
    });

    test('a child on board cannot be retroactively marked absent', () {
      expect(
        AttendanceStatus.onBoard.canTransitionTo(AttendanceStatus.absent),
        isFalse,
      );
    });

    test('terminal states are terminal', () {
      for (final AttendanceStatus terminal in <AttendanceStatus>[
        AttendanceStatus.droppedOff,
        AttendanceStatus.absent,
        AttendanceStatus.noShow,
      ]) {
        expect(terminal.isTerminal, isTrue);
        for (final AttendanceStatus next in AttendanceStatus.values) {
          expect(
            terminal.canTransitionTo(next),
            isFalse,
            reason: 'A correction must be used to change $terminal, not a '
                'transition to $next.',
          );
        }
      }
    });
  });

  group('AttendanceStatus.fromWire', () {
    test('maps known values', () {
      expect(AttendanceStatus.fromWire('onBoard'), AttendanceStatus.onBoard);
      expect(
        AttendanceStatus.fromWire('droppedOff'),
        AttendanceStatus.droppedOff,
      );
    });

    test('defaults to pending for unknown or missing values', () {
      expect(AttendanceStatus.fromWire(null), AttendanceStatus.pending);
      expect(AttendanceStatus.fromWire('nonsense'), AttendanceStatus.pending);
    });
  });
}
