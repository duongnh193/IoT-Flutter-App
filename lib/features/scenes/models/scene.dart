class Scene {
  const Scene({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = false,
  });

  final String id;
  final String name;
  final String description;
  final bool isActive;

  Scene copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return Scene(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
