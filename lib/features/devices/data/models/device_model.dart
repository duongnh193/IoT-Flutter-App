import '../../domain/entities/device_entity.dart';
import '../../domain/entities/device_type.dart';

/// Data Transfer Object (DTO) for Device
/// Used for serialization/deserialization from data sources
class DeviceModel {
  const DeviceModel({
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

  /// Convert from JSON
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _deviceTypeFromString(json['type'] as String),
      room: json['room'] as String,
      isOn: json['isOn'] as bool? ?? false,
      power: (json['power'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'room': room,
      'isOn': isOn,
      'power': power,
    };
  }

  /// Convert to Domain Entity
  DeviceEntity toEntity() {
    return DeviceEntity(
      id: id,
      name: name,
      type: type,
      room: room,
      isOn: isOn,
      power: power,
    );
  }

  /// Create from Domain Entity
  factory DeviceModel.fromEntity(DeviceEntity entity) {
    return DeviceModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      room: entity.room,
      isOn: entity.isOn,
      power: entity.power,
    );
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    DeviceType? type,
    String? room,
    bool? isOn,
    double? power,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      power: power ?? this.power,
    );
  }

  static DeviceType _deviceTypeFromString(String value) {
    return DeviceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeviceType.light,
    );
  }
}

