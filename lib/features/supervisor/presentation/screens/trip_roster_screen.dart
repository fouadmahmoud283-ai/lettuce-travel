import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/errors/failure_x.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/providers/firebase_providers.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/confirm_dialog.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
import 'package:lettuce_travel/features/attendance/domain/entities/attendance_status.dart';
import 'package:lettuce_travel/features/attendance/presentation/widgets/attendance_status_x.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/incidents/presentation/widgets/report_incident_sheet.dart';
import 'package:lettuce_travel/features/supervisor/presentation/controllers/trip_roster_controller.dart';
import 'package:lettuce_travel/features/supervisor/presentation/widgets/roster_row_tile.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';

/// The check-in screen. This is the most important screen in the product.
///
/// Design constraints, from the field (AGENTS.md section 6):
///  * one-handed use, standing on a moving bus — the whole row is the tap
///    target, at least 88dp tall;
///  * the child photo is the primary identifier, the name is secondary;
///  * every tap gives haptic feedback and an immediate colour change;
///  * it must work identically with no signal (the fake repository always
///    "succeeds" locally; wiring the real offline queue is still TODO).
class TripRosterScreen extends ConsumerWidget {
  const TripRosterScreen({required this.tripId, super.key});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RosterData?> rosterAsync = ref.watch(rosterDataProvider(tripId));
    final bool isOnline = ref.watch(isOnlineProvider).asData?.value ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.roster),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded),
            tooltip: context.l10n.sos,
            onPressed: () {
              final String? supervisorId = ref.read(authControllerProvider).user?.id;
              final RosterData? data = rosterAsync.asData?.value;
              if (supervisorId == null || data == null) return;
              unawaited(
                showReportIncidentSheet(
                  context,
                  schoolId: data.trip.schoolId,
                  tripId: data.trip.id,
                  createdBy: supervisorId,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncValueView<RosterData?>(
          value: rosterAsync,
          data: (RosterData? data) {
            if (data == null) {
              return AppEmptyView(message: context.l10n.noData, icon: Icons.list_alt_outlined);
            }
            return _RosterBody(tripId: tripId, data: data, isOnline: isOnline);
          },
        ),
      ),
    );
  }
}

class _RosterBody extends ConsumerWidget {
  const _RosterBody({required this.tripId, required this.data, required this.isOnline});

  final String tripId;
  final RosterData data;
  final bool isOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LastRosterAction? lastAction = ref.watch(lastRosterActionProvider(tripId));
    final bool readOnly = data.trip.hasEnded;
    final Map<String, List<RosterRow>> byStopName = <String, List<RosterRow>>{};
    for (final RosterRow row in data.rows) {
      final String key = row.stop?.name ?? '-';
      byStopName.putIfAbsent(key, () => <RosterRow>[]).add(row);
    }

    return Column(
      children: <Widget>[
        if (!isOnline)
          Container(
            width: double.infinity,
            color: context.colors.errorContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              context.l10n.offlineBanner,
              style: context.text.bodySmall?.copyWith(color: context.colors.onErrorContainer),
            ),
          ),
        Container(
          width: double.infinity,
          color: context.colors.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              StatusChip(
                label: context.l10n.countWaiting(data.waitingCount),
                color: AttendanceStatus.pending.color(),
                icon: AttendanceStatus.pending.icon(),
                dense: true,
              ),
              StatusChip(
                label: context.l10n.countOnBoard(data.onBoardCount),
                color: AttendanceStatus.onBoard.color(),
                icon: AttendanceStatus.onBoard.icon(),
                dense: true,
              ),
              StatusChip(
                label: context.l10n.countDroppedOff(data.droppedOffCount),
                color: AttendanceStatus.droppedOff.color(),
                icon: AttendanceStatus.droppedOff.icon(),
                dense: true,
              ),
            ],
          ),
        ),
        Expanded(
          child: data.rows.isEmpty
              ? AppEmptyView(message: context.l10n.noData, icon: Icons.groups_outlined)
              : ListView(
                  children: <Widget>[
                    for (final MapEntry<String, List<RosterRow>> entry in byStopName.entries) ...<
                        Widget>[
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          context.l10n.stopHeader(
                            entry.value.first.stop?.order ?? 0,
                            entry.key,
                          ),
                          style: context.text.labelLarge
                              ?.copyWith(color: context.colors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                      for (final RosterRow row in entry.value)
                        RosterRowTile(
                          row: row,
                          onPrimaryTap: readOnly || row.isAbsentToday
                              ? null
                              : _primaryActionFor(row) == null
                                  ? null
                                  : () => unawaited(_handlePrimaryTap(context, ref, row)),
                          onMarkNoShow: readOnly || row.isAbsentToday
                              ? null
                              : () => unawaited(_handleNoShow(context, ref, row)),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
        ),
        if (lastAction != null) _UndoBar(tripId: tripId, action: lastAction),
        if (!readOnly)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => unawaited(_handleEndTrip(context, ref)),
                child: Text(context.l10n.endTrip),
              ),
            ),
          ),
      ],
    );
  }

  AttendanceStatus? _primaryActionFor(RosterRow row) => switch (row.record.status) {
        AttendanceStatus.pending => AttendanceStatus.onBoard,
        AttendanceStatus.onBoard => AttendanceStatus.droppedOff,
        AttendanceStatus.droppedOff ||
        AttendanceStatus.absent ||
        AttendanceStatus.noShow =>
          null,
      };

  Future<void> _handlePrimaryTap(BuildContext context, WidgetRef ref, RosterRow row) async {
    final AttendanceStatus? target = _primaryActionFor(row);
    if (target == null) return;
    final TripRosterActions actions = ref.read(tripRosterActionsProvider(tripId));
    final result = target == AttendanceStatus.onBoard
        ? await actions.checkIn(row)
        : await actions.checkOut(row);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (Failure failure) => context.showSnack(failure.message(context), isError: true),
    );
  }

  Future<void> _handleNoShow(BuildContext context, WidgetRef ref, RosterRow row) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: context.l10n.confirmNoShowTitle,
      message: context.l10n.confirmNoShowMessage(row.student.fullName),
      confirmLabel: context.l10n.markNoShow,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref.read(tripRosterActionsProvider(tripId)).markNoShow(row);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (Failure failure) => context.showSnack(failure.message(context), isError: true),
    );
  }

  Future<void> _handleEndTrip(BuildContext context, WidgetRef ref) async {
    if (!data.canEndTrip) {
      await showConfirmDialog(
        context,
        title: context.l10n.confirmEndTripTitle,
        message: context.l10n.confirmEndTripBlocked(data.onBoardCount),
        confirmLabel: context.l10n.close,
      );
      return;
    }
    final bool confirmed = await showConfirmDialog(
      context,
      title: context.l10n.confirmEndTripTitle,
      message: context.l10n.confirmEndTripMessage,
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref.read(tripRosterActionsProvider(tripId)).endTrip();
    if (!context.mounted) return;
    result.when(
      ok: (Trip trip) {
        context.pop();
      },
      err: (Failure failure) => context.showSnack(failure.message(context), isError: true),
    );
  }
}

class _UndoBar extends ConsumerWidget {
  const _UndoBar({required this.tripId, required this.action});

  final String tripId;
  final LastRosterAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Material(
        color: context.colors.inverseSurface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  context.l10n.markedAs(action.studentName, action.newStatus.label(context)),
                  style: TextStyle(color: context.colors.onInverseSurface),
                ),
              ),
              TextButton(
                onPressed: () =>
                    unawaited(ref.read(tripRosterActionsProvider(tripId)).undoLastAction()),
                child: Text(
                  context.l10n.undo,
                  style: TextStyle(color: context.colors.inversePrimary),
                ),
              ),
            ],
          ),
        ),
      );
}
