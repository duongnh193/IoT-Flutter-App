import '../models/scene_model.dart';

/// Local data source for scenes
abstract class SceneLocalDataSource {
  List<SceneModel> getScenes();
  SceneModel? getSceneById(String id);
  SceneModel updateScene(SceneModel scene);
  SceneModel toggleScene(String id);
}

/// Mock implementation
class SceneLocalDataSourceImpl implements SceneLocalDataSource {
  static final List<SceneModel> _scenes = _createMockScenes();

  @override
  List<SceneModel> getScenes() {
    return List.unmodifiable(_scenes);
  }

  @override
  SceneModel? getSceneById(String id) {
    try {
      return _scenes.firstWhere((scene) => scene.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  SceneModel updateScene(SceneModel scene) {
    final index = _scenes.indexWhere((s) => s.id == scene.id);
    if (index != -1) {
      _scenes[index] = scene;
      return scene;
    }
    return scene;
  }

  @override
  SceneModel toggleScene(String id) {
    final scene = getSceneById(id);
    if (scene == null) {
      throw Exception('Scene not found: $id');
    }
    final updatedScene = scene.copyWith(isActive: !scene.isActive);
    return updateScene(updatedScene);
  }

  static List<SceneModel> _createMockScenes() {
    return [
      SceneModel(
        id: 'scene-morning',
        name: 'Chào buổi sáng',
        description: 'Mở rèm, bật đèn dịu và loa phòng khách',
        isActive: true,
      ),
      SceneModel(
        id: 'scene-home',
        name: 'Về nhà',
        description: 'Bật điều hòa, đèn hiên và camera trong nhà',
        isActive: false,
      ),
      SceneModel(
        id: 'scene-relax',
        name: 'Chill tối',
        description: 'Giảm đèn ấm, bật playlist yêu thích',
        isActive: false,
      ),
      SceneModel(
        id: 'scene-away',
        name: 'Đi vắng',
        description: 'Tắt toàn bộ thiết bị không cần thiết',
        isActive: false,
      ),
    ];
  }
}

