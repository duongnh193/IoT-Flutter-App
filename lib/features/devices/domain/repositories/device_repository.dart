import 'dart:async';

import '../entities/device_entity.dart';

/// Repository interface for Device operations
/// Domain layer should depend on abstractions, not implementations
abstract class DeviceRepository {
  /// Get all devices
  Future<List<DeviceEntity>> getDevices();

  /// Watch devices for real-time updates
  Stream<List<DeviceEntity>> watchDevices();

  /// Get device by ID
  Future<DeviceEntity?> getDeviceById(String id);

  /// Get devices by room
  Future<List<DeviceEntity>> getDevicesByRoom(String roomId);

  /// Toggle device state
  Future<DeviceEntity> toggleDevice(String id);

  /// Update device
  Future<DeviceEntity> updateDevice(DeviceEntity device);

  /// Update fan command (0 = off, 1,2,3 = speed levels)
  Future<void> updateFanCommand(String deviceId, int command);

  /// Update curtain position (0-100)
  Future<void> updateCurtainPosition(String deviceId, int position);

  /// Update light command (0 = tắt, 1 = tiết kiệm, 2 = vừa, 3 = sáng)
  Future<void> updateLightCommand(String deviceId, int command);

  /// Update purifier command (0 = tắt, 1 = bật)
  Future<void> updatePurifierCommand(String deviceId, int command);
}

