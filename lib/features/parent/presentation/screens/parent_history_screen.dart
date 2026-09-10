import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';
import 'package:lettuce_travel/features/attendance/presentation/widgets/attendance_status_x.dart';
import 'package:lettuce_travel/features/parent/presentation/controllers/parent_history_controller.dart';

class ParentHistoryScreen extends ConsumerWidget {
  const ParentHistoryScreen({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AttendanceRecord>> history = ref.watch(parentHistoryProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.rideHistory)),
      body: SafeArea(
        child: AsyncValueView<List<AttendanceRecord>>(
          value: history,
          data: (List<AttendanceRecord> records) => records.isEmpty
              ? AppEmptyView(message: context.l10n.historyEmpty, icon: Icons.history_rounded)
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final AttendanceRecord record = records[index];
                    return Material(
                      color: context.colors.surface,
                      elevation: 1,
                      shadowColor: context.colors.shadow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 4,
                              height: 52,
                              decoration: BoxDecoration(
                                color: record.status.color(),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(record.serviceDate, style: context.text.titleSmall),
                                  if (record.boardedAtDevice != null)
                                    Text(
                                      '${context.l10n.checkIn}: '
                                      '${record.boardedAtDevice!.toClockTime(context.l10n.localeName)}',
                                      style: context.text.bodySmall,
                                    ),
                                  if (record.droppedAtDevice != null)
                                    Text(
                                      '${context.l10n.checkOut}: '
                                      '${record.droppedAtDevice!.toClockTime(context.l10n.localeName)}',
                                      style: context.text.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            StatusChip(
                              label: record.status.label(context),
                              color: record.status.color(),
                              icon: record.status.icon(),
                            ),
                          ],
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
