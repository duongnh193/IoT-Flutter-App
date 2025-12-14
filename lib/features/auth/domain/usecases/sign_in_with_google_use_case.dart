import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use Case: Sign in with Google
class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call() async {
    return await _repository.signInWithGoogle();
  }
}

