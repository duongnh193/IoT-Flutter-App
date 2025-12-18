import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore datasource for RFID cards
/// Collection: rfid_card/{cardId}
/// Document fields: active (bool), owner_name (string)
class RfidCardFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'rfid_card';

  /// Get all RFID cards once (for immediate fetch)
  Future<List<RfidCardDocument>> getRfidCards() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) {
      return RfidCardDocument(
        id: doc.id,
        data: doc.data(),
      );
    }).toList();
  }

  /// Watch all RFID cards
  Stream<List<RfidCardDocument>> watchRfidCards() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RfidCardDocument(
          id: doc.id,
          data: doc.data(),
        );
      }).toList();
    });
  }

  /// Watch for new cards that need name assignment (owner_name == "Chưa đặt tên")
  Stream<List<RfidCardDocument>> watchUnnamedCards() {
    return _firestore
        .collection(_collection)
        .where('owner_name', isEqualTo: 'Chưa đặt tên')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RfidCardDocument(
          id: doc.id,
          data: doc.data(),
        );
      }).toList();
    });
  }

  /// Update owner_name for a card
  Future<void> updateOwnerName(String cardId, String ownerName) async {
    await _firestore
        .collection(_collection)
        .doc(cardId)
        .update({'owner_name': ownerName});
  }

  /// Get a specific card by ID
  Future<RfidCardDocument?> getCardById(String cardId) async {
    final doc = await _firestore.collection(_collection).doc(cardId).get();
    if (!doc.exists) return null;
    return RfidCardDocument(
      id: doc.id,
      data: doc.data()!,
    );
  }

  /// Delete a card
  Future<void> deleteCard(String cardId) async {
    await _firestore.collection(_collection).doc(cardId).delete();
  }

  /// Delete all cards
  Future<void> deleteAllCards() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection(_collection).get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

/// Wrapper class for RFID card document
class RfidCardDocument {
  RfidCardDocument({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, dynamic> data;

  bool get isActive => data['active'] ?? false;
  String get ownerName => data['owner_name'] ?? 'Chưa đặt tên';
}

