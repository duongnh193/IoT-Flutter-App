import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device.dart';

final deviceControllerProvider =
    StateNotifierProvider<DeviceController, List<Device>>(
  (ref) => DeviceController(),
);

final activeDevicesCountProvider = Provider<int>((ref) {
  final devices = ref.watch(deviceControllerProvider);
  return devices.where((device) => device.isOn).length;
});

final estimatedLoadProvider = Provider<double>((ref) {
  final devices = ref.watch(deviceControllerProvider);
  return devices
      .where((device) => device.isOn)
      .fold<double>(0, (sum, device) => sum + device.power);
});

class DeviceController extends StateNotifier<List<Device>> {
  DeviceController() : super(_mockDevices);

  void toggle(String id) {
    state = [
      for (final device in state)
        if (device.id == id)
          device.copyWith(isOn: !device.isOn)
        else
          device,
    ];
  }
}

const _mockDevices = [
  Device(
    id: 'light-living',
    name: 'Đèn trần',
    type: DeviceType.light,
    room: 'Phòng khách',
    isOn: true,
    power: 42.0,
  ),
  Device(
    id: 'ac-bedroom',
    name: 'Điều hòa',
    type: DeviceType.climate,
    room: 'Phòng ngủ chính',
    isOn: false,
    power: 950,
  ),
  Device(
    id: 'camera-door',
    name: 'Camera cửa',
    type: DeviceType.camera,
    room: 'Sảnh vào',
    isOn: true,
    power: 12,
  ),
  Device(
    id: 'lock-front',
    name: 'Khóa cửa',
    type: DeviceType.lock,
    room: 'Cửa chính',
    isOn: true,
    power: 3,
  ),
  Device(
    id: 'speaker-kitchen',
    name: 'Loa mini',
    type: DeviceType.speaker,
    room: 'Bếp',
    isOn: false,
    power: 18,
  ),
  Device(
    id: 'sensor-balcony',
    name: 'Cảm biến môi trường',
    type: DeviceType.sensor,
    room: 'Ban công',
    isOn: true,
    power: 6,
  ),
];
