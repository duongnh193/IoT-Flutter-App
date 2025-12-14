import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use Case: Get current authenticated user
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}

