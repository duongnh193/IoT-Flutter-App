import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/auth_dependencies.dart';
import '../domain/entities/user_entity.dart';
import '../domain/usecases/sign_in_with_email_use_case.dart';
import '../domain/usecases/sign_in_with_google_use_case.dart';
import '../domain/usecases/sign_in_with_phone_use_case.dart';
import '../domain/usecases/sign_up_with_email_use_case.dart';
import '../domain/usecases/verify_otp_use_case.dart';

/// Controller for authentication operations
class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthController(
    this._signInWithPhoneUseCase,
    this._verifyOTPUseCase,
    this._signInWithGoogleUseCase,
    this._signInWithEmailUseCase,
    this._signUpWithEmailUseCase,
  ) : super(const AsyncValue.data(null));

  final SignInWithPhoneUseCase _signInWithPhoneUseCase;
  final VerifyOTPUseCase _verifyOTPUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;

  String? _verificationId;

  /// Sign in with phone number
  Future<String> signInWithPhone(String phoneNumber) async {
    state = const AsyncValue.loading();
    try {
      final verificationId = await _signInWithPhoneUseCase(phoneNumber);
      _verificationId = verificationId;
      
      // If auto-verified, get user immediately
      if (verificationId == 'auto') {
        // User was auto-verified, get current user
        await verifyOTP('');
      } else {
        // OTP sent, wait for user to enter code
        state = const AsyncValue.data(null);
      }
      
      return verificationId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Verify OTP
  Future<void> verifyOTP(String otpCode) async {
    state = const AsyncValue.loading();
    try {
      // Use stored verification ID or empty string for auto-verification
      final verificationId = _verificationId ?? '';
      final user = await _verifyOTPUseCase(verificationId, otpCode);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _signInWithGoogleUseCase();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _signInWithEmailUseCase(email, password);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _signUpWithEmailUseCase(email, password);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(null);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  return AuthController(
    ref.watch(signInWithPhoneUseCaseProvider),
    ref.watch(verifyOTPUseCaseProvider),
    ref.watch(signInWithGoogleUseCaseProvider),
    ref.watch(signInWithEmailUseCaseProvider),
    ref.watch(signUpWithEmailUseCaseProvider),
  );
});

