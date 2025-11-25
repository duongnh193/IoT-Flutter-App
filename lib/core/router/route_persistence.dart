import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class RouteStore {
  String? getString(String key);
  Future<bool> setString(String key, String value);
}

class RoutePersistence {
  RoutePersistence(this._store);

  static const lastRouteKey = 'last_route';

  final RouteStore _store;

  String? get lastRoute => _store.getString(lastRouteKey);

  Future<void> saveRoute(String location) async {
    await _store.setString(lastRouteKey, location);
  }

  void attachRouter(GoRouter router) {
    // Save on every location change.
    router.routeInformationProvider.addListener(() {
      final location = router.routeInformationProvider.value.uri.toString();
      saveRoute(location);
    });
  }
}

class RoutePersistenceObserver extends NavigatorObserver {
  RoutePersistenceObserver(this._persistence);

  final RoutePersistence _persistence;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _capture(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _capture(previousRoute);
    super.didPop(route, previousRoute);
  }

  void _capture(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name;
    if (name != null && name.startsWith('/')) {
      _persistence.saveRoute(name);
    }
  }
}
