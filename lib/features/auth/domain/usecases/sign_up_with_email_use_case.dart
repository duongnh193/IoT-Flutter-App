import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for creating a new user with email and password
class SignUpWithEmailUseCase {
  SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call(String email, String password) async {
    return await _repository.createUserWithEmailAndPassword(email, password);
  }
}

