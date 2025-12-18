import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/rfid_card_firestore_datasource.dart';

/// Provider for RFID card Firestore datasource
final rfidCardFirestoreDataSourceProvider =
    Provider<RfidCardFirestoreDataSource>((ref) {
  return RfidCardFirestoreDataSource();
});

/// Provider to watch all RFID cards
final rfidCardsProvider =
    StreamProvider<List<RfidCardDocument>>((ref) {
  final datasource = ref.watch(rfidCardFirestoreDataSourceProvider);
  return datasource.watchRfidCards();
});

/// Provider to watch unnamed cards (owner_name == "Chưa đặt tên")
final unnamedRfidCardsProvider =
    StreamProvider<List<RfidCardDocument>>((ref) {
  final datasource = ref.watch(rfidCardFirestoreDataSourceProvider);
  return datasource.watchUnnamedCards();
});

/// Provider to watch named cards (owner_name != "Chưa đặt tên")
/// Fetches data immediately, then streams real-time updates
final namedRfidCardsProvider =
    StreamProvider<List<RfidCardDocument>>((ref) {
  final datasource = ref.watch(rfidCardFirestoreDataSourceProvider);
  
  // Create a stream that first fetches data immediately, then streams updates
  return _createEagerStream(datasource, ref);
});

Stream<List<RfidCardDocument>> _createEagerStream(
  RfidCardFirestoreDataSource datasource,
  Ref ref,
) async* {
  // First, fetch data immediately to avoid loading delay
  try {
    final allCards = await datasource.getRfidCards();
    final namedCards = allCards.where((card) => card.ownerName != 'Chưa đặt tên').toList();
    yield namedCards;
  } catch (e) {
    // If fetch fails, yield empty list
    yield [];
  }
  
  // Then stream real-time updates
  await for (final allCards in datasource.watchRfidCards()) {
    final namedCards = allCards.where((card) => card.ownerName != 'Chưa đặt tên').toList();
    yield namedCards;
  }
}

/// Provider to track if we're currently in "add card" mode
final isAddingCardProvider = StateProvider<bool>((ref) {
  return false;
});

