import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/room_model.dart' as room_model;
import '../di/device_dependencies.dart';
import '../presentation/mappers/room_mapper.dart';

/// Provider for rooms using Clean Architecture
final roomListProvider = FutureProvider<List<room_model.Room>>((ref) async {
  final useCase = ref.watch(getRoomsUseCaseProvider);
  final entities = await useCase();
  return entities.map((e) => RoomMapper.toPresentation(e)).toList();
});

/// Synchronous provider that unwraps FutureProvider
final roomsProvider = Provider<List<room_model.Room>>((ref) {
  final asyncValue = ref.watch(roomListProvider);
  return asyncValue.when(
    data: (rooms) => rooms,
    loading: () => <room_model.Room>[],
    error: (_, __) => <room_model.Room>[],
  );
});

/// Provider for single room by ID
final roomByIdProvider = Provider.family<room_model.Room?, String>((ref, roomId) {
  final rooms = ref.watch(roomsProvider);
  try {
    return rooms.firstWhere((room) => room.id == roomId);
  } catch (e) {
    return null;
  }
});
