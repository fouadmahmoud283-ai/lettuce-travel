import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/widgets/scaffold_placeholder.dart';

/// Super admin landing screen.
///
/// Presentation only. Data comes from the schools / students / trips features —
/// never define a repository or an entity inside a role feature.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const ScaffoldPlaceholder(
        title: 'Administration',
        description:
            'Set up and run the service: schools, buses, routes and stops, '
            'students and guardians, supervisors, live trips, reports and '
            'incidents.',
        todo: <String>[
          'Dashboard: buses on the road now, children on board, open incidents',
          'Schools, buses and routes CRUD with a map stop picker',
          'Students CRUD with guardian linking and route/stop assignment',
          'Staff management and route assignment for supervisors',
          'Live trips map across the whole school',
          'Attendance reports with CSV export by date range',
          'Announcements to all parents or to one route',
        ],
      );
}
