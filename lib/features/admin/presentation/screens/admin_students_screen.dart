import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/child_avatar.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/students/data/repositories/fake_student_repository.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';

class AdminStudentsScreen extends ConsumerWidget {
  const AdminStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Student>> students = ref.watch(_studentsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.students)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _StudentFormSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: AsyncValueView<List<Student>>(
          value: students,
          data: (List<Student> items) => items.isEmpty
              ? Center(child: Text(context.l10n.noData))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Student student = items[index];
                    return Card(
                      child: ListTile(
                        leading: ChildAvatar(initials: student.initials, photoUrl: student.photoUrl),
                        title: Text(student.fullName),
                        subtitle: Text(
                          '${student.gradeOrClass.isEmpty ? context.l10n.notSet : student.gradeOrClass} · '
                          '${context.l10n.guardiansCount(student.guardianIds.length)}',
                        ),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => _StudentFormSheet(student: student),
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

final StreamProvider<List<Student>> _studentsProvider = StreamProvider<List<Student>>(
  (Ref ref) => ref.watch(studentRepositoryProvider).watchSchoolStudents(MockIds.schoolId),
);

final StreamProvider<List<BusRoute>> _routesForStudentsProvider = StreamProvider<List<BusRoute>>(
  (Ref ref) => ref.watch(busRouteRepositoryProvider).watchSchoolRoutes(MockIds.schoolId),
);

class _StudentFormSheet extends ConsumerStatefulWidget {
  const _StudentFormSheet({this.student});

  final Student? student;

  @override
  ConsumerState<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends ConsumerState<_StudentFormSheet> {
  late final TextEditingController _name = TextEditingController(text: widget.student?.fullName);
  late final TextEditingController _grade = TextEditingController(text: widget.student?.gradeOrClass);
  late final TextEditingController _guardians =
      TextEditingController(text: widget.student?.guardianIds.join(', '));
  String? _routeId;
  String? _stopId;

  @override
  void initState() {
    super.initState();
    _routeId = widget.student?.routeId;
    _stopId = widget.student?.stopId;
  }

  @override
  void dispose() {
    _name.dispose();
    _grade.dispose();
    _guardians.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<BusRoute>> routes = ref.watch(_routesForStudentsProvider);
    final BusRoute? selectedRoute =
        routes.asData?.value.firstWhereOrNull((BusRoute r) => r.id == _routeId);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.student == null ? context.l10n.addStudent : context.l10n.editStudent,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _name, decoration: InputDecoration(labelText: context.l10n.studentNameLabel)),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _grade, decoration: InputDecoration(labelText: context.l10n.gradeLabel)),
            const SizedBox(height: AppSpacing.sm),
            routes.when(
              data: (List<BusRoute> items) => DropdownButtonFormField<String>(
                initialValue: _routeId,
                decoration: InputDecoration(labelText: context.l10n.routeLabel),
                items: <DropdownMenuItem<String>>[
                  for (final BusRoute r in items) DropdownMenuItem<String>(value: r.id, child: Text(r.name)),
                ],
                onChanged: (String? v) => setState(() {
                  _routeId = v;
                  _stopId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (selectedRoute != null)
              DropdownButtonFormField<String>(
                initialValue: _stopId,
                decoration: InputDecoration(labelText: context.l10n.childStop),
                items: <DropdownMenuItem<String>>[
                  for (final stop in selectedRoute.stopsInPickupOrder)
                    DropdownMenuItem<String>(value: stop.id, child: Text(stop.name)),
                ],
                onChanged: (String? v) => setState(() => _stopId = v),
              ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _guardians,
              decoration: InputDecoration(
                labelText: context.l10n.guardianPhoneLabel,
                helperText: 'Comma-separated guardian ids (demo only)',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _routeId == null || _stopId == null ? null : _save,
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final Student student = Student(
      id: widget.student?.id ?? 'stu_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: MockIds.schoolId,
      fullName: _name.text.trim(),
      routeId: _routeId!,
      stopId: _stopId!,
      guardianIds: _guardians.text
          .split(',')
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toList(),
      gradeOrClass: _grade.text.trim(),
    );
    await ref.read(studentRepositoryProvider).upsertStudent(student);
    if (mounted) Navigator.of(context).pop();
  }
}
