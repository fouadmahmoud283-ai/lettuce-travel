import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/widgets/scaffold_placeholder.dart';

/// Parent landing screen: one card per child, showing today at a glance.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const ScaffoldPlaceholder(
        title: 'My children',
        description:
            'Today at a glance for each child: waiting, on the bus, or dropped '
            'off, with the time it happened and a live map while the bus is '
            'running.',
        todo: <String>[
          'Child cards from StudentRepository.watchStudentsForGuardian',
          'Status chip driven by the latest AttendanceRecord for today',
          'Live map screen showing the bus, the route stops and the home stop',
          'Ride history per child',
          'Report an absence for a chosen date',
          'Announcements and messages from the school',
        ],
      );
}
