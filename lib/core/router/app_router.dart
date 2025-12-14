import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/login_success_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/analysis/presentation/analysis_screen.dart';
import '../../features/analysis/presentation/analysis_detail_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/devices/presentation/device_detail_screen.dart';
import '../../features/devices/presentation/gate_room_screen.dart';
import '../../features/devices/presentation/room_devices_screen.dart';
import '../../features/devices/presentation/room_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/layout/app_shell.dart';

enum AppRoute {
  onboarding,
  login,
  phoneSuccess,
  dashboard,
  devices,
  roomDetail,
  deviceDetail,
  analysis,
  analysisDetail,
  settings
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
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
        path: '/login-success',
        name: AppRoute.phoneSuccess.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginSuccessScreen()),
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
                    const NoTransitionPage(child: RoomListScreen()),
                routes: [
                  GoRoute(
                    path: ':roomId',
                    name: AppRoute.roomDetail.name,
                    pageBuilder: (context, state) {
                      final roomId = state.pathParameters['roomId'] ?? '';
                      // Use GateRoomScreen for gate room, RoomDevicesScreen for others
                      if (roomId == 'gate') {
                        return const NoTransitionPage(child: GateRoomScreen());
                      }
                      return NoTransitionPage(
                        child: RoomDevicesScreen(roomId: roomId),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'device/:deviceId',
                        name: AppRoute.deviceDetail.name,
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: DeviceDetailScreen(
                            roomId: state.pathParameters['roomId'] ?? '',
                            deviceId: state.pathParameters['deviceId'] ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
  );
});
