import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/add_name_screen.dart';
import '../../features/auth/presentation/login_phone_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/login_success_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/security_pin_screen.dart';
import '../../features/analysis/presentation/analysis_screen.dart';
import '../../features/analysis/presentation/analysis_detail_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/devices/presentation/devices_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/layout/app_shell.dart';
import 'route_persistence.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/providers/auth_session_provider.dart';

enum AppRoute {
  onboarding,
  login,
  loginPhone,
  pin,
  phoneSuccess,
  addName,
  dashboard,
  devices,
  analysis,
  analysisDetail,
  settings
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
class SharedPrefsRouteStore implements RouteStore {
  SharedPrefsRouteStore(this.prefs);

  final SharedPreferences prefs;

  @override
  String? getString(String key) => prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) => prefs.setString(key, value);
}

class MemoryRouteStore implements RouteStore {
  final Map<String, String> _cache = {};

  @override
  String? getString(String key) => _cache[key];

  @override
  Future<bool> setString(String key, String value) async {
    _cache[key] = value;
    return true;
  }
}

final sharedPrefsProvider = Provider<SharedPreferences?>((ref) => null);

final initialRouteProvider = Provider<String>((ref) {
  final isLoggedIn = ref.watch(authSessionProvider);
  final last = ref.watch(routePersistenceProvider).lastRoute;
  if (isLoggedIn) {
    return last ?? '/dashboard';
  }
  return '/onboarding';
});
final routePersistenceProvider = Provider<RoutePersistence>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final store = prefs != null ? SharedPrefsRouteStore(prefs) : MemoryRouteStore();
  return RoutePersistence(store);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final persistence = ref.watch(routePersistenceProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ref.watch(initialRouteProvider),
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/login-phone',
        name: AppRoute.loginPhone.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPhoneScreen()),
      ),
      GoRoute(
        path: '/pin',
        name: AppRoute.pin.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SecurityPinScreen()),
      ),
      GoRoute(
        path: '/phone-success',
        name: AppRoute.phoneSuccess.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginSuccessScreen()),
      ),
      GoRoute(
        path: '/add-name',
        name: AppRoute.addName.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AddNameScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: AppRoute.dashboard.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/devices',
                name: AppRoute.devices.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DevicesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analysis',
                name: AppRoute.analysis.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AnalysisScreen()),
                routes: [
                  GoRoute(
                    path: 'detail',
                    name: AppRoute.analysisDetail.name,
                    pageBuilder: (context, state) => CustomTransitionPage(
                      transitionDuration: const Duration(milliseconds: 250),
                      reverseTransitionDuration: const Duration(milliseconds: 250),
                      child: const AnalysisDetailScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        final curved =
                            CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                        return FadeTransition(
                          opacity: curved,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: AppRoute.settings.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
    observers: [
      RoutePersistenceObserver(persistence),
    ],
  );

  // Also listen for location changes via RouteInformationProvider.
  persistence.attachRouter(router);
  return router;
});
