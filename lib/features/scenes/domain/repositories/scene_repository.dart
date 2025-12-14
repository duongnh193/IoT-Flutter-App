import '../entities/scene_entity.dart';

/// Repository interface for Scene operations
abstract class SceneRepository {
  /// Get all scenes
  Future<List<SceneEntity>> getScenes();

  /// Get scene by ID
  Future<SceneEntity?> getSceneById(String id);

  /// Toggle scene state
  Future<SceneEntity> toggleScene(String id);

  /// Update scene
  Future<SceneEntity> updateScene(SceneEntity scene);
}

