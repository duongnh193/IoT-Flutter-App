import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/datasources/auth_firebase_datasource.dart';
import '../data/datasources/auth_google_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_current_user_use_case.dart';
import '../domain/usecases/sign_in_with_email_use_case.dart';
import '../domain/usecases/sign_in_with_google_use_case.dart';
import '../domain/usecases/sign_in_with_phone_use_case.dart';
import '../domain/usecases/sign_out_use_case.dart';
import '../domain/usecases/sign_up_with_email_use_case.dart';
import '../domain/usecases/verify_otp_use_case.dart';

// Firebase Auth
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

// Google Sign-In
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    // Use the OAuth client ID from google-services.json for Android
    // Client ID: 81741509116-gm22sflk4qqs00jbehmca799j09e23rq.apps.googleusercontent.com
    scopes: ['email', 'profile'],
  );
});

// Data Sources
final authFirebaseDataSourceProvider =
    Provider<AuthFirebaseDataSource>((ref) {
  return AuthFirebaseDataSource(ref.watch(firebaseAuthProvider));
});

final authGoogleDataSourceProvider = Provider<AuthGoogleDataSource>((ref) {
  return AuthGoogleDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authFirebaseDataSourceProvider),
    ref.watch(authGoogleDataSourceProvider),
  );
});

// Use Cases
final signInWithPhoneUseCaseProvider =
    Provider<SignInWithPhoneUseCase>((ref) {
  return SignInWithPhoneUseCase(ref.watch(authRepositoryProvider));
});

final verifyOTPUseCaseProvider = Provider<VerifyOTPUseCase>((ref) {
  return VerifyOTPUseCase(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signInWithEmailUseCaseProvider =
    Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final signUpWithEmailUseCaseProvider =
    Provider<SignUpWithEmailUseCase>((ref) {
  return SignUpWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

