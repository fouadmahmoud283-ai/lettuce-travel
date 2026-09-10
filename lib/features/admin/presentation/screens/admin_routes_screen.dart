import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_repository.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/schools/domain/entities/route_stop.dart';

class AdminRoutesScreen extends ConsumerWidget {
  const AdminRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BusRoute>> routes = ref.watch(_routesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.routesLabel)),
      body: SafeArea(
        child: AsyncValueView<List<BusRoute>>(
          value: routes,
          data: (List<BusRoute> items) => items.isEmpty
              ? AppEmptyView(message: context.l10n.noData, icon: Icons.alt_route_rounded)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) => _RouteCard(route: items[index]),
                ),
        ),
      ),
    );
  }
}

final StreamProvider<List<BusRoute>> _routesProvider = StreamProvider<List<BusRoute>>(
  (Ref ref) => ref.watch(busRouteRepositoryProvider).watchSchoolRoutes(MockIds.schoolId),
);

final StreamProvider<List<Bus>> _schoolBusesProvider = StreamProvider<List<Bus>>(
  (Ref ref) => ref.watch(busRepositoryProvider).watchSchoolBuses(MockIds.schoolId),
);

class _RouteCard extends ConsumerWidget {
  const _RouteCard({required this.route});

  final BusRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Bus?> bus = ref.watch(busByIdProvider(route.busId));
    return Card(
      child: ExpansionTile(
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(Icons.alt_route_rounded, color: context.colors.onSecondaryContainer),
          ),
        ),
        title: Text(route.name, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${bus.asData?.value?.plateNumber ?? '…'} · '
          '${MockIds.supervisorNames[route.supervisorId] ?? context.l10n.notSet} · '
          '${context.l10n.stopsCount(route.stops.length)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => _RouteFormSheet(route: route),
          ),
        ),
        children: <Widget>[
          for (final RouteStop stop in route.stopsInPickupOrder)
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: context.colors.primaryContainer,
                foregroundColor: context.colors.onPrimaryContainer,
                child: Text('${stop.order}'),
              ),
              title: Text(stop.name),
              subtitle: Text('${stop.expectedMorningTime ?? '--'} · ${stop.expectedAfternoonTime ?? '--'}'),
            ),
        ],
      ),
    );
  }
}

class _RouteFormSheet extends ConsumerStatefulWidget {
  const _RouteFormSheet({required this.route});

  final BusRoute route;

  @override
  ConsumerState<_RouteFormSheet> createState() => _RouteFormSheetState();
}

class _RouteFormSheetState extends ConsumerState<_RouteFormSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.route.name);
  late String _busId = widget.route.busId;
  late String _supervisorId = widget.route.supervisorId;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Bus>> buses = ref.watch(_schoolBusesProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(context.l10n.editRoute, style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: _name, decoration: InputDecoration(labelText: context.l10n.routeNameLabel)),
          const SizedBox(height: AppSpacing.sm),
          buses.when(
            data: (List<Bus> items) => DropdownButtonFormField<String>(
              initialValue: _busId,
              decoration: InputDecoration(labelText: context.l10n.assignBusLabel),
              items: <DropdownMenuItem<String>>[
                for (final Bus b in items)
                  DropdownMenuItem<String>(value: b.id, child: Text(b.plateNumber)),
              ],
              onChanged: (String? v) => setState(() => _busId = v ?? _busId),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _supervisorId,
            decoration: InputDecoration(labelText: context.l10n.assignSupervisorLabel),
            items: <DropdownMenuItem<String>>[
              for (final MapEntry<String, String> entry in MockIds.supervisorNames.entries)
                DropdownMenuItem<String>(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (String? v) => setState(() => _supervisorId = v ?? _supervisorId),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: _save, child: Text(context.l10n.save)),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final BusRoute updated = widget.route.copyWith(
      name: _name.text.trim(),
      busId: _busId,
      supervisorId: _supervisorId,
    );
    await ref.read(busRouteRepositoryProvider).upsertRoute(updated);
    if (mounted) Navigator.of(context).pop();
  }
}
