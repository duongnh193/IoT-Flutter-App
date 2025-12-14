import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

/// Use Case: Get all rooms
class GetRoomsUseCase {
  const GetRoomsUseCase(this._repository);

  final RoomRepository _repository;

  Future<List<RoomEntity>> call() async {
    return await _repository.getRooms();
  }
}

