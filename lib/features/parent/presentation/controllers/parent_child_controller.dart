import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';
import 'package:lettuce_travel/features/students/data/repositories/fake_student_repository.dart';
import 'package:lettuce_travel/features/students/domain/entities/student.dart';
import 'package:lettuce_travel/features/trips/data/repositories/fake_trip_repository.dart';
import 'package:lettuce_travel/features/trips/domain/entities/trip.dart';

/// One of the signed-in guardian's own children, found within their own
/// roster stream rather than a direct by-id lookup — a parent-facing screen
/// never queries a student outside `watchStudentsForGuardian` (invariant 5).
final StreamProviderFamily<Student?, String> parentStudentProvider =
    StreamProvider.family<Student?, String>((Ref ref, String studentId) {
  final String? guardianId = ref.watch(authControllerProvider).user?.id;
  if (guardianId == null) return Stream<Student?>.value(null);
  return ref
      .watch(studentRepositoryProvider)
      .watchStudentsForGuardian(guardianId)
      .map((List<Student> students) => students.firstWhereOrNull((Student s) => s.id == studentId));
});

/// The child's route (for its name, stops and assigned supervisor).
final StreamProviderFamily<BusRoute?, String> parentStudentRouteProvider =
    StreamProvider.family<BusRoute?, String>((Ref ref, String studentId) {
  final Student? student = ref.watch(parentStudentProvider(studentId)).asData?.value;
  if (student == null) return Stream<BusRoute?>.value(null);
  return ref.watch(busRouteRepositoryProvider).watchRoute(student.routeId);
});

/// Whether the child's bus is running right now, and which trip.
final StreamProviderFamily<Trip?, String> parentStudentActiveTripProvider =
    StreamProvider.family<Trip?, String>((Ref ref, String studentId) {
  final Student? student = ref.watch(parentStudentProvider(studentId)).asData?.value;
  if (student == null) return Stream<Trip?>.value(null);
  return ref.watch(tripRepositoryProvider).watchActiveTripForRoute(student.routeId);
});
