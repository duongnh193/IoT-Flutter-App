/// Domain Entity for Scene
class SceneEntity {
  const SceneEntity({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = false,
  });

  final String id;
  final String name;
  final String description;
  final bool isActive;

  SceneEntity copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return SceneEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

