import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

/// Use Case: Get devices by room
class GetDevicesByRoomUseCase {
  const GetDevicesByRoomUseCase(this._repository);

  final DeviceRepository _repository;

  Future<List<DeviceEntity>> call(String roomId) async {
    return await _repository.getDevicesByRoom(roomId);
  }
}

