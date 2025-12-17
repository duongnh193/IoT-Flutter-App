import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_local_datasource.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/device_model.dart';

/// Implementation of DeviceRepository
/// Follows Clean Architecture by implementing domain interface
class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final DeviceRemoteDataSource remoteDataSource;
  final DeviceLocalDataSource localDataSource;

  @override
  Future<List<DeviceEntity>> getDevices() async {
    try {
      // Try remote first, fallback to local
      final remoteDevices = await remoteDataSource.getDevices();
      if (remoteDevices.isNotEmpty) {
        return remoteDevices.map((model) => model.toEntity()).toList();
      }
    } catch (e) {
      // Fallback to local on error
    }
    
    // Use local data source
    final localDevices = localDataSource.getDevices();
    return localDevices.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<DeviceEntity>> watchDevices() {
    // Return stream from Firebase, fallback to local if needed
    return remoteDataSource.watchDevices().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    ).handleError((error) {
      // On error, fallback to local data
      final localDevices = localDataSource.getDevices();
      return localDevices.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<DeviceEntity?> getDeviceById(String id) async {
    try {
      final remoteDevice = await remoteDataSource.getDeviceById(id);
      if (remoteDevice != null) {
        return remoteDevice.toEntity();
      }
    } catch (e) {
      // Fallback to local
    }
    
    final localDevice = localDataSource.getDeviceById(id);
    return localDevice?.toEntity();
  }

  @override
  Future<List<DeviceEntity>> getDevicesByRoom(String roomId) async {
    // For now, use local data source
    final devices = localDataSource.getDevicesByRoom(roomId);
    return devices.map((model) => model.toEntity()).toList();
  }

  @override
  Future<DeviceEntity> toggleDevice(String id) async {
    // Get current device state
    final currentDevice = await getDeviceById(id);
    if (currentDevice == null) {
      throw Exception('Device not found: $id');
    }

    final newState = !currentDevice.isOn;

    // Update Firebase directly (optimistic update)
    try {
      await remoteDataSource.updateDeviceState(id, newState);
    } catch (e) {
      // Handle error
      rethrow;
    }

    // Update local cache for offline support
    final updatedModel = DeviceModel.fromEntity(
      currentDevice.copyWith(isOn: newState),
    );
    localDataSource.updateDevice(updatedModel);

    return updatedModel.toEntity();
  }

  @override
  Future<DeviceEntity> updateDevice(DeviceEntity device) async {
    final model = DeviceModel.fromEntity(device);
    
    // Update local
    final updatedModel = localDataSource.updateDevice(model);
    
    // Sync to remote
    try {
      await remoteDataSource.updateDevice(updatedModel);
    } catch (e) {
      // Handle error
    }
    
    return updatedModel.toEntity();
  }

  @override
  Future<void> updateFanCommand(String deviceId, int command) async {
    try {
      await remoteDataSource.updateFanCommand(deviceId, command);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCurtainPosition(String deviceId, int position) async {
    try {
      await remoteDataSource.updateCurtainPosition(deviceId, position);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateLightCommand(String deviceId, int command) async {
    try {
      await remoteDataSource.updateLightCommand(deviceId, command);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePurifierCommand(String deviceId, int command) async {
    try {
      await remoteDataSource.updatePurifierCommand(deviceId, command);
    } catch (e) {
      rethrow;
    }
  }
}

