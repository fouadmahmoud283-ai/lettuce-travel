import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:lettuce_travel/features/auth/domain/entities/app_user.dart';
import 'package:lettuce_travel/features/auth/domain/entities/user_role.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/phone_sign_in_screen.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/splash_screen.dart';
import 'package:lettuce_travel/features/parent/presentation/screens/parent_home_screen.dart';
import 'package:lettuce_travel/features/supervisor/presentation/screens/supervisor_home_screen.dart';
import 'package:lettuce_travel/features/supervisor/presentation/screens/trip_roster_screen.dart';

/// The app router.
///
/// Redirect logic is the single gate between the three role experiences.
/// A user must never be able to reach another role's subtree, by deep link or
/// otherwise — see invariant 5 in AGENTS.md.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final AuthState auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;

      // Still resolving the session: hold on the splash screen.
      if (auth.isResolving) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      final AppUser? user = auth.user;
      final bool onAuthRoute = location.startsWith('/sign-in') ||
          location == RoutePaths.splash;

      if (user == null) {
        return onAuthRoute && location != RoutePaths.splash
            ? null
            : RoutePaths.phoneSignIn;
      }

      final String home = _homeFor(user.role);

      // Signed in but sitting on an auth route: send to the role home.
      if (onAuthRoute) return home;

      // Signed in but wandering into another role's subtree.
      if (!location.startsWith(_prefixFor(user.role)) &&
          location != RoutePaths.settings) {
        return home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.phoneSignIn,
        builder: (_, __) => const PhoneSignInScreen(),
      ),
      GoRoute(
        path: RoutePaths.otpVerify,
        builder: (BuildContext context, GoRouterState state) => OtpVerifyScreen(
          phoneNumber: state.uri.queryParameters['phone'] ?? '',
        ),
      ),

      // --- Super admin subtree ---
      GoRoute(
        path: RoutePaths.adminHome,
        builder: (_, __) => const AdminHomeScreen(),
        // TODO(scaffold): nest schools / buses / routes / students / reports.
      ),

      // --- Supervisor subtree ---
      GoRoute(
        path: RoutePaths.supervisorHome,
        builder: (_, __) => const SupervisorHomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'trip/:tripId/roster',
            builder: (BuildContext context, GoRouterState state) =>
                TripRosterScreen(
              tripId: state.pathParameters['tripId']!,
            ),
          ),
        ],
      ),

      // --- Parent subtree ---
      GoRoute(
        path: RoutePaths.parentHome,
        builder: (_, __) => const ParentHomeScreen(),
        // TODO(scaffold): nest child detail / live map / history / absence.
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});

String _homeFor(UserRole role) => switch (role) {
      UserRole.superAdmin => RoutePaths.adminHome,
      UserRole.busSupervisor => RoutePaths.supervisorHome,
      UserRole.parent => RoutePaths.parentHome,
    };

String _prefixFor(UserRole role) => switch (role) {
      UserRole.superAdmin => '/admin',
      UserRole.busSupervisor => '/supervisor',
      UserRole.parent => '/parent',
    };
