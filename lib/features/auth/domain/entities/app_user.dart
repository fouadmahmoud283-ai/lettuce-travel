import 'package:lettuce_travel/features/auth/domain/entities/user_role.dart';

/// An authenticated user of any role.
///
/// [role] and [schoolId] are mirrored into Firebase Auth custom claims by a
/// Cloud Function so security rules can check them without a document read.
/// The client never writes either field.
class AppUser {
  const AppUser({
    required this.id,
    required this.role,
    this.phone,
    this.email,
    this.displayName = '',
    this.schoolId,
    this.studentIds = const <String>[],
    this.assignedRouteIds = const <String>[],
    this.locale = 'ar',
    this.isActive = true,
  });

  final String id;
  final UserRole role;

  /// Set for parents and supervisors (phone + OTP sign-in).
  final String? phone;

  /// Set for the super admin (email + password sign-in).
  final String? email;

  final String displayName;

  /// Tenant boundary. Null only for a platform-level super admin.
  final String? schoolId;

  /// Parents only: the children this guardian is linked to.
  final List<String> studentIds;

  /// Supervisors only: the routes this supervisor may start trips for.
  final List<String> assignedRouteIds;

  final String locale;
  final bool isActive;

  bool get isParent => role == UserRole.parent;

  bool get isSupervisor => role == UserRole.busSupervisor;

  bool get isAdmin => role == UserRole.superAdmin;

  bool canStartTripOnRoute(String routeId) =>
      isSupervisor && assignedRouteIds.contains(routeId);

  AppUser copyWith({
    String? displayName,
    String? locale,
    List<String>? studentIds,
    List<String>? assignedRouteIds,
    bool? isActive,
  }) =>
      AppUser(
        id: id,
        role: role,
        phone: phone,
        email: email,
        displayName: displayName ?? this.displayName,
        schoolId: schoolId,
        studentIds: studentIds ?? this.studentIds,
        assignedRouteIds: assignedRouteIds ?? this.assignedRouteIds,
        locale: locale ?? this.locale,
        isActive: isActive ?? this.isActive,
      );
}
