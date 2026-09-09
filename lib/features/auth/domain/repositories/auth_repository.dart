import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/auth/domain/entities/app_user.dart';

/// Authentication and session.
///
/// Parents and supervisors sign in with phone + SMS OTP; the super admin signs
/// in with email + password. Roles are never chosen by the client: the user
/// document and the matching custom claim are written by an admin or a Cloud
/// Function.
abstract interface class AuthRepository {
  /// Emits the current user, or null when signed out. Emits null while the
  /// session is still being resolved on cold start.
  Stream<AppUser?> watchCurrentUser();

  /// Sends an SMS code. Returns the verification id needed by [verifyOtp].
  Future<Result<String>> sendOtp(String phoneNumber);

  Future<Result<AppUser>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<Result<AppUser>> signInAdminWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  /// Registers this device for push. Called after sign-in and on token refresh.
  Future<Result<void>> registerFcmToken(String token);

  Future<Result<void>> updateLocale(String localeCode);
}
