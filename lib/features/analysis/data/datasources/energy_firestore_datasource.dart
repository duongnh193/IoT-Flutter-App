import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore datasource for energy collection
/// Collection structure: energy/{YYYY_MM}
/// Each document contains: daily_data, devices, month, year, total_cost, total_kwh
class EnergyFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'energy';

  /// Watch all documents in energy collection
  /// Returns stream that automatically updates when new documents are added
  /// Sorted by document ID (YYYY_MM format) in descending order (newest first)
  Stream<List<EnergyDocument>> watchEnergyDocuments() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        return EnergyDocument(
          id: doc.id, // e.g., "2025_12", "2026_01", "2026_02"
          data: doc.data(),
        );
      }).toList();
      
      // Sort by document ID in descending order (newest first)
      // Document ID format: YYYY_MM, so string comparison works correctly
      docs.sort((a, b) => b.id.compareTo(a.id));
      
      return docs;
    });
  }

  /// Get the latest document (current month or most recent)
  Stream<EnergyDocument?> watchLatestEnergy() {
    return watchEnergyDocuments().map((docs) {
      if (docs.isEmpty) return null;
      
      // Get current month in format YYYY_MM
      final now = DateTime.now();
      final currentMonthId = '${now.year}_${now.month.toString().padLeft(2, '0')}';
      
      // Try to find current month first
      try {
        final currentMonth = docs.firstWhere(
          (doc) => doc.id == currentMonthId,
        );
        return currentMonth;
      } catch (e) {
        // Fallback to most recent document
        return docs.first;
      }
    });
  }

  /// Get specific month document
  Future<EnergyDocument?> getEnergyByMonth(String monthId) async {
    final doc = await _firestore.collection(_collection).doc(monthId).get();
    if (!doc.exists) return null;
    
    return EnergyDocument(
      id: doc.id,
      data: doc.data()!,
    );
  }

  /// Get previous month for comparison
  Future<EnergyDocument?> getPreviousMonth(String currentMonthId) async {
    // Parse current month ID (e.g., "2026_02")
    final parts = currentMonthId.split('_');
    if (parts.length != 2) return null;
    
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return null;
    
    // Calculate previous month
    DateTime prevDate = DateTime(year, month);
    prevDate = DateTime(prevDate.year, prevDate.month - 1);
    final prevMonthId = '${prevDate.year}_${prevDate.month.toString().padLeft(2, '0')}';
    
    return getEnergyByMonth(prevMonthId);
  }

  /// Get list of all available month IDs (YYYY_MM format)
  /// Returns stream that updates when new documents are added
  Stream<List<String>> watchAvailableMonthIds() {
    return watchEnergyDocuments().map((docs) {
      return docs.map((doc) => doc.id).toList();
    });
  }
}

/// Wrapper class for Firestore document
class EnergyDocument {
  final String id;
  final Map<String, dynamic> data;

  EnergyDocument({
    required this.id,
    required this.data,
  });
}

