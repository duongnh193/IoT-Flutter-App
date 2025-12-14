import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

/// Use Case: Get all devices
/// Encapsulates business logic for fetching devices
class GetDevicesUseCase {
  const GetDevicesUseCase(this._repository);

  final DeviceRepository _repository;

  Future<List<DeviceEntity>> call() async {
    return await _repository.getDevices();
  }
}

