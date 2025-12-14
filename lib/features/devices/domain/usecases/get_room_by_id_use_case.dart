import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

/// Use Case: Get room by ID
class GetRoomByIdUseCase {
  const GetRoomByIdUseCase(this._repository);

  final RoomRepository _repository;

  Future<RoomEntity?> call(String id) async {
    return await _repository.getRoomById(id);
  }
}

