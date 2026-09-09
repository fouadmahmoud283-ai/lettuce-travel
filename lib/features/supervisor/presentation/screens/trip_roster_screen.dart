import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/widgets/scaffold_placeholder.dart';

/// The check-in screen. This is the most important screen in the product.
///
/// Design constraints, from the field:
///  * one-handed use, standing on a moving bus;
///  * rows at least 88dp tall so a tap cannot land on the neighbouring child;
///  * the child photo is the primary identifier, the name is secondary;
///  * every tap gives haptic feedback and an immediate colour change, because
///    the supervisor will not wait for a network round trip;
///  * it must work identically with no signal.
class TripRosterScreen extends ConsumerWidget {
  const TripRosterScreen({required this.tripId, super.key});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ScaffoldPlaceholder(
        title: 'Roster',
        description:
            'Children on this trip, grouped by stop in travel order. Tap a '
            'child to mark them on board, and tap again at their stop to mark '
            'them dropped off. Trip: $tripId',
        todo: const <String>[
          'Group by stop, in pickup or drop-off order for the trip type',
          'Row: photo, name, stop, status chip, large action button',
          'Optimistic local state, then enqueue through OfflineCheckInQueue',
          'Disable drop-off until the child is on board (invariant 3)',
          'Undo window of 60 seconds on the last action',
          'No-show action with confirmation',
          'Grey out children with an absence notice for today',
          'Header counters: waiting / on board / dropped off',
        ],
      );
}
