import '../../domain/entities/device_type.dart';
import '../models/device_model.dart';

/// Local data source for devices
/// Uses in-memory storage for now (can be replaced with SharedPreferences, SQLite, etc.)
abstract class DeviceLocalDataSource {
  List<DeviceModel> getDevices();
  DeviceModel? getDeviceById(String id);
  List<DeviceModel> getDevicesByRoom(String roomId);
  DeviceModel updateDevice(DeviceModel device);
  DeviceModel toggleDevice(String id);
}

/// Mock implementation using the existing mock data
class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  static final List<DeviceModel> _devices = _createMockDevices();

  @override
  List<DeviceModel> getDevices() {
    return List.unmodifiable(_devices);
  }

  @override
  DeviceModel? getDeviceById(String id) {
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<DeviceModel> getDevicesByRoom(String roomId) {
    // Map room IDs to room names
    final roomNames = {
      'living': 'Phòng khách',
      'bedroom': 'Phòng ngủ',
      'bath': 'Phòng tắm',
      'gate': 'Cổng',
      'kitchen': 'Nhà bếp',
      'garden': 'Sân vườn',
    };
    
    final roomName = roomNames[roomId] ?? roomId;
    return _devices.where((device) => device.room == roomName).toList();
  }

  @override
  DeviceModel updateDevice(DeviceModel device) {
    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      _devices[index] = device;
      return device;
    }
    return device;
  }

  @override
  DeviceModel toggleDevice(String id) {
    final device = getDeviceById(id);
    if (device == null) {
      throw Exception('Device not found: $id');
    }
    final updatedDevice = device.copyWith(isOn: !device.isOn);
    return updateDevice(updatedDevice);
  }

  static List<DeviceModel> _createMockDevices() {
    // Convert existing mock devices to models
    return [
      // Phòng khách devices
      DeviceModel(
        id: 'door-living',
        name: 'Cửa Chính',
        type: DeviceType.lock,
        room: 'Phòng khách',
        isOn: true,
        power: 3.0,
      ),
      DeviceModel(
        id: 'light-living',
        name: 'Đèn trần',
        type: DeviceType.light,
        room: 'Phòng khách',
        isOn: true,
        power: 42.0,
      ),
      DeviceModel(
        id: 'air-purifier-living',
        name: 'Máy Lọc Không Khí',
        type: DeviceType.sensor,
        room: 'Phòng khách',
        isOn: false,
        power: 35.0,
      ),
      // Phòng ngủ devices 
      DeviceModel(
        id: 'curtain-bedroom',
        name: 'Rèm Cửa',
        type: DeviceType.curtain,
        room: 'Phòng ngủ',
        isOn: true,
        power: 5.0,
      ),
      DeviceModel(
        id: 'fan-bedroom',
        name: 'Quạt',
        type: DeviceType.fan,
        room: 'Phòng ngủ',
        isOn: true,
        power: 50.0,
      ),
      // Cổng 
      DeviceModel(
        id: 'gate-main',
        name: 'Cổng Chính',
        type: DeviceType.lock,
        room: 'Cổng',
        isOn: true,
        power: 3.0,
      ),
      // Other devices
      DeviceModel(
        id: 'camera-door',
        name: 'Camera cửa',
        type: DeviceType.camera,
        room: 'Sảnh vào',
        isOn: true,
        power: 12,
      ),
      DeviceModel(
        id: 'speaker-kitchen',
        name: 'Loa mini',
        type: DeviceType.speaker,
        room: 'Bếp',
        isOn: false,
        power: 18,
      ),
      DeviceModel(
        id: 'sensor-balcony',
        name: 'Cảm biến môi trường',
        type: DeviceType.sensor,
        room: 'Ban công',
        isOn: true,
        power: 6,
      ),
    ];
  }
}


