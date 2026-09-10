import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/incidents/domain/entities/incident.dart';

/// SOS and incident reports raised by a supervisor during a trip.
///
/// Creating one must never block the supervisor: the write is fire-and-forget
/// from the UI's perspective, the same way a check-in never waits on
/// notification dispatch (invariant 6 in AGENTS.md).
abstract interface class IncidentRepository {
  Stream<List<Incident>> watchSchoolIncidents(String schoolId);

  Stream<List<Incident>> watchTripIncidents(String tripId);

  Future<Result<Incident>> reportIncident(Incident incident);

  Future<Result<void>> acknowledgeIncident({
    required String incidentId,
    required String acknowledgedBy,
  });

  Future<Result<void>> resolveIncident(String incidentId);
}
