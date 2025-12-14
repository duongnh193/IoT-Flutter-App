import 'package:flutter/material.dart';

import '../domain/entities/device_type.dart';

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    this.isOn = false,
    this.power = 0,
  });

  final String id;
  final String name;
  final DeviceType type;
  final String room;
  final bool isOn;
  final double power;

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    String? room,
    bool? isOn,
    double? power,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      power: power ?? this.power,
    );
  }
}

extension DeviceTypeX on DeviceType {
  IconData get icon {
    switch (this) {
      case DeviceType.light:
        return Icons.lightbulb_outline;
      case DeviceType.climate:
        return Icons.ac_unit_outlined;
      case DeviceType.camera:
        return Icons.videocam_outlined;
      case DeviceType.lock:
        return Icons.lock_outline;
      case DeviceType.speaker:
        return Icons.speaker_outlined;
      case DeviceType.sensor:
        return Icons.sensors;
      case DeviceType.curtain:
        return Icons.curtains;
      case DeviceType.fan:
        return Icons.toys;
      case DeviceType.ac:
        return Icons.ac_unit;
      case DeviceType.socket:
        return Icons.power_outlined;
    }
  }

  String get label {
    switch (this) {
      case DeviceType.light:
        return 'Đèn';
      case DeviceType.climate:
        return 'Nhiệt độ';
      case DeviceType.camera:
        return 'Camera';
      case DeviceType.lock:
        return 'Khóa';
      case DeviceType.speaker:
        return 'Loa';
      case DeviceType.sensor:
        return 'Cảm biến';
      case DeviceType.curtain:
        return 'Rèm';
      case DeviceType.fan:
        return 'Quạt';
      case DeviceType.ac:
        return 'Điều hòa';
      case DeviceType.socket:
        return 'Ổ cắm';
    }
  }
}
