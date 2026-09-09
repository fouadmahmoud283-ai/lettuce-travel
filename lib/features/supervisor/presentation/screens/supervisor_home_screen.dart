import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/widgets/scaffold_placeholder.dart';

/// Supervisor landing screen: today's two trips, and a big start button.
class SupervisorHomeScreen extends ConsumerWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const ScaffoldPlaceholder(
        title: 'My trips',
        description:
            'Today: the morning pickup and the afternoon drop-off for the '
            'assigned route. Starting a trip loads the roster and begins '
            'sharing the bus location with parents.',
        todo: <String>[
          'Today list from TripRepository.watchSupervisorTrips',
          'Start trip: permission checks, then location + roster',
          'Persistent banner while a trip is live, with the pending-sync count',
          'End trip: blocked while any child is still marked on board',
          'SOS button reachable from every screen during a trip',
        ],
      );
}
