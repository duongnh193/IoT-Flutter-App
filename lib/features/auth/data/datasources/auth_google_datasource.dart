import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Google Sign-In Data Source
class AuthGoogleDataSource {
  AuthGoogleDataSource(
    this._auth,
    this._googleSignIn,
  );

  final firebase_auth.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Sign out first to ensure fresh sign-in
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled by user');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Validate tokens
      if (googleAuth.idToken == null) {
        throw Exception('Google sign-in failed: ID token is null');
      }

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in: User is null');
      }

      return UserModel(
        id: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        displayName: user.displayName ?? googleUser.displayName,
        email: user.email ?? googleUser.email,
        photoUrl: user.photoURL ?? googleUser.photoUrl,
        isEmailVerified: user.emailVerified,
      ).toEntity();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Firebase authentication failed: ${e.message}');
    } catch (e) {
      // Re-throw if already a formatted exception
      if (e.toString().contains('Google sign-in') || 
          e.toString().contains('Firebase authentication')) {
        rethrow;
      }
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }
}

