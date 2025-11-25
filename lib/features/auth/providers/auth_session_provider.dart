import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';

class AuthSessionNotifier extends StateNotifier<bool> {
  AuthSessionNotifier(this._prefs) : super(false) {
    state = _prefs?.getBool(_key) ?? false;
  }

  static const _key = 'auth_logged_in';
  final SharedPreferences? _prefs;

  void logIn() {
    state = true;
    _prefs?.setBool(_key, true);
  }

  void logOut() {
    state = false;
    _prefs?.setBool(_key, false);
  }
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AuthSessionNotifier(prefs);
});
