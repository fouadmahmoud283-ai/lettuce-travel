import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_announcements_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_buses_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_incidents_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_live_trips_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_routes_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_schools_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_staff_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_students_screen.dart';
import 'package:lettuce_travel/features/auth/domain/entities/app_user.dart';
import 'package:lettuce_travel/features/auth/domain/entities/user_role.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/admin_sign_in_screen.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/phone_sign_in_screen.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/settings_screen.dart';
import 'package:lettuce_travel/features/auth/presentation/screens/splash_screen.dart';
import 'package:lettuce_travel/features/parent/presentation/screens/parent_absence_screen.dart';
import 'package:lettuce_travel/features/parent/presentation/screens/parent_child_screen.dart';
import 'package:lettuce_travel/features/parent/presentation/screens/parent_history_screen.dart';
import 'package:lettuce_travel/features/parent/presentation/screens/parent_home_screen.dart';
import 'package:lettuce_travel/features/parent/presentation/screens/parent_live_map_screen.dart';
import 'package:lettuce_travel/features/parent/presentation/screens/parent_messages_screen.dart';
import 'package:lettuce_travel/features/supervisor/presentation/screens/supervisor_home_screen.dart';
import 'package:lettuce_travel/features/supervisor/presentation/screens/trip_roster_screen.dart';

/// Bridges [authControllerProvider] into a [Listenable] for go_router's
/// `refreshListenable`, notifying only when something that actually changes
/// *where a user is allowed to be* changes (signed-in-ness or role) —
/// deliberately not on every [AuthState] mutation (e.g. `pendingVerificationId`
/// while the OTP flow is mid-flight).
///
/// This is the difference between "re-evaluate redirect on the existing
/// router" (correct) and "throw away the router and its navigation stack"
/// (the bug this replaced: a `Provider<GoRouter>` that did `ref.watch`
/// rebuilt a brand new `GoRouter` on every auth change, which resets to
/// `initialLocation` — so `context.push` to the OTP screen right after
/// `sendOtp` was silently undone by the reset landing back on sign-in).
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authControllerProvider,
      (AuthState? previous, AuthState next) {
        final bool relevantChange = previous == null ||
            previous.isResolving != next.isResolving ||
            (previous.user == null) != (next.user == null) ||
            previous.user?.role != next.user?.role;
        if (relevantChange) notifyListeners();
      },
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// The app router.
///
/// A single [GoRouter] instance lives for the app's lifetime — recreating it
/// resets navigation to `initialLocation`, discarding whatever screen the
/// user was on. Auth changes reach it through [_AuthRouterRefresh] instead.
///
/// Redirect logic is the single gate between the three role experiences.
/// A user must never be able to reach another role's subtree, by deep link or
/// otherwise — see invariant 5 in AGENTS.md.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final _AuthRouterRefresh refresh = _AuthRouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
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
      GoRoute(
        path: RoutePaths.adminSignIn,
        builder: (_, __) => const AdminSignInScreen(),
      ),

      // --- Shared, reachable from any signed-in role ---
      GoRoute(
        path: RoutePaths.settings,
        builder: (_, __) => const SettingsScreen(),
      ),

      // --- Super admin subtree ---
      GoRoute(
        path: RoutePaths.adminHome,
        builder: (_, __) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminSchools,
        builder: (_, __) => const AdminSchoolsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminBuses,
        builder: (_, __) => const AdminBusesScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminRoutes,
        builder: (_, __) => const AdminRoutesScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminStudents,
        builder: (_, __) => const AdminStudentsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminUsers,
        builder: (_, __) => const AdminStaffScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminLiveTrips,
        builder: (_, __) => const AdminLiveTripsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminReports,
        builder: (_, __) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminIncidents,
        builder: (_, __) => const AdminIncidentsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAnnouncements,
        builder: (_, __) => const AdminAnnouncementsScreen(),
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
        routes: <RouteBase>[
          GoRoute(
            path: 'child/:studentId',
            builder: (BuildContext context, GoRouterState state) =>
                ParentChildScreen(studentId: state.pathParameters['studentId']!),
            routes: <RouteBase>[
              GoRoute(
                path: 'live',
                builder: (BuildContext context, GoRouterState state) =>
                    ParentLiveMapScreen(studentId: state.pathParameters['studentId']!),
              ),
              GoRoute(
                path: 'history',
                builder: (BuildContext context, GoRouterState state) =>
                    ParentHistoryScreen(studentId: state.pathParameters['studentId']!),
              ),
              GoRoute(
                path: 'absence',
                builder: (BuildContext context, GoRouterState state) =>
                    ParentAbsenceScreen(studentId: state.pathParameters['studentId']!),
              ),
            ],
          ),
          GoRoute(
            path: 'messages',
            builder: (_, __) => const ParentMessagesScreen(),
          ),
        ],
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
