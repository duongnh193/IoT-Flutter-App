import '../data/datasources/scenario_firestore_datasource.dart';
import '../../devices/data/datasources/device_firebase_datasource.dart';

/// Service to execute scenarios
/// Reads scenario from Firestore and applies actions to Realtime Database
class ScenarioService {
  ScenarioService({
    required this.scenarioDataSource,
    required this.deviceDataSource,
  });

  final ScenarioFirestoreDataSource scenarioDataSource;
  final DeviceFirebaseDataSource deviceDataSource;

  /// Execute a scenario by ID
  /// Reads scenario from Firestore and applies all actions to Realtime Database
  /// Uses PUT (set) method for firmware compatibility, consistent with device control
  Future<void> executeScenario(String scenarioId) async {
    // Get scenario from Firestore
    final scenario = await scenarioDataSource.getScenario(scenarioId);
    if (scenario == null) {
      throw Exception('Scenario not found: $scenarioId');
    }

    // Apply each action using PUT (set) method for firmware compatibility
    // This matches the pattern used by device controls (setFanCommand, setLightCommand, etc.)
    for (final action in scenario.actions) {
      // Construct Firebase path: device_path/field
      final path = '${action.devicePath}/${action.field}';
      
      // Use set() (PUT) instead of update() (PATCH) for firmware compatibility
      // This ensures consistent behavior with device control methods
      await deviceDataSource.setDeviceValue(path, action.value);
    }
  }
}

