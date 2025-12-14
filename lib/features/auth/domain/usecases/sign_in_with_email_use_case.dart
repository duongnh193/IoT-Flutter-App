import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmailUseCase {
  SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call(String email, String password) async {
    return await _repository.signInWithEmailAndPassword(email, password);
  }
}

