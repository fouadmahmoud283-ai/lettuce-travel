import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
import 'package:lettuce_travel/features/attendance/data/repositories/fake_attendance_repository.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_record.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';
import 'package:lettuce_travel/features/attendance/presentation/widgets/attendance_status_x.dart';

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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.navBarClearance,
          ),
          children: <Widget>[
            _DateRangeCard(from: from, to: to, onPickFrom: () => _pickDate(context, ref, isFrom: true), onPickTo: () => _pickDate(context, ref, isFrom: false)),
            const SizedBox(height: AppSpacing.lg),
            AsyncValueView<List<AttendanceRecord>>(
              value: records,
              data: (List<AttendanceRecord> items) {
                if (items.isEmpty) {
                  return AppEmptyView(message: context.l10n.reportsNoData, icon: Icons.bar_chart_rounded);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _StatusBreakdownCard(items: items).animate().fadeIn(duration: 380.ms),
                    const SizedBox(height: AppSpacing.lg),
                    _DailyTrendCard(items: items).animate().fadeIn(delay: 100.ms, duration: 380.ms),
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

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
  });

  final DateTime from;
  final DateTime to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
                    child: OutlinedButton(onPressed: onPickFrom, child: Text(from.toServiceDate())),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Icon(Icons.arrow_forward_rounded, size: 16),
                  ),
                  Expanded(
                    child: OutlinedButton(onPressed: onPickTo, child: Text(to.toServiceDate())),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

/// A donut chart of how attendance records break down by status, with a
/// legend of coloured pills underneath carrying the exact counts.
class _StatusBreakdownCard extends StatelessWidget {
  const _StatusBreakdownCard({required this.items});

  final List<AttendanceRecord> items;

  int _count(AttendanceStatus s) => items.where((AttendanceRecord r) => r.status == s).length;

  @override
  Widget build(BuildContext context) {
    final List<AttendanceStatus> statuses = <AttendanceStatus>[
      AttendanceStatus.droppedOff,
      AttendanceStatus.onBoard,
      AttendanceStatus.absent,
      AttendanceStatus.noShow,
      AttendanceStatus.pending,
    ];
    final Map<AttendanceStatus, int> counts = <AttendanceStatus, int>{
      for (final AttendanceStatus s in statuses) s: _count(s),
    };
    final int total = counts.values.fold(0, (int a, int b) => a + b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: context.colors.shadow.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.l10n.reportsBreakdownTitle, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 42,
                      sections: <PieChartSectionData>[
                        for (final AttendanceStatus s in statuses)
                          if (counts[s]! > 0)
                            PieChartSectionData(
                              value: counts[s]!.toDouble(),
                              color: s.color(),
                              radius: 34,
                              showTitle: false,
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('$total', style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                      Text(context.l10n.reportsTotalRecords, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              for (final AttendanceStatus s in statuses)
                if (counts[s]! > 0)
                  StatusChip(label: '${s.label(context)} · ${counts[s]}', color: s.color(), icon: s.icon(), dense: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// A bar chart of how many children were marked on board each service date
/// in the selected range — the trend a school operator actually wants to see.
class _DailyTrendCard extends StatelessWidget {
  const _DailyTrendCard({required this.items});

  final List<AttendanceRecord> items;

  @override
  Widget build(BuildContext context) {
    final Map<String, int> byDate = <String, int>{};
    for (final AttendanceRecord r in items) {
      if (r.status == AttendanceStatus.onBoard || r.status == AttendanceStatus.droppedOff) {
        byDate.update(r.serviceDate, (int v) => v + 1, ifAbsent: () => 1);
      }
    }
    final List<String> dates = byDate.keys.toList()..sort();
    final double maxY = dates.isEmpty
        ? 5
        : (byDate.values.reduce((int a, int b) => a > b ? a : b) * 1.25).clamp(4, double.infinity);

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: context.colors.shadow.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.l10n.reportsTrendTitle, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          if (dates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(context.l10n.reportsNoData, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
            )
          else
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY.toDouble(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int i = value.toInt();
                          if (i < 0 || i >= dates.length) return const SizedBox.shrink();
                          final String d = dates[i];
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(d.substring(5), style: context.text.labelSmall),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: <BarChartGroupData>[
                    for (int i = 0; i < dates.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: <BarChartRodData>[
                          BarChartRodData(
                            toY: byDate[dates[i]]!.toDouble(),
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
