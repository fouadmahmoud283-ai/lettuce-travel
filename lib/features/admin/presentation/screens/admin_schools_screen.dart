import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/models/geo_position.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_school_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/school.dart';

class AdminSchoolsScreen extends ConsumerWidget {
  const AdminSchoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<School>> schools = ref.watch(_schoolsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.schools)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: AsyncValueView<List<School>>(
          value: schools,
          data: (List<School> items) => items.isEmpty
              ? AppEmptyView(message: context.l10n.noData, icon: Icons.school_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final School school = items[index];
                    return Card(
                      child: ListTile(
                        leading: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Icon(Icons.school_outlined, color: context.colors.onPrimaryContainer),
                          ),
                        ),
                        title: Text(
                          school.name,
                          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(school.address.isEmpty ? context.l10n.notSet : school.address),
                        trailing: const Icon(Icons.edit_outlined, size: 20),
                        onTap: () => _openForm(context, ref, school: school),
                      ),
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
                          duration: 260.ms,
                        ).slideX(begin: 0.03, end: 0);
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref, {School? school}) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _SchoolFormSheet(school: school),
      );
}

final StreamProvider<List<School>> _schoolsProvider = StreamProvider<List<School>>(
  (Ref ref) => ref.watch(schoolRepositoryProvider).watchSchools(),
);

class _SchoolFormSheet extends ConsumerStatefulWidget {
  const _SchoolFormSheet({this.school});

  final School? school;

  @override
  ConsumerState<_SchoolFormSheet> createState() => _SchoolFormSheetState();
}

class _SchoolFormSheetState extends ConsumerState<_SchoolFormSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.school?.name);
  late final TextEditingController _nameAr = TextEditingController(text: widget.school?.nameAr);
  late final TextEditingController _address = TextEditingController(text: widget.school?.address);
  late final TextEditingController _phone =
      TextEditingController(text: widget.school?.contactPhone);

  @override
  void dispose() {
    _name.dispose();
    _nameAr.dispose();
    _address.dispose();
    _phone.dispose();
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
            Text(
              widget.school == null ? context.l10n.addSchool : context.l10n.editSchool,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _name, decoration: InputDecoration(labelText: context.l10n.schoolNameLabel)),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _nameAr, decoration: InputDecoration(labelText: context.l10n.schoolNameArLabel)),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _address, decoration: InputDecoration(labelText: context.l10n.addressLabel)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: context.l10n.phoneNumber),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: _save, child: Text(context.l10n.save)),
          ],
        ),
      );

  Future<void> _save() async {
    final School school = School(
      id: widget.school?.id ?? 'sch_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      nameAr: _nameAr.text.trim(),
      address: _address.text.trim(),
      contactPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      location: widget.school?.location ?? const GeoPosition(lat: 29.9603, lng: 31.2568),
    );
    await ref.read(schoolRepositoryProvider).upsertSchool(school);
    if (mounted) Navigator.of(context).pop();
  }
}
