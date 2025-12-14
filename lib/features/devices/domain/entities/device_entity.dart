import 'device_type.dart';

/// Domain Entity for Device
/// This represents the core business object, independent of data sources
class DeviceEntity {
  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    this.isOn = false,
    this.power = 0.0,
  });

  final String id;
  final String name;
  final DeviceType type;
  final String room;
  final bool isOn;
  final double power;

  DeviceEntity copyWith({
    String? id,
    String? name,
    DeviceType? type,
    String? room,
    bool? isOn,
    double? power,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      power: power ?? this.power,
    );
  }
}

