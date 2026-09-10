import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/errors/failure_x.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/features/incidents/data/repositories/fake_incident_repository.dart';
import 'package:lettuce_travel/features/incidents/domain/entities/incident.dart';
import 'package:lettuce_travel/features/incidents/presentation/widgets/incident_ui_x.dart';

/// The SOS / incident report sheet, reachable from any screen during a trip.
Future<void> showReportIncidentSheet(
  BuildContext context, {
  required String schoolId,
  required String tripId,
  required String createdBy,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => _ReportIncidentSheet(
        schoolId: schoolId,
        tripId: tripId,
        createdBy: createdBy,
      ),
    );

class _ReportIncidentSheet extends ConsumerStatefulWidget {
  const _ReportIncidentSheet({
    required this.schoolId,
    required this.tripId,
    required this.createdBy,
  });

  final String schoolId;
  final String tripId;
  final String createdBy;

  @override
  ConsumerState<_ReportIncidentSheet> createState() => _ReportIncidentSheetState();
}

class _ReportIncidentSheetState extends ConsumerState<_ReportIncidentSheet> {
  IncidentType _type = IncidentType.breakdown;
  IncidentSeverity _severity = IncidentSeverity.medium;
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.warning_amber_rounded, color: context.colors.error),
                const SizedBox(width: AppSpacing.sm),
                Text(context.l10n.reportIncident, style: context.text.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.incidentType, style: context.text.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final IncidentType type in IncidentType.values)
                  ChoiceChip(
                    label: Text(type.label(context)),
                    avatar: Icon(type.icon(), size: 18),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.incidentSeverity, style: context.text.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final IncidentSeverity severity in IncidentSeverity.values)
                  ChoiceChip(
                    label: Text(severity.label(context)),
                    selected: _severity == severity,
                    selectedColor: severity.color().withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _severity = severity),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(hintText: context.l10n.incidentNoteHint),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.submit),
              ),
            ),
          ],
        ),
      );

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final result = await ref.read(incidentRepositoryProvider).reportIncident(
          Incident(
            id: '',
            schoolId: widget.schoolId,
            tripId: widget.tripId,
            type: _type,
            severity: _severity,
            note: _noteController.text.trim(),
            createdBy: widget.createdBy,
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      ok: (_) {
        Navigator.of(context).pop();
        context.showSnack(context.l10n.incidentSubmitted);
      },
      err: (failure) => context.showSnack(failure.message(context), isError: true),
    );
  }
}
