import '../../domain/entities/scene_entity.dart';
import '../../domain/repositories/scene_repository.dart';
import '../datasources/scene_local_datasource.dart';
import '../models/scene_model.dart';

/// Implementation of SceneRepository
class SceneRepositoryImpl implements SceneRepository {
  SceneRepositoryImpl(this._localDataSource);

  final SceneLocalDataSource _localDataSource;

  @override
  Future<List<SceneEntity>> getScenes() async {
    final scenes = _localDataSource.getScenes();
    return scenes.map((model) => model.toEntity()).toList();
  }

  @override
  Future<SceneEntity?> getSceneById(String id) async {
    final scene = _localDataSource.getSceneById(id);
    return scene?.toEntity();
  }

  @override
  Future<SceneEntity> toggleScene(String id) async {
    final updatedModel = _localDataSource.toggleScene(id);
    return updatedModel.toEntity();
  }

  @override
  Future<SceneEntity> updateScene(SceneEntity scene) async {
    final model = SceneModel.fromEntity(scene);
    final updatedModel = _localDataSource.updateScene(model);
    return updatedModel.toEntity();
  }
}

