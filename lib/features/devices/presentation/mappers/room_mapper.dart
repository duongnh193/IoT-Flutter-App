import '../../domain/entities/room_entity.dart';
import '../../data/models/room_model.dart';

/// Mapper to convert between Domain Entities and Presentation Models
class RoomMapper {
  /// Convert Domain Entity to Presentation Room
  static Room toPresentation(RoomEntity entity) {
    final model = RoomModel.fromEntity(entity);
    return model.toRoom();
  }

  /// Convert Presentation Room to Domain Entity
  static RoomEntity toDomain(Room room) {
    final model = RoomModel(
      id: room.id,
      name: room.name,
      iconCode: room.icon.codePoint,
      backgroundColorValue: room.background.toARGB32(),
      keywords: room.keywords ?? [],
    );
    return model.toEntity();
  }
}

