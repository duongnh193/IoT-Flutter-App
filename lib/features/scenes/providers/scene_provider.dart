import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/scene_dependencies.dart';
import '../domain/usecases/get_scenes_use_case.dart';
import '../domain/usecases/toggle_scene_use_case.dart';
import '../models/scene.dart' as presentation;
import '../presentation/mappers/scene_mapper.dart';

/// Refactored SceneController using Clean Architecture
class SceneController extends StateNotifier<AsyncValue<List<presentation.Scene>>> {
  SceneController(this._getScenesUseCase, this._toggleSceneUseCase)
      : super(const AsyncValue.loading()) {
    _loadScenes();
  }

  final GetScenesUseCase _getScenesUseCase;
  final ToggleSceneUseCase _toggleSceneUseCase;

  Future<void> _loadScenes() async {
    state = const AsyncValue.loading();
    try {
      final entities = await _getScenesUseCase();
      final scenes = entities.map((e) => SceneMapper.toPresentation(e)).toList();
      state = AsyncValue.data(scenes);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggle(String id) async {
    final currentScenes = state.value;
    if (currentScenes == null) return;

    // Optimistic update
    final updatedScenes = currentScenes.map((scene) {
      if (scene.id == id) {
        return scene.copyWith(isActive: !scene.isActive);
      }
      return scene;
    }).toList();
    state = AsyncValue.data(updatedScenes);

    try {
      await _toggleSceneUseCase(id);
      await _loadScenes();
    } catch (e) {
      // Revert on error - restore previous state
      state = AsyncValue.data(currentScenes);
    }
  }

  Future<void> refresh() async {
    await _loadScenes();
  }
}

/// Provider that creates SceneController with dependencies injected
final sceneControllerProvider =
    StateNotifierProvider<SceneController, AsyncValue<List<presentation.Scene>>>(
  (ref) {
    return SceneController(
      ref.watch(getScenesUseCaseProvider),
      ref.watch(toggleSceneUseCaseProvider),
    );
  },
);

/// Convenience provider that unwraps AsyncValue
final scenesProvider = Provider<List<presentation.Scene>>((ref) {
  final asyncValue = ref.watch(sceneControllerProvider);
  return asyncValue.when(
    data: (scenes) => scenes,
    loading: () => <presentation.Scene>[],
    error: (_, __) => <presentation.Scene>[],
  );
});

/// Count of active scenes
final activeSceneCountProvider = Provider<int>((ref) {
  final scenes = ref.watch(scenesProvider);
  return scenes.where((scene) => scene.isActive).length;
});
