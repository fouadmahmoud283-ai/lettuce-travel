import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/incidents/data/repositories/fake_incident_repository.dart';
import 'package:lettuce_travel/features/incidents/domain/entities/incident.dart';
import 'package:lettuce_travel/features/incidents/presentation/widgets/incident_ui_x.dart';

class AdminIncidentsScreen extends ConsumerWidget {
  const AdminIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Incident>> incidents = ref.watch(_incidentsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.incidentsLabel)),
      body: SafeArea(
        child: AsyncValueView<List<Incident>>(
          value: incidents,
          data: (List<Incident> items) {
            if (items.isEmpty) return AppEmptyView(message: context.l10n.noData, icon: Icons.report_gmailerrorred_outlined);
            final List<Incident> sorted = List<Incident>.of(items)
              ..sort(
                (Incident a, Incident b) =>
                    (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
              );
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) => _IncidentCard(incident: sorted[index]),
            );
          },
        ),
      ),
    );
  }
}

final StreamProvider<List<Incident>> _incidentsProvider = StreamProvider<List<Incident>>(
  (Ref ref) => ref.watch(incidentRepositoryProvider).watchSchoolIncidents(MockIds.schoolId),
);

class _IncidentCard extends ConsumerWidget {
  const _IncidentCard({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Material(
        color: context.colors.surface,
        elevation: 1,
        shadowColor: context.colors.shadow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: 104,
                decoration: BoxDecoration(
                  color: incident.severity.color(),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(incident.type.icon(), color: incident.severity.color()),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(incident.type.label(context), style: context.text.titleSmall)),
                StatusChip(
                  label: incident.severity.label(context),
                  color: incident.severity.color(),
                  dense: true,
                ),
              ],
            ),
            if (incident.note.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(incident.note, style: context.text.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              incident.createdAt == null
                  ? ''
                  : incident.createdAt!.toClockTime(context.l10n.localeName),
              style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                StatusChip(
                  label: incident.isOpen ? context.l10n.openLabel : context.l10n.incidentResolved,
                  color: incident.isOpen ? context.colors.error : context.colors.primary,
                  dense: true,
                ),
                const Spacer(),
                if (incident.acknowledgedBy == null)
                  TextButton(
                    onPressed: () => _acknowledge(ref),
                    child: Text(context.l10n.acknowledgeIncident),
                  ),
                if (incident.isOpen)
                  TextButton(
                    onPressed: () => ref.read(incidentRepositoryProvider).resolveIncident(incident.id),
                    child: Text(context.l10n.resolveIncident),
                  ),
              ],
            ),
          ],
                  ),
                ),
            ],
          ),
        ),
      );

  void _acknowledge(WidgetRef ref) {
    final String? uid = ref.read(authControllerProvider).user?.id;
    if (uid == null) return;
    ref.read(incidentRepositoryProvider).acknowledgeIncident(incidentId: incident.id, acknowledgedBy: uid);
  }
}
