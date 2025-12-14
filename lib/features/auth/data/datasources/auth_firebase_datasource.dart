import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Firebase Authentication Data Source
class AuthFirebaseDataSource {
  AuthFirebaseDataSource(this._auth);

  final firebase_auth.FirebaseAuth _auth;

  /// Get current user from Firebase
  UserEntity? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    ).toEntity();
  }

  // Phone number sign-in is handled in repository implementation
  // because we need to use Completer to get verification ID from callback

  /// Verify OTP and sign in
  Future<UserEntity> verifyOTP(String verificationId, String otpCode) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in: User is null');
      }

      return UserModel(
        id: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
      ).toEntity();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('OTP verification failed: ${e.message}');
    }
  }

  /// Auth state changes stream
  Stream<bool> get authStateChanges {
    return _auth.authStateChanges().map((user) => user != null);
  }

  /// Sign in with email and password
  Future<UserEntity> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in: User is null');
      }

      return UserModel(
        id: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
      ).toEntity();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    }
  }

  /// Create user with email and password
  Future<UserEntity> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to create user: User is null');
      }

      return UserModel(
        id: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
      ).toEntity();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

