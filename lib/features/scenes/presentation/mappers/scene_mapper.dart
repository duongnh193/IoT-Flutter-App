import '../../domain/entities/scene_entity.dart';
import '../../models/scene.dart' as presentation;

/// Mapper to convert between Domain Entities and Presentation Models
class SceneMapper {
  /// Convert Domain Entity to Presentation Model
  static presentation.Scene toPresentation(SceneEntity entity) {
    return presentation.Scene(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
    );
  }

  /// Convert Presentation Model to Domain Entity
  static SceneEntity toDomain(presentation.Scene scene) {
    return SceneEntity(
      id: scene.id,
      name: scene.name,
      description: scene.description,
      isActive: scene.isActive,
    );
  }
}

