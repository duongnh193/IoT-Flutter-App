import 'dart:async';

import '../models/device_model.dart';
import 'device_firebase_datasource.dart';

/// Remote data source for devices
/// Supports Firebase Realtime Database for real-time updates
abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getDevices();
  Stream<List<DeviceModel>> watchDevices();
  Future<DeviceModel?> getDeviceById(String id);
  Future<DeviceModel> updateDevice(DeviceModel device);
  Future<void> updateDeviceState(String deviceId, bool newState);
  
  /// Update fan command (0 = off, 1,2,3 = speed levels)
  Future<void> updateFanCommand(String deviceId, int command);
  
  /// Update curtain position (0-100)
  Future<void> updateCurtainPosition(String deviceId, int position);

  /// Update light command (0 = tắt, 1 = tiết kiệm, 2 = vừa, 3 = sáng)
  Future<void> updateLightCommand(String deviceId, int command);
  
  /// Watch raw Firebase data for a specific device
  Stream<Map<dynamic, dynamic>?> watchDeviceData(String id);
}

/// Firebase Realtime Database implementation
class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  DeviceRemoteDataSourceImpl(this._firebaseDataSource);

  final DeviceFirebaseDataSource _firebaseDataSource;

  @override
  Future<List<DeviceModel>> getDevices() async {
    return await _firebaseDataSource.getDevices();
  }

  @override
  Stream<List<DeviceModel>> watchDevices() {
    return _firebaseDataSource.watchDevices();
  }

  @override
  Future<DeviceModel?> getDeviceById(String id) async {
    return await _firebaseDataSource.getDeviceById(id);
  }

  @override
  Future<DeviceModel> updateDevice(DeviceModel device) async {
    final updates = _firebaseDataSource.getDeviceToggleUpdates(
      device.id,
      device.isOn,
    );
    await _firebaseDataSource.updateDevice('', updates);
    return device;
  }

  @override
  Future<void> updateDeviceState(String deviceId, bool newState) async {
    final updates = _firebaseDataSource.getDeviceToggleUpdates(
      deviceId,
      newState,
    );
    // Update Firebase with all changes at once
    await _firebaseDataSource.updateDevice('', updates);
  }

  @override
  Future<void> updateFanCommand(String deviceId, int command) async {
    // Use PUT (set) instead of PATCH (update) for firmware compatibility
    final path = _firebaseDataSource.getFanCommandPath(deviceId);
    if (path != null) {
      await _firebaseDataSource.setFanCommand(path, command);
    } else {
      // Fallback to update method for other devices
      final updates = _firebaseDataSource.getFanCommandUpdates(deviceId, command);
      await _firebaseDataSource.updateDevice('', updates);
    }
  }

  @override
  Future<void> updateCurtainPosition(String deviceId, int position) async {
    // Use PUT (set) instead of PATCH (update) for firmware compatibility
    final path = _firebaseDataSource.getCurtainPositionPath(deviceId);
    if (path != null) {
      await _firebaseDataSource.setCurtainPosition(path, position);
    } else {
      // Fallback to update method for other devices
      final updates = _firebaseDataSource.getCurtainPositionUpdates(deviceId, position);
      await _firebaseDataSource.updateDevice('', updates);
    }
  }

  @override
  Future<void> updateLightCommand(String deviceId, int command) async {
    // Use PUT (set) instead of PATCH (update) for firmware compatibility
    final path = _firebaseDataSource.getLightCommandPath(deviceId);
    if (path != null) {
      await _firebaseDataSource.setLightCommand(path, command);
    } else {
      // Fallback to update method for other devices
      final updates = _firebaseDataSource.getLightCommandUpdates(deviceId, command);
      await _firebaseDataSource.updateDevice('', updates);
    }
  }

  @override
  Stream<Map<dynamic, dynamic>?> watchDeviceData(String id) {
    return _firebaseDataSource.watchDeviceData(id);
  }
}

