import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthSessionNotifier extends StateNotifier<bool> {
  AuthSessionNotifier() : super(false);

  void logIn() => state = true;
  void logOut() => state = false;
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, bool>((ref) {
  return AuthSessionNotifier();
});
