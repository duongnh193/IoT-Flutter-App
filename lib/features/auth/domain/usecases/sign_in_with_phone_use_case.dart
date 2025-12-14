import '../repositories/auth_repository.dart';

/// Use Case: Sign in with phone number
/// Returns verification ID for OTP verification
class SignInWithPhoneUseCase {
  const SignInWithPhoneUseCase(this._repository);

  final AuthRepository _repository;

  Future<String> call(String phoneNumber) async {
    return await _repository.signInWithPhoneNumber(phoneNumber);
  }
}

