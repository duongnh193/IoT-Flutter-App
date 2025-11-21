import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scene.dart';

final sceneControllerProvider =
    StateNotifierProvider<SceneController, List<Scene>>(
  (ref) => SceneController(),
);

final activeSceneCountProvider = Provider<int>((ref) {
  final scenes = ref.watch(sceneControllerProvider);
  return scenes.where((scene) => scene.isActive).length;
});

class SceneController extends StateNotifier<List<Scene>> {
  SceneController() : super(_mockScenes);

  void toggle(String id) {
    state = [
      for (final scene in state)
        if (scene.id == id)
          scene.copyWith(isActive: !scene.isActive)
        else
          scene,
    ];
  }
}

const _mockScenes = [
  Scene(
    id: 'scene-morning',
    name: 'Chào buổi sáng',
    description: 'Mở rèm, bật đèn dịu và loa phòng khách',
    isActive: true,
  ),
  Scene(
    id: 'scene-home',
    name: 'Về nhà',
    description: 'Bật điều hòa, đèn hiên và camera trong nhà',
  ),
  Scene(
    id: 'scene-relax',
    name: 'Chill tối',
    description: 'Giảm đèn ấm, bật playlist yêu thích',
  ),
  Scene(
    id: 'scene-away',
    name: 'Đi vắng',
    description: 'Tắt toàn bộ thiết bị không cần thiết',
  ),
];
