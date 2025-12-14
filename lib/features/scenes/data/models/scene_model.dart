import '../../domain/entities/scene_entity.dart';

/// Data Transfer Object (DTO) for Scene
class SceneModel {
  const SceneModel({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = false,
  });

  final String id;
  final String name;
  final String description;
  final bool isActive;

  /// Convert to Domain Entity
  SceneEntity toEntity() {
    return SceneEntity(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
    );
  }

  /// Create from Domain Entity
  factory SceneModel.fromEntity(SceneEntity entity) {
    return SceneModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
    );
  }

  SceneModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return SceneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

