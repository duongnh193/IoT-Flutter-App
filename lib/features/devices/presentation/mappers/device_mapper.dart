import '../../domain/entities/device_entity.dart';
import '../../models/device.dart' as presentation;

/// Mapper to convert between Domain Entities and Presentation Models
/// This allows gradual migration while maintaining compatibility
class DeviceMapper {
  /// Convert Domain Entity to Presentation Model
  static presentation.Device toPresentation(DeviceEntity entity) {
    return presentation.Device(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      room: entity.room,
      isOn: entity.isOn,
      power: entity.power,
    );
  }

  /// Convert Presentation Model to Domain Entity
  static DeviceEntity toDomain(presentation.Device device) {
    return DeviceEntity(
      id: device.id,
      name: device.name,
      type: device.type,
      room: device.room,
      isOn: device.isOn,
      power: device.power,
    );
  }
}

