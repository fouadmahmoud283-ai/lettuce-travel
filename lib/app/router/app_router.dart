import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/shell/role_shell_scaffold.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_announcements_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_buses_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_dashboard_tab_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_incidents_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_live_trips_screen.dart';
import 'package:lettuce_travel/features/admin/presentation/screens/admin_more_screen.dart';
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

/// The app router.
///
/// Redirect logic is the single gate between the three role experiences.
/// A user must never be able to reach another role's subtree, by deep link or
/// otherwise — see invariant 5 in AGENTS.md.
///
/// Each role's routes are a [StatefulShellRoute.indexedStack]: a persistent
/// floating bottom nav (see `app/shell/role_shell_scaffold.dart`) with two to
/// four tabs, each an independent navigation stack. Full-screen drill-down
/// routes (a specific student, a specific trip's roster, admin CRUD screens)
/// are declared as siblings of the shell, outside its branches, so pushing
/// one covers the bottom nav entirely — the conventional go_router pattern
/// for "detail screens that hide the tab bar".
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
      GoRoute(
        path: RoutePaths.adminSignIn,
        builder: (_, __) => const AdminSignInScreen(),
      ),

      // --- Shared, reachable from any signed-in role ---
      GoRoute(
        path: RoutePaths.settings,
        builder: (_, __) => const SettingsScreen(),
      ),

      // ======================================================================
      // Super admin: 4-tab shell (Dashboard / Live / Reports / More) plus
      // full-screen CRUD sections pushed on top of it.
      // ======================================================================
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) =>
            RoleShellScaffold(
          navigationShell: shell,
          destinations: <ShellDestination>[
            ShellDestination(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: context.l10n.navDashboard,
            ),
            ShellDestination(
              icon: Icons.map_outlined,
              selectedIcon: Icons.map,
              label: context.l10n.navLive,
            ),
            ShellDestination(
              icon: Icons.bar_chart_outlined,
              selectedIcon: Icons.bar_chart_rounded,
              label: context.l10n.reports,
            ),
            ShellDestination(
              icon: Icons.apps_outlined,
              selectedIcon: Icons.apps,
              label: context.l10n.moreTabLabel,
            ),
          ],
        ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.adminHome, builder: (_, __) => const AdminDashboardTabScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.adminLiveTrips, builder: (_, __) => const AdminLiveTripsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.adminReports, builder: (_, __) => const AdminReportsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.adminMore, builder: (_, __) => const AdminMoreScreen()),
            ],
          ),
        ],
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
        path: RoutePaths.adminIncidents,
        builder: (_, __) => const AdminIncidentsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAnnouncements,
        builder: (_, __) => const AdminAnnouncementsScreen(),
      ),

      // ======================================================================
      // Bus supervisor: 2-tab shell (Trips / Profile) plus the full-screen
      // roster, which deliberately hides the bottom nav while a trip is live.
      // ======================================================================
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) =>
            RoleShellScaffold(
          navigationShell: shell,
          destinations: <ShellDestination>[
            ShellDestination(
              icon: Icons.directions_bus_outlined,
              selectedIcon: Icons.directions_bus_filled_rounded,
              label: context.l10n.navTrips,
            ),
            ShellDestination(
              icon: Icons.account_circle_outlined,
              selectedIcon: Icons.account_circle,
              label: context.l10n.settings,
            ),
          ],
        ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.supervisorHome, builder: (_, __) => const SupervisorHomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.supervisorProfile, builder: (_, __) => const SettingsScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.supervisorRoster,
        builder: (BuildContext context, GoRouterState state) => TripRosterScreen(
          tripId: state.pathParameters['tripId']!,
        ),
      ),

      // ======================================================================
      // Parent: 3-tab shell (Home / Messages / Profile) plus full-screen child
      // detail, live map, history and absence routes.
      // ======================================================================
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) =>
            RoleShellScaffold(
          navigationShell: shell,
          destinations: <ShellDestination>[
            ShellDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: context.l10n.myChildren,
            ),
            ShellDestination(
              icon: Icons.chat_bubble_outline_rounded,
              selectedIcon: Icons.chat_bubble,
              label: context.l10n.messagesTitle,
            ),
            ShellDestination(
              icon: Icons.account_circle_outlined,
              selectedIcon: Icons.account_circle,
              label: context.l10n.settings,
            ),
          ],
        ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.parentHome, builder: (_, __) => const ParentHomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.parentMessages, builder: (_, __) => const ParentMessagesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: RoutePaths.parentProfile, builder: (_, __) => const SettingsScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.parentChild,
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
