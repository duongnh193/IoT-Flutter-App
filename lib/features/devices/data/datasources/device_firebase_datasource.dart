import 'package:firebase_database/firebase_database.dart';

import '../models/device_model.dart';
import '../../domain/entities/device_type.dart';

/// Firebase Realtime Database implementation for devices
class DeviceFirebaseDataSource {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Listen to realtime changes for all devices
  Stream<List<DeviceModel>> watchDevices() {
    return _database.onValue.map((event) {
      if (event.snapshot.value == null) return <DeviceModel>[];
      
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return _parseFirebaseData(data);
    });
  }

  /// Get devices once (for initial load)
  Future<List<DeviceModel>> getDevices() async {
    final snapshot = await _database.get();
    if (!snapshot.exists) return [];
    
    final data = snapshot.value as Map<dynamic, dynamic>?;
    return data != null ? _parseFirebaseData(data) : [];
  }

  /// Get device by ID
  Future<DeviceModel?> getDeviceById(String id) async {
    final path = _getDevicePath(id);
    if (path == null) return null;
    
    final snapshot = await _database.child(path).get();
    if (!snapshot.exists) return null;
    
    final data = snapshot.value as Map<dynamic, dynamic>;
    return _deviceModelFromFirebase(id, data);
  }

  /// Watch raw Firebase data for a specific device
  Stream<Map<dynamic, dynamic>?> watchDeviceData(String id) {
    final path = _getDevicePath(id);
    if (path == null) {
      return Stream.value(null);
    }
    
    return _database.child(path).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return null;
      }
      return event.snapshot.value as Map<dynamic, dynamic>;
    });
  }

  /// Update device state in Firebase
  /// If devicePath is empty, updates are treated as root-level paths
  Future<void> updateDevice(String devicePath, Map<String, dynamic> updates) async {
    if (devicePath.isEmpty) {
      // Multiple paths update (e.g., {'bedroom/curtain/position': 100, 'bedroom/curtain/target_pos': 100})
      await _database.update(updates);
    } else {
      // Single path update
      await _database.child(devicePath).update(updates);
    }
  }

  /// Set fan command using PUT (for firmware compatibility)
  /// Uses set() instead of update() to send HTTP PUT request
  Future<void> setFanCommand(String path, int command) async {
    await _database.child(path).set(command);
  }

  /// Set curtain position using PUT (for firmware compatibility)
  /// Uses set() instead of update() to send HTTP PUT request
  Future<void> setCurtainPosition(String path, int position) async {
    await _database.child(path).set(position);
  }

  /// Get Firebase path for fan command
  String? getFanCommandPath(String deviceId) {
    switch (deviceId) {
      case 'fan-bedroom':
        return 'bedroom/fan/command';
      default:
        return null;
    }
  }

  /// Get Firebase path for curtain position
  String? getCurtainPositionPath(String deviceId) {
    switch (deviceId) {
      case 'curtain-bedroom':
        return 'bedroom/curtain/position';
      default:
        return null;
    }
  }

  /// Get Firebase path for a device ID
  String? _getDevicePath(String deviceId) {
    switch (deviceId) {
      case 'curtain-bedroom':
        return 'bedroom/curtain';
      case 'fan-bedroom':
        return 'bedroom/fan';
      case 'gate-main':
        return 'gate';
      case 'door-living':
        return 'living_room/door';
      case 'light-living':
        return 'living_room/light';
      case 'air-purifier-living':
        return 'living_room/purifier';
      default:
        return null;
    }
  }

  /// Parse Firebase structure to DeviceModel list
  List<DeviceModel> _parseFirebaseData(Map<dynamic, dynamic> data) {
    final List<DeviceModel> devices = [];

    // Parse bedroom devices
    if (data['bedroom'] != null) {
      final bedroom = data['bedroom'] as Map<dynamic, dynamic>;
      
      // Curtain
      if (bedroom['curtain'] != null) {
        final curtain = bedroom['curtain'] as Map<dynamic, dynamic>;
        // target_pos: Vị trí thực tế từ phần cứng (0-100)
        // position: Command từ UI (không dùng để parse state)
        final targetPos = curtain['target_pos'] as int? ?? 0;
        devices.add(DeviceModel(
          id: 'curtain-bedroom',
          name: 'Rèm Cửa',
          type: DeviceType.curtain,
          room: 'Phòng ngủ',
          isOn: targetPos > 0,
          power: 5.0,
        ));
      }
      
      // Fan
      if (bedroom['fan'] != null) {
        final fan = bedroom['fan'] as Map<dynamic, dynamic>;
        // mode: Chế độ thực tế từ phần cứng (0 = tắt, 1,2,3 = tốc độ)
        // command: Command từ UI (không dùng để parse state)
        final mode = fan['mode'] as int? ?? 0;
        devices.add(DeviceModel(
          id: 'fan-bedroom',
          name: 'Quạt',
          type: DeviceType.fan,
          room: 'Phòng ngủ',
          isOn: mode > 0,
          power: 50.0,
        ));
      }
    }

    // Parse gate
    if (data['gate'] != null) {
      final gate = data['gate'] as Map<dynamic, dynamic>;
      devices.add(DeviceModel(
        id: 'gate-main',
        name: 'Cổng Chính',
        type: DeviceType.lock,
        room: 'Cổng',
        isOn: gate['is_open'] as bool? ?? false,
        power: 3.0,
      ));
    }

    // Parse living_room devices
    if (data['living_room'] != null) {
      final livingRoom = data['living_room'] as Map<dynamic, dynamic>;
      
      // Door
      if (livingRoom['door'] != null) {
        final door = livingRoom['door'] as Map<dynamic, dynamic>;
        devices.add(DeviceModel(
          id: 'door-living',
          name: 'Cửa Chính',
          type: DeviceType.lock,
          room: 'Phòng khách',
          isOn: door['is_open'] as bool? ?? false,
          power: 3.0,
        ));
      }
      
      // Light
      if (livingRoom['light'] != null) {
        final light = livingRoom['light'] as Map<dynamic, dynamic>;
        final command = light['command'] as int? ?? 0;
        devices.add(DeviceModel(
          id: 'light-living',
          name: 'Đèn trần',
          type: DeviceType.light,
          room: 'Phòng khách',
          isOn: command > 0,
          power: 42.0,
        ));
      }
      
      // Purifier
      if (livingRoom['purifier'] != null) {
        final purifier = livingRoom['purifier'] as Map<dynamic, dynamic>;
        devices.add(DeviceModel(
          id: 'air-purifier-living',
          name: 'Máy Lọc Không Khí',
          type: DeviceType.sensor,
          room: 'Phòng khách',
          isOn: purifier['state'] as bool? ?? false,
          power: 35.0,
        ));
      }
    }

    return devices;
  }

  /// Create DeviceModel from Firebase data for a specific device
  DeviceModel? _deviceModelFromFirebase(String id, Map<dynamic, dynamic> data) {
    switch (id) {
      case 'curtain-bedroom':
        // target_pos: Vị trí thực tế từ phần cứng
        final targetPos = data['target_pos'] as int? ?? 0;
        return DeviceModel(
          id: id,
          name: 'Rèm Cửa',
          type: DeviceType.curtain,
          room: 'Phòng ngủ',
          isOn: targetPos > 0,
          power: 5.0,
        );
      case 'fan-bedroom':
        // mode: Chế độ thực tế từ phần cứng
        final mode = data['mode'] as int? ?? 0;
        return DeviceModel(
          id: id,
          name: 'Quạt',
          type: DeviceType.fan,
          room: 'Phòng ngủ',
          isOn: mode > 0,
          power: 50.0,
        );
      case 'gate-main':
        return DeviceModel(
          id: id,
          name: 'Cổng Chính',
          type: DeviceType.lock,
          room: 'Cổng',
          isOn: data['is_open'] as bool? ?? false,
          power: 3.0,
        );
      case 'door-living':
        return DeviceModel(
          id: id,
          name: 'Cửa Chính',
          type: DeviceType.lock,
          room: 'Phòng khách',
          isOn: data['is_open'] as bool? ?? false,
          power: 3.0,
        );
      case 'light-living':
        final command = data['command'] as int? ?? 0;
        return DeviceModel(
          id: id,
          name: 'Đèn trần',
          type: DeviceType.light,
          room: 'Phòng khách',
          isOn: command > 0,
          power: 42.0,
        );
      case 'air-purifier-living':
        return DeviceModel(
          id: id,
          name: 'Máy Lọc Không Khí',
          type: DeviceType.sensor,
          room: 'Phòng khách',
          isOn: data['state'] as bool? ?? false,
          power: 35.0,
        );
      default:
        return null;
    }
  }

  /// Get Firebase update map for device toggle
  Map<String, dynamic> getDeviceToggleUpdates(String deviceId, bool newState) {
    switch (deviceId) {
      case 'curtain-bedroom':
        // Only update 'position' (command from UI)
        // 'target_pos' will be updated by hardware based on actual position
        return {
          'bedroom/curtain/position': newState ? 100 : 0,
        };
      case 'fan-bedroom':
        return {
          'bedroom/fan/command': newState ? 1 : 0,
        };
      case 'gate-main':
        return {
          'gate/is_open': newState,
          'gate/command': newState ? 'OPEN' : 'CLOSE',
          'gate/last_updated': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };
      case 'door-living':
        return {
          'living_room/door/is_open': newState,
          'living_room/door/command': newState ? 1 : 0,
        };
      case 'light-living':
        return {
          'living_room/light/command': newState ? 1 : 0,
        };
      case 'air-purifier-living':
        return {
          'living_room/purifier/state': newState,
          'living_room/purifier/command': newState ? 1 : 0,
        };
      default:
        return {};
    }
  }

  /// Update fan command (0 = off, 1,2,3 = speed levels)
  Map<String, dynamic> getFanCommandUpdates(String deviceId, int command) {
    switch (deviceId) {
      case 'fan-bedroom':
        return {
          'bedroom/fan/command': command,
        };
      default:
        return {};
    }
  }

  /// Update curtain position (0-100)
  Map<String, dynamic> getCurtainPositionUpdates(String deviceId, int position) {
    switch (deviceId) {
      case 'curtain-bedroom':
        return {
          'bedroom/curtain/position': position,
        };
      default:
        return {};
    }
  }
}

