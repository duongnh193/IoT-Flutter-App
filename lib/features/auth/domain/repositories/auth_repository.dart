import '../entities/user_entity.dart';

/// Repository interface for Authentication operations
abstract class AuthRepository {
  /// Get current authenticated user
  Future<UserEntity?> getCurrentUser();

  /// Sign in with phone number
  /// Returns verification ID for OTP verification
  Future<String> signInWithPhoneNumber(String phoneNumber);

  /// Verify OTP code
  Future<UserEntity> verifyOTP(String verificationId, String otpCode);

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle();

  /// Sign in with email and password
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);

  /// Create user with email and password (sign up)
  Future<UserEntity> createUserWithEmailAndPassword(String email, String password);

  /// Sign out
  Future<void> signOut();

  /// Check if user is authenticated
  Stream<bool> get authStateChanges;
}

