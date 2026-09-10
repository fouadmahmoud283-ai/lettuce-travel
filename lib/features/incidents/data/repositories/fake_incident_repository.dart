import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/incidents/domain/entities/incident.dart';
import 'package:lettuce_travel/features/incidents/domain/repositories/incident_repository.dart';

/// In-memory stand-in for the Firestore `incidents` collection.
class FakeIncidentRepository implements IncidentRepository {
  FakeIncidentRepository() {
    _incidents.seed(<Incident>[
      Incident(
        id: 'inc_seed_01',
        schoolId: MockIds.schoolId,
        tripId: '-',
        type: IncidentType.delay,
        severity: IncidentSeverity.medium,
        note: 'Traffic on the Ring Road, expect a 10 minute delay.',
        createdBy: MockIds.supervisorUidB,
        createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
      ),
    ]);
  }

  final MockCollection<Incident> _incidents = MockCollection<Incident>();
  int _seq = 0;

  @override
  Stream<List<Incident>> watchSchoolIncidents(String schoolId) =>
      _incidents.watch((Incident i) => i.schoolId == schoolId);

  @override
  Stream<List<Incident>> watchTripIncidents(String tripId) =>
      _incidents.watch((Incident i) => i.tripId == tripId);

  @override
  Future<Result<Incident>> reportIncident(Incident incident) async {
    _seq++;
    final Incident stored = Incident(
      id: 'inc_$_seq',
      schoolId: incident.schoolId,
      tripId: incident.tripId,
      type: incident.type,
      severity: incident.severity,
      note: incident.note,
      location: incident.location,
      createdBy: incident.createdBy,
      createdAt: DateTime.now(),
    );
    _incidents.add(stored);
    return Result<Incident>.ok(stored);
  }

  @override
  Future<Result<void>> acknowledgeIncident({
    required String incidentId,
    required String acknowledgedBy,
  }) async {
    final Incident? incident =
        _incidents.items.where((Incident i) => i.id == incidentId).firstOrNull;
    if (incident == null) return const Result<void>.ok(null);
    _incidents.upsert(
      Incident(
        id: incident.id,
        schoolId: incident.schoolId,
        tripId: incident.tripId,
        type: incident.type,
        severity: incident.severity,
        note: incident.note,
        location: incident.location,
        createdBy: incident.createdBy,
        createdAt: incident.createdAt,
        acknowledgedBy: acknowledgedBy,
        resolvedAt: incident.resolvedAt,
      ),
      (Incident i) => i.id == incidentId,
    );
    return const Result<void>.ok(null);
  }

  @override
  Future<Result<void>> resolveIncident(String incidentId) async {
    final Incident? incident =
        _incidents.items.where((Incident i) => i.id == incidentId).firstOrNull;
    if (incident == null) return const Result<void>.ok(null);
    _incidents.upsert(
      Incident(
        id: incident.id,
        schoolId: incident.schoolId,
        tripId: incident.tripId,
        type: incident.type,
        severity: incident.severity,
        note: incident.note,
        location: incident.location,
        createdBy: incident.createdBy,
        createdAt: incident.createdAt,
        acknowledgedBy: incident.acknowledgedBy,
        resolvedAt: DateTime.now(),
      ),
      (Incident i) => i.id == incidentId,
    );
    return const Result<void>.ok(null);
  }
}

final Provider<IncidentRepository> incidentRepositoryProvider =
    Provider<IncidentRepository>((Ref ref) => FakeIncidentRepository());
