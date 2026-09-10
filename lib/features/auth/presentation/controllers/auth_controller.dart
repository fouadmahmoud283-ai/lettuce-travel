import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:lettuce_travel/features/auth/domain/entities/app_user.dart';
import 'package:lettuce_travel/features/auth/domain/repositories/auth_repository.dart';

/// Session state consumed by the router guard.
///
/// [isResolving] is deliberately distinct from "signed out": on cold start the
/// app does not yet know who the user is, and redirecting to the sign-in screen
/// during that window would flash the wrong screen at a returning user.
class AuthState {
  const AuthState({
    this.user,
    this.isResolving = true,
    this.pendingVerificationId,
    this.pendingPhoneNumber,
  });

  final AppUser? user;
  final bool isResolving;

  /// Set between sending an OTP and verifying it.
  final String? pendingVerificationId;
  final String? pendingPhoneNumber;

  bool get isSignedIn => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isResolving,
    String? pendingVerificationId,
    String? pendingPhoneNumber,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isResolving: isResolving ?? this.isResolving,
        pendingVerificationId:
            pendingVerificationId ?? this.pendingVerificationId,
        pendingPhoneNumber: pendingPhoneNumber ?? this.pendingPhoneNumber,
      );
}

/// Owns the session.
class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthState(isResolving: false);

  void setUser(AppUser? user) => state = user == null
      ? state.copyWith(clearUser: true, isResolving: false)
      : state.copyWith(user: user, isResolving: false);

  void setPendingVerification({
    required String verificationId,
    required String phoneNumber,
  }) =>
      state = state.copyWith(
        pendingVerificationId: verificationId,
        pendingPhoneNumber: phoneNumber,
      );

  Future<Result<String>> sendOtp(String phoneNumber) async {
    final Result<String> result = await _repository.sendOtp(phoneNumber);
    result.when(
      ok: (String verificationId) => setPendingVerification(
        verificationId: verificationId,
        phoneNumber: phoneNumber,
      ),
      err: (_) {},
    );
    return result;
  }

  Future<Result<AppUser>> verifyOtp(String smsCode) async {
    final String verificationId = state.pendingVerificationId ?? '';
    final Result<AppUser> result = await _repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    result.when(ok: setUser, err: (_) {});
    return result;
  }

  Future<Result<AppUser>> signInAdmin({
    required String email,
    required String password,
  }) async {
    final Result<AppUser> result = await _repository.signInAdminWithEmail(
      email: email,
      password: password,
    );
    result.when(ok: setUser, err: (_) {});
    return result;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    setUser(null);
  }
}

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
