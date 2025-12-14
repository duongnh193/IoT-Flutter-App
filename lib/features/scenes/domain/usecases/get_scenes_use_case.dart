import '../entities/scene_entity.dart';
import '../repositories/scene_repository.dart';

/// Use Case: Get all scenes
class GetScenesUseCase {
  const GetScenesUseCase(this._repository);

  final SceneRepository _repository;

  Future<List<SceneEntity>> call() async {
    return await _repository.getScenes();
  }
}

