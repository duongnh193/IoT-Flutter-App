import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/auth_dependencies.dart';
import '../domain/entities/user_entity.dart';
import '../domain/usecases/sign_out_use_case.dart';

/// Provider for authentication state
final authStateProvider = StreamProvider<bool>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().map((user) => user != null);
});

/// Provider for current user
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  return await useCase();
});

/// Legacy AuthSessionNotifier (kept for compatibility)
class AuthSessionNotifier extends StateNotifier<bool> {
  AuthSessionNotifier(this._auth, this._signOutUseCase)
      : super(_auth.currentUser != null) {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      state = user != null;
    });
  }

  final firebase_auth.FirebaseAuth _auth;
  final SignOutUseCase _signOutUseCase;

  void logIn() => state = true;
  void logOut() async {
    await _signOutUseCase();
    state = false;
  }
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, bool>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  return AuthSessionNotifier(auth, signOutUseCase);
});
