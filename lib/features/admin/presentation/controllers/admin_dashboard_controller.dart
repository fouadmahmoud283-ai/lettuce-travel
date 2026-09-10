import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/utils/combine_streams.dart';
import 'package:lettuce_travel/features/incidents/data/repositories/fake_incident_repository.dart';
import 'package:lettuce_travel/features/incidents/domain/entities/incident.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_school_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/school.dart';
import 'package:lettuce_travel/features/trips/data/repositories/fake_trip_repository.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.schoolsCount,
    required this.busesOnRoad,
    required this.childrenOnBoard,
    required this.openIncidents,
  });

  final int schoolsCount;
  final int busesOnRoad;
  final int childrenOnBoard;
  final int openIncidents;
}

final StreamProvider<AdminDashboardStats> adminDashboardProvider =
    StreamProvider<AdminDashboardStats>((Ref ref) => combine3(
          ref.watch(schoolRepositoryProvider).watchSchools(),
          ref.watch(tripRepositoryProvider).watchActiveTrips(MockIds.schoolId),
          ref.watch(incidentRepositoryProvider).watchSchoolIncidents(MockIds.schoolId),
          (List<School> schools, List<Trip> trips, List<Incident> incidents) =>
              AdminDashboardStats(
            schoolsCount: schools.length,
            busesOnRoad: trips.length,
            childrenOnBoard:
                trips.fold(0, (int sum, Trip t) => sum + t.remainingOnBoard),
            openIncidents: incidents.where((Incident i) => i.isOpen).length,
          ),
        ),);
