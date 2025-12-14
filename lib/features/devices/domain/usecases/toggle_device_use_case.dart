import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

/// Use Case: Toggle device state
/// Contains business logic for toggling device on/off
class ToggleDeviceUseCase {
  const ToggleDeviceUseCase(this._repository);

  final DeviceRepository _repository;

  Future<DeviceEntity> call(String id) async {
    final device = await _repository.getDeviceById(id);
    if (device == null) {
      throw Exception('Device not found: $id');
    }
    return await _repository.toggleDevice(id);
  }
}

