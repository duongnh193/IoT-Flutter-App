import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../datasources/auth_google_datasource.dart';

/// Implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._firebaseDataSource,
    this._googleDataSource,
  );

  final AuthFirebaseDataSource _firebaseDataSource;
  final AuthGoogleDataSource _googleDataSource;

  // Store verification ID for OTP verification
  String? _verificationId;

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _firebaseDataSource.getCurrentUser();
  }

  @override
  Future<String> signInWithPhoneNumber(String phoneNumber) async {
    final completer = Completer<String>();

    // Format phone number to E.164 format
    final formattedPhone = _formatPhoneNumber(phoneNumber);

    try {
      await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (credential) async {
          // Auto-verification completed (SMS code auto-retrieved on some devices)
          try {
            final userCredential =
                await firebase_auth.FirebaseAuth.instance.signInWithCredential(
              credential,
            );
            if (userCredential.user != null && !completer.isCompleted) {
              completer.complete('auto');
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(
                Exception('Auto-verification failed: $e'),
              );
            }
          }
        },
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception('Verification failed: ${error.message}'),
            );
          }
        },
        codeSent: (verificationId, _) {
          _verificationId = verificationId;
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Store verification ID in case auto-retrieval times out
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Failed to send OTP: $e'));
      }
      rethrow;
    }
  }

  @override
  Future<UserEntity> verifyOTP(String verificationId, String otpCode) async {
    // If verificationId is 'auto', user was auto-verified and already signed in
    if (verificationId == 'auto') {
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('User is not authenticated');
      }
      return user;
    }

    // Use stored verification ID if verificationId is empty
    final vid = verificationId.isEmpty ? _verificationId : verificationId;
    if (vid == null || vid.isEmpty) {
      throw Exception('Verification ID is required');
    }

    return await _firebaseDataSource.verifyOTP(vid, otpCode);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await _googleDataSource.signInWithGoogle();
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserEntity> createUserWithEmailAndPassword(String email, String password) async {
    return await _firebaseDataSource.createUserWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() async {
    await _firebaseDataSource.signOut();
  }

  @override
  Stream<bool> get authStateChanges {
    return _firebaseDataSource.authStateChanges;
  }

  /// Format phone number to E.164 format
  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 0, replace with +84
    if (digits.startsWith('0')) {
      return '+84${digits.substring(1)}';
    }

    // If doesn't start with +, add +84
    if (!phoneNumber.startsWith('+')) {
      return '+84$digits';
    }

    return phoneNumber;
  }
}

