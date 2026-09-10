import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';

/// Supervisors, derived from the routes they are assigned to.
///
/// There is no `UserRepository` yet to list staff directly by role (only the
/// signed-in user's own `AppUser` is ever resolved — see
/// `features/auth/data/repositories/fake_auth_repository.dart`), so this
/// reads the assignment the other way around: routes know their supervisor.
class AdminStaffScreen extends ConsumerWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BusRoute>> routes = ref.watch(_routesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.staff)),
      body: SafeArea(
        child: AsyncValueView<List<BusRoute>>(
          value: routes,
          data: (List<BusRoute> items) => items.isEmpty
              ? Center(child: Text(context.l10n.noData))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final BusRoute route = items[index];
                    final String name =
                        MockIds.supervisorNames[route.supervisorId] ?? context.l10n.notSet;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.badge_outlined)),
                        title: Text(name),
                        subtitle: Text('${context.l10n.routeLabel}: ${route.name}'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

final StreamProvider<List<BusRoute>> _routesProvider = StreamProvider<List<BusRoute>>(
  (Ref ref) => ref.watch(busRouteRepositoryProvider).watchSchoolRoutes(MockIds.schoolId),
);
