import '../entities/scene_entity.dart';
import '../repositories/scene_repository.dart';

/// Use Case: Toggle scene state
class ToggleSceneUseCase {
  const ToggleSceneUseCase(this._repository);

  final SceneRepository _repository;

  Future<SceneEntity> call(String id) async {
    final scene = await _repository.getSceneById(id);
    if (scene == null) {
      throw Exception('Scene not found: $id');
    }
    return await _repository.toggleScene(id);
  }
}

