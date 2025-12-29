import '../../devices/data/datasources/device_firebase_datasource.dart';

/// Service to execute scenes
/// Sets scene_control/type in Realtime Database using PUT method
class ScenarioService {
  ScenarioService({
    required this.deviceDataSource,
  });

  final DeviceFirebaseDataSource deviceDataSource;

  /// Execute scene by setting scene_control/type
  /// Uses PUT (set) method for firmware compatibility
  /// scene-home = Về nhà, scene-away = Rời nhà
  Future<void> executeScene(String sceneType) async {
    // Validate sceneType
    if (sceneType != 'scene-home' && sceneType != 'scene-away') {
      throw Exception('Invalid sceneType: $sceneType. Must be "scene-home" or "scene-away"');
    }
    
    // Debug: Print sceneType to verify
    print('Setting scene_control/type = $sceneType');
    
    // Set scene_control/type using PUT (set) method
    await deviceDataSource.setDeviceValue('scene_control/type', sceneType);
    
    // Debug: Confirm value was set
    print('Successfully set scene_control/type = $sceneType');
  }
}

