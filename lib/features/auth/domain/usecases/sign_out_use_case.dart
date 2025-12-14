import '../repositories/auth_repository.dart';

/// Use Case: Sign out
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() async {
    await _repository.signOut();
  }
}

