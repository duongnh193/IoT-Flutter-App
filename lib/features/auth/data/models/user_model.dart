import '../../domain/entities/user_entity.dart';

/// Data Transfer Object (DTO) for User
class UserModel {
  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  final String id;
  final String phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isEmailVerified;

  /// Convert to Domain Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      phoneNumber: phoneNumber,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
    );
  }

  /// Create from Domain Entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      phoneNumber: entity.phoneNumber,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      isEmailVerified: entity.isEmailVerified,
    );
  }
}

