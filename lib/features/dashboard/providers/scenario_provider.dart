import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/scenario_service.dart';
import '../../devices/data/datasources/device_firebase_datasource.dart';

/// Provider for DeviceFirebaseDataSource
final deviceFirebaseDataSourceProvider =
    Provider<DeviceFirebaseDataSource>((ref) {
  return DeviceFirebaseDataSource();
});

/// Provider for ScenarioService
final scenarioServiceProvider = Provider<ScenarioService>((ref) {
  return ScenarioService(
    deviceDataSource: ref.watch(deviceFirebaseDataSourceProvider),
  );
});

/// Provider to execute scene
/// sceneType: 'scene-home' for Về nhà, 'scene-away' for Rời nhà
final executeSceneProvider = FutureProvider.family<void, String>((ref, sceneType) async {
  final service = ref.watch(scenarioServiceProvider);
  await service.executeScene(sceneType);
});

