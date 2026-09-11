import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/stat_tile.dart';
import 'package:lettuce_travel/features/attendance/data/repositories/fake_attendance_repository.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';

final StateProvider<DateTime> _fromDateProvider =
    StateProvider<DateTime>((Ref ref) => DateTime.now().subtract(const Duration(days: 7)));
final StateProvider<DateTime> _toDateProvider = StateProvider<DateTime>((Ref ref) => DateTime.now());

final StreamProvider<List<AttendanceRecord>> _reportRecordsProvider =
    StreamProvider<List<AttendanceRecord>>((Ref ref) {
  final String from = ref.watch(_fromDateProvider).toServiceDate();
  final String to = ref.watch(_toDateProvider).toServiceDate();
  return ref.watch(attendanceRepositoryProvider).watchSchoolAttendance(
        schoolId: MockIds.schoolId,
        fromServiceDate: from,
        toServiceDate: to,
      );
});

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime from = ref.watch(_fromDateProvider);
    final DateTime to = ref.watch(_toDateProvider);
    final AsyncValue<List<AttendanceRecord>> records = ref.watch(_reportRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reports)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: context.colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(context.l10n.reportsDateRange, style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(context, ref, isFrom: true),
                            child: Text(from.toServiceDate()),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Icon(Icons.arrow_forward_rounded, size: 16),
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(context, ref, isFrom: false),
                            child: Text(to.toServiceDate()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AsyncValueView<List<AttendanceRecord>>(
              value: records,
              data: (List<AttendanceRecord> items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl),
                      child: Text(context.l10n.reportsNoData),
                    ),
                  );
                }
                int count(AttendanceStatus s) => items.where((AttendanceRecord r) => r.status == s).length;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.3,
                  children: <Widget>[
                    StatTile(
                      value: '${count(AttendanceStatus.droppedOff)}',
                      label: context.l10n.statusDroppedOff,
                      icon: Icons.check_circle_outline,
                    ),
                    StatTile(
                      value: '${count(AttendanceStatus.onBoard)}',
                      label: context.l10n.statusOnBoard,
                      icon: Icons.directions_bus_outlined,
                    ),
                    StatTile(
                      value: '${count(AttendanceStatus.absent)}',
                      label: context.l10n.statusAbsent,
                      icon: Icons.event_busy_outlined,
                    ),
                    StatTile(
                      value: '${count(AttendanceStatus.noShow)}',
                      label: context.l10n.statusNoShow,
                      icon: Icons.person_off_outlined,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref, {required bool isFrom}) async {
    final DateTime initial =
        isFrom ? ref.read(_fromDateProvider) : ref.read(_toDateProvider);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (isFrom) {
      ref.read(_fromDateProvider.notifier).state = picked;
    } else {
      ref.read(_toDateProvider.notifier).state = picked;
    }
  }
}
