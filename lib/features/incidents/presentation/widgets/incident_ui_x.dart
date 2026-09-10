import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/features/incidents/domain/entities/incident.dart';

extension IncidentTypeUiX on IncidentType {
  String label(BuildContext context) => switch (this) {
        IncidentType.breakdown => context.l10n.incidentBreakdown,
        IncidentType.accident => context.l10n.incidentAccident,
        IncidentType.medical => context.l10n.incidentMedical,
        IncidentType.delay => context.l10n.incidentDelay,
        IncidentType.other => context.l10n.incidentOther,
      };

  IconData icon() => switch (this) {
        IncidentType.breakdown => Icons.build_rounded,
        IncidentType.accident => Icons.car_crash_rounded,
        IncidentType.medical => Icons.medical_services_rounded,
        IncidentType.delay => Icons.schedule_rounded,
        IncidentType.other => Icons.report_rounded,
      };
}

extension IncidentSeverityUiX on IncidentSeverity {
  String label(BuildContext context) => switch (this) {
        IncidentSeverity.low => context.l10n.severityLow,
        IncidentSeverity.medium => context.l10n.severityMedium,
        IncidentSeverity.high => context.l10n.severityHigh,
        IncidentSeverity.critical => context.l10n.severityCritical,
      };

  Color color() => switch (this) {
        IncidentSeverity.low => AppColors.info,
        IncidentSeverity.medium => AppColors.warning,
        IncidentSeverity.high => AppColors.danger,
        IncidentSeverity.critical => AppColors.danger,
      };
}
