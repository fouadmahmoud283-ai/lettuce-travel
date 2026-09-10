import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus.dart';

class AdminBusesScreen extends ConsumerWidget {
  const AdminBusesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Bus>> buses = ref.watch(_busesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.buses)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _BusFormSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: AsyncValueView<List<Bus>>(
          value: buses,
          data: (List<Bus> items) => items.isEmpty
              ? Center(child: Text(context.l10n.noData))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Bus bus = items[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.directions_bus_outlined),
                        title: Text(bus.plateNumber),
                        subtitle: Text('${bus.model} · ${bus.driverName}'),
                        trailing: Text('${bus.capacity}'),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => _BusFormSheet(bus: bus),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

final StreamProvider<List<Bus>> _busesProvider = StreamProvider<List<Bus>>(
  (Ref ref) => ref.watch(busRepositoryProvider).watchSchoolBuses(MockIds.schoolId),
);

class _BusFormSheet extends ConsumerStatefulWidget {
  const _BusFormSheet({this.bus});

  final Bus? bus;

  @override
  ConsumerState<_BusFormSheet> createState() => _BusFormSheetState();
}

class _BusFormSheetState extends ConsumerState<_BusFormSheet> {
  late final TextEditingController _plate = TextEditingController(text: widget.bus?.plateNumber);
  late final TextEditingController _capacity =
      TextEditingController(text: widget.bus?.capacity.toString() ?? '20');
  late final TextEditingController _model = TextEditingController(text: widget.bus?.model);
  late final TextEditingController _driver = TextEditingController(text: widget.bus?.driverName);

  @override
  void dispose() {
    _plate.dispose();
    _capacity.dispose();
    _model.dispose();
    _driver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
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
            Text(widget.bus == null ? context.l10n.addBus : context.l10n.editBus, style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _plate, decoration: InputDecoration(labelText: context.l10n.busPlateLabel)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: context.l10n.busCapacityLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _model, decoration: InputDecoration(labelText: context.l10n.busModelLabel)),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _driver, decoration: InputDecoration(labelText: context.l10n.driverNameLabel)),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: _save, child: Text(context.l10n.save)),
          ],
        ),
      );

  Future<void> _save() async {
    final Bus bus = Bus(
      id: widget.bus?.id ?? 'bus_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: MockIds.schoolId,
      plateNumber: _plate.text.trim(),
      capacity: int.tryParse(_capacity.text.trim()) ?? 20,
      model: _model.text.trim(),
      driverName: _driver.text.trim(),
    );
    await ref.read(busRepositoryProvider).upsertBus(bus);
    if (mounted) Navigator.of(context).pop();
  }
}
