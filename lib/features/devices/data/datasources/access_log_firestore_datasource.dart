import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore datasource for access log
/// Collection: access_log/{logId}
/// Document fields: action (string), time (int timestamp), user_name (string)
class AccessLogFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'access_log';

  /// Get all access logs once (for immediate fetch)
  Future<List<AccessLogDocument>> getAccessLogs() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('time', descending: true) // Latest first
        .get();
    return snapshot.docs.map((doc) {
      return AccessLogDocument(
        id: doc.id,
        data: doc.data(),
      );
    }).toList();
  }

  /// Watch all access logs
  /// Returns logs sorted by time descending (newest first)
  Stream<List<AccessLogDocument>> watchAccessLogs() {
    return _firestore
        .collection(_collection)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AccessLogDocument(
          id: doc.id,
          data: doc.data(),
        );
      }).toList();
    });
  }
}

/// Wrapper class for access log document
class AccessLogDocument {
  AccessLogDocument({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, dynamic> data;

  String get userName => data['user_name'] ?? 'Không xác định';
  int get time => data['time'] ?? 0;
  String get action => data['action'] ?? '';
}

