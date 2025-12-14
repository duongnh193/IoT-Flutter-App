import '../entities/room_entity.dart';

/// Repository interface for Room operations
abstract class RoomRepository {
  /// Get all rooms
  Future<List<RoomEntity>> getRooms();

  /// Get room by ID
  Future<RoomEntity?> getRoomById(String id);
}

