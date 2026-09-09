import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/features/auth/domain/entities/app_user.dart';

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
///
/// TODO(scaffold): inject AuthRepository, subscribe to watchCurrentUser(), and
/// implement sendOtp / verifyOtp / signOut. Until then the app boots signed out.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // TODO(scaffold): replace with a subscription to
    // ref.watch(authRepositoryProvider).watchCurrentUser().
    return const AuthState(isResolving: false);
  }

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
}

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
