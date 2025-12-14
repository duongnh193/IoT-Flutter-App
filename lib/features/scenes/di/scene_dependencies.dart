import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/scene_local_datasource.dart';
import '../data/repositories/scene_repository_impl.dart';
import '../domain/repositories/scene_repository.dart';
import '../domain/usecases/get_scenes_use_case.dart';
import '../domain/usecases/toggle_scene_use_case.dart';

// Data Sources
final sceneLocalDataSourceProvider = Provider<SceneLocalDataSource>((ref) {
  return SceneLocalDataSourceImpl();
});

// Repositories
final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  return SceneRepositoryImpl(ref.watch(sceneLocalDataSourceProvider));
});

// Use Cases
final getScenesUseCaseProvider = Provider<GetScenesUseCase>((ref) {
  return GetScenesUseCase(ref.watch(sceneRepositoryProvider));
});

final toggleSceneUseCaseProvider = Provider<ToggleSceneUseCase>((ref) {
  return ToggleSceneUseCase(ref.watch(sceneRepositoryProvider));
});

