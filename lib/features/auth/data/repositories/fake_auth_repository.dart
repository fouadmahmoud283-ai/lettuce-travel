import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/errors/failure.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/auth/domain/entities/app_user.dart';
import 'package:lettuce_travel/features/auth/domain/entities/user_role.dart';
import 'package:lettuce_travel/features/auth/domain/repositories/auth_repository.dart';

/// In-memory stand-in for Firebase phone-OTP and email/password auth.
///
/// There is no SMS provider or Firebase project configured yet (see AGENTS.md
/// section 9), so this fake resolves a role from the phone number itself, only
/// so the rest of the app has someone to be signed in as:
///  * a phone number containing "999" signs in as the demo bus supervisor;
///  * any other phone number signs in as the demo parent;
///  * the admin email/password path only accepts one demo account.
/// Replace this file with a `FirebaseAuthRepository` once phone auth and
/// custom claims are set up — see docs/firebase-setup.md.
class FakeAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _current;
  String? _pendingPhone;

  static const String _adminEmail = 'admin@lettuce.app';
  static const String _adminPassword = 'admin123';

  static const AppUser _demoSupervisor = AppUser(
    id: MockIds.supervisorUidA,
    role: UserRole.busSupervisor,
    displayName: 'Mona Youssef',
    schoolId: MockIds.schoolId,
    assignedRouteIds: <String>[MockIds.routeIdA],
  );

  static const AppUser _demoParent = AppUser(
    id: MockIds.parentUidA,
    role: UserRole.parent,
    displayName: 'Ahmed Hassan',
    schoolId: MockIds.schoolId,
    studentIds: <String>[
      MockIds.studentId1,
      MockIds.studentId2,
      MockIds.studentId3,
    ],
  );

  static const AppUser _demoAdmin = AppUser(
    id: MockIds.adminUid,
    role: UserRole.superAdmin,
    email: _adminEmail,
    displayName: 'School Admin',
    schoolId: MockIds.schoolId,
  );

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<Result<String>> sendOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _pendingPhone = phoneNumber;
    return const Result<String>.ok('demo-verification-id');
  }

  @override
  Future<Result<AppUser>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (smsCode.trim().length != 6) {
      return const Result<AppUser>.err(
        AuthFailure(messageKey: 'otpInvalid'),
      );
    }
    final String phone = _pendingPhone ?? '';
    final AppUser template = phone.contains('999') ? _demoSupervisor : _demoParent;
    final AppUser user = AppUser(
      id: template.id,
      role: template.role,
      phone: phone,
      displayName: template.displayName,
      schoolId: template.schoolId,
      studentIds: template.studentIds,
      assignedRouteIds: template.assignedRouteIds,
    );
    _setCurrent(user);
    return Result<AppUser>.ok(user);
  }

  @override
  Future<Result<AppUser>> signInAdminWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (email.trim().toLowerCase() != _adminEmail || password.trim() != _adminPassword) {
      return const Result<AppUser>.err(
        AuthFailure(messageKey: 'invalidCredentials'),
      );
    }
    _setCurrent(_demoAdmin);
    return const Result<AppUser>.ok(_demoAdmin);
  }

  @override
  Future<Result<void>> signOut() async {
    _setCurrent(null);
    return const Result<void>.ok(null);
  }

  @override
  Future<Result<void>> registerFcmToken(String token) async =>
      const Result<void>.ok(null);

  @override
  Future<Result<void>> updateLocale(String localeCode) async =>
      const Result<void>.ok(null);

  void _setCurrent(AppUser? user) {
    _current = user;
    _controller.add(user);
  }
}

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) => FakeAuthRepository());
