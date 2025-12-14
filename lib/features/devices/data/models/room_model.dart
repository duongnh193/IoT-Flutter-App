import 'package:flutter/material.dart';

import '../../domain/entities/room_entity.dart';

/// Data Transfer Object (DTO) for Room
class RoomModel {
  const RoomModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.backgroundColorValue,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final int iconCode;
  final int backgroundColorValue;
  final List<String> keywords;

  /// Convert to Domain Entity
  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      name: name,
      iconCode: iconCode,
      backgroundColorValue: backgroundColorValue,
      keywords: keywords,
    );
  }

  /// Create from Domain Entity
  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      name: entity.name,
      iconCode: entity.iconCode,
      backgroundColorValue: entity.backgroundColorValue,
      keywords: entity.keywords,
    );
  }

  /// Convert to Flutter Room (for presentation layer compatibility)
  Room toRoom() {
    return Room(
      id: id,
      name: name,
      icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
      background: Color(backgroundColorValue),
      keywords: keywords,
    );
  }
}

/// Temporary compatibility class for presentation layer
/// TODO: Remove this after full migration
class Room {
  const Room({
    required this.id,
    required this.name,
    required this.icon,
    required this.background,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final IconData icon;
  final Color background;
  final List<String>? keywords;
}

