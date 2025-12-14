import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use Case: Verify OTP code
class VerifyOTPUseCase {
  const VerifyOTPUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call(String verificationId, String otpCode) async {
    return await _repository.verifyOTP(verificationId, otpCode);
  }
}

