import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

/// Use Case: Get device by ID
class GetDeviceByIdUseCase {
  const GetDeviceByIdUseCase(this._repository);

  final DeviceRepository _repository;

  Future<DeviceEntity?> call(String id) async {
    return await _repository.getDeviceById(id);
  }
}

