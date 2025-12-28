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
  Future<void> executeScenario(String scenarioId) async {
    // Get scenario from Firestore
    final scenario = await scenarioDataSource.getScenario(scenarioId);
    if (scenario == null) {
      throw Exception('Scenario not found: $scenarioId');
    }

    // Build update map from actions
    final updates = <String, dynamic>{};
    for (final action in scenario.actions) {
      // Construct Firebase path: device_path/field
      final path = '${action.devicePath}/${action.field}';
      updates[path] = action.value;
    }

    // Apply all updates to Realtime Database at once
    if (updates.isNotEmpty) {
      await deviceDataSource.updateDevice('', updates);
    }
  }
}

