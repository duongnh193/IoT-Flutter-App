import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../domain/entities/device_type.dart';
import '../models/device.dart';
import '../data/models/room_model.dart' as room_model;

class DeviceEntry {
  const DeviceEntry({
    required this.roomId,
    required this.device,
    required this.status,
    this.isPlaceholder = false,
  });

  final String roomId;
  final Device device;
  final String status;
  final bool isPlaceholder;
}

final demoRooms = [
  room_model.Room(
    id: 'living',
    name: 'Phòng khách',
    icon: Icons.weekend_outlined,
    background: AppColors.roomPeach,
    keywords: ['phòng khách', 'living'],
  ),
  room_model.Room(
    id: 'bedroom',
    name: 'Phòng ngủ',
    icon: Icons.bed_outlined,
    background: AppColors.roomSky,
    keywords: ['phòng ngủ'],
  ),
  room_model.Room(
    id: 'bath',
    name: 'Phòng tắm',
    icon: Icons.bathtub_outlined,
    background: AppColors.roomLavender,
    keywords: ['phòng tắm', 'bath'],
  ),
  room_model.Room(
    id: 'gate',
    name: 'Cổng',
    icon: Icons.garage_outlined,
    background: AppColors.roomMint,
    keywords: ['cổng', 'gate'],
  ),
  room_model.Room(
    id: 'kitchen',
    name: 'Nhà bếp',
    icon: Icons.kitchen_outlined,
    background: AppColors.roomMint,
    keywords: ['bếp', 'kitchen'],
  ),
  room_model.Room(
    id: 'garden',
    name: 'Sân vườn',
    icon: Icons.yard_outlined,
    background: AppColors.roomPeach,
    keywords: ['sân', 'vườn', 'garden'],
  ),
];

const demoDevices = [
  // Living room devices
  DeviceEntry(
    roomId: 'living',
    device: Device(
      id: 'door-living',
      name: 'Cửa Chính',
      type: DeviceType.lock,
      room: 'Phòng khách',
      isOn: true,
    ),
    status: 'Đang Mở',
  ),
  DeviceEntry(
    roomId: 'living',
    device: Device(
      id: 'light-living',
      name: 'Đèn',
      type: DeviceType.light,
      room: 'Phòng khách',
      isOn: true,
    ),
    status: 'Đang bật',
  ),
  DeviceEntry(
    roomId: 'living',
    device: Device(
      id: 'socket-living',
      name: 'Ổ cắm',
      type: DeviceType.socket,
      room: 'Phòng khách',
      isOn: false,
    ),
    status: 'Đang Dừng',
  ),
  DeviceEntry(
    roomId: 'living',
    device: Device(
      id: 'tv-living',
      name: 'TV',
      type: DeviceType.speaker,
      room: 'Phòng khách',
      isOn: false,
    ),
    status: 'Đang tắt',
    isPlaceholder: true,
  ),
  DeviceEntry(
    roomId: 'bedroom',
    device: Device(
      id: 'curtain-bedroom',
      name: 'Rèm Cửa',
      type: DeviceType.curtain,
      room: 'Phòng ngủ',
      isOn: true,
    ),
    status: 'Đang mở 40%',
  ),
  DeviceEntry(
    roomId: 'bedroom',
    device: Device(
      id: 'fan-bedroom',
      name: 'Quạt',
      type: DeviceType.fan,
      room: 'Phòng ngủ',
      isOn: true,
    ),
    status: 'Đang bật',
  ),
  DeviceEntry(
    roomId: 'bedroom',
    device: Device(
      id: 'ac-bedroom',
      name: 'Điều hòa',
      type: DeviceType.ac,
      room: 'Phòng ngủ',
      isOn: true,
    ),
    status: 'Đang bật',
  ),
  DeviceEntry(
    roomId: 'bath',
    device: Device(
      id: 'light-bath',
      name: 'Đèn',
      type: DeviceType.light,
      room: 'Phòng tắm',
      isOn: true,
    ),
    status: 'Đang bật',
    isPlaceholder: true,
  ),
  DeviceEntry(
    roomId: 'bath',
    device: Device(
      id: 'heater-bath',
      name: 'Máy nước nóng',
      type: DeviceType.climate,
      room: 'Phòng tắm',
      isOn: false,
    ),
    status: 'Đang tắt',
    isPlaceholder: true,
  ),
  // Gate room - Main Gate device
  DeviceEntry(
    roomId: 'gate',
    device: Device(
      id: 'gate-main',
      name: 'Cổng Chính',
      type: DeviceType.lock,
      room: 'Cổng',
      isOn: true,
    ),
    status: 'Đang Mở',
  ),
  DeviceEntry(
    roomId: 'kitchen',
    device: Device(
      id: 'light-kitchen',
      name: 'Đèn',
      type: DeviceType.light,
      room: 'Nhà bếp',
      isOn: true,
    ),
    status: 'Đang bật',
    isPlaceholder: true,
  ),
  DeviceEntry(
    roomId: 'kitchen',
    device: Device(
      id: 'hood-kitchen',
      name: 'Máy hút mùi',
      type: DeviceType.sensor,
      room: 'Nhà bếp',
      isOn: false,
    ),
    status: 'Đang tắt',
    isPlaceholder: true,
  ),
  DeviceEntry(
    roomId: 'garden',
    device: Device(
      id: 'light-garden',
      name: 'Đèn sân',
      type: DeviceType.light,
      room: 'Sân vườn',
      isOn: true,
    ),
    status: 'Đang bật',
    isPlaceholder: true,
  ),
  DeviceEntry(
    roomId: 'garden',
    device: Device(
      id: 'sprinkler-garden',
      name: 'Tưới cây',
      type: DeviceType.sensor,
      room: 'Sân vườn',
      isOn: false,
    ),
    status: 'Đang tắt',
    isPlaceholder: true,
  ),
];

room_model.Room? findRoomById(String roomId) {
  for (final room in demoRooms) {
    if (room.id == roomId) return room;
  }
  return null;
}

List<DeviceEntry> devicesForRoom(String roomId) {
  return demoDevices.where((entry) => entry.roomId == roomId).toList();
}

DeviceEntry? deviceById(String deviceId) {
  for (final entry in demoDevices) {
    if (entry.device.id == deviceId) return entry;
  }
  return null;
}
