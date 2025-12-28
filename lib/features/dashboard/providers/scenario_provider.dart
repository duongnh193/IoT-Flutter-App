import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/scenario_firestore_datasource.dart';
import '../services/scenario_service.dart';
import '../../devices/data/datasources/device_firebase_datasource.dart';

/// Provider for ScenarioFirestoreDataSource
final scenarioFirestoreDataSourceProvider =
    Provider<ScenarioFirestoreDataSource>((ref) {
  return ScenarioFirestoreDataSource();
});

/// Provider for DeviceFirebaseDataSource
final deviceFirebaseDataSourceProvider =
    Provider<DeviceFirebaseDataSource>((ref) {
  return DeviceFirebaseDataSource();
});

/// Provider for ScenarioService
final scenarioServiceProvider = Provider<ScenarioService>((ref) {
  return ScenarioService(
    scenarioDataSource: ref.watch(scenarioFirestoreDataSourceProvider),
    deviceDataSource: ref.watch(deviceFirebaseDataSourceProvider),
  );
});

/// Provider to execute scenario
final executeScenarioProvider = FutureProvider.family<void, String>((ref, scenarioId) async {
  final service = ref.watch(scenarioServiceProvider);
  await service.executeScenario(scenarioId);
});

