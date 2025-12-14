/// Domain Entity for Room
class RoomEntity {
  const RoomEntity({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.backgroundColorValue,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final int iconCode; // IconData code point
  final int backgroundColorValue; // Color value
  final List<String> keywords;

  RoomEntity copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? backgroundColorValue,
    List<String>? keywords,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      keywords: keywords ?? this.keywords,
    );
  }
}

