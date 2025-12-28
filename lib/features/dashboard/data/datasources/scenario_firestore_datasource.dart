import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore datasource for scenario collection
/// Collection: scenario/{scenarioId}
/// Document structure: { actions: [{ device_path, field, value }] }
class ScenarioFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'scenario';

  /// Get scenario by ID (e.g., "ROI_NHA", "VE_NHA")
  Future<ScenarioDocument?> getScenario(String scenarioId) async {
    final doc = await _firestore.collection(_collection).doc(scenarioId).get();
    if (!doc.exists) return null;
    
    return ScenarioDocument(
      id: doc.id,
      data: doc.data()!,
    );
  }

  /// Watch scenario by ID
  Stream<ScenarioDocument?> watchScenario(String scenarioId) {
    return _firestore
        .collection(_collection)
        .doc(scenarioId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return ScenarioDocument(
        id: snapshot.id,
        data: snapshot.data()!,
      );
    });
  }
}

/// Wrapper class for scenario document
class ScenarioDocument {
  ScenarioDocument({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, dynamic> data;

  /// Get actions list from document
  /// Actions structure: [{ device_path: string, field: string, value: dynamic }]
  List<ScenarioAction> get actions {
    final actionsData = data['actions'];
    if (actionsData == null) return [];
    
    if (actionsData is List) {
      return actionsData.map((action) {
        if (action is Map) {
          return ScenarioAction(
            devicePath: action['device_path']?.toString() ?? '',
            field: action['field']?.toString() ?? '',
            value: action['value'],
          );
        }
        return null;
      }).whereType<ScenarioAction>().toList();
    }
    
    return [];
  }
}

/// Scenario action model
class ScenarioAction {
  ScenarioAction({
    required this.devicePath,
    required this.field,
    required this.value,
  });

  final String devicePath;
  final String field;
  final dynamic value;
}

